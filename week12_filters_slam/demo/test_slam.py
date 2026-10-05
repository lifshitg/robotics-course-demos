"""Range-only SLAM regression and independent Bayesian checks."""
import unittest
from unittest.mock import patch
import numpy as np
import matplotlib
matplotlib.use('Agg')
from model import RangeOnlySLAM, Scenario, LANDMARKS, ranges
from visualize import Visualization


class SLAMTests(unittest.TestCase):
    def small_filter(self, count=2):
        return RangeOnlySLAM(np.random.default_rng(5), count=count, grid_axis=np.array([-1., 0., 1.]))

    def test_unknown_map_prior_and_truth_independence(self):
        a = self.small_filter()
        with patch('model.LANDMARKS', np.array([[999., 999.]])):
            b = self.small_filter()
        np.testing.assert_array_equal(a.map_probs, b.map_probs)
        self.assertFalse(hasattr(a, 'landmarks'))
        np.testing.assert_allclose(a.map_probs, 1/9)
        default = RangeOnlySLAM(np.random.default_rng(1), count=1)
        self.assertEqual(default.map_probs.shape, (1, 3, 6561))
        np.testing.assert_allclose(np.diff(default.grid_axis), .125)

    def test_enumerated_bayes_and_old_map_evidence(self):
        f = self.small_filter()
        f.particles[:] = [[0., 0.], [.7, .3]]
        f.weights[:] = [.3, .7]
        prior = np.arange(1, 10, dtype=float)
        prior /= prior.sum()
        f.map_probs[1, 0] = prior
        old = f.map_probs.copy()
        observation = np.array([.9, .5, 1.2])
        expected_maps = np.empty_like(old)
        evidence = np.empty((2, 3))
        # Explicit Python loops provide an independent small reference calculation.
        for i in range(2):
            for j in range(3):
                weighted = []
                for g, point in enumerate(f.grid_points):
                    distance = np.sqrt(sum((f.particles[i]-point)**2))
                    density = np.exp(-.5*((observation[j]-distance)/f.sigma)**2)/(f.sigma*np.sqrt(2*np.pi))
                    weighted.append(old[i, j, g]*density)
                evidence[i, j] = sum(weighted)
                expected_maps[i, j] = np.array(weighted)/sum(weighted)
        expected_weights = f.weights*evidence.prod(axis=1)
        expected_weights /= expected_weights.sum()
        positions = f.particles.copy()
        f.correct(observation)
        np.testing.assert_allclose(f.last_log_evidence, np.log(evidence), atol=1e-12)
        np.testing.assert_allclose(f.map_probs, expected_maps, atol=1e-12)
        np.testing.assert_allclose(f.weights, expected_weights, atol=1e-12)
        np.testing.assert_array_equal(f.particles, positions)
        np.testing.assert_allclose(f.map_probs.sum(axis=-1), 1)
        expected_marginal = (expected_maps[0]*expected_weights[0]+expected_maps[1]*expected_weights[1]).reshape(3,3,3)
        np.testing.assert_allclose(f.landmark_marginals, expected_marginal)

    def test_circular_first_range_and_multiple_views(self):
        f = RangeOnlySLAM(np.random.default_rng(2), count=1)
        f.particles[:] = [2., 2.]
        f.correct([2., 2., 2.])
        first = f.map_probs[0, 0].copy()
        for point in [[0., 2.], [4., 2.], [2., 0.], [2., 4.]]:
            index = np.flatnonzero(np.all(f.grid_points == point, axis=1))[0]
            self.assertAlmostEqual(first[index], first.max())
        entropy_first = -np.sum(first[first > 0]*np.log(first[first > 0]))
        target = np.array([0., 2.])
        for pose in [[3., 2.], [2., 3.], [3., 4.]]:
            f.particles[:] = pose
            reading = np.linalg.norm(np.array(pose)-target)
            f.correct([reading]*3)
        last = f.map_probs[0, 0]
        entropy_last = -np.sum(last[last > 0]*np.log(last[last > 0]))
        self.assertLess(entropy_last, entropy_first)
        self.assertLess(np.linalg.norm(f.landmark_means[0]-target), .1)

    def test_resampling_copies_maps_without_aliases(self):
        f = self.small_filter(3)
        f.map_probs[1, :, :] = 0
        f.map_probs[1, :, 4] = 1
        f.weights[:] = [0, 1, 0]
        old = f.map_probs.copy()
        indices = f.resample()
        np.testing.assert_array_equal(indices, [1, 1, 1])
        np.testing.assert_array_equal(f.map_probs, old[indices])
        f.map_probs[0, 0, 4] = .5
        self.assertEqual(f.map_probs[1, 0, 4], 1)
        self.assertEqual(old[1, 0, 4], 1)
        np.testing.assert_allclose(f.weights, 1/3)

    def test_prediction_and_invalid_inputs(self):
        f = self.small_filter()
        prior = f.map_probs.copy()
        f.predict([.25, 0])
        np.testing.assert_array_equal(f.map_probs, prior)
        for reading in [[np.nan, 1, 2], [1, 2], [1e308]*3]:
            with self.assertRaises(ValueError):
                f.correct(reading)
        np.testing.assert_array_equal(f.map_probs, prior)
        with self.assertRaises(ValueError):
            RangeOnlySLAM(np.random.default_rng(), grid_axis=[1, 0])
        with self.assertRaises(ValueError):
            Scenario(mode='moving')

    def test_controls_truth_and_reset_isolation(self):
        import matplotlib.pyplot as plt
        app = Visualization()
        app.radio.set_active(1)
        app.toggle()
        app.mode_radio.set_active(1)
        self.assertEqual(app.scenario.mode, 'slam')
        self.assertEqual(app.scenario.sigma, .6)
        self.assertFalse(app.playing)
        before = app.scenario.filter.particles.copy()
        app.truth_check.set_active(0)
        app.landmark_radio.set_active(2)
        self.assertFalse(app.show_truth)
        self.assertEqual(app.selected_landmark, 2)
        np.testing.assert_array_equal(app.scenario.filter.particles, before)
        app.next_stage()
        app.next_stage()
        self.assertEqual(app.scenario.stage, 'Weighting')
        app.reset()
        self.assertEqual(app.scenario.mode, 'slam')
        self.assertEqual(app.scenario.sigma, .6)
        np.testing.assert_array_equal(app.scenario.filter.particles, before)
        app.mode_radio.set_active(0)
        self.assertEqual(app.scenario.mode, 'localization')
        plt.close(app.figure)

    def test_full_runs_normalization_and_physical_comparability(self):
        truths = []
        for sigma in [.15, .6]:
            scenario = Scenario(sigma, mode='slam')
            initial = scenario.filter.particles.copy()
            for _ in range(96):
                scenario.advance()
                f = scenario.filter
                self.assertTrue(np.isfinite(f.map_probs).all())
                self.assertTrue(np.isfinite(f.weights).all())
                self.assertAlmostEqual(f.weights.sum(), 1)
                if scenario.stage == 'Weighting':
                    np.testing.assert_allclose(f.map_probs.sum(axis=-1), 1, atol=1e-12)
            self.assertTrue(scenario.done)
            np.testing.assert_allclose(f.landmark_marginals.sum(axis=(1,2)), 1)
            truths.append(scenario.truth.copy())
            localization = Scenario(sigma)
            for _ in range(96):
                localization.advance()
            np.testing.assert_array_equal(scenario.truth, localization.truth)
            scenario.reset()
            np.testing.assert_array_equal(scenario.filter.particles, initial)
        np.testing.assert_array_equal(truths[0], truths[1])


if __name__ == '__main__':
    unittest.main()
