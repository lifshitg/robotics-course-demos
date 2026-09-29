# Week 2 — Coordinate Transforms and tf2 Presentation Plan

## Slide 1 — Why Does the Frame Matter?

- A camera reports a target; the robot controller expects coordinates in the base frame.
- Recall Week 1: a message carries data. Geometric data also needs a frame and timestamp.
- Spend the first 5 minutes on context; keep slides 2–9 within the next 15 minutes.

## Slide 2 — Read the Frame Labels

- `ᴬT_B` describes frame B in A and converts B coordinates into A.
- The physical point stays put; its coordinate description changes.
- Show two sets of axes around one point (professor slides 12–13).

## Slide 3 — Rotate, Then Translate

- Camera point `(0.2, 0, 1.0)`; camera rotated +90° about z and 0.5 m above the base.
- Predict: rotation gives `(0, 0.2, 1.0)`; translation gives `(0, 0.2, 1.5)`.
- Label this as the lecture's simplified camera frame, not a standard optical frame (slides 16, 18, 22).

## Slide 4 — One Matrix and a Chain

- Show `T = [R t; 0 1]`, with a final homogeneous coordinate of 1 for points.
- Compose `ᴮT_C = ᴮT_M ᴹT_C`; connect the indices to base → mount → camera.
- Inverse: `Rᵀ` and `−Rᵀt`; recover the original camera coordinates.
- A direction is rotated only, without translation (slides 19–21).

## Slide 5 — Quaternions in ROS

- A unit quaternion stores axis and half-angle: `(w, v) = (cos(θ/2), k sin(θ/2))`.
- Professor: `(w, x, y, z)`; ROS: fields `(x, y, z, w)`.
- Our +90° z rotation: ROS `(0, 0, √½, √½)`; identity `(0, 0, 0, 1)`.
- Check radians and unit norm; defer detailed derivations (slide 31).

## Slide 6 — The Frame Tree

- Static chain: `base_link → camera_mount → camera_frame`.
- Each child has one parent; tf2 finds and composes the path.
- Later add dynamic `world → base_link`; fixed mounts and moving bodies need different broadcasters (slides 37–39).

## Slide 7 — Where the Mathematics Lives in Code

- `TransformStamped`: parent, child, timestamp, translation, quaternion.
- Broadcaster sends relationships; listener fills a buffer.
- `lookup_transform(target, source, time)` plus `PointStamped` converts the measurement.
- Connect `/tf_static` and `/tf` to Week 1 topics.

## Slide 8 — Time and Common Mistakes

- Match the transform to the measurement time when frames move (slide 40).
- Latest available is sufficient for our static camera-to-base calculation.
- Check frame direction, radians, quaternion order, missing frames, and unavailable history (slide 43).

## Slide 9 — Predict, Then Inspect

- Ask for the expected base point and the target/source arguments before running code.
- Inspect with `tf2_echo`, view axes and overlapping points in RViz, then add motion.
- Reserve the remaining 25 minutes for code, static demo, moving frames, and the closing checkpoint.

## Visuals Needed

- One point shown against camera and base axes; label rotation and height.
- Worked rotation/translation calculation and the matching 4×4 matrix.
- Parent-to-child frame tree with static and dynamic edges labeled.
- Side-by-side quaternion orders and an old-image/new-transform timeline.
- Live RViz view; terminal output from the demo README as a fallback.

## Live Demo Transition

- Open `static_frames.py` and `transform_point.py` side by side.
- Follow the [demo README](demo/README.md), first predicting `(0, 0.2, 1.5)`.
- End with: which frame, which direction, which time? These questions carry into HW1.
