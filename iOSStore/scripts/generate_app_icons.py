#!/usr/bin/env python3
"""
generate_app_icons.py

Generates all required iOS app icon sizes from a single high-resolution source.

Usage:
    python scripts/generate_app_icons.py path/to/source_image.png

The source image should be square and at least 1024x1024 (2048x2048 recommended).
Output files are saved to iOSStore/Assets.xcassets/AppIcon.appiconset/.
"""

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow is required. Install it with: pip install Pillow")
    sys.exit(1)


# iPhone icon sizes referenced in Contents.json
SIZES = [
    ("icon-20@2x.png", 40),
    ("icon-20@3x.png", 60),
    ("icon-29@2x.png", 58),
    ("icon-29@3x.png", 87),
    ("icon-40@2x.png", 80),
    ("icon-40@3x.png", 120),
    ("icon-60@2x.png", 120),
    ("icon-60@3x.png", 180),
    ("icon-1024.png", 1024),
]


def generate_icons(source_path: Path, output_dir: Path):
    img = Image.open(source_path)
    if img.width != img.height:
        print("Warning: Source image is not square. It will be cropped to square.")
        size = min(img.width, img.height)
        left = (img.width - size) // 2
        top = (img.height - size) // 2
        img = img.crop((left, top, left + size, top + size))

    output_dir.mkdir(parents=True, exist_ok=True)

    for filename, size in SIZES:
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        out_path = output_dir / filename
        resized.save(out_path, "PNG")
        print(f"Generated {out_path}")

    print("Done! All icon sizes generated.")


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_app_icons.py <source_image.png>")
        sys.exit(1)

    source_path = Path(sys.argv[1]).resolve()
    if not source_path.exists():
        print(f"Source image not found: {source_path}")
        sys.exit(1)

    project_root = Path(__file__).resolve().parent.parent
    output_dir = project_root / "iOSStore" / "Assets.xcassets" / "AppIcon.appiconset"

    generate_icons(source_path, output_dir)


if __name__ == "__main__":
    main()
