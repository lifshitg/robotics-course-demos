"""Run: python visualize.py; export: python visualize.py --headless --output figures"""
import argparse
from pathlib import Path
import numpy as np
from model import Scenario, LANDMARKS

EXPLANATIONS = {
    'Initial belief': 'Each dot is a possible position.\nThe star is simulator truth, shown\nfor teaching only.',
    'Prediction': 'Move each hypothesis with noisy\nmotion. No new observation has\nbeen used yet.',
    'Weighting': 'Compare predicted ranges with\nthe sensor readings. Dot positions\nstay fixed; their weights change.',
    'Resampling': 'Select hypotheses by weight.\nWeights are equal again. Overlapping\ndots can hide duplicate particles.',
}


class Visualization:
    def __init__(self, sigma=.15, seed=7):
        import matplotlib.pyplot as plt
        from matplotlib.widgets import Button, RadioButtons
        self.scenario = Scenario(sigma, seed)
        self.playing = False
        self.figure = plt.figure(figsize=(12, 7))
        self.map = self.figure.add_axes([.07, .20, .52, .72])
        self.panel = self.figure.add_axes([.64, .29, .34, .60])
        self.buttons = []
        for x, label, callback in [(.10, 'Next stage', self.next_stage), (.28, 'Play/Pause', self.toggle), (.46, 'Reset', self.reset)]:
            button = Button(self.figure.add_axes([x, .06, .16, .065]), label)
            button.on_clicked(callback)
            self.buttons.append(button)
        self.radio = RadioButtons(self.figure.add_axes([.72, .045, .23, .15]), ['0.15 m', '0.60 m'], active=int(sigma == .6))
        self.radio.on_clicked(self.change_noise)
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

    def draw(self):
        s, ax = self.scenario, self.map
        f = s.filter
        ax.clear()
        ax.scatter(*LANDMARKS.T, marker='s', color='black', s=75, label='Known landmarks')
        for index, location in enumerate(LANDMARKS):
            ax.annotate(f'L{index+1}', location, xytext=(8, 8), textcoords='offset points')
        scaled = f.weights / f.weights.max()
        ax.scatter(*f.particles.T, c=f.weights, s=12 + 95 * scaled,
                   cmap='viridis', vmin=0, vmax=max(f.weights.max(), 1/500), alpha=.55, label='Particles (size/color = weight)')
        history = np.asarray(s.history)
        ax.plot(*history.T, color='tab:orange', alpha=.5)
        ax.scatter(*s.truth, marker='*', s=220, color='tab:orange', edgecolors='black', label='True position (teaching only)')
        ax.scatter(*f.estimate, marker='X', s=120, color='crimson', label='Weighted estimate')
        ax.set(xlim=(-1, 7), ylim=(-1, 7), xlabel='x (m)', ylabel='y (m)', aspect='equal')
        ax.grid(alpha=.2)
        ax.legend(loc='upper right', fontsize=8)
        ax.set_title(f'{s.stage} — motion {s.step}/32')
        self.panel.clear()
        self.panel.axis('off')
        readings = 'Not yet used this motion' if s.observation is None else ', '.join(f'{v:.2f}' for v in s.observation)
        text = (f'{s.stage}\n\n{EXPLANATIONS[s.stage]}\n\n'
                f'Sensor standard deviation: {s.sigma:.2f} m\n'
                f'Ranges L1, L2, L3 (m):\n{readings}\n\n'
                f'Estimate: ({f.estimate[0]:.2f}, {f.estimate[1]:.2f}) m\n'
                f'Weight sum: {f.weights.sum():.3f}\n\n'
                'Known map; position only.\nHeading is fixed.\n\n'
                'Prediction → Weighting → Resampling\n\n'
                + ('Finished — Reset to repeat.' if s.done else ('Playing' if self.playing else 'Paused — predict the next change.')))
        self.panel.text(0, 1, text, va='top', fontsize=11, linespacing=1.5)
        self.figure.suptitle('Particle-filter localization — a belief made of hypotheses', fontsize=16)
        self.figure.canvas.draw_idle()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--headless', action='store_true')
    parser.add_argument('--output', type=Path, default=Path('figures'))
    parser.add_argument('--sigma', type=float, choices=[.15, .6], default=.15)
    parser.add_argument('--seed', type=int, default=7)
    args = parser.parse_args()
    import matplotlib
    if args.headless:
        matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    app = Visualization(args.sigma, args.seed)
    if args.headless:
        args.output.mkdir(parents=True, exist_ok=True)
        for name in ['initial', 'prediction', 'weighting', 'resampling']:
            if name != 'initial':
                app.next_stage()
            app.figure.savefig(args.output / f'{name}.png', dpi=140)
        while not app.scenario.done:
            app.scenario.advance()
        s = app.scenario
        print(f'Completed {s.step} motions; weight sum={s.filter.weights.sum():.6f}; final position error={np.linalg.norm(s.truth-s.filter.estimate):.3f} m')
        plt.close(app.figure)
    else:
        plt.show()


if __name__ == '__main__':
    main()
