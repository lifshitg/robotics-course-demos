# Week 8 — Q-Learning: Mathematics, Exploration, and Off-Policy Learning

**30 minutes explanation + 10 minutes demo + 5 minutes recap** (new selected schedule; preserved teaching notes/runbook retain their older timing). 28 slides including five hidden backups. English,16:9, light background, blue/teal accents, editable diagrams and equations. Derive the sampled Bellman update, distinguish epsilon-greedy behavior from greedy targets, and explain training/evaluation isolation. Preserve all demo files and teaching notes; no behavior, dependencies or interfaces change.

## Sequence and timing

| Slide | Topic | Minutes |
|---|---|---:|
| 1 | Q-learning | 0 |
| 2 | From planning and imitation to RL | 1 |
| 3 | Our maze and interaction loop | 1.5 |
| 4 | Reward versus return | 1.5 |
| 5 | What does Q(s,a) mean? | 1.5 |
| 6 | Max returns a value; argmax an action | 1 |
| 7 | Bellman optimality for Q | 2 |
| 8 | From a model expectation to experience | 1.5 |
| 9 | Derive the Q-learning update | 2 |
| 10 | Calculate one transition | 1.5 |
| 11 | Termination is different from truncation | 1.5 |
| 12 | Why the maximum in the target? | 2 |
| 13 | Q-learning is off-policy | 2 |
| 14 | Compare with SARSA | 1.5 |
| 15 | Why explore and exploit? | 1.5 |
| 16 | Epsilon-greedy: actual probabilities | 2 |
| 17 | Exploration in our implementation | 1 |
| 18 | Training versus evaluation | 1.5 |
| 19 | Read the algorithm | 1 |
| 20 | Interpret the learning results | 1 |
| 21 | What does this result establish? | 1.5 |
| 22 | Predict the update, then train | 10 |
| 23 | Questions & recap | 5 |
| 24 | Bellman expectation and sample targets (hidden) | 0 |
| 25 | Convergence conditions and step sizes (hidden) | 0 |
| 26 | Q-learning versus SARSA: extended check (hidden) | 0 |
| 27 | The maximum can favor noisy estimates (hidden) | 0 |
| 28 | Termination, truncation, and code (hidden) | 0 |

## Speaker guidance and visuals

### 1. Q-learning

Mathematics, exploration, and off-policy learning. Timing: 0 minutes. Visual: title.

Use the newly selected schedule:30 minutes explanation,10 demo,5 recap. Existing teaching notes/runbook retain their older23+17+5 schedule and remain unchanged; this deck and revised plan take precedence for presentation timing. Students know Week6 Bellman equations and Week7 supervised imitation. Explain all new symbols. Ten original nonmetadata files and demo .gitignore were read. No professor slides were supplied. Preserve the demo and all protected documents. Equations and diagrams are editable; proof details go in five hidden backups.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.
- https://inst.eecs.berkeley.edu/~cs188/textbook/rl/rl.html
- Existing reference: Sutton and Barto, Reinforcement Learning: An Introduction, Chapters 3 and 6.5. https://www.incompleteideas.net/book/bookdraft2018mar21.pdf — unavailable during this review; not claimed as reviewed.

### 2. From planning and imitation to RL

Keep the policy idea; learn from a different signal. Timing: 1 minutes. Visual: progress.

Week6 used a known transition/reward model to compute a policy; Week7 used expert action labels to fit one. Today rewards describe consequences rather than correct action labels. The learner observes transitions through interaction and updates action-value estimates. The environment still has defined dynamics; model-free describes the learner not constructing/using a transition model for its updates. The displayed maze is for us; the algorithm samples state/action/reward/next-state tuples rather than using a route planner.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.
- https://inst.eecs.berkeley.edu/~cs188/textbook/rl/rl.html
- Existing reference: Sutton and Barto, Reinforcement Learning: An Introduction, Chapters 3 and 6.5. https://www.incompleteideas.net/book/bookdraft2018mar21.pdf — unavailable during this review; not claimed as reviewed.

### 3. Our maze and interaction loop

State → action → reward and next state → update. Timing: 1.5 minutes. Visual: maze.

The exact5×5 deterministic maze uses(row,column), row0 at top. Start(4,0); goal(0,4); walls(1,1),(1,2),(2,2),(3,1),(3,3). Actions0–3 are up,right,down,left. Boundary/wall attempts stay in place and receive−1. Goal entry earns+10 instead of−1 and truly terminates. The environment returns the next-state/reward sample; it does not provide an expert action. Deterministic physics does not prevent randomized behavior selection. Q-table storage has shape5×5×4, but wall and terminal entries are not ordinary learned decision states.

Ordinary / blocked move: −1. Goal arrival: +10, then terminate.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 4. Reward versus return

A good action can have a bad immediate reward. Timing: 1.5 minutes. Visual: equations.

Keep previous lesson indexing:R_t is the reward after A_t; some textbooks call this R_(t+1). k counts future steps, with immediate coefficientγ^0=1. The eight-action path has seven ordinary rewards−1 and final+10. Raw sum=7(−1)+10=3. Discounted sum=−sum_(k=0)^6 .95^k+10(.95^7)=.9501188828124985. Raw return, discounted return, episode length and success are distinct metrics. Q estimates expected discounted return, not immediate reward or a success probability.

- `G_t = ∑_{k=0}^{∞} γ^k R_{t+k}`
- `Eight moves:    −1, −1, −1, −1, −1, −1, −1, +10`
- `Raw sum = 3     |     Discounted return ≈ 0.950119`

γ = 0.95 discounts future rewards; it is not the exploration rate.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 5. What does Q(s,a) mean?

Take this action now; account for the continuation. Timing: 1.5 minutes. Visual: equations.

s is a particular state; a is one available action; π is a continuation policy. The operational definition fixes the first action, including one π might never select, then follows π. Q* is the value using optimal continuation; Q_t is the evolving table, not already correct. t indexes collected updates, distinct from episode number. Superscriptπ identifies a policy rather than an exponent; star means optimal. The expectation averages uncertain outcomes in general, even though this maze is deterministic. One Q entry is stored per state/action; the learner aims at greedy continuation, not the value of its exploratory policy.

- `Q^{π}(s,a) = 𝔼[G_t | S_t=s, take a, then follow π]`
- `Q^{*}(s,a): optimal expected continuation`
- `Q_t(s,a): current estimate of Q^{*}(s,a)`

A Q-value is a return estimate, not an action probability.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 6. Max returns a value; argmax an action

Choose from the four values at the current state. Timing: 1 minutes. Visual: equations.

The four values are an illustrative table row, not measured maze data. max yields the largest numerical estimate4; argmax yields the index/action up. Argmax may contain several maximizers; the implementation specifies tie rules. V*=maxQ* links to Week6 state values. π_Q is a greedy policy with respect to currentQ; it need not already be optimal. At zero initialization all actions tie. Fixed-order display/evaluation arrows initially point up arbitrarily; do not treat them as useful learned knowledge.

- `Q(s,·) = [4, 1, −2, 0]`
- `max_a Q(s,a) = 4     |     argmax_a Q(s,a) = up`
- `V^{*}(s) = max_a Q^{*}(s,a)`
- `π_Q(s) ∈ argmax_a Q(s,a)`

Action order: up / right / down / left.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 7. Bellman optimality for Q

Immediate reward plus the best continuation at the next state. Timing: 2 minutes. Visual: bellman.

Split the return into its immediate reward and future return. After the first action, optimal continuation has valueV*(s′)=max_(a′)Q*(s′,a′). Substituting gives the displayed conditional expectation. D_t=1 only for true termination, so there is no continuation reward after goal arrival. The multiplication continuation on the next line is inside the expectation. In a general stochastic MDP, the expectation averages next-state/reward outcomes; max is over actions at each realized next state, not over successor outcomes. P is not required by the learner. In our deterministic maze the expectation for a given pair reduces to its single transition.

- `G_t = R_t + γG_{t+1}`
- `Q^{*}(s,a) = 𝔼[ R_t + γ(1−D_t)`
- `× max_{a′} Q^{*}(S_{t+1},a′) | S_t=s, A_t=a ]`

Average successor outcomes; maximize next-state actions.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 8. From a model expectation to experience

Use the transition we actually observed. Timing: 1.5 minutes. Visual: sample.

Week6 used known probabilities to average all successors during model-based backups. Q-learning gets a sampled tuple(s_t,a_t,r_t,s_(t+1),d_t) and builds a one-step target from its current table. Conditional on a fixed table and state/action, the sampled target has expectation equal to that table's Bellman optimality backup. This does not mean one target is the trueQ* or an entire trajectory return. The table changes over time; stochastic approximation combines repeated experience. The learner does not build an explicit P model. Its update is asynchronous over visited entries rather than a synchronous full-vector VI sweep.

One sample and one visited entry; no full model sweep.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 9. Derive the Q-learning update

Target → temporal-difference error → correction. Timing: 2 minutes. Visual: equations.

y_t is the sample target; δ_t is temporal-difference(TD) error. α=.2 controls adjustment size, while γ=.95 weights future rewards and ε=.2 controls exploration: these are different roles. Bootstrapping uses current estimates of future return instead of waiting for the whole realized return. Q_new=Q_old+α(target−old) expands algebraically to a weighted average when0≤α≤1. For α1 replace with target; α0 makes no change. The last displayed equals line continues the Qnew equation. Only(s_t,a_t) is assigned. Q_t in all target terms refers to the pre-update table, including self-transitions.

- `y_t = r_t + γ(1−d_t) max_{a′} Q_t(s_{t+1},a′)`
- `δ_t = y_t − Q_t(s_t,a_t)`
- `Q_{t+1}(s_t,a_t) = Q_t(s_t,a_t) + αδ_t`
- `= (1−α)Q_t(s_t,a_t) + αy_t`

α = 0.2: move 20% toward the target. Other entries stay fixed.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 10. Calculate one transition

Old Q = 0; reward = −1; next-state maximum = 4. Timing: 1.5 minutes. Visual: equations.

Reveal the arithmetic after students predict each line. Nonterminal target uses reward plusγ times next-state maximum. δ is the discrepancy between that target and old estimate0. Applyingα=.2 gives.56. This is the existing test example: q[0,1] is artificially set to4, then update(0,0),right with reward−1. It is not the first real demo step from an all-zero table; that first ordinary target would be−1 and new entry−.2. Positive target despite negative immediate reward illustrates future benefit.

- `y = −1 + 0.95(4) = 2.8`
- `δ = 2.8 − 0 = 2.8`
- `Q_{new} = 0 + 0.2(2.8) = 0.56`

These values illustrate the update; they are not the first zero-table step.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 11. Termination is different from truncation

Goal ends the task; the step cap ends collection. Timing: 1.5 minutes. Visual: termination.

For true goal termination d_t=1, target equals reward10 even if terminalQ entries contain arbitrary values. With old0 andα.2 the first goal update is2. The100-step cap is an external data-collection truncation, not a terminal state in this task; d_t stays0 and bootstrap remains. The code computes update using terminated only before deciding truncated/reset. Use the actual observed final next state, not the reset start, for that target. Time remaining is not part of state because the cap is not an inherent finite-horizon task. Evaluation also caps rollout length but performs no learning.

At the 100-step collection cap: retain the bootstrap, then reset.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.
- https://gymnasium.farama.org/tutorials/gymnasium_basics/handling_time_limits/

### 12. Why the maximum in the target?

Estimate the best continuation, even if behavior explores. Timing: 2 minutes. Visual: max.

At the observed successor let Q=[4,1,−2,0]. We estimate the return of the sampled current action assuming greedy continuation after arrival. max picks4, not the value−2 of a hypothetical exploratory next action. The update still changes the current action actually performed, including exploratory or blocked actions. It does not switch that historical action to the maximizing successor action. Maximum is a value operation inside the target; argmax is used when selecting a behavior/evaluation action. Early maximum estimates may be wrong and can have maximization bias; the hidden DoubleQ motivation addresses that caveat.

The max does not claim that the next behavior action will be greedy.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 13. Q-learning is off-policy

The behavior that gathers data can differ from the target. Timing: 2 minutes. Visual: offpolicy.

Behavior μ is epsilon-greedy and produces observed transitions. Target policy is any greedy maximizer with respect to currentQ; its continuation value is maxQ. The two can differ, making Q-learning off-policy. The target policy evolves asQ changes; it is not assumed already optimal. Off-policy is a behavior-versus-target distinction, not simply training versus evaluation, and it does not mean offline data or require replay buffers. This one-step tabular conditional target does not need an importance ratio to average the observed outcome of the particular pair; adequate state/action coverage remains essential. This demo collects online transitions and has no replay buffer.

Behavior explores; the target assumes greedy continuation.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 14. Compare with SARSA

Same transition; different next-action target. Timing: 1.5 minutes. Visual: sarsa.

SARSA uses(state,action,reward,next-state,next-action) and a target r+γQ(s′,a′) for the next action selected by its behavior policy. When that behavior is also the policy evaluated/improved, SARSA is on-policy. Here Qnext=[4,1,−2,0] and exploratory next action chooses−2: Q-learning target2.8, SARSA target−2.9. With old0 andα.2 updates are.56 and−.58. This compares hypothetical updates with the same old table, not sequential updates of one table. Both use actual first reward/next state. If next behavior action is greedy they can agree numerically; Q-learning remains an off-policy method capable of differing behavior/target.

SARSA is a comparison only; our demo implements Q-learning.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 15. Why explore and exploit?

Learn about alternatives while using what already seems good. Timing: 1.5 minutes. Visual: explore.

Unknown action values require experience. Purely greedy choice can repeatedly choose a plausible but incomplete estimate and leave useful alternatives untried. Exploration sacrifices some immediate performance to gather data; pure random behavior fails to exploit what is learned efficiently. Epsilon-greedy is a simple coverage mechanism, not an optimal exploration strategy. With constant positiveepsilon every action has nonzero conditional probability at a visited state, but adequate state visitation still matters. In this fully reachable small maze it supports continued discovery. Zero initialization and randomized greedy ties can also induce early movement; epsilon0 is not always deterministic in training.

Exploration discovers information; exploitation uses current estimates.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 16. Epsilon-greedy: actual probabilities

Random exploration includes the greedy action too. Timing: 2 minutes. Visual: epsilon.

Define G_Q(s) as the set of actions tied for the maximum. With4 actions, μ(a|s)=ε/4+(1−ε)I[a∈G]/|G|. The first term is uniform random branch probability; the second distributes the greedy branch uniformly across ties, matching training. Forε.2 and one greedy action, that action gets.8+.05=.85; every other action gets.05. Thus20%random branch differs from15%nongreedy action probability. With two ties each greedy action gets.45 and others.05; with four ties every action gets.25 regardless ofepsilon. The exploration flag means the random branch was selected, even if its resulting action is greedy.

With one greedy action: 85% greedy action, 15% other actions.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 17. Exploration in our implementation

The slider changes behavior, not the Q-learning target. Timing: 1 minutes. Visual: ties.

TRAINING_EPSILON=.2. There is no automatic decay. Slider0–100% updates subsequent training actions without clearingQ. Random branch samples all four actions uniformly; greedy branch randomly selects from exact maximizers. Evenε0 can randomize when values tie. Display arrows and evaluation use fixed up/right/down/left argmax order; initial zero-table arrows all up are arbitrary. Evaluation remains greedy whatever slider setting. Reset reconstructs learner with original seed and current epsilon, clearingQ/history/position. This slide should match the actual controls rather than a generic decaying-epsilon textbook pseudocode.

Reset clears Q and restores the seed, retaining your selected epsilon.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 18. Training versus evaluation

Measure the learned policy without changing the training run. Timing: 1.5 minutes. Visual: traineval.

Training uses epsilon-greedy behavior and updates a visitedQ entry after every transition. Evaluation starts atSTART, takes fixed-order greedy actions, and freezesQ. It preserves training position, partial episode counters/history and training RNG. Returning toStep/Train resumes the same learning state. Fixed tie order makes evaluation deterministic in this deterministic environment. Setting trainingepsilon0 would only remove the uniform exploration branch; step() would still updateQ and randomize ties. A separate evaluation function ensures no update/RNG effect. Repeating this same-start rollout is not independent statistical evidence of general robustness.

Epsilon = 0 alone does not disable learning; evaluation skips updates.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 19. Read the algorithm

A sampled transition changes one table entry. Timing: 1 minutes. Visual: code.

Present compact pseudocode:initializeQ=0; choose epsilon-greedy action; observe next state/reward/termination; calculate target; update visited pair; reset after termination or externalcap. Then show the exact update excerpt with whitespace rewrapped but identifiers/tokens preserved. An adjacent action-selection excerpt maps exploratory to the random branch and greedtie behavior. No environment install or GUI tutorial. Explain q[nxt].max() indexes actions at the next state, while q[state+(action,)] is the current sampled pair. All target values are read before assignment. Terminal guard avoids bootstrapping. Training loop still permits exploring after a useful route is learned.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 20. Interpret the learning results

Training behavior and greedy evaluation can have different lengths. Timing: 1 minutes. Visual: results.

Use saved after.png as a historical run, not newly executed training. After1000 defaultseed7 episodes, greedy path is right across bottom then up rightcolumn, eight moves. Other tested seeds can find equally short paths. Training can still take extra steps because epsilon remains.2; its episode lengths are not the greedy policy length. Red crosses mark truncated100-step episodes. Evaluation route, success, raw return and discounted return are different metrics. Arrows at unvisited states may remain arbitrary and do not certify globally optimalQ. The test suite uses an independentBFS route-length comparison; learning itself does not useBFS.

Eight moves → raw return 3; discounted return ≈ 0.950119.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 21. What does this result establish?

A successful finite run is not a general convergence proof. Timing: 1.5 minutes. Visual: limits.

Tabular discountedQ-learning has convergence results under finite states/actions,bounded rewards,repeated state/action sampling and suitable step-size schedules. Constant positiveepsilon can support coverage; epsilon need not decay for Q-learning to estimate optimal values, even while behavior remains exploratory. The current fixedα.2,1000episode run does not satisfy the general diminishing-step-size theorem just by succeeding. Coverage of visited actions alone does not establish all states were visited. Same-start deterministic evaluation checks a particular route, not broad robustness or global optimality. Distinguish the Qtable representation from later function approximation, where guarantees differ.

Coverage and learning-rate conditions matter beyond this demonstration.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 22. Predict the update, then train

Inspect → Step → Train → Evaluate. Timing: 10 minutes. Visual: demo.

Ten-minute demo replaces the older 17-minute runbook timing. First 3 minutes: inspect the maze and zero Q-table; predict an ordinary first update (old 0, target −1, new −0.2), then inspect the last-transition panel and a selected cell. Next 2 minutes: train a 100-episode batch and inspect lengths and truncation marks. Next 3 minutes: continue toward 1,000 episodes, then Evaluate and explain the frozen greedy route. Prepare the saved figure as a fallback if UI time is tight. Final 2 minutes: change epsilon, contrast subsequent training with unchanged greedy evaluation, then Reset, noting that epsilon is retained. A training batch includes the current partial episode. Setup is preparation; no demo interface changes.

3 min updates · 2 batch · 3 greedy route · 2 epsilon/reset

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 23. Questions & recap

Explain the target, the behavior, and the measurement. Timing: 5 minutes. Visual: recap.

Reserve five minutes. Ask students to calculate target 2.8 and new Q 0.56, then terminal target 10 and new Q 2. Which entry changes? The visited state/action pair. Why max? Greedy continuation at the next state. Why off-policy? Behavior can differ from the target. Does epsilon 0.2 mean 20% nongreedy actions? No: the random branch may choose a greedy action; with a unique greedy action the nongreedy probability is 0.15. Why evaluate separately? Freeze Q and preserve training state and RNG. Why does the step cap differ from the goal? An external collection stop retains bootstrapping. Connect HW3 Bellman vocabulary and HW4 reward-based improvement without adding assignment requirements. Week 9 moves to neural policies for continuous control.

Week 9: neural policies for continuous control.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 24. Bellman expectation and sample targets

Optional derivation for a general stochastic MDP. Timing: 0 minutes. Visual: equations.

For this expression, reward and termination are deterministic functions of the transition; stochastic rewards can instead be averaged jointly, as in the main conditional expectation. Condition on a fixed Q_t and current state/action. Averaging the sample target over successor probabilities yields TQ_t, the current Bellman optimality backup. It does not yield already-correct Q*. Actual targets fluctuate in stochastic environments, and stochastic approximation combines repeated experience. The target operator is not behavior-policy evaluation. Terminal d(s′)=1 removes continuation. In the deterministic maze the expectation has one outcome. This reasoning does not justify replacing every estimate with one noisy target.

- `Q^{*}(s,a) = ∑_{s′} P(s′|s,a) { r(s,a,s′)`
- `+ γ[1−d(s′)] max_{a′} Q^{*}(s′,a′) }`
- `𝔼[y_t | s_t=s, a_t=a, Q_t] = (TQ_t)(s,a)`

A sample targets the current Bellman backup, not an already known Q*.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 25. Convergence conditions and step sizes

Finite discounted tabular setting; sufficient repeated coverage. Timing: 0 minutes. Visual: equations.

N_n(s,a) counts updates to that pair. The example step size 1/N applies from its first visit. Standard tabular convergence conditions require finite states/actions, bounded rewards, gamma below one, infinitely repeated state/action sampling, and step sizes whose sum diverges while their squared sum converges. Diverging total adjustment avoids ignoring new information; square summability controls accumulated noise. Constant alpha 0.2 does not satisfy these general diminishing-step-size conditions, although the deterministic demo can work well. Off-policy Q-learning does not require behavior to become greedy if coverage and step-size assumptions hold. Do not present epsilon decay or SARSA-style GLIE as a universal Q-learning requirement. No new schedule is implemented.

- `For every (s,a):    ∑_n α_n(s,a) = ∞`
- `∑_n α_n(s,a)^{2} < ∞`
- `Example:    α_n(s,a) = 1 / N_n(s,a)`

Our constant α = 0.2 and finite training are teaching defaults.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 26. Q-learning versus SARSA: extended check

Same old table and nonterminal sample in both calculations. Timing: 0 minutes. Visual: equations.

SARSA uses the next action actually selected by its behavior policy; Q-learning uses the maximum next-state estimate. Compare hypothetical updates from the same old table, not successive updates to one table. With next values [4,1,−2,0], reward −1, and an exploratory next action valued −2, targets are 2.8 versus −2.9; old zero and alpha 0.2 give 0.56 versus −0.58. If the selected next action were the maximizer valued 4, the targets would agree numerically while the algorithm definitions still differ. At true termination both use reward alone. Our update does not need the next behavior action, and the demo has no SARSA implementation.

- `Q-learning:    y = −1 + 0.95 max{4,1,−2,0} = 2.8`
- `SARSA:          y = −1 + 0.95(−2) = −2.9`
- `Old = 0, α = 0.2:    Q new = 0.56; SARSA new = −0.58`

If the selected next action is greedy, the two targets may agree.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.

### 27. The maximum can favor noisy estimates

Optional motivation for Double Q-learning. Timing: 0 minutes. Visual: bias.

Noisy estimates can acquire positive maximization bias when the same estimates select and evaluate the largest value: E[max estimates] is at least max E[estimates]. Double Q-learning separates action selection and evaluation across two estimators. It addresses selection bias while retaining greedy-continuation logic and off-policy learning. It does not promise zero error or universal superiority. Mention the motivation only; no new algorithm or stochastic bias experiment is added. Incomplete early estimates in this deterministic maze should not be confused with a measured demonstration of noisy maximization bias.

Useful optimality logic does not make estimated maxima unbiased.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.
- https://papers.nips.cc/paper/2010/hash/091d584fced301b442654dd8c23b3fc9-Abstract.html

### 28. Termination, truncation, and code

The bootstrap guard checks termination alone. Timing: 0 minutes. Visual: terminalCode.

The actual update guards the bootstrap with terminated only. Learner.step calls update before computing truncation (steps at least 100 and not terminated), then resets collection for either condition. The external cap therefore does not zero continuation or substitute the reset start for the observed next state. An inherent finite-horizon task is different: remaining time belongs in the Markov state, and its horizon can be a true termination. Existing tests set terminal Q to 999 to verify it is ignored, and arrange a 100th-step transition with next Q equal to 4 to verify target 2.8. The demo does not depend on Gymnasium; its official documentation supplies the conceptual reference.

Use the observed next state before resetting collection.

- https://www.gatsby.ucl.ac.uk/~dayan/papers/cjch.pdf
- Local: demo/gridworld.py, learning.py, demo.py, test_demo.py, README.md, before.png and after.png.
- https://gymnasium.farama.org/tutorials/gymnasium_basics/handling_time_limits/

## Exact examples and code excerpts

α=.2,γ=.95,ε=.2, zero5×5×4 table, seed7. NextQ=[4,1,−2,0], ordinary reward−1,old0:Q-learning target2.8,new.56; if next exploratory action has value−2, SARSA target−2.9,new−.58. First goal target10,new2. External100step cap retains bootstrapping. With one greedy action, epsilon-greedy probabilities are.85,.05,.05,.05; two tied maximizers receive.45 each. Eight-move rewards are seven−1 then+10:raw3,discounted.9501188828124985.

### update — actual learning.py excerpt, whitespace rewrapped

```python
old = float(q[state+(action,)])
target = reward + (0 if terminated else
                  gamma*float(q[nxt].max()))
new = old + alpha*(target-old)
q[state+(action,)] = new
```

### explore — actual learning.py excerpt, whitespace rewrapped

```python
exploratory = bool(self.rng.random() < eps)
```

### terminal — actual learning.py excerpt, whitespace rewrapped

```python
target = reward + (0 if terminated else
                  gamma*float(q[nxt].max()))
```

## Validation and rehearsal boundaries

All ten original nonmetadata files and demo .gitignore read; no professor presentation supplied. Retain Sutton/Barto reference without claiming unavailable PDF review. Render/reopen PowerPoint, inspect28 previews, notes, five hidden backups,28 PDF pages, sources, equations and30+10+5 timing. Verify protected hashes. Independent arithmetic/source checks do not execute Python. Python unavailable locally: existing tests and headless training unexecuted here. Saved figures and documented seed7 results are historical. Classroom GUI rehearsal is separate. Evidence and reproducible commands are in slides/README.md and validation.json/review.json.