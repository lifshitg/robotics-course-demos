# Week 7 slideshow sources

`content.ps1` is the editable slide/notes/timing/source definition. `build_slides.ps1` supplies native PowerPoint helpers and loads `build_body.ps1`. Diagrams, cards, annotations and the backup matrix remain editable; only the preserved saved-result figure is raster.

From the repository root on Windows with installed PowerPoint:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File week07_imitation_learning/slides/build_slides.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File week07_imitation_learning/slides/review_slides.ps1
```

The builder regenerates the plan, deck, PDF and 1600×900 previews. It exports all25 slides to PDF before hiding backups22–25, then saves and reopens the deck. The reviewer checks PPTX/XML titles, notes, source links, hidden states, PDF pages, timing and protected hashes, and produces contact sheets.

`check_content.ps1` independently verifies authored arithmetic and source patterns. `protected_files.json` is the SHA256 baseline for the ten demo files (including .gitignore) plus teaching notes. These slide checks do not execute MuJoCo, NumPy training or the original Python tests.

Python is unavailable locally. On a Python-equipped machine with the existing requirements installed:

```powershell
python -m unittest discover -s week07_imitation_learning/demo -p 'test_*.py' -v
python week07_imitation_learning/demo/demo.py all --output week07_imitation_learning/demo/output/slide-validation
```

Using a separate output directory preserves demonstration artifacts. The saved comparison and documented expert/learner success figures are historical results. Classroom viewer rehearsal is separate; the existing runbook records a prior graphics-backend limitation. The professor PDF was not found and was not reviewed.
