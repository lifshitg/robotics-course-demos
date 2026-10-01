"""Five-step A2C: one update per fresh batch; no replay or PPO objective."""
import numpy as np
import torch
import gymnasium as gym

GAMMA=.99
ENV_ID='InvertedPendulum-v5'
VALIDATION_SEEDS=list(range(10000,10010))
TEST_SEEDS=list(range(20000,20020))


def make_env():
    return gym.make(ENV_ID)


def return_targets(rewards,terminated,truncated,next_values,gamma=GAMMA):
    """Arrays [time,env]; next_values are evaluated BEFORE resetting finished envs."""
    targets=torch.empty_like(rewards)
    tail=next_values[-1].detach()
    for t in reversed(range(len(rewards))):
        continuation=torch.where(truncated[t],next_values[t].detach(),tail)
        continuation=torch.where(terminated[t],torch.zeros_like(continuation),continuation)
        targets[t]=rewards[t]+gamma*continuation
        tail=targets[t]
    return targets.detach()


def losses(model,obs,latent,targets):
    values=model.value(obs)
    advantage=targets.detach()-values
    actor_loss=-(model.log_probability(obs,latent.detach())*advantage.detach()).mean()
    critic_loss=(values-targets.detach()).square().mean()
    return actor_loss,critic_loss,advantage.detach()


class Collector:
    def __init__(self,seed,count=8):
        self.envs=[make_env() for _ in range(count)]
        # Distinct stream seeds, outside the validation and test ranges.
        self.obs=np.array([e.reset(seed=100000+seed*100+i)[0] for i,e in enumerate(self.envs)],dtype=np.float32)
        self.returns=np.zeros(count);self.lengths=np.zeros(count,dtype=int)
        self.episodes=[];self.transitions=0

    def collect(self,model,steps=5):
        records={k:[] for k in ['obs','latent','reward','terminated','truncated','next_value']}
        for _ in range(steps):
            obs=torch.as_tensor(self.obs)
            with torch.no_grad(): actions,latent=model.sample(obs)
            next_obs=[];rewards=[];terms=[];truncs=[]
            for i,(e,a) in enumerate(zip(self.envs,actions.numpy())):
                n,r,term,trunc,_=e.step(a)
                next_obs.append(n);rewards.append(r);terms.append(term);truncs.append(trunc)
                self.returns[i]+=r;self.lengths[i]+=1
            with torch.no_grad(): nv=model.value(torch.tensor(np.array(next_obs),dtype=torch.float32))
            for i,e in enumerate(self.envs):
                if terms[i] or truncs[i]:
                    self.episodes.append(dict(transitions=self.transitions+len(self.envs),
                         return_=float(self.returns[i]),length=int(self.lengths[i]),terminated=bool(terms[i]),truncated=bool(truncs[i])))
                    self.returns[i]=0;self.lengths[i]=0
                    next_obs[i]=e.reset()[0]
            for k,v in [('obs',obs.clone()),('latent',latent),('reward',torch.tensor(rewards,dtype=torch.float32)),
                        ('terminated',torch.tensor(terms)),('truncated',torch.tensor(truncs)),('next_value',nv)]:
                records[k].append(v)
            self.obs=np.array(next_obs,dtype=np.float32);self.transitions+=len(self.envs)
        batch={k:torch.stack(v) for k,v in records.items()}
        batch['targets']=return_targets(batch['reward'],batch['terminated'],batch['truncated'],batch['next_value'])
        return batch

    def close(self):
        for e in self.envs:e.close()


def evaluate(model,seeds=TEST_SEEDS):
    """Own environment, deterministic inference; no training RNG or parameter changes."""
    env=make_env();episodes=[]
    try:
        for seed in seeds:
            obs,_=env.reset(seed=seed);total=0.;angles=[float(obs[1])];values=[];actions=[]
            for length in range(1,1001):
                with torch.no_grad():
                    x=torch.tensor(obs,dtype=torch.float32).unsqueeze(0)
                    a=model.deterministic(x)[0].numpy();v=float(model.value(x)[0])
                obs,r,term,trunc,_=env.step(a);total+=r
                angles.append(float(obs[1]));values.append(v);actions.append(float(a[0]))
                if term or trunc:break
            episodes.append(dict(seed=seed,return_=total,length=length,reached_limit=bool(trunc and not term),
                                 angles=angles,values=values,actions=actions))
    finally:env.close()
    return dict(mean_return=float(np.mean([e['return_'] for e in episodes])),
                mean_length=float(np.mean([e['length'] for e in episodes])),
                reached_limit=sum(e['reached_limit'] for e in episodes),episodes=episodes)
