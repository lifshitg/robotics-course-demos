# Week 2 — Coordinate Transforms and tf2

## Goal

- Convert a point between frames and explain the direction of the transform.
- Connect a rotation matrix and translation to ROS quaternion and transform fields.
- Broadcast a frame chain, inspect it with tf2, and recognize the same point in RViz.
- Explain why a moving sensor measurement needs a transform at its measurement time.

## Context / Recap

- Week 1 connected nodes through typed messages. Now ask: “A camera sends `(0.2, 0, 1.0)` — relative to which axes and origin?”
- HW1 will need a camera observation expressed in the robot base frame before commanding motion. Today we isolate the coordinate conversion.
- Professor reference: *Robotics and Autonomous Systems, Class 2: Coordinate Frames, Rotations, and Transformations*, Ronen I. Brafman. Use printed slide numbers; the 46 numbered slides have repeated builds across 108 PDF pages.

## Core Explanation

### One point, two coordinate descriptions

Use the lecture notation: $^A T_B$ describes the pose of B in A and maps B coordinates into A. The physical point does not move when we change its coordinate description (slides 12–13).

$$
{}^A p = {}^A R_B\,{}^B p + {}^A t_B,
\qquad
{}^A T_B = \begin{bmatrix}{}^A R_B & {}^A t_B\\0\;0\;0 & 1\end{bmatrix}.
$$

### Worked example (slides 16, 18, 22)

The simplified camera frame is rotated +90° about z and is 0.5 m above the base:

```text
p_camera = (0.2, 0, 1.0) m
R = [[0, -1, 0], [1, 0, 0], [0, 0, 1]]
t = (0, 0, 0.5) m
R p_camera = (0, 0.2, 1.0) m
p_base = R p_camera + t = (0, 0.2, 1.5) m
T = [[0, -1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0.5], [0, 0, 0, 1]]
```

Ask students to predict the rotated x coordinate before revealing the result.
`camera_frame` follows the lecture's simplified axes, not the standard camera optical convention (x right, y down, z forward).

### Composition, inversion, and representations

- Split the demo into `base_link → camera_mount → camera_frame`. The first edge translates; the second rotates. $^B T_C = {}^B T_M {}^M T_C$; the rightmost matrix acts first (slides 19–20).
- The inverse has rotation $R^T$ and translation $-R^Tt$. Transforming `(0, 0.2, 1.5)` back gives `(0.2, 0, 1.0)`.
- A point is rotated and translated; a direction vector is only rotated (slide 21).
- A unit quaternion encodes axis and half-angle: lecture order `(w, x, y, z) = (cos(θ/2), k_x sin(θ/2), k_y sin(θ/2), k_z sin(θ/2))` (slide 31).
- ROS fields are `(x, y, z, w)`. For +90° about z, set `(0, 0, √½, √½)`; identity is `(0, 0, 0, 1)`. Use radians and unit norm.

### From matrices to tf2 (slides 37–40)

- Each child has one parent; tf2 composes and inverts edges along the tree.
- `TransformStamped.header.frame_id` is the parent; `child_frame_id` is the child. The stored transform maps child coordinates into parent coordinates.
- Static broadcasters publish fixed relationships on `/tf_static`; dynamic broadcasters publish timestamped relationships on `/tf`.
- A listener fills a buffer. `lookup_transform(target, source, time)` requests source coordinates expressed in target.
- `PointStamped` carries coordinates, frame, and time. `Time()` requests the latest available transform; this demo uses it only across the static camera-to-base chain.
- For a moving sensor, request the transform at the measurement timestamp. Missing history or future data can make that lookup unavailable; silently substituting the latest transform changes the meaning.

Preparation references: slides 12–22 for mathematics, 25–35 for representation details, 37–40 for trees/time, and 43 for pitfalls. Keep full rotation derivations, gimbal lock, and SLERP outside the live explanation.

## Live Demo

Follow [the demo README](demo/README.md).

1. **5 minutes:** Show parent/child fields, quaternion assignments, the lookup argument order, and the point conversion in the two static-demo scripts.
2. **10 minutes:** Start the point node first to show a recoverable missing-frame warning. Start the static broadcaster, read the result, inspect the composed transform, and open RViz. The two differently expressed points overlap physically.
3. **5 minutes:** Start the moving base and change RViz's fixed frame to `world`. The base rotates while camera-to-base coordinates stay constant. The synthetic point is fixed relative to the camera, so it also moves in world coordinates. Contrast this with a real stationary mug, whose camera coordinates would change.
4. **5 minutes:** Check understanding and recap; use the expected output in the README if the GUI fails.

Checkpoint answers:

- “Which lookup converts camera into base?” Target `base_link`, source `camera_frame`.
- “Why do the RViz points overlap?” They describe the same physical point in different frames.
- “What does the inverse recover?” `(0.2, 0, 1.0)` in `camera_frame`.
- “May an old camera image use the latest moving-base transform?” Generally no; use the measurement time.

## Timing

| Part | Minutes |
| --- | ---: |
| Recap: a coordinate needs a frame | 5 |
| Worked mathematics and ROS conventions | 15 |
| Code walkthrough | 5 |
| Static transforms, point conversion, and RViz | 10 |
| Moving frame and timestamps | 5 |
| Learning checkpoint and wrap-up | 5 |
| **Total** | **45** |

## Common Questions / Problems

- **Wrong coordinates:** check target/source order, rotation direction, and whether translation is expressed in the parent frame.
- **Invalid rotation:** check radians, quaternion field order, unit norm, and `w=1` for identity.
- **Frame not found:** check exact names, shared ROS domain, running broadcasters, and discovery time. Return from callbacks so the listener can receive transforms.
- **Extrapolation errors:** the requested timestamp is outside available dynamic history. Check clocks, timestamps, and publisher startup; static transforms do not demonstrate historical lookup failures.
- **RViz fixed-frame error:** keep `base_link` for the static segment; choose `world` only after starting the moving base.
- **Only one point seems visible:** the spheres overlap by design. Toggle each display to compare.
- **Conflicting transforms:** use one broadcaster per child relationship; close old demo processes before rehearsal.

## Homework Connection

- [TA course plan](../TA_plan.md), HW1: this is the camera-to-base conversion step. Detection, Gazebo, and commands to robot joints come later.
- HW3: practise composition, inverse transforms, and representation conventions using this numerical example.
- Week 3 extends fixed relationships into robot links and joint-dependent kinematics.

## Preparation Checklist

- [ ] Review the numbered lecture slides listed above and rehearse the worked calculation.
- [ ] Confirm ROS 2 Jazzy, tf2 Python support, geometry messages, and RViz on the teaching machine.
- [ ] Test startup with the point node before the broadcaster, then in reverse order.
- [ ] Confirm `(0, 0.2, 1.5)` and inverse recovery within numerical tolerance.
- [ ] Verify RViz axes, overlapping points, and motion with `world` as fixed frame.
- [ ] Check CLI commands, terminal readability, clean shutdown, and fallback output.
- [ ] Rehearse the 45-minute flow, including the closing questions.
