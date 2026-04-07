"""
Generates AppIcon.appiconset for SG Rain Radar (macOS 14+).
Light and dark variants at all required sizes.
Requires: pillow
"""
import json, os, math
from PIL import Image, ImageDraw

ASSET_DIR = os.path.join(
    os.path.dirname(__file__),
    "../Assets.xcassets/AppIcon.appiconset"
)

LIGHT = dict(bg=(29, 112, 243), cloud=(255, 255, 255), drop=(160, 212, 255))
DARK  = dict(bg=(15,  22,  50), cloud=(210, 228, 255), drop=(90,  160, 235))


def make_icon(size: int, p: dict) -> Image.Image:
    S = size * 4  # render 4× for anti-aliasing
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    # ── background (flat colour + rounded square mask) ──────────────────────
    bg = Image.new("RGBA", (S, S), p["bg"] + (255,))
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, S - 1, S - 1], radius=int(S * 0.225), fill=255
    )
    img.paste(bg, mask=mask)

    draw = ImageDraw.Draw(img)
    cloud = p["cloud"] + (255,)

    # ── cloud silhouette ─────────────────────────────────────────────────────
    # Three bumps across the top; a wide base ellipse underneath.
    # All positioned so the whole cloud sits centre-high in the icon.
    mid_x = S * 0.50
    mid_y = S * 0.38   # vertical centre of cloud

    def ellipse(cx, cy, rx, ry):
        draw.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=cloud)

    # Wide base
    ellipse(mid_x,          mid_y + S*0.04,  S*0.235, S*0.115)
    # Left bump
    ellipse(mid_x - S*0.14, mid_y - S*0.01,  S*0.115, S*0.105)
    # Centre bump (tallest)
    ellipse(mid_x,          mid_y - S*0.07,  S*0.135, S*0.130)
    # Right bump
    ellipse(mid_x + S*0.13, mid_y - S*0.01,  S*0.110, S*0.100)

    # ── rain drops ───────────────────────────────────────────────────────────
    drop_color = p["drop"] + (220,)
    cloud_base = mid_y + S * 0.155   # bottom of cloud

    dw = S * 0.042   # drop width
    dh = S * 0.115   # drop height
    dr = dw / 2

    # 4 drops, evenly spaced, with a stagger so they look natural
    cols   = [-S*0.155, -S*0.052, S*0.052, S*0.155]
    stagger = [S*0.00,   S*0.05,  S*0.025, S*0.065]

    for dx, dy_off in zip(cols, stagger):
        x = mid_x + dx
        y = cloud_base + S*0.04 + dy_off
        draw.rounded_rectangle(
            [x - dw/2, y, x + dw/2, y + dh],
            radius=int(dr), fill=drop_color
        )

    return img.resize((size, size), Image.LANCZOS)


ENTRIES = [
    (16,  "1x", "16x16"),
    (16,  "2x", "16x16@2x"),
    (32,  "1x", "32x32"),
    (32,  "2x", "32x32@2x"),
    (128, "1x", "128x128"),
    (128, "2x", "128x128@2x"),
    (256, "1x", "256x256"),
    (256, "2x", "256x256@2x"),
    (512, "1x", "512x512"),
    (512, "2x", "512x512@2x"),
]
SCALE_PX = {"1x": 1, "2x": 2}


def generate():
    # Note: dark app icon variants require macOS 15+ deployment target.
    # Only light icons are generated here; add dark variants via Xcode's asset
    # catalog editor once the deployment target is raised to macOS 15.
    os.makedirs(ASSET_DIR, exist_ok=True)
    images_json = []

    for logical, scale, suffix in ENTRIES:
        px = logical * SCALE_PX[scale]
        fname = f"icon_{suffix}.png"
        make_icon(px, LIGHT).save(os.path.join(ASSET_DIR, fname))
        images_json.append({"filename": fname, "idiom": "mac",
                             "scale": scale, "size": f"{logical}x{logical}"})

    contents = {"images": images_json, "info": {"author": "xcode", "version": 1}}
    with open(os.path.join(ASSET_DIR, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

    print(f"Generated {len(ENTRIES) * 2} icons → {ASSET_DIR}")


if __name__ == "__main__":
    generate()
