# Week 9 — Policy Gradients and Actor–Critic

**30 minutes presentation/worked mathematics + 10 minutes visual demo + 5 minutes questions/recap.** This selected schedule replaces the older presentation timing; preserved teaching notes and demo runbook retain their previous schedule. 30 English slides: title, 22 teaching slides, demo transition, recap, and five hidden backups. Light background, blue/teal accents, editable diagrams and equations. Preserve all demo files, checkpoints, README and teaching notes.

## Sequence and timing

| Slide | Topic | Minutes |
|---|---|---:|
| 1 | Policy gradients & actor–critic | 0 |
| 2 | Why tables become impractical | 1.5 |
| 3 | Learn the policy directly | 1 |
| 4 | Our balancing task | 1 |
| 5 | A stochastic continuous policy | 1.5 |
| 6 | What are we optimizing? | 1 |
| 7 | Where the policy gradient comes from | 2 |
| 8 | Reward-to-go and the gradient estimate | 1.5 |
| 9 | REINFORCE intuition | 1 |
| 10 | Why plain returns are noisy | 1.5 |
| 11 | The baseline idea | 1.5 |
| 12 | Baseline worked example | 1 |
| 13 | Advantage: better than expected | 1.5 |
| 14 | Learn the baseline: introduce the critic | 1 |
| 15 | Actor–critic and the TD estimate | 1.5 |
| 16 | Calculate one update signal | 1 |
| 17 | Our five-step return target | 1.5 |
| 18 | Two losses, two learning roles | 1.5 |
| 19 | The A2C training loop | 1 |
| 20 | Exploration versus evaluation | 1 |
| 21 | PPO: discourage excessive policy changes | 2 |
| 22 | SAC: reward plus entropy | 2 |
| 23 | What the demonstration establishes | 1.5 |
| 24 | Watch rewards become a balancing policy | 10 |
| 25 | Questions & recap | 5 |
| 26 | Expanded trajectory-gradient derivation (hidden) | 0 |
| 27 | Baseline cancellation & Gaussian gradient (hidden) | 0 |
| 28 | Multi-step targets and episode boundaries (hidden) | 0 |
| 29 | Bounded density and gradient separation (hidden) | 0 |
| 30 | A2C, PPO, and SAC in context (hidden) | 0 |

## Speaker guidance, mathematics and visuals

### 1. Policy gradients & actor–critic

Learn actions from rewards; learn values to guide the policy. Timing: 0 minutes. Visual: title.

Use the selected 30-minute explanation and worked-math block, 10-minute visual demo, and 5-minute recap. The protected teaching notes and demo runbook retain their previous schedule; this deck and revised plan specify the new presentation schedule. Students know MDPs, Q-learning, and imitation learning. Explain symbols as they appear. Our sequence is directly parameterized policy, policy-gradient derivation, variance and baseline, advantage, critic, then practical algorithm overviews. The demo is synchronous five-step advantage actor–critic, not PPO or SAC. There is no professor presentation supplied for this week. Prepared training figures and checkpoint results are historical, not a new training run.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- https://arxiv.org/abs/1602.01783
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 2. Why tables become impractical

Continuous observations and actions make discretization expensive. Timing: 1.5 minutes. Visual: tableSize.

Recall the small Week 8 Q-table. Here the robot has four real-valued observations and one real-valued action. A deliberately illustrative discretization uses 100 bins per state dimension and 100 action bins: 100^4 states times 100 actions gives 10^10 entries. Float32 storage alone would be 40 GB in decimal units, before other costs. Finer grids grow quickly; coarser grids merge different physical situations. Storage is only part of the difficulty: experience must cover useful regions, and table entries do not automatically share what was learned. A network shares parameters across inputs and can generalize, but inaccurate generalization remains possible. Continuous control does not make every value-based method impossible; we focus on policy parameterization.

Function approximation also exists for value-based RL.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 3. Learn the policy directly

Observation → action distribution, rather than a table lookup. Timing: 1 minutes. Visual: policy.

Compare the Week 8 route: observe state, read four Q estimates, choose via greedy or epsilon-greedy selection. A policy network instead maps observations to parameters of an action distribution. Its trainable parameters are theta. An action can be drawn from that distribution without enumerating a fine action grid. The critic later supplies value estimates to train the actor, so policy-based learning need not abandon values. Contrast with Week 7 behavior cloning: supervised labels tell us what the expert did; policy-gradient learning uses consequences and reward-weighted updates. Direct policy parameterization can also represent discrete distributions. It does not imply the model learns a dynamics model or receives an expert.

Reward feedback supplies learning signals; there are no expert action labels.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 4. Our balancing task

Move the cart to keep the pole upright. Timing: 1 minutes. Visual: cart.

Use the exact InvertedPendulum-v5 demo. Observations are cart position, pole angle, cart velocity, and pole angular velocity. The single continuous actuator command lies in [-3,3]; avoid labeling it a Newton force without checking the actuator model. The pinned environment supplies reward 1 for a healthy post-step state and 0 on failure. It terminates if any observation is nonfinite or absolute pole angle exceeds 0.2 rad, and its wrapper truncates after 1000 steps. Equality to 0.2 by itself does not terminate. The reward asks for survival, rather than penalizing cart displacement or matching an expert. The presentation does not change the task, environment, or reward.

MuJoCo supplies dynamics and reward-bearing experience.

- https://gymnasium.farama.org/environments/mujoco/inverted_pendulum/
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 5. A stochastic continuous policy

A distribution describes which actions are likely. Timing: 1.5 minutes. Visual: distribution.

Teach the idea with an editable bell curve: the actor maps an observation to a Gaussian mean and spread, and training draws an action sample. The mean locates the center; spread determines dispersion, not the learning rate. For a continuous variable the curve is a density: probability comes from an interval area, and probability at an exact real-valued point is zero. Use a sample marker away from the mean to illustrate exploration. The drawn bell curve represents the underlying Gaussian idea, not an exact plot of the bounded applied-action density. In the actual demo the underlying sample is transformed to respect limits, but keep the specific function off this slide. Detailed transformation and log-density corrections belong in backup 4. Training does not use an epsilon slider.

Mean: central action. Spread: randomness. Respect actuator limits.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 6. What are we optimizing?

Increase expected discounted return. Timing: 1 minutes. Visual: equations.

Theta is the vector of trainable policy parameters, not a robot angle. Tau is a trajectory, T its horizon, gamma the reward discount, and eta the optimization step size. R_t follows A_t, matching previous lessons; some references call it R_(t+1). J is expected performance over initial states, actions, and environment outcomes. A gradient is a vector of sensitivities: how changing each parameter changes the objective locally. Ascent adds the gradient because larger return is preferred. We cannot directly observe this expectation or differentiate a single reward through the simulator in this method; we estimate the gradient using interaction. Finite updates and imperfect estimates do not guarantee improvement. The demo optimizer minimizes a negative surrogate loss.

- `J(θ) = 𝔼_{τ∼πθ}[ ∑_{t=0}^{T−1} γ^t R_t ]`
- `θ ← θ + η ∇_θ J(θ)`

θ: policy parameters · η: step size · γ: reward discount

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 7. Where the policy gradient comes from

Differentiate trajectory likelihood, rather than simulator physics. Timing: 2 minutes. Visual: equations.

Explain the product: a trajectory requires an initial state, each chosen action, and each resulting next state. Rho_0 is the initial-state distribution and P is transition probability or density. Taking the logarithm turns the product into a sum. The log-derivative identity follows from the chain rule, derivative log p = derivative p divided by p. When differentiating with respect to actor parameters, initial-state and dynamics terms vanish because these environment functions do not depend on theta. Substitute this score into the derivative of the expected trajectory return to obtain a reward-weighted sum of action log-gradients. Model-free sampling does not mean the physics has no dynamics; it means this update does not need to know or differentiate its equations. Full integration and regularity assumptions are in backup 1.

- `p_θ(τ) = ρ_0(s_0) ∏_t π_θ(a_t|s_t) P(s_{t+1}|s_t,a_t)`
- `∇_θ p_θ(τ) = p_θ(τ) ∇_θ log p_θ(τ)`
- `∇_θ log p_θ(τ) = ∑_t ∇_θ log π_θ(a_t|s_t)`

The initial-state law and environment dynamics do not depend on θ.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 8. Reward-to-go and the gradient estimate

An action receives credit for future rewards. Timing: 1.5 minutes. Visual: equations.

G_t discounts relative to the action at time t, while gamma^t weights that decision relative to the episode start. Earlier rewards do not depend causally on the current action, so their score-function contributions vanish in expectation; dropping them improves the credit signal. The exact discounted finite-trajectory gradient retains the outer gamma^t factor. Approximate the expectation by averaging sums from trajectories sampled under the current policy. Uppercase variables describe random states/actions/rewards; lowercase symbols describe a collected sample. The demo uses uniform rollout-sample averaging with discounted bootstrapped advantages, a practical A2C surrogate; do not identify it with the exact outer-gamma^t trajectory estimator. Backup 1 makes this distinction explicit. We are not maximizing over sampled successor outcomes.

- `G_t = ∑_{k=t}^{T−1} γ^{k−t} R_k`
- `∇_θ J = 𝔼[ ∑_t γ^t G_t ∇_θ log π_θ(A_t|S_t) ]`
- `ĝ = average of these weighted scores over trajectories`

Keep γᵗ for the stated discounted start-state objective.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 9. REINFORCE intuition

Return weights the direction of an action log-gradient. Timing: 1 minutes. Visual: reinforce.

REINFORCE uses Monte Carlo reward-to-go rather than a bootstrapped critic target. The per-sample formula illustrates one term in the gradient estimate. A positive weight locally encourages the sampled action likelihood; a negative weight discourages it. Network parameters are shared, so probabilities at other states/actions can change too. Negative raw returns are possible in general, but this balancing demo has nonnegative rewards. Negative centered advantages will become meaningful even when all raw returns are positive. The actor loss is a surrogate for a gradient, not a direct measure of policy performance. Do not teach that minimizing it repeatedly on an old batch guarantees increasing return. This intuition explains likelihood weighting before introducing a baseline.

- `θ ← θ + η γ^t G_t ∇_θ log π_θ(a_t|s_t)`

A local likelihood update is not an expert action label.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 10. Why plain returns are noisy

The same policy can produce very different trajectories. Timing: 1.5 minutes. Visual: variance.

Even with deterministic physics, different reset states and stochastic actions create variable episode returns. Long trajectories mix the effects of many decisions. An action taken in an easy state may have a large return mainly because most actions there would have done well. Using the entire return magnitude can make score-function updates noisy and inefficient. A reference level centers the signal around what is expected at that state. Distinguish variance of the gradient estimator from environment stochasticity and from critic approximation error. A baseline is not extra reward, a new objective, or an expert label. It changes the estimator while preserving its expected score-function gradient under the stated assumptions. Good variance reduction improves learning efficiency, not a universal finite-run convergence guarantee.

Compare outcomes against a useful reference level.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 11. The baseline idea

Subtract expected performance without changing the mean gradient. Timing: 1.5 minutes. Visual: equations.

Fix a state s. Multiplying the action score by b(s), then averaging over actions, gives b(s) times the integral of the policy derivative. A normalized policy integrates to one, whose derivative is zero. For discrete actions the integral is replaced by a sum. Thus subtracting an action-independent baseline leaves the expected score-function gradient unchanged. Hold the baseline fixed while differentiating the actor loss; otherwise extra derivatives are introduced. A state-value estimate is a useful choice, but it is not universally the mathematically optimal variance-minimizing baseline. An arbitrary poor baseline may increase variance. This cancellation proof concerns baseline subtraction; replacing full returns with imperfect bootstrapped targets can introduce a separate source of bias.

- `G_t → G_t − b(S_t)`
- `𝔼_{a∼πθ}[ b(s) ∇_θ log π_θ(a|s) ]`
- `= b(s) ∇_θ ∫ π_θ(a|s) da = b(s) ∇_θ 1 = 0`

b(s) is action-independent and held fixed in the actor gradient.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 12. Baseline worked example

Judge an outcome relative to what was expected. Timing: 1 minutes. Visual: baselineExample.

Illustrate two outcomes at the same state with a fixed baseline of 6. An outcome return 8 gives weight +2; a return 4 gives weight -2. Both raw returns were positive, but the second did worse than the reference. These two illustrative observations do not prove an unbiased empirical estimate or establish that 6 is the true value. The cancellation result is about expectation over the policy, not an arbitrary two-sample batch. Subtracting the baseline does not alter the environment rewards or observed episode return. Explain local encourage/discourage behavior using the corresponding action log-gradient, not a direct addition to the force command. This motivates evaluating actions relative to average performance at the current state.

Raw returns may both be positive; centered weights can differ in sign.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 13. Advantage: better than expected

Compare taking this action with following the policy on average. Timing: 1.5 minutes. Visual: equations.

Reconnect to Week 6 definitions. V^pi averages actions according to the policy at the current state; Q^pi fixes this first action and follows the policy thereafter. Advantage measures the difference. Under the same policy, the action-weighted average of true advantage is zero. Positive means better than average continuation at that state, not better than every possible action or globally optimal. Distinguish pi, the policy label, from an exponent. A hat denotes an estimate computed from finite samples and a learned critic. Replacing the return with a suitable action-value or advantage signal is the bridge to actor–critic. In this demo the critic estimates V, and the return target supplies an approximate action-conditioned outcome signal.

- `V^{π}(s): expected return from s under π`
- `Q^{π}(s,a): take a, then follow π`
- `A^{π}(s,a) = Q^{π}(s,a) − V^{π}(s)`

True advantage is unknown; learning uses an estimate Â.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html

### 14. Learn the baseline: introduce the critic

The actor chooses; the critic estimates expected return. Timing: 1 minutes. Visual: actorCritic.

Draw separate actor and critic networks receiving the same observation. Actor parameters theta specify a distribution over actions. Critic parameters phi map the observation to one scalar V_phi(s). Experience supplies rewards, next observations, and target returns used to fit the critic. The estimated advantage supplies the actor learning weight. A learned baseline adapts to different states rather than subtracting a single constant. Bootstrapped targets allow updates without waiting for a whole episode, potentially reducing variance, with critic approximation and bootstrap bias as tradeoffs. The actor still collects real reward-bearing experience, and the critic does not choose the correct action or modify simulator physics. The demo uses separate networks, although other architectures can share features.

A critic is a value estimator, not an expert controller.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- https://arxiv.org/abs/1602.01783
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 15. Actor–critic and the TD estimate

Compare a one-step return target with the current value prediction. Timing: 1.5 minutes. Visual: equations.

The one-step target includes immediate reward and discounted next-state value. d_t means true task termination, not merely stopping collection. At failure, there is no continuation; an external time limit still bootstraps from the final pre-reset observation. With an exact V^pi, the conditional expectation of this TD residual at a fixed state/action equals the true advantage. With a learned critic it is an approximate signal and may be biased. The sampled sign can also be noisy. The critic learns toward y_t; the actor weights the sampled-action log-gradient by the residual. Contrast Week 8: there is no maximum over next actions because this critic evaluates the current stochastic policy rather than computing a Q-learning optimality target.

- `y_t = r_t + γ(1−d_t) V_φ(s_{t+1})`
- `Â_t = y_t − V_φ(s_t)`
- `d_t = 1: true termination; d_t = 0: continuation`

Bootstrapping uses an estimate of future return.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- https://arxiv.org/abs/1602.01783
- https://gymnasium.farama.org/tutorials/gymnasium_basics/handling_time_limits/
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 16. Calculate one update signal

r = 1 · γ = 0.99 · V(s) = 5 · V(s′) = 6 Timing: 1 minutes. Visual: equations.

This is a nonterminal illustrative transition, not a measured state from the checkpoint. Keep the prediction 5, future prediction 6, target 6.94, and advantage 1.94 distinct. The critic prediction is below the target, so minimizing squared error moves its local output upward. The positive detached advantage increases the sampled action likelihood locally through the actor update. It does not add 1.94 to the actuator command. The actual parameter change depends on network derivatives and the optimizer. If the target were below 5, the advantage would be negative. The existing target unit test checks 6.94 and 1.94. The scalar squared error 3.7636 provides a concrete link to critic fitting before discussing averaged minibatch losses.

- `y = 1 + 0.99 × 6 = 6.94`
- `Â = 6.94 − 5 = +1.94`
- `Critic squared error = (5 − 6.94)^2 = 3.7636`

Encourage the sampled action; fit the critic toward 6.94.

- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.
- https://arxiv.org/abs/1602.01783

### 17. Our five-step return target

Combine observed rewards with a learned continuation value. Timing: 1.5 minutes. Visual: equations.

The displayed formula assumes no boundary within those n steps. The demo collects five steps from eight environments and builds targets backward. Earlier samples can include up to five observed rewards; later rollout samples have a shorter return to the rollout end. The critic supplies the tail. More observed rewards reduce reliance on the immediate bootstrap but can increase sampling variance. At termination the tail is zero, while truncation uses that transition final-observation value. Stop at either reset boundary: never include the rewards or value of the next episode as continuation of the old one. The collector computes next values before resetting. This is n-step A2C, not a GAE implementation. The general formula and boundary example are expanded in backup 3.

- `y_t^{(n)} = ∑_{k=0}^{n−1} γ^k r_{t+k} + γ^n V_φ(s_{t+n})`
- `n = 5: r_t + γr_{t+1} + ⋯ + γ^4 r_{t+4} + γ^5 V_φ(s_{t+5})`
- `Actual boundary handling can shorten the return.`

Termination: no bootstrap. Truncation: use the final observation.

- https://arxiv.org/abs/1602.01783
- https://gymnasium.farama.org/tutorials/gymnasium_basics/handling_time_limits/
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 18. Two losses, two learning roles

Treat advantage and return targets as fixed learning signals. Timing: 1.5 minutes. Visual: equations.

N is the number of transitions in the batch, 40 here. stopgrad means keep the numerical quantity fixed during differentiation. It prevents actor-loss gradients flowing through the value baseline, and prevents critic fitting from chasing gradients through its own return target. The policy likelihood is differentiated at the already sampled action, not through the simulator or a reparameterized action sample. The code uses separate networks and one optimizer over their parameters; the gradient split matches the two roles, with critic coefficient 0.5. Plain gradient-descent arrows explain direction; actual training uses RMSprop and gradient clipping, so these are conceptual update equations rather than a literal optimizer implementation. The actor loss is not a direct performance metric. Show short exact excerpts in notes/backup.

- `L_{actor} = −(1/N) ∑_t log π_θ(a_t|s_t) stopgrad(Â_t)`
- `L_{critic} = (1/N) ∑_t [V_φ(s_t) − stopgrad(y_t)]^2`
- `L = L_{actor} + 0.5 L_{critic}`
- `θ ← θ − η∇_θ L_{actor}    |    φ ← φ − η∇_φ L_{critic}`

Actor ascent becomes descent on a negative surrogate loss.

- https://arxiv.org/abs/1602.01783
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 19. The A2C training loop

One update per fresh batch, then collect with the updated policy. Timing: 1 minutes. Visual: loop.

Synchronous advantage actor–critic collects all eight environment streams under the same current policy, builds bootstrapped targets, computes advantages and losses, and performs one optimizer step. Then it obtains fresh experience from the changed policy. The environment instances have independently seeded streams; they do not imply this implementation steps simulator processes concurrently. This synchronous method differs from the asynchronous A3C paper cited for the underlying multi-step actor–critic mathematics. The demo has no replay buffer and does not repeatedly optimize old rollout batches. Defaults are gamma .99, RMSprop learning rate .0007, gradient norm limit .5, and no entropy bonus. Actor and critic each use separate 64–64 tanh hidden layers. These settings go in notes, not the main loop diagram.

8 environments × 5 steps = 40 transitions per update.

- https://arxiv.org/abs/1602.01783
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 20. Exploration versus evaluation

Collect varied experience; test a frozen policy consistently. Timing: 1 minutes. Visual: evaluation.

Training draws actions from the learned Gaussian distribution; its learned state-independent spread provides exploration. There is no epsilon-greedy switch or guaranteed monotonic reduction of randomness. The standard deviation is numerically bounded by the code, but detailed ranges stay in preparation notes. Evaluation uses the deterministic bounded action associated with the Gaussian mean and no weight updates. That action is not generally the expected action after a nonlinear transformation. The critic learned discounted return under stochastic training behavior, while the viewer displays its estimate during deterministic evaluation and also shows undiscounted reward accumulated so far. These quantities need not agree. Separate validation starts select checkpoints; held-out test starts provide final reporting, not selection.

Evaluation changes neither weights nor training environment streams.

- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 21. PPO: discourage excessive policy changes

Keep the advantage signal; limit incentives for large likelihood changes. Timing: 2 minutes. Visual: ppo.

Explain rho as new likelihood divided by collection-policy likelihood for the same sampled action. Advantage estimates come from the old rollout and are held fixed. Clipping removes objective incentives to increase positive-advantage action likelihood too much or decrease negative-advantage likelihood too much. For epsilon_c .2, rho1.5 and advantage2 give min(3,2.4)=2.4. For rho.5 and advantage-2, min(-1,-1.6)=-1.6. It does not impose a hard bound on all ratios or guarantee safe improvement. Epsilon_c is a clipping range, not Week 8 exploration probability. PPO commonly makes several minibatch passes over a newly collected rollout and fits a value critic; it is classified as on-policy despite within-rollout policy ratios. These implementation details are overview only, not changes to our A2C demo.

- `ρ_t(θ) = π_θ(a_t|s_t) / π_{old}(a_t|s_t)`
- `L^{clip} = 𝔼[ min(ρ_t Â_t,`
- `                 clip(ρ_t, 1−ε_c, 1+ε_c) Â_t) ]`
- `θ ← θ + η ∇_θ L^{clip}`

Overview only; our demo implements A2C.

- https://arxiv.org/abs/1707.06347
- https://spinningup.openai.com/en/latest/algorithms/ppo.html

### 22. SAC: reward plus entropy

Learn valuable actions while rewarding policy randomness. Timing: 2 minutes. Visual: sac.

Use the modern twin-Q SAC variant described in the technical guide, while citing the original paper for motivation. D is a replay buffer of transitions. The stochastic actor learns to maximize useful Q values plus policy entropy, equivalently minimizing alpha_ent log likelihood minus the smaller critic estimate. Alpha_ent is entropy temperature, not the actor learning rate eta. For continuous actions entropy is differential entropy; log density can be positive, and entropy is not a safety guarantee. Each critic fits the soft target, which samples a new next action a-prime from the current actor; it does not take a discrete max over enumerated actions. Bars denote slowly updated target critics; twin critics reduce overestimation. Reparameterized actor gradients, temperature tuning, target-network averaging and squared critic loss belong in notes. SAC is off-policy and reuses replay data. None of these mechanisms is present in our A2C demo.

- `L_π = 𝔼_{s∼D, a∼πθ}[ α_{ent} log π_θ(a|s) − min_i Q_{φi}(s,a) ]`
- `y = r + γ(1−d)[ min_i Q̄_{φi}(s′,a′)`
- `                               − α_{ent} log π_θ(a′|s′) ]`
- `θ ← θ − η ∇_θ L_π; critics fit Q_{φi}(s,a) to y`

Overview only; our demo implements A2C.

- https://arxiv.org/abs/1801.01290
- https://spinningup.openai.com/en/latest/algorithms/sac.html

### 23. What the demonstration establishes

Matched comparisons show learning; multiple seeds show its variability. Timing: 1.5 minutes. Visual: results.

The classroom figures and results JSON report earlier completed runs, not a new validation run. Seed 7: initial mean length 28.45, selected mean 1000, checkpoint at 100,000 transitions. Seed 0: initial 28, selected 220.15, checkpoint at 25,000. Seed 1: initial 27.95, selected 1000, checkpoint at 75,000. Each run trained for 250,000 transitions. Seeds 7 and 1 reached the cap on all 20 test starts; seed 0 did not. More training was not monotonically better. Ten validation seeds select the checkpoint; 20 separate test seeds provide final reporting. These small perturbations do not establish robustness to large disturbances or changed dynamics. A failed episode return is one less than its length; a healthy 1,000-step episode returns 1,000. Training curves use stochastic actions; evaluation is deterministic.

Historical checkpoints: validation-selected, tested on separate starts.

- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 24. Watch rewards become a balancing policy

Initial → trained on the same start → inspect → compare seeds. Timing: 10 minutes. Visual: demo.

Use prepared classroom checkpoints, not full live training. First 2 minutes: initial policy, observations, continuous command and survival reward. Next 4 minutes: switch to trained on the same test seed and camera; pause to inspect pole angle, accumulated reward and critic V. V is a prediction, rather than reward accumulated so far. Next 2 minutes: show the prepared target/advantage/loss excerpt and connect 6.94 and 1.94 to the two learning roles. Final 2 minutes: historical validation and held-out comparisons for all three training seeds. The viewer starts paused at test seed 20000. Switching policy resets to the same start. Restart preserves pause status and policy; Next episode advances through 20 fixed test seeds. Saved plots provide a rendering fallback. Classroom viewer rehearsal remains separate from PowerPoint validation.

2 min initial · 4 trained · 2 update signals · 2 evidence

- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 25. Questions & recap

Explain the learning signal, the baseline, and the two roles. Timing: 5 minutes. Visual: recap.

Use 5 minutes for questions and checks: why does the table grow with state dimension? What does a log-probability gradient do, and why weight it by return? Why can an action-independent baseline be subtracted without changing the expected score-function gradient? Calculate target 6.94 and advantage 1.94; what does positive advantage encourage? Identify actor and critic, and distinguish observed return from predicted value. Compare A2C fresh-rollout updates with PPO clipping and SAC replay/entropy. Do not require advanced PPO/SAC derivations from one overview slide. Connect HW4 training/evaluation habits and HW5 policy-gradient theory. Check that students understand the critic is not an expert controller and that no algorithm guarantees improvement from every sampled update.

Policy gradient → baseline → advantage → actor–critic.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 26. Expanded trajectory-gradient derivation

Exact discounted start-state objective and practical rollout surrogate. Timing: 0 minutes. Visual: equations.

Start from J as an integral, interchange derivative and integral under regularity assumptions, and apply the likelihood-ratio identity. Expand log trajectory density into action scores. Split the full discounted return into past and future terms for each score. Conditional on the history/state, the expected action score is zero, so past terms cancel; future terms equal gamma^t times relative discounted G_t. The exact result refers to the stated finite-horizon discounted start-state objective and uses expectations over on-policy trajectories. Infinite-horizon formulations can express related gradients through discounted occupancy measures. The uniform transition averaging in this implementation is a practical A2C surrogate using discounted targets, not a literal implementation of the outer-gamma^t trajectory estimator. Do not silently switch objectives or claim mathematical exactness of imperfect bootstrapped advantages.

- `F(τ) = ∑_k γ^k R_k;   J = ∫ p_θ(τ) F(τ) dτ`
- `∇_θ J = ∫ p_θ(τ) F(τ) ∇_θ log p_θ(τ) dτ`
- `= 𝔼[ ∑_t γ^t G_t ∇_θ log π_θ(A_t|S_t) ]`
- `Demo surrogate: −mean[log π_θ(a_t|s_t) stopgrad(Â_t)]`

Uniform rollout weighting differs from the explicit γᵗ estimator.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 27. Baseline cancellation & Gaussian gradient

The baseline centers the signal; the score sets its direction. Timing: 0 minutes. Visual: equations.

The Gaussian derivative follows from log density = -log sigma - (z-mu)^2/(2sigma^2) plus a constant. It is evaluated at a fixed sample z. A positive advantage with a sample above the mean moves the mean toward that sample in this scalar illustration; negative advantage would reverse it. The actual bounded-policy score at fixed latent sample retains the parameter derivative of this Gaussian because its action transformation does not depend on the actor parameters. Baseline cancellation requires no dependence on the sampled action and a normalized differentiable density. A learned baseline can be inaccurate while still cancelling in expectation if treated correctly as fixed; this does not make a bootstrapped advantage estimator unbiased. V^pi is a useful but not universally minimum-variance baseline. No scalar network parameter update is claimed to reproduce the real optimizer.

- `𝔼_a[b(s)∇_θ log π_θ(a|s)] = b(s)∇_θ 1 = 0`
- `For z ∼ Normal(μ,σ²):   ∂ log p(z)/∂μ = (z−μ)/σ²`
- `Example: z = 1, μ = 0, σ = 1, Â = 2`
- `η = 0.1:   μ ← 0 + 0.1 × 2 × 1 = 0.2`

Illustrative scalar ascent; the real network uses RMSprop.

- https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 28. Multi-step targets and episode boundaries

Continue within the episode; never bootstrap through a reset. Timing: 0 minutes. Visual: equations.

This three-step example matches an existing return-target unit test and illustrates the same backward recursion used for five-step rollouts. In general, true termination removes future value while retaining that transition immediate reward. Actual failure reward here is0, although synthetic tests can use different rewards to isolate the recursion. Truncation bootstraps from the final observation then stops recurrence across that boundary. A two-row unit test deliberately uses rewards1 then100 in different episodes and final values6 then999: the first truncated target must be6.94, not include100. Collector values next observations before replacing them with reset observations. Monte Carlo returns avoid bootstrap approximation but can have high variance; short TD targets rely more on the learned critic. This implementation uses neither GAE nor generalized lambda-return machinery.

- `Three observed rewards, tail value 2:`
- `y = 1 + 0.99 + 0.99² + 0.99³ × 2 = 4.910698`
- `True failure: tail = 0`
- `Time cap: tail = V(final observation), not V(reset state)`

Longer targets use more experience and rely less on the critic.

- https://arxiv.org/abs/1602.01783
- https://gymnasium.farama.org/tutorials/gymnasium_basics/handling_time_limits/
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 29. Bounded density and gradient separation

Implementation reference: fixed samples and fixed return targets. Timing: 0 minutes. Visual: density.

The transformation bounds actuator commands. Correct likelihoods require the change-of-variable Jacobian and scale factor. The code computes a stable expression for log Jacobian rather than directly subtracting nearly equal values when tanh saturates. Sampling uses sample(), not rsample(); latent is detached when evaluating the actor score. Advantages are detached so actor-loss backward does not train the critic through its baseline. Targets are detached while critic squared error is fitted. The existing tests compare against PyTorch TransformedDistribution, check finite densities at large latent magnitudes, and verify gradient separation. Deterministic inference uses3*tanh(mean), not generally E[3*tanh(z)]. These are implementation checks and mathematical reference details; do not insert the transformation formula into teaching slide4.

- `z ∼ Normal(μ_θ(s),σ²);   a = 3 tanh(z)`
- `log π_θ(a|s) = log p_θ(z|s) − log[3(1−tanh²z)]`

Specific action transformation belongs here, not on the introductory slide.

- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

### 30. A2C, PPO, and SAC in context

Different update mechanisms; shared actor–critic ideas. Timing: 0 minutes. Visual: comparison.

A2C here: stochastic actor, V critic, fresh five-step rollouts, one update per batch, no replay, no entropy bonus. PPO: actor and V critic, clipped likelihood-ratio objective, several minibatch passes over a recent rollout. SAC: stochastic actor, twin Q critics, off-policy replay, target critics, entropy objective. These are the discussed variants; implementations vary. Demo settings: separate 64–64 tanh networks; eight environments; five steps; gamma 0.99; RMSprop learning rate 0.0007; critic coefficient 0.5; gradient norm limit 0.5; 250,000-transition budget. Validation seeds 10000–10009 choose the checkpoint; test seeds 20000–20019 assess it. Saved seed 0 results show that more training need not improve every run. Theory references do not imply this educational implementation reproduces published benchmarks.

Only A2C is implemented in this week's demo.

- https://arxiv.org/abs/1602.01783
- https://arxiv.org/abs/1707.06347
- https://spinningup.openai.com/en/latest/algorithms/sac.html
- Local sources: demo/networks.py, algorithm.py, train.py, evaluate.py, watch.py, compare.py, test_demo.py, README.md, classroom/settings.json and classroom/results.json.

## Actual source excerpts

### losses — demo source, whitespace may be rewrapped

```python
advantage = targets.detach()-values
actor_loss = -(model.log_probability(obs,latent.detach())*advantage.detach()).mean()
critic_loss = (values-targets.detach()).square().mean()
```

### action — demo source, whitespace may be rewrapped

```python
latent = self.distribution(obs).sample()
return 3*latent.tanh(), latent
```

## Validation and rehearsal boundaries

Read existing plan, teaching notes, demo runbook, all Python sources/tests, dependency pins, ignore rules, saved settings/results and both plots. Checkpoints are preserved binary artifacts; source review does not claim their execution. No professor deck supplied. Verify all 30 previews, notes, timing, hidden slides 26–30, PDF pages, numerical calculations and source excerpts. Report protected SHA-256 hashes. Python availability is rechecked; if unavailable, existing tests/checkpoint evaluation remain unexecuted locally. Historical training results are clearly labeled and classroom viewer rehearsal remains separate from PowerPoint checks. Reproduction commands and machine-readable evidence are under slides/.