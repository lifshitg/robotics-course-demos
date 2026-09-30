"""Supervised action regression using ONLY recorded observation/action pairs."""
from pathlib import Path
import numpy as np
from task import LIMIT


def load_dataset(path):
    try:
        with np.load(path, allow_pickle=False) as f:
            x, y, ids = f['observations'], f['actions'], f['episode_ids']
    except (KeyError, OSError, ValueError) as e:
        raise ValueError('Dataset must contain observations, actions, and episode_ids.') from e
    if (x.ndim != 2 or x.shape[1] != 4 or y.shape != (len(x),2) or ids.shape != (len(x),)
            or len(x)==0 or ids.dtype.kind not in 'iu' or np.any(ids<0)):
        raise ValueError('Malformed dataset shapes or episode IDs.')
    if x.dtype.kind not in 'fiu' or y.dtype.kind not in 'fiu' or not np.isfinite(x).all() or not np.isfinite(y).all():
        raise ValueError('Dataset observations/actions must be finite numeric arrays.')
    if np.any(np.abs(y)>LIMIT):
        raise ValueError('Recorded actions exceed actuator limits.')
    episodes = np.unique(ids)
    if len(episodes) != 100 or not np.array_equal(episodes,np.arange(100)):
        raise ValueError('Expected the 100 demonstration episodes numbered 0–99.')
    if any(np.sum(ids==i)!=250 for i in episodes):
        raise ValueError('Each demonstration must contain 250 labeled observations.')
    return x, y, ids


class Policy:
    def __init__(self, weights, bias):
        self.weights, self.bias = np.asarray(weights), np.asarray(bias)
        if self.weights.shape!=(2,4) or self.bias.shape!=(2,) or not np.isfinite(self.weights).all() or not np.isfinite(self.bias).all():
            raise ValueError('Policy requires finite W[2,4] and b[2].')

    def __call__(self, observation):
        x=np.asarray(observation, dtype=float)
        if x.shape!=(4,) or not np.isfinite(x).all():
            raise ValueError('Expected a finite observation vector of length four.')
        return np.clip(self.weights@x+self.bias,-LIMIT,LIMIT)

    def save(self,path):
        np.savez(path,weights=self.weights,bias=self.bias)

    @classmethod
    def load(cls,path):
        if not Path(path).exists():
            raise ValueError('Trained policy is missing. Run the collect and train commands, or run all.')
        try:
            with np.load(path,allow_pickle=False) as f:
                return cls(f['weights'],f['bias'])
        except (KeyError,OSError) as e:
            raise ValueError('Malformed policy file.') from e


def train(dataset_path):
    x,y,ids=load_dataset(dataset_path)
    train_mask=ids<80
    design=np.column_stack([x,np.ones(len(x))])
    coefficients,_,rank,_=np.linalg.lstsq(design[train_mask],y[train_mask],rcond=None)
    if rank != 5:
        raise ValueError('Training observations do not identify all affine coefficients.')
    policy=Policy(coefficients[:4].T,coefficients[4])
    def mse(mask):
        predictions=np.clip(design[mask]@coefficients,-LIMIT,LIMIT)
        return float(np.mean((predictions-y[mask])**2))
    return policy, dict(train_episodes=list(range(80)),validation_episodes=list(range(80,100)),
                        train_action_mse=mse(train_mask),validation_action_mse=mse(~train_mask),
                        training_rows=int(train_mask.sum()),validation_rows=int((~train_mask).sum()))
