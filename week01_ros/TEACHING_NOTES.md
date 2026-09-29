# Week 1 — ROS 2

## Goal

- Students can explain why ROS 2 is useful for connecting robotics software components.
- Students can identify nodes, topics, publishers, and subscribers in a simple example.
- Students can use basic ROS 2 command-line tools to inspect running nodes and topic data.

## Context / Recap

- Start with a robot that senses its surroundings, makes decisions, and commands motors. These components need to exchange data.
- Introduce ROS 2 as a set of software libraries and tools for building robotics applications, including communication between components.
- Use a sensor sending readings to a processing component as the running example.

## Core Explanation

- **Node:** a participant in the ROS 2 system with a specific responsibility, such as producing sensor readings or processing them.
- **Topic:** a named channel carrying messages of a defined type.
- **Publisher:** sends messages to a topic. **Subscriber:** receives messages from a topic.
- Draw `publisher node → topic → subscriber node`. Explain that a topic can connect multiple publishers and subscribers.
- **Typed messages:** communicating components must agree on the message structure; a topic name alone is not enough.
- Introduce the CLI as a way to inspect the running system: `ros2 node list`, `ros2 topic list`, `ros2 topic info <topic>`, and `ros2 topic echo <topic>`.

## Live Demo

- Planned demonstration: start a simple publisher and subscriber in separate terminals and observe messages arriving.
- List the running nodes and topics, then inspect the example topic and echo its messages.
- Stop the subscriber and show that the publisher can continue running; restart the subscriber and observe new messages arriving.
- Ask students to map the terminal output to the publisher → topic → subscriber diagram.
- Demo code and launch instructions will be prepared later in `demo/`.

## Timing

| Part | Minutes | Focus |
| --- | ---: | --- |
| Context / recap | 5 | Robotics motivation and session goal |
| Core explanation | 15 | Concepts, architecture diagram, and CLI introduction |
| Live demo, questions, and wrap-up | 25 | Observe communication, inspect the system, and recap |
| **Total** | **45** | |

## Common Questions / Problems

- **Is ROS 2 an operating system?** Explain that it provides robotics libraries and tools that run on a supported operating system.
- **Is a topic a node?** A node performs work; a topic names a communication channel.
- **Can several subscribers receive the same data?** Yes; multiple subscribers can listen to a topic.
- **Why is `ros2` unavailable or a package missing?** Check installation and whether the ROS 2 environment and any required workspace are sourced in that terminal.
- **Why are no messages arriving?** Check that the nodes are running, topic names and message types match, and terminals use the same ROS domain. If needed, check QoS compatibility and network discovery.

## Homework Connection

- These concepts can support future assignments that connect sensors, processing, and robot control components.
- Practise inspecting the running system before debugging application logic.
- Add links to actual assignment requirements when they become available.

## Preparation Checklist

- [ ] Confirm the course ROS 2 distribution, operating system, and environment setup.
- [ ] Prepare and test the publisher/subscriber demo and its instructions.
- [ ] Rehearse starting, stopping, and restarting the nodes in separate terminals.
- [ ] Verify the CLI commands against the chosen demo's actual node and topic names.
- [ ] Check terminal readability and prepare a small sample of expected output as a fallback.
- [ ] Rehearse the 45-minute flow and leave time for student questions.
