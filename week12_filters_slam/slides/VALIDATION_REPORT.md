# Week 12 validation report

## Delivered

- Editable 16:9 English PowerPoint and matching all-slide PDF: `SLAM_AND_BAYESIAN_ESTIMATION`.
- 38 slides: title,26 teaching slides, five integrated visualization slides, recap, five hidden backups34–38.
- Exact timing:30 minutes explanation,12 minutes visualization,3 minutes recap.
- Revised presentation plan, detailed notes with primary references, reproducible PowerShell sources,38 previews and seven contact sheets.
- Selectable known-map localization / unknown-map range-only SLAM demo, documentation, regression tests, prepared map snapshots and numerical exports.

## Executed checks

### Demo

Current runtime: Python3.13.5, NumPy2.2.6, Matplotlib3.10.8. This environment was found directly at the local Python313 path although the launcher reported no registered Python installations. The unchanged requirements pin NumPy1.26.4; this session did NOT validate a freshly installed pinned environment.

All12 tests passed: five original tests unchanged plus seven new SLAM tests. Recorded execution took42.16 seconds. New tests cover truth-independent map priors, normalization, an independent explicitly enumerated Bayesian update, OLD-map predictive evidence, circular ambiguity, multiple noncollinear viewpoints, weighted map marginals, joint resampling/alias isolation, invalid inputs, mode/noise/reset/display controls, identical seeded physical motion, and complete32-motion runs at both noise levels. See `demo_validation/tests.txt` and `tests.json`.

Headless runs completed for all four mode/noise combinations with seed7. Robot weights and conditional/marginal map distributions stayed finite and normalized. Summaries record the actual results, including artifacts and offsets; errors are diagnostics, not guarantees.

| Mode | Range sigma | Final robot error | Landmark mean errors L1/L2/L3 |
|---|---:|---:|---|
| Localization |0.15m|0.171m|Known map|
| Localization |0.60m|0.354m|Known map|
| SLAM |0.15m|0.584m|0.584 /0.238 /0.885m|
| SLAM |0.60m|0.437m|0.229 /0.153 /0.529m|

The higher-noise SLAM trial happened to have a smaller absolute error; do not imply guaranteed monotonic accuracy with noise. Initial robot uncertainty, particle ancestry and finite grids affect outcomes. Early rings and motion8 ambiguity are visible; later measurements constrain the maps. At low noise, particle/grid depletion produces visibly discrete modes. The demonstration retains these effects and does not fabricate a perfect map.

500-particle performance,81×81 grids: median correction0.464s at low noise and0.398s at high noise; median resampling about0.039s. Maximum correction0.498s /0.435s. Drawing plus PNG-export snapshots typically0.28–0.29s. Timing samples exclude the first cycle and are machine-specific. Persistent map probabilities are75.1MiB; working buffers/copies require additional memory. Vectorized operations use32-particle likelihood batches.

A hidden TkAgg desktop check passed startup, mode selection, prediction/weighting/resampling, landmark selection, truth overlay, play/tick/pause, noise/reset and shutdown. It required the normal desktop session: the sandbox could not initialize Tcl, while the installed runtime succeeded outside it. Record: `demo_validation/gui.json`. This was programmatic, not a full human classroom rehearsal.

### Mathematics and presentation

24 independent PowerShell checks passed: initial ranges, worked weights/expected copies, rotated-point example, Kalman gain/mean/covariance and Joseph agreement, occupancy log odds, grid resolution/memory, slide/backup counts and all timing sums.

Installed PowerPoint generated and rendered every slide, exported38 PDF pages including backups, saved the PPTX with five backups hidden, and reopened it successfully. ZIP checks verified38 slide and38 notes parts, ordered titles, notes timings and primary links, and hidden flags. All38 preview images were reviewed via seven contact sheets; equation-heavy and corrected diagram/image slides were also inspected individually. Text-bound checks report zero overflow. Image/footer and diagram-label spacing were corrected during visual review. PDF page count was checked; preview images come from PowerPoint's native slide renderer, not an independent PDF rasterizer.

Sources were reviewed: Monte Carlo Localization, Durrant-Whyte/Bailey SLAM tutorial, FastSLAM, occupancy-grid modeling, and the author RoboticsBook SLAM chapter. No professor lecture was supplied or claimed reviewed. Sensor likelihood equations are range-only. The local-point transform and scalar direct-position Kalman examples are explicitly separate teaching examples, not additional sensors secretly supplied to the demo.

## Preservation and limitations

SHA-256 checks passed for seven protected files: teaching notes, requirements, original localization tests, and four original localization images. Demo model/UI/README changes are expressly authorized for this week. Existing localization numerical outputs match historical documented values.

SLAM means fixed landmarks with unknown coordinates, not moving landmarks. It estimates position and map jointly with fixed heading and supplied IDs. Initial position and finite map bounds are explicit priors. Landmark-location grids are not occupancy grids. No automatic feature discovery, heading estimation, adaptive resampling, recovery, explicit loop-closure detector or global trajectory optimizer is implemented. Conditional maps are quantized; finite robot particles can lose diversity.

Still separate: full human45-minute classroom rehearsal and fresh validation with the pinned NumPy1.26.4 environment. Historical Python3.12/Qt localization checks in the README are labeled historical and do not stand in for current SLAM validation.