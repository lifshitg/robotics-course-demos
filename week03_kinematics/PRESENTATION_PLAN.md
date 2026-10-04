# Week 3 — Gazebo, ROS, and Kinematics

Gazebo is the main subject: what simulation gives us, why Gazebo fits the course, and how its configuration and ROS bridge support the existing workflow. FK/IK are brief visual practice, not the main lecture. Audience has Python familiarity and Weeks 1–2 ROS/TF basics.

**20 minutes explanation + 25 minutes demo/questions = 45 minutes.** Title is untimed; twelve teaching slides, demo transition and four hidden backups give 18 slides overall. Incorporate the former separate recap into the workflow and model sketch. Use the Weeks 1–2 light background, blue/teal palette, sparse prose, editable diagrams/equations, body text at least 24 pt, and detailed speaker notes with sources.

Baseline: ROS 2 Jazzy and Gazebo Harmonic (Gazebo Sim 8). Preserve teaching notes and every demo file. All twelve existing Week 3 files were read; no separate professor Week 3 lecture was supplied. Existing TA_plan.md Session 3, HW1 and HW3 connections remain relevant. Use the existing captured screenshot honestly as an illustration of a bent arm pose; a new launch begins at zero angles.

## Presentation sequence and speaker guidance

### Gazebo, ROS & kinematics — Untimed title

Untimed title. Gazebo is the main subject; kinematics is the practice task. Audience has used ROS topics and tf2 in Weeks 1 and 2 and knows Python. Explain for 20 minutes, then run the existing 25-minute demo: 8 interface/model/joints, 10 target and IK branches, 7 unreachable target and checkpoint. Four hidden backups are untimed. We incorporate the former five-minute recap into the workflow and frame sketch rather than adding it to the schedule. Gazebo Harmonic (Gazebo Sim 8), ROS 2 Jazzy. All twelve existing Week 3 files were read, including the labelled SVG screenshot. Existing demo and teaching notes remain unchanged. No separate professor Week 3 lecture was supplied; TA_plan.md Session 3 is the course connection. Keep the slides brief; use notes for technical detail.

Source: https://gazebosim.org/docs/harmonic/getstarted/


### What is Gazebo? — Teaching 1 / 1.5 minutes

Visual: the existing real screenshot of the planar_arm demo beside world/model/physics/time labels. The screenshot illustrates a bent pose; a fresh launch starts at zero angles. Gazebo runs a world containing robot models, environment, physics and optional simulated sensors. It numerically advances modeled state in time steps, such as positions and velocities; controllers and sensors can operate on that state. Rendering helps us inspect what happens but is not the physics computation itself: headless simulation still runs. Our world has ground and light, a fixed-base arm and joint feedback. Gazebo supports cameras and other sensors, but this demo has no camera sensor. The GUI camera merely changes the viewpoint. Kinematics predicts geometry for given joint angles; simulation also produces the time evolution under the configured controllers and physics. Do not equate a visual 3D robot model with a complete realistic model of hardware.

Source: https://gazebosim.org/docs/harmonic/getstarted/

Source: https://gazebosim.org/docs/harmonic/sdf_worlds/


### Why simulate robots? — Teaching 2 / 2 minutes

Visual: four benefit cards: develop before hardware, repeat a setup, try commands, inspect measurements. Simulation lets us develop robot software before hardware is ready and compare experiments from a known initial configuration. A virtual robot can exercise software and command choices without moving a physical robot. We can inspect modeled joints, frames and time more easily than many real systems. This supports HW1 and mathematical HW3 exercises. Explain the limits with one sentence: results depend on geometry, mass/inertia, contact, actuator and sensor models, so verify later on hardware. Avoid claiming simulation guarantees safety or perfectly reproduces reality. For reproducibility in this demo, use the documented full restart; the GUI reset alone does not restart ROS nodes or guarantee controller targets/history are cleared. Repeated runs may vary numerically; compare within appropriate tolerances rather than expecting bitwise identical output.

Source: https://gazebosim.org/docs/harmonic/getstarted/


### Why Gazebo fits this course — Teaching 3 / 1.5 minutes

Visual: ROS integration, configurable models, reusable systems, GUI/headless cards. ros_gz provides ROS launch/model spawning and a message bridge. URDF expresses our robot; SDF expresses its world; YAML defines the topic mapping; gui.config prepares the view. Existing Gazebo systems provide physics, spawning, rendering updates, joint control and joint measurements. We configure them rather than write a simulator. GUI helps students see the robot, while headless mode supports preparation and automated checks. The launch file orchestrates these pieces in one command and resolves local model paths; this demo needs no package build or external model download. This makes Gazebo useful for our lesson, not universally the simplest simulator or a claim that ROS and Gazebo automatically share all messages. Supported bridge message types, explicit mapping and consistent runtime settings still matter. Use Harmonic-specific commands rather than Gazebo Classic instructions.

Source: https://gazebosim.org/docs/harmonic/ros2_integration/

Source: https://gazebosim.org/docs/harmonic/sdf_worlds/

Source: https://gazebosim.org/docs/harmonic/spawn_urdf/


### Gazebo, ROS, and RViz — Teaching 4 / 1.5 minutes

Visual: three cards joined by labelled data arrows. Gazebo computes simulated motion and measurements. ROS nodes communicate and run application logic, such as analytical IK and command validation. RViz visualizes ROS data including frames and robot state; it does not run the Gazebo physics simulation. RViz is optional and is not launched by our Week 3 demo. A Gazebo model is not automatically a ROS node. Our bridge translates between ROS 2 topics and Gazebo Transport messages. robot_state_publisher combines the URDF with measured JointState angles to publish TF; it neither controls the robot nor solves IK. Students can inspect this data using ROS CLI and tf2_echo without RViz. Reuse Week 1 typed communication and Week 2 frames as reminders here, avoiding a separate lengthy recap.

Source: https://gazebosim.org/docs/harmonic/ros2_integration/

Source: https://github.com/ros/robot_state_publisher/blob/jazzy/README.md


### The ROS–Gazebo bridge — Teaching 5 / 2.5 minutes

Visual: ROS command node ↔ ros_gz_bridge ↔ Gazebo controllers/measurements, with separately directed arrows. command_arm publishes /arm/joint1/cmd_pos and /arm/joint2/cmd_pos: ROS std_msgs/msg/Float64 → Gazebo gz.msgs.Double, direction ROS_TO_GZ. Gazebo /arm/joint_states (gz.msgs.Model) → ROS /joint_states (sensor_msgs/msg/JointState), GZ_TO_ROS. Gazebo /world/kinematics/clock (gz.msgs.Clock) → ROS /clock (rosgraph_msgs/msg/Clock), GZ_TO_ROS. These are four explicit mappings in bridge.yaml; selected channels collectively allow communication in both directions, rather than making every topic bidirectional. The bridge handles supported message conversions and naming, not physics, IK or frame transformation. Below the bridge, show /joint_states → robot_state_publisher + URDF → TF. Measured joints must drive this chain, not the requested angles. ROS use_sim_time reads the bridged clock. ROS_DOMAIN_ID and GZ_PARTITION isolate separate communication systems; their roles are distinct. Exact settings and detailed type names belong in notes/code walkthrough.

Source: https://gazebosim.org/docs/harmonic/ros2_integration/

Source: https://github.com/ros/robot_state_publisher/blob/jazzy/README.md


### The workflow — Teaching 6 / 2 minutes

Visual: six editable numbered steps arranged in two rows, with the existing file role beside each. Describe robot/world using arm.urdf and world.sdf. demo.launch.py starts Gazebo and spawns planar_arm using ros_gz_sim/create; it also starts parameter_bridge and robot_state_publisher. bridge.yaml explicitly connects commands, measured joints and clock. command_arm.py accepts joint targets or calls kinematics.py for IK. Inspect /joint_states and tf2_echo base_link end_effector, then compare measured-state FK with the target. Launch orchestrates processes; it does not calculate IK. gui.config changes the view, not the mathematics. Recap: Week 1 gave us typed topics; Week 2 gave us frame chains; now joint measurements update those frames. Follow existing README setup: source Jazzy, ROS_DOMAIN_ID=42, ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST, GZ_PARTITION=robotics_week03. No installation instructions need to occupy the slide. Use one launch session; duplicate simulators can produce confusing feedback.

Source: https://gazebosim.org/docs/harmonic/spawn_urdf/

Source: https://gazebosim.org/docs/harmonic/ros2_integration/

Source: https://github.com/ros/robot_state_publisher/blob/jazzy/README.md


### Configure robot and world — Teaching 7 / 2 minutes

Visual: three short editable excerpts from the actual robot, world and bridge configuration. URDF contains links, parent/child joint origins, axes, limits, visuals, collisions and inertias. A link frame is not its visual center: link1 frame is at the shoulder, while its box center is x=0.3 m. joint2 is at x=0.6 m in link1 and rotates about 0 0 1. SDF world kinematics contains gravity 0 0 −9.81, 0.001 s maximum physics step, ground, light, and physics/spawning/scene systems. Configuring max_step_size does not guarantee a wall-clock rate. bridge.yaml records names, types and direction, e.g. ROS_TO_GZ for one joint target. Gazebo converts the URDF during spawning, including configured simulation plugins. Both controllers use velocity-command mode capped at 1 rad/s, an idealized control model rather than realistic motors. Self-collision is disabled. Do not claim changing visual geometry alone changes link-frame origins or the analytical link length.

Source: https://gazebosim.org/docs/harmonic/spawn_urdf/

Source: https://gazebosim.org/docs/harmonic/sdf_worlds/

Source: https://gazebosim.org/docs/harmonic/ros2_integration/


### Read the simulation — Teaching 8 / 1.5 minutes

Visual: full screenshot with editable callouts for 3D view/robot, entity tree, play/pause/reset and clock statistics. The screenshot comes from the existing gazebo_overview.svg; its layout can vary by desktop/window size. Pan, orbit and zoom change the viewpoint, not joint angles. Pause stops simulation time and motion; wall time continues. Expand the lower-right chevron to show simulation time, real time and real-time factor. A real-time factor below one means simulation advances more slowly than wall time; this is performance, not an FK error. GUI reset changes simulator state/time, not the whole ROS application. Use full restart for a reproducible baseline. Our ROS nodes use simulation time, but command_arm uses time.monotonic for its 10-second deadline and 10 Hz command scheduling so a paused/missing simulation can time out. Resume before demonstrating motion. Do not present the viewport camera as a simulated camera sensor.

Source: https://gazebosim.org/docs/harmonic/gui/


### Our two-joint arm — Teaching 9 / 1 minutes

Visual: existing simulation screenshot close-up beside an editable top-view sketch with the blue first link (0.6 m), orange second link (0.4 m), green tool and x/y base axes. The screenshot and illustrative sketch show a bent pose; launch begins at q1=q2=0. Joint1 is shoulder angle q1; q2 is elbow rotation relative to link1, so link2 absolute orientation is q1+q2. Positive angles use the right-hand rule about +z. Arm motion is planar in base xy, positions in metres, angles in radians. Frame chain: base_link→link1→link2→end_effector. The fixed world_anchor places base_link 0.25 m above world: tool z=0 in base and z=0.25 in world. Joint limits are [−π,π]. The target interface constrains xy position only, not tool orientation. Do not mistake the box center for the joint frame.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Forward kinematics — Teaching 10 / 1.5 minutes

Visual: blue/orange arm sketch beside two large editable equations. x=L1 cos(q1)+L2 cos(q1+q2); y=L1 sin(q1)+L2 sin(q1+q2). Each link contributes its projected vector; q2 is relative, so the second vector uses q1+q2. Briefly explain the sum of vectors rather than derive the full transform product in the main lesson. At zero angles position=(1,0). At (q1,q2)=(0,π/2), link1 contributes (0.6,0), link2 contributes (0,0.4), total=(0.6,0.4). Ask students to predict before commanding. Tool orientation is q1+q2. These predictions specify geometry, not the motion duration, controller response or measured convergence. Exact equations are in kinematics.forward; transform-based derivation is a hidden backup. L1=0.6 m,L2=0.4 m; keep radians explicit.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Inverse kinematics — Teaching 11 / 1.5 minutes

Visual: two editable arm configurations converging on target (0.6,0.4), plus three compact formula lines. c2=(x²+y²−L1²−L2²)/(2L1L2); q2=±acos(c2); q1=atan2(y,x)−atan2(L2 sin(q2),L1+L2 cos(q2)). Briefly point out the two signs, without live derivation. Positive/negative refer exactly to the sign of q2, avoiding convention-dependent elbow-up/down names. Positive branch=(0,1.570796); negative≈(1.176005,−1.570796). Both reach the same xy point but tool orientations differ: about 1.570796 rad and −0.394791 rad. This interface solves position only. At singular boundaries the geometric branches merge (up to angle wrapping), and not every target is reachable. The existing code checks finite values, radius and joint limits, clamps only numerical boundary roundoff, and normalizes q1 with atan2(sin(q1),cos(q1)). Show where the equations appear in inverse during the demo. Hidden backup derives the cosine rule.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Verify what happened — Teaching 12 / 1.5 minutes

Visual: workspace annulus and measurement→FK/TF→position error path. Geometric radius range is |L1−L2|≤r≤L1+L2: 0.2–1.0 m. (1.2,0) is too far and (0,0) lies in the inner hole. Limits also matter. command_arm requests joint positions, receives simulated measured JointState values and applies FK to those measured angles. Compare with tf2_echo base_link end_effector: translations should approach (0.6,0.4,0). Success checks both joint errors <0.01 rad and Cartesian position error <0.01 m. Representative measured values vary with timing; do not claim publishing a target proves it was reached. TF and measured-state FK both depend on the model/measured joints, so agreement does not independently validate physical calibration or real hardware. Idealized control is capped at 1 rad/s and self-collision is disabled. An IK position solution is not a collision-free path; Week 4 covers motion planning. Full extension/folding are singular; deeper geometry is in backups.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf

Source: https://github.com/ros/robot_state_publisher/blob/jazzy/README.md

Source: https://gazebosim.org/api/sim/8/classgz_1_1sim_1_1systems_1_1JointPositionController.html


### Live demo: predict, command, inspect — Demo / 25 minutes

8 minutes INTERFACE/MODEL/JOINTS: launch using existing README before the session. Identify world, planar_arm, camera controls, clock and play/pause. Pause/resume once; show joint2 origin/axis in URDF. Command zero, then q1=0.5,q2=0, then q1=0,q2=π/2. Explain bridge channels and simulation-time versus wall-time behavior as you inspect the files.
10 minutes TARGET/BRANCHES: predict (0.6,0.4) before executing. Read the short FK/IK functions in kinematics.py, show command validation/measurement handling in command_arm.py, then run target --x 0.6 --y 0.4 --branch positive and --branch negative. Observe two configurations with the same tool xy and different orientation. Inspect /joint_states and tf2_echo base_link end_effector; compare measured-state FK and position error. Actual measured values depend on settling/timing. No RViz is required.
7 minutes REJECTION/CHECKPOINT: target --x 1.2 --y 0 is rejected before ROS publishers are created; the previous target remains active. Mention the unreachable inner hole too. Ask: what does Gazebo simulate, what does the bridge translate, why q1+q2, why two branches, and why measurements matter? IK does not avoid obstacles. Recap simulation and workflow. Use screenshot/expected output as fallback, or headless mode if GUI unavailable.
Follow existing README exactly for paths and setup: ROS_DOMAIN_ID=42, local ROS discovery, GZ_PARTITION=robotics_week03. GUI reset is not a complete ROS restart. Stop tools and Ctrl+C the launch terminal for full restart/shutdown; interrupting a command tool does not cancel a target already sent. Artifact validation does not claim a fresh classroom ROS/Gazebo rehearsal on this Windows machine.

Source: https://gazebosim.org/docs/harmonic/ros2_integration/

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Forward kinematics as transforms — Hidden / untimed

Untimed backup. R is a 3×3 rotation matrix: orientation of source axes expressed in destination coordinates. t is a 3×1 translation: source origin expressed in destination coordinates. T=[R t;0 1] combines them as a 4×4 rigid transform. Rz(q)=[[cosq,−sinq,0],[sinq,cosq,0],[0,0,1]]. For this model, base→link1 has Rz(q1),t=0; link1→link2 has Rz(q2),t=(L1,0,0); link2→tool has R=I,t=(L2,0,0). Thus T_base_tool=RotZ(q1) TransX(L1) RotZ(q2) TransX(L2). Product order matters; rightmost acts first on column vectors. Translation is Rz(q1)(L1,0,0)+Rz(q1+q2)(L2,0,0), which yields the two FK equations. The final homogeneous matrix is [[cos(q1+q2),−sin(q1+q2),0,x],[sin(q1+q2),cos(q1+q2),0,y],[0,0,1,0],[0,0,0,1]]. This is in base_link; world transform adds z=0.25. The frame-tree arrow names parent→child, while the stored pose maps child coordinates→parent. Matrices compose by multiplication, not addition; only the separately projected link displacement vectors are added.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Derive the inverse kinematics — Hidden / untimed

Untimed backup. Let r²=x²+y². Taking the norm of the link-vector sum gives r²=L1²+L2²+2L1L2 cos(q2), because q2 is the angle between the two link displacement directions. Equivalently the triangle interior elbow angle is π−q2, which changes the cosine-rule sign. Solve c2=(r²−L1²−L2²)/(2L1L2). Select q2=±acos(c2). Let β=atan2(y,x) and γ=atan2(L2 sin(q2),L1+L2 cos(q2)); then q1=β−γ. atan2 handles quadrants; do not replace it by atan(y/x). For target (.6,.4), r²=.52,L1²+L2²=.52,2L1L2=.48,c2=0. β≈.588002604. Positive γ=β gives q1=0,q2=π/2. Negative γ=−β gives q1≈1.176005207,q2=−π/2. Substitute each into FK to verify the same point. Tool orientations are π/2 and about −.394791120 rad. Other robots need different IK formulations; these analytical equations are specific to this planar two-revolute-joint model. Code wraps q1 into the principal range and checks limits.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Workspace and singular boundaries — Hidden / untimed

Untimed backup. Triangle inequality gives .2≤r≤1 for lengths .6,.4 with this model's full [−π,π] joint ranges. Generic narrower joint limits can further restrict the workspace. Full extension q2=0 reaches outer radius1; folding q2=±π reaches inner radius.2. Both branches describe the same physical configuration at these boundaries up to angle representation. The planar position Jacobian is J=[[-L1 sin(q1)−L2 sin(q1+q2),−L2 sin(q1+q2)],[L1 cos(q1)+L2 cos(q1+q2),L2 cos(q1+q2)]]. Its determinant is L1L2 sin(q2), zero at extension/folding: an instantaneous Cartesian direction is lost. Avoid a long Jacobian derivation; this is optional. Reject finite targets outside the annulus before publishing; clamp tiny floating-point deviations only after geometric checking. (1.2,0) and (0,0) are rejected. Self-collision is disabled and no obstacles are checked by inverse(), so an IK solution does not validate the trajectory. Motion planning is Week 4.

Source: Existing course demo: demo/kinematics.py, demo/test_kinematics.py, and demo/arm.urdf


### Bridge and configuration checks — Hidden / untimed

Untimed backup. No model: inspect Gazebo physics/user-command systems and ros_gz_sim create output. No motion: check play/pause, ROS domain/Gazebo partition, command bridge and controller configuration. Missing measurements: inspect /joint_states and its mapping from Gazebo /arm/joint_states; command publications are not measurements. Missing TF: inspect robot_state_publisher, URDF and JointState joint names. Clock: Gazebo /world/kinematics/clock→ROS /clock and use_sim_time. A slow real-time factor can trigger the 10 wall-clock-second command deadline; headless mode may help. ROS_DOMAIN_ID=42 and GZ_PARTITION=robotics_week03 are different isolation mechanisms, not matching numeric domains. Bridge message types must be supported and directions/names correct. Launch starts Gazebo, bridge, state publisher and spawn; gui.config is only view configuration. Duplicate launches can mix feedback. GUI reset does not guarantee clearing ROS/controller state. Full restart restores initial pose. Interrupting command_arm does not cancel a target Gazebo has received. Snap library workaround belongs in unchanged demo README, not teaching slide text. Headless mode runs the same physics/model and measurement checks without rendering.

Source: https://gazebosim.org/docs/harmonic/ros2_integration/

Source: https://github.com/ros/robot_state_publisher/blob/jazzy/README.md

## Deliverables and validation

GAZEBO_AND_KINEMATICS.pptx contains 18 editable widescreen slides, notes on every slide, four hidden backups (slides 15–18). The PDF includes all 18 slides. Reproducible source content, PowerPoint generator, mathematical validation, rendered previews, and inspection results are under slides/.

Validate link lengths/axes/limits against URDF; bridge names/types/directions against bridge.yaml; FK zero and worked examples; both IK branches and orientations; FK/IK round trips, geometric workspace boundaries, rejected targets, transform-product agreement, and singular Jacobian determinant. Reopen the saved deck in PowerPoint, verify notes/hidden states/timing, count PDF pages, inspect every slide preview, and check actual text bounds. Compare hashes for all eleven protected files. Numeric/artifact checks do not claim a new classroom ROS/Gazebo rehearsal on this Windows slide-generation machine. Follow the unchanged README on the Jazzy/Harmonic teaching machine for that rehearsal.
