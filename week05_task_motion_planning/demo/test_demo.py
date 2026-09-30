import copy
from pathlib import Path
import re
import unittest

import matplotlib
matplotlib.use('Agg')

from geometry import load_scene, validate_scene, check_motion, segment_rectangle_distance
from planning import (HERE, load_task, solve, validate_plan, refine_problem,
                      location, loaded, radius_for)
from pyperplan.search import breadth_first_search


class GeometryTests(unittest.TestCase):
    def setUp(self):
        self.scene=load_scene()

    def test_shortcut_depends_on_load(self):
        a,b=self.scene['locations']['pickup'],self.scene['locations']['delivery']
        self.assertTrue(check_motion(self.scene,a,b,.12)[0])
        self.assertFalse(check_motion(self.scene,a,b,.25)[0])
        self.assertFalse(check_motion(self.scene,a,b,.2)[0])  # Tangency.

    def test_distances_and_boundaries(self):
        rect=(2,3,2,3)
        self.assertEqual(segment_rectangle_distance((0,2.5),(5,2.5),rect),0)
        self.assertAlmostEqual(segment_rectangle_distance((0,1),(5,1),rect),1)
        self.assertAlmostEqual(segment_rectangle_distance((1,1),(1,1),rect),2**.5)
        self.assertFalse(check_motion(self.scene,(.12,1),(1,1),.12)[0])
        self.assertTrue(check_motion(self.scene,(.13,1),(1,1),.12)[0])

    def test_invalid_scene_and_motion(self):
        for key,value in [('empty_radius',-1),('loaded_radius',float('nan')),
                          ('size',[0,6]),('obstacles',[[3,2,0,1]]),
                          ('connections',[['pickup','missing']])]:
            scene=copy.deepcopy(self.scene);scene[key]=value
            with self.subTest(key=key),self.assertRaises(ValueError):validate_scene(scene)
        with self.assertRaises(ValueError):check_motion(self.scene,(float('nan'),0),(1,1),.12)


class PlanningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.scene=load_scene();cls.result=solve(cls.scene)

    def test_expected_plans_and_refinement(self):
        result=self.result
        self.assertEqual(result.status,'success')
        self.assertEqual([len(a.plan) for a in result.attempts],[4,6])
        self.assertEqual(result.attempts[0].validation.failed_index,2)
        self.assertEqual(result.rejected,['(can-loaded pickup delivery)'])
        self.assertTrue(result.attempts[-1].task.goal_reached(result.attempts[-1].validation.states[-1]))
        text=refine_problem((HERE/'problem.pddl').read_text(),result.rejected)
        self.assertIn('(can-empty pickup delivery)',text)
        self.assertIn('(can-loaded delivery pickup)',text)
        self.assertNotIn('(can-loaded pickup delivery)',text)

    def test_pddl_preconditions_and_effects(self):
        task=load_task();state=task.initial_state
        by_name={op.name:op for op in task.operators}
        self.assertFalse(by_name['(pick parcel pickup)'].applicable(state))
        state=by_name['(move-empty delivery pickup)'].apply(state)
        state=by_name['(pick parcel pickup)'].apply(state)
        self.assertIn('(holding parcel)',state)
        self.assertNotIn('(hand-empty)',state)
        self.assertNotIn('(package-at parcel pickup)',state)
        self.assertFalse(by_name['(move-empty pickup delivery)'].applicable(state))
        state=by_name['(move-loaded parcel pickup delivery)'].apply(state)
        state=by_name['(place parcel delivery)'].apply(state)
        self.assertIn('(hand-empty)',state)
        self.assertNotIn('(holding parcel)',state)
        self.assertTrue(task.goal_reached(state))

    def test_validation_is_hypothetical_and_authored_problem_unchanged(self):
        before=(HERE/'problem.pddl').read_bytes()
        task=load_task();state=task.initial_state
        validate_plan(task,breadth_first_search(task),self.scene)
        self.assertEqual(task.initial_state,state)
        self.assertEqual(before,(HERE/'problem.pddl').read_bytes())
        self.assertEqual(location(self.result.initial_state),'delivery')
        self.assertFalse(loaded(self.result.initial_state))

    def test_validated_states_and_dense_route_check(self):
        states=self.result.attempts[-1].validation.states
        for state in states:
            self.assertEqual(sum(f.startswith('(robot-at ') for f in state),1)
            self.assertEqual(sum(f.startswith('(package-at parcel ') for f in state)+int(loaded(state)),1)
            self.assertEqual('(hand-empty)' in state,not loaded(state))
        for a,b in zip(states,states[1:]):
            start,end=self.scene['locations'][location(a)],self.scene['locations'][location(b)]
            r=max(radius_for(self.scene,a),radius_for(self.scene,b))
            for i in range(101):
                p=tuple(x+(y-x)*i/100 for x,y in zip(start,end))
                self.assertTrue(check_motion(self.scene,p,p,r)[0])

    def test_growth_at_pick_is_checked(self):
        scene=copy.deepcopy(self.scene)
        scene['obstacles'].append([.9,1.1,3.2,3.3])
        task=load_task();v=validate_plan(task,breadth_first_search(task),scene)
        self.assertFalse(v.valid)
        self.assertEqual(v.failed_index,1)
        self.assertIsNone(v.permission)
        self.assertEqual(v.radius,.25)

    def test_failures_and_finite_bound(self):
        text=re.sub(r'\(can-(?:empty|loaded) [^()]+\)','',(HERE/'problem.pddl').read_text())
        self.assertEqual(solve(problem_text=text).status,'symbolic-failure')
        scene=copy.deepcopy(self.scene);scene['loaded_radius']=.7
        result=solve(scene)
        self.assertEqual(result.status,'symbolic-failure')
        self.assertEqual(len(result.rejected),len(set(result.rejected)))
        self.assertLessEqual(len(result.attempts),16)
        scene=copy.deepcopy(self.scene);scene['obstacles'].append([4.9,5.1,2.9,3.1])
        self.assertEqual(solve(scene).status,'geometric-failure')


class InterfaceTests(unittest.TestCase):
    def test_stages_execution_and_reset(self):
        from demo import Demo
        app=Demo()
        try:
            original=app.execution_state
            app.next_stage();app.next_stage()
            self.assertEqual(app.stage,2)
            self.assertEqual(app.execution_state,original)
            self.assertAlmostEqual(app.robot.radius,.25)
            app.next_stage();app.next_stage();app.toggle_play()
            app.advance(4.6)  # Empty crossing, then pick.
            self.assertTrue(loaded(app.execution_state))
            self.assertAlmostEqual(app.robot.radius,.25)
            app.advance(.5)
            self.assertAlmostEqual(app.parcel.get_xdata()[0],app.robot.center[0])
            self.assertAlmostEqual(app.parcel.get_ydata()[0],app.robot.center[1])
            app.toggle_play();position=app.position;app.advance(1)
            self.assertEqual(app.position,position)
            app.toggle_play();app.advance(100)
            self.assertTrue(app.final.task.goal_reached(app.execution_state))
            self.assertFalse(app.playing)
            self.assertAlmostEqual(app.robot.radius,.12)
            self.assertIn('GOAL REACHED',app.text.get_text())
            app.reset()
            self.assertEqual(app.stage,0);self.assertEqual(app.execution_state,original)
            app.fig.canvas.draw()
        finally:app.plt.close(app.fig)


if __name__=='__main__':unittest.main()
