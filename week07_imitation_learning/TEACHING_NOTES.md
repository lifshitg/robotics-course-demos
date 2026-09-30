# Week 7 — Imitation Learning in MuJoCo

## Goal

- Trace expert → demonstrations → supervised training → learned policy.
- Identify continuous observations and actions in a running MuJoCo task.
- Explain why action prediction accuracy and closed-loop success are different measurements.
- Watch the expert and learner on the same unseen initial conditions.

## Context / Recap

Week 6 computed policies from a known MDP. This week we learn an observation-to-action mapping from expert examples. MuJoCo supplies dynamics, the expert supplies labels, and behavior cloning fits the policy.

Follow [TA_plan.md](../TA_plan.md), Session 7. Source: professor's `Class9-ImitationLearning.pdf`, originally `/home/gilad/Downloads/Class9-ImitationLearning.pdf`. Use printed slide numbers: motivation/setup 3–6, behavior cloning 8–11, DAgger 13–15. The PDF is referenced, not copied; classroom prompts are source material.

MuJoCo is a physics simulator with models, state, actuators, and a viewer. In our loop Python observes the simulated state, chooses forces, writes actuator commands, and advances physics. Students saw a similar command-to-simulation relationship in Gazebo; no ROS bridge is needed here.

## Core Explanation

### The task and the expert

A 1 kg body has two perpendicular slide joints; it moves in x/y at fixed height. Gravity is disabled and the robot does not contact the ground. The orange marker is a target. This is a simple reaching system, not an arm or grasping task.

- Observation: `[target_x − x, target_y − y, velocity_x, velocity_y]`.
- Action: two forces in newtons, each clipped to ±10.
- Expert: `force = 4 × position_error − 3 × velocity`.
- The position term pulls toward the target; the velocity term brakes motion.
- Physics advances every 0.01 s; actions are recomputed every 0.02 s and held for two physics steps.
- Episodes last 5 s. At control samples throughout the final 0.5 s, distance must remain below 0.03 m and speed below 0.05 m/s.

Ask: “Who is the expert?” **Our scripted feedback controller.** An expert need not be human or a pretrained neural network. We already know a controller for this intentionally easy task; the point is to reveal the imitation pipeline.

### Dataset and supervised learning

Collect 100 expert episodes with seed 7. Each contributes 250 observation/action pairs, recorded before each action: 25,000 rows. Initial and target xy coordinates are independently drawn from [−0.6,0.6] m with distance at least 0.2 m; initial velocities from [−0.2,0.2] m/s.

An illustrative row: observation `[0.3, −0.2, 0.1, 0]` → expert force `[0.9, −0.8]` N. Check the arithmetic together.

Fit `a_hat = W o + b` by least squares, minimizing mean squared action error. Training receives only observations and recorded actions, not the expert gains. Clip predicted forces to the same actuator limits. There is no reward optimization in this training step.

Use complete episodes 0–79 for training and 80–99 for validation. Randomly mixing adjacent frames would make the split less informative because neighboring observations are strongly correlated. Evaluate task success on 20 fresh episodes using seed 42.

### What students should observe

The expert mapping is linear over the sampled range, and our affine policy can represent it. Expect near-zero validation MSE and almost overlapping expert/learner trajectories. The recovered weights are approximately:

```text
W = [[4, 0, -3, 0],
     [0, 4, 0, -3]],  b = [0, 0]
```

These are learned from labels, not assigned. At every rollout step, the learner recomputes actions from its own current observation. It neither replays a trajectory nor calls the expert. A zero-force baseline makes the comparison interpretable; its initial velocity can still cause drift.

### Limits and lecture connections

- Low held-out action error does not guarantee success after the learner changes which states it visits.
- Small action errors can take the learner outside the expert-data distribution and compound (slide 10). This well-specified linear example is not designed to fail.
- DAgger collects learner-visited states, asks the expert for actions there, aggregates labels, and retrains (13–15). Explain only; do not implement it this week.
- IRL infers rewards explaining demonstrations; GAIL seeks matching state/action distributions using a discriminator. Name them as alternatives without deriving them.
- Strong results here do not establish robustness to changed dynamics or difficult tasks.

## Live Demo

Follow the [runbook](demo/README.md). Prepare dependencies and artifacts beforehand.

1. **4 min:** watch expert; identify robot, target, camera, pause, and reset. Explain force versus position commands.
2. **4 min:** collect demonstrations; inspect the 25,000-row dataset and one observation/action pair.
3. **3 min:** train; show validation MSE and fitted W/b. Ask where those coefficients came from.
4. **5 min:** watch learner on the same episode; evaluate all 20 cases and compare expert/learner/zero plots.
5. **2 min:** ask whether low MSE alone proves successful control; show the separate rollout metrics.

Expected measured result: expert 20/20, learner 20/20, zero 0/20; mean expert/learner final distance about 0.000425 m. Use the saved figure if the viewer cannot open. The current development desktop has a graphics-backend limitation; rehearse GUI operation on the classroom machine.

## Timing

| Part | Minutes |
|---|---:|
| Recap: policies and learning from demonstrations | 5 |
| MuJoCo introduction and continuous observations/actions | 7 |
| Behavior cloning: expert data and supervised learning | 10 |
| Watch expert, collect, train, and compare | 18 |
| Distribution shift, DAgger intuition, and recap | 5 |
| **Total** | **45** |

## Common Questions / Problems

- **Is the expert inside MuJoCo?** No. Python computes expert forces; MuJoCo computes resulting motion.
- **Why learn if we have a controller?** This transparent example teaches the method; real experts may be humans or expensive planners.
- **Is this copying the gains?** No. The learner estimates coefficients from observed inputs/labels.
- **Does BC require a neural network?** No. Supervised regression is enough for this mapping.
- **Are we training with rewards?** No; the loss compares predicted actions with expert labels.
- **Why include velocity?** The expert's braking action depends on velocity, so position error alone is insufficient.
- **Why does the baseline move?** Initial velocity may be nonzero even with zero force.
- **Will DAgger always fix failures?** It improves data coverage through expert feedback; do not promise universal success.
- **Missing policy file:** run collect and train, or the all command.

## Homework Connection

HW4 uses continuous control in MuJoCo. This session prepares model/state/action understanding, rollout evaluation, and reproducible comparisons. This custom task is not the HW4 environment; PPO/SAC and reward-based training come later. There is no extra Week 7 homework requirement in the course plan.

## Preparation Checklist

- [ ] Review professor slides 3–6, 8–11, 13–15.
- [ ] Install the pinned MuJoCo dependency in an isolated environment.
- [ ] Rehearse expert playback and camera controls on the classroom desktop.
- [ ] Run all; verify 100 episodes, 80/20 split, and 20 fresh evaluation cases.
- [ ] Confirm the learner reaches at least 19/20 targets and never queries the expert.
- [ ] Test pause/resume, restart, next episode, and close; note GUI limitations.
- [ ] Keep saved comparison figure and expected console output ready.
- [ ] Rehearse the 18-minute demonstration and final distribution-shift explanation.

Implementation reference: [official MuJoCo Python bindings and viewer](https://mujoco.readthedocs.io/en/latest/python.html).
