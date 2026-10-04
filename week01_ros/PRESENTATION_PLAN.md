# Week 1 — ROS Basics Presentation Plan

## Session Goal and Timing

Teach the basics of ROS: what it provides, where it is used, its components and
communication patterns, and how ROS 2 implements them. The Python demo is a concrete
example of these concepts, followed by a live code walkthrough.

Assume Python familiarity and little networking knowledge. Use ROS 2 Jazzy and the
existing localhost/domain setup in the [demo instructions](demo/README.md).

| Part | Minutes |
| --- | ---: |
| Slides 1–10: explanation, including motivation and context | 25 |
| Read the two Python scripts | 7 |
| Run and inspect the system | 6 |
| Stop/restart experiments | 4 |
| Questions and recap | 3 |
| **Total** | **45** |

Backup slides are outside this schedule. Keep their details available for questions.

## Slide 1 — What Is ROS? (2 minutes)

**Purpose:** Establish what students are learning and why it exists.

- ROS means **Robot Operating System**: a software framework for building robotics
  applications that runs on an operating system such as Linux.
- It supplies communication libraries, development/debugging tools, and an ecosystem
  of reusable packages, including drivers and robotics algorithms.
- Robotics software combines components written by different people, often in different
  languages and running on different computers. ROS supplies common interfaces to connect them.

**Visual:** Three layers: robot application; ROS libraries/tools/packages; host OS/hardware.

**Speaker guidance:** Start with “How do a camera, a planner, and a motor driver share
information?” Define middleware as software handling communication between application
components. Explain the purpose before introducing API names.

**Demo connection:** Python supplies the application logic; `rclpy` supplies ROS
interfaces; `std_msgs` supplies the message definition.

**Reference:** [Official ROS 2 overview](https://github.com/ros2/ros2_documentation/blob/jazzy/source/index.rst).

## Slide 2 — What Is ROS Used For? (2 minutes)

**Purpose:** Connect the framework to complete robots and industrial applications.

- Example robot: sensor drivers → perception/localization → planning → control →
  actuator drivers. Localization also consumes motion feedback from the robot.
- Teams can integrate modules, inspect data, and reuse existing drivers and algorithms.
- Compatible interfaces allow simulated sensors/actuators to replace hardware during
  development. Physical behavior and timing still need validation on the robot.
- Industry examples: ROS-Industrial's work with BMW and Microsoft on logistics
  interoperability, and robotic blending/scan-and-plan work for foundries. These are
  documented ROS ecosystem applications; do not assume all use the same ROS generation.

**Visual:** Robot software graph with sensor inputs, actuator outputs, and an alternative
simulation boundary. Place the industrial examples beside the graph.

**Speaker guidance:** Explain the benefit: interoperability for logistics; perception
linked to motion planning for manufacturing. ROS adoption alone does not make a system
safety certified or guarantee hard real-time control; these require system-level design.

**Demo connection:** The greeting producer and consumer represent two software modules;
a real sensor publishes structured measurements rather than greetings.

**Reference:** [ROS-Industrial applications and project overview](https://rosindustrial.org/).

## Slide 3 — ROS History: ROS 1 and ROS 2 (3 minutes)

**Purpose:** Explain the redesign and establish which ROS students will use.

- ROS development began in 2007 around Willow Garage's PR2 research platform.
- ROS 2 addressed broader needs: multiple robots, embedded computers, unreliable
  networks, production deployments, and more controlled execution.
- ROS 2's first non-beta distribution was Ardent Apalone in 2017.
- ROS 1's final official distribution, Noetic, reached end of life on May 31, 2025.
  Existing ROS 1 systems remain, but this course uses ROS 2.
- ROS 1/ROS 2 are framework generations; Jazzy is a ROS 2 distribution bundling
  compatible package versions. Jazzy is the demo baseline, not a claim about the newest release.

| Aspect | ROS 1 | ROS 2 |
| --- | --- | --- |
| Discovery | Nodes register with a ROS master | DDS-based discovery in the course setup; no ROS master |
| Topic transport | Custom protocols, commonly TCPROS | Replaceable RMW layer; DDS/RTPS in this explanation |
| Delivery policies | More limited options, including latching | Configurable QoS, including reliability/durability |
| Node management | Application-specific coordination | Standard managed lifecycle interface available |
| Application libraries | `rospy`, `roscpp` | `rclpy`, `rclcpp` |

**Visual:** Timeline and comparison table. In a ROS 1 sketch, distinguish master discovery
arrows from a direct data arrow between nodes.

**Speaker guidance:** The ROS 1 master helps endpoints find each other; it does not
relay every topic message. ROS 2 changes APIs/infrastructure while retaining concepts
such as nodes and topics. Real-time capability depends on the full system.

**Demo connection:** The scripts import `rclpy`; there is no `roscore` startup step.

**References:** [Origins and redesign motivations](https://design.ros2.org/articles/why_ros2.html),
[Ardent release](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Releases/Release-Ardent-Apalone.rst),
[distribution dates](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Releases.rst),
[official ROS 1 end-of-life announcement](https://discourse.ros.org/t/ros-noetic-end-of-life-may-31-2025/43160).

## Slide 4 — Nodes and the ROS Graph (2 minutes)

**Purpose:** Explain how a robot application is decomposed.

- A **node** is a logical component with a responsibility: camera driver, localization,
  planner, or motor interface. It creates communication endpoints and performs work.
- A **process** is a running OS program. One process can contain multiple ROS nodes;
  this demo runs one node per Python process.
- The **ROS graph** describes nodes and communication connections. Names and namespaces
  help identify components. Our nodes are `/greeting_publisher` and `/greeting_subscriber`.

**Visual:** Two process boxes containing the demo nodes; beside them, one process
containing two nodes to distinguish the concepts.

**Speaker guidance:** Point to `super().__init__('greeting_publisher')`. The class name,
script filename, and ROS node name are different identifiers.

**Demo connection:** `ros2 node list` reports graph names, not Python class names.

**Reference:** [ROS 2 nodes](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Nodes.rst).

## Slide 5 — Topics, Messages, Publishers, and Subscribers (3 minutes)

**Purpose:** Teach the communication pattern used in the demo.

- A **topic** names a channel carrying data of a defined message type.
- A **publisher** sends messages; a **subscription** receives them and registers a
  callback. Multiple publishers and subscribers can use the same topic.
- Endpoints need the same resolved topic name, compatible type, and compatible QoS.
  A shared name alone is insufficient.
- Message definitions describe fields; generated language bindings let Python and
  C++ code use the same interface.

```text
/greeting_publisher → /chatter (std_msgs/msg/String) → /greeting_subscriber

Definition: string data       Python: message = String()
                                     message.data = 'Hello, robotics! Message 0'
```

**Visual:** The diagram above with a second subscriber branch; show the field definition
beside the Python assignment.

**Speaker guidance:** A topic is a name and contract, not a separate broker process or
storage service. `String` keeps the example small; actual sensors use richer types.

**Demo connection:** Both constructors use `String` and `/chatter`. Show the definition
with `ros2 interface show std_msgs/msg/String` live.

**Reference:** [Interface definitions](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Interfaces.rst).

## Slide 6 — Services, Actions, and Parameters (2 minutes)

**Purpose:** Choose the right interface for a task.

| Concept | Interaction | Example |
| --- | --- | --- |
| Topic | Stream of typed messages | Sensor readings |
| Service | Client request → server response | Reset odometry and return success |
| Action | Goal → feedback → result; cancellation can be requested | Navigate to a waypoint |
| Parameter | Named, typed configuration belonging to a node | Sensor exposure or frame name |

- `.srv` defines request and response separated by `---`; `.action` defines goal,
  result, and feedback. Cancellation is handled by the server and need not be immediate.
- ROS 2 parameters belong to nodes, rather than a ROS 1-style global parameter server.
  Whether a parameter can change at runtime depends on the node.

**Visual:** Three communication diagrams plus a configuration box attached to a node.

**Speaker guidance:** Ask which pattern fits camera frames, reset, and drive to a goal.

**Demo connection:** These scripts exercise topics. Their interval and greeting are
hardcoded; they have not been exposed as custom parameters.

**References:** [Interfaces](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Interfaces.rst),
[parameters](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Parameters.rst).

## Slide 7 — ROS 2 Architecture and DDS (4 minutes)

**Purpose:** Explain what sits underneath the ROS API.

```text
Application: GreetingPublisher / GreetingSubscriber
                      ↓
Client library: rclpy (Python) / rclcpp (C++)
                      ↓
rcl: shared C client-library core
                      ↓
rmw: ROS middleware interface and selected adapter
                      ↓
DDS implementation: for example Fast DDS or Cyclone DDS
                      ↓
Transport: for example UDP/IP; local delivery may use shared memory
```

- **DDS (Data Distribution Service)** is industry-standard middleware for typed
  publish/subscribe exchange. ROS supplies robotics-facing APIs above it.
- A **DomainParticipant** joins a DDS domain. **DataWriters** and **DataReaders** are
  sending/receiving endpoints underlying topic communication. ROS nodes do not
  necessarily map one-to-one to DDS participants.
- **Discovery:** participants find one another and exchange endpoint information.
  Compatible topic/type/QoS endpoints match, then exchange application data.
- **Serialization:** convert fields into bytes for transport; deserialize on receipt.
- **RTPS** is the interoperability wire protocol used by DDS implementations. DDS
  describes middleware behavior/API; RTPS describes protocol-level communication.
- RMW allows different middleware implementations. Use DDS for this Jazzy explanation
  without claiming every ROS 2 deployment must use DDS.

**Visual:** Layer stack plus two peers with dashed discovery and solid data arrows.
Label their writer/reader; do not insert a central topic broker.

**Speaker guidance:** Introduce terms one at a time. `ROS_DOMAIN_ID=42` groups the demo's
participants; `LOCALHOST` restricts discovery to this machine. The same domain is
necessary here, but topic/type/QoS and network checks still matter. A domain ID does
not authenticate participants.

**Demo connection:** `publish(message)` enters the stack without application socket
code. Middleware receives data; the executor schedules the Python callback.

**References:** [Middleware interface](https://design.ros2.org/articles/ros_middleware_interface.html),
[client libraries](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Client-Libraries.rst),
[DDS implementations and RTPS](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Intermediate/About-Different-Middleware-Vendors.rst).

## Slide 8 — QoS Basics (2 minutes)

**Purpose:** Explain why delivery behavior is configurable.

| Policy | Meaning | Demo setting |
| --- | --- | --- |
| Reliability | Best effort may lose samples; reliable delivery retries as needed | Reliable |
| Durability | Volatile serves current readers; transient local can retain samples for late joiners | Volatile |
| History/depth | KEEP_LAST retains up to a configured sample count per endpoint history | KEEP_LAST, depth 10 |

- Passing `10` to the `rclpy` constructors sets depth with other policies at their
  defaults. `create_timer(1.0, ...)` sets a one-second interval.
- Restarting the subscriber gives new greetings after matching, not replay of all
  missed greetings. Depth 10 does not change volatile durability.
- QoS must be compatible: a best-effort publisher cannot satisfy a reader requesting reliable delivery.

**Visual:** Bounded history beside a timeline marking subscriber stop/restart.

**Speaker guidance:** Distinguish history, late joining, and reliability. Reliable
transport does not guarantee callback processing by a deadline.

**Demo connection:** Inspect QoS with `ros2 topic info /chatter --verbose`.

**References:** [QoS policies](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Intermediate/About-Quality-of-Service-Settings.rst),
[rclpy endpoint depth handling](https://github.com/ros2/rclpy/blob/jazzy/rclpy/rclpy/node.py).

## Slide 9 — How Nodes Execute and Shut Down (3 minutes)

**Purpose:** Connect ROS concepts to execution and lifecycle management.

```text
rclpy.init() → construct node/endpoints/timer → rclpy.spin(node)
                                                   ↓
                               Ctrl+C / context shutdown
                                                   ↓
                             destroy_node() → try_shutdown()
```

- An **executor** waits for ready work and runs callbacks. These scripts use the
  default single-threaded executor through `rclpy.spin(node)`.
- Publisher: timer ready → `publish_greeting` → construct/fill `String` → publish.
  Subscriber: data available → executor takes message → `receive_greeting` → log.
- The timer sets an intended period, not a hard deadline. A long callback delays
  other work on that single-threaded executor. Middleware receipt and callback
  execution are separate stages.
- The scripts catch keyboard/external shutdown and clean up in `finally`, releasing
  node resources and shutting down the context if needed.
- **Managed lifecycle** adds explicit states: Unconfigured, Inactive, Active, Finalized.
  Configure prepares resources; activate enables managed operation; deactivate pauses
  it; cleanup releases configured resources; shutdown reaches Finalized.
- Example: configure a camera, verify readiness, then activate downstream processing.
  A supervisor coordinates dependencies; the state machine does not do that alone.

**Visual:** Runtime flow beside `Unconfigured --configure--> Inactive --activate--> Active`;
add deactivate back to Inactive, cleanup back to Unconfigured, and shutdown to Finalized.

**Speaker guidance:** These scripts inherit ordinary `Node`; startup and Ctrl+C
cleanup are not managed lifecycle transitions. Keep transition/error details in backup.

**Demo connection:** Keep the runtime flow visible while reading both `main()` functions.

**References:** [rclpy initialization/spin](https://github.com/ros2/rclpy/blob/jazzy/rclpy/rclpy/__init__.py),
[executor implementation](https://github.com/ros2/rclpy/blob/jazzy/rclpy/rclpy/executors.py),
[managed-node lifecycle](https://design.ros2.org/articles/node_lifecycle.html).

## Slide 10 — ROS Tools and Demo Transition (2 minutes)

**Purpose:** Give students a practical starting point for inspecting ROS.

| Command | What to look for |
| --- | --- |
| `ros2 node list` | The two node names |
| `ros2 topic list` | `/chatter` and infrastructure topics |
| `ros2 topic info /chatter --verbose` | Type, endpoint counts, and QoS |
| `ros2 interface show std_msgs/msg/String` | `string data` |
| `ros2 topic echo /chatter` | Live data; echo adds another subscription |

- A **package** groups code/resources and declares dependencies. A **workspace**
  groups packages for building; ROS 2 commonly uses `ament` and `colcon`.
- **Sourcing** a setup script makes an installation available in that shell; a built
  workspace can overlay that installation.
- This demo uses installed `rclpy` and `std_msgs`. Run directly without creating or
  building a package; source Jazzy in every terminal.

**Visual:** Three terminal panes plus the publisher/topic/subscriber diagram.

**Speaker guidance:** Ask students to find the names, type, depth, and interval in
code before running it. Predict what an extra subscriber changes.

**Demo connection:** Open both scripts, then use the prepared terminals to connect
each inspection command to the running greeting graph.

**References:** [Topic tutorial](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Topics/Understanding-ROS2-Topics.rst),
[workspace tutorial](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.rst),
[verbose topic-info implementation](https://github.com/ros2/ros2cli/blob/jazzy/ros2topic/ros2topic/verb/info.py).

## Code Walkthrough and Live Demo (20 minutes)

Follow the [demo instructions](demo/README.md); keep the greeting graph visible.

- **7 minutes — code:** Imports/inheritance, node names, matching topic/type, depth,
  timer, message construction/publication, subscriber callback/logging, `init`,
  executor spin, and cleanup. Read both scripts before running them.
- **6 minutes — run and inspect:** Start nodes; identify names, type, endpoint counts,
  QoS, field definition, and data. Explain echo's subscription; stop it before
  interpreting endpoint counts again.
- **4 minutes — experiments:** Predict, then stop/restart the subscriber (publisher
  continues; no replay) and publisher (reception stops; counter resets). The subscriber
  may miss early restarted messages while discovery completes.
- **3 minutes — recap:** Identify components; choose topic/service/action; distinguish
  `10` from `1.0`; explain DDS versus executor roles and ordinary versus managed nodes.

## Optional Backup Slides

### B1 — DDS Discovery and RTPS

Expand participant discovery followed by endpoint discovery (SPDP/SEDP in standard
RTPS discovery). Explain sequence numbers, heartbeats, acknowledgments/negative
acknowledgments, and retransmission for reliability; reliable DDS does not imply TCP.
UDP multicast is commonly used for discovery, but discovery servers and transport
configurations vary. Local delivery can use implementation-specific optimizations.

**Visual:** Discovery sequence beside a missing-sample/retransmission sequence.
**Reference:** [Fast DDS discovery](https://fast-dds.docs.eprosima.com/en/stable/fastdds/discovery/discovery.html)
and [RTPS writer behavior](https://fast-dds.docs.eprosima.com/en/stable/fastdds/rtps_layer/rtps_layer.html).

### B2 — QoS Compatibility

| Publisher offers | Subscriber requests | Reliability compatible? |
| --- | --- | --- |
| Best effort | Best effort | Yes |
| Best effort | Reliable | No |
| Reliable | Best effort | Yes |
| Reliable | Reliable | Yes |

Assume other policies are compatible. Transient-local retention needs a live writer
and compatible late-joining reader; it is not an indefinite archive. Deadline and
liveliness policies expose timing/availability expectations and events, not hard
callback timing guarantees.

**Visual:** Compatibility table and retained-data timeline.
**Reference:** [QoS documentation](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Intermediate/About-Quality-of-Service-Settings.rst).

### B3 — Executors and Concurrency

Compare one execution thread with a multithreaded worker pool. Callback groups control
which callbacks may overlap; additional threads alone do not make callbacks in the
default mutually exclusive group concurrent. Discuss slow callbacks and blocking
service calls as sources of delay/deadlock; favor short callbacks and asynchronous interactions.

**Visual:** Single-worker versus multiple-worker callback timelines.
**Reference:** [Callback-group guide](https://github.com/ros2/ros2_documentation/blob/jazzy/source/How-To-Guides/Using-callback-groups.rst).

### B4 — Managed Lifecycle Transitions

Expand the diagram with Configuring, Activating, Deactivating, CleaningUp, ShuttingDown,
and ErrorProcessing. Lifecycle callbacks report success/failure/error; resulting
states depend on the transition and error handling. Supervisors inspect states and
request transitions. Lifecycle publishers gate managed publication when inactive;
application code must still implement suitable behavior for other callbacks/resources.
Use a sensor-startup example separate from the ordinary-node demo.

**Visual:** Full state machine with success, failure, and error paths distinguished.
**Reference:** [Managed-node design](https://design.ros2.org/articles/node_lifecycle.html).

### B5 — Migrating ROS 1 Systems

Port APIs, package/build configuration, parameters, launch files, and delivery policies;
`rospy` code does not run unchanged as `rclpy`. A ROS 1/ROS 2 bridge can connect supported
topic/service interfaces when built with required types. Check distribution/OS support
before planning a mixed deployment. The course demo needs no bridge.

**Visual:** ROS 1 graph → interface bridge → ROS 2 graph.
**Reference:** [Official ROS 1 bridge documentation](https://github.com/ros2/ros1_bridge).

## Preparation and Acceptance

- Prepare the layer stack, robot graph, interface comparison, runtime/lifecycle flows,
  and sample terminal output. Use diagrams above as specifications for future slides.
- Verify names/options; rehearse on the Jazzy machine using the demo checklist.
  Keep backup slides outside the 45-minute core.
- Students should explain what ROS supplies, recognize basic interfaces, describe
  DDS's role, read both scripts, and inspect/predict their runtime behavior.
