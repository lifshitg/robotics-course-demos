"""Optional: recreate the attributed illustration from the supplied lecture PDF.

Requires PyMuPDF. The deck builder uses the checked-in PNG, not this dependency.
Usage: python extract_lecture_figure.py "path/to/9-TAMP+PDB.pdf"
"""
import argparse
from pathlib import Path

import pymupdf


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pdf", type=Path)
    args = parser.parse_args()
    target = Path(__file__).resolve().parent / "assets" / "ronen-blocked-mug.png"
    with pymupdf.open(args.pdf) as document:
        page = document[4]  # Printed slide 4, PDF page 5 (overlays shift numbering).
        rect = page.rect
        clip = pymupdf.Rect(rect.width * .13, rect.height * .16,
                            rect.width * .87, rect.height * .85)
        target.parent.mkdir(exist_ok=True)
        page.get_pixmap(matrix=pymupdf.Matrix(4, 4), clip=clip).save(target)
    print(target)


if __name__ == "__main__":
    main()
