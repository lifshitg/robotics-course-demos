# Week 6 — MDPs Presentation Plan

Presentation and worked examples: 35 minutes; visualization: 5; recap: 5.
Use the professor's printed slide numbers below. This is an outline, not a slide deck.

## Slide 1 — From a Plan to a Policy

- Recall Week 5's action sequence. Uncertain outcomes require decisions based on the observed state.
- Ask: “If the intended outcome does not occur, what should the robot do?”
- Source: 14–15.

## Slide 2 — Our Delivery Robot

- Draw start → detour → delivered, plus risky branches from start to delivered/failed.
- Label safe reward −1, finish +8, risky success +10 and failure −10.
- Explain that the smaller reliable delivery reward is a deliberate teaching assumption.
- Reveal risky probabilities 0.8 / 0.2 only after students identify the possible outcomes.

## Slide 3 — Define the MDP

- Reveal S, available actions, P, transition rewards, and gamma=0.9 alongside the graph.
- Terminal states stay in place with reward 0; arrival rewards occur once.
- Show `R(s,a) = sum P(s'|s,a) r(s,a,s')` to match the lecture convention.
- Source: 7–12.

## Slide 4 — What Makes a State Markov?

- Current state/action determine the next-state and reward distribution.
- Prompt: “Would location suffice if battery charge changes the success probability?” Answer: include the relevant battery information.
- Our example assumes the four states suffice and are fully observed.

## Slide 5 — Reward, Return, and Value

- Reveal immediate reward → discounted trajectory return → expected return under a policy.
- Safe trajectory: `−1 + 0.9 × 8 = 6.2`; risky trajectories return +10 or −10.
- Ask why one successful run does not establish a value of 10.
- Source: 19–21.

## Slide 6 — A Policy Answers “What Should I Do Here?”

- Highlight risky at start, finish at detour, and absorbing stay at terminals.
- Distinguish a deterministic action choice from stochastic outcomes; optionally contrast a randomized action choice.
- Source: 14–15.

## Slide 7 — Evaluate a Fixed Policy

- Reveal `V^pi(s) = sum P(s'|s,pi(s)) [r + gamma V^pi(s')]`.
- Compute terminals 0, detour 8, then start `0.8 × 10 + 0.2 × (−10) = 6`.
- Prompt: “Where is the maximum?” Answer: nowhere; the policy is fixed.
- Source: 25–29.

## Slide 8 — Compare Actions Using Q

- Define `Q_V(s,a) = sum P(s'|s,a) [r + gamma V(s')]`.
- Reveal safe `−1 + 0.9 × 8 = 6.2`, risky 6; choose safe.
- Then reveal `V*(s) = max_a Q_(V*)(s,a)`; distinguish action choice from outcome averaging.
- Source: 30–33.

## Slide 9 — Value Iteration by Hand

- Start with V0=0. Ask students to fill start/detour columns before revealing answers.
- V1=(6,8), V2=(6.2,8), V3 unchanged; terminals always 0.
- Use separate old/new columns: all states read the same old vector.
- Clarify: arrows greedy from V1 already choose safe; V1(start) was computed from V0.
- Source: 41–44.

## Slide 10 — Policy Iteration

- Reveal the cycle: evaluate current policy → improve actions → repeat.
- Risky policy value 6 → safe policy value 6.2 → unchanged safe policy.
- Explain exact evaluation as a small linear system; no matrix derivation required.
- Source: 54–55.

## Slide 11 — Keep the Three Operations Separate

| Operation | What is held fixed? | What changes? |
|---|---|---|
| Policy evaluation | Policy | Values |
| Value iteration | MDP | Values via maximizing backups |
| Policy iteration | MDP | Alternating evaluated values and policy |

- Prompt students to identify each operation from its equation.
- Known model: this is planning, not learning transition probabilities from experience.

## Slide 12 — Predict, Then Visualize

- Ask: “What if failure probability falls from 0.2 to 0.1?”
- Reveal risky value 8 versus safe 6.2 after the prediction.
- Spend five minutes on backups, solve, scenario change, and reset.
- Expected-return preference is not a worst-case safety guarantee.

## Slide 13 — Checkpoint and HW3

- Which quantity averages outcomes? Which operation chooses the action?
- Why is terminal V zero? Why does V1(start) differ from V2(start)?
- Connect to HW3's Bellman equations and VI/PI; answers are in the teaching notes.

## Visuals Needed

- Original four-state graph with action, probability, and transition-reward labels.
- Old/new value table for V0–V3 and evaluate → improve cycle.
- [Baseline solved graph](demo/baseline.png) and [lower-risk graph](demo/lower_risk.png), generated from the same code/model.
- Keep terminal rewards and values visually distinct; highlight both stochastic branches of a selected risky action.

## Live Demo Transition

“Now predict the first backup before I click. The program is applying the same equation we just calculated.” Open the [demo](demo/README.md) at V0. Do not spend the session reading code.
