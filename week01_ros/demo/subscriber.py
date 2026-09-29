"""Print the greetings received on /chatter."""

import rclpy
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from std_msgs.msg import String


class GreetingSubscriber(Node):
    def __init__(self):
        super().__init__('greeting_subscriber')
        # Register a callback for messages arriving on the publisher's topic.
        self.subscription = self.create_subscription(
            String, '/chatter', self.receive_greeting, 10
        )

    def receive_greeting(self, message):
        self.get_logger().info(f'Received: {message.data}')


def main():
    rclpy.init()
    node = GreetingSubscriber()
    try:
        rclpy.spin(node)  # Wait for messages and run the callback.
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
