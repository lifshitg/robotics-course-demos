# Week 1 — Final ROS presentation

Present [ROS_BASICS_FINAL.pptx](../ROS_BASICS_FINAL.pptx), or review
[ROS_BASICS_FINAL.pdf](../ROS_BASICS_FINAL.pdf). The PowerPoint contains **15 main
slides and five hidden backups**. The reference PDF includes all **20 pages**;
optional pages keep the “Optional / deeper discussion” heading.

## Final slide order

| Slide | Content |
| --- | --- |
| 1 | Robotics & Autonomous Systems — Week 1 |
| 2 | About me — Gilad Lifshitz, studies, army experience, feedback invitation |
| 3 | ROS basics — today's plan |
| 4 | What is ROS, and why do we need it? |
| 5 | Application photographs: autonomous vehicles, robotics, drones |
| 6–9 | ROS timeline; nodes; topics/messages; interfaces |
| 10 | ROS domain |
| 11 | ROS 2 communication behind the scenes |
| 12 | QoS shapes delivery, including a mention of additional policies |
| 13 | Lifecycle of an ordinary node |
| 14 | Inspect before debugging |
| 15 | Demo time |
| 16–20 | Hidden backups: DDS, QoS compatibility, concurrency, managed lifecycle, migration |

The explanation and introduction take 25 minutes. The Demo time block reserves
7 minutes for code, 6 for running/inspection, 4 for stop/restart experiments, and
3 for questions/recap: **45 minutes total**. Per-slide pacing and teaching guidance
are in speaker notes. Use the [demo instructions](../demo/README.md) for commands.
The existing teaching notes and presentation plan remain as background material;
their older slide numbering does not describe the final deck.

## Rebuild

From the repository root:

```bash
python3 -m venv /tmp/ros-slides-venv
/tmp/ros-slides-venv/bin/pip install -r week01_ros/slides/requirements-final.txt
/tmp/ros-slides-venv/bin/python week01_ros/slides/build_final_slides.py
```

Install LibreOffice Impress before running the complete build. If its executable
is not on `PATH`, pass `--soffice /path/to/soffice`. Use `--no-pdf` to rebuild only
the PowerPoint. The builder works from any current directory and does not require
Windows or PowerPoint.

For a matching PDF, install **Aptos** from the
[official Microsoft font download](https://www.microsoft.com/en-us/download/details.aspx?id=106087).
The deck retains the original Aptos and Consolas font names; the exporter uses a
fallback for any unavailable font. Keep Consolas installed when exact code-font
matching is needed. Fonts are not distributed in this repository.

The source is `ROS_BASICS_UPDATED.pptx`. The builder keeps its native diagram and
text shapes, inserts the introduction and agenda, applies the requested edits,
and writes only the final outputs. It exports an all-visible temporary copy with
LibreOffice so backup pages appear in the PDF while staying hidden in the final
PowerPoint. The original decks, plans, notes, and demo files are checked for changes.

## Images and review

The three photographs are downloaded originals in `assets/`; rebuilding needs no
network access. [credits.json](assets/credits.json) records author, license,
license URL, source page, download URL, and the displayed crop for each image.
Full credits also appear in slide 5's speaker notes. They illustrate application
fields rather than asserting that the pictured products use ROS.

`final_preview/` contains one rendered PNG per slide.
[final_validation.json](final_validation.json) records slide counts, hidden states,
titles, timing, preserved diagrams/slides, PDF content checks, and original-file
hashes. Review the previews after rebuilding: automated checks do not substitute
for inspecting slide layout. [FINAL_REVIEW.md](FINAL_REVIEW.md) records the visual
review of the delivered version.

The existing `build_slides.ps1`, `preview/`, and `validation.json` belong to the
earlier deck and are retained unchanged.
