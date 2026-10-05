# Week 7 — MuJoCo and Imitation Learning

Two parts: **MuJoCo 7 minutes; imitation learning 15 minutes; demo 18 minutes; recap 5 minutes.** English, 16:9, light background, blue/teal accents, editable visuals and detailed speaker notes. 25 slides including two untimed dividers and four hidden backups. Teach behavior cloning as supervised action prediction with closed-loop distribution shift. No installation/API tutorial or regression derivation. Preserve demo files and teaching notes; no interfaces or dependencies change.

## Sequence and timing

| Slide | Topic | Minutes |
|---|---|---:|
| 1 | MuJoCo & imitation learning | 0 |
| 2 | Part 1 · MuJoCo | 0 |
| 3 | What is MuJoCo? | 1.5 |
| 4 | Why simulation for RL? | 2 |
| 5 | MuJoCo versus Gazebo | 2 |
| 6 | GPU compatibility: three different jobs | 1.5 |
| 7 | Part 2 · Imitation learning | 0 |
| 8 | From computing a policy to learning one | 1 |
| 9 | What is imitation learning? | 1 |
| 10 | The behavior-cloning workflow | 1.5 |
| 11 | Demonstrations are labeled data | 1.5 |
| 12 | Train it like supervised learning | 1 |
| 13 | When imitation drifts | 2 |
| 14 | DAgger: learn from learner-visited states | 1.5 |
| 15 | Other approaches: IRL and GAIL | 1 |
| 16 | Evaluate predictions and behavior | 1.5 |
| 17 | Our coming demo: reach the target | 1 |
| 18 | Our expert is a feedback controller | 1.5 |
| 19 | What should we expect? | 0.5 |
| 20 | Watch → collect → learn → compare | 18 |
| 21 | Questions, recap & HW4 | 5 |
| 22 | CPU and GPU: choose the workload (hidden) | 0 |
| 23 | Controller and learned weights (hidden) | 0 |
| 24 | Four approaches, different feedback (hidden) | 0 |
| 25 | Data and evaluation checklist (hidden) | 0 |

## Speaker guidance and visuals

### 1. MuJoCo & imitation learning

Simulate motion. Learn behavior from an expert. Timing: 0 minutes. Visual: title.

Week7 has two distinct subjects: seven minutes MuJoCo and fifteen minutes imitation learning, followed by eighteen minutes demo and five minutes recap. Students know Python and prior weeks; no least-squares derivation or simulator API tutorial is needed. Explain the practical labeled-data viewpoint with its closed-loop complications. All eleven original files were read, including the saved plot. Preserve every demo file and teaching notes. The professor PDF was not found; its printed-slide references are existing references, not independently reviewed material.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.
- Existing Class9-ImitationLearning.pdf printed-slide references: motivation/setup 3–6; behavior cloning 8–11; DAgger 13–15; existing plan further references 33. PDF not found locally and not reviewed.

### 2. Part 1 · MuJoCo

Why this simulator fits robot-learning experiments. Timing: 0 minutes. Visual: divider.

Untimed divider. Establish the distinction between the simulator, which computes motion, and the learning method, which changes a policy. Refer back to Gazebo in Week3; both are simulation tools. Focus on purpose, tradeoffs and the GPU distinction. Installation, model authoring and API calls stay outside this presentation.

- https://mujoco.readthedocs.io/en/stable/overview.html

### 3. What is MuJoCo?

A physics simulator for articulated bodies and control. Timing: 1.5 minutes. Visual: loop.

MuJoCo stands for Multi-Joint dynamics with Contact. Its model describes bodies, joints, geometry, actuators and physical properties; its simulation state evolves under forces and constraints. Show the repeating observation→controller→forces→physics→new-observation loop. Rendering lets us view the motion but is separate from the physics calculation. The controller may be scripted or learned; MuJoCo itself does not train our policy. Our task is a simple moving body, not an arm, although the simulator supports articulated systems and contacts.

MuJoCo computes motion. The controller chooses actions.

- https://mujoco.readthedocs.io/en/stable/overview.html
- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 4. Why simulation for RL?

Learning through interaction needs many trials. Timing: 2 minutes. Visual: four.

RL chooses actions, observes transitions and rewards, and improves a policy from experience. Repeated trials on hardware consume time, wear components and can be costly or risky. Simulation offers controlled initial conditions, inexpensive resets, repeatable comparisons and parallel rollouts. Headless operation avoids unnecessary rendering when observations are state vectors. MuJoCo is a useful option, not a requirement for all RL: other simulators and hardware interaction are valid. Simulation results depend on model quality, so success does not automatically transfer to hardware. This week uses expert labels rather than reward-based RL updates.

- Repeat: Run many experiments.
- Reset: Try new initial conditions.
- Compare: Share scenarios and seeds.
- Scale: Collect trials in parallel.

Explore in simulation before committing to hardware.

- https://mujoco.readthedocs.io/en/stable/overview.html
- https://mujoco.readthedocs.io/en/stable/mjx.html

### 5. MuJoCo versus Gazebo

Choose the tool around the experiment. Timing: 2 minutes. Visual: comparison.

Explain this as a course-oriented comparison, not a universal speed or fidelity ranking. MuJoCo strengths here are direct programmatic control, compact experiments and high-throughput learning backends. The tradeoff is that a ROS-integrated robot system and full sensor/application workflow need additional integration. Gazebo strengths are its ROS ecosystem, sensor/noise models and modular worlds/systems; that broader system setup can be more than this small state-based experiment needs. Gazebo can run headless and support learning, while MuJoCo has rendering and sensors too. Neither is restricted to its preferred course role; speed and physical fidelity depend on model, physics configuration and workload.

- MuJoCo: Focused control experiments; direct state/action access; learning backends.
- Gazebo: ROS integration; robot systems, worlds, sensors and plugins.

Both can support learning. Their workflows emphasize different needs.

- https://mujoco.readthedocs.io/en/stable/overview.html
- https://gazebosim.org/docs/harmonic/architecture/
- https://gazebosim.org/libs/sensors/

### 6. GPU compatibility: three different jobs

Drawing, learning, and physics are separate workloads. Timing: 1.5 minutes. Visual: gpu.

Separate GPU rendering of images, GPU computation for training a policy, and GPU physics advancing simulated states. Standard MuJoCo C-engine physics uses CPU execution; its viewer uses OpenGL rendering. MJX provides accelerator-oriented simulation, with JAX and Warp implementations; MuJoCo Warp targets NVIDIA GPUs. Explain batches as many environment instances producing experience together. GPU speedups depend on batch size, workload, transfer/compilation overhead, hardware and backend feature support; one tiny environment need not be faster. CPU models do not become GPU simulations automatically. This repository uses ordinary mujoco stepping and NumPy least squares, without MJX, Warp, JAX or GPU learning. Keep backend APIs and configuration out of slides.

This demo: CPU physics + NumPy fitting. No GPU training.

- https://mujoco.readthedocs.io/en/stable/overview.html
- https://mujoco.readthedocs.io/en/stable/mjx.html
- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 7. Part 2 · Imitation learning

Learn an observation-to-action policy from demonstrations. Timing: 0 minutes. Visual: divider.

Untimed divider. We now move from the simulation tool to the learning method. The simulator provides dynamics; expert demonstrations provide labels; behavior cloning provides the fitted policy. Keep those responsibilities separate. The key comparison is supervised learning versus deployment in a feedback loop, not MuJoCo versus a machine-learning algorithm.

- https://arxiv.org/abs/1011.0686
- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 8. From computing a policy to learning one

Keep the policy idea; change where it comes from. Timing: 1 minutes. Visual: two.

Week6 optimized expected return using known transition probabilities and rewards. This week fits behavior from expert observations/actions instead of solving Bellman equations. The input is an observation in our continuous reaching task, not a symbolic four-state identifier. We use imitation learning rather than reward-based RL. A fitted policy can be a small regression model, not necessarily a neural network. At deployment it chooses a new action for the current observation, just as the policy concept predicts.

- Week 6: Given a model, compute a policy using Bellman equations.
- Week 7: Given expert examples, fit an observation-to-action policy.

A policy still answers: what action should I take now?

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.
- Existing Class9-ImitationLearning.pdf printed-slide references: motivation/setup 3–6; behavior cloning 8–11; DAgger 13–15; existing plan further references 33. PDF not found locally and not reviewed.

### 9. What is imitation learning?

Use expert behavior to learn how to act. Timing: 1 minutes. Visual: experts.

An expert can be a human demonstrator, a scripted controller, an expensive planner or another trained policy. The demonstrations show behavior that the learner should reproduce or achieve. Behavior cloning is the supervised-learning approach used here. Imitation learning is broader: DAgger changes data collection, IRL seeks a reward explanation, and GAIL matches visitation behavior. Demonstrations alone do not mean copying fixed trajectories; our policy reacts to its current input. An expert is a source of guidance, not proof of globally optimal or safe behavior.

This week: behavior cloning from observation/action labels.

- https://arxiv.org/abs/1011.0686
- https://arxiv.org/abs/1606.03476
- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 10. The behavior-cloning workflow

Separate expert collection from independent execution. Timing: 1.5 minutes. Visual: workflow.

First run the expert and record aligned pairs of current observation and expert action. Fit a model on those pairs and check it on held-out episodes. Deploy the learned policy independently, then test complete rollouts on fresh cases. Distinguish collection from execution visually: expert→data→training is a one-time pipeline; learner↔simulator is a closed loop. The expert is present for collection and expert comparison, but not called by the learner during its own rollout. No action tape is replayed. Behavior-cloning fitting compares predicted actions with labels, not rewards.

During deployment: current observation → learned action → new observation.

- https://arxiv.org/abs/1011.0686
- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 11. Demonstrations are labeled data

Inputs: what the expert sees. Labels: what it does. Timing: 1.5 minutes. Visual: dataset.

Observation field order is [error_x,error_y,velocity_x,velocity_y], in metres and metres/second; labels are [force_x,force_y] in newtons. Show the illustrative row [0.3,−0.2,0.1,0]→[0.9,−0.8]. It matches the expert rule but is not claimed to be the first row of the collected file. Record observation before applying its action; the next observation must not be mislabeled with that preceding action. Each five-second episode contributes250 decisions at50Hz, giving25000 rows. Time-adjacent rows are correlated and do not represent25000 independent episodes.

100 episodes × 250 decisions = 25,000 labeled pairs.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 12. Train it like supervised learning

Predict expert actions and reduce label error. Timing: 1 minutes. Visual: train.

The practical explanation is labeled input/output data as in supervised learning. Choose a model, compare its predicted action with the expert label, and fit parameters to reduce action error. This demo uses affine regression with NumPy least squares and mean squared action error. There is no need for a neural network, iterative SGD or a regression derivation here. More complex observations/experts often call for richer models. Training reads stored observations/actions, not the expert gains; the recovered coefficients are estimates from labels. Deployment clips predicted forces to the same limits. The supervised training problem is ordinary regression; the complication arises in how its predictions influence future inputs.

No reward optimization in behavior-cloning training.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.
- https://arxiv.org/abs/1011.0686

### 13. When imitation drifts

Our actions change the next inputs we will see. Timing: 2 minutes. Visual: drift.

Compared with a common supervised setup, where test examples are supplied externally from a similar distribution, robot actions influence the next observation. A small erroneous action can take the robot away from expert-visited states; later predictions then face unfamiliar inputs and can compound errors. Ordinary machine learning can have distribution shift too: the special issue is policy-induced state distribution in closed-loop control. Use a conceptual path sketch labeled illustration, not a demo result. The real linear reaching demo imitates well; do not suggest drift was observed here or that every imitation policy necessarily fails. Explain why rollout evaluation is needed in addition to held-out label accuracy.

Low action error on expert data does not guarantee successful control.

- https://arxiv.org/abs/1011.0686
- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 14. DAgger: learn from learner-visited states

Ask the expert about the states your learner actually reaches. Timing: 1.5 minutes. Visual: dagger.

DAgger means Dataset Aggregation. Start with expert data and an initial learner. Collect states while executing the learner or a scheduled mixture with expert behavior; ask the expert what action it would take at those states. Aggregate these labeled states with previous demonstrations, retrain, and repeat. Feedback targets the learner-induced distribution rather than only the original expert trajectories. Expert queries are needed during additional collection, not necessarily during final deployment. This requires an available labeling expert and does not guarantee universal robustness or safety. DAgger is explained conceptually and is not implemented by the Week7 demo.

Aggregate the new labels with earlier data, then retrain.

- https://arxiv.org/abs/1011.0686

### 15. Other approaches: IRL and GAIL

 Timing: 1 minutes. Visual: two.

Keep this to one minute with no formulas, code or algorithm walkthrough. Expand IRL as Inverse Reinforcement Learning: infer a reward/cost under which demonstrated behavior makes sense, then obtain a policy using planning or RL. Demonstrations generally do not uniquely determine the reward; several rewards can explain the same behavior. GAIL is Generative Adversarial Imitation Learning: a discriminator distinguishes expert from learner state/action samples, and its feedback guides policy learning toward matching visitation distributions. It normally requires learner-environment interaction; it is not just per-row action regression. GAIL does not aim to recover a unique interpretable task reward. These descriptions provide orientation only. This slide must be immediately after DAgger.

- IRL: Infer a reward that explains expert behavior; use it to learn or plan a policy.
- GAIL: Train a policy to match expert state/action visitation using discriminator feedback.

Different approaches; our demo uses behavior cloning.

- https://ai.stanford.edu/~ang/papers/icml00-irl.pdf
- https://arxiv.org/abs/1606.03476

### 16. Evaluate predictions and behavior

Two different questions need two different measurements. Timing: 1.5 minutes. Visual: two.

Train on episodes0–79 and validate on80–99, rather than randomly mixing adjacent frames from the same episode. This avoids a misleadingly easy correlated split. Evaluate expert, learner and zero-force baseline on the same20 fresh seed42 scenarios. Action MSE is measured on held-out expert inputs; rollout success uses observations generated by the deployed controller. Different controllers see their own evolving observations even though initial conditions match. Success requires distance<0.03m and speed<0.05m/s at all26 control samples from4.50 through5.00seconds. These sampled simulation metrics are not physical continuous-time guarantees.

- Held-out action error: Do predictions match
expert labels?
- Closed-loop success: Does the learner complete the task on fresh episodes?

Split by whole trajectories. Compare on shared unseen cases.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.
- https://arxiv.org/abs/1011.0686

### 17. Our coming demo: reach the target

A two-axis moving body, not an arm or grasping task. Timing: 1 minutes. Visual: task.

Editable top-view sketch: teal cylinder is the1kg body with perpendicular x/y slide joints, orange target is a marker. The body stays at fixed height; gravity is disabled and it does not contact the floor. Inputs contain position error and velocity, not camera images. Outputs are forces, not position targets. Physics runs at100Hz and the controller recomputes at50Hz, holding each command over two physics steps. Episodes last5seconds. Mention those numbers only as needed in notes; the purpose is to understand dynamics versus action selection, not simulator configuration.

Observe error + velocity. Command x/y forces.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 18. Our expert is a feedback controller

A transparent teacher for an intentionally simple task. Timing: 1.5 minutes. Visual: two.

The controller is force=4×position_error−3×velocity, clipped independently to±10N. Position feedback accelerates toward the target, while velocity feedback opposes motion and helps settle. Velocity is essential because two states with equal error but different velocity need different braking. The expert exists in Python, not inside the MuJoCo physics engine. We already know this controller so we can make the imitation pipeline transparent; in other tasks experts may be humans or costly planners. Do not derive PD control or stability. The learner receives only the recorded pairs and independently estimates coefficients.

- Position feedback: Pull toward the target.
- Velocity feedback: Brake the motion to settle.

The learner sees examples; it is not given the controller gains.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 19. What should we expect?

Expert and learner trajectories nearly overlap. Timing: 0.5 minutes. Visual: results.

Use the preserved comparison.png as a saved result, not a new run. The affine learner represents the expert over the sampled range, so near-zero validation action error and overlapping rollouts are expected. Existing documentation reports expert20/20, learner20/20, zero0/20; tests require learner≥19/20. Numeric residuals vary by library. Strong performance in this easy task is not a claim of robustness to unfamiliar dynamics or hard tasks. The zero-force baseline may move because initial velocity is nonzero. Do not deliberately degrade training to manufacture drift.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 20. Watch → collect → learn → compare

First meet the expert, then let the learner act independently. Timing: 18 minutes. Visual: demo.

Eighteen-minute demo using the existing runbook. Four minutes: watch expert, identify body/target and force commands. Four: collect100episodes and inspect25000 pairs and one aligned row. Three: train, show held-out MSE and fitted W/b; ask where coefficients came from. Five: watch learner from the same test start and evaluate20 shared episodes against expert/zero. Two: distinguish label agreement from task success. Setup and installation are preparation, not lecture material. Viewer failure is documented on an earlier development desktop; rehearse on a working classroom OpenGL desktop and keep comparison.png as fallback. No new UI or dependency changes.

4 min expert · 4 collect · 3 train · 5 compare · 2 metrics

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 21. Questions, recap & HW4

Who provides dynamics, labels, and actions? Timing: 5 minutes. Visual: recap.

Reserve five minutes. Dynamics come from MuJoCo; labels come from the expert controller; the deployed learner computes actions. Behavior cloning trains from action labels, whereas RL generally optimizes rewards through interaction. Why can action MSE mislead? The learner changes the state distribution during rollout. What does DAgger add? Expert labels at learner-visited states. IRL infers reward explanations; GAIL matches state/action visitation via discriminator feedback. Check velocity/braking and independent learner execution. HW4 uses a separate continuous-control MuJoCo environment; PPO/SAC are later topics. Do not invent extra homework requirements.

MuJoCo simulates. Expert labels. Learner acts.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.
- https://arxiv.org/abs/1011.0686
- https://arxiv.org/abs/1606.03476

### 22. CPU and GPU: choose the workload

Optional details, without setup instructions. Timing: 0 minutes. Visual: backend.

Standard C-engine stepping uses CPU physics and can exploit CPU parallelism for appropriate workloads. Accelerator backends include MJX/JAX and NVIDIA Warp-based implementations, intended for high-throughput parallel environments. Hardware, model feature support, batch size, compile costs, rendering needs and data transfer affect performance. A GPU network training loop combined with CPU physics remains a mixed pipeline. Gazebo uses GPU acceleration for rendering and sensors such as GPU lidar; that alone does not imply batched GPU physics. Do not promise that any backend accepts every model or always runs faster. Check exact-version documentation before an implementation; the demo pins mujoco3.14.0 and uses neither MJX nor Warp.

Rendering ≠ policy training ≠ physics stepping.

- https://mujoco.readthedocs.io/en/stable/overview.html
- https://mujoco.readthedocs.io/en/stable/mjx.html
- https://gazebosim.org/libs/sensors/

### 23. Controller and learned weights

Supplemental detail for the demo, not a regression derivation. Timing: 0 minutes. Visual: weights.

Expert force is clip(4e−3v,−10,10), applied separately for each axis. Illustrative observation [0.3,−0.2,0.1,0] yields [.9,−.8]N. Expected fitted weights W=[[4,0,−3,0],[0,4,0,−3]], bias≈[0,0]. Weight dimensions are2×4 and bias length2. The learner clips predictions to actuator limits. Least squares solves the affine prediction problem over recorded observations/actions. There is no need to derive normal equations; source uses numpy.linalg.lstsq and checks design rank5. Saturation makes the global expert clipped rather than globally affine, but over this sampled operating range the affine learner matches it closely.

Coefficients are estimated from labels, not copied into the learner.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

### 24. Four approaches, different feedback

Optional comparison of the learning signal. Timing: 0 minutes. Visual: approaches.

Behavior cloning: stored observation/action labels. DAgger: repeated collection and expert labeling at learner-visited states, aggregated with previous data. IRL: infer reward/cost explanations and use a planning/RL stage; rewards are not uniquely identifiable from behavior alone. GAIL: adversarial feedback from expert-versus-learner state/action samples, guiding interaction-based policy training to match visitation. DAgger and GAIL both commonly need further environment interaction, but their supervision sources differ. None of these broader methods is executed in the current demo. Keep this comparison conceptual and avoid mathematical objectives or implementation instructions.

- https://arxiv.org/abs/1011.0686
- https://ai.stanford.edu/~ang/papers/icml00-irl.pdf
- https://arxiv.org/abs/1606.03476

### 25. Data and evaluation checklist

Avoid mistaking prediction accuracy for control performance. Timing: 0 minutes. Visual: evaluation.

Collection: seed7,100episodes,250 decisions each. Inputs25000×4, labels25000×2; label the pre-action observation with the applied clipped force. Training20000 rows from80 episodes; validation5000 rows from20. Fresh evaluation seed42 uses20 scenarios shared across expert, learner and zero. Success uses all26 control samples from4.50 to5.00seconds, requiring distance<.03m and speed<.05m/s. Predictions on held-out expert trajectories and performance on learner-generated trajectories answer different questions. GUI tests on a historical desktop had graphics limitations; runtime tests and classroom viewer rehearsal must be reported separately from slide arithmetic/source inspection.

Simulation success is sampled, task-specific, and model-dependent.

- Local: demo/task.py, expert.py, learning.py, demo.py, robot.xml, test_demo.py, README.md and comparison.png.

## Validation and preparation

All eleven original Week7 files reviewed, including comparison.png. Professor Class9-ImitationLearning.pdf not found; printed-slide references are retained without claiming review. Generate/render/reopen25 slides in installed PowerPoint; verify four hidden backups, notes, sources,25 PDF pages and22+18+5 timing. IRL/GAIL must immediately follow DAgger. Check observation/action order, controller example,100×250 rows,80/20 episode split,20 fresh shared cases and sampled distance/speed success. SHA256 protected hashes must match. Python unavailable locally; original tests and headless pipeline are unexecuted here. Historical runbook outcomes and GUI limitations are not new execution results. Classroom viewer rehearsal remains separate. See slides/README.md and validation.json/review.json.