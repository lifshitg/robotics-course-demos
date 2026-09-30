# Week 5 — Classical Planning and Task-and-Motion Planning

## Goal

- Describe a symbolic state, goal, and action with preconditions and effects.
- Read the domain/problem split in a small typed STRIPS PDDL example.
- Explain why a symbolic plan may fail a geometric check.
- Trace a concrete propose → validate → refine → replan loop and distinguish planning from execution.

## Context / Recap

- Week 4 planned a path between configurations. Now ask which actions the robot should perform, and in what order.
- Follow [TA_plan.md](../TA_plan.md), Session 5. No Week 5 professor presentation has been supplied; this is a TA-created example.
- Delivery task: robot starts at delivery, package starts at pickup. Goal: package at delivery. The robot fits through a narrow passage when empty but not when carrying the package.
- Explain the two levels: symbolic facts describe possession and named locations; geometry gives those locations coordinates and determines whether motion fits.

## Core Explanation

### Classical planning and PDDL

- A state is a set of true facts. Under this classical closed-world model, facts absent from the state are false.
- An action has parameters, preconditions, add effects, and delete effects. Applicable actions generate successor states; a goal is a condition that a final state must satisfy.
- Classical assumptions here: deterministic actions, fully known symbolic state, and discrete action transitions. We model no uncertain sensing or outcomes.
- `domain.pddl` defines types, predicates, and reusable action schemas. `problem.pddl` defines objects, initial facts, and the goal.
- Read `pick`: robot and package must share a location and the hand must be empty. Its effects add holding and remove package-at and hand-empty.
- Read `move-loaded`: holding plus a permitted directed connection enables a location change. Package possession remains true without being restated in the effects.
- Pyperplan parses and grounds the real files, then uses BFS. Grounding substitutes objects for action parameters. BFS minimizes number of actions here; it does not minimize metres traveled or execution time.
- Python applies the parsed operators. It does not maintain a second hand-written symbolic transition system.

### Why the first plan fails

First candidate:

```text
move-empty delivery pickup
pick parcel pickup
move-loaded parcel pickup delivery
place parcel delivery
```

- All candidate connections are initially permitted for both load states. These permissions are optimistic model assumptions, not geometric certificates.
- The central gap is 0.4 m wide. Empty diameter is 0.24 m, loaded diameter is 0.50 m.
- The empty trip passes. The loaded return fails: distance from centerline to either wall is 0.20 m, less than the loaded radius 0.25 m.
- The package is represented by an enlarged disk while held. Grasping and placing are abstract state changes, with footprint checks at the handling location.

### Refinement and TAMP

1. Generate a symbolic plan.
2. Replay it in a temporary hypothetical state; check each designated straight motion and footprint change.
3. Reject `(can-loaded pickup delivery)` after the failed check. Keep the empty permission and the reverse-direction permission unchanged.
4. Replan from the original initial state under the refined permissions.
5. Validate the new candidate fully, then execute its animation.

The six-action revised plan uses the empty shortcut, picks the package, visits upper-left and upper-right, returns to delivery, and places the package.

- Rejection applies to one designated connection and load state in this fixed scene. It does not establish that no continuous route exists between those endpoint locations.
- This is a small TAMP demonstration over a finite set of candidate motions. More general TAMP also searches grasps, placements, configurations, and continuous paths.
- A failed symbolic search means no plan under the remaining discrete model. A geometric rejection means a candidate action failed the geometry model. Keep these messages distinct.
- There are 16 initial directed/load-specific permissions. Every retry removes a new one, giving a finite bound of 17 candidate searches.

### Geometry and execution

- Workspace is 6 × 6 m. The upper route passes above the wall at y=5.4 m.
- Check swept disks using the minimum distance between a straight segment and each rectangular obstacle. Unlike Week 4's sampled arm checking, this simple geometry supports a whole-segment distance test.
- Contact is collision. Check workspace boundaries too; the disk must remain strictly inside them.
- Candidate validation never changes execution state. The rejection stage shows a clearly labeled hypothetical state after pickup.
- Only a fully validated plan is animated. PDDL facts update at action completion; during a move, the continuous pose changes while the symbolic location still names the departure waypoint.
- Playback uses illustrative timing, with no robot dynamics, manipulation physics, or physical safety guarantee.

## Live Demo

Follow [the runbook](demo/README.md); install dependencies and rehearse before class.

- **3 minutes:** Read one action schema and the initial/goal states. Predict the shortest action sequence.
- **4 minutes:** Reveal the four-action candidate, then its failed loaded return. Compare robot diameter with the gap width.
- **4 minutes:** Show the precise rejected permission and the six-action revision. Emphasize that the empty shortcut remains usable.
- **4 minutes:** Animate only the validated plan. Pause after pickup to inspect holding, robot radius, and the attached package.

Closing checkpoint answers:

- **Domain versus problem?** Reusable action model versus one set of objects, initial facts, and goals.
- **Does a symbolically applicable action necessarily fit geometrically?** No; the symbolic model may omit constraints.
- **Why does the empty shortcut remain?** Its smaller footprint fits; the rejection was load-specific.
- **Has the robot moved during candidate checking?** No; that is a hypothetical replay.
- **Does a six-action plan minimize distance?** Not necessarily; BFS optimizes action count.

## Timing

| Part | Minutes |
| --- | ---: |
| Recap: motion planning versus choosing actions | 5 |
| States, goals, actions, and PDDL | 12 |
| Connecting symbolic plans to geometry | 8 |
| Generate, reject, replan, and animate | 15 |
| Checkpoint and recap | 5 |
| **Total** | **45** |

## Common Questions / Problems

- **Why two move actions?** Empty and loaded motions have different preconditions and geometric permissions; their radii differ.
- **Does PDDL contain the wall coordinates?** No. The named waypoints/permissions are symbolic; `scene.json` supplies geometry.
- **Is Pyperplan checking collisions?** No. It searches symbolic states; our geometric layer checks the candidate motions.
- **Can we delete every failed move permanently?** Only within the stated scene, load state, and designated connection. A different route, footprint, or environment requires reconsideration.
- **Why is the robot-at fact unchanged mid-motion?** The symbolic model treats a move as a discrete transition; the visualization interpolates its physical pose.
- **Missing Pyperplan:** activate the demo virtual environment and install its requirements. No ROS setup is needed.
- **Play does nothing:** reach the execution stage first; no unvalidated plan can be played.

## Homework Connection

- Link to HW2's geometric search: a route planner can provide the low-level feasibility check inside a larger task planner.
- Reuse Weeks 3–4's distinction between goal feasibility and valid motion. The delivery example changes task order/route because of geometry.
- This lesson supports the course's symbolic-planning/TAMP topic; `TA_plan.md` assigns no separate Week 5 homework deliverable.
- Week 6 will relax deterministic classical-planning assumptions with MDPs.

## Preparation Checklist

- [ ] Create the isolated environment and install the pinned Pyperplan dependency.
- [ ] Read `pick` and both move schemas; manually trace the first candidate's facts.
- [ ] Run the tests and headless trace; confirm four actions become six.
- [ ] Verify only the directed loaded shortcut permission is rejected.
- [ ] Rehearse all five stages, pause/resume, radius changes, package motion, and reset.
- [ ] Keep the rejection, revised-plan, and delivered figures ready as fallbacks.
- [ ] Rehearse the 45-minute flow and checkpoint answers.

Preparation references: [Pyperplan](https://github.com/aibasel/pyperplan) for supported STRIPS planning and BFS; [Planning Algorithms, Chapter 2](https://lavalle.pl/planning/ch2.pdf) for discrete planning; [Integrated Task and Motion Planning](https://arxiv.org/abs/2010.01083) for broader TAMP context. These support background reading; the demo implements only the finite-connection example above.
