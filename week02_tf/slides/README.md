# Week 2 slide sources and checks

## Updated 18-slide presentation

The current teaching deck is `../TF_COORDINATE_TRANSFORMS_UPDATED.pptx`, with a
matching 18-page PDF. All slides are visible, numbered 01–18, with no backup or
hidden slide parts. The 45-minute session remains 20 minutes of explanation plus
25 minutes of practical work and questions.

The revised sequence separates elementary/Euler rotations, the axes-as-columns
interpretation, and homogeneous transforms. Slide 8 shows the same 4×4 transform
both as a 2×2 block layout and as 16 explicit entries. Slides 10–13 cover quaternion
motivation, representation (bold vector **v** and **K**), Hamilton multiplication
and point transformation, and tf2's internal use of quaternions. Slide 13 avoids
message types. The standalone numerical-example slide is removed; its point
transformation remains in the final demonstration guide.

Slide 4 embeds the exact supplied hand image from `assets/right_hand_rule.jpg`,
with its aspect ratio preserved, and replaces the quaternion-order strip with an
explicit reminder to check every data source, library and API. Slide 5 restores
the original equation/B-to-A interpretation and retains the two-frame point diagram.

Rebuild and review using installed Windows PowerPoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week02_tf/slides/update_slides.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week02_tf/slides/review_updated_slides.ps1
```

`revised_content.ps1` contains the revised editable slide bodies; the update script
copies and reorders the original slide templates, preserving the style, then
updates selected bodies and numbering. It does not invoke the original builder.
`-HandImagePath` can override the bundled image; the default is the supplied asset.
`-NoPreview` makes a quick build, but full review requires a fresh build without it.

Updated renders, five contact sheets and reports go into `updated_review/`.
Review checks include package slide order/count, hidden state, notes, numbering,
source-content/render preservation on slides 1, 2, 15 and 16 (allowing footer
renumbering), vector bolding, exact embedded-image hash, video click action,
PDF page count and 209 independent mathematical checks. The original first
207 mathematical checks are supplemented by homogeneous point/direction checks.
Inspect all five contact sheets and dense equations at full resolution.

The gimbal-lock link is now on slide 6 and targets
`https://www.youtube.com/watch?v=BczeMqU_u2Y&t=140s` (2:20). Saved URL/action
verification is separate from actual mouse activation and live Internet playback.
Temporary PDF tools were used to independently parse and render the PDF; they are
not demo dependencies and are not needed by the PowerPoint build/review scripts.

Professor sources reviewed: `2-Frames.pdf` (notation, axes as columns, rigid
transforms, RPY and quaternions) and `3-Kinematics.pdf`, printed slides 12–13
(neighboring-link composition and FK), in the nearby `teaching/ronen slides` folder.

The original PPTX/PDF, teaching notes, mathematical handout, original presentation
workflow, and every file under `week02_tf/demo/` remain preserved. Demo files are
read only as bytes for before/after SHA-256 checks; no demo code is inspected,
modified, executed, rehearsed, or given new dependencies. Slide 18 changes only
presentation guidance.

## Original 26-slide workflow

The following commands and documentation describe the retained original deck.
Use the separate commands above for the updated 18-slide version.

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
