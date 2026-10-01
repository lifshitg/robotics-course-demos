"""Deterministic teaching environment; no planning algorithm lives here."""
START = (4, 0)
GOAL = (0, 4)
WALLS = frozenset({(1, 1), (1, 2), (2, 2), (3, 1), (3, 3)})
MOVES = ((-1, 0), (0, 1), (1, 0), (0, -1))
NAMES = ('up', 'right', 'down', 'left')


def valid(state):
    return len(state) == 2 and all(isinstance(x, int) for x in state) and all(0 <= x < 5 for x in state) and state not in WALLS


def transition(state, action):
    if not valid(state) or state == GOAL:
        raise ValueError('Expected a free nonterminal state.')
    if action not in range(4):
        raise ValueError('Action must be 0, 1, 2, or 3.')
    dr, dc = MOVES[action]
    nxt = (state[0]+dr, state[1]+dc)
    if not valid(nxt):
        nxt = state
    terminated = nxt == GOAL
    return nxt, 10. if terminated else -1., terminated
