# Rebuild and review Week 12

`content.ps1` is the editable slide specification: titles, short slide text, equations, timing, notes and primary references. `build_slides.ps1` supplies the shared Week1–10 PowerPoint style; `build_body.ps1` renders native editable diagrams/equations and regenerates the presentation plan. PowerPoint is required on Windows. Sources use UTF-8 BOM for Windows PowerShell 5.1 and CRLF line endings.

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File week12_filters_slam/slides/build_slides.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File week12_filters_slam/slides/review_slides.ps1
```

The builder exports all38 slides to PDF and PNG before hiding backups34–38 in the saved PPTX. It reopens the deck, checks notes/hidden states, measures text bounds, and checks protected hashes. `check_content.ps1` performs24 independent arithmetic/timing checks. `review_slides.ps1` verifies ZIP titles/notes/references,38 PDF pages, previews, timing and hashes, and assembles seven contact sheets.

Demo checks:

```powershell
python week12_filters_slam/demo/validate_demo.py
python week12_filters_slam/demo/smoke_gui.py
```

The GUI smoke test uses a hidden Tk window and records startup, controls and shutdown. It is separate from a human classroom rehearsal. Use a desktop-capable Python runtime. Current local commands used `C:/Users/gilad/AppData/Local/Programs/Python/Python313/python.exe`; use your environment's `python` elsewhere. See the demo README for all four headless exports.

Protected baseline: teaching notes, pinned requirements, existing localization test file and four original localization images. Demo source/README changes are explicitly authorized this week. Original protected files are never regenerated. New SLAM snapshots are under `demo/figures/slam_low` and `slam_high`.

Evidence: `validation.json`, `review.json`, `demo_validation/tests.json`, `demo_validation/gui.json`, the per-mode summaries and `VALIDATION_REPORT.md`. No professor presentation was supplied. The sources reference primary papers and author documentation; numerical examples and diagrams are original teaching material.