# Week 4 — Configuration Space and Probabilistic Roadmaps

## Goal

- Distinguish a reachable goal from a collision-free motion to that goal.
- Map the whole arm to a configuration `(q1, q2)` and relate workspace obstacles to invalid configurations.
- Explain and read the PRM pipeline: sample, reject collisions, connect, and search.
- Interpret the returned path and the limits of a finite roadmap.

## Context / Recap

- Week 3's IK found joint angles for a target. It did not check the motion between configurations.
- Ask: “If both endpoints are safe, can the arm still hit something in between?”
- Source: the supplied `MotionPlaningIntroPRM.pdf`, credited to Oren Salzman, combines selected Introduction and planar-planning slides with repeated builds. Cite section plus printed slide number, not PDF page number.
- References: Introduction 15–20 (configuration space and problem statement); PRM 4–8 (pipeline/sampling), 14 (connections), 17 and 20 (collision/local planning), 21 (search), 22–23 (completeness).

## Core Explanation

### Workspace and configuration space

- Workspace is the physical xy plane. A configuration `(q1, q2)` specifies the entire arm; the end-effector position alone does not.
- Use Week 3's lengths: 0.6 m and 0.4 m. FK maps each configuration to base, elbow, and tool positions for collision checking.
- Our hard limits give a bounded square `[-π,π]²`. Opposite edges are not connected. Two unrestricted revolute joints would give `S¹ × S¹`; the lecture's 2R example should be interpreted as having two angular coordinates.
- The free region is defined by geometric collision queries. Its plotted grid is a teaching visual, not planner input.

### The scene and collision model

- Start `(-0.7,0.6)`, goal `(0.7,-0.6)` radians. Both are free; their direct interpolation passes through the colliding `(0,0)` configuration.
- Obstacle center `(0.80,0)` m, physical radius 0.12 m. Both links are capsules of radius 0.03 m; add 0.01 m collision padding. Contact is rejected.
- Implementation correction to the initial plan: center x=0.75 plus thickness/padding blocked every q1=0 configuration. Moving the obstacle 5 cm outward makes a detour possible without removing padding.
- Check both links, not just the tool. Self-collision is outside this simplified model, as in Week 3.
- An edge is tested at endpoints and intermediate configurations with maximum joint increments of 0.01 rad. Explain approximate local checking and padding; this is not a general continuous collision detector or a physical robot safety guarantee.

### PRM construction and query

1. Uniformly sample angles; reject colliding configurations until enough samples are accepted or the attempt budget is exhausted.
2. For each accepted sample, consider its k nearest neighbors in Euclidean joint-angle distance.
3. Add an undirected edge only if the interpolated local motion passes collision checking. Its cost is joint-space length in radians.
4. Copy the roadmap for a query, attach start and goal with checked edges, and run Dijkstra. The original roadmap remains reusable.

- Defaults: 300 accepted samples, k=10, seed=7; a finite rejection budget prevents hanging.
- Read `configuration_free`, `edge_free`, `build_roadmap`, and `query_roadmap` in the demo. The code uses ordinary neighbor search and a heap for clarity.
- Shortest on this graph is not shortest in continuous free space. Joint-space length is also not tool travel distance or execution time.
- The animation adds a playback speed to a geometric path; it does not model acceleration, control error, or dynamics.

### What failure means

- “No path found in this roadmap” does not prove no physical path exists. Sampling or connections may have missed one.
- Narrow passages are easy to miss with uniform sampling. Changing sample count, connections, or seed changes results.
- Probabilistic completeness concerns limiting success probability under appropriate assumptions. It is not a finite-run promise, and we do not claim it for every fixed-k implementation.
- PRM* and asymptotic optimality are distinct topics. Keep the lecture's advanced sampling, neighbor structures, and PRM* proofs in preparation references.

## Live Demo

Follow [the demo README](demo/README.md).

1. **5 minutes:** Walk through FK-based collision checking, interpolation, the connection loop, and Dijkstra query.
2. **12 minutes:** Preview the endpoints and `(0,0)`. Reveal accepted samples, valid edges, then the selected path. Animate both panels together. Pause and explain one configuration along the route.
3. **8 minutes:** Compare 20 and 300 samples with seed 7. Both defaults find a path; the larger example is shorter in this particular comparison. Explain why this is not guaranteed for every run. End with the checkpoint.

Expected comparison: 20 samples / 91 roadmap edges / path about 5.630 rad; 300 samples / 1728 edges / path about 5.243 rad. Timings depend on the machine. Query edges are additional to the reported preprocessing edge count.

Checkpoint answers:

- **What does one roadmap vertex represent?** The whole arm at a pair of joint angles.
- **Are free endpoints sufficient?** No; the edge's intermediate configurations also need checking.
- **Does a clear tool imply a clear robot?** No; either link can collide.
- **Does search failure prove impossibility?** No; only absence of a route in this roadmap.
- **Is the output a controller-ready trajectory?** No; it is a geometric path with illustrative playback.

## Timing

| Part | Minutes |
| --- | ---: |
| Recap: IK versus motion planning | 5 |
| Configuration space and the PRM pipeline | 15 |
| Inspect collision checking and planner code | 5 |
| Build, search, and animate the roadmap | 12 |
| Sampling experiment, failure interpretation, recap | 8 |
| **Total** | **45** |

## Common Questions / Problems

- **Robot looks blocked but sample is free:** distinguish physical geometry from the padded model and the approximate background grid. Collision queries determine validity.
- **Collision missed by endpoint checks:** inspect intermediate configurations, resolution, and link thickness.
- **Angles jump across plot boundaries:** the demo uses hard limits and no wrapping; a toroidal model needs a different metric and interpolation.
- **Play does nothing:** advance to the final stage first; a failed query cannot play a path.
- **Seed comparison is inconsistent:** use the same seed and neighbor count. Timing is nondeterministic even when samples/path are reproducible.
- **GUI unavailable:** export with `--export`; use the saved overview images.

## Homework Connection

- [TA_plan.md](../TA_plan.md), HW2: sampling, collision checking, graph construction, and search transfer to maze navigation. The robot state and collision model change for a mobile robot.
- Relate Dijkstra here to the A* alternative in HW2; do not add a second planner implementation this week.
- Carry Week 3's distinction between goal configuration and motion feasibility into future planning tasks.

## Preparation Checklist

- [ ] Review the referenced sections and the bounded-angle convention.
- [ ] Run the geometry/planner/interface tests and default demo.
- [ ] Rehearse endpoint versus midpoint collision and clicking both panels' linked configuration.
- [ ] Check stage progression, play/pause, reset, and reaching the final goal.
- [ ] Run the fixed-seed 20/300 comparison and review graph costs.
- [ ] Keep overview exports ready and check their readability on the classroom screen.
- [ ] Rehearse the 45-minute flow and failure interpretation.
