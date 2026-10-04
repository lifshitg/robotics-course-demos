# Week 4 slide sources

Editable, 16:9 PowerPoint with a light background, blue/teal accents, 40 pt titles, 24 pt or larger teaching text, native diagrams and editable equations. The existing demo overview is the only raster figure. Mathematical subscripts are smaller by design; running headers and footers use 16 pt.

## Build and review

Requires Windows PowerShell, installed Microsoft PowerPoint, and the .NET compiler available through `Add-Type`. No Python, ROS or Gazebo is needed to generate these artifacts. From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week04_motion_planning/slides/build_slides.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week04_motion_planning/slides/review_slides.ps1
```

The build overwrites the Week 4 PPTX, PDF, presentation plan, previews and validation record. It creates and closes its own presentations and preserves an already-running PowerPoint session. The PDF intentionally contains all 22 slides for review; slides 18–22 are hidden in the PPTX. Speaker notes carry teaching details, timing, caveats and references. The 15 teaching slides total 20 minutes; demo transition notes preserve the 5/12/8-minute blocks.

- `content.ps1`: slide order, short cues, notes, timings and sources; also generates the updated presentation plan.
- `build_slides.ps1`: native PowerPoint layout, editable arm/roadmap illustrations, render/export/reopen and validation.
- `GeometryChecks.cs`: independent geometry checks and illustrative roadmap. Its hand-selected points are **not** the demo's seed-7 samples. The actual start/goal are retained; valid and rejected attachments are checked against the scene geometry.
- `review_slides.ps1`: ZIP notes/hidden-state checks, PDF page count, contact-sheet generation and text-overflow checks.
- `protected_files.json`: original SHA256 hashes for teaching notes and all seven demo files. Build fails if they differ; do not refresh hashes to conceal changes.
- `validation.json`: generated checks, timing and hashes. `preview/slide_*.png` are PowerPoint renders of every slide, including backups; `contact_*.png` are four overview sheets.
- `review.json`: saved slide-order, note-source/timing, hidden-state and PDF-page verification.

Preview sheets: [slides 1–6](preview/contact_01.png), [7–12](preview/contact_02.png), [13–18](preview/contact_03.png), [19–22](preview/contact_04.png). [Unsampled-point slide](preview/slide_13.png).

## Validation boundary

PowerPoint generated and rendered the deck, reopened the saved PPTX, and checked 22 slides, notes, five hidden backups and 20+25-minute timing. Review checks validate 22 PDF pages. Text bounds were checked and every slide preview was visually inspected for legibility, overlaps, subscripts, signs and contrast. Independent C# calculations check FK, free endpoints/colliding midpoint, segment distances, hard limits, interpolation endpoints/resolution, neighbor ordering, disconnected search, exact illustrative query endpoints and denser 0.002-rad replay. Source assertions match attachment/copy/contact/equal-endpoint explanations to the existing Python code. Protected files retain their original hashes.

Python is not installed on this Windows machine: the repository's eight Python test methods and GUI were **read but not executed here**. No new 20/300-sample comparison or classroom rehearsal is claimed. The numeric comparison on slide 16 is explicitly attributed to the existing README's TA-machine run. To rehearse on that machine:

```bash
python3 -m unittest discover -s week04_motion_planning/demo -p 'test_*.py'
python3 week04_motion_planning/demo/demo.py
python3 week04_motion_planning/demo/demo.py --compare
```

Clicking configuration space previews a pose and pauses playback; it does not submit a planning query. Stages reveal calculations prepared at startup. Sampling and local collision checks are finite, self-collision is unmodeled, and playback is kinematic.

The separate `MotionPlaningIntroPRM.pdf` was not found locally. Oren Salzman's references remain by **section and printed slide number**: Introduction 15–20; PRM 4–8 (pipeline/sampling), 14 (connections), 17 and 20 (collision/local planning), 21 (search), 22–23 (completeness). The supplied PDF was not reviewed for this update. Primary background links are in the slide notes and presentation plan.
