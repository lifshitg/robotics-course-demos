"""A five-minute visual explanation of Bellman backups on a known robot MDP."""
import argparse
from pathlib import Path
from model import delivery_mdp, action_values, backup, greedy_policy, value_iteration, policy_iteration


class Demo:
    def __init__(self, failure=0.2):
        import matplotlib.pyplot as plt
        from matplotlib.widgets import Button, RadioButtons
        self.plt = plt
        self.fig, (self.graph, self.panel) = plt.subplots(1, 2, figsize=(13, 7))
        self.fig.subplots_adjust(left=.04, right=.98, top=.87, bottom=.22, wspace=.12)
        self.buttons = []
        for x, label, callback in [(.12, 'Next backup', self.next_backup), (.32, 'Solve', self.solve), (.52, 'Reset', self.reset)]:
            button = Button(self.fig.add_axes([x,.06,.16,.06]), label)
            button.on_clicked(callback)
            self.buttons.append(button)
        self.selector = RadioButtons(self.fig.add_axes([.76,.03,.17,.13]), ['0.2', '0.1'], active=0 if failure==.2 else 1)
        self.selector.ax.set_title('Failure probability', fontsize=10)
        self.selector.on_clicked(self.change_scenario)
        self.failure = failure
        self.reset()

    def reset(self, event=None):
        self.mdp = delivery_mdp(self.failure)
        self.values = self.mdp.zeros()
        self.iteration, self.delta = 0, None
        self.message = 'Predict the first backup before clicking.'
        self.render()

    def change_scenario(self, label):
        self.failure = float(label)
        self.reset()

    def next_backup(self, event=None):
        if self.iteration >= 1000:
            self.message = 'Iteration limit reached.'
        else:
            self.values, self.delta = backup(self.mdp, self.values)
            self.iteration += 1
            self.message = 'Converged: maximum change < 1e-10.' if self.delta < 1e-10 else 'All updates used the previous complete vector.'
        self.render()

    def solve(self, event=None):
        while self.iteration < 1000:
            self.values, self.delta = backup(self.mdp, self.values)
            self.iteration += 1
            if self.delta < 1e-10:
                self.message = 'Converged: maximum change < 1e-10.'
                break
        else:
            self.message = 'Iteration limit reached without convergence.'
        self.render()

    def render(self):
        ax = self.graph
        ax.clear(); self.panel.clear(); self.panel.axis('off')
        ax.set(xlim=(-.4,4.4), ylim=(-.7,3.5)); ax.axis('off')
        pos = {'start': (0,1.5), 'detour': (2,3), 'delivered': (4,1.5), 'failed': (2,0)}
        policy = greedy_policy(self.mdp, self.values)
        edges = [('start','detour','safe','p=1; r=-1',(0.85,2.65)),
                 ('start','delivered','risky',f'p={1-self.failure:.1f}; r=+10',(2,1.73)),
                 ('start','failed','risky',f'p={self.failure:.1f}; r=-10',(.65,.55)),
                 ('detour','delivered','finish','p=1; r=+8',(3.3,2.65))]
        for src, dst, action, label, labelpos in edges:
            chosen = policy[src] == action
            ax.annotate('', pos[dst], pos[src], arrowprops=dict(arrowstyle='->',lw=3 if chosen else 1.3,
                        color='#168078' if chosen else '#a6afb6', shrinkA=27, shrinkB=27))
            ax.text(*labelpos, action+'\n'+label,ha='center',fontsize=10,
                    bbox=dict(facecolor='white',edgecolor='none',alpha=.9))
        for state, xy in pos.items():
            ax.text(*xy, state+'\nV='+f'{self.values[state]:.2f}',ha='center',va='center',fontsize=11,
                    bbox=dict(boxstyle='round,pad=.5', facecolor='#e5f2f1' if state not in self.mdp.terminals else '#f2e8d7',edgecolor='#43616c'))
        ax.set_title('Green: greedy policy w.r.t. displayed V\nBoth risky outcomes remain possible',fontsize=11)
        ax.text(2,-.55,'Terminals: absorbing, zero later reward; V=0',ha='center',fontsize=10)
        q = action_values(self.mdp,'start',self.values)
        lines = [f'V{self.iteration}   |   gamma = 0.9', '',
                 'Action values from the DISPLAYED vector:',
                 f'Q_V(start, safe) = -1 + 0.9 x {self.values["detour"]:.2f}',
                 f'                = {q["safe"]:.2f}',
                 f'Q_V(start, risky) = {1-self.failure:.1f} x 10 + {self.failure:.1f} x (-10)',
                 f'                 = {q["risky"]:.2f}', '',
                 f'Greedy start action: {policy["start"]}',
                 'These Q values produce the NEXT backup.', '', self.message]
        if self.delta is not None: lines.append(f'Last maximum change: {self.delta:.3g}')
        if self.delta is not None and self.delta < 1e-10:
            _, _, trace = policy_iteration(self.mdp, {'start':'risky','detour':'finish'})
            lines += ['', 'Policy iteration (finish at detour):']
            for p,v,new in trace:
                lines.append(f'  {p["start"]}: V(start)={v["start"]:.2f} -> {new["start"]}')
        self.panel.text(0,1,'\n'.join(lines),va='top',family='monospace',fontsize=10)
        self.fig.suptitle('Week 6: From Actions to Policies',fontsize=18)
        self.fig.canvas.draw_idle()


def print_trace(failure):
    mdp = delivery_mdp(failure)
    values, policy, history = value_iteration(mdp)
    print(f'Failure probability={failure}; gamma={mdp.gamma}')
    for i,v in enumerate(history): print(f'V{i}: start={v["start"]:.2f}, detour={v["detour"]:.2f}, terminals=0')
    print('Optimal policy:', policy)
    _, _, trace = policy_iteration(mdp, {'start':'risky','detour':'finish'})
    for p,v,new in trace: print(f'PI: evaluate {p}: start={v["start"]:.2f}; improve -> {new}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--failure',type=float,choices=[.2,.1],default=.2)
    parser.add_argument('--headless',action='store_true')
    parser.add_argument('--export',type=Path)
    args = parser.parse_args()
    try:
        print_trace(args.failure)
        if args.headless and not args.export: return 0
        if args.export:
            import matplotlib
            matplotlib.use('Agg')
        app = Demo(args.failure)
        if args.export:
            app.solve()
            args.export.parent.mkdir(parents=True,exist_ok=True)
            app.fig.savefig(args.export,dpi=140)
            app.plt.close(app.fig)
        else: app.plt.show()
        return 0
    except (ValueError, RuntimeError) as error:
        parser.exit(1, str(error)+'\n')


if __name__ == '__main__':
    raise SystemExit(main())
