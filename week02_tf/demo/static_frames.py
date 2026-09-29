"""Broadcast the lecture's fixed camera mounting as two transform edges."""

import math

import rclpy
from geometry_msgs.msg import TransformStamped
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from tf2_ros import StaticTransformBroadcaster


class StaticFrames(Node):
    def __init__(self):
        super().__init__('static_frames')
        self.broadcaster = StaticTransformBroadcaster(self)
        stamp = self.get_clock().now().to_msg()

        # The mount origin is 0.5 m above the base, with aligned axes.
        mount = TransformStamped()
        mount.header.stamp = stamp
        mount.header.frame_id = 'base_link'
        mount.child_frame_id = 'camera_mount'
        mount.transform.translation.z = 0.5
        mount.transform.rotation.w = 1.0

        # The simplified camera frame is rotated +90 degrees about mount z.
        camera = TransformStamped()
        camera.header.stamp = stamp
        camera.header.frame_id = 'camera_mount'
        camera.child_frame_id = 'camera_frame'
        camera.transform.rotation.z = math.sin(math.pi / 4)
        camera.transform.rotation.w = math.cos(math.pi / 4)

        self.broadcaster.sendTransform([mount, camera])
        self.get_logger().info(
            'Static frames: base_link -> camera_mount -> camera_frame'
        )


def main():
    rclpy.init()
    node = StaticFrames()
    try:
        rclpy.spin(node)  # Keep the static publisher available to new listeners.
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
