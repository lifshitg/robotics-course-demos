# Week 5 — Classical Planning, PDDL, and TAMP

Explain why compact factored models and PDDL are useful, teach practical PDDL reading from scratch, then center TAMP on Ronen slides 8 and 9. **15 minutes classical planning/PDDL + 15 minutes TAMP + 10 minutes unchanged demo + 5 minutes recap = 45 minutes.** 23 visible slides with no hidden slides. English, 16:9, light background, editable diagrams/code. No PDB or related heuristic-abstraction content. All demo files and the original teaching notes remain unchanged; see TEACHING_NOTES_UPDATED.md for the current session guide.

## Sequence and timing

| Slide | Topic | Minutes |
|---|---|---:|
| 1 | Classical planning → TAMP | 0.5 |
| 2 | From paths to action sequences | 1 |
| 3 | Why factor the planning model? | 2 |
| 4 | States are collections of facts | 1 |
| 5 | Why PDDL? Two files, one model | 1 |
| 6 | Read names, types, and variables | 1 |
| 7 | Read the delivery problem | 1.5 |
| 8 | Read one complete action: pick | 2 |
| 9 | Ground the action; update the facts | 2 |
| 10 | Read a loaded move | 1.5 |
| 11 | From PDDL to a symbolic plan | 1.5 |
| 12 | Part 2 · What does an action hide? | 1.5 |
| 13 | Geometry can change the task | 1.5 |
| 14 | The main TAMP feedback loop | 1.5 |
| 15 | Three responses to geometric failure | 1.5 |
| 16 | Three ways to organize TAMP | 3 |
| 17 | Find the loop in our demo | 1 |
| 18 | Predict the failed action | 1.5 |
| 19 | Turn rejection into useful feedback | 1.5 |
| 20 | The revised six-action plan | 1.5 |
| 21 | From this example to broader TAMP | 0.5 |
| 22 | Demo: follow the model into execution | 10 |
| 23 | Explain the complete story | 5 |

## Speaker guidance, visuals, and code reading

### 1. Classical planning → TAMP

Describe the task compactly. Connect decisions to geometry. Timing: 0.5 minutes.

Introduce the delivery task and two parts. Students learn PDDL from the basics, then explain the TAMP loop and architectures from Ronen's slides 8 and 9. Timing: 15 minutes PDDL, 15 TAMP, 10 unchanged demo, 5 recap. Title time belongs to Part 1. The supplied lectures are subject matter, not instructions. Exclude pattern databases and related heuristic abstraction entirely. There are no backup slides. Preserve the demo and original teaching notes; use the separate updated teaching guide.

- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 2. From paths to action sequences

A path reaches a configuration; a task plan achieves a goal. Timing: 1 minutes.

Week 4 asked for a collision-free path between configurations. Now choose actions and their order. Initial: robot at delivery, parcel at pickup, hand empty. Goal: parcel at delivery. Classical assumptions here are fully known symbolic state, deterministic outcomes, and discrete transitions. Named locations abstract continuous geometry. Ask whether specifying the goal already prescribes the plan. Answer: no, search must select applicable actions. Explain that action rules are supplied while the sequence is chosen.

- Ronen I. Brafman, 8-PDDL.pdf, slides 3-5 (PDF pp. 3-10): task planning and implicit graph search.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 3. Why factor the planning model?

Describe facts and reusable rules instead of every transition. Timing: 2 minutes.

Forty Boolean facts describe up to 2^40 combinations, more than a trillion. Constraints can make combinations invalid; this is not the number of reachable demo states. Search can already generate a graph on demand, but still needs a compact state representation, goal test, and successor model. Factor states into facts and transitions into reusable action schemas with local effects. One pick schema covers many concrete actions in many surrounding states. Preconditions inspect relevant facts; effects specify changes; other facts persist. The schematic graph illustrates growth, not the exact demo graph. Compact description does not eliminate exponential search. Ask whether each combination of unrelated facts requires another pick rule: no.

- Ronen I. Brafman, 8-PDDL.pdf, slides 9-11 (PDF pp. 18-25) and slide 18 (PDF pp. 37-39): scaling, factored models, and PDDL.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 4. States are collections of facts

Predicates describe relationships; ground facts describe this state. Timing: 1 minutes.

Read the predicate declaration and the grounded fact robot-at delivery. Substituting objects into a predicate creates a ground atom. A state contains true ground atoms, not variable declarations. Match robot-at, package-at, and hand-empty to the scene. Closed-world assumption: absent atoms are false; holding parcel is initially false. These facts are statements, not commands or coordinates. Selected state facts are shown; permissions are also in the actual state. The robot is implicit, not a declared object.

- Ronen I. Brafman, 8-PDDL.pdf, slides 13-17 (PDF pp. 27-36): predicates, states, action schemas, grounding.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 5. Why PDDL? Two files, one model

A standard language for facts, rules, and planning instances. Timing: 1 minutes.

Expand Planning Domain Definition Language. PDDL gives a standard syntax for the factored model, letting a planner read vocabulary, action rules, objects, initial facts, and goals. domain.pddl is reusable; problem.pddl supplies one delivery instance and references the domain. Changing the initial parcel location changes the problem; changing pickup rules changes the domain. Pyperplan reads and searches; PDDL is not an algorithm or controller. Compact input still defines a potentially large search graph. Skip requirement flags and dialects.

- Ronen I. Brafman, 8-PDDL.pdf, slides 9-11 (PDF pp. 18-25) and slide 18 (PDF pp. 37-39): scaling, factored models, and PDDL.
- Ronen I. Brafman, 8-PDDL.pdf, slides 20-24 (PDF pp. 41-46): domain, problem, and generated search.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 6. Read names, types, and variables

Concrete objects fill typed placeholders in reusable rules. Timing: 1 minutes.

Read actual declarations. pickup, delivery, upper-left, upper-right are locations; parcel is a package. A hyphen attaches preceding names to a type, not subtraction. Variables begin with ?, for example ?p and ?l; their names are conventions. Types constrain compatible substitutions. Connect the predicate declaration to the concrete fact robot-at delivery. Keep this practical: students need enough syntax to read the example, not a grammar lesson.

- Ronen I. Brafman, 8-PDDL.pdf, slides 13-17 (PDF pp. 27-36): predicates, states, action schemas, grounding.
- Ronen I. Brafman, 8-PDDL.pdf, slides 20-24 (PDF pp. 41-46): domain, problem, and generated search.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 7. Read the delivery problem

Connect initial facts and the goal to the same scene. Timing: 1.5 minutes.

The opening :init excerpt is incomplete: directed can-empty/can-loaded facts follow in the actual file. Robot starts at delivery (5,3), parcel at pickup (1,3), hand empty. Goal is only package-at parcel delivery; robot position and hand status are additional final facts produced by place. Coordinates, walls, and radii live in scene.json, not PDDL. Permissions are optimistic symbolic assumptions, not geometric certificates. Ask students to match each fact to the large scene. Do not reveal the revised route yet.

- Ronen I. Brafman, 8-PDDL.pdf, slides 20-24 (PDF pp. 41-46): domain, problem, and generated search.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 8. Read one complete action: pick

Parameters → preconditions → effects. Timing: 2 minutes.

Read the entire actual pick schema. Parameters identify package and location. Preconditions require robot and package co-located and hand empty. Effects add holding and delete package-at and hand-empty. not inside an effect makes a fact false. Translate each field; conditions are tests, effects are updates. One schema replaces many transition descriptions, reinforcing factoring. Ask if pick parcel pickup is initially applicable. No: robot-at pickup is false. Symbolic conditions do not establish feasible grasp or motion; save geometry for Part 2.

- Ronen I. Brafman, 8-PDDL.pdf, slides 13-17 (PDF pp. 27-36): predicates, states, action schemas, grounding.
- Ronen I. Brafman, 8-PDDL.pdf, slides 33-36 (PDF pp. 61-66): STRIPS and the frame assumption.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 9. Ground the action; update the facts

Add what changes, delete what changes, preserve the rest. Timing: 2 minutes.

Substitute parcel and pickup consistently throughout the pick schema. Grounding creates an instance; applicability tests current facts. BEFORE here means after the empty journey to pickup, not the original initial state. Delete package-at parcel pickup and hand-empty; add holding parcel. robot-at pickup and permissions persist by the frame assumption. The parcel has no package-at fact while held; possession represents it until place. Ask which shown fact persists and why. Answer: robot-at pickup, because no effect changes it. This is the advantage of local transition rules.

- Ronen I. Brafman, 8-PDDL.pdf, slides 13-17 (PDF pp. 27-36): predicates, states, action schemas, grounding.
- Ronen I. Brafman, 8-PDDL.pdf, slides 33-36 (PDF pp. 61-66): STRIPS and the frame assumption.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 10. Read a loaded move

The location changes; possession persists. Timing: 1.5 minutes.

Read actual move-loaded precondition/effect excerpts. Require robot at source, holding package, and a directed loaded permission. Delete the source robot-at and add destination robot-at. Holding persists without being restated. move-empty instead needs hand-empty and can-empty. A permission fact allows a symbolic edge; it is not a path or clearance certificate. The parcel has no package-at fact during a loaded move. Ask whether holding must reappear in the effects: no, unchanged facts persist.

- Ronen I. Brafman, 8-PDDL.pdf, slides 20-24 (PDF pp. 41-46): domain, problem, and generated search.
- Ronen I. Brafman, 8-PDDL.pdf, slides 33-36 (PDF pp. 61-66): STRIPS and the frame assumption.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 11. From PDDL to a symbolic plan

The compact model generates a search graph on demand. Timing: 1.5 minutes.

Show domain+problem → grounding → BFS and the exact four-action candidate. Nodes are fact sets; applicable grounded actions generate edges; effects produce successors. Pyperplan parses the real files and uses BFS; operators are sorted for reproducible ties. With unit action costs BFS minimizes action count, not metres or execution time. Compact representation does not make the search space small. This candidate has not been geometrically checked or executed. End Part 1 at minute 15: does symbolic validity guarantee the robot fits? No.

- Ronen I. Brafman, 8-PDDL.pdf, slides 3-5 (PDF pp. 3-10): task planning and implicit graph search.
- Ronen I. Brafman, 8-PDDL.pdf, slides 20-24 (PDF pp. 41-46): domain, problem, and generated search.
- https://github.com/aibasel/pyperplan
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 12. Part 2 · What does an action hide?

TAMP connects a task skeleton to geometric choices. Timing: 1.5 minutes.

Expand Task and Motion Planning. Adapt Ronen's two-level diagram: pick/move/place hides grasps, base configurations, inverse kinematics, approach paths, placement poses, and retreat motions. Early choices may constrain later actions, requiring coordination across levels. The delivery demo reduces handling to possession and a changed disk radius. It does not solve grasps or IK and does not invoke PRM. Week 4's motion planner could support queries in a larger TAMP pipeline. Define IK verbally as finding a robot configuration for a desired pose.

- Ronen I. Brafman, 8-PDDL.pdf, slide 6 (PDF pp. 11-12), slide 38 (PDF pp. 68-71): task skeleton and geometric realization.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 13. Geometry can change the task

Sometimes the plan needs an additional action. Timing: 1.5 minutes.

Use the illustration from Ronen's numbered slide 4, PDF page 5. A box blocks access to the mug. The illustrated revision is pick box, place box aside, then pick mug. Geometry changes the symbolic sequence, not just the curve for an existing move. This lecture example is not an added demo feature. Ask what prevents repeated blocked picks. Answer: geometric feedback/constraints plus a domain permitting obstacle rearrangement. The drawing illustrates access; it is not a proof from the delivery checker. Credit the source visibly.

- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 4 (PDF p. 5), slide 5 (PDF pp. 6-8): blocked mug and task revision. Illustration reproduced from slide 4.

### 14. The main TAMP feedback loop

Adapted from Ronen, slide 8 · three responses to refinement failure. Timing: 1.5 minutes.

Central slide, adapted from Ronen's numbered slide 8, PDF p. 12. Follow task search → candidate → geometric refinement → validated task-and-motion plan. Refinement searches/checks grasps, IK, paths, collisions, and compatibility. Distinguish: (1) retry another grasp/path for the same action; (2) rebind an earlier base pose, grasp, or placement with the same task skeleton; (3) insert/reorder actions or select another skeleton. Small refinement loop represents retries/parameter revision; large feedback loop constrains task search. Without changed information, symbolic replanning can repeat failure. A witness establishes feasibility; timeout/failed geometric search is undetermined, not proved impossible. Ask which arrow represents moving the blocking box: feedback to task search.

- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 8 (PDF p. 12): From Geometric Failure to Plan Revision. Diagram adapted as editable shapes.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slides 6-7 (PDF pp. 9-11): geometric procedures and undetermined queries.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 4 (PDF p. 5), slide 5 (PDF pp. 6-8): blocked mug and task revision. Illustration reproduced from slide 4.

### 15. Three responses to geometric failure

Retry locally, revisit an earlier choice, or revise the task. Timing: 1.5 minutes.

Use the response/meaning/example table to make the previous slide concrete. A task skeleton means the symbolic action sequence, such as pick mug → move → place mug. (1) Retry geometry: change how the current action is realized, for example another collision-free approach path. (2) Rebind earlier parameters: a grasp allows pickup but causes a later placement failure; backtrack and choose a different grasp at pickup while keeping the symbolic action sequence. The distinction between 1 and 2 is local retry versus revisiting an earlier decision. (3) Revise the task: insert pick box → place box aside before picking the mug. Options 1 and 2 can preserve the skeleton; option 3 changes it. These illustrative manipulation examples are not added features of the delivery demo. Ask students which response applies when pickup succeeds but placement later fails because of the chosen grasp: 2. The loop and this table share the previous three-minute explanation slot (1.5 minutes each), so the session remains 45 minutes.

| Response | Meaning | Example |
|---|---|---|
| 1. Retry geometry | Try another realization of the current action. | The approach collides. Try another approach path. |
| 2. Rebind earlier parameters | Revisit an earlier choice causing a later failure. Keep the sequence. | Pickup works, but the grasp prevents placing on the shelf. Choose another grasp at pickup. |
| 3. Revise the task | Change the symbolic actions or their order. | A box blocks the mug. Insert: pick box → place box aside before picking the mug. |

- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 8 (PDF p. 12): From Geometric Failure to Plan Revision. Diagram adapted as editable shapes.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 4 (PDF p. 5), slide 5 (PDF pp. 6-8): blocked mug and task revision. Illustration reproduced from slide 4.

### 16. Three ways to organize TAMP

Adapted from Ronen, slide 9 · when does geometry enter the search? Timing: 3 minutes.

Compare three alternative architectures, not sequential stages. Task-first: propose a full symbolic sequence, refine geometric choices, and backtrack or feed constraints to task search. Interleaved: grow a task prefix and test selected geometric choices during expansion, rejecting conflicts before completing the sequence. Joint/constraint-based: discrete action choices and continuous parameters share a coupled model; propagation/optimization/search enforce compatibility. Use matching visual task vocabulary across panels. Ask which checks geometry while growing a prefix: interleaved. The delivery demo is task-first with refinement feedback, not interleaved or joint. Avoid solver-specific algorithms and notation. Draw from Ronen's numbered slide 9, PDF p. 13.

- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 9 (PDF p. 13): How Is TAMP Solved? Three General Architectures.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 8 (PDF p. 12): From Geometric Failure to Plan Revision. Diagram adapted as editable shapes.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 17. Find the loop in our demo

Real PDDL → search → external geometry → playback. Timing: 1 minutes.

Map PDDL files to Pyperplan parsing/grounding/BFS, geometry.py to swept-disk checks, planning.py to feedback/replanning, and demo.py to validated playback. The full candidate is checked after search: task-first refinement. Permissions are ordinary optimistic facts, not procedural attachments inside PDDL. External geometry interprets motions/possession. Parsed operators supply applicable/apply methods; Python does not duplicate symbolic rules. Computation occurs at startup; stage buttons reveal results. Rejected candidates have not been executed. All demo files stay unchanged.

- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 8 (PDF p. 12): From Geometric Failure to Plan Revision. Diagram adapted as editable shapes.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 9 (PDF p. 13): How Is TAMP Solved? Three General Architectures.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 18. Predict the failed action

The same passage can accept one footprint and reject another. Timing: 1.5 minutes.

Show the four actions and pause for predictions before naming action 3: move-loaded parcel pickup delivery. Passage width is 0.40 m (walls end at y=2.8 and resume at y=3.2). Centerline clearance is 0.20 m. Empty radius/diameter 0.12/0.24 m fits; loaded 0.25/0.50 m fails. Contact is collision. Hypothetical checking reaches the held-parcel state without execution. Possession changes footprint; no grasp mechanics are modeled. The shape comparison uses the actual dimensions. Explain that the failed loaded return differs from the empty outward trip.

- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 19. Turn rejection into useful feedback

Refine one load-specific, directed permission. Timing: 1.5 minutes.

Remove only can-loaded pickup delivery from a temporary problem copy. Keep the empty shortcut and the reverse loaded fact. Geometry is symmetric here, but implementation refines only queried directions; the reverse would be checked if used. Do not remove the whole action schema or all paths between those names. Authored PDDL remains unchanged. Each search restarts from original robot/package/hand facts under refined permissions, not from the hypothetical rejection pose. Ask why replanning differs: its permission model changed. Failure of this designated centerline does not rule out other continuous paths.

- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 8 (PDF p. 12): From Geometric Failure to Plan Revision. Diagram adapted as editable shapes.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 20. The revised six-action plan

Empty shortcut outward; loaded upper route back. Timing: 1.5 minutes.

Match exact actions to numbered motions: empty delivery→pickup, pick, loaded pickup→upper-left→upper-right→delivery, place. Upper waypoints (2,5.4)/(4,5.4) pass above wall top y=4.8. All designated motions and footprint changes validate before playback. Empty shortcut stays available. Geometric feedback changes four actions into six, illustrating a changed task sequence. BFS minimizes action count in the refined model, not distance. Goal becomes true only after place. Ask students to narrate the list and diagram together. Use overview.png if live display fails.

- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 21. From this example to broader TAMP

The coordination logic supports richer geometric choices. Timing: 0.5 minutes.

Our finite demo supplies named waypoints, straight motions, disks, and abstract handling. Broader TAMP searches grasps, placements, configurations, and paths, using retries, earlier-parameter revision, and changed task skeletons. A rejected designated edge does not rule out every continuous route. A query timeout is not proof of impossibility. Symbolic-failure means no plan under remaining model permissions. End Part 2 at minute 30 and switch to the unchanged demo.

- Ronen I. Brafman, 8-PDDL.pdf, slide 6 (PDF pp. 11-12), slide 38 (PDF pp. 68-71): task skeleton and geometric realization.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slides 6-7 (PDF pp. 9-11): geometric procedures and undetermined queries.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 9 (PDF p. 13): How Is TAMP Solved? Three General Architectures.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 22. Demo: follow the model into execution

Inspect the actual files, then reveal the five stages. Timing: 10 minutes.

0-2 min: open domain/problem; locate goal and pick conditions. 2-4: reveal candidate and predict failed action. 4-6: show hypothetical rejection and removed directed/load-specific permission. 6-8: inspect revised plan and route. 8-10: execute, pause after pickup to inspect holding/radius/parcel attachment, then finish. Computation happens at startup; Next stage reveals it. Candidate checks leave execution state unchanged. Only validated plans animate; parsed effects update facts at action completion. Mid-motion robot-at names the departure waypoint. Reset restores initial state/display; completed Play replays. Use existing rejected.png, overview.png, delivered.png as fallback. No ROS/Gazebo; kinematic playback is not dynamics.

- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

### 23. Explain the complete story

Compact model → plan → geometry → feedback → execution. Timing: 5 minutes.

Minute 40-45. Ask: why facts/schemas? Compact reusable rules with local effects; search can still be large. Domain versus problem? Vocabulary/rules versus one instance. Grounded implies applicable? No, current preconditions must hold. Why robot-at persists through pick? Effects leave it unchanged. Symbolic validity guarantees geometry? No. Three failure responses? Retry geometry, revise earlier parameters, revise skeleton. Demo architecture? Task-first with feedback. Has rejection preview executed anything? No. Have students narrate compact model→candidate→check→feedback→revision→execution, then explain why the empty shortcut survives. Use remaining time for questions, not new theory.

- Ronen I. Brafman, 8-PDDL.pdf, slides 9-11 (PDF pp. 18-25) and slide 18 (PDF pp. 37-39): scaling, factored models, and PDDL.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 8 (PDF p. 12): From Geometric Failure to Plan Revision. Diagram adapted as editable shapes.
- Ronen I. Brafman, 9-TAMP+PDB.pdf, slide 9 (PDF p. 13): How Is TAMP Solved? Three General Architectures.
- Local sources: demo/domain.pddl, demo/problem.pddl, demo/planning.py, demo/geometry.py, demo/scene.json, demo/test_demo.py and demo/README.md. Demo files remain unchanged.

## Source excerpts

### emptypermission — demo/problem.pddl

```lisp
(can-empty pickup delivery)
```

### fact — demo/problem.pddl

```lisp
(robot-at delivery)
```

### goal — demo/problem.pddl

```lisp
(:goal (package-at parcel delivery))
```

### init — demo/problem.pddl

```lisp
(:init
  (robot-at delivery)
  (package-at parcel pickup)
  (hand-empty)
```

### loadedpre — demo/domain.pddl

```lisp
:precondition (and
  (robot-at ?from)
  (holding ?p)
  (can-loaded ?from ?to))
```

### moveeffect — demo/domain.pddl

```lisp
:effect (and
  (not (robot-at ?from))
  (robot-at ?to))
```

### objects — demo/problem.pddl

```lisp
(:objects pickup delivery
          upper-left upper-right - location
          parcel - package)
```

### permission — demo/problem.pddl

```lisp
(can-loaded pickup delivery)
```

### pick — demo/domain.pddl

```lisp
(:action pick
  :parameters (?p - package ?l - location)
  :precondition (and (robot-at ?l)
    (package-at ?p ?l) (hand-empty))
  :effect (and (holding ?p)
    (not (package-at ?p ?l))
    (not (hand-empty))))
```

### place — demo/domain.pddl

```lisp
(:action place
  :parameters (?p - package ?l - location)
  :precondition (and (robot-at ?l) (holding ?p))
  :effect (and
    (package-at ?p ?l)
    (hand-empty)
    (not (holding ?p))))
```

### predicate — demo/domain.pddl

```lisp
(robot-at ?l - location)
```

### reversepermission — demo/problem.pddl

```lisp
(can-loaded delivery pickup)
```

### types — demo/domain.pddl

```lisp
(:types location package)
```

## Validation

Check all 23 rendered/exported pages, 23 visible slides, no hidden slides, notes/timings/lecture citations, and unchanged hashes for all 13 protected files. Authored PDDL excerpts are compared by tokens; the independent C# checker reproduces the four/six-action plans, exact rejection/refinement, and geometry. Actual Python-suite/headless results are recorded separately in slides/python_validation.json. Rendered contact sheets receive visual review. No classroom rehearsal or live hardware execution is claimed.