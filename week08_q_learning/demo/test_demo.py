import os
os.environ['MPLBACKEND']='Agg'
import copy
from collections import deque
from types import SimpleNamespace
import tempfile
from pathlib import Path
import unittest
import numpy as np
from gridworld import START, GOAL, WALLS, MOVES, transition
from learning import Learner, update, TRAINING_EPSILON, evaluate
from demo import Demo, save_results


class Tests(unittest.TestCase):
    def test_environment(self):
        self.assertEqual(transition((0,0),0),((0,0),-1.,False))
        self.assertEqual(transition((1,0),1),((1,0),-1.,False))
        self.assertEqual(transition((0,3),1),(GOAL,10.,True))
        with self.assertRaises(ValueError):transition(GOAL,0)
        with self.assertRaises(ValueError):transition((1,1),0)

    def test_updates(self):
        q=np.zeros((5,5,4));q[0,1]=4
        d=update(q,(0,0),1,-1,(0,1),False)
        self.assertAlmostEqual(d['target'],2.8);self.assertAlmostEqual(d['new'],.56)
        q[GOAL]=999
        d=update(q,(0,3),1,10,GOAL,True)
        self.assertEqual(d['target'],10);self.assertEqual(d['new'],2)

    def test_truncation_and_constant_exploration(self):
        l=Learner();l.steps=99;l.q[:]=4
        d=l.step()
        self.assertTrue(d['truncated']);self.assertFalse(d['terminated'])
        self.assertAlmostEqual(d['target'],2.8)
        self.assertEqual(l.history[0]['length'],100)
        self.assertEqual(l.state,START);self.assertEqual(l.episode,1)
        self.assertEqual(TRAINING_EPSILON,.2)
        for episode in [0,100,1000]:
            learner=Learner();learner.episode=episode
            self.assertEqual(learner.step()["epsilon"],.2)

    def test_adjustable_epsilon(self):
        for value in [-.1,1.1,float("nan")]:
            with self.assertRaises(ValueError):Learner(epsilon=value)
        app=Demo()
        app.step();q=app.learner.q.copy()
        app.epsilon_slider.set_val(100)
        np.testing.assert_array_equal(q,app.learner.q)
        app.step();self.assertTrue(app.learner.last["exploratory"])
        app.epsilon_slider.set_val(0)
        app.step();self.assertFalse(app.learner.last["exploratory"])
        app.epsilon_slider.set_val(35)
        app.reset();self.assertEqual(app.learner.epsilon,.35)
        self.assertEqual(app.epsilon_slider.val,35)
        app.plt.close(app.fig)

    def test_reproducibility_and_evaluation_isolation(self):
        a,b=Learner(),Learner();a.train(100);b.train(100)
        np.testing.assert_array_equal(a.q,b.q)
        snapshot=copy.deepcopy(a.__dict__)
        evaluate(a.q)
        np.testing.assert_array_equal(a.q,snapshot['q'])
        self.assertEqual(a.rng.bit_generator.state,snapshot['rng'].bit_generator.state)
        self.assertEqual(a.state,snapshot['state']);self.assertEqual(a.history,snapshot['history'])
        a.step();b.step();self.assertEqual(a.last,b.last)

    def test_default_route_against_independent_bfs(self):
        queue=deque([(START,0)]);seen={START}
        while queue:
            s,d=queue.popleft()
            if s==GOAL:break
            for dr,dc in MOVES:
                n=(s[0]+dr,s[1]+dc)
                if all(0<=x<5 for x in n) and n not in WALLS and n not in seen:
                    seen.add(n);queue.append((n,d+1))
        self.assertEqual(d,8)
        for seed in [7,0,1,2,3]:
            l=Learner(seed);l.train(1000);e=evaluate(l.q)
            self.assertTrue(e['success']);self.assertEqual(e['length'],d)
            self.assertEqual(e['raw_return'],3)
            self.assertAlmostEqual(e['discounted_return'],sum(-.95**i for i in range(7))+10*.95**7)

    def test_controls_exports(self):
        app=Demo();app.step();self.assertIsNotNone(app.learner.last)
        app.select(SimpleNamespace(inaxes=app.grid,xdata=0,ydata=0))
        self.assertEqual(app.selected,(0,0))
        app.start_evaluation();before=app.learner.q.copy();app.tick()
        np.testing.assert_array_equal(before,app.learner.q)
        app.train_batch();self.assertIsNone(app.evaluation)
        # Tick executes the same path used by the GUI timer.
        app.batch_target=app.learner.episode+1;app.tick();self.assertIsNone(app.batch_target)
        with tempfile.TemporaryDirectory() as tmp:
            save_results(app.learner,Path(tmp));app.fig.savefig(Path(tmp)/'test.png')
            self.assertTrue((Path(tmp)/'metrics.json').exists())
        app.reset();self.assertEqual(app.learner.episode,0);self.assertTrue(np.all(app.learner.q==0))
        app.plt.close(app.fig)


if __name__=='__main__':unittest.main()
