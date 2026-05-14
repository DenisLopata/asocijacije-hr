"""Generate PNG icons for Asocijacije from the SVG design."""
from PIL import Image, ImageDraw
import os

DARK_BG   = (28, 28, 33, 255)
YELLOW    = (242, 214, 79, 255)
GREEN     = (107, 176, 90, 255)
BLUE      = (97, 148, 199, 255)
PURPLE    = (173, 119, 201, 255)

def draw_icon(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # Background rounded rect (approximate with ellipse corners)
    radius = max(2, size // 8)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=DARK_BG)

    pad = size // 16
    gap = size // 16
    cell = (size - 2 * pad - gap) // 2

    # Top-left: yellow
    d.rounded_rectangle(
        [pad, pad, pad + cell, pad + cell],
        radius=max(2, size // 16), fill=YELLOW
    )
    # Top-right: green
    d.rounded_rectangle(
        [pad + cell + gap, pad, pad + cell * 2 + gap, pad + cell],
        radius=max(2, size // 16), fill=GREEN
    )
    # Bottom-left: blue
    d.rounded_rectangle(
        [pad, pad + cell + gap, pad + cell, pad + cell * 2 + gap],
        radius=max(2, size // 16), fill=BLUE
    )
    # Bottom-right: purple
    d.rounded_rectangle(
        [pad + cell + gap, pad + cell + gap, pad + cell * 2 + gap, pad + cell * 2 + gap],
        radius=max(2, size // 16), fill=PURPLE
    )
    return img


sizes = {
    "icon_16.png":   16,
    "icon_32.png":   32,
    "icon_64.png":   64,
    "icon_128.png":  128,
    "icon_256.png":  256,
    "favicon.png":   32,
}

out_dir = os.path.join(os.path.dirname(__file__), "assets", "icons")
os.makedirs(out_dir, exist_ok=True)

for filename, size in sizes.items():
    img = draw_icon(size)
    path = os.path.join(out_dir, filename)
    img.save(path)
    print(f"  {filename} ({size}x{size})")

# Also save favicon to project root for Godot web export
favicon_path = os.path.join(os.path.dirname(__file__), "favicon.png")
draw_icon(32).save(favicon_path)
print("  favicon.png -> project root")

# Save 128px icon.png to project root (Godot fallback)
draw_icon(128).save(os.path.join(os.path.dirname(__file__), "icon.png"))
print("  icon.png (128x128) -> project root")

print("\nDone.")
