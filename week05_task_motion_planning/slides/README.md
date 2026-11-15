# Week 5 slide sources

**23 editable 16:9 slides, all presented; no hidden slides.**
The PDF includes all 23 pages. Timing is **15 minutes classical planning/PDDL +
15 minutes TAMP + 10 minutes unchanged demo + 5 minutes recap = 45 minutes**.

The lesson begins with the motivation for factored representations and PDDL:
implicit search still needs a compact model; facts and reusable action schemas
specify states and local transitions without listing the whole graph. Compact
representation does not eliminate a potentially exponential search space.
Slide 15 adds a response/meaning/example table after the TAMP loop; the previous
architecture slide is now slide 16. The loop and table share three minutes.
The second part centers Ronen's feedback loop and three TAMP architectures
(numbered slides 8 and 9, supplied PDF pages 12 and 13). No pattern-database or
related heuristic-abstraction material is taught, and no hidden references remain.

## Build and review

Requires Windows PowerShell and installed Microsoft PowerPoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week05_task_motion_planning/slides/build_slides.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week05_task_motion_planning/slides/review_slides.ps1
```

The builder overwrites the Week 5 PPTX, PDF, generated presentation plan, numbered
previews, and validation record. It creates/closes its own presentations while
preserving an existing PowerPoint session. Windows Office automation may require
the interactive user's logon context. The checked-in lecture illustration means
no Python/PDF library is required for normal deck generation.

- `content.ps1`: lesson order, exact timing, speaker notes, lecture slide/PDF-page
  references, actual PDDL excerpts, and expected action sequences.
- `layouts.ps1`: editable slide diagrams and code layouts; the blocked-mug figure
  is the one attributed raster illustration.
- `build_slides.ps1`: PowerPoint generation/export/reopen, token/source checks,
  text fit, and protected-file checks.
- `LessonChecks.cs`: independent checker scoped to this scene and PDDL example.
  It is not Pyperplan or a general planning implementation.
- `review_slides.ps1`: contact sheets, slide/note order, hidden states, timings,
  citations, PDF page count, preview count, and protected hashes.
- `protected_files.json`: original hashes for all 12 demo files and original
  teaching notes. The baseline is preserved; it must not be refreshed to hide edits.
- `validation.json`, `review.json`: generated slide-build evidence.
- `python_validation.json`: actual existing Python-suite and headless trace
  results, separate from the independent C# checks.
- `assets/README.md`: illustration attribution and optional extraction details.

Use [the updated teaching guide](../TEACHING_NOTES_UPDATED.md) for the current
schedule. The original `TEACHING_NOTES.md` is retained unchanged as historical
material. The generated [presentation plan](../PRESENTATION_PLAN.md) carries
per-slide notes and source excerpts.

## Validation and classroom boundary

The original ten Python tests and the headless trace pass. The suite includes
noninteractive Agg interface/playback/reset checks. It confirms the four-action
candidate, third-action rejection, exact directed/load-specific refinement,
six-action revision, goal completion, and unchanged authored problem. See the
record for exact commands and output. Temporary dependency installation did not
change demo code, configuration, images, requirements, or the runbook.

The independent C# checks also verify state effects, swept-disk contact/boundary
behavior, and the finite refinement bound. The builder compares PDDL tokens to
actual files and checks diagrams against `scene.json`. The exported deck is
reopened to verify notes and hidden states; PDF and preview counts must be 23.
Every numbered render receives visual review. These checks do not replace
classroom GUI rehearsal or a timed presentation rehearsal.

Rehearse initial → candidate → hypothetical rejection → revision → execution.
All planning is computed at startup; stage buttons reveal it. Candidate checks do
not move execution state. Only validated plans animate. The demo checks straight
swept disks, without PRM, grasp mechanics, dynamics, or hardware execution.

Preview sheets: [1–6](preview/contact_01.png), [7–12](preview/contact_02.png),
[13–18](preview/contact_03.png), [19–23](preview/contact_04.png). Individual renders are `preview/slide_*.png`.
Teaching text/code is generally 24 pt or larger; diagrams may use smaller
connector labels, while headers, footers, citations, and subscripts are smaller.
