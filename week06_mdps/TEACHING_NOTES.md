# Week 6 — MDPs: From Actions to Policies

## Goal

- Distinguish an action sequence from a policy for observed states.
- Calculate a Bellman backup and explain policy evaluation, value iteration (VI), and policy iteration (PI).
- Reinforce the professor's lecture through calculations; reserve only five minutes for the visualization.

## Context / Recap

Week 5 assumed deterministic symbolic outcomes and checked geometry. Here a known stochastic model gives several possible outcomes of one action. We observe which state actually occurs and consult a policy. A deterministic policy can operate in a stochastic world.

Follow [TA_plan.md](../TA_plan.md), Session 6, and the professor's `Class7-MDPs.pdf` (original location: `/home/gilad/Downloads/Class7-MDPs.pdf`). Reference **printed slide numbers**, not PDF page indices; repeated builds share numbers. The PDF is not copied into this repository. Its classroom prompts are reference material.

Source map: definitions/policies 7–15; return/value 19–21; expectation/evaluation 25–29; Q and optimality 30–33; VI 41–44; PI 54–55. Slides 50–51 show **fixed random-policy evaluation**, despite the “VI Example” headings. Explain that difference rather than reproducing the heading. LP, occupancy measures, asynchronous DP, and modified PI are optional preparation reading.

## Core Explanation

### One shared robot MDP

Fully observed states: start, detour, delivered, failed. Gamma is 0.9.

| State/action | Next state | Probability | Transition reward |
|---|---|---:|---:|
| start / safe | detour | 1 | −1 |
| start / risky | delivered | 0.8 | +10 |
| start / risky | failed | 0.2 | −10 |
| detour / finish | delivered | 1 | +8 |
| either terminal / stay | same terminal | 1 | 0 |

Terminal values are zero. Delivery/failure rewards are paid **on arrival once**, not repeatedly at the terminal. The reliable route's smaller delivery reward is an explicit modeled route preference. These are illustrative rewards, not measured robot costs.

The current state must contain all information needed to predict the next-state/reward distribution given an action: this is the Markov assumption. For example, if battery charge changes success probabilities, location alone may be insufficient. Here the probabilities depend only on the listed state/action.

### Return, value, and action value

Use the professor's indexing: reward R_t follows action A_t.

- Trajectory return: `G_t = R_t + gamma R_(t+1) + gamma² R_(t+2) + ...`.
- `V^pi(s) = E_pi[G_t | S_t=s]` averages over outcomes while following pi.
- Transition reward `r(s,a,s')` gives expected immediate reward `R(s,a) = sum_s' P(s'|s,a) r(s,a,s')`, matching the professor's notation.
- `Q_V(s,a) = sum_s' P(s'|s,a) [r(s,a,s') + gamma V(s')]`.
- Fixed deterministic policy: `V^pi(s) = Q_(V^pi)(s,pi(s))`.
- Optimality: `V*(s) = max_a Q_(V*)(s,a)`.

Prompt: does the robot choose the successor state? **No.** It chooses the action; the transition distribution determines the outcome. A stochastic policy additionally randomizes the action choice.

### Worked answers and reveals

Start with policy risky at start, finish at detour; terminal stay is implicit.

1. Reveal terminal values 0.
2. `V^pi(detour) = 8 + 0.9 × 0 = 8`.
3. `V^pi(start) = 0.8 × 10 + 0.2 × (−10) = 6`.
4. Compare `Q(start,safe) = −1 + 0.9 × 8 = 6.2` with risky value 6.
5. Improve the policy to safe, then reevaluate: start 6.2, detour 8.

A safe trajectory receives −1 then +8: its discounted return is 6.2. A risky trajectory receives +10 **or** −10; its expected return is 6. A single successful rollout is not its expected value. Maximizing expected return does not establish worst-case safety.

### Value iteration and policy iteration

VI starts with all zeros and uses a **separate old vector** for every synchronous sweep:

| Sweep | start | detour | delivered | failed |
|---|---:|---:|---:|---:|
| V0 | 0 | 0 | 0 | 0 |
| V1 | 6 | 8 | 0 | 0 |
| V2 | 6.2 | 8 | 0 | 0 |
| V3 | 6.2 | 8 | 0 | 0 |

At V0 the safe action value is −1; its future +8 has not propagated yet. V1(start) is therefore 6, not 6.2. A **greedy policy extracted from V1** already chooses safe because it looks ahead using V1(detour)=8. It differs from the action that produced V1(start) from V0.

- Policy evaluation holds actions fixed and solves their values. The demo solves `(I − gamma P_pi)V = R_pi` over nonterminals.
- VI maximizes over actions during each value backup.
- PI alternates full evaluation and greedy improvement; the baseline trace is risky → safe → safe.
- The demo retains the current action when it ties for best, avoiding unnecessary policy switches.
- The discounted finite model has gamma < 1. Do not transfer this convergence justification unqualified to gamma=1 examples in the lecture.

At failure probability 0.1, risky value is `0.9 × 10 − 0.1 × 10 = 8`, so risky wins over safe 6.2. The safe route's value does not change.

## Live Demo

Use the [runbook](demo/README.md). No code walkthrough is required.

- Minute 1: show V0 and ask for the first backup.
- Minute 2: click **Next backup** twice; compare with the handwritten table.
- Minute 3: **Solve**; show the convergence check and PI trace.
- Minute 4: predict the effect of failure probability 0.1, then select it and solve.
- Minute 5: reset and summarize why a policy depends on the model and reward choices.

Checkpoint answers: the expectation sums over outcomes; the maximum chooses an action; terminal value is zero because arrival reward was already paid; PI evaluates a complete policy before improving it; no learning is happening because transitions and rewards are given.

## Timing

| Part | Minutes |
|---|---:|
| Recap: deterministic plans versus policies | 5 |
| Define the robot MDP, rewards, and return | 8 |
| Worked Bellman expectation and optimality calculations | 12 |
| Value iteration and policy iteration | 10 |
| Short visualization | 5 |
| Checkpoint and HW3 connection | 5 |
| **Total** | **45** |

## Common Questions / Problems

- **Why not set delivered value to 10?** That would double-count the arrival reward in this convention.
- **Why sum and maximize?** Outcomes are random; actions are our choice. Do not maximize over successor states.
- **Is V1 already the final answer?** Its detour value is correct, but the start value needs another sweep.
- **Does a policy require several actions per state?** No. This optimal policy is deterministic even though risky outcomes are random.
- **Why do arrows change before start value settles?** They are greedy with respect to the displayed vector, supplying the next backup.
- **Is VI reinforcement learning?** Here it is planning with a known model. Later RL lessons consider learning from experience.
- **No GUI backend?** Use the headless trace and saved figures.

## Homework Connection

HW3 explicitly includes Bellman equations and value/policy iteration. Practice identifying the reward convention, writing one state's equation, keeping old/new vectors separate, and extracting a policy. Do not invent additional assignment requirements. This prepares the vocabulary for later RL sessions; no Q-learning or policy-gradient derivations this week.

## Preparation Checklist

- [ ] Review the printed lecture references above and the distinction on slides 50–51.
- [ ] Reproduce values 6, 8, and 6.2 without code.
- [ ] Rehearse the first two synchronous sweeps and explain the displayed arrows.
- [ ] Run tests and both headless scenarios; check VI/PI agreement.
- [ ] Test Next backup, Solve, Reset, and probability switching.
- [ ] Keep both saved figures available and rehearse the five-minute demo limit.
- [ ] Reserve time for the final HW3 checkpoint.
