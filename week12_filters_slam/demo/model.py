"""Position-only particle filtering; the filter never receives ground truth."""
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


class Scenario:
    """Owns simulator state separately from the filter and advances one teaching stage."""
    def __init__(self, sigma=.15, seed=7):
        self.sigma, self.seed = sigma, seed
        self.reset()

    def reset(self):
        streams = np.random.SeedSequence(self.seed).spawn(3)
        self.motion_rng, self.sensor_rng = [np.random.default_rng(s) for s in streams[:2]]
        self.filter = ParticleFilter(np.random.default_rng(streams[2]), self.sigma)
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
