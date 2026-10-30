# Week 3 presentation sources

Run from the repository root on Windows with installed PowerPoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week03_kinematics/slides/validate_math.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week03_kinematics/slides/build_slides.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File week03_kinematics/slides/review_slides.ps1
```

`content.ps1` supplies the sequence, timing, notes and source links; the generator updates the presentation plan from it. Diagrams, equations, snippets, callouts and arm sketches use editable PowerPoint shapes/text. The existing screenshot is extracted unchanged from the SVG's embedded PNG; close-ups use editable PowerPoint picture cropping. `assets/gazebo_screenshot.png` is a derived copy and is regenerated from the protected source.

The deck has 19 slides: title, 12 teaching slides totaling 20 minutes, an untimed picture-only geometry slide at position 12, 25-minute demo transition, and four hidden backups (16–19). The review PDF includes the backups. All 19 slides have notes. The supplied image is stored unchanged in `assets/forward_kinematics_geometry.jpg`; existing slides retain their original content and footer numbers. Main body text is at least 24 pt; equation indices are smaller; headers/footers follow the previous weeks at 16 pt. The deck uses ROS 2 Jazzy/Gazebo Harmonic, not Gazebo Classic.

The build uses installed PowerPoint to export every slide, save PDF/PPTX, reopen and check the PPTX. It keeps existing user presentations open. The review script makes four contact sheets and validates slide/notes counts, hidden XML states, PDF pages and unresolved text bounds. Inspect individual slide previews for equation signs, spacing, picture crops and readability.

Numerical checks independently compare planar FK with a 4×4 transform product, exercise both IK branches and round trips, boundaries/rejections, orientations and a finite-difference Jacobian. Configuration checks compare the equations and teaching claims with URDF dimensions/axes/limits, world physics, and bridge topic names/types/directions. They do not run or replace the existing Python unit tests or live ROS/Gazebo rehearsal; use the unchanged demo README for those on the teaching machine.

`protected_files.json` records SHA256 hashes of the original teaching notes and all ten demo files. The builder refuses mismatches and verifies hashes again after export. `validation.json` and `math_validation.json` record artifact and numerical checks. No demo files or teaching notes are edited.
