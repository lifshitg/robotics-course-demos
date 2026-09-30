# Week 6 — MDP visualization

A five-minute companion to the presentation. One known four-state model drives
all calculations, policy arrows, and saved figures. No ROS or Gazebo is needed.

## Setup and run

From the repository root, with Python 3.10 or newer:

```bash
python3 -m venv /tmp/robotics-week06-venv
source /tmp/robotics-week06-venv/bin/activate
python -m pip install -r week06_mdps/demo/requirements.txt
python week06_mdps/demo/demo.py
```

An interactive Matplotlib backend such as Tk or Qt is needed for the window.
Headless operation needs no desktop. The temporary environment may need recreating
after reboot. The demo was validated with NumPy 1.26.4 and Matplotlib 3.6.3.

## Controls and five-minute script

1. **Next backup:** perform one synchronous sweep; predict V1 before clicking.
2. Click again: V2(start)=6.2, V2(detour)=8. Terminals remain zero.
3. **Solve:** finish convergence and reveal the policy-iteration trace.
4. Predict, then select **0.1** failure probability. Selection resets to V0;
   solve again and observe the risky policy win.
5. **Reset:** restore V0 under the currently selected probability. Close to exit.

Green arrows are greedy with respect to the **displayed** values. The action-value
panel computes the **next** backup. Thus the arrows already favor safe at V1 even
though V1(start)=6. Both risky branches remain possible when risky is selected.

## Model and expected results

Gamma=0.9. Safe goes from start to detour with reward −1; finish goes from detour
to delivered with reward +8. Risky goes directly to delivered (+10) with probability
1−p or failed (−10) with probability p. Terminal states absorb with zero subsequent
reward/value. The smaller reliable delivery reward is an explicit model choice.

| Quantity | p=0.2 | p=0.1 |
|---|---:|---:|
| Risky expected return | 6 | 8 |
| Detour value | 8 | 8 |
| Safe return | 6.2 | 6.2 |
| Optimal start action | safe | risky |

Baseline trace:

```text
V0: start=0.00, detour=0.00, terminals=0
V1: start=6.00, detour=8.00, terminals=0
V2: start=6.20, detour=8.00, terminals=0
V3: start=6.20, detour=8.00, terminals=0
PI: risky, value 6.00 -> safe
PI: safe, value 6.20 -> safe
```

The extra unchanged sweep checks convergence. A policy maximizing expected return
is not a worst-case safety guarantee. No rollout or learning is needed: the model
is given, and all successor outcomes are summed exactly.

## Code-to-equation map

- [model.py](model.py): transition table, model validation, `action_values()` for
  `sum P[r + gamma V]`, and `backup()` for synchronous maximization.
- `evaluate_policy()` solves `(I − gamma P_pi)V = R_pi` over nonterminal states.
- `value_iteration()` returns values, greedy policy, and all value vectors;
  `policy_iteration()` returns values, policy, and evaluation/improvement trace.
- Both solvers cap iterations at 1,000 and require change/residual below `1e-10`;
  PI also requires an unchanged policy. Exceeding the cap raises an explicit error.
- Ties retain the current policy action during improvement; otherwise model action
  order chooses deterministically (safe before risky), with `1e-12` tie tolerance.
- [demo.py](demo.py) provides controls, graph, headless trace, and export.

This intentionally tiny acyclic example converges quickly. General discounted
MDPs with cycles may require many sweeps. Gamma=1 is excluded from this solver.

## Headless output and fallback figures

```bash
python week06_mdps/demo/demo.py --headless
python week06_mdps/demo/demo.py --headless --failure 0.1
python week06_mdps/demo/demo.py --export /tmp/week06-baseline.png
python week06_mdps/demo/demo.py --failure 0.1 --export /tmp/week06-lower-risk.png
python -m unittest discover -s week06_mdps/demo -p 'test_*.py' -v
```

Exports show converged values and use a noninteractive backend. Saved classroom
fallbacks: [baseline](baseline.png), [lower risk](lower_risk.png).

If imports fail, activate the environment and install requirements. If the window
cannot open, use headless output or exports. Reset keeps the selected scenario;
select 0.2 to return to the baseline. The numeric displays are rounded to two
decimal places; solver calculations retain full precision.

Source: professor's `Class7-MDPs.pdf`; see the [teaching notes](../TEACHING_NOTES.md)
for printed-slide references, worked answers, and the 45-minute lesson structure.
