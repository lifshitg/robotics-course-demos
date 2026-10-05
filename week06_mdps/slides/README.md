# Week 6 slideshow sources

`content.ps1` contains all 30 slides, equations, notes, timings and source links. `build_slides.ps1` supplies native PowerPoint drawing helpers and loads `build_body.ps1`. Equations are editable Cambria Math text with native superscript/subscript formatting; matrices and graphs use editable shapes.

From the repository root on Windows with installed PowerPoint:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File week06_mdps/slides/build_slides.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File week06_mdps/slides/review_slides.ps1
```

The builder regenerates the presentation plan, PPTX, PDF and 1600×900 PNG previews, reopens the saved deck, checks notes and hidden states, and records `validation.json`. It exports the PDF before hiding slides 26–30, keeping all 30 PDF pages. The reviewer checks the ZIP/XML structure, notes, sources, PDF page count and timing; it generates contact sheets and `review.json`.

`protected_files.json` records the SHA256 baseline for all demo files and teaching notes. Build and review must preserve these hashes. `check_math.ps1` checks slide arithmetic independently and confirms demo source constants/algorithm patterns. It is not a substitute for execution of the demo's Python solvers.

Python is unavailable locally. The following existing checks remain for a Python-equipped machine with the requirements installed:

```powershell
python -m unittest discover -s week06_mdps/demo -p 'test_*.py' -v
python week06_mdps/demo/demo.py --headless
python week06_mdps/demo/demo.py --headless --failure 0.1
```

Classroom GUI rehearsal is separate. Existing README/teaching-note results are historical documentation, not checks newly executed during slide generation. The professor PDF was not found locally; its existing printed-slide references are retained without claiming review.
