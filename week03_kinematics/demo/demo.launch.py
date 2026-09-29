"""Start the local arm demo: ros2 launch ./week03_kinematics/demo/demo.launch.py."""

from pathlib import Path

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, EmitEvent, ExecuteProcess, OpaqueFunction, RegisterEventHandler
from launch.event_handlers import OnProcessExit
from launch.events import Shutdown
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def start_demo(context):
    directory = Path(__file__).resolve().parent
    headless = LaunchConfiguration('headless').perform(context).lower() == 'true'
    command = ['gz', 'sim', '-r', str(directory / 'world.sdf')]
    command += ['-s'] if headless else ['--gui-config', str(directory / 'gui.config')]
    simulator = ExecuteProcess(cmd=command, output='screen')
    bridge = Node(package='ros_gz_bridge', executable='parameter_bridge',
                  parameters=[{'config_file': str(directory / 'bridge.yaml'), 'use_sim_time': True}],
                  output='screen')
    state_publisher = Node(package='robot_state_publisher', executable='robot_state_publisher',
                           parameters=[{'robot_description': (directory / 'arm.urdf').read_text(),
                                        'use_sim_time': True}], output='screen')
    spawn = Node(package='ros_gz_sim', executable='create',
                 arguments=['-world', 'kinematics', '-file', str(directory / 'arm.urdf'),
                            '-name', 'planar_arm'], output='screen')

    def spawned(event, context):
        if event.returncode != 0:
            return [EmitEvent(event=Shutdown(reason='Arm spawn failed; inspect Gazebo output.'))]
        return []

    return [RegisterEventHandler(OnProcessExit(target_action=simulator,
                on_exit=[EmitEvent(event=Shutdown(reason='Gazebo exited.'))])),
            RegisterEventHandler(OnProcessExit(target_action=spawn, on_exit=spawned)),
            simulator, bridge, state_publisher, spawn]


def generate_launch_description():
    return LaunchDescription([
        DeclareLaunchArgument('headless', default_value='false', choices=['true', 'false']),
        OpaqueFunction(function=start_demo),
    ])
