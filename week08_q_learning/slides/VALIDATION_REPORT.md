# Week 8 validation — 5 October 2026

Created the editable English PowerPoint, all-slide PDF, revised plan, reproducible PowerShell sources, and 28 individual previews. The presentation uses 30 minutes explanation, 10 minutes demo, and 5 minutes recap. The requested table summed to 30.5 minutes; the algorithm recap is one minute rather than 1.5 to meet the selected schedule.

## Executed checks

- Generated and rendered every slide with installed Microsoft PowerPoint, saved the deck, reopened it, and checked notes and hidden-slide states.
- Verified 28 slides, 28 notes pages, five hidden backups (24–28), and 28 PDF pages. Checked ordered titles, timing annotations, and reference URLs in notes against the reproducible content source.
- Reviewed all five contact sheets covering every slide; corrected a footer wrap and maze-label overlap. Final PowerPoint text-bound checks report no overflow.
- Passed 15 independent PowerShell arithmetic checks: nonterminal target 2.8 and new Q 0.56; terminal target 10 and new Q 2; initial ordinary update −0.2; SARSA comparison; epsilon probabilities and ties; eight-move raw return 3 and discounted return 0.9501188828124985.
- Verified three displayed code excerpts against actual source after whitespace normalization, plus 15 source-pattern checks for defaults, maze, rewards, random training ties, evaluation tie order, slider/reset handling, and truncation. Reviewed update-before-reset ordering and evaluation's lack of Q writes or RNG calls. These are source checks, not execution of the learner.
- Rechecked SHA-256 hashes against the recorded baseline for every demo file, including `.gitignore`, and `TEACHING_NOTES.md`. All are unchanged. Repository status shows only the presentation plan and new deliverables changed.

## Source review and limitations

Reviewed the ten original Week 8 teaching/demo files and demo `.gitignore`. Notes reference Watkins–Dayan, Berkeley's RL material, the official Gymnasium time-limit explanation, and the original Double Q-learning paper. The existing Sutton–Barto reference is retained; its unavailable PDF was not reviewed. No Week 8 professor deck was supplied.

`py --list` reports no installed Python. The Python unit suite and headless training pipeline were **not run**. Existing saved demo figures and documented seed-7 results are historical evidence, clearly labeled as such; no new training result is claimed. Evaluation isolation and truncation behavior were checked against source, not runtime. Classroom GUI rehearsal is separate from presentation rendering.

Machine-readable evidence: `validation.json`, `review.json`, and `protected_files.json`. Reproduction and optional Python commands are in `README.md`.
