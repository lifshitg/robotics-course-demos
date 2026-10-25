# Robotics & Autonomous Systems — TA Materials

Private TA preparation materials for 13 weekly sessions, each 45 minutes long.
The [TA course plan](TA_plan.md) covers the syllabus, assignments, and grading strategy.

## Getting started

Choose a week below. Open the PDF to review the slides, or download the PowerPoint
to present or edit them. Read the teaching notes for timing and preparation, and
follow the demo instructions for setup, commands, and rehearsal checks.

All material links below are relative to this repository and work on GitHub and
in a local checkout. Access on GitHub requires permission to view the repository
if it is private. PowerPoint files may need to be downloaded to open.

## Prepared sessions

| Week | Topic | Slides | Preparation | Demo / board work |
| --- | --- | --- | --- | --- |
| 1 | ROS 2 | [PDF](week01_ros/ROS_BASICS_FINAL.pdf) · [PowerPoint](week01_ros/ROS_BASICS_FINAL.pptx) | [Notes](week01_ros/TEACHING_NOTES.md) · [Final deck guide](week01_ros/slides/README.md) · [Original plan](week01_ros/PRESENTATION_PLAN.md) | [Publisher/subscriber](week01_ros/demo/README.md) |
| 2 | Coordinate transforms and tf2 | [PDF](week02_tf/TF_COORDINATE_TRANSFORMS_UPDATED.pdf) · [PowerPoint](week02_tf/TF_COORDINATE_TRANSFORMS_UPDATED.pptx) | [Notes](week02_tf/TEACHING_NOTES.md) · [Updated deck guide](week02_tf/slides/README.md) · [Original plan](week02_tf/PRESENTATION_PLAN.md) | [Python/RViz](week02_tf/demo/README.md) |
| 3 | Gazebo and robot kinematics | [PDF](week03_kinematics/GAZEBO_AND_KINEMATICS.pdf) · [PowerPoint](week03_kinematics/GAZEBO_AND_KINEMATICS.pptx) | [Notes](week03_kinematics/TEACHING_NOTES.md) · [Plan](week03_kinematics/PRESENTATION_PLAN.md) | [Two-joint arm](week03_kinematics/demo/README.md) |
| 4 | Configuration space and PRM | [PDF](week04_motion_planning/CONFIGURATION_SPACE_AND_PRM.pdf) · [PowerPoint](week04_motion_planning/CONFIGURATION_SPACE_AND_PRM.pptx) | [Notes](week04_motion_planning/TEACHING_NOTES.md) · [Plan](week04_motion_planning/PRESENTATION_PLAN.md) | [Interactive planning](week04_motion_planning/demo/README.md) |
| 5 | Classical planning and task-and-motion planning | [PDF](week05_task_motion_planning/CLASSICAL_PLANNING_AND_TAMP.pdf) · [PowerPoint](week05_task_motion_planning/CLASSICAL_PLANNING_AND_TAMP.pptx) | [Notes](week05_task_motion_planning/TEACHING_NOTES.md) · [Plan](week05_task_motion_planning/PRESENTATION_PLAN.md) | [Delivery planning](week05_task_motion_planning/demo/README.md) |
| 6 | MDPs: from actions to policies | [PDF](week06_mdps/MARKOV_DECISION_PROCESSES.pdf) · [PowerPoint](week06_mdps/MARKOV_DECISION_PROCESSES.pptx) | [Notes](week06_mdps/TEACHING_NOTES.md) · [Plan](week06_mdps/PRESENTATION_PLAN.md) | [Bellman backups](week06_mdps/demo/README.md) |
| 7 | Imitation learning in MuJoCo | [PDF](week07_imitation_learning/MUJOCO_AND_IMITATION_LEARNING.pdf) · [PowerPoint](week07_imitation_learning/MUJOCO_AND_IMITATION_LEARNING.pptx) | [Notes](week07_imitation_learning/TEACHING_NOTES.md) · [Plan](week07_imitation_learning/PRESENTATION_PLAN.md) | [Expert-to-learner](week07_imitation_learning/demo/README.md) |
| 8 | Q-learning | [PDF](week08_q_learning/Q_LEARNING.pdf) · [PowerPoint](week08_q_learning/Q_LEARNING.pptx) | [Notes](week08_q_learning/TEACHING_NOTES.md) · [Plan](week08_q_learning/PRESENTATION_PLAN.md) | [Interactive Gridworld](week08_q_learning/demo/README.md) |
| 9 | Policy gradients and actor–critic | [PDF](week09_actor_critic/POLICY_GRADIENTS_AND_ACTOR_CRITIC.pdf) · [PowerPoint](week09_actor_critic/POLICY_GRADIENTS_AND_ACTOR_CRITIC.pptx) | [Notes](week09_actor_critic/TEACHING_NOTES.md) · [Plan](week09_actor_critic/PRESENTATION_PLAN.md) | [MuJoCo actor–critic](week09_actor_critic/demo/README.md) |
| 10 | POMDP foundations and belief updates | [PDF](week10_pomdp/POMDP_FOUNDATIONS_AND_BELIEF_UPDATES.pdf) · [PowerPoint](week10_pomdp/POMDP_FOUNDATIONS_AND_BELIEF_UPDATES.pptx) | [Notes](week10_pomdp/TEACHING_NOTES.md) · [Plan](week10_pomdp/PRESENTATION_PLAN.md) | [Board-work guide](week10_pomdp/demo/README.md) |
| 12 | Particle filters and SLAM | [PDF](week12_filters_slam/SLAM_AND_BAYESIAN_ESTIMATION.pdf) · [PowerPoint](week12_filters_slam/SLAM_AND_BAYESIAN_ESTIMATION.pptx) | [Notes](week12_filters_slam/TEACHING_NOTES.md) · [Plan](week12_filters_slam/PRESENTATION_PLAN.md) | [Localization and SLAM visualization](week12_filters_slam/demo/README.md) |

Week 1 links use the final deck: 15 main slides and five hidden PowerPoint backups.
Its reference PDF includes all 20 slides. The original `ROS_BASICS` and
`ROS_BASICS_UPDATED` files are also retained.
Week 2 links use the updated deck: 18 visible slides, no hidden slides, and a
matching 18-page PDF. The original presentation files are retained. See the
[transform mathematics reference](week02_tf/TF_MATH_REFERENCE.md) for additional detail.

## Planned sessions

- [Week 11 — POMDP homework walkthrough](week11_pomdp/README.md): pending the homework; currently a provisional session plan.
- [Week 13 — Foundation models and perception](week13_foundation_models/README.md): conditional on semester progress; may instead cover unfinished material or exam preparation.

## Running and maintaining the materials

Run demo commands from the repository root unless the week's README says otherwise.
Each demo has its own dependencies and setup instructions. Weeks 1–3 use ROS 2
and related robotics tools; later demos use the Python environments documented
in their individual READMEs. Week 10 provides board work rather than an executable demo.

Each prepared week includes `TEACHING_NOTES.md`, `PRESENTATION_PLAN.md`, and a
`demo/` directory. Where a `slides/README.md` is present, it documents rebuilding
and reviewing the deck. The PowerShell build scripts require Windows with installed
PowerPoint; Week 1's final deck also has a Python builder with LibreOffice PDF export.
Consult the week's rehearsal checklist before teaching.
