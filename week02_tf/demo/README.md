# Week 2 — tf2 Live Demo

Reproduce the professor's camera-to-base example, then add a moving base in RViz.
Use printed lecture slides 16, 18, 22, and 37–40; the PDF repeats slide builds.

```text
base_link --translation (0, 0, 0.5)--> camera_mount --yaw +90°--> camera_frame
```

Each arrow points from parent to child. Its stored transform maps child coordinates
into parent coordinates. The camera point `(0.2, 0, 1.0)` becomes `(0, 0.2, 1.5)`
in `base_link`, in metres. `camera_frame` uses the lecture's simplified axes,
not standard camera optical axes.

## Prerequisites and Terminal Setup

Use Linux/Bash with ROS 2 Jazzy and packages `rclpy`, `geometry_msgs`, `tf2_ros_py`,
`tf2_ros`, `tf2_geometry_msgs`, and `rviz2`. Use the system Python associated with
ROS. The scripts run directly; no package build or Gazebo is required.

Open terminals at the repository root. Run this in **every terminal**, including
those used for RViz and inspection:

```bash
source /opt/ros/jazzy/setup.bash
export ROS_DOMAIN_ID=42
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
```

Use another shared domain if 42 is already in use locally. These settings keep
discovery on this machine and apply to the current terminal session.

## 1. Start the Point Node Before the Frames

**Terminal 1:**

```bash
python3 week02_tf/demo/transform_point.py
```

Expect a brief `Waiting for camera-to-base transform` warning. The node retries
once per second and throttles warnings. Its callback returns immediately so the
listener can process incoming transforms.

**Terminal 2:**

```bash
python3 week02_tf/demo/static_frames.py
```

After discovery, Terminal 1 should print this once per second (log prefixes omitted):

```text
camera_frame (0.200, 0.000, 1.000) -> base_link (0.000, 0.200, 1.500) m
```

Floating-point formatting may show `-0.000` instead of `0.000`. Starting the static
broadcaster first also works. Keep it running for listeners that join later.

## 2. Inspect the Chain

**Terminal 3:**

```bash
ros2 node list --no-daemon --spin-time 3
ros2 run tf2_ros tf2_echo base_link camera_frame
```

The lookup should report translation approximately `[0, 0, 0.5]` and quaternion
`[0, 0, 0.707107, 0.707107]` in `(x, y, z, w)` order. The CLI describes the pose of
`camera_frame` relative to `base_link`; this maps camera coordinates into base.
Compare it to Python `lookup_transform('base_link', 'camera_frame', Time())`.
Initial discovery warnings are normal. Stop `tf2_echo` with Ctrl+C before continuing.

```bash
ros2 topic echo /point_camera --once
ros2 topic echo /point_base --once
ros2 topic info /tf_static --no-daemon --spin-time 3
ros2 interface show geometry_msgs/msg/TransformStamped
```

Expected point fields:

| Topic | `header.frame_id` | x | y | z |
| --- | --- | ---: | ---: | ---: |
| `/point_camera` | `camera_frame` | 0.2 | 0 | 1.0 |
| `/point_base` | `base_link` | 0 | 0.2 | 1.5 |

Both published points carry the same measurement timestamp. `/tf_static` carries
`tf2_msgs/msg/TFMessage`; each entry inside it is a `TransformStamped`.

## 3. Open RViz

**Terminal 4:**

```bash
rviz2 -d week02_tf/demo/frames.rviz
```

- Keep **Global Options → Fixed Frame** at `base_link` initially.
- Inspect the labeled base, mount, and camera axes: the mount is 0.5 m above the
  base; the camera axes rotate +90° about z at the mount origin.
- The larger translucent blue camera point and smaller orange base point share
  one center. Toggle either point display to confirm they coincide.
- Ask why different coordinate numbers produce the same displayed location.

## 4. Add a Moving Base

In Terminal 3, after stopping any continuous inspection command:

```bash
python3 week02_tf/demo/moving_base.py
```

This adds `world → base_link` at 10 Hz: zero translation and yaw
`0.2 × elapsed_seconds` radians. In RViz, change **Fixed Frame** to `world`.
Observe the rotating base and its camera. Point messages update at 1 Hz, so their
positions are sampled rather than a continuous trace. Return to `base_link` to
see the same scene relative to the robot.

For numerical inspection, use another prepared terminal:

```bash
ros2 run tf2_ros tf2_echo world base_link
```

The yaw changes, while camera-to-base coordinates remain constant. The synthetic
point stays fixed relative to the camera and moves with the robot. A real mug
fixed in the world would have changing camera coordinates instead.

### Timestamp Discussion

`Time()` requests the latest available transform. It is sufficient for the
camera-to-base computation because both edges in that path are static.

For a real measurement through a moving frame, request its actual time, e.g.
`lookup_transform('world', point.header.frame_id, Time.from_msg(point.header.stamp))`.
The buffer must contain data for that time; a listener may need to wait for a
future sample or report that older data has expired. Do not silently replace the
measurement time with the latest transform.

The point script restores the input measurement timestamp after `do_transform_point`
(which takes its output header from the transform). RViz then uses that time for
both points when converting them into `world`. It may briefly wait for the next
dynamic transform sample. This demo illustrates timestamps; it does not simulate
a delayed camera or implement historical sensor processing.

## Code Walkthrough (5 Minutes)

1. `static_frames.py`: find parent/child names, the 0.5 m translation, and the
   half-angle quaternion. Both edges are sent together by a static broadcaster.
2. Contrast the lecture's `(w, x, y, z)` with ROS `(x, y, z, w)`. Identity needs
   `w=1`; a default all-zero quaternion is invalid.
3. `transform_point.py`: find the stamped input, buffer/listener, target/source
   order, `do_transform_point`, and the two publishers.
4. Before the moving segment, point out `moving_base.py`'s 0.1-second timer,
   changing timestamp, and `sin(yaw/2)` / `cos(yaw/2)` fields.

## Troubleshooting and Fallback

- **Missing modules/commands:** source Jazzy and use the matching system Python.
- **Missing frame:** check script processes, exact frame names, and identical
  ROS domain settings; allow a few seconds for discovery.
- **RViz cannot find `world`:** start `moving_base.py`, or use `base_link` for the
  static demo. A desktop/display is required for RViz.
- **Wrong result:** check target/source direction, radians, quaternion order,
  unit norm, and translation in parent coordinates.
- **Time/extrapolation error:** check measurement timestamps, clock consistency,
  and dynamic publisher history. Latest lookup is not a general repair.
- **One point seems hidden:** toggle the overlapping point displays; their sizes
  differ so the smaller sphere can be seen inside the larger one.
- **Stale CLI discovery after changing terminal settings:** run `ros2 daemon stop`
  in that terminal and retry. Close old broadcasters that publish the same child.
- **GUI unavailable:** use the frame tree, transform values, point table, and
  expected terminal line above. Ask students to predict each result before revealing it.

If RViz launched from VS Code's Snap terminal fails with a `GLIBC_PRIVATE` or
`libpthread` symbol error, retry with its inherited GTK/GIO paths removed:

```bash
env -u GTK_PATH -u GIO_MODULE_DIR -u GTK_EXE_PREFIX -u GTK_DATA_PREFIX \
  rviz2 -d week02_tf/demo/frames.rviz
```

This workaround was needed on the TA development machine; it changes only the
launched process's environment. An ordinary system terminal is another option.

Stop scripts and continuous CLI tools with Ctrl+C; close RViz. The demo stores no
robot state, and restarting the moving node resets its elapsed time and yaw.

## Rehearsal Checklist

- [ ] Predict and verify `(0, 0.2, 1.5)` within `1e-6`.
- [ ] Verify inverse recovery and agreement between direct and composed transforms.
- [ ] Start the point node before and after the static broadcaster.
- [ ] Inspect the frame chain, point topics, and moving transform.
- [ ] Check RViz overlap and rotation with the appropriate fixed frame.
- [ ] Test Ctrl+C and keep the fallback output ready.
- [ ] Fit the demo block into 25 minutes: 5 code, 10 static/RViz, 5 moving/time,
      and 5 checkpoint/wrap-up.

## Validation on the TA Machine

Checked on ROS 2 Jazzy:

- Forward result, inverse recovery, and direct/composed agreement within `1e-6`.
- Both startup orders, including recovery from an initially missing frame.
- CLI node discovery and the composed transform in `tf2_echo`.
- Dynamic yaw rate of 0.2 rad/s and equal world coordinates for both point
  representations at the same measurement time.
- RViz static and world views: frame axes, overlapping points, and changing
  positions during rotation; the GUI reported an OK global status.
- Clean Ctrl+C shutdown of all three Python nodes.

Rehearse on the classroom machine too; display and environment settings may differ.

## References

- Professor's *Class 2: Coordinate Frames, Rotations, and Transformations*, printed
  slides 16, 18, 22, 31, and 37–43; supplied separately as `Robotics_AutonomousSystems.pdf`.
- [Official ROS 2 static broadcaster tutorial](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Static-Broadcaster-Py.html).
- [Week 2 teaching notes](../TEACHING_NOTES.md) and [TA course plan](../../TA_plan.md).
