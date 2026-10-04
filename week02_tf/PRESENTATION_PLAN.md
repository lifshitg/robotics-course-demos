# Week 2 — Coordinate Frames, Transformations, and tf2

Audience: Python familiarity, little robotics geometry or networking. ROS 2 Jazzy baseline. **20 minutes explanation + 25 minutes code/demo/questions = 45 minutes.** Title is untimed. Fourteen core teaching slides, demo transition, ten hidden backups: 26 slides total. Follow the Week 1 palette, editable diagrams and equations, sparse visible prose, detailed speaker notes. All mathematical formulas use column vectors, right-handed rotations, Hamilton quaternions and fixed-axis XYZ RPY unless explicitly comparing conventions. Scalar-first mathematics versus ROS xyzw fields is always labelled.

All seven existing Week 2 files were read. Preserve teaching notes, demo code, RViz configuration and demo README. The separately supplied professor PDF was not found: retain references to Robotics_AutonomousSystems.pdf printed slides 12–22, 25–35, 37–40, and 43 without claiming review.

## Sequence, visuals, and speaker guidance

### Coordinate frames & tf2 — Untimed title

Week 2: understand why coordinates need a frame, how rotation and translation are represented, and how tf2 maintains relationships over time. Audience knows Python and has little geometry/networking background. Title is untimed. Teaching slides total 20 minutes; demo is 25 minutes: 5 code, 10 static/RViz, 5 moving/time, 5 checkpoint. Ten hidden derivation slides are outside that schedule. Use the reference sheet for deeper study instead of trying to derive all conversions live. All seven existing Week 2 files were read. The separately supplied Robotics_AutonomousSystems.pdf was not found; retain its existing printed-slide references without claiming it was reviewed. Demo code, README, RViz and teaching notes remain unchanged.

Source: https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Tf2.html


### Why do coordinates need a frame? — 1 minutes

Visual: three labelled coordinate axes looking at one target. A frame is an origin plus axes; the target is unchanged, but its coordinates depend on that origin and basis. A camera can report a point without telling the arm where it is in robot coordinates. Ask what happens if the robot treats camera coordinates as base coordinates. Frame conversions connect sensor drivers, perception, localization and camera-guided motion. PointStamped carries both frame_id and observation time; an unlabelled three-number tuple is ambiguous. The illustration is conceptual, not a calibration of the demo camera. Do not confuse movement of a physical object with a change in its coordinate description.

Source: https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Tf2.html


### What are TF and tf2? — 1.5 minutes

Visual: frame, transform and tf2 cards. A coordinate frame defines an origin and three basis directions. A rigid transform gives rotation and translation between two frames. TF often refers to the ROS transform/frame system; tf2 is the library that tracks relationships over time, traverses paths, composes/inverts transforms and converts stamped data. It is not a localization or calibration algorithm: another component must supply estimated or measured relationships. The robot can have many frames and ROS nodes can publish different edges. Rigid transforms preserve distances and angles. Orientations may be stored as matrices, Euler angles or quaternions, while translation remains a separate quantity.

Source: https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Tf2.html


### Always check the conventions — 2 minutes

Visual: ROS body and optical axes plus a seven-item checklist. ROS body axes are x forward, y left, z up; optical axes are x right, y down, z forward. Both are right-handed. Metres and radians are ROS defaults; slide examples explicitly marked degrees are converted in code. Check axes/handedness, units, transform direction, fixed versus moving Euler axes and sequence, quaternion order, and row versus column vectors. This deck uses column vectors, right-handed rotations, Hamilton multiplication, fixed-axis XYZ RPY. Mathematical quaternion notation is (w,x,y,z); ROS message fields are (x,y,z,w). Parent/child is a tree relationship; target/source is the coordinate mapping requested from tf2. Different libraries and domains can use other conventions, so check their documentation; ROS has standards rather than arbitrary local choices. The demo camera_frame is simplified, not optical. Do not apply an optical correction to it without changing the actual model.

Source: https://github.com/ros-infrastructure/rep/blob/master/rep-0103.rst

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### Read the direction correctly — 1.5 minutes

Define ^A T_B as the pose of frame B expressed in A. It maps coordinates written in B into coordinates written in A. ^A t_B is the B origin in A; the columns of ^A R_B are B axes written in A. Formula: p_A=R_AB p_B+t_AB. Superscript denotes destination/reference; subscript denotes source frame for T and R. A tree arrow parent→child names an edge, while the stored pose maps child coordinates→parent coordinates. For ROS lookup_transform(target,source,time), target is the destination coordinate system. Moving the frame axes changes the point coordinates without moving the physical point. Reverse the coordinate map by inverting the whole rigid transform, including the rotated translation.

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Listener-Py.html

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp


### Matrix representation — 2 minutes

Visual: three editable elementary 3×3 matrices and an editable 4×4 homogeneous block matrix. Right-hand positive rotations determine the sine signs. Use Rz(+90°)e_x=e_y as an intuitive check. A proper rotation obeys RᵀR=I and det R=+1; its nine entries have only three independent orientation degrees of freedom. R alone transforms free direction vectors. A homogeneous point [p;1] includes translation; [d;0] excludes it. T combines R with t in one matrix and ends with row 0,0,0,1. Do not read every element aloud. Highlight the z matrix and point/direction distinction; the reference sheet has every formula. These 3-vector rules are not the general transformation law for six-component twists or wrenches.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp


### Compose and invert — 1.5 minutes

Visual: coordinate arrows C→B→A, then composition and inverse equations. T_AC=T_AB T_BC. Expanded composition is R_AC=R_AB R_BC and t_AC=R_AB t_BC+t_AB; translation from the inner frame must rotate before adding the outer translation. From p_A=Rp_B+t, subtract t, then multiply by Rᵀ. Therefore inverse translation is −Rᵀt, not simply −t. The inverse rotation is Rᵀ because a proper rotation is orthogonal. tf2 computes this chain automatically when frames are connected. The same rightmost-first ordering applies to Hamilton quaternion orientation composition. The static demo provides two edges whose composed camera-to-base result we will check later.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp

Source: https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Tf2.html


### Euler angles: order matters — 2 minutes

Visual: roll x, pitch y, yaw z cards followed by R=Rz(ψ)Ry(θ)Rx(φ). Fixed/extrinsic XYZ means rotate about the original unmoving x, y, then z axes; matrices act rightmost first on column vectors. The equivalent intrinsic description is moving-axis ZYX with angles ψ,θ,φ. Intrinsic XYZ is different. At +90° each, RzRx e_x=e_y but RxRz e_x=e_z. Angles are convenient to read but multiple tuples can represent the same orientation. At pitch ±90° the representation is singular: roll and yaw cannot be recovered separately. This is gimbal lock in coordinates, not loss of physical rotation. Other Euler sequences require their own ordered products and inverse formulas. Use the hidden slides for expanded matrix and extraction ranges rather than deriving them during the core.

Source: https://github.com/ros-infrastructure/rep/blob/master/rep-0103.rst

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### Quaternion representation — 2 minutes

Visual: unit axis k and half-angle formula with mathematical and ROS order cards. For rotation α about unit k, scalar-first Hamilton q=(cos(α/2),k sin(α/2)). Four numbers subject to unit norm leave three orientation degrees of freedom. q and −q represent the same orientation; they are not inverse orientations. Identity is mathematical (1,0,0,0), ROS (0,0,0,1); all-zero is invalid. Normalize nonzero numerical input. Quaternions avoid the Euler singularity and interpolate well, but still require a convention and a separate translation. The demo uses α=π/2, so z=sin(π/4),w=cos(π/4); x=y=0. Field order in a message does not change mathematical multiplication if components are explicitly mapped correctly.

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp


### Rotate with a quaternion — 1 minutes

Visual: pure quaternion (0,p) → quaternion sandwich → rotated vector → add t. Under Hamilton convention, (0,p_rot)=q⊗(0,p)⊗q⁻¹. The scalar output is zero; read its vector part. For unit q, inverse is conjugate (w,−x,−y,−z). For nonunit q the general inverse divides the conjugate by squared norm. Negating all four components gives an equivalent orientation, not the inverse operation. Then p_A=p_rot+t_AB. Orientation composition follows q_AC=q_AB⊗q_BC, matching matrix order. Libraries optimize this computation; students do not need to implement the sandwich in the demo. Complete component formulas and intermediate numerical products are in the reference sheet.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### One example, three representations — 1.5 minutes

Visual: matrix, Euler and quaternion cards converging on the same camera→base result. static_frames.py publishes base_link→camera_mount with identity rotation and +0.5 m z translation, then camera_mount→camera_frame with zero translation and +90° rotation about z. Camera point (0.2,0,1) rotates to (0,0.2,1), then becomes base point (0,0.2,1.5). Euler is roll=0,pitch=0,yaw=π/2. Mathematical q=(√2/2,0,0,√2/2); ROS fields=(0,0,√2/2,√2/2). All three forms require the same translation. Inverse: subtract (0,0,0.5), multiply by Rᵀ, recover (0.2,0,1). Direct and composed transforms agree. Exact identifiers and values come from demo/static_frames.py and demo/transform_point.py. The camera is simplified rather than optical. The reference sheet shows the full homogeneous matrix and intermediate quaternion products.

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### The frame tree — 1 minutes

Visual: world→base_link→camera_mount→camera_frame. Arrows here mean parent→child relationship, not coordinate mapping direction. moving_base publishes the dynamic world→base_link edge; static_frames publishes both static camera/base edges. A frame is not a node: one node can publish several frames and several nodes can collectively supply a tree. A child has one parent at a time; avoid cycles. Give each edge one authoritative broadcaster; conflicting broadcasters produce inconsistent data, not useful consensus. Multiple disconnected trees can exist, but lookup cannot cross roots without a connecting edge. Demo world is a generic reference; it does not implement REP 105 map/odom localization. The sensor-to-base chain remains static even when the base moves in world.

Source: https://docs.ros.org/en/jazzy/Concepts/Intermediate/About-Tf2.html

Source: https://github.com/ros-infrastructure/rep/blob/master/rep-0105.rst


### How tf2 works — 1 minutes

Visual: static_frames and moving_base feed /tf_static and /tf, then listener/buffer and lookup. StaticTransformBroadcaster uses durable static data suitable for late listeners; TransformBroadcaster streams dynamic samples. TransformStamped includes header.frame_id parent, child_frame_id child, timestamp, translation and quaternion. Several nodes can publish different edges. Each TransformListener populates its own Buffer; there is no central lookup server. DDS transports samples between endpoints; executor callbacks consume them and fill the buffer. Lookup then performs geometry and time selection locally. These responsibilities are distinct. In the scripts, point_transformer creates Buffer and TransformListener, receives data while spinning, and calls lookup in its timer. Static data is time-independent, but publisher lifetime matters for late discovery; leave the existing static script spinning.

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Static-Broadcaster-Py.html

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Listener-Py.html


### Transform at the measurement time — 1 minutes

Visual: acquisition time and current time on a timeline. Time() requests latest common usable transform, not necessarily now. Real observations need the transform at their acquisition timestamp when the chain is dynamic. The demo camera-to-base relationship is static, so latest lookup there is valid. moving_base adds time dependence only between world and base_link. transform_point.py restores the input stamp after do_transform_point, so RViz can convert both point messages into world at the same measurement time. The synthetic point stays fixed in camera coordinates and moves with the robot; a real world-fixed target would change its camera coordinates. History is finite; requests too old or newer than buffered dynamic samples raise extrapolation. Missing frames and disconnected paths fail too. Match clock sources and use_sim_time; bounded waiting/retry can allow data to arrive, while blocking the only executor thread may prevent listener callbacks. Existing code does not simulate delayed camera observations.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/src/cache.cpp

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Listener-Py.html


### Inspect and predict — 1 minutes

Visual: tf2_echo commands, lookup target/source labels and RViz fixed-frame badge. ros2 run tf2_ros tf2_echo base_link camera_frame shows camera pose in base, matching lookup_transform('base_link','camera_frame',Time()). Reverse arguments reverse the mapping. RViz starts Fixed Frame=base_link; switch to world after moving_base runs. The blue camera point and orange base point differ numerically but coincide physically. Start point_transformer before static_frames for a recoverable missing-frame warning: the timer catches TransformException, returns without blocking, and retries on later ticks while listener callbacks fill the buffer. Also inspect ros2 interface show geometry_msgs/msg/TransformStamped and topic endpoints using the existing README. The demo code publishes /point_camera and /point_base. Sources include the unchanged demo/README.md; classroom command execution is separate from deck generation checks.

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Debugging-Tf2-Problems.html

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Listener-Py.html


### Live demo: read, run, predict — 25 minutes

5 minutes CODE: read static_frames.py, transform_point.py, moving_base.py. Identify node names static_frames, point_transformer, moving_base; parent/child fields, ROS quaternion order, broadcaster types, Buffer/TransformListener, timer callbacks, spin and cleanup. Explain static latest lookup, TransformException recovery, do_transform_point and restored input stamp.
10 minutes STATIC/RVIZ: follow existing README commands unchanged. Source Jazzy and existing ROS_DOMAIN_ID=42/localhost setup in each terminal. Start point node before static broadcaster; observe recovery. Echo base_link camera_frame, open RViz with existing config, inspect point topics and message definition. Camera (0.2,0,1) becomes base (0,0.2,1.5); points overlap. Explain frame/node distinction and late-listener static data.
5 minutes MOVING/TIME: run moving_base.py, echo world base_link, switch RViz fixed frame to world. Yaw=0.2·elapsed radians; timer=0.1 s (10 Hz). Ask why world point moves but base coordinates stay constant. Synthetic point moves with camera. Explain measurement-time world conversion, unavailable history, clock mismatch and wait/retry; this is not a delayed-image demo.
5 minutes CHECKPOINT: select lookup target/source, predict inversion and rotation order, check optical/body axes and quaternion order, explain frames/transforms/tf2. Recap and questions. Keep hidden derivations outside this 45-minute session. Existing professor PDF reference retained, not reviewed.

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Writing-A-Tf2-Listener-Py.html

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Debugging-Tf2-Problems.html


### Expanded Euler rotation matrix — Hidden / untimed

Untimed backup. In these entries c and s mean full-angle cosine and sine, unlike the half-angle notation on the quaternion conversion slide. Derive by multiplying RyRx first, then premultiplying Rz. This is specifically fixed XYZ RPY, equivalent to intrinsic ZYX; different sequences require different products. All nine entries and elementary matrices appear in TF_MATH_REFERENCE.md. Test RᵀR=I and det R=1, then compare the expanded matrix to elementary-matrix multiplication and quaternion conversion. Avoid checking rounded display entries at very tight tolerance.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp


### Recover Euler angles — Hidden / untimed

Untimed backup. For fixed XYZ RPY use pitch=atan2(−r31,sqrt(r11²+r21²)), roll=atan2(r32,r33), yaw=atan2(r21,r11). Principal pitch lies in [−π/2,π/2], roll/yaw in (−π,π] with consistent boundary handling. At cos(pitch)≈0 set roll=0 and yaw=atan2(−r12,r22); pitch retains its atan2 value. At +90° only yaw−roll is identifiable; at −90° yaw+roll. Roll30/yaw45 at pitch+90 reconstructs with roll0/yaw15; at −90 reconstructs with roll0/yaw75. This is a coordinate singularity. Reconstruct and compare matrices rather than assuming Euler angles are unique. Reference sheet includes singular branch and examples.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp


### Quaternion → rotation matrix — Hidden / untimed

Untimed backup. The full editable matrix uses mathematical scalar-first q and column-vector right-hand rotations. Normalize nonzero q first; all-zero is invalid. Each entry is quadratic, so negating all four components preserves R. Check identity and ±90° rotations about each axis, then a mixed-axis example. Cross-check against independently multiplied elementary matrices. Orthogonality and determinant tests check that conversion yields SO(3), not merely a plausible set of entries. The scalar-first formulas must not be applied to a raw xyzw array without reordering named components. Reference sheet contains the complete formula.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### Stable matrix → quaternion — Hidden / untimed

Untimed backup. Compute aw=(1+r11+r22+r33)/4, ax=(1+r11−r22−r33)/4, ay=(1−r11+r22−r33)/4, az=(1−r11−r22+r33)/4. Choose largest, take positive square root, recover others, normalize. If w largest: x=(r32−r23)/(4w), y=(r13−r31)/(4w), z=(r21−r12)/(4w). If x largest: w=(r32−r23)/(4x), y=(r12+r21)/(4x), z=(r13+r31)/(4x). If y largest: w=(r13−r31)/(4y), x=(r12+r21)/(4y), z=(r23+r32)/(4y). If z largest: w=(r21−r12)/(4z), x=(r13+r31)/(4z), y=(r23+r32)/(4z). At 180° about x candidates=(0,1,0,0), q=(0,1,0,0). Validate R first; only clamp tiny negative roundoff. Avoid trace-only division by w near zero. q or −q may be returned; compare reconstructed R. All branches in reference.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp


### Roll–pitch–yaw → quaternion — Hidden / untimed

Untimed backup. Here cφ=cos(φ/2),sφ=sin(φ/2), and similarly θ,ψ. Derive scalar-first q=qz(ψ)⊗qy(θ)⊗qx(φ). Components: w=cφcθcψ+sφsθsψ; x=sφcθcψ−cφsθsψ; y=cφsθcψ+sφcθsψ; z=cφcθsψ−sφsθcψ. These are not universal for intrinsic XYZ or another Euler sequence. Convert radians correctly. Reverse: normalize quaternion, build R(q), recover Euler with singular handling. ROS message fields take x,y,z,w from these named components; message layout does not change this algebra. Reference sheet includes derivation and reverse conversion.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### Quaternion algebra — Hidden / untimed

Untimed backup. Product (w1,v1)⊗(w2,v2)=(w1w2−v1·v2,w1v2+w2v1+v1×v2). Expanded components and all signs are in the reference. Conjugate=(w,−v); general inverse=q*/norm², unit inverse=q*. Composition qAC=qAB⊗qBC follows matrix order. If q2=qrel⊗q1 with both in the same reference, relative qrel=q2⊗q1⁻¹. Negating all four entries gives an equivalent orientation, not inverse; conjugating changes orientation to inverse except special cases. Verify sandwich rotation against R(q), norm of product, inverse-to-identity and R(q)=R(−q).

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp

Source: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html


### Conventions change the formula — Hidden / untimed

Untimed backup. Active rotation physically rotates a vector in a fixed basis p'=Rp; passive basis change expresses the same vector in rotated axes, using inverse/transpose relative to that basis orientation. Define source/target explicitly. Row-vector form is p'ᵀ=pᵀRᵀ+tᵀ and homogeneous matrix Tᵀ; transposition reverses multiplication order. If pnew=S pold with same basis conversion both sides, Rnew=S Rold S⁻¹, tnew=S told. For distinct source/target changes Rnew=SA Rold SB⁻¹, tnew=SA told. A reflection changing handedness cannot itself be encoded by a unit quaternion. Fixed XYZ matches intrinsic ZYX with reversed angles; other sequences require ordered products appropriate to that convention. Reference section on conventions expands these cases.

Source: https://github.com/ros-infrastructure/rep/blob/master/rep-0103.rst


### ROS axes and common frames — Hidden / untimed

Untimed backup. REP103 body axes: x forward,y left,z up; optical: x right,y down,z forward. For aligned axes the coordinates convert p_opt=(−y_body,−z_body,x_body), using S=[[0,−1,0],[0,0,−1],[1,0,0]]. This is a convention example, not an extra edge in our simplified demo. REP105 map is a long-term world reference, typically drift-bounded but may jump after corrections; odom is continuous but can drift; base_link is attached to the robot. Common tree map→odom→base_link→sensor separates corrections from smooth odometry. Our world is generic and no localization node estimates map/odom. Names alone do not guarantee semantics: check the actual publisher and documentation.

Source: https://github.com/ros-infrastructure/rep/blob/master/rep-0103.rst

Source: https://github.com/ros-infrastructure/rep/blob/master/rep-0105.rst


### Interpolate time and orientation — Hidden / untimed

Untimed backup. With timestamps τ0,τ1 and τ between them, u=(τ−τ0)/(τ1−τ0). Translation interpolates linearly t(u)=(1−u)t0+ut1. For unit q0,q1, if their dot is negative replace q1 by its equivalent −q1. Clamp dot to [−1,1] before acos; Ω=acos(dot). SLERP uses sin((1−u)Ω)/sinΩ and sin(uΩ)/sinΩ weights. Near equality use normalized linear blending to avoid a small denominator. q1=−q0 represents no physical rotation after sign choice. Endpoints and norms should check correctly. tf2 interpolates buffered compatible dynamic samples; unavailable past/future still raises extrapolation and static edges remain constant. Interpolation is an approximation of motion, not arbitrary extrapolation. Reference includes full formula and sign discussion.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/src/cache.cpp

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp


### Worked mathematical checks — Hidden / untimed

Untimed backup. Mixed fixedXYZ RPY=(30°,−20°,45°) gives math q≈(0.861642,0.299673,−0.057422,0.405550); full R is on slide and in reference. Point (1,2,3) rotates to approximately (−0.369798,−0.041628,3.723106); adding (0.4,−0.2,0.7) gives (0.030202,−0.241628,4.423106). Inverse recovers original using unrounded values. Demo forward: (0.2,0,1)→(0,0.2,1.5) and back. Noncommuting +90° x/z rotations send e_x to e_y or e_z depending on order. Test identity, ±90° axes, mixed axes, direct/composed transform, RᵀR=I, det=1, unit quaternion, q/−q same matrix, largest-component conversion near/exact180°, singularEuler reconstruction and SLERP. Run validate_math.ps1. Classroom ROS/RViz execution is separate from these slide-generation/math checks.

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp

Source: https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp

## Deliverables and validation

- TF_COORDINATE_TRANSFORMS.pptx: 26 editable widescreen slides; 17–26 hidden; notes on every slide.
- TF_COORDINATE_TRANSFORMS.pdf: review copy including hidden references.
- TF_MATH_REFERENCE.md: complete formulas, all conversion branches, intermediate demo and mixed-axis calculations, convention caveats, time interpolation and sources.
- slides/content.ps1 and slides/build_slides.ps1: reproducible content and PowerPoint generation; slides/preview contains rendered slide images. slides/validate_math.ps1 independently checks numerical formulas.

Check demo forward (0.2,0,1)→(0,0.2,1.5), inverse recovery, direct/composed transforms; identity, ±90° axes, mixed axes, SO(3), quaternion norm and sign equivalence, stable near/exact180° conversion, Euler singular recovery and SLERP. Render all slides in installed PowerPoint, inspect legibility and layout, reopen saved deck, verify notes/hidden states/timing and PDF page count. Compare protected-file hashes. Artifact checks are separate from classroom ROS/RViz rehearsal; this local Windows slide-generation machine has no ROS installation.
