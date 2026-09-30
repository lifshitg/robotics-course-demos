"""MuJoCo dynamics and observations shared by every controller."""
from pathlib import Path
import numpy as np
import mujoco

CONTROL_DT = .02
STEPS = 250
LIMIT = 10.


def scenarios(seed=42, count=20):
    if not isinstance(count, int) or count < 1:
        raise ValueError('Episode count must be a positive integer.')
    rng = np.random.default_rng(seed)
    result = []
    for _ in range(count):
        for attempt in range(10000):
            start, target = rng.uniform(-.6, .6, (2, 2))
            if np.linalg.norm(start-target) >= .2:
                break
        else:
            raise RuntimeError('Could not sample a separated start and target.')
        result.append(dict(start=start, target=target, velocity=rng.uniform(-.2, .2, 2)))
    return result


class Task:
    def __init__(self):
        self.model = mujoco.MjModel.from_xml_path(str(Path(__file__).with_name('robot.xml')))
        self.data = mujoco.MjData(self.model)
        self.target = np.zeros(2)

    def reset(self, scenario):
        arrays = {k: np.asarray(scenario[k], dtype=float) for k in ['start','target','velocity']}
        if any(v.shape != (2,) or not np.isfinite(v).all() for v in arrays.values()):
            raise ValueError('Start, target, and velocity must be finite xy vectors.')
        mujoco.mj_resetData(self.model, self.data)
        self.target = arrays['target'].copy()
        self.data.qpos[:] = arrays['start']
        self.data.qvel[:] = arrays['velocity']
        self.data.mocap_pos[0] = [*self.target, .025]
        mujoco.mj_forward(self.model, self.data)
        return self.observe()

    def observe(self):
        obs = np.r_[self.target-self.data.qpos, self.data.qvel]
        if not np.isfinite(obs).all():
            raise RuntimeError('Simulation produced a nonfinite observation.')
        return obs

    def step(self, action):
        action = np.asarray(action, dtype=float)
        if action.shape != (2,) or not np.isfinite(action).all():
            raise ValueError('Action must contain two finite forces.')
        applied = np.clip(action, -LIMIT, LIMIT)
        self.data.ctrl[:] = applied
        # Hold the same action for two 0.01-second physics steps.
        mujoco.mj_step(self.model, self.data, nstep=2)
        return self.observe(), applied.copy()


def rollout(task, policy, scenario):
    obs = task.reset(scenario)
    observations, actions = [], []
    positions = [task.data.qpos.copy()]
    distances, speeds = [], []
    for _ in range(STEPS):
        observations.append(obs.copy())  # Label the observation BEFORE its action.
        obs, applied = task.step(policy(obs))
        actions.append(applied)
        positions.append(task.data.qpos.copy())
        distances.append(np.linalg.norm(obs[:2]))
        speeds.append(np.linalg.norm(obs[2:]))
    distances, speeds = np.array(distances), np.array(speeds)
    # Include the 4.50-second sample through 5.00 seconds (26 samples).
    success = bool(np.all(distances[-26:] < .03) and np.all(speeds[-26:] < .05))
    return dict(observations=np.array(observations), actions=np.array(actions),
                positions=np.array(positions), distances=distances, speeds=speeds,
                success=success, final_distance=float(distances[-1]), final_speed=float(speeds[-1]))
