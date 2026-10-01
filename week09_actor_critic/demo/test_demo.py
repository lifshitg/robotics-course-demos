import os
os.environ.setdefault('MUJOCO_GL','egl')
os.environ.setdefault('MPLBACKEND','Agg')
import copy
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import numpy as np
import torch
from torch.distributions import TransformedDistribution,TanhTransform,AffineTransform
from networks import ActorCritic
from algorithm import make_env,return_targets,losses,evaluate,Collector
from train import save_checkpoint,load_checkpoint

torch.set_num_threads(1)


class Tests(unittest.TestCase):
    def test_environment_and_actions(self):
        env=make_env()
        try:
            obs,_=env.reset(seed=4)
            self.assertEqual(obs.shape,(4,));self.assertEqual(env.spec.max_episode_steps,1000)
            np.testing.assert_array_equal(env.action_space.low,[-3]);np.testing.assert_array_equal(env.action_space.high,[3])
            m=ActorCritic();x=torch.randn(100,4)
            actions,z=m.sample(x)
            self.assertTrue(torch.isfinite(actions).all());self.assertTrue((actions.abs()<=3).all())
            self.assertEqual(m.value(x).shape,(100,))
            env.unwrapped.set_state(np.array([0.,.3]),np.zeros(2))
            _,reward,terminated,_,_=env.step(np.zeros(1))
            self.assertTrue(terminated);self.assertEqual(reward,0)
        finally:env.close()

    def test_log_density(self):
        m=ActorCritic();x=torch.zeros(2,4);z=torch.tensor([[.3],[-.6]])
        ref=TransformedDistribution(m.distribution(x),[TanhTransform(),AffineTransform(0,3)])
        torch.testing.assert_close(m.log_probability(x,z),ref.log_prob(3*z.tanh()).sum(-1))
        self.assertTrue(torch.isfinite(m.log_probability(x,torch.tensor([[50.],[-50.]]))).all())

    def test_return_targets(self):
        r=torch.tensor([[1.]])
        f=torch.tensor([[False]]);t=~f
        result=return_targets(r,f,f,torch.tensor([[6.]]))
        self.assertAlmostEqual(result.item(),6.94,places=5)
        self.assertAlmostEqual(result.item()-5,1.94,places=5)
        self.assertEqual(return_targets(r,t,f,torch.tensor([[99.]])).item(),1)
        # Truncation uses its own final-observation value, not the reset episode.
        r=torch.tensor([[1.],[100.]])
        target=return_targets(r,torch.tensor([[False],[True]]),torch.tensor([[True],[False]]),torch.tensor([[6.],[999.]]))
        self.assertAlmostEqual(target[0].item(),6.94,places=5)
        self.assertEqual(target[1].item(),100)
        target=return_targets(torch.ones(3,1),torch.zeros(3,1,dtype=torch.bool),torch.zeros(3,1,dtype=torch.bool),torch.tensor([[0.],[0.],[2.]]))
        self.assertAlmostEqual(target[0].item(),1+.99+.99**2+.99**3*2,places=5)

    def test_collector_uses_final_observation_before_reset(self):
        class FakeEnv:
            def reset(self,seed=None):return np.array([42.,0,0,0]),{}
            def step(self,action):return np.array([6.,0,0,0]),1.,False,True,{}
            def close(self):pass
        with patch('algorithm.make_env',side_effect=FakeEnv):
            collector=Collector(7,1)
            model=ActorCritic()
            model.value=lambda obs:obs[:,0]
            try:
                batch=collector.collect(model,steps=1)
                self.assertEqual(batch['next_value'].item(),6.)
                self.assertAlmostEqual(batch['targets'].item(),6.94,places=5)
                self.assertEqual(collector.obs[0,0],42.)
            finally:collector.close()

    def test_gradient_separation(self):
        m=ActorCritic();x=torch.randn(5,4);_,z=m.sample(x)
        targets=torch.ones(5,requires_grad=True)
        al,cl,_=losses(m,x,z,targets)
        al.backward()
        self.assertTrue(any(p.grad is not None for p in m.actor.parameters()))
        self.assertTrue(all(p.grad is None for p in m.critic.parameters()))
        self.assertIsNone(targets.grad)
        m.zero_grad();cl.backward()
        self.assertTrue(all(p.grad is None for p in m.actor.parameters()))
        self.assertTrue(any(p.grad is not None for p in m.critic.parameters()))
        self.assertIsNone(targets.grad)

    def test_roundtrip_and_evaluation_isolation(self):
        m=ActorCritic();x=torch.randn(4,4)
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'test.pt';save_checkpoint(p,m,40,7)
            restored,meta=load_checkpoint(p)
            torch.testing.assert_close(m.deterministic(x),restored.deterministic(x))
            self.assertEqual(meta['steps'],40)
        collector=Collector(7,2)
        try:
            params=copy.deepcopy(m.state_dict());rng=torch.get_rng_state().clone()
            state=collector.obs.copy();time=[e.unwrapped.data.time for e in collector.envs]
            evaluate(m,[20000,20001])
            torch.testing.assert_close(rng,torch.get_rng_state())
            for k,v in params.items():torch.testing.assert_close(v,m.state_dict()[k])
            np.testing.assert_array_equal(state,collector.obs)
            self.assertEqual(time,[e.unwrapped.data.time for e in collector.envs])
            batch=collector.collect(m)
            self.assertEqual(batch['targets'].shape,(5,2))
            self.assertFalse(batch['targets'].requires_grad)
        finally:collector.close()

    def test_classroom_checkpoint(self):
        root=Path(__file__).with_name('classroom')
        a,_=load_checkpoint(root/'initial.pt');b,_=load_checkpoint(root/'trained.pt')
        initial=evaluate(a);trained=evaluate(b)
        self.assertGreater(trained['mean_length'],initial['mean_length'])
        self.assertGreaterEqual(trained['mean_length'],900)

    def test_playback_controls(self):
        from watch import Playback
        m=ActorCritic();p=Playback({'initial':m,'trained':m})
        try:
            original=p.obs.copy();p.tick();self.assertEqual(p.steps,0)
            p.paused=False;p.tick();self.assertEqual(p.steps,1)
            p.paused=True;p.tick();self.assertEqual(p.steps,1)
            p.reset();np.testing.assert_array_equal(original,p.obs)
            p.select('trained');np.testing.assert_array_equal(original,p.obs)
            p.next_episode();self.assertEqual(p.episode,1)
        finally:p.close()


if __name__=='__main__':unittest.main()
