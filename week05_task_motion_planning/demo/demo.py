"""Show symbolic planning, geometric rejection, and validated delivery execution."""
import argparse
import math
from pathlib import Path
import time
import textwrap

from geometry import load_scene
from planning import (solve, print_trace, visible_facts, location, loaded, radius_for)


class Demo:
    titles = ['1 · Initial delivery problem', '2 · Symbolic candidate — not executed',
              '3 · Geometric rejection — hypothetical state',
              '4 · Revised, geometrically validated plan', '5 · Execute validated plan']

    def __init__(self, scene=None, result=None):
        import matplotlib.pyplot as plt
        from matplotlib.patches import Circle, Rectangle
        from matplotlib.widgets import Button
        self.plt = plt
        self.scene = load_scene() if scene is None else scene
        self.result = solve(self.scene) if result is None else result
        self.stage, self.playing, self.action_index, self.elapsed = 0, False, 0, 0.
        self.last_time = None
        self.execution_state = self.result.initial_state
        self.position = tuple(self.scene['locations'][location(self.execution_state)])
        self.final = self.result.attempts[-1] if self.result.status == 'success' else None
        self.fig, (self.world, self.panel) = plt.subplots(1,2,figsize=(12,7),gridspec_kw={'width_ratios':[1,1.15]})
        self.fig.subplots_adjust(top=.85,bottom=.17,wspace=.16)
        w,h = self.scene['size']
        self.world.set(xlim=(0,w),ylim=(0,h),aspect='equal',xlabel='x (m)',ylabel='y (m)')
        self.world.set_title('Geometry: footprint depends on possession',fontsize=11)
        self.world.grid(alpha=.15)
        for x0,x1,y0,y1 in self.scene['obstacles']:
            self.world.add_patch(Rectangle((x0,y0),x1-x0,y1-y0,color='#647487'))
        for a,b in self.scene['connections']:
            self.world.plot(*zip(self.scene['locations'][a],self.scene['locations'][b]),'--',color='#aab8c5',lw=1)
        for name,p in self.scene['locations'].items():
            self.world.plot(*p,'.',color='#182f43')
            self.world.annotate(name,p,xytext=(0,9),textcoords='offset points',ha='center',fontsize=9)
        self.route, = self.world.plot([],[],color='#ca8619',lw=3,zorder=3)
        self.rejected_line, = self.world.plot([],[],'--',color='#c2414a',lw=3,zorder=3)
        self.robot = Circle(self.position,self.scene['empty_radius'],color='#167e91',alpha=.85,zorder=5)
        self.world.add_patch(self.robot)
        self.parcel, = self.world.plot([],[],'s',color='#e99c20',ms=8,zorder=6)
        self.panel.axis('off')
        self.text = self.panel.text(0,1,'',va='top',fontsize=10,family='monospace')
        self.heading = self.fig.suptitle(self.titles[0],fontsize=16)
        self.fig.text(.1,.105,'Straight candidate connections · BFS minimizes action count · Kinematic playback, no manipulation physics',fontsize=9)
        self.buttons=[]
        for x,label,callback in [(.16,'Next stage',self.next_stage),(.43,'Play / Pause',self.toggle_play),(.70,'Reset',self.reset)]:
            button=Button(self.fig.add_axes([x,.035,.15,.045]),label)
            button.on_clicked(callback)
            self.buttons.append(button)
        self.timer=self.fig.canvas.new_timer(interval=30)
        self.timer.add_callback(self.tick)
        self.fig.canvas.mpl_connect('close_event',lambda event:self.timer.stop())
        self.timer.start()
        self.render()

    def render_pose(self,state,position=None):
        pos = tuple(self.scene['locations'][location(state)]) if position is None else position
        self.robot.center=pos
        self.robot.set_radius(radius_for(self.scene,state))
        if loaded(state):
            package=pos
        else:
            fact=next(f for f in state if f.startswith('(package-at parcel '))
            package=self.scene['locations'][fact[1:-1].split()[-1]]
        self.parcel.set_data([package[0]],[package[1]])

    def render(self):
        state=self.execution_state
        plan=[]; highlight=None
        details=('Package goal: (package-at parcel delivery)\n'
                 f'Empty radius {self.scene["empty_radius"]} m; loaded radius {self.scene["loaded_radius"]} m.')
        self.route.set_data([],[]);self.rejected_line.set_data([],[])
        if self.stage in (1,2) and self.result.attempts:
            candidate=self.result.attempts[0]
            plan=candidate.plan
            if self.stage==2:
                v=candidate.validation
                state=v.states[-1]
                highlight=v.failed_index
                details=('CHECK ONLY: execution has not started.\n'
                         + ('Candidate passes geometric checks.' if v.valid else
                            f'{v.reason}\nRemove: {v.permission}\nEmpty permission stays available.'))
                if v.permission:
                    _,a,b=v.permission[1:-1].split()
                    self.rejected_line.set_data(*zip(self.scene['locations'][a],self.scene['locations'][b]))
        elif self.stage>=3:
            if self.final:
                plan=self.final.plan
                points=[self.scene['locations'][location(s)] for s in self.final.validation.states]
                self.route.set_data(*zip(*points))
                details='All designated motions checked.\nNo action has been executed yet.'
                if self.stage==4:
                    highlight=self.action_index if self.action_index<len(plan) else None
                    details=('GOAL REACHED: package delivered.' if highlight is None
                             else 'EXECUTION of validated plan.\nFacts update when each action finishes.')
            else:
                details=self.result.status+'\n'+self.result.message
        self.heading.set_text(self.titles[self.stage])
        prefix='Hypothetical facts' if self.stage==2 else 'Current facts'
        lines=[prefix+':',*visible_facts(state),'',f'Load: {"loaded" if loaded(state) else "empty"}', '',
               'Actions:' if plan else 'Press Next stage to inspect the plan.']
        for i,op in enumerate(plan):
            lines.append(('> ' if i==highlight else '  ')+f'{i+1}. '+op.name)
        lines += ['']
        for line in details.splitlines():
            lines.extend(textwrap.wrap(line, width=51) or [''])
        if self.stage==2 and self.result.attempts[0].validation.valid:
            self.heading.set_text('3 · Candidate passes geometric checks')
        self.text.set_text('\n'.join(lines))
        self.render_pose(state,self.position if self.stage==4 else None)
        self.fig.canvas.draw_idle()

    def next_stage(self,event=None):
        self.playing=False
        self.stage=min(4 if self.final else 3,self.stage+1)
        if self.stage==4:
            self.execution_state=frozenset(self.final.task.initial_state)
            self.position=tuple(self.scene['locations'][location(self.execution_state)])
            self.action_index,self.elapsed=0,0.
        self.render()

    def toggle_play(self,event=None):
        if self.stage!=4 or not self.final:
            return
        if self.action_index==len(self.final.plan):
            self.execution_state=frozenset(self.final.task.initial_state)
            self.action_index,self.elapsed=0,0.
            self.position=tuple(self.scene['locations'][location(self.execution_state)])
        self.playing=not self.playing
        self.last_time=time.monotonic()
        self.render()

    def advance(self,dt):
        """Advance validated playback; symbolic changes use parsed PDDL operators."""
        if not self.playing or dt<=0:
            return
        while dt>0 and self.action_index<len(self.final.plan):
            op=self.final.plan[self.action_index]
            if not op.applicable(self.execution_state):
                raise RuntimeError('Playback state violates the PDDL action preconditions.')
            after=frozenset(op.apply(self.execution_state))
            a=self.scene['locations'][location(self.execution_state)]
            b=self.scene['locations'][location(after)]
            duration=max(.6,math.dist(a,b))  # Movement at 1 m/s; handling lasts .6 s.
            step=min(dt,duration-self.elapsed)
            self.elapsed+=step;dt-=step
            t=self.elapsed/duration
            self.position=tuple(x+(y-x)*t for x,y in zip(a,b))
            if self.elapsed>=duration-1e-10:
                self.execution_state=after
                self.action_index+=1;self.elapsed=0.
        if self.action_index==len(self.final.plan):
            self.playing=False
        self.render()

    def tick(self):
        if self.playing:
            now=time.monotonic()
            dt=now-self.last_time;self.last_time=now
            self.advance(dt)

    def reset(self,event=None):
        self.stage,self.playing,self.action_index,self.elapsed=0,False,0,0.
        self.execution_state=self.result.initial_state
        self.position=tuple(self.scene['locations'][location(self.execution_state)])
        self.render()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--scene',type=Path,help='Alternative geometry JSON with the same PDDL locations.')
    parser.add_argument('--headless',action='store_true',help='Print candidate/refinement trace and exit.')
    parser.add_argument('--export',type=Path,help='Write an overview without opening a window.')
    parser.add_argument('--export-stage',choices=['rejected','plan','goal'],default='plan')
    args=parser.parse_args()
    try:
        scene=load_scene(args.scene)
        result=solve(scene)
        print_trace(result)
        if args.headless and not args.export:
            return 0 if result.status=='success' else 1
        if args.export:
            import matplotlib
            matplotlib.use('Agg')
        app=Demo(scene,result)
        if args.export:
            target={'rejected':2,'plan':3,'goal':4}[args.export_stage]
            for _ in range(target):app.next_stage()
            if args.export_stage=='goal' and app.final:
                app.toggle_play();app.advance(100)
            args.export.parent.mkdir(parents=True,exist_ok=True)
            app.fig.savefig(args.export,dpi=140)
            app.plt.close(app.fig)
        else:
            app.plt.show()
        return 0 if result.status=='success' else 1
    except (ValueError,KeyError) as error:
        parser.error(str(error))


if __name__=='__main__':
    raise SystemExit(main())
