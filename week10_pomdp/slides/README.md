# Week 10 slideshow sources

`content.ps1` contains all 38 slides, notes, timing, mathematical expressions and references. `build_slides.ps1` provides native PowerPoint helpers; `build_body.ps1` generates the deck, plan and previews. Equations use editable Cambria Math text with true subscript/superscript offsets. Matrices, probability tables, policy trees, belief diagrams and value plots are editable native shapes/text.

Run from the repository root with installed Windows PowerPoint:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File week10_pomdp/slides/build_slides.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File week10_pomdp/slides/review_slides.ps1
```

The builder renders 1600 × 900 slide previews, exports the all-slide PDF before hiding slides 34–38, saves the PPTX and reopens it to verify notes and hidden states. It checks protected hashes before and after generation. Existing PowerPoint presentations are left open. The reviewer checks ordered titles, note timings/source references, PDF pages, hashes and layout evidence; it generates seven contact sheets.

The selected schedule is 38 minutes explanation/worked calculations, four minutes exercise and three minutes recap. There is no software-demo block. The blue exercise is physical slide 16; its answer follows on slide 17. Notes contain instructor answers, while the exercise slide visibly leaves calculation slots blank.

`check_content.ps1` performs 51 independent content checks, including probability calculations, posterior averaging, sensing values and alpha-vector intersections. Grid checks compare Bayes-derived sense-once decisions with fixed-tree/envelope values across 101 priors and belief-update identities across 21 priors. It also checks 13 source patterns against the preserved original material.

`protected_files.json` records the original SHA-256 hashes of teaching notes, board-work README and commitment-only SVG. The presentation plan is intentionally rewritten. The original SVG remains unchanged; native editable plot lines reproduce its mathematics, and a separate expanded plot adds the sensing strategy.

This theoretical week has no executable learner or simulator to test. All validation arithmetic runs in PowerShell. No Python, ROS or MuJoCo process is needed. The professor PDF was not found locally; its existing filename/title-page discrepancy and printed-slide references are retained without claiming review. Primary source URLs are in notes.

See `VALIDATION_REPORT.md`, `validation.json` and `review.json` for the build evidence. Text files use UTF-8 and Windows line endings; scripts include a BOM for Windows PowerShell compatibility. PowerPoint lock files remain excluded by the repository's existing ignore rule.
