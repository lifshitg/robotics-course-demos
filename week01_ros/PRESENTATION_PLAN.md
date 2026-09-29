# Week 1 — ROS 2 Presentation Plan

## Slide 1 — Why ROS 2?

- A robot combines sensing, decision-making, and actuation; its software components need to communicate.
- ROS 2 provides libraries and tools for building and connecting these components.
- Session goal: understand a simple communication path and inspect it live.

## Slide 2 — Nodes

- A node has a specific responsibility within the robot's software.
- Examples: a sensor node and a node that processes its readings.

## Slide 3 — Topics and Messages

- A topic is a named channel for messages of a defined type.
- A message is the data being sent; its type defines field names and types in a `.msg` file.
- Use the demo's `std_msgs/msg/String`: its definition is `string data`, and the Python code sets `message.data`.
- Briefly show `ros2 interface show std_msgs/msg/String` to connect the definition to the code (about 1 minute).

## Slide 4 — Publishers and Subscribers

- Publishers send messages; subscribers receive them.
- Multiple subscribers can listen to the same topic.

## Slide 5 — Follow One Message

- Show `publisher node → topic → subscriber node` with the topic name and message type labeled.
- Trace a single reading from its source to its consumer.
- Ask students what happens if the subscriber stops.

## Slide 6 — Services: Request and Response

- A client sends a request; a server performs a short operation and returns a response.
- Example: request an odometry reset and receive a success/failure response.
- A `.srv` definition describes the request and response fields, separated by `---`.
- Spend about 1 minute on the idea and example.

## Slide 7 — Actions: Goals, Feedback, and Results

- A client sends a goal to an action server for a task that takes time, such as navigating to a waypoint.
- The server provides progress feedback and a final result; the client can request cancellation.
- A `.action` definition describes goal, result, and feedback fields.
- Quick comparison: topic = ongoing sensor readings; service = reset odometry; action = navigate to a waypoint.
- Spend about 2 minutes, including asking students which communication pattern fits each example.

TA reference: [ROS 2 interface definitions](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Basic/About-Interfaces.rst).

## Slide 8 — Inspect the System

- `ros2 node list` — list running nodes.
- `ros2 topic list` — list topics.
- `ros2 topic info <topic>` — inspect the topic's type and publisher/subscriber counts.
- `ros2 topic echo <topic>` — observe messages; replace `<topic>` with the demo topic name.

## Slide 9 — From Diagram to Live Demo

- Show the publisher timer and subscriber callback in the two short Python scripts.
- Start both nodes, then find them in the running system.
- Observe messages and predict what happens when a node stops or restarts.
- Keep context and slides within the first 20 minutes: 5 minutes context, then 15 minutes explanation including the 4-minute messages/services/actions overview. Reserve 25 minutes for the demo, questions, and wrap-up.

## Visuals Needed

- Simple robot sketch connecting sensing, processing, and actuation.
- Publisher → topic → subscriber diagram with space for the chosen demo's names and message type.
- Compact comparison visual: topic data flow, service request → response, and action goal → feedback → result with a cancellation request arrow.
- Show `string data` beside the demo's `message.data` assignment.
- Short sample of terminal output as a fallback.

## Live Demo Transition

- Bring the focus back to the publisher → topic → subscriber example and leave that diagram visible while opening the prepared terminals.
- Ask students to identify the publisher, topic, and subscriber as each appears.
- Walk through the two scripts for 5 minutes, then run and inspect the message flow using the [demo instructions](demo/README.md).
