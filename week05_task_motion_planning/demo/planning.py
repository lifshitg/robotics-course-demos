"""Parse real PDDL, search, check geometry, and refine candidate permissions."""
from dataclasses import dataclass
from pathlib import Path
import re
import tempfile

from pyperplan.pddl.parser import Parser
from pyperplan.grounding import ground
from pyperplan.search import breadth_first_search

from geometry import check_motion, load_scene, validate_scene

HERE = Path(__file__).resolve().parent


def load_task(problem_text=None, domain_path=None):
    text = problem_text if problem_text is not None else (HERE/'problem.pddl').read_text()
    with tempfile.TemporaryDirectory(prefix='week05-pddl-') as directory:
        problem = Path(directory)/'problem.pddl'
        problem.write_text(text)
        parser = Parser(str(domain_path or HERE/'domain.pddl'), str(problem))
        domain = parser.parse_domain()
        task = ground(parser.parse_problem(domain), remove_statics_from_initial_state=False,
                      remove_irrelevant_operators=False)
    task.operators.sort(key=lambda op: op.name)  # Reproducible BFS tie-breaking.
    return task


def location(state):
    values = [fact[1:-1].split()[1] for fact in state if fact.startswith('(robot-at ')]
    if len(values) != 1:
        raise ValueError('State must have exactly one robot location.')
    return values[0]


def loaded(state):
    return any(fact.startswith('(holding ') for fact in state)


def radius_for(scene, state):
    return scene['loaded_radius' if loaded(state) else 'empty_radius']


def visible_facts(state):
    return sorted(f for f in state if not f.startswith('(can-'))


@dataclass
class Validation:
    valid: bool
    states: list
    failed_index: int | None = None
    permission: str | None = None
    reason: str = ''
    radius: float | None = None


def validate_plan(task, plan, scene):
    state = frozenset(task.initial_state)
    states = [state]
    position = scene['locations'][location(state)]
    ok, reason = check_motion(scene, position, position, radius_for(scene,state))
    if not ok:
        return Validation(False, states, reason='Invalid initial footprint: '+reason)
    for i, op in enumerate(plan):
        if not op.applicable(state):
            raise ValueError(f'Unsatisfied PDDL preconditions: {op.name}')
        after = op.apply(state)  # Preconditions/effects come from PDDL, not duplicated Python.
        before_name, after_name = location(state), location(after)
        a, b = scene['locations'][before_name], scene['locations'][after_name]
        action = op.name[1:-1].split()[0]
        if action not in ('move-empty','move-loaded','pick','place'):
            raise ValueError(f'Unsupported geometric action: {action}')
        radius = max(radius_for(scene,state), radius_for(scene,after))
        ok, reason = check_motion(scene,a,b,radius)
        if not ok:
            permission = None
            if action.startswith('move-'):
                mode = 'loaded' if loaded(state) else 'empty'
                permission = f'(can-{mode} {before_name} {after_name})'
            return Validation(False, states, i, permission, reason, radius)
        state = frozenset(after)
        states.append(state)
    if not task.goal_reached(state):
        raise ValueError('Plan finishes without satisfying the PDDL goal.')
    return Validation(True, states, reason='Every action is geometrically valid.')


@dataclass
class Attempt:
    task: object
    plan: list
    validation: Validation


@dataclass
class Result:
    status: str
    attempts: list
    rejected: list
    initial_state: frozenset
    message: str


def refine_problem(text, rejected):
    # The supplied STRIPS problem has one :init section, followed by :goal.
    prefix, rest = text.split('(:init',1)
    initial, suffix = rest.split('(:goal',1)
    for fact in rejected:
        initial, count = re.subn(re.escape(fact), '', initial)
        if count != 1:
            raise ValueError(f'Expected one initial permission: {fact}')
    return prefix+'(:init'+initial+'(:goal'+suffix


def solve(scene=None, problem_text=None):
    scene = load_scene() if scene is None else scene
    validate_scene(scene)
    original = problem_text if problem_text is not None else (HERE/'problem.pddl').read_text()
    original_task = load_task(original)
    known = set(scene['locations'])
    for fact in original_task.initial_state:
        tokens = fact[1:-1].split()
        if tokens[0].startswith('can-'):
            if any(name not in known for name in tokens[1:]):
                raise ValueError('PDDL permission names a location absent from the scene.')
            if not any(set(tokens[1:]) == set(pair) for pair in scene['connections']):
                raise ValueError('PDDL permission has no designated scene connection.')
        elif tokens[0] in ('robot-at','package-at') and tokens[-1] not in known:
            raise ValueError('PDDL state names a location absent from the scene.')
    permissions = {f for f in original_task.initial_state if f.startswith('(can-')}
    rejected, attempts = [], []
    initial = frozenset(original_task.initial_state)
    for _ in range(len(permissions)+1):
        task = load_task(refine_problem(original,rejected))
        plan = breadth_first_search(task)
        if plan is None:
            return Result('symbolic-failure',attempts,rejected,initial,
                          'No symbolic plan with the remaining designated connections.')
        validation = validate_plan(task,plan,scene)
        attempts.append(Attempt(task,plan,validation))
        if validation.valid:
            return Result('success',attempts,rejected,initial,'Validated plan found.')
        if validation.permission is None:
            return Result('geometric-failure',attempts,rejected,initial,
                          'Footprint check failed outside a motion connection: '+validation.reason)
        if validation.permission in rejected:
            raise RuntimeError('Repeated rejection without progress.')
        rejected.append(validation.permission)
    return Result('limit',attempts,rejected,initial,'Finite refinement bound reached.')


def print_trace(result):
    for i, attempt in enumerate(result.attempts,1):
        print(f'Candidate {i}: {len(attempt.plan)} actions')
        for j, op in enumerate(attempt.plan):
            print(f'  {j+1}. {op.name}')
        v = attempt.validation
        if v.valid:
            print('  VALID: '+v.reason)
        else:
            print(f'  REJECT action {None if v.failed_index is None else v.failed_index+1}: {v.reason}')
            print(f'  Footprint radius: {v.radius}; remove only {v.permission}')
    print(result.status+': '+result.message)
