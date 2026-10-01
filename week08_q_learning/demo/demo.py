"""Inspect sampled Q-learning updates, train, and animate greedy evaluation."""
import argparse
import json
from pathlib import Path
import numpy as np
from gridworld import START, GOAL, WALLS, MOVES, NAMES, valid
from learning import Learner, epsilon, evaluate


class Demo:
    def __init__(self, seed=7):
        import matplotlib.pyplot as plt
        from matplotlib.widgets import Button
        self.plt=plt
        self.seed=seed
        self.learner=Learner(seed)
        self.selected=START
        self.batch_target=None
        self.evaluation=None
        self.frame=0
        self.fig=plt.figure(figsize=(13,7))
        gs=self.fig.add_gridspec(2,2,width_ratios=[1,1.3],height_ratios=[2,1])
        self.grid=self.fig.add_subplot(gs[:,0])
        self.panel=self.fig.add_subplot(gs[0,1])
        self.chart=self.fig.add_subplot(gs[1,1])
        self.fig.subplots_adjust(bottom=.18,top=.88,wspace=.25,hspace=.35)
        self.buttons=[]
        for x,label,fn in [(.08,'Step',self.step),(.29,'Train 100 episodes',self.train_batch),(.52,'Evaluate',self.start_evaluation),(.75,'Reset',self.reset)]:
            b=Button(self.fig.add_axes([x,.045,.18,.06]),label)
            b.on_clicked(fn);self.buttons.append(b)
        self.fig.canvas.mpl_connect('button_press_event',self.select)
        self.fig.canvas.mpl_connect('close_event',lambda e:self.timer.stop())
        self.timer=self.fig.canvas.new_timer(interval=150)
        self.timer.add_callback(self.tick)
        self.timer.start()
        self.render()

    def step(self,event=None):
        if self.batch_target is not None:return
        self.evaluation=None
        self.learner.step();self.render()

    def train_batch(self,event=None):
        if self.batch_target is None:
            self.evaluation=None
            self.batch_target=self.learner.episode+100
            self.render()

    def start_evaluation(self,event=None):
        if self.batch_target is not None:return
        self.evaluation=evaluate(self.learner.q)
        self.frame=0
        self.render()

    def reset(self,event=None):
        self.learner=Learner(self.seed)
        self.batch_target=self.evaluation=None
        self.frame=0;self.selected=START
        self.render()

    def select(self,event):
        if event.inaxes != self.grid or event.xdata is None or event.ydata is None:return
        state=(int(np.floor(event.ydata+.5)),int(np.floor(event.xdata+.5)))
        if valid(state):self.selected=state;self.render()

    def tick(self):
        if self.batch_target is not None:
            self.learner.train(1)  # Finish the current episode; render after each episode.
            if self.learner.episode>=self.batch_target:self.batch_target=None
            self.render()
        elif self.evaluation is not None and self.frame < self.evaluation['length']:
            self.frame+=1;self.render()

    def render(self):
        from matplotlib.patches import Rectangle
        ax=self.grid;ax.clear()
        ax.set(xlim=(-.5,4.5),ylim=(4.5,-.5),aspect='equal',xlabel='column',ylabel='row')
        ax.set_xticks(range(5));ax.set_yticks(range(5))
        for r in range(5):
            for c in range(5):
                s=(r,c)
                ax.add_patch(Rectangle((c-.5,r-.5),1,1,facecolor='#617080' if s in WALLS else '#f2f5f5',edgecolor='white'))
                if s not in WALLS and s != GOAL:
                    a=int(self.learner.q[s].argmax());dr,dc=MOVES[a]
                    ax.arrow(c-dc*.15,r-dr*.15,dc*.3,dr*.3,width=.025,head_width=.13,color='#7aa19b')
        ax.text(GOAL[1],GOAL[0],'GOAL\n+10',ha='center',va='center',color='#176738')
        ax.text(START[1],START[0]+.35,'START',ha='center',fontsize=8)
        r,c=self.selected
        ax.add_patch(Rectangle((c-.49,r-.49),.98,.98,fill=False,edgecolor='#d39321',lw=2))
        state=self.learner.state
        if self.evaluation is not None:
            path=self.evaluation['path'][:self.frame+1];state=path[-1]
            ax.plot([s[1] for s in path],[s[0] for s in path],color='#a1429e',lw=2)
        ax.plot(state[1],state[0],'o',ms=13,color='#176c9a')
        ax.set_title('Greedy arrows (fixed tie order)\nClick a cell to inspect its Q-values',fontsize=11)
        self.panel.clear();self.panel.axis('off')
        l=self.learner
        lines=[f'Completed episodes: {l.episode} | next epsilon: {epsilon(l.episode):.3f}',
               f'Current training state: {l.state}; steps: {l.steps}',
               f'Q-values at {self.selected}:',
               '  '+'  '.join(f'{n}={v:.2f}' for n,v in zip(NAMES,l.q[self.selected])),'']
        if l.last:
            t=l.last
            lines += [f'Last: {t["state"]} --{NAMES[t["action"]]}--> {t["next_state"]}; r={t["reward"]:g}',
                      f'Exploration selected: {t["exploratory"]} (epsilon={t["epsilon"]:.3f})',
                      f'old={t["old"]:.3f}; target={t["target"]:.3f}; new={t["new"]:.3f}',
                      f'Terminal: {t["terminated"]}; truncated: {t["truncated"]}']
        else:lines += ['Step to observe one transition and Q update.']
        if self.batch_target is not None:lines+=['',f'Training until episode {self.batch_target}…']
        if self.evaluation is not None:
            e=self.evaluation
            lines+=['','EVALUATION ONLY: no learning or exploration',
                    f'Success={e["success"]}; moves={e["length"]}; raw return={e["raw_return"]:g}',
                    f'Discounted return={e["discounted_return"]:.4f}',
                    'Click Step or Train to return to training.']
        self.panel.text(0,1,'\n'.join(lines),va='top',family='monospace',fontsize=9)
        self.chart.clear()
        if l.history:
            xs=np.arange(1,len(l.history)+1);ys=[h['length'] for h in l.history]
            self.chart.plot(xs,ys,lw=.7,color='#267b94')
            truncated=[h for h in l.history if h['truncated']]
            self.chart.scatter([h['episode']+1 for h in truncated],[h['length'] for h in truncated],marker='x',color='#bc4545',s=15,label='truncated')
            if truncated:self.chart.legend(fontsize=8)
        self.chart.set(title='Training episode lengths',xlabel='completed episode',ylabel='steps',ylim=(0,105))
        self.fig.suptitle('Week 8 — Learn Q-values from experience',fontsize=17)
        self.fig.canvas.draw_idle()


def save_results(learner,output):
    output.mkdir(parents=True,exist_ok=True)
    np.save(output/'q_table.npy',learner.q)
    result=evaluate(learner.q)
    (output/'metrics.json').write_text(json.dumps(dict(seed=learner.seed,episodes=learner.episode,
         alpha=.2,gamma=.95,evaluation=result,training=learner.history),indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != "path"},indent=2))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--seed',type=int,default=7)
    p.add_argument('--episodes',type=int,default=1000,help='Headless/export training count; GUI starts untrained.')
    p.add_argument('--headless',action='store_true')
    p.add_argument('--export',type=Path,help='Directory for before/after figures, Q-table, and metrics.')
    p.add_argument('--output',type=Path,default=Path(__file__).with_name('output'))
    a=p.parse_args()
    if a.episodes<0 or a.seed<0:p.error('Episodes and seed must be nonnegative.')
    if a.headless or a.export:
        import matplotlib
        matplotlib.use('Agg')
        app=Demo(a.seed)
        output=a.export or a.output
        output.mkdir(parents=True,exist_ok=True)
        if a.export:app.fig.savefig(output/'before.png',dpi=140)
        app.learner.train(a.episodes)
        save_results(app.learner,output)
        if a.export:
            app.start_evaluation();app.frame=app.evaluation['length'];app.render()
            app.fig.savefig(output/'after.png',dpi=140)
        app.plt.close(app.fig)
    else:
        app=Demo(a.seed);app.plt.show()


if __name__=='__main__':main()
