# Final Week 1 presentation review

Reviewed on 2026-10-20.

## Delivered files

- `ROS_BASICS_FINAL.pptx`: 20 editable slides, with main slides 1–15 visible and
  backup slides 16–20 hidden during normal slideshow playback.
- `ROS_BASICS_FINAL.pdf`: all 20 slides, including the labeled optional pages.
- `final_preview/slide_01.png` through `slide_20.png`: rendered slide previews.

## Validation performed

- Reopened the generated PowerPoint with python-pptx and parsed its XML package.
- Checked titles, sequential footer numbers, all speaker notes, slide dimensions,
  hidden-slide states, and a 45-minute teaching schedule.
- Compared preserved slide shapes against the updated source. The timeline,
  nodes, topics, interfaces, inspection slide, and five backup slides retain
  their original shapes apart from footer numbering. The domain and demo slides
  change only their titles and footers. The definition layers, DDS stack and
  discovery/data arrows, and original QoS cards also pass preservation checks.
- Confirmed three photographs on the applications slide and full image
  attribution/license/source information in its speaker notes.
- Confirmed that the main lifecycle slide contains only the ordinary-node flow.
- Exported the reference PDF with LibreOffice 24.2.7.2 and checked that all **269
  nonempty text frames** survive export, including code, captions, and new text.
- Visually inspected all 20 rendered slides for text clipping, overlap, photo
  crops, diagram readability, and footer placement. No layout problems found.
- Confirmed that the PDF embeds Aptos, Aptos Bold, Consolas, and Consolas Bold.
  Aptos came from Microsoft's font download; the source PDF's embedded Consolas
  subsets were used temporarily for export. Font files are not redistributed.
- Checked the added deadline, lifespan, and liveliness examples against the
  [official Jazzy QoS documentation](https://github.com/ros2/ros2_documentation/blob/jazzy/source/Concepts/Intermediate/About-Quality-of-Service-Settings.rst).
- Verified hashes of both earlier PPTX/PDF versions and the existing teaching
  plans, notes, and demo files; all are unchanged.
- Checked repository presentation links and `git diff --check`.

Detailed machine-readable results and original-file hashes are in
[final_validation.json](final_validation.json). Validation used LibreOffice and
python-pptx; interactive Microsoft PowerPoint playback was not exercised here.
