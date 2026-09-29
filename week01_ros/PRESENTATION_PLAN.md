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
- Example: a sensor reading travels on a topic; its message type defines the data fields.

## Slide 4 — Publishers and Subscribers

- Publishers send messages; subscribers receive them.
- Multiple subscribers can listen to the same topic.

## Slide 5 — Follow One Message

- Show `publisher node → topic → subscriber node` with the topic name and message type labeled.
- Trace a single reading from its source to its consumer.
- Ask students what happens if the subscriber stops.

## Slide 6 — Inspect the System

- `ros2 node list` — list running nodes.
- `ros2 topic list` — list topics.
- `ros2 topic info <topic>` — inspect the topic's type and publisher/subscriber counts.
- `ros2 topic echo <topic>` — observe messages; replace `<topic>` with the demo topic name.

## Slide 7 — From Diagram to Live Demo

- Start a publisher and subscriber, then find both in the running system.
- Observe messages and predict what happens when a node stops or restarts.
- Keep slides within the first 20 minutes; reserve 25 minutes for the demo, questions, and wrap-up.

## Visuals Needed

- Simple robot sketch connecting sensing, processing, and actuation.
- Publisher → topic → subscriber diagram with space for the chosen demo's names and message type.
- Short sample of terminal output as a fallback once the demo is prepared.

## Live Demo Transition

- Leave the communication diagram visible while opening the prepared terminals.
- Ask students to identify the publisher, topic, and subscriber as each appears.
- Begin with message flow, then use the CLI tools to inspect it. Demo implementation and exact commands will be added later in `demo/`.
