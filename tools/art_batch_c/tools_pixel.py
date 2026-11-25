# ART-16 revision 2 (user, 25 November 2026: "the tools should be pixel art"). The five bench tools, the
# vacuum's hose / clamp / dust bin and the cloth texture as pixel art, native half size, shown at 2x.
# The bench turns tools in 15-degree steps, so each tool comes as 24 pre-turned frames made the RotSprite
# way (enlarge with Scale2x three times, turn, reduce), then outlined and lit after turning so every frame
# keeps a clean 1 px outline and the light stays top-left.
# Tool frame (tool_rig.gd): origin = centre of the 60 x 84 box, working tip at Rig.TIP (-18, 24) logical.
# Native frames are 64 x 64 with the origin at (32, 32), so the tip is at (23, 44) in the unturned frame.
import os, sys, math, json
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))
from px import c, outline, light

N = 64
O = (32, 32)
STEPS = 24


def L(x, y):                         # tool-frame logical point -> native px
    return (O[0] + x / 2.0, O[1] + y / 2.0)


TIP = L(-18, 24)


def rod(d, a, b, w, col, hi=None, sh=None):
    d.line([a, b], fill=c(col), width=w)
    for p in (a, b):
        r = (w - 1) / 2.0
        d.ellipse((p[0] - r, p[1] - r, p[0] + r, p[1] + r), fill=c(col))
    if hi or sh:
        dx, dy = b[0] - a[0], b[1] - a[1]
        n = math.hypot(dx, dy) or 1
        nx, ny = -dy / n, dx / n                                     # left normal
        off = (w - 2) / 2.0
        if hi: d.line([(a[0] + nx * off, a[1] + ny * off), (b[0] + nx * off, b[1] + ny * off)], fill=c(hi), width=1)
        if sh: d.line([(a[0] - nx * off, a[1] - ny * off), (b[0] - nx * off, b[1] - ny * off)], fill=c(sh), width=1)


def canvas():
    im = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def vacuum():
    im, d = canvas()
    rod(d, L(10, -18), L(21, -31), 9, "#4f74a0", "#7fa4cc", "#34506f")         # grip body
    a = L(21, -31); d.ellipse((a[0] - 4, a[1] - 4, a[0] + 4, a[1] + 4), fill=c("#1f2226"))   # hose cuff
    rod(d, TIP, L(10, -18), 5, "#b9c3cb", "#e4eaee", "#7d8791")               # wand
    for t in (0.35, 0.6):
        q = (TIP[0] + (L(10, -18)[0] - TIP[0]) * t, TIP[1] + (L(10, -18)[1] - TIP[1]) * t)
        d.ellipse((q[0] - 3, q[1] - 3, q[0] + 3, q[1] + 3), fill=c("#6d7782"))  # ring joints
    d.ellipse((TIP[0] - 4, TIP[1] - 4, TIP[0] + 4, TIP[1] + 4), fill=c("#cfd8de"))   # nozzle mouth
    d.ellipse((TIP[0] - 2, TIP[1] - 2, TIP[0] + 2, TIP[1] + 2), fill=c("#0f1a22"))
    g = L(15, -24); d.rectangle((g[0] - 1, g[1] - 1, g[0] + 1, g[1] + 1), fill=c("#e0b84e"))   # switch
    return im


def brush():
    im, d = canvas()
    rod(d, L(-18, 8), L(18, -34), 6, "#b07a48", "#d39a63", "#7e5530")         # wooden handle
    h = L(14, -29); d.point(h, fill=c("#2a1d12"))                               # hanging hole
    y = L(0, 11)[1]
    d.rectangle((L(-38, 0)[0], y - 2, L(2, 0)[0], y + 2), fill=c("#b8c0c8"))    # ferrule across the tip
    d.line((L(-38, 0)[0], y - 2, L(2, 0)[0], y - 2), fill=c("#e6ebef"))
    d.line((L(-38, 0)[0], y + 2, L(2, 0)[0], y + 2), fill=c("#7d8793"))
    for x in range(int(L(-34, 0)[0]), int(L(0, 0)[0]), 4): d.line((x, y - 1, x, y + 1), fill=c("#8a939d"))
    return im


def pick():
    im, d = canvas()
    rod(d, L(-2, 4), L(20, -30), 5, "#c0904c", "#e2b56f", "#8a6430")          # handle
    for t in (0.3, 0.5, 0.7):
        a, b = L(-2, 4), L(20, -30)
        q = (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
        d.line((q[0] - 2, q[1] - 1, q[0] + 2, q[1] + 1), fill=c("#7d5a26"))   # grip ribs
    d.line([L(-2, 4), TIP], fill=c("#dfe4e6"), width=1)                          # steel hook
    d.line([TIP, (TIP[0] - 3, TIP[1] + 0.5)], fill=c("#dfe4e6"), width=1)
    return im


def syringe():
    im, d = canvas()
    rod(d, L(13, -19), L(24, -34), 2, "#a9b1b9")                                 # plunger rod
    rod(d, L(16, -38), L(31, -28), 2, "#c9d0d6")                                 # thumb pad
    rod(d, L(-9, 11), L(13, -19), 7, "#dfe6ea", "#f6f9fb", "#a9b7bf")            # barrel
    a, b = L(-9, 11), L(13, -19)
    q = (a[0] + (b[0] - a[0]) * 0.55, a[1] + (b[1] - a[1]) * 0.55)
    rod(d, a, q, 4, "#8f979e")                                                   # grey paste
    for t in (0.3, 0.5, 0.7):
        m = (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
        d.point((m[0] + 2, m[1] + 2), fill=c("#5d646c"))                         # marks, no numbers
    rod(d, TIP, L(-9, 11), 2, "#b8bec4")                                         # tip
    return im


def screwdriver():
    im, d = canvas()
    s1 = (TIP[0] + 4, TIP[1] - 8)
    rod(d, TIP, s1, 2, "#d3d9de")                                                # steel shaft
    h = (TIP[0] + 10.5, TIP[1] - 20)
    rod(d, s1, h, 6, "#d8453f", "#f08a85", "#9e2a26")                            # red handle
    for t in (0.35, 0.65):
        q = (s1[0] + (h[0] - s1[0]) * t, s1[1] + (h[1] - s1[1]) * t)
        d.line((q[0] - 2, q[1] - 1, q[0] + 2, q[1] + 1), fill=c("#8e2420"))
    return im


# ---- RotSprite ----

def scale2x(a):
    """EPX/Scale2x on an RGBA array (exact colour copies, no blending)."""
    H, W = a.shape[:2]
    p = np.pad(a, ((1, 1), (1, 1), (0, 0)), mode="edge")
    B, D, F, Hh, E = p[:-2, 1:-1], p[1:-1, :-2], p[1:-1, 2:], p[2:, 1:-1], p[1:-1, 1:-1]
    eq = lambda x, y: np.all(x == y, axis=2)
    cond = ~eq(B, Hh) & ~eq(D, F)
    out = np.zeros((H * 2, W * 2, 4), a.dtype)
    e0 = np.where((cond & eq(D, B))[..., None], D, E)
    e1 = np.where((cond & eq(B, F))[..., None], F, E)
    e2 = np.where((cond & eq(D, Hh))[..., None], D, E)
    e3 = np.where((cond & eq(Hh, F))[..., None], F, E)
    out[0::2, 0::2], out[0::2, 1::2], out[1::2, 0::2], out[1::2, 1::2] = e0, e1, e2, e3
    return out


def rotsprite(im, deg_clockwise):
    a = np.array(im)
    for _ in range(3): a = scale2x(a)
    big = Image.fromarray(a).rotate(-deg_clockwise, resample=Image.NEAREST, center=(O[0] * 8, O[1] * 8))
    b = np.array(big)
    small = b[4::8, 4::8]                                       # sample the centre of each 8 x 8 block
    return Image.fromarray(np.ascontiguousarray(small))


def frames(base):
    out = []
    for k in range(STEPS):
        r = base if k == 0 else rotsprite(base, k * 15)
        out.append(light(outline(r), 0.18, 0.26))
    return out


# ---- the vacuum's other pieces and the cloth ----

def hose_tile():
    im = Image.new("RGBA", (16, 12), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rectangle((0, 1, 15, 10), fill=c("#4a5662"))
    d.line((0, 2, 15, 2), fill=c("#7d8b98")); d.line((0, 9, 15, 9), fill=c("#2b3239"))
    for x in (0, 4, 8, 12): d.line((x, 1, x, 10), fill=c("#20262c")); d.line((x + 1, 3, x + 1, 8), fill=c("#6c7a87"))
    d.line((0, 0, 15, 0), fill=c("#14171b")); d.line((0, 11, 15, 11), fill=c("#14171b"))
    return im


def clamp():
    im = Image.new("RGBA", (44, 15), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle((1, 2, 42, 12), 3, fill=c("#7d8a95"))
    d.line((3, 3, 40, 3), fill=c("#b3bfc8")); d.line((3, 11, 40, 11), fill=c("#4f5a63"))
    d.ellipse((16, 1, 27, 13), fill=c("#2b3036")); d.ellipse((19, 4, 24, 10), fill=c("#121417"))
    for x in (6, 37): d.ellipse((x - 2, 5, x + 2, 9), fill=c("#c9d0d6"))
    return outline(im)


def bin_body():
    im = Image.new("RGBA", (36, 26), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle((1, 6, 34, 24), 2, fill=c("#3a4651"))
    d.rectangle((5, 10, 30, 16), fill=c("#9fd3c1")); d.rectangle((6, 11, 29, 15), fill=c("#78b39f"))
    d.line((2, 23, 33, 23), fill=c("#232a31"))
    d.rounded_rectangle((0, 2, 35, 7), 2, fill=c("#5c6a76")); d.line((2, 2, 33, 2), fill=c("#8796a3"))
    return outline(im)


def cloth_tile():
    T = 32
    im = Image.new("RGBA", (T, T), c("#e2dabc")); d = ImageDraw.Draw(im)
    for y in range(0, T, 4):
        d.line((0, y, T - 1, y), fill=c("#d2c9a8"))
        for x in range((y // 4) % 2 * 2, T, 4): d.point((x, y + 2), fill=c("#ece6cf"))
    return im


TOOLS = {"vacuum": vacuum, "brush": brush, "pick": pick, "syringe": syringe, "screwdriver": screwdriver}

if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for name, fn in TOOLS.items():
        fs = frames(fn())
        fs[0].save(os.path.join(out, f"tool_{name}.png"))
        sheet = Image.new("RGBA", (N * STEPS, N), (0, 0, 0, 0))
        for k, f in enumerate(fs): sheet.alpha_composite(f, (k * N, 0))
        sheet.save(os.path.join(out, f"tool_{name}_turns.png"))
    hose_tile().save(os.path.join(out, "hose_tile.png"))
    clamp().save(os.path.join(out, "hose_clamp.png"))
    bin_body().save(os.path.join(out, "dust_bin_body.png"))
    cloth_tile().save(os.path.join(out, "cloth_tile.png"))
    json.dump({"style": "pixel art, native half size, shown at exactly 2x", "frame": [N, N], "origin": list(O),
               "tip": [round(TIP[0], 1), round(TIP[1], 1)], "turn_frames": STEPS, "turn_step_degrees": 15,
               "turn_direction": "frame k = k x 15 degrees clockwise (Godot's positive angle)",
               "bristle_a": "#2c2a2a", "bristle_b": "#4a4744",
               "kept_from_rev1": ["fx_suction.png", "fx_dust_puff.png"]}, open(os.path.join(out, "tools_manifest.json"), "w"), indent=1)
    print("ok")
