# Week 1 — ROS Basics

## Goal

Students should be able to:

- Explain what ROS provides and how it connects sensing, perception, planning, and control.
- Describe industry uses and why ROS 2 was developed after ROS 1.
- Identify nodes, topics, typed messages, publishers, and subscribers; choose between
  topics, services, and actions, and recognize parameters as node configuration.
- Describe DDS discovery/delivery, QoS, and executors at an introductory technical level.
- Distinguish ordinary node startup/shutdown from managed lifecycle states.
- Read the provided Python nodes and inspect/predict their live behavior with ROS tools.

Assume Python familiarity and little networking knowledge. The practical baseline is
ROS 2 Jazzy with the demo's existing localhost discovery and shared domain ID.

## Teaching Approach

Follow the [presentation plan](PRESENTATION_PLAN.md). The session is about ROS basics;
the greeting example illustrates the framework rather than defining the whole lesson.
Explain each term before using its acronym. Connect concepts to the scripts, then
reserve a dedicated block to read both scripts and run them.

## Core Explanation (25 minutes)

| Slides | Minutes | Focus |
| --- | ---: | --- |
| 1–2 | 4 | What ROS provides; robot architecture and industry examples |
| 3 | 3 | Origins, ROS 1 versus ROS 2, generations versus distributions |
| 4–5 | 5 | Nodes/processes, graph, typed topics, publishers/subscribers |
| 6 | 2 | Services, actions, and node parameters |
| 7 | 4 | Client libraries → rcl → rmw → DDS → transport |
| 8 | 2 | Reliability, durability, history/depth |
| 9 | 3 | Executors, callbacks, shutdown, and managed lifecycle introduction |
| 10 | 2 | CLI inspection, packages/workspaces, and sourcing |
| **Explanation total** | **25** | |

Key distinctions to preserve:

- ROS supplies libraries/tools/packages on top of the OS. The industry examples and
  historical/technical references are linked beside the relevant slides.
- A node is a logical component; a process may host several nodes. A topic names a
  typed channel, rather than a central broker or durable message archive.
- The ROS 1 master supports discovery; topic data normally travels between endpoints.
  ROS 2's course setup uses DDS discovery without a ROS master.
- DDS handles discovery and data exchange; the executor schedules application callbacks.
  DDS participants do not necessarily map one-to-one to ROS nodes.
- Same domain/topic/type and compatible QoS are needed for this demo. Domain IDs
  isolate discovery groups; they do not authenticate peers.
- Depth `10` is history size, `1.0` is timer interval. Defaults here are reliable and
  volatile. Reliable transport does not promise callback deadlines or late-join replay.
- Ordinary `Node` initialization/cleanup differs from managed lifecycle transitions.
  Managed states are Unconfigured, Inactive, Active, Finalized; a supervisor can coordinate startup.
- ROS use alone does not guarantee hard real-time operation or safety certification.

## Code Walkthrough and Live Demo (20 minutes)

Use the [demo instructions](demo/README.md) and prepared terminals.

- **7 minutes — read both scripts:** Identify imports, inheritance, ROS names, matching
  `String`/`/chatter`, depth, timer, message construction/publication, callback/logging,
  `init`, default single-threaded executor through `spin`, and `finally` cleanup.
- **6 minutes — run/inspect:** Show numbered greetings, list nodes/topics, inspect type,
  endpoint counts and QoS, show the interface definition, then echo messages. Echo
  adds a subscriber; stop it before interpreting counts again.
- **4 minutes — predict/experiment:** Stop/restart the subscriber, then the publisher.
  Explain no replay, discovery delay, and publisher counter reset. Early restarted
  messages may be missed before the subscriber matches.
- **3 minutes — questions/recap:** Check the components, communication choices, DDS
  role, executor role, depth versus interval, and ordinary versus managed lifecycle.

| Part | Minutes |
| --- | ---: |
| Explanation including context | 25 |
| Code walkthrough | 7 |
| Run and inspect | 6 |
| Stop/restart experiments | 4 |
| Questions and recap | 3 |
| **Total** | **45** |

Backup slides cover DDS/RTPS internals, QoS compatibility, concurrency, lifecycle error
paths, and ROS 1 migration. Use them for follow-up questions outside the core schedule.

## Common Questions / Problems

- **Is ROS an OS?** It supplies robotics software running on a host OS.
- **Why use services/actions instead of topics everywhere?** Their interfaces make
  requests, completion, progress, and cancellation explicit.
- **Is `10` the publishing frequency?** No; it is history depth. The timer sets the interval.
- **Why did restart skip numbers?** Volatile durability does not replay old greetings;
  discovery/matching also takes time. Publisher restart resets its own counter to zero.
- **Does `spin` move messages across the network?** Middleware handles transport;
  spinning makes application callbacks execute when work is ready.
- **Why is a package or `ros2` missing?** Check sourcing and the matching Python interpreter.
- **Why is there no data?** Check running processes, domain/discovery settings, resolved
  topic name, type, QoS compatibility, and networking before debugging application logic.
- **Why are endpoint counts unexpected?** Look for echo or an older demo process;
  allow graph discovery time. Use the README's daemon troubleshooting if listings are stale.

## Homework Connection

The [HW1 outline](../TA_plan.md) connects camera observations, coordinate transforms,
and simulated actuation. Identify the ROS interfaces that would connect those modules;
leave detailed transforms, Gazebo setup, and control implementation to later sessions.
Practise inspecting the graph and data before debugging algorithm behavior. Link the
actual assignment handout when available.

## Preparation Checklist

- [ ] Confirm Jazzy, matching system Python, and the three-terminal setup.
- [ ] Prepare readable robot/graph, layer-stack, interface, runtime, and lifecycle diagrams.
- [ ] Rehearse both scripts, CLI inspection, QoS output, and independent stop/restart behavior.
- [ ] Confirm counts before/during/after echo and allow time for discovery.
- [ ] Verify Ctrl+C cleanup; prepare saved terminal output as a fallback.
- [ ] Rehearse 25 minutes explanation plus the 7/6/4/3-minute demo blocks.
- [ ] Keep backup content outside the 45-minute core and retain time for questions.

## Validation Status

The outline and commands were checked against the scripts and official Jazzy documentation/
source. The editing workspace is Windows without the ROS CLI or an installed WSL environment;
live ROS execution, Ctrl+C behavior, and timed rehearsal remain to be checked on the
Jazzy teaching machine. Checklist items above are intentionally unmarked.
