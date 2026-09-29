"""Convert the lecture's camera point into base coordinates using tf2."""

import rclpy
from geometry_msgs.msg import PointStamped
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from rclpy.time import Time
from tf2_geometry_msgs import do_transform_point
from tf2_ros import Buffer, TransformException, TransformListener


class PointTransformer(Node):
    def __init__(self):
        super().__init__('point_transformer')
        self.buffer = Buffer()
        self.listener = TransformListener(self.buffer, self)
        self.camera_publisher = self.create_publisher(PointStamped, '/point_camera', 10)
        self.base_publisher = self.create_publisher(PointStamped, '/point_base', 10)
        self.timer = self.create_timer(1.0, self.transform_point)

    def transform_point(self):
        point = PointStamped()
        point.header.frame_id = 'camera_frame'
        point.header.stamp = self.get_clock().now().to_msg()
        point.point.x = 0.2
        point.point.z = 1.0

        try:
            # Arguments are TARGET, SOURCE, time. Time() asks for latest available.
            # This is valid here because the entire camera-to-base chain is static.
            transform = self.buffer.lookup_transform('base_link', 'camera_frame', Time())
        except TransformException as error:
            # Never block this callback: the listener needs the executor to run.
            self.get_logger().warning(f'Waiting for camera-to-base transform: {error}',
                                      throttle_duration_sec=5.0)
            return

        converted = do_transform_point(point, transform)
        # do_transform_point uses the transform header. Preserve measurement time
        # for RViz's later conversion through the dynamic world-to-base edge.
        converted.header.stamp = point.header.stamp
        self.camera_publisher.publish(point)
        self.base_publisher.publish(converted)
        p = converted.point
        self.get_logger().info(
            f'camera_frame (0.200, 0.000, 1.000) -> '
            f'base_link ({p.x:.3f}, {p.y:.3f}, {p.z:.3f}) m'
        )


def main():
    rclpy.init()
    node = PointTransformer()
    try:
        rclpy.spin(node)
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
