"""Run: python visualize.py; export: python visualize.py --headless --output figures"""
import argparse
import json
import platform
import time
from pathlib import Path
import numpy as np
from model import Scenario, LANDMARKS

EXPLANATIONS = {
    'Initial belief': 'Each dot is a possible position.\nThe star is simulator truth, shown\nfor teaching only.',
    'Prediction': 'Move each hypothesis with noisy\nmotion. No new observation has\nbeen used yet.',
    'Weighting': 'Compare predicted ranges with\nthe sensor readings. Dot positions\nstay fixed; their weights change.',
    'Resampling': 'Select hypotheses by weight.\nWeights are equal again. Overlapping\ndots can hide duplicate particles.',
}

SLAM_EXPLANATIONS = {
    'Initial belief': 'Landmark locations are unknown.\nEach robot hypothesis carries three\nuniform landmark probability grids.',
    'Prediction': 'Move the robot hypotheses.\nStatic landmark grids stay fixed.\nNo new range reading yet.',
    'Weighting': 'A range gives a circular band.\nUpdate conditional landmark grids\nand robot weights using old-map evidence.',
    'Resampling': 'Copy each selected robot hypothesis\nTOGETHER with its conditional map.\nRobot weights are uniform again.',
}
MAP_COLORS = ['tab:blue', 'tab:green', 'tab:purple']


class Visualization:
    def __init__(self, sigma=.15, seed=7, mode='localization'):
        import matplotlib.pyplot as plt
        from matplotlib.widgets import Button, RadioButtons, CheckButtons
        self.scenario = Scenario(sigma, seed, mode)
        self.playing = False
        self.show_truth, self.selected_landmark = True, 0
        self.figure = plt.figure(figsize=(16, 9))
        self.map = self.figure.add_axes([.05, .25, .43, .66])
        self.detail = self.figure.add_axes([.52, .43, .25, .45])
        self.panel = self.figure.add_axes([.79, .25, .20, .64])
        self.buttons = []
        for x, label, callback in [(.05, 'Next stage', self.next_stage), (.22, 'Play/Pause', self.toggle), (.39, 'Reset', self.reset)]:
            button = Button(self.figure.add_axes([x, .055, .15, .06]), label)
            button.on_clicked(callback)
            self.buttons.append(button)
        self.radio = RadioButtons(self.figure.add_axes([.85, .03, .13, .14]), ['0.15 m', '0.60 m'], active=int(sigma == .6))
        self.radio.on_clicked(self.change_noise)
        self.mode_radio = RadioButtons(self.figure.add_axes([.57, .03, .26, .14]),
                                       ['Localization: known map', 'SLAM: unknown map'], active=int(mode == 'slam'))
        self.mode_radio.on_clicked(self.change_mode)
        self.truth_check = CheckButtons(self.figure.add_axes([.05, .15, .15, .06]), ['Show truth'], [True])
        self.truth_check.on_clicked(self.toggle_truth)
        self.landmark_radio = RadioButtons(self.figure.add_axes([.52, .20, .10, .16]), ['L1', 'L2', 'L3'])
        self.landmark_radio.on_clicked(self.change_landmark)
        self.timer = self.figure.canvas.new_timer(interval=1400)
        self.timer.add_callback(self.tick)
        self.timer.start()
        self.figure.canvas.mpl_connect('close_event', lambda event: self.timer.stop())
        self.draw()

    def next_stage(self, event=None):
        try:
            self.scenario.advance()
        except ValueError as error:
            self.playing = False
            self.panel.clear()
            self.panel.text(0, .8, f'Cannot continue:\n{error}', wrap=True)
            self.figure.canvas.draw_idle()
            return
        if self.scenario.done:
            self.playing = False
        self.draw()

    def toggle(self, event=None):
        self.playing = not self.playing and not self.scenario.done
        self.draw()

    def tick(self):
        if self.playing:
            self.next_stage()

    def reset(self, event=None):
        self.playing = False
        self.scenario.reset()
        self.draw()

    def change_noise(self, label):
        self.scenario.sigma = float(label.split()[0])
        self.reset()

    def change_mode(self, label):
        self.scenario.mode = 'slam' if label.startswith('SLAM') else 'localization'
        self.reset()

    def toggle_truth(self, label=None):
        self.show_truth = bool(self.truth_check.get_status()[0])
        self.draw()

    def change_landmark(self, label):
        self.selected_landmark = int(label[1:]) - 1
        self.draw()

    def draw(self):
        s, ax = self.scenario, self.map
        f = s.filter
        ax.clear()
        slam = s.mode == 'slam'
        ax.set_position([.045, .26, .43 if slam else .56, .65])
        self.panel.set_position([.79 if slam else .64, .25, .20 if slam else .34, .64])
        self.detail.set_visible(slam)
        self.landmark_radio.ax.set_visible(slam)
        if not slam or self.show_truth:
            ax.scatter(*LANDMARKS.T, marker='s', color='black' if not slam else 'gray', s=65,
                       label='Known landmarks' if not slam else 'True landmarks (teaching only)')
            for index, location in enumerate(LANDMARKS):
                ax.annotate(f'L{index+1}', location, xytext=(8, 8), textcoords='offset points')
        if slam:
            marginal = f.landmark_marginals
            means = marginal.reshape(3, -1) @ f.grid_points
            for index, probability in enumerate(marginal):
                if np.ptp(probability) > 1e-12:
                    descending = np.sort(probability.ravel())[::-1]
                    mass = np.cumsum(descending)
                    levels = sorted(set(descending[min(np.searchsorted(mass, p), len(descending)-1)] for p in [.9, .5]))
                    ax.contour(f.grid_axis, f.grid_axis, probability, levels=levels, colors=MAP_COLORS[index], linewidths=1.5)
                    ax.scatter(*means[index], marker='D', s=48, color=MAP_COLORS[index], label=f'L{index+1} posterior mean')
            detail = self.detail
            detail.clear()
            j = self.selected_landmark
            detail.imshow(marginal[j], origin='lower', extent=(-2.0625, 8.0625, -2.0625, 8.0625), cmap='magma', aspect='equal')
            if np.ptp(marginal[j]) > 1e-12:
                detail.scatter(*means[j], marker='D', color='cyan', s=40)
            if self.show_truth:
                detail.scatter(*LANDMARKS[j], marker='s', facecolors='none', edgecolors='white', s=60)
            detail.set(xlim=(-2, 8), ylim=(-2, 8), xlabel='x (m)', ylabel='y (m)', title=f'L{j+1}: probability per grid location')
            detail.text(.5, -.12, 'Bright = more plausible; mean may lie between modes', transform=detail.transAxes,
                        ha='center', fontsize=9)
        else:
            self.detail.clear()
        scaled = f.weights / f.weights.max()
        ax.scatter(*f.particles.T, c=f.weights, s=12 + 95 * scaled,
                   cmap='viridis', vmin=0, vmax=max(f.weights.max(), 1/500), alpha=.55, label='Particles (size/color = weight)')
        if self.show_truth:
            history = np.asarray(s.history)
            ax.plot(*history.T, color='tab:orange', alpha=.5)
            ax.scatter(*s.truth, marker='*', s=220, color='tab:orange', edgecolors='black', label='True position (teaching only)')
        ax.scatter(*f.estimate, marker='X', s=120, color='crimson', label='Weighted estimate')
        ax.set(xlim=(-2, 8) if slam else (-1, 7), ylim=(-2, 8) if slam else (-1, 7), xlabel='x (m)', ylabel='y (m)', aspect='equal')
        ax.grid(alpha=.2)
        ax.legend(loc='upper right', fontsize=8)
        ax.set_title(f'{s.stage} — motion {s.step}/32')
        self.panel.clear()
        self.panel.axis('off')
        readings = 'Not yet used this motion' if s.observation is None else ', '.join(f'{v:.2f}' for v in s.observation)
        explanation = SLAM_EXPLANATIONS if slam else EXPLANATIONS
        text = (f'{s.stage}\n\n{explanation[s.stage]}\n\n'
                f'Sensor standard deviation: {s.sigma:.2f} m\n'
                f'Ranges L1, L2, L3 (m):\n{readings}\n\n'
                f'Estimate: ({f.estimate[0]:.2f}, {f.estimate[1]:.2f}) m\n'
                f'Weight sum: {f.weights.sum():.3f}\n\n'
                + ('Unknown map; position only.\nRange only; landmark IDs known.\nGrid prior: [-2, 8] m, not walls.\nMap means can mislead.\n\n' if slam else 'Known map; position only.\nHeading is fixed.\n\n') +
                'Prediction → Weighting → Resampling\n\n'
                + ('Finished — Reset to repeat.' if s.done else ('Playing' if self.playing else 'Paused — predict the next change.')))
        self.panel.text(0, 1, text, va='top', fontsize=10 if slam else 11, linespacing=1.35)
        self.figure.suptitle('Grid-based range-only SLAM — estimate position AND map' if slam else 'Particle-filter localization — a belief made of hypotheses', fontsize=16)
        self.figure.canvas.draw_idle()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--headless', action='store_true')
    parser.add_argument('--output', type=Path, default=Path('figures'))
    parser.add_argument('--sigma', type=float, choices=[.15, .6], default=.15)
    parser.add_argument('--seed', type=int, default=7)
    parser.add_argument('--mode', choices=['localization', 'slam'], default='localization')
    args = parser.parse_args()
    import matplotlib
    if args.headless:
        matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    app = Visualization(args.sigma, args.seed, args.mode)
    if args.headless:
        args.output.mkdir(parents=True, exist_ok=True)
        for name in ['initial', 'prediction', 'weighting', 'resampling']:
            if name != 'initial':
                app.next_stage()
            app.figure.savefig(args.output / f'{name}.png', dpi=140)
        timings, renderings = [], []
        stage_timings = {'Prediction': [], 'Weighting': [], 'Resampling': []}
        while not app.scenario.done:
            before = app.scenario.stage
            begin = time.perf_counter()
            app.scenario.advance()
            elapsed = time.perf_counter() - begin
            stage_timings[app.scenario.stage].append(elapsed)
            if before == 'Prediction':
                timings.append(elapsed)
            if args.mode == 'slam' and app.scenario.stage == 'Resampling' and app.scenario.step in (8, 16, 32):
                begin = time.perf_counter()
                app.draw()
                app.figure.savefig(args.output / f'map_motion_{app.scenario.step:02d}.png', dpi=140)
                renderings.append(time.perf_counter() - begin)
        s = app.scenario
        print(f'Completed {s.step} motions; weight sum={s.filter.weights.sum():.6f}; final position error={np.linalg.norm(s.truth-s.filter.estimate):.3f} m')
        summary = {'mode': s.mode, 'seed': args.seed, 'sensor_sigma': s.sigma,
                   'motions': s.step, 'robot_estimate': s.filter.estimate.tolist(),
                   'robot_error_m': float(np.linalg.norm(s.truth-s.filter.estimate)),
                   'weight_sum': float(s.filter.weights.sum()),
                   'python': platform.python_version(), 'numpy': np.__version__, 'matplotlib': matplotlib.__version__,
                   'correction_median_seconds': float(np.median(timings)),
                   'correction_max_seconds': float(max(timings)), 'snapshot_render_seconds': renderings,
                   'stage_median_seconds': {key: float(np.median(values)) for key, values in stage_timings.items()},
                   'stage_max_seconds': {key: float(max(values)) for key, values in stage_timings.items()}}
        if args.mode == 'slam':
            f = s.filter
            summary.update(landmark_means=f.landmark_means.tolist(),
                           landmark_errors_m=np.linalg.norm(f.landmark_means-LANDMARKS, axis=1).tolist(),
                           conditional_map_sum_min=float(f.map_probs.sum(axis=-1).min()),
                           conditional_map_sum_max=float(f.map_probs.sum(axis=-1).max()),
                           marginal_sums=f.landmark_marginals.sum(axis=(1, 2)).tolist(),
                           all_finite=bool(np.isfinite(f.map_probs).all() and np.isfinite(f.weights).all()))
            np.savez_compressed(args.output / 'final_map.npz', axis=f.grid_axis, marginals=f.landmark_marginals,
                                robot_particles=f.particles, robot_weights=f.weights)
        (args.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
        plt.close(app.figure)
    else:
        plt.show()


if __name__ == '__main__':
    main()
