# Week 8 — Q-Learning Presentation Plan

A compact explanation followed by a focused 17-minute demonstration.

## Slide 1 — Learning Through Interaction

- Week 6: known-model planning; Week 7: expert labels; today: reward feedback.
- Progression: state → Q-values → choose action → observe reward → update.

## Slide 2 — The RL Loop

- Identify agent, environment, state, action, next state, and reward in the maze.
- Deterministic movement still permits randomized exploration.

## Slide 3 — Reward Versus Return

- Ordinary move −1; goal arrival +10, ending the episode.
- Eight moves: raw sum 3; discounted return about .950119 at gamma=.95.
- Ask why optimizing immediate reward alone misses the goal's future benefit.

## Slide 4 — What Q(s,a) Estimates

- One value per state/action pair; future discounted return after that action.
- Q-learning targets greedy continuation. A value is an estimate, not a probability.

## Slide 5 — Choosing from a Q-Table

- Inspect four values and choose an argmax action.
- Zero initialization creates ties; initial arrows are not useful learned knowledge.

## Slide 6 — Exploration Versus Exploitation

- Epsilon-greedy: random action with probability epsilon, greedy otherwise.
- Exploration can choose a greedy action by chance.
- Default training epsilon is .2: 20% random exploration, 80% greedy selection. Use the slider to compare exploration levels; there is no automatic decay. Evaluation uses epsilon=0.

## Slide 7 — The Q-Learning Update

- Reveal target: `r + gamma max Q(s',a)`; terminal target is r only.
- Then reveal `new = old + alpha (target − old)`.
- Behavior can explore while the target uses a greedy maximum.

## Slide 8 — Calculate One Transition

- Old=0, r=−1, next max=4, gamma=.95, alpha=.2.
- Ask first; reveal target=2.8, new=.56.
- Compare a first goal update: target=10, new=2.

## Slide 9 — Training Versus Evaluation

- Training explores and updates; evaluation uses a frozen table and epsilon=0.
- Goal termination removes bootstrap; a collection time limit does not.
- Episode length and raw return differ from discounted return.

## Slide 10 — Predict the Route, Then Run

- Inspect zero values, step, train, and evaluate; predict how arrows change.
- Checkpoint: where do rewards come from, and which entry changes?
- Preview Week 9: state → neural policy → action for continuous control.

## Visuals Needed

- Maze with start/goal, greedy arrows, and selected cell's four Q-values.
- Old estimate → target → updated estimate calculation.
- [Before training](demo/before.png) and [after training](demo/after.png).
- Training episode lengths with truncated episodes marked.

## Live Demo Transition

“Predict the next Q update before I press Step.” Follow the [runbook](demo/README.md).
Source: Sutton and Barto, [Reinforcement Learning: An Introduction](https://www.incompleteideas.net/book/bookdraft2018mar21.pdf), Chapters 3 and 6.5. No professor slides were supplied for this week.
