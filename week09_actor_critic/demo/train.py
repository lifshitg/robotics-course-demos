"""CPU A2C training and checkpoint selection using validation seeds only."""
import argparse
import json
import time
from pathlib import Path
import importlib.metadata
import numpy as np
import torch
from networks import ActorCritic
from algorithm import Collector,losses,evaluate,VALIDATION_SEEDS


def save_checkpoint(path,model,steps,seed,optimizer=None):
    payload=dict(model=model.state_dict(),steps=steps,seed=seed)
    if optimizer is not None:payload['optimizer']=optimizer.state_dict()
    torch.save(payload,path)


def load_checkpoint(path):
    if not Path(path).exists():raise ValueError(f'Missing checkpoint {path}. Run train.py first or use the classroom artifacts.')
    with torch.random.fork_rng():model=ActorCritic()
    data=torch.load(path,map_location='cpu',weights_only=True)
    model.load_state_dict(data['model'])
    return model,data


def train(output,seed=7,steps=250000):
    if seed<0 or steps<40 or steps%40:raise ValueError('Seed must be nonnegative; steps must be a positive multiple of 40.')
    if output.exists() and any(output.iterdir()):raise ValueError('Use an empty output directory to preserve previous runs.')
    output.mkdir(parents=True,exist_ok=True)
    torch.set_num_threads(1);torch.manual_seed(seed);np.random.seed(seed)
    model=ActorCritic()
    optimizer=torch.optim.RMSprop(model.parameters(),lr=7e-4,alpha=.99,eps=1e-5)
    settings=dict(seed=seed,steps=steps,env='InvertedPendulum-v5',environments=8,rollout_steps=5,
                  gamma=.99,learning_rate=7e-4,critic_weight=.5,gradient_limit=.5,entropy_bonus=0,
                  training_env_seeds=[100000+seed*100+i for i in range(8)],validation_seeds=VALIDATION_SEEDS,
                  versions={n:importlib.metadata.version(n) for n in ['torch','gymnasium','mujoco','numpy','matplotlib']})
    (output/'settings.json').write_text(json.dumps(settings,indent=2))
    save_checkpoint(output/'initial.pt',model,0,seed)
    initial=evaluate(model,VALIDATION_SEEDS)
    validations=[dict(steps=0,mean_return=initial['mean_return'],mean_length=initial['mean_length'])]
    best=initial['mean_return'];save_checkpoint(output/'best.pt',model,0,seed)
    collector=Collector(seed);updates=[];start=time.monotonic()
    try:
        for count in range(40,steps+1,40):
            b=collector.collect(model)
            al,cl,adv=losses(model,b['obs'].reshape(-1,4),b['latent'].reshape(-1,1),b['targets'].flatten())
            loss=al+.5*cl
            if not torch.isfinite(loss):raise RuntimeError('Nonfinite training loss.')
            optimizer.zero_grad();loss.backward()
            norm=torch.nn.utils.clip_grad_norm_(model.parameters(),.5)
            if not torch.isfinite(norm):raise RuntimeError('Nonfinite gradient norm.')
            optimizer.step()
            updates.append(dict(steps=count,actor_loss=float(al.detach()),critic_loss=float(cl.detach()),
                                mean_advantage=float(adv.mean()),std=float(model.log_std.clamp(-5,2).exp().detach()[0])))
            if count%25000==0 or count==steps:
                result=evaluate(model,VALIDATION_SEEDS)
                validations.append(dict(steps=count,mean_return=result['mean_return'],mean_length=result['mean_length']))
                save_checkpoint(output/f'checkpoint_{count}.pt',model,count,seed,optimizer)
                if result['mean_return']>best:
                    best=result['mean_return'];save_checkpoint(output/'best.pt',model,count,seed,optimizer)
                print(f'seed={seed} steps={count} validation={result["mean_return"]:.1f} best={best:.1f} elapsed={time.monotonic()-start:.1f}s',flush=True)
                (output/'training.json').write_text(json.dumps(dict(episodes=collector.episodes,updates=updates,validation=validations),indent=2))
    finally:collector.close()
    (output/'runtime.json').write_text(json.dumps(dict(seconds=time.monotonic()-start)))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',type=Path,default=Path(__file__).with_name('output')/'seed7')
    p.add_argument('--seed',type=int,default=7);p.add_argument('--steps',type=int,default=250000)
    a=p.parse_args()
    try:train(a.output,a.seed,a.steps)
    except (ValueError,RuntimeError) as e:p.exit(1,str(e)+'\n')
