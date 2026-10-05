# Week 12 — Localization and range-only SLAM

Select **Localization: known map** or **SLAM: unknown map** in the same visualization. Physical landmarks stay fixed in both modes. Both modes measure **distance only**, with known landmark IDs and fixed robot heading.

## Launch

On your Linux computer, open a terminal at the repository root. The existing `.venv` has Python 3.12.3, NumPy 1.26.4 and Matplotlib 3.10.8, so you can launch directly:

```bash
cd /home/gilad/robotics-course/robotics-course-demos
source .venv/bin/activate
python week12_filters_slam/demo/visualize.py
```

To start directly in SLAM mode, run from that same terminal:

```bash
python week12_filters_slam/demo/visualize.py --mode slam
```

An interactive Matplotlib desktop backend is required for the window. If no window opens or Matplotlib selects the noninteractive `Agg` backend, try:

```bash
MPLBACKEND=TkAgg python week12_filters_slam/demo/visualize.py --mode slam
```

This requires Tk support and a desktop display; run it in your local desktop terminal. No ROS or robotics simulator is needed.

For a fresh setup, the pinned requirements support Python 3.10–3.12. From the repository root, create and activate an environment, then install the dependencies:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -r week12_filters_slam/demo/requirements.txt
```

On Windows, use `python -m venv .venv` with a supported Python version and activate with `.venv\Scripts\Activate.ps1`; the installation and launch commands above then use the same repository-relative paths. Historical SLAM validation used Python 3.13.5 / NumPy 2.2.6; that is separate from the pinned environment and the local dependency check above.

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

## Why the SLAM result has several clumps

There are four estimated objects: one robot and three landmarks. Yellow/green dots describe the robot belief; blue, green and purple contours describe L1, L2 and L3. Within each object's belief, the default low-noise run can also show several separate clumps. Those are alternative hypotheses, not extra robots or landmarks. The algorithm does not impose a count of four clumps.

Range-only observations constrain distances, not directions. A first observation leaves a ring of possible landmark positions; observations along a straight path can leave alternatives on opposite sides of that path. Turning gives additional information, but the robot trajectory is itself uncertain.

Robot and map uncertainty are coupled: shifting a whole candidate robot trajectory and all its landmarks by the same amount preserves their relative distances. The initial robot prior and finite map bounds constrain this freedom, but there is no exact known robot pose or landmark coordinate to fix the map's absolute position. Several robot/map explanations can therefore remain plausible. Corresponding clumps across the robot and landmark displays can reflect these different joint explanations; the separate plots do not show their correlations directly.

The finite particle approximation also affects the shape. Resampling duplicates successful robot hypotheses together with their maps and discards others. Repeating this with only 500 particles can leave a few dominant families; later motion noise spreads their robot descendants into clumps. The 0.125 m map grid and narrow likelihoods can make landmark probability islands look sharp. The exact number and prominence of clumps depend on seed, noise and stage; they are not a guarantee of four equally valid geometric solutions. The red robot X and landmark diamonds are averages, so they can fall between clumps where little probability lies.

A local ancestry trace of the default seed-7, 0.15 m run found only eight initial particle ancestors still represented after motion 32. The four largest families contained 227, 156, 64 and 22 descendants: together 469 of the 500 particles. This supports the explanation of a few dominant robot/map families. An ancestral family is not necessarily one visible clump, since descendants acquire different motion noise and map updates.

## Are L1–L3 particles or heatmaps?

The robot is represented by **500 weighted particles**. Each robot particle carries **three separate 81×81 probability grids**, one per landmark, conditional on that particle's robot trajectory. Landmark locations are not sampled as a separate cloud of particles in this implementation. These grids are the estimator's stored beliefs, not just a display effect.

The L1/L2/L3 selector shows the corresponding **marginal distribution**: for each grid cell, sum that landmark's conditional probability across robot particles, weighted by their robot weights. The colored contours on the main plot show the same marginal distributions. Bright heatmap cells are more plausible landmark locations; diamonds are their means. Selecting L1/L2/L3 only changes the displayed landmark. Resampling copies a selected robot particle and all three of its conditional grids together, preserving the robot/map relationship.

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

```bash
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
