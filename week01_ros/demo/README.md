# Week 1 — ROS 2 Live Demo

Two small Python nodes demonstrate message flow:

```text
greeting_publisher → /chatter (std_msgs/msg/String) → greeting_subscriber
```

- [publisher.py](publisher.py) sends a numbered greeting once per second.
- [subscriber.py](subscriber.py) prints each greeting it receives.

Run the scripts directly with Python; no package build is needed for this demo.

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
ros2 interface show std_msgs/msg/String
ros2 topic echo /chatter
```

Expect `/greeting_publisher` and `/greeting_subscriber` in the node list, and
`/chatter` in the topic list alongside ROS infrastructure topics. Before starting
`echo`, topic info should show type `std_msgs/msg/String`, one publisher, and one
subscriber. `echo` adds another subscriber while it runs. Press Ctrl+C to stop it.

## Show the Code

Spend about 5 minutes with the two scripts side by side:

1. Find the node names passed to `Node` through `super().__init__`.
2. Match `String` and `/chatter` in `create_publisher` and `create_subscription`.
3. Trace the publisher timer → `message.data` → `publish(message)`.
4. Trace the subscriber callback → `message.data` → terminal log.
5. Explain that `spin` processes callbacks, and `10` is the message queue depth,
   not a frequency. The timer's `1.0` sets the interval in seconds.

## Live Experiments

- Stop only the subscriber with Ctrl+C. The publisher keeps sending. Restart the
  subscriber and observe new messages arriving without replaying missed greetings.
- While the subscriber runs, stop the publisher. Reception stops; restart it and
  observe the counter begin again at zero once discovery completes.
- If time permits, start a second subscriber in another prepared terminal:
  `python3 week01_ros/demo/subscriber.py --ros-args -r __node:=second_subscriber`.
  Both receive greetings; inspect the subscriber count before running `echo`.
- Ask students to predict the result before each change. Stop all scripts with
  Ctrl+C when finished.

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
- [ ] Stop and restart the subscriber and publisher separately.
- [ ] Check Ctrl+C exits without a traceback.
- [ ] Rehearse within 25 minutes: 5 minutes code, 8 minutes running and inspecting,
      7 minutes experiments, and 5 minutes questions and wrap-up.
