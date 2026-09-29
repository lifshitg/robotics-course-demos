"""Run with: python3 -m unittest discover -s week03_kinematics/demo -p 'test_*.py'."""

import math
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET

from kinematics import L1, L2, forward, inverse, validate_joints


class KinematicsTests(unittest.TestCase):
    def assert_point(self, actual, expected):
        for a, b in zip(actual, expected):
            self.assertAlmostEqual(a, b, places=9)

    def test_worked_examples(self):
        self.assert_point(forward(0, 0), (1, 0))
        self.assert_point(forward(0, math.pi / 2), (.6, .4))

    def test_two_branches_and_round_trips(self):
        solutions = [inverse(.6, .4, branch) for branch in ('positive', 'negative')]
        self.assertGreater(solutions[0][1], 0)
        self.assertLess(solutions[1][1], 0)
        for q1 in (-2.7, -1, 0, .8, 2.7):
            for q2 in (-2.5, -.6, .6, 2.5):
                point = forward(q1, q2)
                for branch in ('positive', 'negative'):
                    solution = inverse(*point, branch)
                    validate_joints(*solution)
                    self.assert_point(forward(*solution), point)

    def test_boundaries(self):
        for radius in (abs(L1-L2), L1+L2):
            for angle in (0, 1.2, math.pi):
                point = (radius*math.cos(angle), radius*math.sin(angle))
                for branch in ('positive', 'negative'):
                    self.assert_point(forward(*inverse(*point, branch)), point)
        self.assert_point(forward(*inverse(1+1e-14, 0)), (1, 0))

    def test_rejections(self):
        for point in ((0, 0), (.1, 0), (1.2, 0), (1+1e-8, 0), (.2-1e-8, 0),
                      (math.nan, 0), (0, math.inf), (1e308, 1e308)):
            with self.subTest(point=point), self.assertRaises(ValueError):
                inverse(*point)
        for pair in ((math.pi+.01, 0), (0, -math.pi-.01), (math.nan, 0), (0, math.inf)):
            with self.subTest(pair=pair), self.assertRaises(ValueError):
                forward(*pair)
        with self.assertRaises(ValueError):
            inverse(.6, .4, 'unknown')

    def test_model_matches_math(self):
        robot = ET.parse(Path(__file__).with_name('arm.urdf')).getroot()
        self.assertEqual(float(robot.find("joint[@name='joint2']/origin").get('xyz').split()[0]), L1)
        self.assertEqual(float(robot.find("joint[@name='tool_fixed']/origin").get('xyz').split()[0]), L2)
        for link, length in (('link1', L1), ('link2', L2)):
            box = robot.find(f"link[@name='{link}']/visual/geometry/box")
            self.assertEqual(float(box.get('size').split()[0]), length)
        for name in ('joint1', 'joint2'):
            joint = robot.find(f"joint[@name='{name}']")
            self.assertEqual(joint.find('axis').get('xyz'), '0 0 1')
            self.assertEqual(float(joint.find('limit').get('lower')), -math.pi)
            self.assertEqual(float(joint.find('limit').get('upper')), math.pi)


if __name__ == '__main__':
    unittest.main()
