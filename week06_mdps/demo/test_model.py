import math
import os
os.environ['MPLBACKEND'] = 'Agg'
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from model import (MDP, delivery_mdp, action_values, backup, evaluate_policy,
                   greedy_policy, value_iteration, policy_iteration)


class ModelTests(unittest.TestCase):
    def test_worked_sweeps(self):
        m = delivery_mdp()
        v0 = m.zeros()
        v1, _ = backup(m, v0)
        v2, _ = backup(m, v1)
        self.assertEqual(v0, m.zeros())
        self.assertEqual(v1, dict(start=6, detour=8, delivered=0, failed=0))
        self.assertAlmostEqual(v2['start'], 6.2)
        self.assertEqual(greedy_policy(m,v1)['start'], 'safe')
        self.assertEqual(action_values(m,'start',v0)['safe'], -1)

    def test_policy_evaluation_and_improvement(self):
        m = delivery_mdp()
        p = {'start':'risky', 'detour':'finish'}
        v = evaluate_policy(m,p)
        self.assertEqual(v['start'],6)
        self.assertEqual(v['detour'],8)
        result, policy, trace = policy_iteration(m,p)
        self.assertEqual([t[0]['start'] for t in trace],['risky','safe'])
        self.assertAlmostEqual(result['start'],6.2)
        self.assertEqual(policy['start'],'safe')
        self.assertEqual(p['start'],'risky')

    def test_both_solvers_and_terminal_behavior(self):
        for p, expected, value in [(.2,'safe',6.2),(.1,'risky',8)]:
            m = delivery_mdp(p)
            v, pi, _ = value_iteration(m)
            w, pj, _ = policy_iteration(m,{'start':'risky','detour':'finish'})
            self.assertEqual(pi,pj)
            self.assertEqual(pi['start'],expected)
            self.assertAlmostEqual(v['start'],value)
            for s in v:self.assertAlmostEqual(v[s],w[s])
            for s in m.terminals:
                self.assertEqual(v[s],0)
                self.assertEqual(m.transitions[s]['stay'],[(1.,s,0.)])

    def test_ties_and_cyclic_evaluation(self):
        m = delivery_mdp(.19)  # risky=6.2, equal to safe
        v = evaluate_policy(m,{'start':'risky','detour':'finish'})
        self.assertEqual(greedy_policy(m,v,{'start':'risky','detour':'finish'})['start'],'risky')
        cyc = MDP({'s': {'wait':[(1.,'s',1.)]}},frozenset())
        self.assertAlmostEqual(evaluate_policy(cyc,{'s':'wait'})['s'],10)
        self.assertAlmostEqual(value_iteration(cyc)[0]['s'],10,places=8)

    def test_invalid_inputs_and_iteration_limits(self):
        for p in [-.1,1.1,math.nan,math.inf]:
            with self.assertRaises(ValueError):delivery_mdp(p)
        for gamma in [1,-1,math.nan]:
            with self.assertRaises(ValueError):MDP({'s':{'a':[(1,'s',0)]}},frozenset(),gamma)
        for outcomes in [[(.9,'s',0)],[(1,'unknown',0)],[(1,'s',math.nan)],[(1.1,'s',0),(-.1,'s',0)]]:
            with self.assertRaises(ValueError):MDP({'s':{'a':outcomes}},frozenset())
        with self.assertRaises(ValueError):MDP({'s':{'a':[(1,'s',1)]}},frozenset({'s'}))
        m=delivery_mdp()
        with self.assertRaises(ValueError):evaluate_policy(m,{'start':'safe'})
        with self.assertRaises(ValueError):action_values(m,'start',{'start':0})
        for solver in [value_iteration,policy_iteration]:
            with self.assertRaises(ValueError):solver(m,tolerance=0)
            with self.assertRaises(ValueError):solver(m,max_iterations=0)
        with self.assertRaises(RuntimeError):value_iteration(m,max_iterations=1)
        with self.assertRaises(RuntimeError):policy_iteration(m,{'start':'risky','detour':'finish'},max_iterations=1)


class InterfaceTests(unittest.TestCase):
    def test_controls(self):
        from demo import Demo
        app=Demo()
        app.buttons[0]._observers.process('clicked',None)
        self.assertEqual(app.values['start'],6)
        app.next_backup()
        self.assertAlmostEqual(app.values['start'],6.2)
        app.solve()
        self.assertLess(app.delta,1e-10)
        app.selector.set_active(1)
        self.assertEqual(app.failure,.1)
        self.assertEqual(app.iteration,0)
        app.solve()
        self.assertEqual(app.values['start'],8)
        app.reset()
        self.assertEqual(app.iteration,0)
        self.assertEqual(app.failure,.1)
        app.fig.canvas.draw()
        app.plt.close(app.fig)

    def test_cli_and_export(self):
        script=Path(__file__).with_name('demo.py')
        for p, expected in [('0.2','safe'),('0.1','risky')]:
            proc=subprocess.run([sys.executable,str(script),'--headless','--failure',p],capture_output=True,text=True,check=True)
            self.assertIn("'start': '"+expected+"'",proc.stdout)
        with tempfile.TemporaryDirectory() as d:
            path=Path(d)/'figure.png'
            subprocess.run([sys.executable,str(script),'--export',str(path)],capture_output=True,check=True)
            self.assertGreater(path.stat().st_size,10000)


if __name__=='__main__':unittest.main()
