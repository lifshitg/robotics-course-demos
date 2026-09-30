"""Scripted demonstrator. The learning module never imports these gains."""
import numpy as np
from task import LIMIT


def expert(observation):
    obs = np.asarray(observation, dtype=float)
    if obs.shape != (4,) or not np.isfinite(obs).all():
        raise ValueError('Expected four finite observation components.')
    return np.clip(4*obs[:2] - 3*obs[2:], -LIMIT, LIMIT)
