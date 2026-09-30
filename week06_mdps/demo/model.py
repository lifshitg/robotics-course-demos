"""Known finite MDP: rewards belong to transitions; terminals give no later reward."""
from dataclasses import dataclass
import math
import numpy as np


@dataclass
class MDP:
    transitions: dict  # state -> action -> [(probability, next_state, reward)]
    terminals: frozenset
    gamma: float = 0.9

    def __post_init__(self):
        if not math.isfinite(self.gamma) or not 0 <= self.gamma < 1:
            raise ValueError('Discount must be finite and in [0, 1).')
        if not self.transitions or not self.terminals <= self.transitions.keys():
            raise ValueError('Terminal states must belong to a nonempty model.')
        for state, actions in self.transitions.items():
            if not actions:
                raise ValueError('Every state needs an action (stay for terminals).')
            for outcomes in actions.values():
                if not outcomes or not math.isclose(sum(p for p, _, _ in outcomes), 1, abs_tol=1e-12):
                    raise ValueError('Each transition distribution must sum to one.')
                for p, nxt, reward in outcomes:
                    if not math.isfinite(p) or not 0 <= p <= 1 or not math.isfinite(reward):
                        raise ValueError('Invalid probability or reward.')
                    if nxt not in self.transitions:
                        raise ValueError('Unknown next state.')
                    if state in self.terminals and (nxt != state or reward != 0):
                        raise ValueError('Terminals must be absorbing with zero reward.')

    @property
    def nonterminal(self):
        return [s for s in self.transitions if s not in self.terminals]

    def zeros(self):
        return dict.fromkeys(self.transitions, 0.0)


def delivery_mdp(failure=0.2):
    if not math.isfinite(failure) or not 0 <= failure <= 1:
        raise ValueError('Failure probability must be in [0, 1].')
    return MDP({
        'start': {'safe': [(1., 'detour', -1.)],
                  'risky': [(1-failure, 'delivered', 10.), (failure, 'failed', -10.)]},
        'detour': {'finish': [(1., 'delivered', 8.)]},
        'delivered': {'stay': [(1., 'delivered', 0.)]},
        'failed': {'stay': [(1., 'failed', 0.)]},
    }, frozenset({'delivered', 'failed'}))


def action_values(mdp, state, values):
    """Q_V(s,a) = sum P(s'|s,a) [r(s,a,s') + gamma V(s')]."""
    if set(values) != set(mdp.transitions) or not all(math.isfinite(v) for v in values.values()):
        raise ValueError('Supply one finite value per state.')
    if any(values[s] != 0 for s in mdp.terminals):
        raise ValueError('Terminal values must be zero.')
    return {a: sum(p*(r+mdp.gamma*values[nxt]) for p, nxt, r in outcomes)
            for a, outcomes in mdp.transitions[state].items()}


def greedy_policy(mdp, values, previous=None):
    policy = {}
    for s in mdp.nonterminal:
        q = action_values(mdp, s, values)
        best = max(q.values())
        # Retain a current maximizing action; otherwise use model insertion order.
        tied = [a for a in q if abs(q[a]-best) <= 1e-12]
        old = None if previous is None else previous.get(s)
        policy[s] = old if old in tied else tied[0]
    return policy


def backup(mdp, values):
    """Synchronous: every update reads the same old vector."""
    new = {s: max(action_values(mdp, s, values).values()) for s in mdp.transitions}
    delta = max(abs(new[s]-values[s]) for s in new)
    return new, delta


def check_settings(tolerance, max_iterations):
    if not math.isfinite(tolerance) or tolerance <= 0:
        raise ValueError('Tolerance must be finite and positive.')
    if not isinstance(max_iterations, int) or isinstance(max_iterations, bool) or max_iterations < 1:
        raise ValueError('Iteration limit must be a positive integer.')


def value_iteration(mdp, tolerance=1e-10, max_iterations=1000):
    check_settings(tolerance, max_iterations)
    values = mdp.zeros()
    history = [values.copy()]
    for _ in range(max_iterations):
        values, delta = backup(mdp, values)
        history.append(values.copy())
        if delta < tolerance:
            return values, greedy_policy(mdp, values), history
    raise RuntimeError('Value iteration reached its iteration limit without convergence.')


def evaluate_policy(mdp, policy):
    states = mdp.nonterminal
    if set(policy) != set(states) or any(policy[s] not in mdp.transitions[s] for s in states):
        raise ValueError('Policy must choose one valid action at every nonterminal state.')
    index = {s: i for i, s in enumerate(states)}
    matrix, rewards = np.eye(len(states)), np.zeros(len(states))
    for s, i in index.items():
        for p, nxt, reward in mdp.transitions[s][policy[s]]:
            rewards[i] += p*reward
            if nxt in index:
                matrix[i, index[nxt]] -= mdp.gamma*p
    result = mdp.zeros()
    result.update(zip(states, np.linalg.solve(matrix, rewards)))
    return result


def policy_iteration(mdp, initial=None, tolerance=1e-10, max_iterations=1000):
    check_settings(tolerance, max_iterations)
    policy = ({s: next(iter(mdp.transitions[s])) for s in mdp.nonterminal}
              if initial is None else initial.copy())
    trace = []
    for _ in range(max_iterations):
        values = evaluate_policy(mdp, policy)
        improved = greedy_policy(mdp, values, policy)
        trace.append((policy.copy(), values.copy(), improved.copy()))
        _, residual = backup(mdp, values)
        if improved == policy and residual < tolerance:
            return values, policy, trace
        policy = improved
    raise RuntimeError('Policy iteration reached its iteration limit without convergence.')
