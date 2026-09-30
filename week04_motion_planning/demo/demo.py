"""Step through PRM, preview configurations, or export figures without a desktop."""
import argparse
import math
from pathlib import Path
import time

import numpy as np

from robot import (L1, L2, LINK_RADIUS, PADDING, OBSTACLE, LIMIT, START, GOAL,
                   configuration_free, edge_free, forward_points, interpolate)
from planner import build_roadmap, query_roadmap


class Demo:
    stages = ['1 · Direct motion is blocked', '2 · Accepted random samples',
              '3 · Collision-checked roadmap', '4 · Search result and playback']

    def __init__(self, samples=300, neighbors=10, seed=7):
        import matplotlib.pyplot as plt
        from matplotlib.collections import LineCollection
        from matplotlib.patches import Circle
        from matplotlib.widgets import Button
        self.plt = plt
        self.graph = build_roadmap(samples, neighbors, seed)
        begin = time.perf_counter()
        self.result = query_roadmap(self.graph, START, GOAL)
        self.query_seconds = time.perf_counter() - begin
        self.stage, self.playing, self.distance = 0, False, 0.0
        self.last_time = None
        self.speed = 0.7  # Joint-space radians/second, only for visual playback.
        self.playback = []
        for a, b in zip(self.result.path, self.result.path[1:]):
            self.playback.extend(interpolate(a, b)[:-1])
        if self.result.path:
            self.playback.append(self.result.path[-1])
        self.arc = np.r_[0.0, np.cumsum([math.dist(a, b) for a, b in
                                       zip(self.playback, self.playback[1:])])]
        self.fig, (self.work, self.space) = plt.subplots(1, 2, figsize=(12, 6.5))
        self.fig.subplots_adjust(bottom=.28, top=.84, wspace=.30)
        self.work.set(xlim=(-1.12, 1.12), ylim=(-1.12, 1.12), xlabel='x (m)', ylabel='y (m)',
                      title='Workspace · both links matter', aspect='equal')
        self.work.grid(alpha=.2)
        self.work.add_patch(Circle(OBSTACLE[:2], OBSTACLE[2], color='#d1495b'))
        self.work.add_patch(Circle(OBSTACLE[:2], OBSTACLE[2]+PADDING,
                                  fill=False, linestyle='--', color='#d1495b'))
        self.arm, = self.work.plot([], [], '-o', color='#147d92', lw=7, solid_capstyle='round')
        self.capsules = [Circle((0, 0), LINK_RADIUS, color='#147d92') for _ in range(3)]
        # Link polygons plus rounded end caps depict physical thickness in data units.
        from matplotlib.patches import Polygon
        self.links = [Polygon(np.zeros((4, 2)), color='#147d92') for _ in range(2)]
        for artist in self.links + self.capsules:
            self.work.add_patch(artist)
        self.arm.set_linewidth(1)
        self.pose_text = self.work.text(.02, .97, '', transform=self.work.transAxes, va='top', fontsize=9)
        self.space.set(xlim=(-LIMIT, LIMIT), ylim=(-LIMIT, LIMIT), xlabel='q1 (rad)',
                       ylabel='q2 (rad)', title='Configuration space · one point = whole arm', aspect='equal')
        angles = np.linspace(-LIMIT, LIMIT, 121)
        blocked = np.array([[not configuration_free((a, b)) for a in angles] for b in angles])
        from matplotlib.colors import ListedColormap
        self.space.imshow(blocked, origin='lower', extent=(-LIMIT, LIMIT, -LIMIT, LIMIT),
                          cmap=ListedColormap(['#f6fafb', '#f4b7bd']), interpolation='nearest', alpha=.8)
        self.space.plot(*zip(START, GOAL), '--', color='#c43c47', lw=1.5, label='Blocked direct edge')
        self.space.scatter(*zip(START, GOAL), c=['#14804a', '#8a4bb6'], s=65, zorder=6)
        self.space.annotate('start', START, xytext=(5, 7), textcoords='offset points')
        self.space.annotate('goal', GOAL, xytext=(5, 7), textcoords='offset points')
        self.samples = self.space.scatter(*zip(*self.graph.points), s=7, color='#247ba0', visible=False)
        segments = [(self.result.roadmap.points[i], self.result.roadmap.points[j])
                    for i, row in enumerate(self.result.roadmap.adjacency) for j, _ in row if i < j]
        self.edges = LineCollection(segments, colors='#8196a0', linewidths=.45, alpha=.55, visible=False)
        self.space.add_collection(self.edges)
        self.path_artist, = self.space.plot([], [], color='#d98200', lw=2.5, zorder=5)
        self.current, = self.space.plot([], [], 'o', color='#102c43', ms=6, zorder=7)
        self.heading = self.fig.suptitle(self.stages[0], fontsize=17)
        length = 'none' if self.result.length is None else f'{self.result.length:.3f} rad'
        self.fig.text(.07, .12,
            f'{samples} samples / {self.graph.attempts} attempts · k={neighbors} · seed={seed} · '
            f'{self.graph.edge_count} roadmap edges\n'
            f'Build {self.graph.seconds:.3f}s · query {self.query_seconds:.3f}s · path length {length}\n'
            'Click configuration space to preview. Bounded joints; no wrapping. Kinematic playback only.', fontsize=9)
        self.buttons = []
        for x, label, callback in [(0.16, 'Next stage', self.next_stage),
                                    (0.43, 'Play / Pause', self.toggle_play), (0.70, 'Reset', self.reset)]:
            button = Button(self.fig.add_axes([x, .035, .15, .045]), label)
            button.on_clicked(callback)
            self.buttons.append(button)
        self.fig.canvas.mpl_connect('button_press_event', self.preview)
        self.fig.canvas.mpl_connect('close_event', lambda event: self.timer.stop())
        self.timer = self.fig.canvas.new_timer(interval=30)
        self.timer.add_callback(self.tick)
        self.timer.start()
        self.show_pose(START)

    def show_pose(self, q):
        points = np.array(forward_points(q))
        free = configuration_free(q)
        color = '#147d92' if free else '#c43c47'
        self.arm.set_data(points[:, 0], points[:, 1])
        self.arm.set_color(color)
        for link, a, b in zip(self.links, points, points[1:]):
            d = b-a
            normal = LINK_RADIUS*np.array([-d[1], d[0]])/np.linalg.norm(d)
            link.set_xy([a+normal, b+normal, b-normal, a-normal])
            link.set_color(color)
        for cap, center in zip(self.capsules, points):
            cap.center = center
            cap.set_color(color)
        self.current.set_data([q[0]], [q[1]])
        self.pose_text.set_text(f'q = ({q[0]:.2f}, {q[1]:.2f})\n'
                               + ('Free (with padding)' if free else 'Collision / padding violation'))
        self.fig.canvas.draw_idle()

    def set_stage(self, stage):
        self.stage = stage
        self.samples.set_visible(stage >= 1)
        self.edges.set_visible(stage >= 2)
        if stage == 3 and self.result.path:
            self.path_artist.set_data(*zip(*self.result.path))
        else:
            self.path_artist.set_data([], [])
        suffix = ' — ' + self.result.message if stage == 3 else ''
        self.heading.set_text(self.stages[stage] + suffix)
        self.fig.canvas.draw_idle()

    def next_stage(self, event=None):
        self.set_stage(min(3, self.stage+1))

    def toggle_play(self, event=None):
        if self.stage != 3 or not self.playback:
            return
        if self.distance >= self.arc[-1]:
            self.distance = 0.0
        self.playing = not self.playing
        self.last_time = time.monotonic()

    def tick(self):
        if not self.playing:
            return
        now = time.monotonic()
        self.distance = min(self.arc[-1], self.distance+self.speed*(now-self.last_time))
        self.last_time = now
        i = min(len(self.playback)-1, int(np.searchsorted(self.arc, self.distance, side='right')))
        if i == 0 or self.arc[i] == self.arc[i-1]:
            q = self.playback[i]
        else:
            fraction = (self.distance-self.arc[i-1])/(self.arc[i]-self.arc[i-1])
            q = tuple(a+fraction*(b-a) for a, b in zip(self.playback[i-1], self.playback[i]))
        self.show_pose(q)
        if self.distance >= self.arc[-1]:
            self.playing = False

    def preview(self, event):
        if event.inaxes is self.space and event.xdata is not None and event.ydata is not None:
            self.playing, self.distance = False, 0.0
            self.show_pose((event.xdata, event.ydata))

    def reset(self, event=None):
        self.playing, self.distance = False, 0.0
        self.set_stage(0)
        self.show_pose(START)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--samples', type=int, default=300)
    parser.add_argument('--neighbors', type=int, default=10)
    parser.add_argument('--seed', type=int, default=7)
    parser.add_argument('--export', type=Path, help='Save final overview and exit without a GUI.')
    parser.add_argument('--compare', action='store_true', help='Print 20/300-sample results and exit.')
    args = parser.parse_args()
    if args.export:
        import matplotlib
        matplotlib.use('Agg')
    try:
        if args.compare:
            for n in (20, 300):
                graph = build_roadmap(n, args.neighbors, args.seed)
                begin = time.perf_counter()
                result = query_roadmap(graph, START, GOAL)
                print(f'n={n}, attempts={graph.attempts}, edges={graph.edge_count}, '
                      f'build={graph.seconds:.3f}s, query={time.perf_counter()-begin:.3f}s, '
                      f'length={result.length}: {result.message}')
            return
        app = Demo(args.samples, args.neighbors, args.seed)
        print(f'Direct edge valid: {edge_free(START, GOAL)}. {app.result.message}')
        if args.export:
            app.set_stage(3)
            args.export.parent.mkdir(parents=True, exist_ok=True)
            app.fig.savefig(args.export, dpi=150)
            app.plt.close(app.fig)
        else:
            app.plt.show()
    except (ValueError, RuntimeError) as error:
        parser.error(str(error))


if __name__ == '__main__':
    main()
