import copy
import math
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import matplotlib
matplotlib.use('Agg')
import numpy as np

import robot
from robot import (START, GOAL, forward_points, configuration_free, edge_free,
                   interpolate, clearance)
from planner import Roadmap, build_roadmap, query_roadmap, shortest_path


class GeometryTests(unittest.TestCase):
    def test_forward_and_week3_dimensions(self):
        np.testing.assert_allclose(forward_points((0, math.pi/2))[-1], (.6, .4), atol=1e-12)
        model = Path(__file__).resolve().parents[2] / 'week03_kinematics/demo/arm.urdf'
        root = ET.parse(model).getroot()
        for name, length in [('joint2', robot.L1), ('tool_fixed', robot.L2)]:
            self.assertEqual(float(root.find(f"joint[@name='{name}']/origin").get('xyz').split()[0]), length)

    def test_both_links_and_contact(self):
        for center in ((.3, 0, .1), (.9, 0, .1)):
            with patch.object(robot, 'OBSTACLE', center):
                self.assertFalse(configuration_free((0, 0)))
        with patch.object(robot, 'OBSTACLE', (.3, .13, .1)):
            self.assertFalse(configuration_free((0, 0)))
        self.assertTrue(configuration_free(START))
        self.assertTrue(configuration_free(GOAL))
        self.assertFalse(configuration_free((0, 0)))
        self.assertFalse(edge_free(START, GOAL))

    def test_invalid_and_no_wrapping(self):
        for q in ((math.nan, 0), (0, math.inf), (4, 0), (0,)):
            with self.assertRaises(ValueError):
                forward_points(q)
        values = interpolate((-3, 0), (3, 0))
        self.assertTrue(any(abs(q[0]) < .01 for q in values))
        for step in (0, -1, math.nan):
            with self.assertRaises(ValueError):
                interpolate(START, GOAL, step)


class PlannerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.graph = build_roadmap()
        cls.result = query_roadmap(cls.graph, START, GOAL)

    def test_default_and_dense_independent_check(self):
        self.assertTrue(self.result.path)
        self.assertEqual(self.result.path[0], START)
        self.assertEqual(self.result.path[-1], GOAL)
        # Independently sample more densely and measure segment distances with NumPy.
        for a, b in zip(self.result.path, self.result.path[1:]):
            self.assertTrue(edge_free(a, b))
            n = math.ceil(max(abs(x-y) for x, y in zip(a, b))/.002)
            for fraction in np.linspace(0, 1, n+1):
                q = np.array(a) + fraction*(np.array(b)-a)
                points = np.array(forward_points(q))
                for p, end in zip(points, points[1:]):
                    delta = end-p
                    t = np.clip(np.dot(np.array(robot.OBSTACLE[:2])-p, delta)/np.dot(delta, delta), 0, 1)
                    distance = np.linalg.norm(np.array(robot.OBSTACLE[:2])-(p+t*delta))
                    self.assertGreater(distance, robot.OBSTACLE[2]+robot.LINK_RADIUS)

    def test_determinism_prefix_and_no_mutation(self):
        again = build_roadmap()
        self.assertEqual(again.points, self.graph.points)
        self.assertEqual(again.adjacency, self.graph.adjacency)
        self.assertEqual(build_roadmap(20).points, self.graph.points[:20])
        before = copy.deepcopy(self.graph)
        query_roadmap(self.graph, START, GOAL)
        self.assertEqual(before, self.graph)

    def test_failures_and_equal_endpoints(self):
        empty = Roadmap([], [], 10)
        result = query_roadmap(empty, START, GOAL)
        self.assertEqual(result.message, 'No path found in this roadmap.')
        self.assertEqual(query_roadmap(empty, START, START).path, [START])
        with self.assertRaises(ValueError):
            query_roadmap(empty, (0, 0), GOAL)
        for options in [dict(samples=0), dict(neighbors=0), dict(seed=1.2), dict(max_attempts=0)]:
            with self.assertRaises(ValueError):
                build_roadmap(**options)
        with patch('planner.configuration_free', return_value=False):
            with self.assertRaises(RuntimeError):
                build_roadmap(5, max_attempts=10)

    def test_shortest_path(self):
        graph = [[(1, 1), (2, 5)], [(0, 1), (2, 1)], [(0, 5), (1, 1)], []]
        self.assertEqual(shortest_path(graph, 0, 2), ([0, 1, 2], 2))
        self.assertEqual(shortest_path(graph, 0, 3), ([], None))


class InterfaceTests(unittest.TestCase):
    def test_controls_preview_animation_and_reset(self):
        from demo import Demo
        app = Demo()
        try:
            for stage in (1, 2, 3):
                app.next_stage()
                self.assertEqual(app.stage, stage)
            app.toggle_play()
            self.assertTrue(app.playing)
            app.last_time -= .1
            app.tick()
            self.assertGreater(app.distance, 0)
            app.toggle_play()
            self.assertFalse(app.playing)
            app.preview(SimpleNamespace(inaxes=app.space, xdata=0, ydata=0))
            self.assertIn('Collision', app.pose_text.get_text())
            app.reset()
            self.assertEqual(app.stage, 0)
            self.assertFalse(app.samples.get_visible())
            np.testing.assert_allclose(app.current.get_xdata(), [START[0]])
            app.set_stage(3)
            app.toggle_play()
            app.last_time -= 100
            app.tick()
            self.assertFalse(app.playing)
            np.testing.assert_allclose(app.current.get_xdata(), [GOAL[0]])
            self.assertTrue(all(configuration_free(q) for q in app.playback))
            app.fig.canvas.draw()
        finally:
            app.plt.close(app.fig)


if __name__ == '__main__':
    unittest.main()
