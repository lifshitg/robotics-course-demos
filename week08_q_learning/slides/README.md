# Week 8 slideshow sources

`content.ps1` contains all28 slides, notes, timings, sources and actual code excerpts. `build_slides.ps1` supplies native drawing helpers and loads `build_body.ps1`. Equations use editable Cambria Math text with true superscript/subscript offsets; diagrams, maze and cards are editable shapes.

Run from the repository root with installed Windows PowerPoint:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File week08_q_learning/slides/build_slides.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File week08_q_learning/slides/review_slides.ps1
```

The builder regenerates the plan, deck, PDF and1600×900 slide previews. PDF export precedes hiding slides24–28, ensuring all28 pages appear. It then saves/reopens the PPTX and verifies hidden states/notes/protected hashes. The reviewer checks title order, note sources/timing, PDF pages, layout evidence and hashes, generating contact sheets and `review.json`.

Selected timing is30+10+5. Existing teaching notes and runbook are protected and retain older23+17+5 timing; use the new deck/plan schedule.

`check_content.ps1` independently checks arithmetic, rewrapped source excerpts, defaults, action selection, update/reset order and evaluation source isolation. It does not execute the Python learner. `protected_files.json` preserves every demo file (including .gitignore) and teaching notes.

Python is unavailable locally. On a Python-equipped machine with existing dependencies installed:

```powershell
python -m unittest discover -s week08_q_learning/demo -p 'test_*.py' -v
python week08_q_learning/demo/demo.py --headless --output week08_q_learning/demo/output/slide-validation
```

Saved figures and runbook route results are historical, not new training runs. Classroom GUI rehearsal is separate. No professor deck was supplied; the existing Sutton/Barto reference is retained without claiming the unavailable PDF was reviewed.
