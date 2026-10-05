# Week 6 — Markov Decision Processes

Teach MDP notation and solve the existing delivery model through Bellman equations, exact policy evaluation, value iteration and policy iteration. **35 minutes explanation/worked examples + 5 minutes visualization + 5 minutes recap/HW3.** English; 16:9; editable diagrams and equations; detailed speaker notes. 30 slides, last five hidden. Preserve demo files, README and teaching notes. No interfaces or dependencies change.

## Slide order and timing

| Slide | Topic | Minutes |
|---|---|---:|
| 1 | Markov decision processes | 0 |
| 2 | From plans to policies | 1 |
| 3 | Our delivery robot | 1.5 |
| 4 | Define every part of the MDP | 2 |
| 5 | Read transition probabilities | 1.5 |
| 6 | What makes a state Markov? | 1 |
| 7 | A policy chooses actions | 1.5 |
| 8 | Reward now; value of the future | 1.5 |
| 9 | Return and discounting | 1.5 |
| 10 | State values and action values | 1.5 |
| 11 | Derive the Bellman recursion | 2 |
| 12 | Evaluate a fixed policy | 1.5 |
| 13 | Evaluate the risky policy by hand | 2 |
| 14 | Policy evaluation as linear algebra | 2 |
| 15 | Solve the safe policy's system | 1.5 |
| 16 | Choose actions; average outcomes | 1.5 |
| 17 | Value iteration | 1.5 |
| 18 | Value iteration by hand | 2 |
| 19 | Extract a policy from the displayed V | 2 |
| 20 | Policy iteration | 1 |
| 21 | Policy iteration by hand | 1.5 |
| 22 | Keep three operations separate | 2 |
| 23 | Change risk; change the policy | 1.5 |
| 24 | Predict, then visualize | 5 |
| 25 | Checkpoint & HW3 | 5 |
| 26 | Why value iteration converges (hidden) | 0 |
| 27 | Stopping and numerical error (hidden) | 0 |
| 28 | A stochastic policy worked example (hidden) | 0 |
| 29 | A cyclic MDP needs repeated backups (hidden) | 0 |
| 30 | When does the decision switch? (hidden) | 0 |

## Speaker guidance, visuals and mathematical content

### 1. Markov decision processes

Model uncertain outcomes. Compute a policy. Timing: 0 minutes. Visual: title; all formulas and diagram components are editable.

Week 6: 35 minutes of explanation and worked calculations, five minutes visualization, five minutes recap/HW3. Students know Python and earlier planning concepts. This lesson uses the existing fully observed four-state delivery model, not motion geometry or learning. Explain every mathematical symbol on first use. All nine original Week 6 files were reviewed, including the two saved images. The professor PDF was not found; retain the existing printed-slide source map without claiming independent review.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 2. From plans to policies

What should we do after an uncertain outcome? Timing: 1 minutes. Visual: cards; all formulas and diagram components are editable.

Connect to Week 5: the symbolic model assumed deterministic action outcomes. An action sequence prescribes successive actions, while a state-feedback policy prescribes what to do at each observed state, including states reached unexpectedly. Policies can also be useful in deterministic settings; uncertainty motivates the distinction here. A contingent plan can represent branching behavior, so do not imply all uses of the word plan exclude branches. The demo gives a known stochastic model and fully observes each resulting state.
- Week 5 · Plan: Choose an action sequence.
- Week 6 · Policy: Choose an action for each observed state.

The robot chooses an action; the world determines its outcome.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 3. Our delivery robot

Two routes. Different outcomes and rewards. Timing: 1.5 minutes. Visual: graph; all formulas and diagram components are editable.

Reveal the states start, detour, delivered, failed. At start choose safe or risky; at detour choose finish. Safe goes to detour with probability one and reward −1. Finish reaches delivered with probability one and reward +8. Risky reaches delivered with probability 0.8 and reward +10 or failed with probability 0.2 and reward −10. Terminal stay actions are absorbing and reward zero. The lower reliable-route delivery reward is an illustrative route preference, not a measured robot cost. Two incoming transitions can have different rewards despite ending at the same delivered state.

γ = 0.9 · Rewards belong to transitions.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 4. Define every part of the MDP

A Markov decision process is a mathematical model. Timing: 2 minutes. Visual: tuple; all formulas and diagram components are editable.

S is the finite set of states; s is one member and s′ a possible next state. A(s) is the available-action set at state s; a is one action. P gives the next-state distribution conditional on current state/action. r(s,a,s′) is the immediate transition reward. γ is the discount factor, here 0.9 and restricted to [0,1). S_t and A_t are random variables at time t, while s and a denote specific possible values. R_t is the random reward following A_t, not the state set S or a transition matrix. Terminal set T={delivered,failed} is specified separately. Every state has an action in this implementation, including stay at terminals.

Displayed mathematics:

- `ℳ = (S, {A(s)}, P, r, γ)`

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 5. Read transition probabilities

Condition on the current state and the chosen action. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

Read the vertical bar as given. The prime denotes next state, not differentiation. The sum ranges over all successor states, while s and a remain fixed. Expand 0.8+0.2=1 for risky. Safe has P(detour|start,safe)=1; finish has P(delivered|detour,finish)=1. P is a collection of conditional distributions, not a single scalar. The robot selects risky as one action, not its delivered/failed outcome. Impossible transitions have zero probability. model.py validates distributions, finite rewards, known successor names, and absorbing zero-reward terminal transitions.

Displayed mathematics:

- `P(s′ | s, a) ≥ 0     ∑_{s′∈S} P(s′ | s, a) = 1`
- `P(delivered | start, risky) = 0.8`
- `P(failed | start, risky) = 0.2`

The two risky outcomes sum to 1. Other successors have probability 0.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 6. What makes a state Markov?

The present state must contain the relevant information. Timing: 1 minutes. Visual: equations; all formulas and diagram components are editable.

This equality states the Markov assumption: conditional on the current state/action, the earlier history does not add predictive information. Explain S_0:t as the history through time t. The reward distribution must also depend only on the relevant current state/action/next state; our reward is the deterministic function r of that transition. Location alone may fail to be Markov if battery, load or damage changes transition probabilities. The demo assumes its four fully observed states suffice. Full observability and the Markov property are distinct assumptions: an underlying Markov state need not always be directly observable.

Displayed mathematics:

- `P(S_{t+1} | S_{0:t}, A_{0:t})`
- `= P(S_{t+1} | S_t, A_t)`

If battery changes success probability, include battery in the state.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 7. A policy chooses actions

A deterministic decision can have a stochastic outcome. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

π is the policy. π(s) is an action in a deterministic stationary policy. π(a|s) is the probability of selecting action a in a stochastic stationary policy. A policy randomizes action selection only in the latter case; P randomizes outcomes in either case. In this finite discounted setting an optimal deterministic stationary policy exists. The Python policy dictionaries list nonterminal states only; terminal stay is implicit. Explain stationary as using the same state-to-action rule whenever the state occurs, rather than depending explicitly on time. Our worked initial policy chooses risky at start and finish at detour.

Displayed mathematics:

- `Deterministic:     π(s) ∈ A(s)`
- `Stochastic:         π(a | s) ≥ 0,   ∑_a π(a | s) = 1`
- `Example:             π(start) = risky`

At detour: finish. At either terminal: stay.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 8. Reward now; value of the future

Do not count the arrival reward twice. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

Lowercase r is the reward for a particular transition. Uppercase R(s,a) is the expected immediate reward, averaged over next states. Random R_t is the actual reward following A_t, and may be +10 or −10 for risky. Pay delivery/failure rewards once on entry. The terminal state then stays with zero reward forever, making its future value zero. Setting V(delivered)=10 would add another discounted delivery reward and double-count in this convention. The safe route gives −1 now and +8 on the later finish transition; its first expected immediate reward is −1, not 6.2.

Displayed mathematics:

- `r(s,a,s′): reward on this transition`
- `R(s,a) = ∑_{s′} P(s′ | s,a) r(s,a,s′)`
- `R(start,risky) = 0.8(10) + 0.2(−10) = 6`

Delivered / failed: later rewards = 0, so terminal values = 0.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 9. Return and discounting

Return adds rewards along one trajectory. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

G_t is the discounted return from time t. k counts how many transitions into the future a reward arrives; γ^0=1 weights the immediate reward. γ=0 ignores later rewards; γ near one weights them more strongly. Rewards can be abstract task preferences rather than physical money. The lesson uses R_t for the reward after A_t, matching existing notes; some books label the same reward R_(t+1). State that alternative only in notes and keep slides consistent. A successful risky rollout gives 10, but this does not establish expected value 10. Discounting also enables the finite-model convergence result when rewards are bounded and γ<1.

Displayed mathematics:

- `G_t = ∑_{k=0}^{∞} γ^k R_{t+k}`
- `G_t = R_t + γR_{t+1} + γ^{2}R_{t+2} + ⋯`
- `Safe:    G = −1 + 0.9(8) = 6.2`

Risky: one trajectory returns +10 or −10. Expected return is 6.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 10. State values and action values

Both average future return under a policy. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

Expectation means a probability-weighted average over possible trajectories, including action randomness if π is stochastic. Vπ starts in s and follows π immediately. Qπ takes the specified first action a and then follows π thereafter, including actions not normally selected by π; interpret this conditioning operationally as fixing the first action even when it has zero probability under π. Superscript π identifies the policy, not exponentiation. Later Q_V denotes a one-step backup based on any value vector V, not necessarily the true value of a policy. The aim is to obtain V* and an optimal policy, not simply to maximize immediate reward.

Displayed mathematics:

- `V^{π}(s) = 𝔼_{π}[G_t | S_t = s]`
- `Q^{π}(s,a) = 𝔼_{π}[G_t | S_t=s, A_t=a]`

V: follow π now. Q: take a now, then follow π.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 11. Derive the Bellman recursion

One reward now, then the same problem at the next state. Timing: 2 minutes. Visual: equations; all formulas and diagram components are editable.

Work line by line: split the first term from the discounted series; condition on starting state s; use linearity and conditional expectation; the future return conditional on successor s′ is Vπ(s′) under the same stationary policy. Expand the outer expectation over action probabilities π(a|s) and next-state probabilities P(s′|s,a) on the next slide. This is the law of total expectation, not assuming future return equals its expectation on every realized trajectory. γ multiplies future value but not the immediate reward. The prime and time subscripts identify next state/time consistently.

Displayed mathematics:

- `G_t = R_t + γG_{t+1}`
- `V^{π}(s) = 𝔼_{π}[R_t + γG_{t+1} | S_t=s]`
- `= 𝔼_{π}[r(s,A_t,S_{t+1}) + γV^{π}(S_{t+1}) | S_t=s]`

Condition on the chosen action and successor; apply the Markov property.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 12. Evaluate a fixed policy

Average actions and outcomes; keep the policy fixed. Timing: 1.5 minutes. Visual: policyEquation; all formulas and diagram components are editable.

The first two displayed lines form one expression: the continuation is multiplied inside the sum over actions, not by a separately evaluated sum. The outside sum averages policy action choices; the inside sum averages next-state outcomes. For a deterministic policy all action probabilities are zero except π(s), so only that action remains. Q_(Vπ) means Q_V with V equal to Vπ, using the generic backup definition introduced below. Ask where the maximum is: nowhere. These coupled equations can be solved exactly as a linear system or approximately by repeated fixed-policy backups. The demo uses the exact linear solve.

Displayed mathematics:

- `V^{π}(s) = ∑_{a∈A(s)} π(a | s) {`
- `∑_{s′∈S} P(s′ | s,a) [r(s,a,s′) + γV^{π}(s′)] }`
- `Deterministic:    V^{π}(s) = Q^{π}(s, π(s))`

There is no max: evaluation asks how good this policy is.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 13. Evaluate the risky policy by hand

π(start) = risky; π(detour) = finish. Timing: 2 minutes. Visual: equations; all formulas and diagram components are editable.

Evaluate terminal states first, then detour, then start. The weights 0.8 and 0.2 apply to the entire immediate-plus-future quantity. Show 8−2=6 as the final start arithmetic. The detour state is not reached when starting at start under this policy, yet Vπ(detour) still answers what happens if we start there; this matters when comparing safe as an alternative first action. No action optimization occurs during this calculation. Reward +10 and −10 occurs immediately on risky's transition, so neither receives an extra factor γ. The finish reward is immediate when evaluating detour.

Displayed mathematics:

- `V^{π}(delivered) = V^{π}(failed) = 0`
- `V^{π}(detour) = 1[8 + 0.9(0)] = 8`
- `V^{π}(start) = 0.8[10+0.9(0)] + 0.2[−10+0.9(0)]`
- `= 6`

The policy's value at detour is defined even if start → risky never visits it.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 14. Policy evaluation as linear algebra

One equation per nonterminal state. Timing: 2 minutes. Visual: equations; all formulas and diagram components are editable.

For n nonterminal states, Vπ and Rπ are n×1 vectors and Pπ is n×n. i and j index states in the fixed order [start,detour], not time. Deterministic π reduces action sums to the selected action. Pπ contains only transitions to nonterminals; rows can sum to less than one because terminal probability is omitted. Rπ still includes rewards on all transitions, including terminal arrivals. The omitted terminal future term is zero. I is the identity matrix. Move γPπVπ to the left and factor Vπ. The Python implementation constructs I−γPπ and calls numpy.linalg.solve; explicitly computing the matrix inverse is unnecessary.

Displayed mathematics:

- `P_{π}(i,j) = ∑_a π(a | i) P(j | i,a)`
- `R_{π}(i) = ∑_a π(a | i) ∑_{s′} P(s′ | i,a) r(i,a,s′)`
- `V^{π} = R_{π} + γP_{π}V^{π}`
- `(I − γP_{π})V^{π} = R_{π}`

Vector order: [start, detour]. Solve a 2 × 2 linear system.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 15. Solve the safe policy's system

Rows and columns use [start, detour]. Timing: 1.5 minutes. Visual: matrix; all formulas and diagram components are editable.

For safe at start and finish at detour, Pπ=[[0,1],[0,0]] and Rπ=[−1,8]^T. Its second row has no nonterminal successor because finish reaches delivered. Thus I−0.9Pπ=[[1,−0.9],[0,1]]. The displayed linear system says Vstart−0.9Vdetour=−1 and Vdetour=8. Substitute to get Vstart=6.2. For the risky policy Pπ is the zero 2×2 matrix and Rπ=[6,8]^T, so its system directly gives [6,8]^T. These are two different policies, not simultaneous equations that choose actions. Each system evaluates a policy already selected.

V(detour) = 8   ⇒   V(start) = −1 + 0.9(8) = 6.2

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 16. Choose actions; average outcomes

Bellman optimality separates control from uncertainty. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

Q_V uses an arbitrary current value estimate V. It equals Qπ when V=Vπ and Q* when V=V*. The star means optimal, not multiplication. The Bellman optimality equation is a condition on the unknown optimal values. It does not itself specify the numerical iteration; that comes next. Maximizing over outcomes would wrongly let the robot choose success and ignore failure. argmax returns an action; max returns its numerical action value. Safe is optimal here despite lower expected immediate reward because of its future finish reward. Restrict max to actions available at the current state.

Displayed mathematics:

- `Q_V(s,a) = ∑_{s′} P(s′ | s,a)[r(s,a,s′)+γV(s′)]`
- `V^{*}(s) = max_{a∈A(s)} Q^{*}(s,a)`
- `At start:    max{−1 + 0.9(8), 6} = 6.2`

Sum over successor states. Max over actions.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 17. Value iteration

Improve values through repeated maximizing backups. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

k is the sweep index, not a physical trajectory time. All updates in a sweep read V_k; do not let an earlier new value leak into another update. Stop when Δ_k is below tolerance; the demo uses 1e−10 with a cap of 1000 sweeps. Afterwards extract a greedy policy using the returned new vector. A cap failure raises an error rather than asserting convergence. V0=0 can be interpreted as a zero-step horizon; this is a teaching initialization, not a measured initial return. Bellman optimality characterizes the answer, whereas this update is an algorithm approaching it. Numerical bounds are in the hidden backups.

Displayed mathematics:

- `Initialize:    V_0(s) = 0`
- `V_{k+1}(s) = max_a ∑_{s′} P(s′ | s,a)[r(s,a,s′)+γV_k(s′)]`
- `Δ_k = max_s |V_{k+1}(s) − V_k(s)|`

Read the complete old vector; write a separate new vector.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 18. Value iteration by hand

Every row uses the complete preceding row. Timing: 2 minutes. Visual: sweeps; all formulas and diagram components are editable.

V0=(0,0,0,0). First backup: finish gives 8, safe at start gives −1+0.9×0=−1, risky gives 6, so V1=(6,8,0,0). The new detour value 8 cannot be used for start during that first synchronous sweep. Second backup: safe uses old detour=8, giving 6.2, while risky remains 6; V2=(6.2,8,0,0). The third sweep is unchanged, confirming the stopping criterion. Maximum changes are 8, 0.2, 0. The tiny nonterminal graph is acyclic, so reward propagates quickly; general cyclic models may need many iterations. Ask students to compute each start value before pointing to the corresponding row.

V₁(start): max{−1, 6} = 6.    V₂(start): max{6.2, 6} = 6.2.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 19. Extract a policy from the displayed V

The greedy action uses a fresh one-step lookahead. Timing: 2 minutes. Visual: equations; all formulas and diagram components are editable.

The value V1(start)=6 was computed using V0, whose detour value was zero. The greedy policy extracted from V1 recomputes action values using V1(detour)=8. Therefore safe already appears green in the demo at V1. This is consistent: the displayed Q values supply the next backup rather than explaining the previous maximizing choice. argmax may contain several actions; choose any maximizer. The demo keeps an old action if it remains tied within 1e−12; otherwise insertion order picks safe first. When risky is selected both stochastic branches remain possible, and both are highlighted rather than only the successful branch.

Displayed mathematics:

- `π_V(s) ∈ argmax_a Q_V(s,a)`
- `Using V_1:    Q_{V₁}(start,safe) = −1 + 0.9(8) = 6.2`
- `Using V_1:    Q_{V₁}(start,risky) = 6`

V₁(start) = 6, but the greedy action from V₁ is already safe.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 20. Policy iteration

Evaluate a policy completely, then improve it. Timing: 1 minutes. Visual: equations; all formulas and diagram components are editable.

k indexes policy-iteration rounds. Evaluation holds πk fixed and solves its coupled equations. Improvement uses the resulting Vπk to choose maximizing actions at every nonterminal state. The demo additionally checks the Bellman optimality residual below 1e−10 and caps rounds at 1000. Preserve an existing action when tied for best, avoiding needless switches. Under finite discounted assumptions, improvement cannot reduce the policy value and stable greedy policies are optimal. The convergence proof is not part of the timed explanation. This is distinct from VI, which need not fully evaluate a policy between maximizing sweeps.

Displayed mathematics:

- `Evaluate:    (I − γP_{πₖ})V^{πₖ} = R_{πₖ}`
- `Improve:     π_{k+1}(s) ∈ argmax_a Q^{πₖ}(s,a)`

Repeat until the policy is unchanged and the optimality residual is small.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 21. Policy iteration by hand

The visualization deliberately starts with risky. Timing: 1.5 minutes. Visual: piTrace; all formulas and diagram components are editable.

Round 0: evaluate risky at start and finish at detour to get V=(6,8,0,0). Improvement compares safe=6.2 with risky=6 and selects safe. Round 1: evaluate safe to get V=(6.2,8,0,0). Improvement still chooses safe; residual is zero. Stop. The demo explicitly passes the risky initial policy for this instructive trace. Calling policy_iteration without an initial policy defaults to the first action in model order, which is already safe; do not claim it always begins risky. The initial dictionary is copied and not modified. In the lower-risk model risky is already optimal and the first round is stable.

Evaluate → improve → evaluate again → unchanged.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 22. Keep three operations separate

Identify what is fixed before reading an equation. Timing: 2 minutes. Visual: compare; all formulas and diagram components are editable.

Policy evaluation holds the policy and model fixed; it solves or iteratively estimates Vπ. Value iteration holds the model fixed and repeatedly maximizes while updating values; it extracts a policy from those values. Policy iteration holds the model fixed and alternates complete policy evaluation with improvement, changing the policy explicitly. All three use the same transition/reward model and Bellman building blocks. Here the probabilities and rewards are supplied, so this is model-based planning. It does not learn them from data or use Q-learning. Ask students whether a formula with π weights but no max is evaluation, and whether a max using old V is VI.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 23. Change risk; change the policy

Predict before selecting failure probability 0.1. Timing: 1.5 minutes. Visual: equations; all formulas and diagram components are editable.

Changing the known failure probability changes the MDP, not the policy evaluation algorithm. The safe route rewards and transitions stay the same. At p=0.1 risky has expected return 8 and beats safe6.2. Ask students to predict the new action before selecting the scenario. The model still permits failure with probability 0.1; optimal expected return is not guaranteed delivery or worst-case safety. The numerical display rounds to two decimals, while solvers keep full precision. Threshold derivations for risk and discount are available on the final hidden slide.

Displayed mathematics:

- `Risky at p=0.2:    0.8(10) + 0.2(−10) = 6`
- `Risky at p=0.1:    0.9(10) + 0.1(−10) = 8`
- `Safe remains:      −1 + 0.9(8) = 6.2`

The optimal start action changes: safe → risky.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 24. Predict, then visualize

The program applies the equations we just calculated. Timing: 5 minutes. Visual: demo; all formulas and diagram components are editable.

Five-minute demo; no code walkthrough. Minute1 open at baseline p=0.2 and V0, ask for the first backup. Minute2 click Next backup twice, compare V1 and V2 with the hand table, and explain greedy green arrows using displayed V. Minute3 click Solve to show the unchanged sweep and risky→safe→safe PI trace. Minute4 predict p=0.1, select it (which resets to V0), then Solve and confirm risky wins. Minute5 Reset returns to V0 under the selected probability; choose 0.2 to restore the baseline. Both risky branches are possible when risky is selected. Use saved baseline/lower-risk figures if the GUI is unavailable. No ROS/Gazebo process is needed.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 25. Checkpoint & HW3

Explain the calculation, not just the final number. Timing: 5 minutes. Visual: recap; all formulas and diagram components are editable.

Reserve five minutes for questions and recap. Answers: P gives next-state probabilities conditional on state/action; expectation averages outcomes the robot cannot choose; max selects a controllable action. Terminal value is zero because rewards were paid on arrival and future stay rewards are zero. V1 lacks propagation of detour8 into start until the next synchronous sweep. VI uses repeated maximizing backups; PI fully evaluates a policy and then improves it. Connect to HW3 Bellman equations and value/policy iteration without inventing additional requirements. Ask students to write one state equation, identify its reward convention, and distinguish evaluation from optimization.
- Model + policy: What does P(s′ | s,a) mean?
- Bellman operations: Why sum outcomes but maximize actions?

Why terminal V = 0? Why V₁ ≠ V₂? How do VI and PI differ?

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 26. Why value iteration converges

Finite model, bounded rewards, 0 ≤ γ < 1. Timing: 0 minutes. Visual: equations; all formulas and diagram components are editable.

Optional proof: |max f−max g|≤max|f−g|. For each action, reward terms cancel in the difference; triangle inequality bounds γ times the probability-weighted difference in successor values. Since probabilities are nonnegative and sum to1, this is at most γ||V−W||∞. Taking the maximum over states proves contraction. Iterating gives the displayed geometric error bound toward the unique fixed point. Finite states/actions and bounded rewards make the value vector finite for γ<1. The gamma0 case reaches the immediate-reward solution in one update. Do not transfer this result unqualified to gamma1; the demo rejects it.

Displayed mathematics:

- `(TV)(s) = max_a Q_V(s,a)`
- `‖TV − TW‖_{∞} ≤ γ‖V − W‖_{∞}`
- `‖V_k − V^{*}‖_{∞} ≤ γ^k ‖V_0 − V^{*}‖_{∞}`

A contraction has a unique fixed point: TV* = V*.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 27. Stopping and numerical error

A small update is evidence of a small residual. Timing: 0 minutes. Visual: equations; all formulas and diagram components are editable.

Define infinity norm as maximum absolute component. Residual bound follows ||V−V*||≤||V−TV||+||TV−TV*||≤δ+γ||V−V*||. For a synchronous update V_(k+1)=TV_k, Δ_k is the residual at the old V_k; applying contraction yields the bound γΔ_k/(1−γ) for the returned new vector. At gamma.9 and Δ<1e−10, the exact-arithmetic bound for the new vector is <9e−10. Floating-point implementation adds numerical considerations. VI stops on sweep change; PI checks optimality residual and unchanged policy. A value-error bound does not automatically promise an exact greedy action near a tie or physical safety.

Displayed mathematics:

- `δ(V) = ‖TV − V‖_{∞}`
- `‖V − V^{*}‖_{∞} ≤ δ(V) / (1−γ)`
- `Δ_k = ‖V_{k+1}−V_k‖_{∞}`
- `‖V_{k+1}−V^{*}‖_{∞} ≤ γΔ_k / (1−γ)`

Label the returned vector correctly; the two bounds use different indices.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/value-iteration.html
- https://inst.eecs.berkeley.edu/~cs188/textbook/mdp/policies-iteration.html

### 28. A stochastic policy worked example

At start choose safe or risky with probability 0.5 each. Timing: 0 minutes. Visual: equations; all formulas and diagram components are editable.

This policy randomizes the initial action independently according to the current state. At detour it always finishes, and at terminals always stays. The nested expectation distinguishes π action probabilities0.5 from P risky outcome probabilities0.8/0.2. Matrix over [start,detour] has Pπ=[[0,0.5],[0,0]] and Rπ=[2.5,8]^T; 2.5 comes from 0.5(−1)+0.5(6). Solve Vstart=2.5+0.9×0.5×8=6.1. This example is supplemental mathematics; the Python demo policy dictionaries and evaluator support deterministic choices only. Do not imply the UI implements randomized policies.

Displayed mathematics:

- `π(safe | start) = π(risky | start) = 0.5`
- `V^{π}(detour) = 8`
- `V^{π}(start) = 0.5[−1+0.9(8)] + 0.5[0.8(10)+0.2(−10)]`
- `= 0.5(6.2) + 0.5(6) = 6.1`

First average action choices; within risky, average successor outcomes.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 29. A cyclic MDP needs repeated backups

One state, one action: wait earns +1 and returns to itself. Timing: 0 minutes. Visual: equations; all formulas and diagram components are editable.

This continuing model has no terminal states and gives reward1 on every transition. The geometric discounted sum is finite because gamma.9<1. Matrix evaluation solves the scalar system (1−gamma)V=1 immediately; VI approaches10. Expand V_k=sum_(i=0)^(k−1)0.9^i and apply the geometric-series formula. The model test suite includes this cyclic evaluation example. It shows why the delivery model stabilizing after two informative sweeps is not a general iteration bound. The solver cap and tolerance are necessary numerical controls; there is no rollout learning involved.

Displayed mathematics:

- `V = 1 + 0.9V     ⇒     0.1V = 1     ⇒     V = 10`
- `V_0 = 0,   V_1 = 1,   V_2 = 1.9,   V_3 = 2.71`
- `V_k = (1 − 0.9^k) / (1 − 0.9)`

Unlike the delivery example, values approach the limit over many sweeps.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

### 30. When does the decision switch?

Compare the two expected returns algebraically. Timing: 0 minutes. Visual: equations; all formulas and diagram components are editable.

At gamma.9 choose safe for p>.19 and risky for p<.19. At p.2 choose safe for gamma>.875 and risky for gamma<.875 within [0,1). These inequalities compare designated actions in this exact model, not universal robot safety thresholds. At equality either policy is optimal; the demo preserves a current tied action within tolerance. The UI exposes only failure probabilities.2 and.1; gamma and other probabilities are algebraic extensions, not new controls. Reward preferences and discount can change the chosen action even with the same physical outcome probabilities.

Displayed mathematics:

- `Q_{risky} = (1−p)10 + p(−10) = 10 − 20p`
- `Q_{safe} = −1 + 8γ`
- `At γ=0.9:    10−20p = 6.2    ⇒    p = 0.19`
- `At p=0.2:    −1+8γ = 6    ⇒    γ = 0.875`

At equality both actions maximize expected return.

- https://www.cs.cmu.edu/~15281-s25/coursenotes/mdps/index.html
- Local: demo/model.py, demo/demo.py, demo/test_model.py, demo/README.md, and TEACHING_NOTES.md.
- Existing printed-slide references to Class7-MDPs.pdf: definitions/policies 7–15; return/value 19–21; evaluation 25–29; Q/optimality 30–33; VI 41–44; PI 54–55. The PDF was not found locally and was not reviewed.

## Exact model and worked checks

| State / action | Next state | Probability | Transition reward |
|---|---|---:|---:|
| start / safe | detour | 1 | −1 |
| start / risky | delivered | 0.8 | +10 |
| start / risky | failed | 0.2 | −10 |
| detour / finish | delivered | 1 | +8 |
| delivered / stay | delivered | 1 | 0 |
| failed / stay | failed | 1 | 0 |

γ=0.9. Arrival reward is paid once; terminal future value is zero. Risky-policy value [6,8,0,0]; safe-policy value [6.2,8,0,0]. At p=0.1 optimal start value8 and action risky. VI vectors: [0,0,0,0] → [6,8,0,0] → [6.2,8,0,0] → unchanged. PI visualization explicitly starts risky, unlike the solver's default first-action initialization.

Safe-policy nonterminal matrix: Pπ=[[0,1],[0,0]], Rπ=[−1,8]ᵀ. Solve [[1,−0.9],[0,1]]V=Rπ in order [start,detour]. Risky-policy matrix is zero with reward vector [6,8]ᵀ. Omitted terminal transitions still contribute immediate rewards. Main policy-equation continuation is inside the sum over actions. Q_V is an arbitrary-value backup, Qπ follows a policy after the specified first action, and Q* uses V*.

## Validation and rehearsal boundaries

Read all nine original Week6 files including both figures. Class7-MDPs.pdf was not found locally; existing printed-slide references are retained without claiming it was reviewed. Generate/render/reopen in installed PowerPoint; inspect 30 slide previews, notes, equations, five hidden slides, 30 PDF pages and protected hashes. Independent PowerShell arithmetic checks validate displayed examples and source constants; these are not execution of the Python demo. Python is currently unavailable locally: original tests, headless traces and classroom GUI rehearsal remain unexecuted here. See slides/validation.json, review.json and README.md for evidence and future commands.