#!/usr/bin/env python3
"""
extract_brand_colors.py

Extracts dominant colors from the app logo for use in the SwiftUI theme.

Usage:
    python scripts/extract_brand_colors.py LOGIC.png
"""

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow is required. Install it with: pip install Pillow")
    sys.exit(1)


def get_dominant_colors(image_path: Path, count: int = 5):
    img = Image.open(image_path)
    img = img.convert("RGB")
    img = img.resize((150, 150))  # resize for speed
    pixels = list(img.getdata())

    # Simple color quantization by rounding to nearest 32
    color_counts = {}
    for r, g, b in pixels:
        key = (r // 32 * 32, g // 32 * 32, b // 32 * 32)
        color_counts[key] = color_counts.get(key, 0) + 1

    sorted_colors = sorted(color_counts.items(), key=lambda x: x[1], reverse=True)
    return sorted_colors[:count]


def to_hex(rgb):
    return "#{:02x}{:02x}{:02x}".format(*rgb)


def main():
    if len(sys.argv) < 2:
        print("Usage: python extract_brand_colors.py <image.png>")
        sys.exit(1)

    image_path = Path(sys.argv[1]).resolve()
    if not image_path.exists():
        print(f"Image not found: {image_path}")
        sys.exit(1)

    colors = get_dominant_colors(image_path)
    print("Dominant colors from logo:")
    for color, count in colors:
        hex_color = to_hex(color)
        print(f"  {hex_color} (RGB: {color}) - {count} pixels")


if __name__ == "__main__":
    main()
