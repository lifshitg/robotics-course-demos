# Week 9 slideshow sources

`content.ps1` contains all 30 slides, speaker guidance, timing, formulas, references and source excerpts. `build_slides.ps1` supplies PowerPoint drawing helpers; `build_body.ps1` generates the plan and deck. Diagrams and equations are editable native shapes/text. Cambria Math equations use true superscript/subscript offsets, including Greek indices.

Run from the repository root with installed Windows PowerPoint:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File week09_actor_critic/slides/build_slides.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File week09_actor_critic/slides/review_slides.ps1
```

The builder generates the PowerPoint, PDF, plan and 1600 × 900 previews. It exports the PDF before hiding slides 26–30, so the review copy includes all 30 pages. It saves and reopens the PPTX to verify notes and hidden states. Existing PowerPoint presentations are left open. The reviewer checks slide order, note timings and references, PDF page count, protected hashes, and layout evidence, then produces five contact sheets.

Teaching slide 4 is physical slide 5 because of the title slide. It teaches distribution and sampling without the specific action-bounding formula. Implementation details appear in notes and hidden backup 4 (physical slide 29).

Selected timing is 30 minutes presentation/worked math, 10 minutes visual demo, and 5 minutes recap. Existing teaching notes and demo runbook are protected and retain their older schedule. Use the new plan/deck for this presentation.

`check_content.ps1` independently checks arithmetic, baseline cancellation, gradient examples, target calculations, PPO clipping examples, historical metrics, and actual code excerpts. It also inspects source for episode boundaries and evaluation behavior. It does not execute Python or validate PyTorch gradients at runtime. `protected_files.json` records original hashes for all demo files, checkpoints, README and teaching notes.

Python is unavailable locally. On a Python-equipped machine with the existing pinned dependencies, run:

```powershell
python -m unittest discover -s week09_actor_critic/demo -p 'test_*.py' -v
python week09_actor_critic/demo/evaluate.py --checkpoint week09_actor_critic/demo/classroom/trained.pt
```

No retraining is needed to validate the supplied checkpoint. Saved figures and recorded training results are historical; no new training result is claimed. Classroom viewer rehearsal is separate from slide-generation checks. Primary technical URLs are in speaker notes. No professor deck was supplied.

See `VALIDATION_REPORT.md`, `validation.json`, and `review.json` for this build's evidence. Text sources use UTF-8 and Windows line endings; scripts include a BOM for Windows PowerShell 5 compatibility.
