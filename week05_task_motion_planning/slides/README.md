# Week 5 slide sources

27 editable 16:9 slides: title, two section dividers, nineteen teaching slides, demo transition, and four hidden backups. The PDF includes all 27 pages for review. Notes carry detailed explanations and primary references. Timing is **20 minutes PDDL + 10 minutes TAMP + 10 minutes demo + 5 minutes questions/recap**. Language flags, dialects and advanced syntax are intentionally not taught.

## Reproduce

Requires Windows PowerShell, installed Microsoft PowerPoint and .NET `Add-Type`. From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week05_task_motion_planning/slides/build_slides.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week05_task_motion_planning/slides/review_slides.ps1
```

The build overwrites the Week 5 PPTX, PDF, presentation plan, previews and validation record. It opens/closes its own presentations and preserves an existing PowerPoint session. No Python, ROS or Gazebo is required for slide generation.

- `content.ps1`: lesson order, timing, notes, source links, action sequences and PDDL excerpts.
- `build_slides.ps1`: native diagrams, editable code with colored keywords, presentation plan generation, PowerPoint export/reopen, text bounds, source checks and hashes.
- `LessonChecks.cs`: independent checker scoped to this demo. It reads the authored PDDL, grounds the actions, uses BFS, traces effects and validates candidate/refined motions against the exact scene. It is not Pyperplan or a general PDDL implementation.
- `review_slides.ps1`: contact sheets, ZIP slide/note/hidden-state checks, note timings/source links, PDF page count and layout checks.
- `protected_files.json`: original SHA256 hashes for teaching notes and all 12 demo files; do not refresh the baseline to conceal changes.
- `validation.json` and `review.json`: generated evidence and limitations.

Preview sheets: [1–6](preview/contact_01.png), [7–12](preview/contact_02.png), [13–18](preview/contact_03.png), [19–24](preview/contact_04.png), [25–27](preview/contact_05.png). Individual PowerPoint renders are `preview/slide_*.png`.

Teaching/code text uses 24 pt or larger; headers and footers use 16 pt, and mathematical subscripts are smaller. Diagrams and equations are editable shapes/text. The demo transition uses the unchanged saved rejection image.

## Checks and rehearsal boundary

Independent C# checks reproduce the four-action BFS candidate, third-action rejection, exact directed/load-specific refinement, six-action revision, pickup/place fact changes, goal completion, unchanged original state, 0.20 m shortcut clearance, empty/tangent/loaded footprint results, workspace boundaries and the 16-permission refinement bound. Token comparison verifies every authored-code excerpt after whitespace rewrapping. The diagram's coordinates/radii/walls are checked against `scene.json`. Source assertions match the explanation to `planning.py`. PowerPoint renders every slide, reopens the saved deck and verifies notes/hidden states. Review verifies all 27 PDF pages and slide/note order. All 13 protected files retain their original hashes.

Every preview was visually inspected for readability, overlaps, code parentheses/indentation, diagrams, signs and contrast. This is artifact validation, not classroom rehearsal.

Python is currently unavailable on this Windows machine. The existing **ten Python tests**, headless trace and GUI were read but **not executed here**. The independent checker does not replace Pyperplan/Matplotlib regression tests. Historical TA-machine results in the preserved runbook remain separate from this generation's checks. On the prepared machine, activate the existing environment and run:

```bash
python -m unittest discover -s week05_task_motion_planning/demo -p 'test_*.py' -v
python week05_task_motion_planning/demo/demo.py --headless
python week05_task_motion_planning/demo/demo.py
```

Rehearse initial → candidate → hypothetical rejection → revision → execution. Computation occurs at startup; stage buttons reveal it. Candidate validation does not modify execution state. Only a validated plan is animated, using parsed action effects at completion. The demo checks straight swept disks, not PRM, grasp mechanics or dynamics. No separate Week 5 professor presentation was supplied.
