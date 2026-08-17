#!/usr/bin/env python3
"""Build a square launcher source from assets/images/popmusic-logo.png.

Fills the white corner regions (outside the rounded artwork) with the navy
background so Android/iOS/web icons don't show white corners.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "images" / "popmusic-logo.png"
DST = ROOT / "assets" / "images" / "app_icon.png"


def near_white(pixel: tuple[int, int, int, int], thresh: int = 240) -> bool:
    return pixel[0] >= thresh and pixel[1] >= thresh and pixel[2] >= thresh


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    width, height = src.size
    pixels = src.load()

    # Mid-left edge is navy inside the rounded rect.
    bg = pixels[8, height // 2][:3] + (255,)

    out = src.copy()
    out_pixels = out.load()
    visited = [[False] * width for _ in range(height)]
    queue: deque[tuple[int, int]] = deque(
        [(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1)]
    )

    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= width or y >= height or visited[y][x]:
            continue
        visited[y][x] = True
        if not near_white(pixels[x, y]):
            continue
        out_pixels[x, y] = bg
        queue.extend([(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)])

    out.save(DST)
    print(f"Wrote {DST.relative_to(ROOT)} from {SRC.relative_to(ROOT)} (bg={bg[:3]})")


if __name__ == "__main__":
    main()
