"""Known-map localization and grid-based range-only SLAM, without truth inputs."""
import numpy as np

LANDMARKS = np.array([[0., 0.], [6., 0.], [0., 6.]])
COMMANDS = np.repeat([[.25, 0.], [0., .25], [-.25, 0.], [0., -.25]], 8, axis=0)


def vector(value, shape):
    value = np.asarray(value, dtype=float)
    if value.shape != shape or not np.isfinite(value).all():
        raise ValueError(f'Expected finite array of shape {shape}')
    return value


def ranges(points, landmarks=LANDMARKS):
    return np.linalg.norm(np.asarray(points)[..., None, :] - landmarks, axis=-1)


class ParticleFilter:
    def __init__(self, rng, sensor_sigma=.15, count=500):
        if sensor_sigma not in (.15, .6) or not isinstance(count, int) or count < 1:
            raise ValueError('Use positive particle count and sensor sigma 0.15 or 0.6')
        self.rng = rng
        self.sigma = sensor_sigma
        self.landmarks = LANDMARKS.copy()
        self.particles = rng.normal([2., 2.], .6, (count, 2))
        self.weights = np.full(count, 1 / count)

    def predict(self, command):
        command = vector(command, (2,))
        self.particles += command + self.rng.normal(0, .08, self.particles.shape)

    def correct(self, observation):
        observation = vector(observation, (3,))
        residual = (ranges(self.particles, self.landmarks) - observation) / self.sigma
        with np.errstate(over='ignore', divide='ignore', invalid='ignore'):
            logs = np.log(self.weights) - .5 * np.sum(residual ** 2, axis=1)
            peak = np.max(logs)
            weights = np.exp(logs - peak)
        if not np.isfinite(weights).all() or weights.sum() <= 0:
            raise ValueError('Invalid observation likelihoods: cannot normalize weights')
        self.weights = weights / weights.sum()

    def resample(self):
        n = len(self.weights)
        positions = (self.rng.random() + np.arange(n)) / n
        cumulative = np.cumsum(self.weights)
        cumulative[-1] = 1.
        indices = np.searchsorted(cumulative, positions, side='right')
        self.particles = self.particles[indices].copy()
        self.weights.fill(1 / n)
        return indices

    @property
    def estimate(self):
        return np.average(self.particles, weights=self.weights, axis=0)


class RangeOnlySLAM(ParticleFilter):
    """Robot particles with independent landmark grids conditional on each path.

    The bounded, uniform map prior is independent of simulator landmark positions.
    Fixed heading and identified landmarks keep this a position-only SLAM model.
    """

    def __init__(self, rng, sensor_sigma=.15, count=500, grid_axis=None):
        if sensor_sigma not in (.15, .6) or not isinstance(count, int) or count < 1:
            raise ValueError('Use positive particle count and sensor sigma 0.15 or 0.6')
        self.rng, self.sigma = rng, sensor_sigma
        self.particles = rng.normal([2., 2.], .6, (count, 2))
        self.weights = np.full(count, 1 / count)
        self.grid_axis = np.linspace(-2., 8., 81) if grid_axis is None else np.asarray(grid_axis, dtype=float).copy()
        if (self.grid_axis.ndim != 1 or len(self.grid_axis) < 2
                or not np.isfinite(self.grid_axis).all()
                or not np.all(np.diff(self.grid_axis) > 0)):
            raise ValueError('Grid axis must contain increasing finite coordinates')
        xx, yy = np.meshgrid(self.grid_axis, self.grid_axis)
        self.grid_points = np.column_stack([xx.ravel(), yy.ravel()])
        cells = len(self.grid_points)
        self.map_probs = np.full((count, 3, cells), 1 / cells, dtype=np.float64)
        self.last_log_evidence = None

    @staticmethod
    def _normalize_logs(logs):
        peak = np.max(logs, axis=-1, keepdims=True)
        if not np.isfinite(peak).all():
            raise ValueError('Invalid SLAM likelihoods: no finite probability mass')
        values = np.exp(logs - peak)
        total = values.sum(axis=-1, keepdims=True)
        if not np.isfinite(total).all() or np.any(total <= 0):
            raise ValueError('Invalid SLAM likelihoods: cannot normalize')
        return values / total, (peak + np.log(total)).squeeze(axis=-1)

    def correct(self, observation):
        observation = vector(observation, (3,))
        updated = np.empty_like(self.map_probs)
        evidence = np.empty((len(self.weights), 3))
        # Each batch uses a modest distance matrix, not a full N x J x G tensor.
        for begin in range(0, len(self.weights), 32):
            end = min(begin + 32, len(self.weights))
            delta = self.particles[begin:end, None, :] - self.grid_points[None, :, :]
            predicted = np.sqrt(np.sum(delta * delta, axis=-1))
            for landmark in range(3):
                with np.errstate(divide='ignore', over='ignore', invalid='ignore'):
                    logs = (np.log(self.map_probs[begin:end, landmark])
                            - .5 * ((observation[landmark] - predicted) / self.sigma) ** 2
                            - np.log(self.sigma * np.sqrt(2 * np.pi)))
                updated[begin:end, landmark], evidence[begin:end, landmark] = self._normalize_logs(logs)
        # Evidence is integrated against OLD maps, before the map update.
        with np.errstate(divide='ignore'):
            weights, _ = self._normalize_logs(np.log(self.weights) + evidence.sum(axis=1))
        self.map_probs, self.weights = updated, weights
        self.last_log_evidence = evidence

    def resample(self):
        indices = super().resample()
        self.map_probs = self.map_probs[indices].copy()
        if self.last_log_evidence is not None:
            self.last_log_evidence = self.last_log_evidence[indices].copy()
        return indices

    @property
    def landmark_marginals(self):
        marginal = np.einsum('i,ijg->jg', self.weights, self.map_probs, optimize=True)
        side = len(self.grid_axis)
        return marginal.reshape(3, side, side)

    @property
    def landmark_means(self):
        return self.landmark_marginals.reshape(3, -1) @ self.grid_points


class Scenario:
    """Owns simulator state separately from the filter and advances one teaching stage."""
    def __init__(self, sigma=.15, seed=7, mode='localization'):
        if mode not in ('localization', 'slam'):
            raise ValueError('Mode must be localization or slam')
        self.sigma, self.seed, self.mode = sigma, seed, mode
        self.reset()

    def reset(self):
        streams = np.random.SeedSequence(self.seed).spawn(3)
        self.motion_rng, self.sensor_rng = [np.random.default_rng(s) for s in streams[:2]]
        if self.mode not in ('localization', 'slam'):
            raise ValueError('Mode must be localization or slam')
        estimator = ParticleFilter if self.mode == 'localization' else RangeOnlySLAM
        self.filter = estimator(np.random.default_rng(streams[2]), self.sigma)
        self.truth = np.array([2., 2.])
        self.history = [self.truth.copy()]
        self.observation = None
        self.stage, self.step = 'Initial belief', 0

    @property
    def done(self):
        return self.step == len(COMMANDS) and self.stage == 'Resampling'

    def advance(self):
        if self.done:
            return
        if self.stage in ('Initial belief', 'Resampling'):
            command = COMMANDS[self.step]
            self.truth += command + self.motion_rng.normal(0, .08, 2)
            self.history.append(self.truth.copy())
            self.filter.predict(command)
            self.observation = None
            self.step += 1
            self.stage = 'Prediction'
        elif self.stage == 'Prediction':
            self.observation = ranges(self.truth) + self.sensor_rng.normal(0, self.sigma, 3)
            self.filter.correct(self.observation)
            self.stage = 'Weighting'
        else:
            self.filter.resample()
            self.stage = 'Resampling'
