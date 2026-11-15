# Week 5 — Classical Planning, PDDL, and TAMP

Current guide for the revised deck: **23 presented slides, no hidden slides**. The original teaching notes are retained as historical
material. This guide and the speaker notes use the agreed 45-minute schedule.

## Learning goals

Students should be able to explain why factored models help specify planning
problems, read the domain/problem split and a small PDDL action, trace its effects,
and explain how geometric feedback can change task decisions. They should also
distinguish task-first refinement, interleaved search, and joint planning.

Assume PDDL is new. Build on Week 4's motion planning. Do not teach pattern
databases, heuristic abstraction, additivity, cost partitioning, advanced PDDL
syntax, or solver-specific TAMP algorithms.

## Timeline

| Time | Slides | Teaching focus |
| --- | --- | --- |
| 0–15 min | 1–11 | Motivation, classical planning, factored states/actions, actual PDDL, symbolic search |
| 15–30 min | 12–21 | Hidden geometry, blocked mug, TAMP feedback loop and architectures, delivery refinement |
| 30–40 min | 22 | Unchanged demo and actual PDDL files |
| 40–45 min | 23 | Questions, student explanation, recap |

The title is timed (30 seconds). Detailed per-slide timing and source references
are in [PRESENTATION_PLAN.md](PRESENTATION_PLAN.md) and the PowerPoint speaker notes.

## Part 1: motivate the model before its syntax

Ask how a robot model could specify every combination of locations, possession,
and other conditions. Forty Boolean facts describe up to `2^40` combinations;
constraints can make some invalid, so this is an upper bound rather than a count
of reachable states in our delivery example.

Search can already generate a graph on demand. It still needs state
representation, a goal test, and successor generation. Facts plus reusable action
schemas specify these compactly. Preconditions test relevant facts; local effects
describe changes, and other facts persist. Compact input can still induce an
enormous search space.

PDDL gives this factored model a standard syntax. The domain supplies types,
predicates, and schemas; the problem supplies objects, initial facts, and goal.
Pyperplan searches the model. Show the real delivery vocabulary throughout.

Read the complete `pick` action. Ground it as `(pick parcel pickup)`, then trace
its effects **after the empty trip to pickup**. The initial robot is at delivery,
so that grounded action is not initially applicable. Explain the frame assumption
using the unchanged robot location. Follow with `move-loaded` and the actual
four-action BFS candidate. BFS minimizes action count, not metres or time.

## Part 2: center the feedback logic and architectures

The first two visuals establish why discrete and geometric choices interact:
symbolic actions hide configurations, grasps, IK, and paths; a box obstructing a
mug may force additional task actions. The mug figure is a lecture illustration,
not an implemented capability of the delivery demo.

Spend three minutes on the feedback loop and its example table together (our
slides **14 and 15**, 1.5 minutes each), and three minutes on the architectures
(our slide **16**). These adapt Ronen's numbered slides **8 and 9** (supplied PDF
pages **12 and 13**):

- **Feedback loop:** propose a task skeleton, refine its geometry, accept a
  validated plan or use feedback. Responses include retrying geometry, rebinding
  earlier parameters, and revising the task sequence. Unchanged symbolic search
  can repeat the same failure without new constraints or information.
- **Architectures:** task-first builds a whole task candidate before refinement;
  interleaved search checks selected geometry as it extends a prefix; joint
  planning couples discrete choices and continuous parameters in one model.
  These are alternatives, not stages of one solver.

Our demo uses **task-first refinement with feedback**. Its `can-empty` and
`can-loaded` predicates are ordinary optimistic symbolic facts. Geometry runs
externally, rather than as procedural attachments inside its PDDL.

Distinguish feasible witnesses, proved infeasibility, and undetermined geometric
queries. A timeout or failed general path search does not prove impossibility.
The demo's exact check can reject a designated straight swept disk; that still
does not reject every possible continuous path between those endpoints.

## Ten-minute demo

Follow the setup and controls in the unchanged [demo runbook](demo/README.md).
Open the actual `domain.pddl` and `problem.pddl` beside the visualization.

| Minutes | Action and question |
| --- | --- |
| 0–2 | Locate the problem goal and read the `pick` conditions. Which file describes reusable rules? |
| 2–4 | Reveal the four-action candidate. Which action will fail, and why? |
| 4–6 | Reveal the hypothetical rejection. Which precise permission is removed? |
| 6–8 | Match the six-action revision to the upper route. Why does the empty shortcut survive? |
| 8–10 | Play execution, pause after pickup, inspect possession and radius, then finish. |

Expected candidate: empty delivery→pickup; pick parcel; loaded pickup→delivery;
place parcel. Action 3 fails. The gap is **0.40 m**, centerline clearance **0.20 m**,
empty radius **0.12 m**, loaded radius **0.25 m**. Contact counts as collision.
Remove only `(can-loaded pickup delivery)` from a temporary problem copy. Preserve
the empty permission and the unqueried reverse loaded fact. Replan from the
original robot/package/hand state. The revised loaded route visits `upper-left`
and `upper-right` before returning to delivery.

All computation happens at startup; stage buttons reveal it. Candidate checks do
not move the execution state. The rejection display is a hypothetical preview.
Only a validated plan animates, and parsed effects update facts when an action
finishes. `Reset` restores the initial state/display. Playback is kinematic;
there is no manipulation physics, PRM call, hardware execution, or ROS setup.

Fallback figures already in the demo are `rejected.png`, `overview.png`, and
`delivered.png`. Do not overwrite them when preparing slides.

## Recap prompts and answers

- Why factor a model? Reusable facts/rules describe many states and transitions
  compactly, while local effects preserve everything else.
- What does PDDL provide? A standard description that a planner can interpret.
- Does grounding imply applicability? No: preconditions must hold now.
- Does symbolic validity guarantee geometry? No: abstract rules can omit it.
- What can change after refinement failure? Geometry, earlier parameters, or the
  task skeleton.
- Which architecture does this demo illustrate? Task-first refinement with
  geometric feedback.
- Has rejection already executed the empty trip and pick? No: it is hypothetical.

## Preparation and verification

Rehearse the five stages, file navigation, pause after pickup, and the 45-minute
flow. Existing ten Python tests and the headless trace pass in this update;
details are in [slides/python_validation.json](slides/python_validation.json).
The interface test uses the noninteractive Agg backend; it is not a live
classroom GUI rehearsal. Slide build/review evidence and protected-file hashes
are documented in [slides/README.md](slides/README.md).
