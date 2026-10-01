"""Tabular Q-learning from sampled transitions; evaluation has no side effects."""
import numpy as np
from gridworld import START, transition


def epsilon(episode):
    return max(.05, 1-episode/800)


def update(q, state, action, reward, nxt, terminated, alpha=.2, gamma=.95):
    old = float(q[state+(action,)])
    target = reward + (0 if terminated else gamma*float(q[nxt].max()))
    new = old + alpha*(target-old)
    q[state+(action,)] = new
    return dict(old=old, target=float(target), new=float(new))


class Learner:
    def __init__(self, seed=7):
        self.seed = seed
        self.rng = np.random.default_rng(seed)
        self.q = np.zeros((5,5,4))
        self.state = START
        self.episode = self.steps = 0
        self.raw_return = self.discounted_return = 0.
        self.history = []
        self.last = None

    def step(self):
        state = self.state
        eps = epsilon(self.episode)
        exploratory = bool(self.rng.random() < eps)
        action = int(self.rng.integers(4)) if exploratory else int(self.rng.choice(np.flatnonzero(self.q[state] == self.q[state].max())))
        nxt, reward, terminated = transition(state, action)
        details = update(self.q,state,action,reward,nxt,terminated)
        self.raw_return += reward
        self.discounted_return += .95**self.steps*reward
        self.steps += 1
        truncated = self.steps >= 100 and not terminated
        self.last = dict(state=state,action=action,next_state=nxt,reward=reward,
                         exploratory=exploratory,epsilon=eps,terminated=terminated,truncated=truncated,**details)
        self.state = nxt
        if terminated or truncated:
            self.history.append(dict(episode=self.episode,length=self.steps,terminated=terminated,
                                     truncated=truncated,raw_return=self.raw_return,discounted_return=self.discounted_return))
            self.episode += 1
            self.state = START
            self.steps = 0
            self.raw_return = self.discounted_return = 0.
        return self.last

    def train(self, episodes=1000):
        if not isinstance(episodes,int) or episodes < 0:
            raise ValueError('Episode count must be a nonnegative integer.')
        target = self.episode+episodes
        while self.episode < target:
            self.step()


def evaluate(q):
    if q.shape != (5,5,4) or not np.isfinite(q).all():
        raise ValueError('Expected a finite 5 x 5 x 4 Q-table.')
    state = START
    path, rewards = [state], []
    for _ in range(100):
        action = int(q[state].argmax())  # Fixed up/right/down/left tie order.
        state, reward, terminated = transition(state,action)
        path.append(state); rewards.append(reward)
        if terminated:
            break
    return dict(success=terminated,path=path,length=len(rewards),raw_return=sum(rewards),
                discounted_return=sum(.95**i*r for i,r in enumerate(rewards)))
