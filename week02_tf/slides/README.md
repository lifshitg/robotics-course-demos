# Week 2 slide sources and checks

Run from the repository root on Windows with installed PowerPoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week02_tf/slides/validate_math.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week02_tf/slides/build_slides.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week02_tf/slides/review_slides.ps1
```

`content.ps1` holds the lesson sequence, speaker guidance, timings and source links. `build_slides.ps1` creates editable native PowerPoint text, equations and diagrams, updates the presentation plan, exports every slide and the full review PDF, hides slides 17–26, and reopens the saved deck to verify it. It does not close an existing user presentation. `TF_MATH_REFERENCE.md` is the complete mathematical handout; it is independently maintained and is not overwritten by deck generation.

`MathChecks.cs` compares elementary matrices, expanded Euler formulas, quaternion formulas, and quaternion sandwich rotation. It also checks composition/inversion, principal and singular Euler recovery, stable largest-component matrix conversion, and SLERP sign handling. Displayed rounded values use appropriately looser tolerances than unrounded internal calculations.

`math_validation.json` records numerical checks. `validation.json` records slide timing, notes/hidden-state verification, dimensions, text-bound issues and protected-file hashes. `review_slides.ps1` builds five contact sheets and checks PowerPoint ZIP structure, hidden states, notes count, PDF pages and unresolved overflow. Inspect every contact sheet and zoom into dense equations in the individual slide PNGs. Superscripts/subscripts use smaller index glyphs; teaching body text is at least 24 pt. Headers and footers match Week 1 at 16 pt.

The baseline in `protected_files.json` covers all six preserved Week 2 files: teaching notes, demo README, three Python scripts and RViz config. Regeneration refuses changes relative to that baseline. These numerical and artifact checks do not run the classroom ROS/RViz demo. Follow the unchanged demo README on the Jazzy teaching machine for rehearsal.
