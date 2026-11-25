# ART-16: repair-tool skins for the bench close-up, comic-book semi-realistic like the hardware (they are
# turned freely in 15-degree steps, which pixel art cannot survive). Each sprite is drawn in the tool's
# OWN frame from tool_rig.gd / tool_renderer.gd: the 60 x 84 box centred on the origin, the working tip at
# Rig.TIP (-18, 24), the handle running up-right. Sprites are 2x masters (160 x 200): origin at (80, 100),
# tip at (44, 148); the game draws them at half size with its existing transform. Geometry that moves
# (brush bristles, the cloth's outline, the hose) stays code-drawn; for those this file gives textures:
# a tileable cloth, a tileable hose and colours for the bristles. Plus the hose clamp, the dust-bin body
# and two effect sprites (suction glow, dust puff).
import os, sys, math, random
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))   # shared comic/pixel helpers
import parts_comic as pc

FW, FH = 160, 200                 # 2x masters with a margin: the thumb pad and hose cuff reach past the 60 x 84 box
O = (80, 100)


def L(x, y):                      # tool-frame logical point -> sprite master px
    return (O[0] + x * 2, O[1] + y * 2)


TIP = L(-18, 24)


def pen():
    pc.S = 4
    return pc.Pen(FW, FH)


def fin(p):
    im = pc.light_pass(p.im)
    im = pc.ink_outline(im, 1.4)
    return im.resize((FW, FH), Image.LANCZOS)


def bar(p, a, b, width, c0, c1, ink=1.4, cap=True):
    """A rod from a to b (master px): a polygon with a lengthwise two-tone shade."""
    ax, ay = a; bx, by = b
    dx, dy = bx - ax, by - ay
    n = math.hypot(dx, dy) or 1
    nx, ny = -dy / n * width / 2, dx / n * width / 2
    p.poly([(ax + nx, ay + ny), (bx + nx, by + ny), (bx - nx, by - ny), (ax - nx, ay - ny)], c1, ink)
    p.poly([(ax + nx, ay + ny), (bx + nx, by + ny), (bx + nx * 0.1, by + ny * 0.1), (ax + nx * 0.1, ay + ny * 0.1)], c0, 0)
    if cap:
        r = width / 2
        p.ell((bx - r, by - r, bx + r, by + r), c1, ink)


def vacuum():
    p = pen()
    bar(p, L(10, -18), L(21, -31), 40, "#5b86ad", "#33597d")                       # grip body
    p.ell((L(21, -31)[0] - 16, L(21, -31)[1] - 16, L(21, -31)[0] + 16, L(21, -31)[1] + 16), "#1c1e22", 1.4)   # hose cuff
    bar(p, TIP, L(10, -18), 26, "#e4eaee", "#8f99a3", cap=False)                   # wand
    for t in (0.35, 0.55):
        a = (TIP[0] + (L(10, -18)[0] - TIP[0]) * t, TIP[1] + (L(10, -18)[1] - TIP[1]) * t)
        p.ell((a[0] - 15, a[1] - 15, a[0] + 15, a[1] + 15), "#6d7782", 1.0)        # ring joints
    p.ell((TIP[0] - 20, TIP[1] - 20, TIP[0] + 20, TIP[1] + 20), "#cfd8de", 1.6)    # nozzle mouth
    p.ell((TIP[0] - 12, TIP[1] - 12, TIP[0] + 12, TIP[1] + 12), "#0f1a22", 1.0)
    g = L(15, -24); p.rect((g[0] - 6, g[1] - 6, g[0] + 6, g[1] + 6), "#e0b84e", 1.0, r=2)   # switch
    p.glint(TIP[0] + 12, TIP[1] - 30, 12, 1.6)
    return fin(p)


def brush():
    p = pen()
    root = L(-18, 8)                                                                 # tip + (0, -16)
    bar(p, root, L(18, -34), 26, "#d39a63", "#9a6a3c")                              # wooden handle
    hole = L(14, -29); p.ell((hole[0] - 4, hole[1] - 4, hole[0] + 4, hole[1] + 4), "#2a1d12", 0.8)
    a, b = L(-38, 11), L(2, 11)                                                      # ferrule across tip + (-20..20, -13)
    p.grad((a[0], a[1] - 9, b[0], b[1] + 9), "#e6ebef", "#7d8793", 1.6, r=3)
    for x in range(a[0] + 10, b[0] - 4, 12): p.line([(x, a[1] - 8), (x, a[1] + 8)], "#8a939d", 1.0)   # crimps
    p.glint(a[0] + 6, a[1] - 2, 14, 1.4)
    return fin(p)


def pick():
    p = pen()
    bar(p, L(-2, 4), L(20, -30), 22, "#d9b06a", "#9f7436")                           # handle
    for t in (0.25, 0.4, 0.55, 0.7):
        a, b = L(-2, 4), L(20, -30)
        c = (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
        p.line([(c[0] - 9, c[1] - 6), (c[0] + 9, c[1] + 6)], "#7d5a26", 1.4)        # grip ribs
    p.line([L(-2, 4), TIP, (TIP[0] - 12, TIP[1] + 2)], pc.INK, 7.0)                   # steel hook
    p.line([L(-2, 4), TIP, (TIP[0] - 12, TIP[1] + 2)], "#dfe4e6", 4.0)
    p.line([L(-3, 5), (TIP[0] + 2, TIP[1] - 2)], "#ffffff", 1.2)
    return fin(p)


def syringe():
    p = pen()
    bar(p, L(13, -19), L(24, -34), 10, "#c9d0d6", "#8f98a1")                         # plunger rod
    bar(p, L(16, -38), L(31, -28), 10, "#d9dfe4", "#9aa3ac")                         # thumb pad
    bar(p, L(-9, 11), L(13, -19), 30, "#eef3f6", "#b9c7cf")                          # barrel
    a, b = L(-9, 11), L(13, -19)
    c = (a[0] + (b[0] - a[0]) * 0.55, a[1] + (b[1] - a[1]) * 0.55)
    bar(p, a, c, 18, "#a3abb3", "#7d858d", ink=0.8, cap=False)                       # grey paste inside
    for t in (0.2, 0.35, 0.5, 0.65, 0.8):
        q = (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
        p.line([(q[0] + 6, q[1] + 4), (q[0] + 12, q[1] + 8)], "#5d646c", 1.2)        # marks, no numbers
    bar(p, TIP, L(-9, 11), 9, "#cfd6dc", "#8f98a1", cap=False)                       # tip
    p.glint(c[0] - 14, c[1] - 6, 10, 1.4)
    return fin(p)


def screwdriver():
    p = pen()
    s1 = (TIP[0] + 16, TIP[1] - 32)
    bar(p, TIP, s1, 7, "#e6ebef", "#9aa3ac", cap=False)                              # steel shaft
    h = (TIP[0] + 42, TIP[1] - 80)
    bar(p, s1, h, 26, "#ef6a63", "#b8322d")                                          # red handle
    for t in (0.3, 0.5, 0.7):
        q = (s1[0] + (h[0] - s1[0]) * t, s1[1] + (h[1] - s1[1]) * t)
        p.line([(q[0] - 10, q[1] - 5), (q[0] + 10, q[1] + 5)], "#8e2420", 1.4)
    p.glint(s1[0] + 2, s1[1] - 10, 14, 1.6)
    return fin(p)


def cloth_tile():
    """Tileable microfibre texture for the code-drawn cloth (128 x 128, wraps on all sides)."""
    T = 128
    im = Image.new("RGBA", (T, T), (226, 218, 188, 255))
    d = ImageDraw.Draw(im)
    rnd = random.Random(7)
    for _ in range(900):
        x, y = rnd.randrange(T), rnd.randrange(T)
        c = rnd.choice([(212, 203, 172), (236, 229, 202), (204, 195, 163)])
        for ox in (-T, 0, T):
            for oy in (-T, 0, T):
                d.line((x + ox, y + oy, x + ox + rnd.choice([-2, 2]), y + oy + 1), fill=c + (255,))
    for k in range(0, T, 16):                                                         # a soft woven ridge
        d.line((0, k, T, k), fill=(206, 197, 166, 255))
    return im


def hose_tile():
    """Tileable corrugated hose (repeats along x; 32 x 24 master), for a textured line along the hose."""
    W, H = 32, 24
    pc.S = 8
    p = pc.Pen(W, H)
    p.grad((0, 2, W, H - 3), "#5e6b77", "#252b31", 0, angle=0)
    for x in range(0, W + 1, 8):
        p.line([(x, 2), (x, H - 3)], "#1b1f24", 2.0)
        p.line([(x + 3, 4), (x + 3, H - 6)], "#8796a3", 1.0)
    im = p.im.resize((W, H), Image.LANCZOS)
    return im


def clamp():
    W, H = 176, 60                                                                   # BENCH_CLAMP 88 x 30, at 2x
    pc.S = 4
    p = pc.Pen(W, H)
    p.grad((6, 10, W - 7, H - 9), "#9aa6b0", "#56616b", 1.6, r=10)
    p.ell((W / 2 - 24, 6, W / 2 + 24, H - 6), "#2b3036", 1.4)
    p.ell((W / 2 - 14, 16, W / 2 + 14, H - 16), "#121417", 0)
    for x in (22, W - 22): p.ell((x - 8, H / 2 - 8, x + 8, H / 2 + 8), "#c9d0d6", 1.0)
    p.glint(16, 18, 20, 1.6)
    return fin_simple(p, W, H)


def bin_body():
    W, H = 144, 104                                                                  # BENCH_BIN 72 x 52, at 2x
    pc.S = 4
    p = pc.Pen(W, H)
    p.grad((4, 26, W - 5, H - 5), "#48545f", "#232a31", 1.8, r=8, angle=0.4)
    p.rect((16, 40, W - 16, 64), "#a9d9c8", 1.0, r=4)                                 # clear window (the fill shows here)
    p.rect((20, 44, W - 20, 60), "#7fb7a4", 0, r=3)
    p.grad((0, 8, W - 1, 30), "#6c7a86", "#3c4651", 1.6, r=6)                       # lid rim
    p.glint(12, 16, 22, 1.6)
    return fin_simple(p, W, H)


def fin_simple(p, W, H):
    im = pc.light_pass(p.im)
    im = pc.ink_outline(im, 1.2)
    return im.resize((W, H), Image.LANCZOS)


def suction_glow():
    T = 128
    yy, xx = np.mgrid[0:T, 0:T]
    r = np.hypot(xx - T / 2 + 0.5, yy - T / 2 + 0.5) / (T / 2)
    a = np.clip(1 - r, 0, 1) ** 1.6 * 150
    ring = np.exp(-((r - 0.55) / 0.06) ** 2) * 90
    img = np.zeros((T, T, 4), np.uint8)
    img[..., 0], img[..., 1], img[..., 2] = 210, 236, 255
    img[..., 3] = np.clip(a * 0.5 + ring, 0, 255).astype(np.uint8)
    return Image.fromarray(img)


def dust_puff():
    W = H = 96
    pc.S = 4
    p = pc.Pen(W, H)
    for (x, y, r) in [(30, 54, 20), (50, 40, 24), (68, 56, 18), (46, 64, 18)]:
        p.ell((x - r, y - r, x + r, y + r), "#e6dcc4", 1.4)
    for (x, y, r) in [(36, 48, 8), (54, 36, 9)]:
        p.ell((x - r, y - r, x + r, y + r), "#f6f0e2", 0)
    for (x, y) in [(14, 30), (82, 28), (86, 70), (12, 76)]:
        p.ell((x - 3, y - 3, x + 3, y + 3), "#d7c9a8", 0.8)
    im = pc.ink_outline(p.im, 1.0).resize((W, H), Image.LANCZOS)
    a = np.array(im); a[..., 3] = (a[..., 3] * 0.85).astype(np.uint8)
    return Image.fromarray(a)


BRISTLES = {"bristle_a": "#2c2a2a", "bristle_b": "#4a4744", "note": "brush bristles stay code-drawn (brush_shape.gd); use these two colours instead of the old tan pair"}

if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for n, fn in [("vacuum", vacuum), ("brush", brush), ("pick", pick), ("syringe", syringe), ("screwdriver", screwdriver)]:
        fn().save(os.path.join(out, f"tool_{n}.png"))
    cloth_tile().save(os.path.join(out, "cloth_tile.png"))
    hose_tile().save(os.path.join(out, "hose_tile.png"))
    clamp().save(os.path.join(out, "hose_clamp.png"))
    bin_body().save(os.path.join(out, "dust_bin_body.png"))
    suction_glow().save(os.path.join(out, "fx_suction.png"))
    dust_puff().save(os.path.join(out, "fx_dust_puff.png"))
    import json
    json.dump({"frame": [FW, FH], "origin": list(O), "tip": list(TIP), "scale_in_game": 0.5, **BRISTLES}, open(os.path.join(out, "tools_manifest.json"), "w"), indent=1)
    print("ok")
