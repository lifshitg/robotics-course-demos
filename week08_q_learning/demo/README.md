# Week 8 — Interactive Q-learning

Learn a Q-table by interacting with a deterministic maze. NumPy and Matplotlib
are the only dependencies; no simulator, neural network, or external RL package.

## Setup and launch

From the repository root:

```bash
python3 -m venv /tmp/robotics-week08-venv
source /tmp/robotics-week08-venv/bin/activate
python -m pip install -r week08_q_learning/demo/requirements.txt
python week08_q_learning/demo/demo.py
```

Use Python 3.10+ and a working Matplotlib GUI backend (Tk or Qt). Tested libraries:
NumPy 1.26.4 and Matplotlib 3.6.3. Temporary environments can be recreated after reboot.

## Controls

- **Step:** one training transition and Q update. It exits evaluation without clearing training.
- **Train 100 episodes:** finish 100 more episodes, including the current partial
  episode. The window refreshes after each episode. Step/Evaluate wait until the batch ends;
  Reset can interrupt it. Ten batches reach 1,000 completed episodes.
- **Evaluate:** animate a greedy rollout from the start. Q, training position,
  episode history, and training RNG are preserved. Step/Train return to training.
- **Reset:** restore seed, zero Q-table, initial state, and empty history.
- Click a free cell to inspect its four Q-values. Close the window to stop.

The blue marker is the current agent, green arrows use fixed up/right/down/left
tie order, and gold outlines the inspected cell. Training greedy ties are randomized.
An exploration flag means the random branch was selected, even if it chose a greedy action.
After an episode ends, training resets immediately; the last-transition panel retains
its terminal/truncated transition. Evaluation draws a purple route.

## Task and defaults

5×5 grid, `(row,column)` with row 0 at the top. Start `(4,0)`, goal `(0,4)`;
walls `(1,1)`, `(1,2)`, `(2,2)`, `(3,1)`, `(3,3)`. Moves are up/right/down/left.
Blocked moves stay put. Each ordinary transition gives −1; goal arrival gives +10
instead and terminates. A 100-step cap truncates collection and retains bootstrapping.

Zero Q-table; alpha=.2; gamma=.95; seed 7; epsilon=`max(.05,1−episode/800)` with
episode 0 first. Training uses sampled transitions, not a route planner.

After 1,000 episodes, expected greedy evaluation:

```text
success: true
length: 8
raw_return: 3.0
discounted_return: 0.9501188828124985
path: (4,0) → (3,0) → (2,0) → (1,0) → (0,0) → (0,1) → (0,2) → (0,3) → (0,4)
```

Seven −1 rewards precede +10. Discounting produces a different sum than raw rewards.
Other seeds can select an equally short route. This deterministic same-start evaluation
is repeated behavior, not independent statistical evidence of robustness.

## Headless and exports

```bash
python week08_q_learning/demo/demo.py --headless
python week08_q_learning/demo/demo.py --headless --seed 3 --episodes 1000 --output /tmp/week08-run
python week08_q_learning/demo/demo.py --export /tmp/week08-figures
python -m unittest discover -s week08_q_learning/demo -p 'test_*.py' -v
```

GUI starts untrained. `--episodes` controls headless/export training only.
Headless commands save `q_table.npy` and `metrics.json` (settings, training history,
and evaluation path/returns). Default output is `demo/output/`, ignored by Git.
`--export` also saves `before.png` and `after.png`, without requiring a display.
Existing artifacts in the chosen output directory are replaced on a rerun.

Classroom fallbacks: [before](before.png), [after](after.png).

## Read the implementation

- [gridworld.py](gridworld.py): environment dynamics and transition rewards.
- [learning.py](learning.py): epsilon-greedy sampling, one-entry Q update, training,
  and evaluation with no training side effects.
- [demo.py](demo.py): controls, animation, inspection, and exports.
- [test_demo.py](test_demo.py): worked equations, termination/truncation, reproducibility,
  independent shortest-path comparison, evaluation isolation, and controls.

If evaluation appears stuck early, it may be repeatedly choosing a blocked action;
that is an incomplete policy, not animation failure. Resume training. If the window
cannot open, use headless output and saved figures. Policy arrows at unvisited states
may remain arbitrary: do not interpret them as a proven globally optimal policy.

See the [teaching notes](../TEACHING_NOTES.md) for the worked updates and lesson timing.
