# Week 12 — Particle-filter visualization

A visual aid for theory: predict → weight → resample. No classroom code walkthrough, ROS, or simulator installation. This demonstrates localization with known landmarks; SLAM is discussed in the presentation.

## Setup and launch

From the repository root (`robotics-course-demos/`), using Python 3.10 or newer:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r week12_filters_slam/demo/requirements.txt
python week12_filters_slam/demo/visualize.py
```

## Controls and classroom sequence

- **Next stage:** prediction → weighting → resampling, repeated for 32 motion commands.
- **Play/Pause:** advance automatically every 1.4 seconds or pause for discussion.
- **Reset:** restore seed 7 and the initial cloud, keeping the selected noise preset.
- **Sensor selector:** 0.15 m or 0.60 m standard deviation; switching resets and pauses.
- Close the window to stop. Playback stops after the last resampling step.

Begin with “which dots are possible positions?” Predict the next stage before pressing the button. During weighting, coordinates stay unchanged while size/color indicate relative weight. After resampling, weights are equal and coincident dots can hide duplicates. The weighted estimate can shift in either step. Repeat with noisier measurements; no single run guarantees a monotonic uncertainty reduction.

Orange star/path = simulator truth for explanation only. Red X = weighted estimate. Squares = known landmarks. Heading is fixed. The view limits are not walls; this is an unbounded plane. The prior already provides rough localization, so this is not global localization or kidnapped-robot recovery.

## Headless and fallback figures

Run these commands from the repository root with the virtual environment active:

```bash
python week12_filters_slam/demo/visualize.py --headless --output /tmp/week12-low
python week12_filters_slam/demo/visualize.py --headless --sigma 0.6 --output /tmp/week12-high
python -m unittest discover -s week12_filters_slam/demo -p 'test_*.py' -v
```

Headless mode saves four snapshots of the first cycle, then runs all 32 motion cycles and prints the final position error and weight sum. `--seed` defaults to 7. Saved classroom images: [initial](figures/initial.png), [prediction](figures/prediction.png), [weighting](figures/weighting.png), [resampling](figures/resampling.png). These are seeded illustrations, not accuracy guarantees.

## Model and files

- `model.py`: separate filter and simulator. The filter accepts commands and observations, owns the landmark map, and never receives simulator truth.
- `visualize.py`: stages, controls, explanatory panel, and figure export.
- `test_demo.py`: filtering and control regression checks.

There are 500 particles with Gaussian prior `(2,2)`, sigma 0.6 m per axis. Commands: eight 0.25 m moves in +x, +y, −x, −y. Motion noise is independent Gaussian sigma 0.08 m per axis for both simulator and filter, with separate random streams. Landmarks `(0,0),(6,0),(0,6)` are identified; observations are their ranges plus Gaussian noise. Range readings are not clipped. Changing sensor noise preserves the seeded physical motion and uses the same underlying standardized sensor noise, scaled by the preset.

Measurement likelihoods multiply the prior weights and use log-space normalization. Systematic resampling runs after every measurement. This simple teaching schedule can reduce particle diversity; no adaptive resampling or recovery is implemented. Gaussian priors/noise are assumptions, not claims about every robot.

## Troubleshooting and validation

If no interactive window appears, use an installed GUI-capable Matplotlib backend or the headless figures. Invalid inputs/likelihoods raise clear errors; an interactive update error pauses playback. Reset before continuing. See the validation record below for actual tested behavior.

Background: [Localization chapter](https://www.roboticsbook.org/S44_logistics_perception.html), [Monte Carlo Localization](https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf). See [teaching notes](../TEACHING_NOTES.md) for the board exercise, timing, and conceptual SLAM connection.

### Validation record

Tested with Python 3.12, NumPy 1.26.4, and Matplotlib 3.10.8. Five automated tests passed, covering worked weights, measurement likelihoods, prediction/resampling, reproducibility, and control callbacks. Qt GUI startup, timed playback, noise selection, reset, and shutdown passed on this desktop. The existing environment emitted Qt/Wayland notices and an unavailable Axes3D warning; the 2D visualization worked. A fresh environment still needs a desktop GUI backend (for example, system Tk support); headless export needs none.

Representative seed-7 console output:

```text
# sigma = 0.15 m
Completed 32 motions; weight sum=1.000000; final position error=0.171 m
# sigma = 0.60 m
Completed 32 motions; weight sum=1.000000; final position error=0.354 m
```

The fallback weighting figure was visually inspected for labels and layout. GUI checks used programmatic controls; a full human classroom rehearsal remains on the preparation checklist.
