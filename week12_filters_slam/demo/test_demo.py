import unittest
import numpy as np
import matplotlib
matplotlib.use('Agg')
from model import ParticleFilter, Scenario, ranges
from visualize import Visualization


class FilterTests(unittest.TestCase):
    def test_worked_weights(self):
        weights = np.ones(3)/3 * [.6, .3, .1]
        np.testing.assert_allclose(weights / weights.sum(), [.6, .3, .1])

    def test_measurement_and_no_position_change(self):
        f = ParticleFilter(np.random.default_rng(4))
        before = f.particles.copy()
        obs = ranges([2., 2.])
        expected = np.exp(-.5*np.sum(((ranges(before)-obs)/.15)**2, axis=1))
        f.correct(obs)
        np.testing.assert_array_equal(before, f.particles)
        np.testing.assert_allclose(f.weights, expected/expected.sum(), atol=1e-15)
        self.assertAlmostEqual(f.weights.sum(), 1)
        with self.assertRaises(ValueError):
            f.correct([np.nan, 1, 2])
        with self.assertRaises(ValueError):
            f.predict([1])

    def test_prediction_and_resampling(self):
        f = ParticleFilter(np.random.default_rng(3))
        before = f.particles.copy()
        f.predict([.25, 0])
        delta = f.particles - before
        np.testing.assert_allclose(delta.mean(axis=0), [.25, 0], atol=.015)
        self.assertGreater(delta.std(), .04)
        before = f.particles.copy()
        f.weights.fill(0)
        f.weights[17] = 1
        f.resample()
        np.testing.assert_array_equal(f.particles, np.repeat(before[17:18], 500, axis=0))
        np.testing.assert_allclose(f.weights, 1/500)

    def test_scenario_reproducibility(self):
        for sigma in [.15, .6]:
            a, b = Scenario(sigma), Scenario(sigma)
            for _ in range(96):
                a.advance()
                b.advance()
                np.testing.assert_array_equal(a.filter.particles, b.filter.particles)
                self.assertTrue(np.isfinite(a.filter.weights).all())
                self.assertAlmostEqual(a.filter.weights.sum(), 1)
            self.assertTrue(a.done)
            a.reset()
            np.testing.assert_array_equal(a.filter.particles, Scenario(sigma).filter.particles)
        low, high = Scenario(.15), Scenario(.6)
        for _ in range(96):
            low.advance()
            high.advance()
        np.testing.assert_array_equal(low.truth, high.truth)

    def test_controls(self):
        import matplotlib.pyplot as plt
        app = Visualization()
        app.buttons[0]._observers.process('clicked', None)
        self.assertEqual(app.scenario.stage, 'Prediction')
        app.buttons[1]._observers.process('clicked', None)
        app.tick()
        self.assertEqual(app.scenario.stage, 'Weighting')
        app.toggle()
        app.tick()
        self.assertEqual(app.scenario.stage, 'Weighting')
        app.radio.set_active(1)
        self.assertEqual(app.scenario.sigma, .6)
        self.assertEqual(app.scenario.stage, 'Initial belief')
        self.assertFalse(app.playing)
        app.next_stage()
        app.buttons[2]._observers.process('clicked', None)
        self.assertEqual(app.scenario.step, 0)
        plt.close(app.figure)


if __name__ == '__main__':
    unittest.main()
