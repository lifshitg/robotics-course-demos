# Week 7 — Watch the expert, then learn to imitate it

This demo uses real MuJoCo physics. A scripted expert controls a two-axis robot;
behavior cloning fits a separate policy from recorded observation/action pairs.
The expert and learner then run on identical, previously unseen test episodes.

## Setup

From the repository root (tested with Python 3.12 on Linux):

```bash
python3 -m venv /tmp/robotics-week07-venv
source /tmp/robotics-week07-venv/bin/activate
python -m pip install -r week07_imitation_learning/demo/requirements.txt
```

MuJoCo **3.14.0** is pinned to the tested version. Validation used NumPy 1.26.4 and
Matplotlib 3.6.3. No ROS, Gazebo, PyTorch, Gymnasium, model downloads, or GPU training
is required. The viewer needs a working desktop OpenGL context. The temporary
virtual environment may need recreating after reboot.

## Classroom sequence

### 1. Watch the expert

```bash
python week07_imitation_learning/demo/demo.py watch --controller expert
```

Identify the teal robot, orange target, and camera view. The expert receives
`[error_x, error_y, velocity_x, velocity_y]` and commands x/y **forces**, not target
positions. MuJoCo computes the motion. The expert is `4 × error − 3 × velocity`,
clipped to ±10 N; the 1 kg body has two slide joints and no gravity/contact motion.

The viewer labels controller, episode, and simulated time. **Space** pauses or
resumes; **R** restarts the current episode; **N** advances to the next test case.
Restart/next preserve pause status. Episodes stop advancing after five simulated
seconds; press R or N to continue. Drag the camera with the viewer's mouse controls
(left drag rotates, right drag pans, scroll zooms). The initial camera is the same
for expert and learner. Close the window to exit.

### 2. Collect demonstrations

```bash
python week07_imitation_learning/demo/demo.py collect
```

This runs without a window: 100 episodes, seed 7, 250 labeled decisions per episode.
The observation is captured **before** its action; the stored label is the applied
force. Initial/target xy coordinates lie in [−0.6,0.6] m with at least 0.2 m separation;
initial velocities lie in [−0.2,0.2] m/s. All episodes last five seconds.

To inspect the first recorded row:

```bash
python -c "import numpy as np; d=np.load('week07_imitation_learning/demo/output/dataset.npz'); print(d['observations'][0], '->', d['actions'][0])"
```

### 3. Train behavior cloning

```bash
python week07_imitation_learning/demo/demo.py train
```

Fit `action = W @ observation + b` by least squares on whole episodes 0–79.
Episodes 80–99 provide validation action MSE. The training module reads data only;
it does not receive or import the expert gains. No rewards enter the loss.

The affine learner can represent this expert over the sampled operating range.
Expect near-zero MSE and weights near:

```text
[[4, 0, -3, 0],
 [0, 4, 0, -3]]
b = [0, 0]
```

These coefficients are estimated from labels. We do not deliberately degrade
learning to create a distribution-shift failure.

### 4. Watch the learned policy

```bash
python week07_imitation_learning/demo/demo.py watch --controller learner
```

Playback begins at the same seed-42 test start as the expert. Every control step
uses the learner's current observation to compute a new action. It neither queries
the expert nor replays recorded actions. Predicted forces have the same ±10 N limit.

### 5. Compare all controllers

```bash
python week07_imitation_learning/demo/demo.py evaluate
```

Twenty fresh seed-42 episodes are shared by expert, learner, and zero-force baseline.
Success requires distance <0.03 m AND speed <0.05 m/s at every control sample from
4.50 through 5.00 s. Policy rate is 50 Hz; physics rate is 100 Hz. This is a sampled
simulation success metric, not a continuous-time physical guarantee.

Representative measured output:

```text
Train action MSE: 2.67e-29; validation: 2.44e-29
expert : 20/20 successful; mean final distance 0.000425 m; speed 0.000395 m/s
learner: 20/20 successful; mean final distance 0.000425 m; speed 0.000395 m/s
zero   : 0/20 successful; mean final distance 0.886116 m; speed 0.140937 m/s
```

Tiny regression residuals may vary by numerical library. Action MSE measures
agreement on held-out expert data; rollout success measures closed-loop behavior.
The baseline may drift because its initial velocity is nonzero.

## Headless pipeline and outputs

```bash
python week07_imitation_learning/demo/demo.py all
python week07_imitation_learning/demo/demo.py all --output /tmp/week07-experiment
python -m unittest discover -s week07_imitation_learning/demo -p 'test_*.py' -v
```

`all` collects, trains, evaluates, and exports a plot without initializing the viewer.
The default `demo/output/` directory is ignored by Git. Re-running commands replaces
their output artifacts; use `--output` on **every command** to keep a separate run.

| Artifact | Contents |
|---|---|
| dataset.npz | observations [25000,4], actions [25000,2], episode_ids [25000] |
| collection.json | Seed, all starts/targets/velocities, timing, field order, MuJoCo version |
| policy.npz | Learned weights [2,4] and bias [2] |
| training.json | Episode split, row counts, training/validation action MSE |
| evaluation.json | Seed, summary metrics, and per-episode results |
| trajectories.npz | Expert/learner/baseline positions and targets |
| comparison.png | Shared-start trajectories, distance history, success counts |

[Saved classroom comparison](comparison.png) is available even before installation.
Expert and learner curves nearly overlap; the learner uses a dashed line.

## Files and data flow

- [robot.xml](robot.xml): primitive geometry, mass, slide joints, motors, timestep.
- [task.py](task.py): observations, scenario generation, physics stepping, rollouts.
- [expert.py](expert.py): feedback demonstrator used for collection/comparison.
- [learning.py](learning.py): dataset checks, regression, policy save/load/inference.
- [demo.py](demo.py): commands, viewer controls, metrics, plotting.
- [test_demo.py](test_demo.py): dynamics, data alignment/split, independent learner
  execution, held-out success, malformed inputs, and playback-state controls.

Expert → observation/action dataset → least-squares fit → learned policy.
During execution: observation → policy → forces → MuJoCo physics → new observation.
This establishes the basic workflow for HW4; it is not the homework environment.

## Troubleshooting and validation limitation

- Missing policy: run `collect` then `train`, or `all`, using the same output directory.
- Import errors: activate the virtual environment and install requirements.
- A paused restart stays paused: press Space to resume.
- Zero-action motion is expected when initial velocity is nonzero.
- Do not infer general robustness from this intentionally easy linear task.

**GUI validation limitation:** the development desktop failed native viewer startup
with Wayland/libdecor errors, and an X11 retry failed with `GLXBadDrawable`. Headless
MuJoCo execution, training, evaluation, plot export, and viewer-independent control
logic passed; actual keyboard/camera operation and clean interactive shutdown still
need rehearsal on a desktop with working OpenGL. Do not rely on the GUI without
that rehearsal. Use the saved comparison figure and console trace as fallback.

The installed GLFW package supports selecting an X11 backend with
`PYGLFW_LIBRARY_VARIANT=x11` on an X11-capable desktop, but this did not fix the
current development environment. `--seconds 10` limits viewer duration for a smoke
test when the graphics context is healthy.

Reference: [official MuJoCo Python documentation](https://mujoco.readthedocs.io/en/latest/python.html).
See the [teaching notes](../TEACHING_NOTES.md) for professor-slide references and the
45-minute session plan.
