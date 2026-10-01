# Week 9 — Policy Gradients and Actor–Critic

## Goal

- Explain `state → actor network → continuous action` and the critic's training role.
- Calculate an advantage estimate and identify the actor/critic losses in code.
- Compare untrained and trained MuJoCo behavior on matched initial states.
- Understand that training results vary across seeds; no PPO or SAC implementation this week.

## Context / Recap

Follow [TA_plan.md](../TA_plan.md), Session 9. Week 8 selected actions from a Q-table; now a neural actor produces actions directly. Actor–critic still learns values: the critic helps train the actor, rather than selecting an action through a table argmax. Week 7 used expert action labels; here reward feedback drives learning.

No professor lecture has been supplied for Week 9. Preparation references: [Spinning Up: policy optimization](https://spinningup.openai.com/en/latest/spinningup/rl_intro3.html), [A2C reference implementation](https://stable-baselines3.readthedocs.io/en/master/_modules/stable_baselines3/a2c/a2c.html), and [Gymnasium InvertedPendulum](https://gymnasium.farama.org/environments/mujoco/inverted_pendulum/). Our teaching implementation does not claim to reproduce a library benchmark.

## Core Explanation

### Task and policy

The standard `InvertedPendulum-v5` observation contains cart position, pole angle, cart velocity, and pole angular velocity. The actor chooses one continuous control command in [−3,3]. MuJoCo simulates the resulting motion.

Installed Gymnasium 1.3.0 gives reward 1 when the new state is healthy and 0 on failure. Failure is a nonfinite state or absolute pole angle **greater than** 0.2 rad; equality alone does not terminate. The wrapper truncates at 1,000 steps. We preserve this reward and environment.

A Q-table needs discretization to cover continuous states/actions and grows rapidly as resolution increases. Function approximation is another option for value-based RL; continuous control does not make all value-based methods impossible. This lesson focuses on a directly parameterized policy.

Actor and critic each have two 64-unit tanh hidden layers. The actor produces a Gaussian mean and learns a state-independent standard deviation. Training samples a latent action z and sends `3 tanh(z)` to the simulator. Evaluation uses `3 tanh(mean)`; this is a deterministic representative action, not generally the expectation of the transformed distribution. There is no epsilon-greedy switch.

### Critic and advantage

The critic outputs V(s), an estimate of expected discounted return. It is not an expert supplying correct actions. For one transition:

```text
r = 1, gamma = .99, V(s) = 5, V(s') = 6
target = 1 + .99 × 6 = 6.94
advantage estimate = target − 5 = 1.94
```

Positive advantage encourages the sampled action; negative advantage discourages it relative to current behavior. This is an estimate from limited experience, not a guarantee that any individual action is good or bad.

### From the calculation to A2C

Collect five transitions from each of eight independently seeded environments. Use discounted rewards plus the critic's value at the rollout end as the return target. When an episode ends inside a rollout, stop that return at the boundary.

- True failure: zero bootstrap.
- Time-limit truncation: bootstrap from the final pre-reset observation.
- Never use the reset state's value as the previous episode's continuation.
- `advantage = target − V(s)`.
- Actor loss: `−mean(log pi(a|s) × detached_advantage)`.
- Critic loss: `mean((V(s) − detached_target)²)`.
- Total loss: actor loss + 0.5 × critic loss; one optimizer step per fresh batch.

“Detached” means treat that quantity as a fixed number while calculating gradients. Actor gradients do not train the critic through the advantage; critic targets are fixed while fitting V. The actor density includes the tanh transformation and action-scale correction. Keep that numerical detail in preparation/code comments rather than spending class time deriving it.

Defaults: gamma .99, RMSprop learning rate .0007, gradient norm limit .5, no entropy bonus. Train for 250,000 environment transitions. These are finite-run teaching settings, not convergence guarantees. The learned Gaussian spread provides exploration.

### Expected observations and limitations

The included seed-7 checkpoint was selected at 100,000 transitions using 10 validation starts. On 20 separate test starts, it reaches the 1,000-step limit every time; its initial network averages 28.4 steps. Seed 1 also reaches the limit on every test start; seed 0 averages 220.2 steps despite the same training budget. Show all three results.

The training curve uses stochastic actions. Validation/test runs use deterministic actions, so their performance can differ. More training is not guaranteed to improve every checkpoint. Select checkpoints by validation results; reserve test seeds for final reporting.

PPO limits policy changes through a clipped optimization objective. SAC combines a stochastic actor with learned action values and an entropy objective, reusing experience from a replay buffer. Mention them as later practical methods; do not demonstrate either.

## Live Demo

Follow the [runbook](demo/README.md); use saved checkpoints, not a full live training run.

1. **3 min:** watch the initial policy; identify four observations, continuous action, and survival reward.
2. **5 min:** inspect actor/critic networks and one update. Match `target`, `advantage`, and both losses to the worked calculation.
3. **5 min:** switch to trained on the same test seed; pause and inspect pole angle, episode return, and current critic V.
4. **4 min:** compare training/validation curves and all three training seeds. Distinguish a prepared successful demo from a robustness claim.

Checkpoint answers: actor chooses actions; critic estimates return; reward comes from the environment; gradients update parameters; no expert label or Q-table is required. During evaluation there are no updates and no sampled exploration. A high critic value is an estimate, not an observed episode return.

## Timing

| Part | Minutes |
|---|---:|
| Recap: Q-tables versus neural policies | 5 |
| Continuous actions and policy-gradient intuition | 8 |
| Actor, critic, and advantage | 10 |
| Code walkthrough and MuJoCo comparison | 17 |
| Recap and PPO/SAC overview | 5 |
| **Total** | **45** |

## Common Questions / Problems

- **Does policy-based mean no values?** No; actor–critic uses values to guide policy learning.
- **Does the critic tell us the correct force?** No; it evaluates a state, not an expert action label.
- **Why no epsilon slider?** Gaussian action sampling supplies exploration.
- **Why can the trained model drift?** The task rewards balancing; it does not directly penalize cart displacement.
- **Why show a weaker training seed?** Randomness affects optimization and collected experience. One successful seed does not establish reliability.
- **Why does learning stop at an arbitrary time?** The finite budget is a practical limit. We choose among checkpoints using validation.
- **Viewer cannot open?** Use saved plots and console results; see rendering instructions in the runbook.

## Homework Connection

HW4 asks for MuJoCo continuous-control training and evaluation across seeds. This example establishes those habits without replacing the assignment's PPO/SAC requirements. HW5's actor–critic and policy-gradient theory connects to today's update intuition. Detailed derivations, extensive tuning, and advanced algorithms remain outside this session.

## Preparation Checklist

- [ ] Install the tested CPU dependencies in an isolated environment.
- [ ] Read the source references and confirm the reward/failure conventions.
- [ ] Calculate target 6.94 and advantage 1.94 by hand.
- [ ] Run tests and open the viewer with both supplied checkpoints.
- [ ] Rehearse pause, restart, policy selection, and next test episode.
- [ ] Review the three-seed results; explain validation selection and held-out testing.
- [ ] Keep comparison/training figures available for graphics fallback.
- [ ] Rehearse the 17-minute demo; avoid waiting for training in class.
