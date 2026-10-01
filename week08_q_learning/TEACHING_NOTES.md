# Week 8 — Q-Learning: Learning Action Values from Experience

## Goal

Explain and demonstrate **state → Q-values → choose action → observe reward → update**. Students should calculate one update and distinguish exploration during training from greedy evaluation.

## Context / Recap

Week 6 used a known transition model for Bellman backups. Week 7 learned actions from expert labels. Here an agent learns from reward-bearing transitions, without expert actions or a transition model inside the learner. The environment implements the dynamics; the agent samples it.

Follow [TA_plan.md](../TA_plan.md), Session 8. No professor lecture has been supplied for this week. Preparation reference: Sutton and Barto, [Reinforcement Learning: An Introduction](https://www.incompleteideas.net/book/bookdraft2018mar21.pdf), Chapter 3 (agent–environment framework) and Section 6.5 (Q-learning).

## Core Explanation

### Environment and returns

A deterministic 5×5 maze uses `(row,column)`, row 0 at the top. Start `(4,0)`, goal `(0,4)`. Walls: `(1,1)`, `(1,2)`, `(2,2)`, `(3,1)`, `(3,3)`. Actions are up/right/down/left. Boundary/wall attempts stay put and earn −1. Other ordinary moves also earn −1; entering the goal earns +10 **instead of** −1 and ends the episode.

Immediate reward describes one transition. Discounted return is the sum of future rewards weighted by powers of gamma. An eight-move route receives seven −1 rewards followed by +10: raw sum 3; discounted return at gamma=.95 is approximately .950119. Do not confuse either with success rate.

### Action values and exploration

`Q(s,a)` estimates discounted return from taking action a in state s and then following the target behavior. Q-learning targets greedy continuation. Its exploratory behavior can choose a different action from the maximizing action in the update target.

Epsilon-greedy chooses a uniformly random action with probability epsilon; otherwise it chooses an action maximizing Q. Random exploration can happen to select a greedy action too. Training breaks greedy ties randomly; evaluation uses fixed up/right/down/left order. At zero initialization the displayed arrows therefore all point up; they are arbitrary ties, not learned expertise.

### Update and worked answers

```text
target = reward + gamma × max_a Q(next_state,a)
Q(state,action) = old_Q + alpha × (target − old_Q)
```

For true termination, target is reward only. Interpret alpha as how far to move toward the new target; gamma discounts later rewards.

- Old Q=0, reward=−1, next maximum=4, gamma=.95: target=2.8. With alpha=.2, new Q=.56.
- First goal transition: old Q=0, reward=10, terminal target=10, new Q=2.
- Hitting the 100-step cap is **truncation**, not reaching a terminal state. Keep the bootstrap term, then restart data collection from the start. Time is not part of this task's state; the cap is an external collection limit.

Defaults: zero Q-table, alpha=.2, gamma=.95, seed 7, 1,000 training episodes. Training epsilon defaults to 0.2: 20% random exploration and 80% greedy selection. The slider changes it for subsequent training actions without clearing Q-values; it stays fixed until changed manually. Evaluation uses epsilon=0. These finite-run settings are practical teaching defaults, not a general convergence guarantee.

## Live Demo

Use the [runbook](demo/README.md).

- **4 min:** inspect maze and zero Q-values. Step through individual transitions; ask students to predict old/target/new values.
- **4 min:** inspect a cell, train 100 episodes, and watch episode lengths and truncation marks.
- **5 min:** continue training toward 1,000 episodes; evaluate the greedy route. Show that training can take extra exploratory moves even after a good route is learned.
- **4 min:** compare initial/final figures, raw versus discounted return, and reset behavior.

Expected default outcome: success in 8 moves, raw return 3, discounted return .950119. The default route goes right across the bottom row and up the right column. Other seeds may choose another equally short route.

Checkpoint answers: the environment supplies reward, not a correct action label; the max chooses the greedy target action; exploration selects behavior; evaluation changes neither Q nor the training random generator. Repeating a deterministic evaluation from the same start is not independent evidence of robustness.

## Timing

| Part | Minutes |
|---|---:|
| Recap: known models, expert labels, and reward feedback | 5 |
| RL loop, return, and action values | 8 |
| Exploration and one worked Q-learning update | 10 |
| Step through learning, train, and evaluate | 17 |
| Checkpoint and transition to Week 9 | 5 |
| **Total** | **45** |

## Common Questions / Problems

- **Is this value iteration?** No. Updates use sampled transitions and change one visited state/action entry at a time.
- **Does the agent see the map?** The viewer shows it to us. The learner receives state, reward, and next-state samples; it does not plan over the map.
- **Why can evaluation fail early?** Values are incomplete, and greedy tie-breaking can repeatedly hit a boundary.
- **Why is a random action sometimes the best action?** Exploration samples all four actions, including greedy ones.
- **Does evaluation improve Q?** No; it freezes the learned table and preserves all training state.
- **Why does the blue marker jump to start?** Training immediately resets after termination/truncation. The last-transition panel still shows the final move.
- **No GUI?** Use headless exports and the saved figures.

## Homework Connection

Connect to HW2's Gridworld/search ideas while distinguishing learning from search using a known map. Reinforce HW3's Bellman vocabulary. This introduces reward-based policy improvement for HW4; it creates no new assignment requirement. Week 9 moves toward neural policies for continuous actions. No DQN, policy-gradient derivations, or other RL implementations this week.

## Preparation Checklist

- [ ] Calculate both numerical updates and the eight-step returns.
- [ ] Run tests and seed-7 headless training; confirm an eight-move greedy route.
- [ ] Rehearse Step, batch training, cell selection, Evaluate, and Reset.
- [ ] Explain fixed tie-order arrows versus randomized training ties.
- [ ] Explain termination versus truncation without turning it into a long digression.
- [ ] Keep before/after figures available and rehearse the 17-minute demo.
