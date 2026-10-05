# Week 9 validation — 5 October 2026

Created the editable English PowerPoint, all-slide PDF, revised presentation plan, reproducible sources, 30 individual previews, and five contact sheets. Confirmed 30 minutes teaching/worked mathematics, 10 minutes visual demo, and 5 minutes recap.

## Executed checks

- Generated every slide in installed Microsoft PowerPoint, exported slide previews and the PDF, saved and reopened the presentation.
- Verified 30 slides and notes pages, five hidden backups (26–30), 30 PDF pages, ordered titles, note timing annotations, and source URLs against the reproducible content.
- Inspected all five contact sheets covering every slide. Corrected a narrow card label and wrapped footer; confirmed Greek formula subscripts render as subscripts. Final PowerPoint text-bound checks report no overflow.
- Teaching slide 4 (physical slide 5) contains the distribution diagram, mean, spread and sampled action, without a specific bounding function. The transformation formula is confined to implementation notes and hidden backup 4.
- Passed 35 independent PowerShell content checks, including table growth, target 6.94, advantage 1.94, critic error 3.7636, baseline cancellation in a discrete numerical example, Gaussian mean-gradient example, multi-step targets, termination/truncation examples, rollout count, and positive/negative PPO clipping cases. Historical metrics were checked against the saved results JSON.
- Verified two source excerpts after whitespace normalization and 20 source patterns for network/algorithm defaults, losses, detached values, transformed action likelihood, optimizer settings and evaluation actions. Checked final-observation value computation before reset and evaluation's separate environment/deterministic inference. These are source checks, not execution of Python or PyTorch.
- Compared protected SHA-256 hashes after generation and during review. All demo files, checkpoints, README, and teaching notes are unchanged. Repository status shows only the Week 9 presentation plan and new presentation deliverables changed.

## Mathematics and source review

Reviewed the existing plan, teaching notes, demo runbook, all Python sources/tests, dependency pins, ignore rules, saved settings/results and both plots. Binary checkpoints were preserved; they were not loaded or executed locally.

Checked mathematical explanations against the policy-gradient derivation, original actor–critic/PPO/SAC papers, modern SAC technical guide, official environment documentation and time-limit guidance linked in notes. The discounted trajectory derivation retains the outer gamma-to-time weighting; notes explicitly distinguish the uniform rollout surrogate used by the code. Baseline cancellation is separated from bootstrap bias. PPO clipping is not described as a hard policy-change constraint. SAC is an overview of the modern twin-Q variant; the demo remains A2C. No professor presentation was supplied.

## Limitations

`py --list` reports no installed Python. The existing Python unit tests, checkpoint evaluation, and training were **not run locally**. Gradient isolation, transformed-density runtime checks, and classroom performance tests remain unexecuted here. Existing source tests and recorded results document earlier verification; this report does not claim it repeated those runs.

The saved three-seed comparisons and images are historical evidence, labeled accordingly. PowerPoint rendering and content/source checks are separate from MuJoCo classroom viewer rehearsal. No demo behavior, dependencies or interfaces were changed.

Machine-readable evidence: `validation.json`, `review.json`, and `protected_files.json`. Reproduction commands are in `README.md`.
