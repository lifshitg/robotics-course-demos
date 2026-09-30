import os
os.environ['MPLBACKEND']='Agg'
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import numpy as np
from task import Task, scenarios, rollout, CONTROL_DT, STEPS
from expert import expert
from learning import Policy, train, load_dataset
from demo import collect, Playback, get_policy, evaluate


class DemoTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp=tempfile.TemporaryDirectory()
        cls.output=Path(cls.tmp.name)
        collect(cls.output)
        cls.policy,cls.metrics=train(cls.output/'dataset.npz')
        cls.policy.save(cls.output/'policy.npz')

    @classmethod
    def tearDownClass(cls):cls.tmp.cleanup()

    def test_model_axes_timing_observation_and_limits(self):
        task=Task(); case=dict(start=np.array([.1,.2]),target=np.array([.4,.6]),velocity=np.array([.2,-.1]))
        obs=task.reset(case)
        np.testing.assert_allclose(obs,[.3,.4,.2,-.1])
        self.assertEqual(task.model.nq,2)
        np.testing.assert_allclose(task.model.jnt_axis,[[1,0,0],[0,1,0]])
        self.assertEqual(task.model.opt.timestep,.01)
        zero=dict(start=np.zeros(2),target=np.ones(2)*.4,velocity=np.zeros(2))
        task.reset(zero); _, applied=task.step([20,0])
        np.testing.assert_allclose(applied,[10,0])
        self.assertGreater(task.data.qpos[0],0)
        self.assertEqual(task.data.qpos[1],0)
        self.assertAlmostEqual(task.data.time,CONTROL_DT)
        task.reset(zero);task.step([0,1])
        self.assertGreater(task.data.qpos[1],0)
        for a in [[np.nan,0],[1],[np.inf,0]]:
            with self.assertRaises(ValueError):task.step(a)

    def test_sampling_and_repeatability(self):
        a,b=scenarios(42,20),scenarios(42,20)
        for x,y in zip(a,b):
            for key in x:np.testing.assert_array_equal(x[key],y[key])
            self.assertGreaterEqual(np.linalg.norm(x['start']-x['target']),.2)
        self.assertFalse(np.array_equal(scenarios(7,1)[0]['start'],a[0]['start']))
        t=Task()
        x=rollout(t,expert,a[0]);y=rollout(t,expert,a[0])
        np.testing.assert_array_equal(x['positions'],y['positions'])
        self.assertAlmostEqual(t.data.time,5)

    def test_labels_split_and_fitted_policy(self):
        x,y,ids=load_dataset(self.output/'dataset.npz')
        self.assertEqual(x.shape,(25000,4))
        np.testing.assert_allclose(y,np.array([expert(obs) for obs in x]))
        self.assertEqual(set(ids[ids<80]),set(self.metrics['train_episodes']))
        self.assertTrue(set(self.metrics['train_episodes']).isdisjoint(self.metrics['validation_episodes']))
        self.assertLess(self.metrics['validation_action_mse'],1e-12)
        np.testing.assert_allclose(self.policy.weights,[[4,0,-3,0],[0,4,0,-3]],atol=1e-10)
        np.testing.assert_allclose(x[0],Task().reset(scenarios(7,1)[0]))

    def test_roundtrip_and_no_expert_at_execution(self):
        loaded=Policy.load(self.output/'policy.npz')
        obs=np.array([.2,.4,.1,-.1])
        np.testing.assert_array_equal(loaded(obs),self.policy(obs))
        with patch('expert.expert',side_effect=AssertionError('Learner consulted expert')):
            policy=get_policy('learner',self.output)
            self.assertTrue(rollout(Task(),policy,scenarios(42,1)[0])['success'])
        self.assertTrue(np.all(np.abs(loaded([100,-100,0,0]))<=10))

    def test_closed_loop_acceptance_and_export(self):
        result=evaluate(self.output)
        self.assertEqual(result['controllers']['expert']['successes'],20)
        self.assertGreaterEqual(result['controllers']['learner']['successes'],19)
        self.assertEqual(result['controllers']['zero']['successes'],0)
        self.assertGreater((self.output/'comparison.png').stat().st_size,10000)

    def test_malformed_dataset_and_missing_policy(self):
        path=self.output/'bad.npz'
        np.savez(path,observations=np.zeros((3,4)),actions=np.zeros((3,2)),episode_ids=np.arange(3))
        with self.assertRaises(ValueError):load_dataset(path)
        np.savez(path,observations=np.array([[np.nan]*4]),actions=np.zeros((1,2)),episode_ids=np.zeros(1,dtype=int))
        with self.assertRaises(ValueError):load_dataset(path)
        with self.assertRaisesRegex(ValueError,'collect and train'):Policy.load(self.output/'absent.npz')
        with self.assertRaises(ValueError):Policy(np.zeros((4,2)),np.zeros(2))

    def test_playback_controls(self):
        p=Playback(self.policy)
        initial=p.observation.copy()
        p.tick();self.assertEqual(p.steps,1)
        p.key(32);p.tick();self.assertEqual(p.steps,1)
        p.key(ord('R'));self.assertEqual(p.steps,0)
        np.testing.assert_array_equal(p.observation,initial)
        p.key(ord('N'));self.assertEqual(p.episode,1)
        self.assertTrue(p.paused)
        p.key(32)
        for _ in range(STEPS+3):p.tick()
        self.assertEqual(p.steps,STEPS)
        self.assertAlmostEqual(p.task.data.time,5)


if __name__=='__main__':unittest.main()
