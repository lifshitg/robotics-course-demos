"""Add a rotating world-to-base transform for the timestamp discussion."""

import math

import rclpy
from geometry_msgs.msg import TransformStamped
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from tf2_ros import TransformBroadcaster


class MovingBase(Node):
    def __init__(self):
        super().__init__('moving_base')
        self.broadcaster = TransformBroadcaster(self)
        self.start_time = self.get_clock().now()
        self.timer = self.create_timer(0.1, self.broadcast_transform)

    def broadcast_transform(self):
        now = self.get_clock().now()
        elapsed_seconds = (now - self.start_time).nanoseconds / 1e9
        yaw = 0.2 * elapsed_seconds  # Radians; positive rotation about world z.
        transform = TransformStamped()
        transform.header.stamp = now.to_msg()
        transform.header.frame_id = 'world'
        transform.child_frame_id = 'base_link'
        transform.transform.rotation.z = math.sin(yaw / 2)
        transform.transform.rotation.w = math.cos(yaw / 2)
        self.broadcaster.sendTransform(transform)


def main():
    rclpy.init()
    node = MovingBase()
    try:
        rclpy.spin(node)
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
