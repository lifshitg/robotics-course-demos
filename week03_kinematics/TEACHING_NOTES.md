# Week 3 — Gazebo and Robot Kinematics

## Goal

- Explain what Gazebo simulates, why we use it, and how it differs from RViz.
- Identify links, joints, axes, and origins in a small URDF model.
- Calculate forward kinematics (FK) and interpret two inverse-kinematics (IK) solutions.
- Send ROS joint commands into Gazebo and verify measured motion through joint states and TF.

## Context / Recap

- Week 1: ROS nodes communicate through typed topics. Week 2: transform chains convert coordinates between frames.
- This week the transforms depend on joint angles: `base_link → link1 → link2 → end_effector`.
- Follow [TA_plan.md](../TA_plan.md), Session 3. No separate professor Week 3 lecture has been supplied; these are TA preparation materials.
- Open with: “Given a target in the base frame, which angles would put the robot's tool there?”

## Core Explanation

### What Gazebo is and why we need it (5 minutes)

- Gazebo is a robotics simulator: it runs a world containing models, a physics engine, and optionally sensors. Time advances in simulation steps.
- We can develop before hardware is available, repeat experiments, and try commands without risking the physical robot. HW1 uses it for robot interaction.
- Simulation quality depends on geometry, inertia, contact, actuator, and sensor models. A successful simulation still needs validation on hardware.
- Gazebo computes simulated behavior; ROS carries commands and measurements; RViz displays ROS data. A Gazebo model does not become a ROS node by itself.
- Our ROS–Gazebo bridge carries command topics into Gazebo and measured joint states and the simulation clock back out.
- Explain play/pause, simulation time versus wall time, and reset. Pause the world during the interface tour to show the simulation clock stop.

### Robot description and conventions

- URDF describes links and joints. Link geometry is distinct from the link frame: our first link's box center is at x=0.3 m, but its frame is at the shoulder.
- A joint defines parent, child, origin, axis, and limits. Visual shapes support rendering; collision geometry and mass/inertia support physics.
- The SDF world defines the environment, physics settings, lighting, and simulation systems. Gazebo converts the URDF when spawning the robot.
- Our base is anchored 0.25 m above world ground. Both joint axes are +z; the arm moves in base xy. The end-effector has z=0 in base and z=0.25 in world.
- Link lengths: `L1=0.6 m`, `L2=0.4 m`. Zero angles extend along +x; positive angles follow the right-hand rule. Angles are radians; limits are `[-π, π]`.

### Forward kinematics

```text
x = L1 cos(q1) + L2 cos(q1 + q2)
y = L1 sin(q1) + L2 sin(q1 + q2)
```

- The second link's absolute angle is `q1 + q2`: q2 is relative to link1.
- `(q1, q2)=(0, 0)` gives `(x, y)=(1, 0)`.
- `(0, π/2)` gives `(0.6, 0.4)`. Ask students to predict this before commanding it.
- This is the xy part of the transform product from Week 2. Tool orientation is `q1+q2`; our target command specifies position only.

### Inverse kinematics

```text
c2 = (x² + y² - L1² - L2²) / (2 L1 L2)
q2 = ±acos(c2)
q1 = atan2(y, x) - atan2(L2 sin(q2), L1 + L2 cos(q2))
```

- Two signs give two configurations. For `(0.6, 0.4)`: positive branch is `(0, 1.570796)`; negative branch is approximately `(1.176005, -1.570796)`.
- Both reach the same point but have different tool orientations. IK is not generally unique.
- Geometric workspace: `0.2 ≤ sqrt(x²+y²) ≤ 1.0`. `(1.2, 0)` is unreachable, and the origin is also unreachable because the link lengths differ.
- Full extension and folding are singular: the branches meet and the arm loses an instantaneous Cartesian motion direction. Keep the Jacobian derivation for later.
- Our code checks finite inputs, geometric reachability, and joint limits. Tiny floating-point errors are clamped only at the workspace boundaries.

### Commands versus measurements

- Each Float64 command requests a joint angle. Gazebo controllers move the joints; the bridge returns measured `JointState` data.
- `robot_state_publisher` combines URDF with measured angles to publish TF. It does not command the robot or compute IK.
- The controller uses an idealized velocity-command mode, capped at 1 rad/s. This keeps attention on kinematics rather than actuator tuning.
- The command tool computes the measured end position from measured joint angles. Compare it with `tf2_echo base_link end_effector`.
- Self-collision is disabled. An IK solution is a position solution, not a collision-free path; Week 4 introduces planning.

## Live Demo

Use the [demo README](demo/README.md) and launch Gazebo before the session.

1. **8 minutes:** Identify robot, world, camera controls, clock, and play/pause. Pause/resume once, inspect the URDF axes/origins, and command individual joints.
2. **10 minutes:** Predict `(0.6, 0.4)` for `(0, π/2)`, then command it. Run IK for the same target with both branches. Inspect measured state and end-effector TF.
3. **7 minutes:** Reject `(1.2, 0)` without sending a command. Ask the checkpoint questions and summarize Gazebo's role plus the command/measurement loop.

Checkpoint answers:

- **Does RViz simulate physics?** No; it displays ROS data. Gazebo runs the simulation.
- **Why use q1+q2 for link2?** Joint2's rotation is relative to the first link.
- **Can one point have two IK solutions?** Yes; this arm has two branches away from singular boundaries.
- **Does publishing a target prove it was reached?** No; inspect measured joints and position error.
- **Does IK avoid obstacles?** No; geometric reachability alone does not plan a safe path.

## Timing

| Part | Minutes |
| --- | ---: |
| Recap: transforms become joint-dependent | 5 |
| What Gazebo is and why we use simulation | 5 |
| Robot modeling and forward/inverse kinematics | 10 |
| Gazebo interface tour and individual joint commands | 8 |
| Reach a target and compare two IK solutions | 10 |
| Unreachable target, checkpoint, and recap | 7 |
| **Total** | **45** |

## Common Questions / Problems

- **No motion:** check play/pause, model spawn, command bridge, and measured joint-state updates.
- **Command times out:** it allows 10 wall-clock seconds, even if simulation time stops. Check a paused or slow simulator before changing the mathematics.
- **Wrong coordinates:** check radians, joint order, parent-relative angles, link origins, and base versus world height.
- **Target rejected:** check the inner as well as the outer workspace boundary and joint limits.
- **TF missing:** inspect `/joint_states` and the `robot_state_publisher` process; publishing commands alone does not generate measured TF.
- **Robot folds through itself:** self-collision is intentionally disabled for the position examples; this is not a motion-planning demo.
- **Reset surprises:** a world reset is not a complete restart of ROS nodes and controller state. Use the documented full restart for a reproducible baseline.

## Homework Connection

- HW1: once a camera target is expressed in the robot base frame, choose a feasible configuration and send joint commands in Gazebo. Camera perception is outside this demo.
- HW3: FK, IK branches, reachable workspace, and transforms connect directly to mathematical exercises.
- Week 4: add path feasibility and obstacles to the position-level reasoning learned here.

## Preparation Checklist

- [ ] Run the pure kinematics tests and verify the model dimensions match the equations.
- [ ] Launch Jazzy/Harmonic and check model anchoring, axes, colors, and the saved camera view.
- [ ] Rehearse both IK branches, measured errors below 1 cm, and end-effector TF.
- [ ] Test unreachable input, missing simulation, and paused-simulation timeout.
- [ ] Rehearse play/pause and a full restart, then restore the zero configuration.
- [ ] Keep the labeled Gazebo screenshot and expected output ready as fallbacks.
- [ ] Rehearse the complete 45-minute session.
