# Batch C additions for review (25 November 2026):
# 1. Two power connectors, kept clean (user: "Add connectors (only 2 kinds for now), but make sure they look
#    clean"): the 24-pin motherboard cable and the 8-pin graphics-card cable. Sleeved black cables, tidy
#    combs, plugs seen from above. Tileable cable textures for code-drawn routes (Line2D, tile mode), the
#    plugs and combs as sprites. Comic-book semi-realistic like the hardware; master 64 px per cell.
# 2. The case lying open on its side (user: the repair bench shows the PC "lying on its side, open"):
#    the inner walls with depth around the case interior, as an overlay on ART-14's case picture.
import os, sys, math
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))
import parts_comic as pc

U = 64


def cable_tile(width, length=32):
    """Sleeved cable bundle, tileable along x. width px across."""
    pc.S = 8
    p = pc.Pen(length, width + 4)
    p.grad((0, 2, length, width + 1), "#3a3d44", "#121316", 0, angle=0)
    for x in range(-width, length + width, 4):                     # braided sleeve weave
        p.line([(x, 3), (x + width * 0.7, width)], (90, 96, 106, 150), 0.8)
        p.line([(x + width * 0.7, 3), (x, width)], (24, 26, 30, 170), 0.8)
    p.line([(0, 3.5), (length, 3.5)], (150, 158, 170, 170), 1.0)   # top highlight
    p.line([(0, 2), (length, 2)], pc.INK, 1.2); p.line([(0, width + 1), (length, width + 1)], pc.INK, 1.2)
    return p.im.resize((length, width + 4), Image.LANCZOS)


def plug_24():
    """The 24-pin plug seated in the board's power connector, seen from above, with its comb."""
    W, H = 196, 132                                                # the psu_bay footprint is 3 x 2 cells
    pc.S = 4
    p = pc.Pen(W, H)
    p.grad((8, 26, 188, 104), "#2c2f35", "#101114", 1.6, r=5, angle=0.3)   # plug housing
    for r_ in range(2):
        for k in range(12):
            x = 16 + k * 14; y = 36 + r_ * 32
            p.rect((x, y, x + 11, y + 24), "#1a1b1f", 0.8, r=3)
            p.ell((x + 2, y + 6, x + 9, y + 13), "#3e434b", 0)    # wire entries
    p.rect((86, 14, 110, 28), "#2c2f35", 1.2, r=3)                # latch
    p.line([(16, 30), (180, 30)], (150, 158, 170, 140), 1.0)
    return pc.ink_outline(pc.light_pass(p.im), 1.2).resize((W, H), Image.LANCZOS)


def plug_8():
    W, H = 52, 34
    pc.S = 8
    p = pc.Pen(W, H)
    p.grad((4, 6, 48, 28), "#2c2f35", "#101114", 1.4, r=3, angle=0.3)
    for r_ in range(2):
        for k in range(4):
            x = 8 + k * 10; y = 9 + r_ * 9
            p.rect((x, y, x + 8, y + 7), "#1a1b1f", 0.6, r=2)
    p.rect((20, 1, 32, 7), "#2c2f35", 1.0, r=2)
    return pc.ink_outline(pc.light_pass(p.im), 1.0).resize((W, H), Image.LANCZOS)


def comb(width):
    W, H = 14, width + 12
    pc.S = 8
    p = pc.Pen(W, H)
    p.grad((2, 1, 12, H - 2), "#5b6470", "#2c3138", 1.2, r=3)
    for y in range(5, H - 4, 5): p.line([(4, y), (10, y)], "#1b1e22", 0.8)
    return pc.ink_outline(p.im, 0.8).resize((W, H), Image.LANCZOS)


def case_walls():
    """Inner walls of the tower case lying open on its side, seen from above (overlay, 18 x 16 cells)."""
    W, H = 18 * U, 16 * U
    pc.S = 3
    p = pc.Pen(W, H)
    t = 26                                                          # how much of each wall face shows
    o = 6
    p.poly([(o, o), (W - o, o), (W - o - t, o + t), (o + t, o + t)], "#7d8793", 0)            # top wall face (lit)
    p.poly([(o, o), (o + t, o + t), (o + t, H - o - t), (o, H - o)], "#6c7682", 0)            # left wall face (lit)
    p.poly([(W - o, o), (W - o, H - o), (W - o - t, H - o - t), (W - o - t, o + t)], "#3a414b", 0)   # right (shade)
    p.poly([(o, H - o), (W - o, H - o), (W - o - t, H - o - t), (o + t, H - o - t)], "#2f353e", 0)   # bottom (shade)
    for a, b in [((o, o), (o + t, o + t)), ((W - o, o), (W - o - t, o + t)), ((o, H - o), (o + t, H - o - t)), ((W - o, H - o), (W - o - t, H - o - t))]:
        p.line([a, b], pc.INK, 1.4)                                  # corner creases
    p.d.rounded_rectangle(p._b((o, o, W - o, H - o)), 10 * pc.S, outline=pc.C("#c9d0d6"), width=3 * pc.S)   # cut rim where the side panel was
    p.d.rounded_rectangle(p._b((o + t, o + t, W - o - t, H - o - t)), 4 * pc.S, outline=pc.INK, width=2 * pc.S)
    for x in range(80, W - 80, 160):                                 # screw holes along the rim
        for y in (o + 10, H - o - 10):
            p.ell((x - 4, y - 4, x + 4, y + 4), "#22262b", 0)
    p.glint(40, 18, 40, 1.4)
    im = pc.ink_outline(p.im, 1.0)
    return im.resize((W, H), Image.LANCZOS)


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    cable_tile(38).save(os.path.join(out, "cable_24pin_tile.png"))
    cable_tile(16).save(os.path.join(out, "cable_8pin_tile.png"))
    plug_24().save(os.path.join(out, "plug_24pin.png"))
    plug_8().save(os.path.join(out, "plug_8pin.png"))
    comb(38).save(os.path.join(out, "comb_24pin.png"))
    comb(16).save(os.path.join(out, "comb_8pin.png"))
    case_walls().save(os.path.join(out, "case_tower_walls.png"))
    print("ok")
