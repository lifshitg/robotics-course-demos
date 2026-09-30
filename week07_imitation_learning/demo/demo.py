"""Watch, collect, clone, and compare policies in the same MuJoCo task."""
import argparse
from collections import deque
import json
from pathlib import Path
import time
import numpy as np
import mujoco
from task import Task, scenarios, rollout, STEPS, CONTROL_DT
from learning import Policy, train

HERE=Path(__file__).resolve().parent


def save_json(path, obj):
    Path(path).write_text(json.dumps(obj,indent=2)+'\n')


def get_policy(name, output):
    if name=='learner':
        return Policy.load(output/'policy.npz')
    if name=='zero':
        return lambda obs: np.zeros(2)
    from expert import expert
    return expert


def collect(output):
    from expert import expert
    output.mkdir(parents=True,exist_ok=True)
    task=Task()
    cases=scenarios(7,100)
    records=[rollout(task,expert,s) for s in cases]
    np.savez_compressed(output/'dataset.npz',
                        observations=np.concatenate([r['observations'] for r in records]),
                        actions=np.concatenate([r['actions'] for r in records]),
                        episode_ids=np.repeat(np.arange(100),STEPS))
    save_json(output/'collection.json',dict(seed=7,episodes=100,control_dt=CONTROL_DT,
               physics_dt=float(task.model.opt.timestep),steps=STEPS,mujoco_version=mujoco.__version__,
               observation_order=['error_x','error_y','velocity_x','velocity_y'],
               action_order=['force_x','force_y'],
               scenarios=[{k:v.tolist() for k,v in s.items()} for s in cases]))
    print('Collected 100 expert episodes: 25,000 observation/action pairs (seed 7).')


def fit(output):
    policy,metrics=train(output/'dataset.npz')
    policy.save(output/'policy.npz')
    save_json(output/'training.json',metrics)
    print(f'Train action MSE: {metrics["train_action_mse"]:.3g}; validation: {metrics["validation_action_mse"]:.3g}')
    print('Learned W:\n',policy.weights,'\nLearned b:',policy.bias)
    return metrics


def evaluate(output):
    output.mkdir(parents=True,exist_ok=True)
    cases=scenarios(42,20)
    task=Task()
    records={name:[rollout(task,get_policy(name,output),s) for s in cases]
             for name in ['expert','learner','zero']}
    report={'evaluation_seed':42,'episodes':20,'controllers':{}}
    if (output/'training.json').exists():
        report['validation_action_mse']=json.loads((output/'training.json').read_text())['validation_action_mse']
    for name,rs in records.items():
        metrics=dict(successes=sum(r['success'] for r in rs),success_rate=float(np.mean([r['success'] for r in rs])),
                     mean_final_distance=float(np.mean([r['final_distance'] for r in rs])),
                     mean_final_speed=float(np.mean([r['final_speed'] for r in rs])),
                     per_episode=[{k:r[k] for k in ['success','final_distance','final_speed']} for r in rs])
        report['controllers'][name]=metrics
        print(f'{name:7}: {metrics["successes"]}/20 successful; mean final distance {metrics["mean_final_distance"]:.6f} m; speed {metrics["mean_final_speed"]:.6f} m/s')
    save_json(output/'evaluation.json',report)
    np.savez_compressed(output/'trajectories.npz',targets=np.array([s['target'] for s in cases]),
                        **{name:np.array([r['positions'] for r in rs]) for name,rs in records.items()})
    plot(output,records,cases)
    return report


def plot(output, records, cases):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    fig,axes=plt.subplots(1,3,figsize=(13,4.6))
    colors={'expert':'#137b80','learner':'#ce7915','zero':'#89909a'}
    for name in records:
        r=records[name][0]
        p=r['positions']
        axes[0].plot(p[:,0],p[:,1],label=name,color=colors[name],
                     linestyle='--' if name=='learner' else '-',linewidth=2)
        axes[1].plot(np.arange(1,STEPS+1)*CONTROL_DT,r['distances'],label=name,color=colors[name],
                     linestyle='--' if name=='learner' else '-')
    axes[0].scatter(*cases[0]['start'],marker='o',color='black',label='start')
    axes[0].scatter(*cases[0]['target'],marker='*',s=130,color='#a23044',label='target')
    axes[0].set(title='Same test start: episode 1',xlabel='x (m)',ylabel='y (m)',aspect='equal')
    axes[0].legend(fontsize=8)
    axes[1].axhline(.03,color='black',ls=':',label='distance threshold')
    axes[1].set(title='Distance during closed-loop execution',xlabel='time (s)',ylabel='distance (m)')
    axes[1].legend(fontsize=8)
    names=list(records)
    axes[2].bar(names,[sum(r['success'] for r in records[n]) for n in names],color=[colors[n] for n in names])
    axes[2].set(title='20 shared unseen episodes',ylabel='successful episodes',ylim=(0,22))
    fig.suptitle('Behavior cloning: expert and learner trajectories overlap',fontsize=14)
    fig.tight_layout()
    fig.savefig(output/'comparison.png',dpi=150)
    plt.close(fig)


class Playback:
    """Viewer-independent state makes keyboard behavior testable."""
    def __init__(self,policy):
        self.task=Task()
        self.policy=policy
        self.cases=scenarios(42,20)
        self.episode=0
        self.paused=False
        self.restart()

    def restart(self):
        self.observation=self.task.reset(self.cases[self.episode])
        self.steps=0

    def key(self,key):
        if key==32:self.paused=not self.paused
        elif key in (ord('R'),ord('r')):self.restart()
        elif key in (ord('N'),ord('n')):
            self.episode=(self.episode+1)%len(self.cases)
            self.restart()

    def tick(self):
        if self.paused or self.steps>=STEPS:return
        self.observation,_=self.task.step(self.policy(self.observation))
        self.steps+=1


def watch(name,output,seconds=None):
    import mujoco.viewer
    player=Playback(get_policy(name,output))
    events=deque()
    with mujoco.viewer.launch_passive(player.task.model,player.task.data,key_callback=events.append) as viewer:
        with viewer.lock():
            viewer.cam.lookat[:]=[0,0,0]
            viewer.cam.distance=2.7
            viewer.cam.azimuth=90
            viewer.cam.elevation=-75
        start=time.monotonic()
        while viewer.is_running() and (seconds is None or time.monotonic()-start<seconds):
            t=time.monotonic()
            with viewer.lock():
                while events:player.key(events.popleft())
                player.tick()
            status='finished' if player.steps>=STEPS else ('paused' if player.paused else 'running')
            viewer.set_texts([(mujoco.mjtFontScale.mjFONTSCALE_150,mujoco.mjtGridPos.mjGRID_TOPLEFT,
                               f'{name.upper()} | Episode {player.episode+1}/20 | {status}',
                               f't={player.steps*CONTROL_DT:.2f}s\nSpace: pause/resume | R: restart | N: next')])
            viewer.sync()
            time.sleep(max(0,CONTROL_DT-(time.monotonic()-t)))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('command',choices=['watch','collect','train','evaluate','all'])
    p.add_argument('--controller',choices=['expert','learner','zero'],default='expert')
    p.add_argument('--output',type=Path,default=HERE/'output')
    p.add_argument('--seconds',type=float,help='Optional viewer duration for rehearsals/smoke tests.')
    args=p.parse_args()
    try:
        if args.seconds is not None and (not np.isfinite(args.seconds) or args.seconds<=0):
            raise ValueError('--seconds must be finite and positive.')
        if args.command=='watch':watch(args.controller,args.output,args.seconds)
        if args.command in ['collect','all']:collect(args.output)
        if args.command in ['train','all']:fit(args.output)
        if args.command in ['evaluate','all']:evaluate(args.output)
        return 0
    except (ValueError,RuntimeError,OSError) as e:
        p.exit(1,str(e)+'\n')


if __name__=='__main__':raise SystemExit(main())
