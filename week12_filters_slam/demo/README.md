# Week 12 — Localization and range-only SLAM

Select **Localization: known map** or **SLAM: unknown map** in the same visualization. Physical landmarks stay fixed in both modes. Both modes measure **distance only**, with known landmark IDs and fixed robot heading.

## Launch

The pinned requirements support Python 3.10–3.12. Activate your course environment, then run from the repository root:

```powershell
python -m pip install -r week12_filters_slam/demo/requirements.txt
python week12_filters_slam/demo/visualize.py
python week12_filters_slam/demo/visualize.py --mode slam
```

An interactive Matplotlib desktop backend is required for the window. No ROS or robotics simulator is needed. For a Windows virtual environment, create it with `python -m venv .venv` and activate `.venv\Scripts\Activate.ps1`. Current local checks used an existing Python 3.13.5 / NumPy 2.2.6 environment; this is separate from validation of the unchanged NumPy 1.26.4 pin.

## Controls

- **Next stage:** Prediction → Weighting → Resampling, repeated over 32 commands.
- **Play/Pause:** automatically advance every 1.4 seconds, or pause for discussion. An update takes additional computation time.
- **Reset:** pause and restore seed 7, retaining selected mode and sensor noise.
- **Mode selector:** pause and reset when changing between known-map localization and unknown-map SLAM. Sensor noise and seed are retained.
- **Sensor selector:** choose 0.15 m or 0.60 m range standard deviation; changing it pauses and resets while retaining mode.
- **Show truth:** hide/show simulator truth without changing estimation. In localization, known landmark coordinates remain visible because they are supplied to the estimator.
- **L1 / L2 / L3:** choose the SLAM landmark detail heatmap. This affects the display only.

Playback stops after the last resampling. Invalid numerical inputs pause playback with an error; reset before continuing.

## Read the display

Robot dots are hypotheses, not physical robots. Size/color show robot weights; the red X is their weighted mean. Orange star/path is simulator truth for teaching only. In localization the black squares are known map landmarks.

In SLAM, gray squares show teaching-only true landmark locations. Blue/green/purple contours show landmark marginal probability regions (approximately 50% and 90% highest-density regions). Diamonds show posterior means. A mean can lie between modes or inside a ring where probability is low; inspect the full heatmap rather than treating a diamond as a unique solution. Heatmap brightness is scaled independently for each display; compare shapes, not absolute brightness across frames.

Before observations, landmark priors are uniform. One range produces a circular band conditional on a robot position. Measurements from additional viewpoints narrow the possibilities; collinear viewpoints can preserve ambiguity. In the seeded run, motion 8 illustrates ambiguity and motions 16/32 show later refinement. Estimated landmarks need not coincide exactly with the truth overlay.

## What each estimator knows

| Mode | Given | Estimated |
|---|---|---|
| Localization | Landmark coordinates, commands, identified ranges | Robot position |
| SLAM | Commands, identified ranges, robot prior, generic map bounds | Robot position and landmark coordinates jointly |

The SLAM estimator never receives true landmark coordinates or the true robot state. Simulation, sensing, and filtering use separate seeded random streams. Mode/noise changes preserve the same seeded physical motion. Landmark IDs are supplied, so this is not feature discovery or automatic data association.

The initial robot prior anchors the coordinate frame imperfectly. Relative observations leave robot/map uncertainty coupled; exact absolute-map recovery is not guaranteed. Heading is fixed. There is no explicit loop-closure detector, pose-graph optimizer, moving-object estimation, or retrospective trajectory correction display. Repeated identified-landmark observations provide new constraints.

## Model and algorithm

The existing localization algorithm is unchanged: 500 particles; initial Gaussian mean (2,2), standard deviation 0.6 m per axis; motion noise 0.08 m per axis; three true landmarks at (0,0), (6,0), (0,6). Commands are eight 0.25 m moves in each of +x, +y, −x, −y. True noisy motion need not close a square. Range errors are independent Gaussian, and readings are not clipped. Display limits are not walls.

SLAM uses a Rao–Blackwellized particle filter with three conditional landmark-location grids per robot hypothesis. Each grid has 81×81 coordinates spanning −2 through 8 m at 0.125 m spacing. Its prior is uniform, independent of true coordinates. Bounds are a modeling assumption and can clip possible landmarks; resolution is a numerical approximation. These grids represent **locations of individual landmarks**, not occupancy probabilities.

For every robot hypothesis and landmark, integrate the range likelihood against the OLD conditional map to compute evidence. Multiply robot weights by these evidences; normalize. Update each conditional map by multiplying that old map by likelihood and normalizing. Prediction moves only robot particles. Systematic resampling copies the selected robot and its complete map together, with independent mutable storage for descendants.

The implementation uses float64, stable log-space normalization, and batches of 32 robot hypotheses. Persistent map probabilities use about 75.1 MiB; working arrays and resampling copies require additional memory. It resamples after every measurement; adaptive resampling and recovery are not implemented. Particle depletion and map quantization can produce artifacts.

The decomposition is inspired by FastSLAM, but the original landmark-EKF FastSLAM algorithm is not what this demo implements. Here grids preserve range-only ring/multimodal distributions.

## Classroom sequence

Use the five pause points in the presentation: initial localization, prediction, weighting, resampling, then SLAM.

In SLAM, reset; step through the first observation and inspect each landmark heatmap. Play a few cycles or use the prepared motion-8/16/32 images. Ask why one distance cannot locate a point and why each resampled robot must bring its own map. Briefly compare noise presets, noting that selection resets the experiment. There is no code walkthrough.

## Headless export and tests

```powershell
python week12_filters_slam/demo/visualize.py --headless --output week12_filters_slam/slides/demo_validation/localization_low
python week12_filters_slam/demo/visualize.py --headless --sigma 0.6 --output week12_filters_slam/slides/demo_validation/localization_high
python week12_filters_slam/demo/visualize.py --headless --mode slam --output week12_filters_slam/demo/figures/slam_low
python week12_filters_slam/demo/visualize.py --headless --mode slam --sigma 0.6 --output week12_filters_slam/demo/figures/slam_high
python -m unittest discover -s week12_filters_slam/demo -p 'test_*.py' -v
python week12_filters_slam/demo/validate_demo.py
```

`--seed` defaults to 7. Headless output contains the first four stages and a `summary.json`. SLAM additionally exports maps after motions 8,16,32 and a compressed `final_map.npz` containing marginal maps and robot hypotheses. Stage timing samples exclude the first cycle; snapshot timing includes drawing and PNG export.

Original localization fallback images remain unchanged: [initial](figures/initial.png), [prediction](figures/prediction.png), [weighting](figures/weighting.png), [resampling](figures/resampling.png). SLAM snapshots: [first range](figures/slam_low/weighting.png), [motion 8](figures/slam_low/map_motion_08.png), [motion 16](figures/slam_low/map_motion_16.png), [motion 32](figures/slam_low/map_motion_32.png), [higher noise](figures/slam_high/map_motion_32.png).

## Validation provenance

Current execution: Python 3.13.5, NumPy 2.2.6, Matplotlib 3.10.8. All five original tests and seven new SLAM tests passed. Tests include independent Bayesian enumeration, circular ambiguity, noncollinear observations, map ancestry/copy isolation, input rejection, controls, resets, and complete normalized runs at both noise levels. Headless exports completed in both modes and both noise settings. A hidden TkAgg desktop smoke check also passed startup, mode/stage controls, truth/landmark selection, playback, noise/reset and shutdown; its record is `../slides/demo_validation/gui.json`. Exact results and timings are in each summary and `../slides/demo_validation/tests.json`.

Seed-7 final robot errors: localization 0.171 m / 0.354 m; SLAM 0.584 m / 0.437 m for low/high noise. These are diagnostic single-run measurements, not monotonic accuracy or robustness guarantees. Higher noise happened to give lower absolute error in this SLAM run; model uncertainty and resampling explain why one run is not a universal comparison.

Historical validation, separate from current checks: the previous localization-only demo passed five tests with Python 3.12, NumPy 1.26.4 and Matplotlib 3.10.8. Qt startup and programmatic controls were checked on the previous desktop, with benign Qt/Wayland and Axes3D notices. That record does not validate the new SLAM mode or the current pinned environment. A full human classroom rehearsal remains separate.

Sources: [Monte Carlo Localization](https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf), [SLAM tutorial](https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf), [FastSLAM](https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf).