"""Publish one numbered greeting per second on /chatter."""

import rclpy
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from std_msgs.msg import String


class GreetingPublisher(Node):
    def __init__(self):
        super().__init__('greeting_publisher')
        # Both nodes use the same message type and topic; 10 is the queue depth.
        self.publisher = self.create_publisher(String, '/chatter', 10)
        self.count = 0
        # ROS calls publish_greeting once every second while the node spins.
        self.timer = self.create_timer(1.0, self.publish_greeting)

    def publish_greeting(self):
        message = String()
        message.data = f'Hello, robotics! Message {self.count}'
        self.publisher.publish(message)
        self.get_logger().info(f'Sent: {message.data}')
        self.count += 1


def main():
    rclpy.init()
    node = GreetingPublisher()
    try:
        rclpy.spin(node)  # Process callbacks until Ctrl+C.
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
