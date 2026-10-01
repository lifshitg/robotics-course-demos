"""Evaluate frozen initial/validation-selected policies on held-out test seeds."""
import argparse
import json
from pathlib import Path
import numpy as np
import torch
from algorithm import evaluate,TEST_SEEDS
from train import load_checkpoint


def compare(runs,output):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    torch.set_num_threads(1)
    output.mkdir(parents=True,exist_ok=True)
    summaries=[];records=[]
    fig,axes=plt.subplots(1,3,figsize=(14,4.7))
    for run in runs:
        settings=json.loads((run/'settings.json').read_text())
        history=json.loads((run/'training.json').read_text())
        record={};summary=dict(training_seed=settings['seed'],test_seeds=TEST_SEEDS)
        for name,file in [('initial','initial.pt'),('trained','best.pt')]:
            model,meta=load_checkpoint(run/file)
            result=evaluate(model)
            record[name]=result
            summary[name]={k:v for k,v in result.items() if k!='episodes'}
            summary[name]['checkpoint_steps']=meta['steps']
            summary[name]['per_episode']=[{k:e[k] for k in ['seed','return_','length','reached_limit']} for e in result['episodes']]
        summaries.append(summary);records.append(record)
        validations=history['validation']
        axes[0].plot([v['steps'] for v in validations],[v['mean_return'] for v in validations],marker='.',label=f'seed {settings["seed"]}')
        print(f'seed {settings["seed"]}: initial mean length {summary["initial"]["mean_length"]:.1f}; trained {summary["trained"]["mean_length"]:.1f}; reached limit {summary["trained"]["reached_limit"]}/20; selected at {summary["trained"]["checkpoint_steps"]} steps',flush=True)
    axes[0].set(title='Checkpoint validation (10 seeds)',xlabel='environment transitions',ylabel='mean return')
    axes[0].legend()
    x=np.arange(len(runs));w=.35
    for offset,name,color in [(-w/2,'initial','#bd796e'),(w/2,'trained','#227e88')]:
        axes[1].bar(x+offset,[s[name]['mean_length'] for s in summaries],w,label=name,color=color)
    axes[1].set(xticks=x,xticklabels=[str(s['training_seed']) for s in summaries],xlabel='training seed',ylabel='mean episode steps',title='Held-out test (20 seeds)')
    axes[1].legend()
    for name,color in [('initial','#bd796e'),('trained','#227e88')]:
        trace=records[0][name]['episodes'][0]
        axes[2].plot(trace['angles'],label=name,color=color)
    axes[2].axhline(.2,ls=':',color='gray');axes[2].axhline(-.2,ls=':',color='gray')
    axes[2].set(title=f'Matched test start: seed {TEST_SEEDS[0]}',xlabel='environment step',ylabel='pole angle (rad)')
    axes[2].legend()
    fig.tight_layout();fig.savefig(output/'comparison.png',dpi=150);plt.close(fig)
    (output/'results.json').write_text(json.dumps(summaries,indent=2)+'\n')
    # Training curves use completed episode returns, grouped into 100-episode means.
    fig,ax=plt.subplots(figsize=(8,4))
    for run in runs:
        history=json.loads((run/'training.json').read_text());settings=json.loads((run/'settings.json').read_text())
        ep=history['episodes'];groups=[ep[i:i+100] for i in range(0,len(ep),100)]
        ax.plot([g[-1]['transitions'] for g in groups],[np.mean([e['return_'] for e in g]) for g in groups],label=f'seed {settings["seed"]}')
    ax.set(title='Stochastic training behavior: 100-episode means',xlabel='environment transitions',ylabel='episode return')
    ax.legend();fig.tight_layout();fig.savefig(output/'training.png',dpi=150);plt.close(fig)
    return summaries


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runs',type=Path,nargs='+',required=True)
    p.add_argument('--output',type=Path,default=Path(__file__).with_name('output')/'comparison')
    a=p.parse_args()
    compare(a.runs,a.output)
