# Week 5 — Task and motion planning demo

A delivery robot can use the central passage empty, but its larger loaded footprint
cannot fit. Pyperplan reads the actual PDDL files, proposes a plan, and replans after
our geometry checker rejects the loaded shortcut. No ROS or Gazebo is needed.

## Setup

From the repository root, use an isolated environment:

```bash
python3 -m venv /tmp/robotics-week05-venv
source /tmp/robotics-week05-venv/bin/activate
python -m pip install -r week05_task_motion_planning/demo/requirements.txt
python week05_task_motion_planning/demo/demo.py
```

Python's `venv` module and a Matplotlib GUI backend (for example Tk or Qt) are
needed for the interactive window. The temporary environment can be recreated
with these commands after a reboot. Pyperplan is pinned to **2.1**; implementation
was tested with NumPy 1.26.4 and Matplotlib 3.6.3.

## Controls and classroom sequence

**Next stage** reveals five stages:

1. Initial problem: robot at delivery, package at pickup, hand empty.
2. Candidate symbolic plan: inspect the four actions before executing anything.
3. Geometric rejection: preview the hypothetical loaded state and failed edge.
4. Revised plan: all motions and footprint changes have passed validation.
5. Execution: press **Play / Pause** to animate the validated plan.

The rejection preview does not change execution state. The facts panel explicitly
labels hypothetical facts. During execution, facts update when an action finishes;
the orange package follows the robot while held, and the disk changes size after
pick/place. Playback uses 1 m/s motion and 0.6-second handling pauses for display,
not a dynamics model. **Reset** returns to the initial problem. Close the window
to stop. Play after completion replays the validated plan.

Ask students to predict the rejected action before revealing stage 3. Check that
they preserve the empty shortcut when revising the loaded permissions.

## Expected result

The first BFS plan has four actions:

```text
(move-empty delivery pickup)
(pick parcel pickup)
(move-loaded parcel pickup delivery)
(place parcel delivery)
```

The third action fails: clearance from its centerline to the wall is **0.20 m**,
less than the **0.25 m** loaded radius. The **0.12 m** empty disk fits.
Only `(can-loaded pickup delivery)` is removed. The new six-action plan is:

```text
(move-empty delivery pickup)
(pick parcel pickup)
(move-loaded parcel pickup upper-left)
(move-loaded parcel upper-left upper-right)
(move-loaded parcel upper-right delivery)
(place parcel delivery)
```

The final state contains `(package-at parcel delivery)`, `(robot-at delivery)`,
and `(hand-empty)`. BFS minimizes action count with these unit-cost actions;
it does not minimize travel distance.

## PDDL → search → geometry → execution

| File | Role |
| --- | --- |
| [domain.pddl](domain.pddl) | Typed STRIPS predicates and four action schemas, including their preconditions and effects. |
| [problem.pddl](problem.pddl) | Objects, initial facts, directed empty/loaded connection permissions, and delivery goal. |
| [scene.json](scene.json) | Workspace, waypoints, rectangles, robot radii, and candidate connections. |
| [planning.py](planning.py) | Pyperplan parsing, grounding and BFS; hypothetical validation; permission refinement and replanning. |
| [geometry.py](geometry.py) | Swept-disk collision checks and scene validation. |
| [demo.py](demo.py) | Staged visualization and playback using the parsed action effects. |
| [test_demo.py](test_demo.py) | Geometry, symbolic behavior, refinement, and interface regression tests. |

`load_task()` parses and grounds the authored PDDL. There is no parallel Python
implementation of action preconditions or effects: validation and playback use
Pyperplan operators' `applicable()` and `apply()` methods. Python maps motion
operators and possession facts to geometric checks.

Each attempt starts from the original initial state. Validation uses immutable
state copies. A rejected directed permission is removed from a revised PDDL
problem in temporary storage; the authored problem remains unchanged. The next
search parses that revised problem. With 16 initial permissions, at most 17 search
attempts are possible. Symbolic search exhaustion is reported separately from a
geometric failure. A handling/footprint failure cannot be repaired by deleting a
motion permission and is reported as geometric failure.

## What the geometry checker establishes

The workspace is 6 × 6 m, with pickup `(1,3)`, delivery `(5,3)`, and upper waypoints
`(2,5.4)` and `(4,5.4)`. Walls occupy `[2.8,3.2] × [0,2.8]` and
`[2.8,3.2] × [3.2,4.8]`. Each designated connection is a straight centerline.

For each motion, the checker computes segment-to-rectangle distance and compares
it with the disk radius. Intersection or contact is collision, including a tiny
numerical tolerance. The disk must also remain strictly inside the workspace;
checking the endpoints suffices for a straight segment inside this convex box.
Pick/place checks the larger of the before/after footprints at that location.
This checks the entire swept disk against these static rectangles, rather than
sampling points along the motion as in Week 4.

Rejecting one designated connection does **not** prove that no continuous path
exists between its endpoints. This is a small TAMP demonstration over finitely
many candidate motions. Package handling changes possession and disk radius;
it includes no grasp mechanics, arm motion, or manipulation physics.

## Headless trace and classroom fallback

```bash
python week05_task_motion_planning/demo/demo.py --headless
python week05_task_motion_planning/demo/demo.py --export /tmp/week05-plan.png
python week05_task_motion_planning/demo/demo.py --export /tmp/week05-rejected.png --export-stage rejected
python week05_task_motion_planning/demo/demo.py --export /tmp/week05-delivered.png --export-stage goal
```

All runs print the candidate sequences, rejected action and permission, and final
planning status. Headless/export modes require no display server. Exit status is
0 for a validated solution and 1 for planning failure.

Saved classroom figures: [rejection](rejected.png), [validated plan](overview.png),
and [delivered package](delivered.png). These let you explain the same sequence
if a graphical backend is unavailable.

## Tests and troubleshooting

```bash
python -m unittest discover -s week05_task_motion_planning/demo -p 'test_*.py' -v
```

The suite checks the parsed actions, the four-to-six-action refinement, geometric
contact and workspace boundaries, invalid inputs, bounded replanning and symbolic
failure, candidate-state isolation, dense route replay, and playback/reset.

- **Missing `pyperplan`:** activate the environment and install its requirements.
- **No interactive window:** select an installed interactive Matplotlib backend;
  use the headless commands and saved figures when no desktop is available.
- **Play does nothing:** advance to the execution stage first.
- **Package appears at pickup during rejection:** that is the hypothetical preview,
  not executed motion; the next execution still begins at delivery.
- **Changed scene fails:** `--scene path/to/scene.json` accepts an alternative scene
  with the same PDDL locations. Inspect the reported failed action and clearance.
  Adding geometry alone does not add symbolic connections to the PDDL problem.

Planning reference: [Pyperplan](https://github.com/aibasel/pyperplan).
See the [teaching notes](../TEACHING_NOTES.md) for the lesson timing and sources.
