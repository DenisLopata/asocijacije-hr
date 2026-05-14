"""Generate boot splash for Asocijacije."""
from PIL import Image, ImageDraw, ImageFont
import os

DARK_BG = (28, 28, 33, 255)
YELLOW  = (242, 214, 79, 255)
GREEN   = (107, 176, 90, 255)
BLUE    = (97, 148, 199, 255)
PURPLE  = (173, 119, 201, 255)
WHITE   = (255, 255, 255, 255)
GRAY    = (160, 160, 170, 255)

W, H = 1280, 720

img = Image.new("RGBA", (W, H), DARK_BG)
d = ImageDraw.Draw(img)

# --- 4-square icon centered-left of title ---
icon_size = 120
gap = 8
cell = (icon_size - gap) // 2
cx = W // 2 - 80
cy = H // 2 - 30

squares = [
    (cx - cell - gap // 2, cy - cell - gap // 2, YELLOW),
    (cx + gap // 2,        cy - cell - gap // 2, GREEN),
    (cx - cell - gap // 2, cy + gap // 2,        BLUE),
    (cx + gap // 2,        cy + gap // 2,        PURPLE),
]
radius = 10
for x, y, color in squares:
    d.rounded_rectangle([x, y, x + cell, y + cell], radius=radius, fill=color)

# --- Title text ---
font_path = os.path.join(os.path.dirname(__file__), "assets", "fonts", "Outfit-VariableFont_wght.ttf")

try:
    font_title = ImageFont.truetype(font_path, 80)
    font_sub   = ImageFont.truetype(font_path, 28)
except Exception:
    font_title = ImageFont.load_default()
    font_sub   = font_title

title = "Asocijacije"
sub   = "Grupiranje rijeci"

title_x = cx + icon_size // 2 + 24
title_y = cy - 52
d.text((title_x, title_y), title, font=font_title, fill=WHITE)

sub_x = title_x + 4
sub_y = title_y + 88
d.text((sub_x, sub_y), sub, font=font_sub, fill=GRAY)

out_path = os.path.join(os.path.dirname(__file__), "assets", "boot_splash.png")
img.convert("RGB").save(out_path)
print("Saved:", out_path)
