# Lecture illustration

`ronen-blocked-mug.png` reproduces the central illustration from **Ronen I.
Brafman, Class 9, “When Geometry Changes the Task Plan,” numbered slide 4,
PDF page 5** of the user-supplied `9-TAMP+PDB.pdf`.

It illustrates moving an obstructing box before picking a mug. It does not
depict an additional capability of the unchanged delivery demo.

The source title/footer were cropped; the destination slide credits the author,
lecture slide, and PDF page visibly and in speaker notes. The supplied lecture
PDF remains external to this repository. Optional reproduction:

```powershell
python week05_task_motion_planning/slides/extract_lecture_figure.py "path/to/9-TAMP+PDB.pdf"
```

This optional extraction uses PyMuPDF at 4× resolution and relative page bounds
`(0.13, 0.16, 0.87, 0.85)`. Normal slideshow rebuilding only needs the checked-in
PNG and PowerPoint. The two central TAMP diagrams are native editable shapes
adapted from slides 8 and 9 (PDF pages 12 and 13).
