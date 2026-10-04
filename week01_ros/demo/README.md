# Week 1 — ROS Basics: ROS 2 Live Demo

Two small Python nodes demonstrate message flow:

```text
greeting_publisher → /chatter (std_msgs/msg/String) → greeting_subscriber
```

- [publisher.py](publisher.py) sends a numbered greeting once per second.
- [subscriber.py](subscriber.py) prints each greeting it receives.

Run the scripts directly with Python; no package build is needed for this demo.

This is the practical example for the [ROS basics presentation](../PRESENTATION_PLAN.md).
Reserve 20 minutes: 7 minutes reading code, 6 minutes running/inspecting,
4 minutes stop/restart experiments, and 3 minutes questions/recap. The preceding
explanation takes 25 minutes, for a 45-minute session.

## Setup

Use a ROS 2 installation with `rclpy` and `std_msgs`. The commands below use
Linux/Bash and Jazzy, which is installed on the TA development machine. For a
different installation, use its setup script and matching Python interpreter.

Open three terminals at the repository root. In **each terminal**, run:

```bash
source /opt/ros/jazzy/setup.bash
export ROS_DOMAIN_ID=42
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
```

Use the same domain in every terminal. Localhost discovery keeps this demonstration
on one machine; students running nodes on separate machines will not connect to it.
These exports apply only to the current terminal session. Use the system Python
that matches the ROS installation, outside an unrelated virtual environment.

## Run

**Terminal 1 — publisher:**

```bash
python3 week01_ros/demo/publisher.py
```

**Terminal 2 — subscriber:**

```bash
python3 week01_ros/demo/subscriber.py
```

Example log messages (timestamps omitted):

```text
[greeting_publisher]: Sent: Hello, robotics! Message 3
[greeting_subscriber]: Received: Hello, robotics! Message 3
```

The subscriber may start at a later number: these nodes use the default volatile
durability, so a new subscriber receives new messages rather than replaying earlier
ones. Allow a moment for the nodes to discover each other.

**Terminal 3 — inspect:**

```bash
ros2 node list
ros2 topic list
ros2 topic info /chatter
ros2 topic info /chatter --verbose
ros2 interface show std_msgs/msg/String
ros2 topic echo /chatter
```

Expect `/greeting_publisher` and `/greeting_subscriber` in the node list, and
`/chatter` in the topic list alongside ROS infrastructure topics. Before starting
`echo`, topic info should show type `std_msgs/msg/String`, one publisher, and one
subscriber. `echo` adds another subscriber while it runs. Press Ctrl+C to stop it.

The verbose view adds endpoint names and QoS profiles. For the demo endpoints,
look for KEEP_LAST, depth 10, RELIABLE, and VOLATILE. Stop echo before checking
counts again; allow discovery time for counts to update. To observe echo's extra
subscription while it runs, use another configured terminal if available.

## Show the Code

Spend about 7 minutes with the two scripts side by side:

1. Identify `rclpy`, the `Node` base class, and `String` from `std_msgs`. Find the
   node names passed through `super().__init__`; distinguish ROS node names from
   Python class names and filenames. Each script runs one node in one process.
2. Match `String` and `/chatter` in `create_publisher` and `create_subscription`.
3. Trace the publisher timer → `message.data` → `publish(message)`.
4. Trace the subscriber callback → `message.data` → terminal log.
5. Explain that `10` selects KEEP_LAST history depth with other QoS defaults,
   including reliable delivery and volatile durability. It is not a frequency
   or a promise to replay ten messages to a new subscriber. The timer's `1.0`
   sets the intended interval in seconds, without a hard timing guarantee.
6. Trace `rclpy.init()` → node/endpoints/timer construction → `rclpy.spin(node)`.
   The default single-threaded executor waits for ready work and runs callbacks;
   long callbacks delay other work on that executor. DDS discovery and data
   reception are distinct from callback execution.
7. Trace the shutdown exceptions and `finally`: `destroy_node()` releases resources;
   `try_shutdown()` shuts down the context if needed. These are ordinary `Node`
   instances, not managed lifecycle nodes with configure/activate transitions.

Connect publication to the slide's application → `rclpy` → `rcl` → `rmw` → DDS
stack. Both endpoints use the same domain, topic/type, and compatible QoS. The
localhost setup makes this a local demonstration of distributed communication;
it does not exercise communication between separate computers.

References: [Jazzy endpoint depth handling](https://github.com/ros2/rclpy/blob/jazzy/rclpy/rclpy/node.py),
[default executor and spin](https://github.com/ros2/rclpy/blob/jazzy/rclpy/rclpy/__init__.py),
[verbose topic inspection](https://github.com/ros2/ros2cli/blob/jazzy/ros2topic/ros2topic/verb/info.py).

## Live Experiments

Use 4 minutes for the two stop/restart experiments. Ask for predictions first.

- Stop only the subscriber with Ctrl+C. The publisher keeps sending. Restart the
  subscriber and observe new messages arriving without replaying missed greetings.
- While the subscriber runs, stop the publisher. Reception stops; restart it and
  observe the counter reset to zero in the publisher's log. The subscriber resumes
  after matching and may first receive a later number; it need not observe zero.
- Optional extension outside the core schedule: start a second subscriber in
  another prepared terminal:
  `python3 week01_ros/demo/subscriber.py --ros-args -r __node:=second_subscriber`.
  Both receive greetings; inspect the subscriber count before running `echo`.
- Ask students to predict the result before each change. Stop all scripts with
  Ctrl+C when finished.

## Questions and Recap (3 minutes)

- Identify the node names, topic, type, publisher, and subscription.
- Choose topic/service/action for sensor readings, an odometry reset, and navigation.
- Explain `10` versus `1.0`, and why volatile durability prevents replay on restart.
- Distinguish DDS discovery/delivery from executor callback scheduling, and ordinary
  initialization/cleanup from managed lifecycle transitions.

## Troubleshooting

- **`ros2` or a Python module is missing:** source the setup script in that terminal
  and use the Python interpreter supplied for the ROS installation.
- **No messages:** check that both scripts run, both terminals use the same domain,
  and the topic name and message type match. Allow a moment for discovery.
- **Unexpected nodes or counts:** stop older demo processes and any running
  `ros2 topic echo`. Use a different shared domain number if another local session
  is using 42.
- **The first inspection returns an empty list:** allow discovery time and retry.
  For an explicit wait, use `ros2 node list --no-daemon --spin-time 3` or
  `ros2 topic info /chatter --no-daemon --spin-time 3`.
- **CLI lists appear stale after changing domains or discovery settings:** run
  `ros2 daemon stop` in the configured inspection terminal, then retry the command.

## Rehearsal Checklist

- [ ] Run both scripts and confirm matching message numbers.
- [ ] Inspect node names, topic type, counts, and message data.
- [ ] Verify verbose endpoint QoS; check counts before/during/after echo.
- [ ] Stop and restart the subscriber and publisher separately.
- [ ] Check Ctrl+C exits without a traceback.
- [ ] Rehearse within 20 minutes: 7 minutes code, 6 minutes running and inspecting,
      4 minutes experiments, and 3 minutes questions and recap.

Documentation and command syntax were checked against the scripts and official
Jazzy sources. Live execution and timed rehearsal still need the Jazzy machine;
the Windows editing workspace has neither the ROS CLI nor an installed WSL environment.
