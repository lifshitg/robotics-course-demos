# Week 3 — Gazebo and Kinematics Demo

A two-joint arm connects URDF modeling, planar forward/inverse kinematics, ROS
commands, and measured motion. It uses ROS 2 Jazzy and Gazebo Harmonic (Gazebo Sim 8).

## What Each File Does

| File | Role |
| --- | --- |
| `arm.urdf` | Robot links, joints, geometry, inertias, limits, and Gazebo controllers |
| `world.sdf` | Ground, lighting, physics, and model-spawning systems |
| `gui.config` | Saved Gazebo camera view, entity tree, and playback/statistics controls |
| `bridge.yaml` | Topic types and directions between ROS and Gazebo |
| `demo.launch.py` | Starts simulation, spawns the arm, and runs bridge/state publisher |
| `kinematics.py` | ROS-independent FK and analytical IK |
| `command_arm.py` | Sends targets and checks measured convergence |
| `test_kinematics.py` | Mathematics, boundary cases, and model-consistency tests |
| `gazebo_overview.svg` | Labeled screenshot for the interface tour |

No package build or external model download is needed. Run commands below from
the repository root. Model paths are resolved relative to the launch file.

## Prerequisites and Setup

Required: Jazzy, Gazebo Harmonic, `ros_gz_sim`, `ros_gz_bridge`,
`robot_state_publisher`, `rclpy`, `sensor_msgs`, `std_msgs`, `rosgraph_msgs`, and
`tf2_ros`. The GUI requires a desktop/display; the headless demo does not.

In **each terminal**:

```bash
source /opt/ros/jazzy/setup.bash
export ROS_DOMAIN_ID=42
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
export GZ_PARTITION=robotics_week03
```

Use matching settings in all demo terminals. `ROS_DOMAIN_ID` separates ROS graphs;
`GZ_PARTITION` separates Gazebo Transport. Close earlier copies of this demo before
starting another with the same settings. Use the system Python matching ROS.

## Launch

**Terminal 1 — complete GUI demo:**

```bash
ros2 launch ./week03_kinematics/demo/demo.launch.py
```

**Headless alternative:**

```bash
ros2 launch ./week03_kinematics/demo/demo.launch.py headless:=true
```

Choose one launch mode. Both run physics, spawn the same model, and publish measured
feedback. Wait for `Entity creation successful` and bridge startup messages.
The simulation starts playing; the arm initially extends along +x.

If Gazebo launched from VS Code's Snap environment reports a `GLIBC_PRIVATE` or
`libpthread` error, remove inherited GTK/GIO paths for that process:

```bash
env -u GTK_PATH -u GIO_MODULE_DIR -u GTK_EXE_PREFIX -u GTK_DATA_PREFIX \
  QT_QPA_PLATFORM=xcb ros2 launch ./week03_kinematics/demo/demo.launch.py
```

## Gazebo Interface Tour (Part of the 8-Minute Opening Demo)

Use the [labeled view](gazebo_overview.svg).

1. **World and robot:** locate the ground, light, and `planar_arm` in the entity tree.
   The fixed gray base supports a blue 0.6 m link and an orange 0.4 m link. The green
   sphere marks the end effector.
2. **View navigation:** drag with the left mouse button to pan, scroll to zoom,
   and drag with the middle mouse button (or Shift+left drag) to orbit. Camera
   movement changes your view, not the robot configuration.
3. **Clock:** expand the statistics using the small chevron near the lower-right
   corner of the 3D view. Compare simulation time, real time, and real-time factor.
4. **Play/pause:** click pause at the lower left; simulation time and robot motion
   stop while wall time continues. Resume before sending a command.
5. **Reset:** identify the circular-arrow control. It resets the simulation, not
   the entire ROS application. Use the full restart below for a reliable baseline.

Gazebo simulates physics and supports sensors; this demo uses joint measurements
and has no camera sensor. ROS transports data and runs the kinematics code. RViz
can display ROS data, but is not required for this Gazebo lesson.

## Command Individual Joints and Predict FK

**Terminal 2:**

```bash
python3 week03_kinematics/demo/command_arm.py joints --q1 0 --q2 0
python3 week03_kinematics/demo/command_arm.py joints --q1 0.5 --q2 0
python3 week03_kinematics/demo/command_arm.py joints --q1 0 --q2 1.5707963267948966
```

Angles are radians. Both joints turn around +z. The second angle is relative to
link1, so the second link's absolute angle is `q1+q2`.

```text
x = 0.6 cos(q1) + 0.4 cos(q1+q2)
y = 0.6 sin(q1) + 0.4 sin(q1+q2)
```

Predict `(x,y)=(1,0)` for zero angles and `(0.6,0.4)` for `(0,π/2)`.
Positions are expressed in `base_link`, where the tool has z=0. The fixed base is
0.25 m above `world`, so its world z coordinate is 0.25 m.

## Reach One Target Through Two Configurations

```bash
python3 week03_kinematics/demo/command_arm.py target --x 0.6 --y 0.4 --branch positive
python3 week03_kinematics/demo/command_arm.py target --x 0.6 --y 0.4 --branch negative
```

`positive` and `negative` select the sign of elbow angle q2. The default is
`positive`. Expected joint targets:

| Branch | q1 (rad) | q2 (rad) | Tool xy (m) |
| --- | ---: | ---: | --- |
| Positive | 0 | 1.570796 | (0.6, 0.4) |
| Negative | 1.176005 | -1.570796 | (0.6, 0.4) |

The final positions match; the configurations and tool orientations differ.
Targets constrain xy position only. Links can pass through each other because
self-collision is disabled; this is not collision-free motion planning.

Representative positive-branch output from a zero configuration:

```text
Requested joints: q1=0.000000, q2=1.570796 rad
Predicted position: x=0.600000, y=0.400000 m
Measured joints: q1=0.000000, q2=1.561000 rad
Measured position: x=0.603918, y=0.399981 m
Position error: 0.003919 m; converged.
```

Measured values vary with timing. Success requires both joint errors below
0.01 rad and position error below 0.01 m. The command tool computes measured
position by applying FK to simulated joint measurements. The robot continues
settling toward the last target after the tool exits.

## Inspect Commands, Measurements, and TF

**Terminal 3:**

```bash
ros2 topic list
ros2 topic echo /joint_states --once
ros2 topic echo /clock --once
ros2 run tf2_ros tf2_echo base_link end_effector
```

Stop `tf2_echo` with Ctrl+C. At the teaching target, translation should approach
`[0.600, 0.400, 0.000]`. Compare it to the command output after motion settles.

| ROS topic | ROS type | Bridge direction |
| --- | --- | --- |
| `/arm/joint1/cmd_pos` | `std_msgs/msg/Float64` | ROS → Gazebo |
| `/arm/joint2/cmd_pos` | `std_msgs/msg/Float64` | ROS → Gazebo |
| `/joint_states` | `sensor_msgs/msg/JointState` | Gazebo → ROS |
| `/clock` | `rosgraph_msgs/msg/Clock` | Gazebo → ROS |

The underlying Gazebo joint-state topic is `/arm/joint_states`; the bridge renames
it on the ROS side. The clock comes from `/world/kinematics/clock`.

`robot_state_publisher` uses the URDF and **measured** joint states to publish TF.
It does not command the robot. ROS nodes use simulation time; the command tool's
10-second deadline and 10 Hz command scheduling use wall time so it can detect
stopped simulation.

## Unreachable Targets and Failure Demonstrations

```bash
python3 week03_kinematics/demo/command_arm.py target --x 1.2 --y 0
```

Expected: `Unreachable target: radius must be between 0.2 and 1.0 m.` The command
exits with status 2 before creating ROS publishers. The previous target remains
unchanged. The origin is also unreachable because the links have unequal lengths.
Joint targets outside `[-π,π]` and nonfinite numbers are rejected too.

For a preparation check, pause Gazebo and issue a different valid joint target.
The command exits with status 1 after 10 wall-clock seconds and reports missing
or stopped feedback. Resume before retrying. If a command was already sent before
pausing, Gazebo may retain that target and continue toward it on resume.

## Model and Controller Walkthrough

- In `arm.urdf`, compare link1's visual center at x=0.3 to joint2's origin at x=0.6.
  Both joints have axis `0 0 1`; a fixed joint anchors the base to world.
- Inertial and collision elements support physics; colored visual elements make
  the robot readable. The world file supplies a local ground and light.
- Each Gazebo joint-position controller uses velocity-command mode, capped at
  1 rad/s. It provides idealized position control; it is not a realistic motor model.
- `kinematics.py` contains the equations. `command_arm.py` validates targets,
  waits for measured state and bridge connections, publishes at 10 Hz, and checks
  measured convergence with a 10-second wall-clock deadline.
- The GUI configuration only sets up the view. The launch file starts processes;
  it does not perform the IK calculation.

## Reset, Restart, and Shutdown

- To return to the zero configuration without resetting time, command `joints
  --q1 0 --q2 0` while the simulation runs.
- The GUI reset control changes simulator state/time. ROS processes are still
  alive; controller targets and transform history should not be assumed cleared.
- For a reproducible baseline, stop active command tools, Ctrl+C the launch
  terminal, close any separately opened Gazebo client, and relaunch. The model
  respawns at zero and simulation time starts again.
- Ctrl+C stops a command tool but does not cancel a target already received by
  Gazebo. Ctrl+C the launch terminal to stop the complete demonstration.

## Troubleshooting and Fallback

- **No model:** inspect spawn output and verify the physics/user-command plugins
  loaded. Use the local launch file and matching Gazebo partition.
- **No feedback or no motion:** check bridge startup, matching ROS domain, and
  play/pause. No advancing `/clock` usually means the world is paused or absent.
- **Slow convergence:** inspect real-time factor; heavy rendering can slow the
  simulation. Try headless mode before changing the equations or controller.
- **Wrong position:** check radians, joint names, relative angles, and base/world
  frame choice. Initial TF discovery may take a few seconds.
- **GUI library error:** use the Snap-environment workaround above or a normal
  system terminal. If rendering is unavailable, use headless mode and the screenshot.
- **Duplicate robots or odd feedback:** close older launch sessions using the
  same ROS domain/Gazebo partition and restart one copy.
- **Paused-demo warning:** latest commands may remain active. Resume deliberately
  or perform a full restart before the next example.

For a classroom fallback, use the screenshot, FK equations, branch table, and
representative output. The same commands and TF checks work headlessly.

## Tests and Rehearsal

```bash
python3 -m unittest discover -s week03_kinematics/demo -p 'test_*.py'
```

Tests cover worked FK examples, both IK branches, round trips, singular workspace
boundaries, invalid inputs, joint limits, and consistency with URDF dimensions.

Rehearse the three live blocks: 8 minutes interface and joints, 10 minutes target
and branches, 7 minutes rejection and checkpoint. See the [teaching notes](../TEACHING_NOTES.md)
for the full 45-minute schedule.

## Validation Results

Validated on the TA machine with ROS 2 Jazzy and Gazebo Harmonic 8.15:

- All five unit tests passed, including both branches and singular boundaries.
- Headless and full GUI launch both spawned the model and bridge successfully.
- Individual joint commands and both IK branches converged below 1 cm position
  error; representative IK runs ended around 3.9 mm before further settling.
- Measured-state FK agreed with end-effector TF within 1 mm in the checked poses.
- Unreachable input published no commands and left the settled pose unchanged.
- Pause/resume through Gazebo's world-control service and missing-simulator
  checks produced the expected 10-second wall-clock timeout behavior.
- A fresh launch restored the zero configuration; Ctrl+C shut down the launched
  Gazebo, bridge, and state-publisher processes cleanly.
- The saved GUI view rendered the arm and supplied the labeled screenshot.
  Rehearse mouse navigation and the statistics expander on the classroom desktop;
  window layout and desktop input behavior can differ.

## References

- [Gazebo Harmonic ROS integration](https://gazebosim.org/docs/harmonic/ros2_integration/).
- [Gazebo joint-position controller](https://gazebosim.org/api/sim/8/classgz_1_1sim_1_1systems_1_1JointPositionController.html).
- [TA course plan](../../TA_plan.md): Session 3, HW1, and HW3.
