"""Hidden Tk desktop startup/control check, distinct from human rehearsal."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from visualize import Visualization


def main():
    app = Visualization()
    window = app.figure.canvas.manager.window
    window.withdraw()
    app.figure.canvas.draw()
    window.update()
    app.next_stage()
    app.next_stage()
    app.next_stage()
    app.mode_radio.set_active(1)
    app.next_stage()
    app.next_stage()
    app.next_stage()
    app.landmark_radio.set_active(1)
    app.truth_check.set_active(0)
    app.toggle()
    app.tick()
    app.toggle()
    app.radio.set_active(1)
    assert app.scenario.mode == 'slam'
    assert app.scenario.sigma == .6
    assert app.scenario.stage == 'Initial belief'
    assert not app.playing
    app.figure.canvas.draw()
    window.update()
    plt.close(app.figure)
    output = Path(__file__).resolve().parent.parent / 'slides' / 'demo_validation' / 'gui.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(dict(backend='TkAgg', startup=True, controls=True, shutdown=True,
                                     hidden_window=True, human_classroom_rehearsal=False), indent=2)+'\n', encoding='utf-8')
    print('TkAgg startup, mode/stages, truth, landmark, noise, playback/reset and shutdown passed.')


if __name__ == '__main__':
    main()
