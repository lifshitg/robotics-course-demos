"""Command the simulated arm and check measured joint convergence."""

import argparse
import math
import time

from kinematics import forward, inverse, validate_joints


def parse_command():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_subparsers(dest='mode', required=True)
    joints = modes.add_parser('joints', help='Command joint angles in radians.')
    joints.add_argument('--q1', type=float, required=True)
    joints.add_argument('--q2', type=float, required=True)
    target = modes.add_parser('target', help='Reach an xy target in base_link, in metres.')
    target.add_argument('--x', type=float, required=True)
    target.add_argument('--y', type=float, required=True)
    target.add_argument('--branch', choices=['positive', 'negative'], default='positive')
    args = parser.parse_args()
    try:
        goal = (validate_joints(args.q1, args.q2) if args.mode == 'joints'
                else inverse(args.x, args.y, args.branch))
    except ValueError as error:
        parser.error(str(error))  # Reject before creating any ROS publisher.
    return goal


def main():
    goal = parse_command()
    expected = forward(*goal)
    print(f'Requested joints: q1={goal[0]:.6f}, q2={goal[1]:.6f} rad', flush=True)
    print(f'Predicted position: x={expected[0]:.6f}, y={expected[1]:.6f} m', flush=True)

    import rclpy
    from rclpy.executors import ExternalShutdownException
    from rclpy.parameter import Parameter
    from sensor_msgs.msg import JointState
    from std_msgs.msg import Float64

    rclpy.init(args=[])
    node = rclpy.create_node('command_arm', parameter_overrides=[
        Parameter('use_sim_time', value=True)])
    publishers = [node.create_publisher(Float64, f'/arm/joint{i}/cmd_pos', 10)
                  for i in (1, 2)]
    state = {'angles': None, 'stamp': None, 'wall_update': 0.0}

    def receive(msg):
        positions = dict(zip(msg.name, msg.position))
        if not all(name in positions for name in ('joint1', 'joint2')):
            return
        stamp = (msg.header.stamp.sec, msg.header.stamp.nanosec)
        if stamp != state['stamp']:
            state.update(angles=(positions['joint1'], positions['joint2']),
                         stamp=stamp, wall_update=time.monotonic())

    subscription = node.create_subscription(JointState, '/joint_states', receive, 10)
    deadline = time.monotonic() + 10.0
    next_publish = 0.0
    sent = False
    sent_stamp = None
    result = 1
    try:
        while rclpy.ok() and time.monotonic() < deadline:
            rclpy.spin_once(node, timeout_sec=0.02)
            now = time.monotonic()
            ready = (state['angles'] is not None and now - state['wall_update'] < 0.5
                     and node.get_clock().now().nanoseconds > 0
                     and all(pub.get_subscription_count() for pub in publishers))
            if not ready:
                continue
            # Wall-clock scheduling also allows timeouts when simulation is paused.
            if now >= next_publish:
                for pub, angle in zip(publishers, goal):
                    pub.publish(Float64(data=angle))
                next_publish = now + 0.1
                if not sent:
                    sent_stamp = state['stamp']
                sent = True
            if sent and state['stamp'] != sent_stamp:
                errors = [abs(actual - wanted) for actual, wanted in zip(state['angles'], goal)]
                if max(errors) < 0.01:
                    q1, q2 = state['angles']
                    # Use the measured values directly; tiny solver limit overshoot is possible.
                    from kinematics import L1, L2
                    x = L1 * math.cos(q1) + L2 * math.cos(q1 + q2)
                    y = L1 * math.sin(q1) + L2 * math.sin(q1 + q2)
                    error = math.hypot(x - expected[0], y - expected[1])
                    if error >= 0.01:
                        continue
                    print(f'Measured joints: q1={q1:.6f}, q2={q2:.6f} rad')
                    print(f'Measured position: x={x:.6f}, y={y:.6f} m')
                    print(f'Position error: {error:.6f} m; converged.')
                    result = 0
                    break
        if result:
            if state['angles'] is None:
                reason = 'No measured joint states. Check Gazebo, model spawn, bridge, and play/pause.'
            elif time.monotonic() - state['wall_update'] >= 0.5:
                reason = 'Simulation is paused or joint-state updates stopped. Resume Gazebo.'
            elif not all(pub.get_subscription_count() for pub in publishers):
                reason = 'Command bridge is missing. Check the launch output.'
            else:
                reason = 'Joints did not converge. Check simulation speed and controllers.'
            print('Timed out after 10 wall-clock seconds. ' + reason)
    except (KeyboardInterrupt, ExternalShutdownException):
        print('Command interrupted; Gazebo may retain the last target.')
        result = 130
    finally:
        node.destroy_node()
        rclpy.try_shutdown()
    return result


if __name__ == '__main__':
    raise SystemExit(main())
