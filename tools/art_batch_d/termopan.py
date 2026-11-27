# Termopan counter-room drafts (D174, user 27 Nov 2026): white PVC, clear glass, radiator under the window,
# linoleum floor. Layers on the Batch A source canvas (1672x941), in the Batch A look: thick dark outline,
# flat fills, a light edge top-left and a shade edge bottom-right, faint grime. Drafts only, not game art.
import random, sys, os
from PIL import Image, ImageDraw

W, H = 1672, 941
F = 1672 / 1280
def S(v): return int(round(v * F))

INK = (18, 20, 24, 255)
PVC = (233, 230, 219, 255); PVC_HI = (249, 248, 242, 255); PVC_SH = (199, 195, 181, 255); PVC_DK = (165, 160, 146, 255)
GASKET = (36, 36, 38, 255)
STEEL = (196, 200, 204, 255); STEEL_HI = (240, 242, 244, 255); STEEL_SH = (128, 132, 138, 255)
GLARE = (255, 255, 255, 34)

# Geometry (screen px from counter_art.gd, converted to source px)
FLOOR = S(505)
BLOCK = (S(52), S(106), S(604), FLOOR)          # outer frame of door + window
DOOR = (S(52), S(106), S(213), FLOOR)
SILL_Y = S(410)                                  # window sill: the radiator sits under it
WINDOW = (S(213), S(106), S(604), SILL_Y)
BOX = (S(44), S(56), S(612), S(106))
WS = (S(1062), S(118), S(1248), S(490))          # the painted workshop doorway
VP = (S(640), S(330))


def canvas(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))


def grime(im, box, n, seed, col=(150, 140, 116, 38)):
    rnd = random.Random(seed); d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = box
    for _ in range(n):
        x = rnd.randint(x0, x1 - 3); y = rnd.randint(y0, y1 - 3)
        r = rnd.choice((0, 1, 1, 1, 2))
        d.rectangle((x, y, x + r, y + r), fill=col)


def bevel_rect(d, box, fill, hi, sh, outline=INK, ow=3, edge=3):
    x0, y0, x1, y1 = box
    d.rectangle(box, fill=fill)
    d.rectangle((x0, y0, x1, y0 + edge), fill=hi); d.rectangle((x0, y0, x0 + edge, y1), fill=hi)
    d.rectangle((x0, y1 - edge, x1, y1), fill=sh); d.rectangle((x1 - edge, y0, x1, y1), fill=sh)
    d.rectangle(box, outline=outline, width=ow)


def pvc_ring(d, box, w):
    """A PVC frame profile of width w around an opening; the opening is left untouched (clear glass)."""
    x0, y0, x1, y1 = box
    for r in [(x0, y0, x1, y0 + w), (x0, y1 - w, x1, y1), (x0, y0, x0 + w, y1), (x1 - w, y0, x1, y1)]:
        d.rectangle(r, fill=PVC)
    d.rectangle((x0, y0, x1, y0 + 3), fill=PVC_HI); d.rectangle((x0, y0, x0 + 3, y1), fill=PVC_HI)
    d.rectangle((x0, y1 - 4, x1, y1), fill=PVC_SH); d.rectangle((x1 - 4, y0, x1, y1), fill=PVC_SH)
    ix0, iy0, ix1, iy1 = x0 + w, y0 + w, x1 - w, y1 - w
    d.rectangle((ix0 - 3, iy0 - 3, ix1 + 3, iy0), fill=PVC_SH)            # inner chamfer, shaded top
    d.rectangle((ix0 - 3, iy0 - 3, ix0, iy1 + 3), fill=PVC_SH)
    d.rectangle((ix0 - 3, iy1, ix1 + 3, iy1 + 3), fill=PVC_HI)
    d.rectangle((ix1, iy0 - 3, ix1 + 3, iy1 + 3), fill=PVC_HI)
    d.rectangle((ix0, iy0, ix1, iy1), outline=GASKET, width=3)            # black rubber gasket
    d.rectangle(box, outline=INK, width=3)
    d.rectangle((ix0 - 4, iy0 - 4, ix1 + 4, iy1 + 4), outline=INK, width=2)
    return (ix0 + 3, iy0 + 3, ix1 - 3, iy1 - 3)


def glare(im, box):
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(ov)
    x0, y0, x1, y1 = box
    for k, w in ((0.16, 30), (0.30, 12), (0.68, 44), (0.82, 14)):
        x = x0 + (x1 - x0) * k
        d.polygon([(x, y0), (x + w, y0), (x + w - (y1 - y0) * 0.35, y1), (x - (y1 - y0) * 0.35, y1)], fill=GLARE)
    m = Image.new("L", im.size, 0); ImageDraw.Draw(m).rectangle(box, fill=255)
    im.alpha_composite(Image.composite(ov, Image.new("RGBA", im.size, (0, 0, 0, 0)), m))


def lever(d, x, y, side=1, keyhole=True):
    """Termopan door handle: a narrow plate, a lever pointing away from the edge, the lock cylinder below."""
    d.rounded_rectangle((x - 9, y - 30, x + 9, y + 62), 6, fill=STEEL, outline=INK, width=2)
    d.line((x - 5, y - 26, x - 5, y + 58), fill=STEEL_HI, width=2)
    lx1 = x + side * 62
    d.rounded_rectangle((min(x, lx1) - 2, y - 7, max(x, lx1) + 2, y + 7), 6, fill=STEEL, outline=INK, width=2)
    d.line((min(x, lx1) + 4, y - 3, max(x, lx1) - 4, y - 3), fill=STEEL_HI, width=2)
    d.ellipse((x - 8, y - 8, x + 8, y + 8), fill=STEEL_SH, outline=INK, width=2)
    if keyhole:
        d.ellipse((x - 6, y + 32, x + 6, y + 44), fill=(30, 30, 32, 255))
        d.rectangle((x - 2, y + 40, x + 2, y + 52), fill=(30, 30, 32, 255))


def hinges(d, x, ys, side=-1):
    for y in ys:
        x0 = x if side > 0 else x - 10
        bevel_rect(d, (x0, y, x0 + 10, y + 34), PVC, PVC_HI, PVC_SH, ow=2, edge=2)


def door_leaf(im, box, handle_side, seed, keyhole=True):
    """A termopan door leaf: clear glass over a white panel, the handle on `handle_side` (+1 right, -1 left)."""
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = box
    glass = pvc_ring(d, box, S(26))
    panel_top = y0 + int((y1 - y0) * 0.60)
    # the mid rail and the lower panel (opaque white sandwich panel)
    bevel_rect(d, (glass[0] - 3, panel_top - S(12), glass[2] + 3, panel_top + S(4)), PVC, PVC_HI, PVC_SH, ow=2)
    p = (glass[0], panel_top + S(4), glass[2], glass[3])
    bevel_rect(d, p, (238, 236, 228, 255), PVC_SH, PVC_HI, ow=2)        # recessed: shade top-left
    d.rectangle((p[0] + 10, p[1] + 10, p[2] - 10, p[3] - 10), outline=PVC_SH, width=2)
    glare(im, (glass[0], glass[1], glass[2], panel_top - S(12)))
    d = ImageDraw.Draw(im)
    hx = x1 - S(14) if handle_side > 0 else x0 + S(14)
    lever(d, hx, y0 + int((y1 - y0) * 0.55), side=-handle_side, keyhole=keyhole)
    hinges(d, x0 if handle_side > 0 else x1, (y0 + S(40), y0 + int((y1 - y0) * 0.5), y1 - S(80)), side=-1 if handle_side > 0 else 1)
    grime(im, (x0 + 4, y0 + 4, x1 - 4, y1 - 4), 45, seed)


def open_leaf(im, hinge_x, top, bottom, width, toward, seed):
    """A leaf swung away from the viewer: seen edge-on, narrowing toward the vanishing point."""
    d = ImageDraw.Draw(im)
    fx = hinge_x + toward * width
    t = width / abs(VP[0] - hinge_x)
    ftop = top + (VP[1] - top) * t * 1.4
    fbot = bottom + (VP[1] - bottom) * t * 1.4
    outer = [(hinge_x, top), (fx, ftop), (fx, fbot), (hinge_x, bottom)]
    d.polygon(outer, fill=PVC, outline=INK)
    th = S(14)
    inner = [(hinge_x + toward * th * 0.9, top + th), (fx - toward * th * 0.6, ftop + th * 0.8), (fx - toward * th * 0.6, fbot - th * 0.8), (hinge_x + toward * th * 0.9, bottom - th)]
    mid = 0.60
    def lerp(a, b, k): return (a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k)
    gl = [inner[0], inner[1], lerp(inner[1], inner[2], mid - 0.03), lerp(inner[0], inner[3], mid - 0.03)]
    pn = [lerp(inner[0], inner[3], mid + 0.02), lerp(inner[1], inner[2], mid + 0.02), inner[2], inner[3]]
    mask = Image.new("L", im.size, 0); ImageDraw.Draw(mask).polygon(gl, fill=255)
    im.paste((0, 0, 0, 0), mask=mask)                                     # clear glass
    d = ImageDraw.Draw(im)
    d.polygon(gl, outline=GASKET)
    d.polygon(pn, fill=(226, 223, 212, 255), outline=PVC_DK)
    d.line([outer[1], outer[2]], fill=PVC_HI, width=4)                    # the leaf's edge catches the light
    d.line(outer + [outer[0]], fill=INK, width=3)
    grime(im, (int(min(hinge_x, fx)), int(top), int(max(hinge_x, fx)), int(bottom)), 25, seed)


# ---------------- layers ----------------

def front_frame():
    im = canvas(); d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = BLOCK
    fw = S(16)
    # outer frame: jambs to the floor on the door side, around the window above the sill
    for r in [(x0, y0, x1, y0 + fw), (x0, y0, x0 + fw, y1), (DOOR[2] - fw // 2, y0, DOOR[2] + fw // 2, y1), (x1 - fw, y0, x1, SILL_Y)]:
        bevel_rect(d, r, PVC, PVC_HI, PVC_SH, ow=3)
    # the window: two sashes, the right one tilt-and-turn with its handle
    wx0, wy0, wx1, wy1 = DOOR[2] + fw // 2, y0 + fw, x1 - fw, SILL_Y
    mid = (wx0 + wx1) // 2
    left = pvc_ring(d, (wx0, wy0, mid, wy1), S(16))
    right = pvc_ring(d, (mid, wy0, wx1, wy1), S(16))
    glare(im, left); glare(im, right); d = ImageDraw.Draw(im)
    hx = mid + S(8)
    d.rounded_rectangle((hx - 7, (wy0 + wy1) // 2 - 20, hx + 7, (wy0 + wy1) // 2 + 20), 4, fill=PVC_HI, outline=INK, width=2)
    d.rounded_rectangle((hx - 5, (wy0 + wy1) // 2 - 4, hx + 5, (wy0 + wy1) // 2 + 46), 4, fill=PVC, outline=INK, width=2)
    # the sill: a white PVC board sticking out a little, with its shadow on the wall
    d.rectangle((DOOR[2] + fw // 2 - 6, SILL_Y, x1 + 10, SILL_Y + S(10)), fill=PVC_HI, outline=INK, width=3)
    d.rectangle((DOOR[2] + fw // 2 - 2, SILL_Y + S(10) + 1, x1 + 6, SILL_Y + S(10) + 9), fill=(0, 0, 0, 70))
    grime(im, (x0, y0, x1, y1), 60, 11)
    return im


def front_door_closed():
    im = canvas()
    door_leaf(im, (DOOR[0] + S(14), DOOR[1] + S(14), DOOR[2] - S(6), DOOR[3]), +1, 21)
    return im


def front_door_open():
    im = canvas()
    open_leaf(im, DOOR[0] + S(14), DOOR[1] + S(14), DOOR[3], S(70), +1, 22)
    return im


def ws_frame_and_leaf(open_):
    im = canvas(); d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = WS
    fw = S(14)
    for r in [(x0, y0, x1, y0 + fw), (x0, y0, x0 + fw, y1), (x1 - fw, y0, x1, y1)]:
        bevel_rect(d, r, PVC, PVC_HI, PVC_SH, ow=3)
    leaf = (x0 + fw, y0 + fw, x1 - fw, y1 + S(30))
    if open_:
        open_leaf(im, leaf[2], leaf[1], leaf[3], S(60), -1, 32)
    else:
        door_leaf(im, leaf, -1, 31)                                     # handle and keyhole on the left, hinges right
    return im


def box_up():
    im = canvas(); d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = BOX
    bevel_rect(d, BOX, PVC, PVC_HI, PVC_SH, ow=3, edge=4)
    for k in range(1, 3): d.line((x0 + 6, y0 + k * (y1 - y0) // 3, x1 - 6, y0 + k * (y1 - y0) // 3), fill=PVC_SH, width=2)
    d.rectangle((x0 + 8, y1 - 9, x1 - 8, y1 - 3), fill=(40, 40, 42, 255))   # the slot
    for x in (x0, x1 - S(14)): bevel_rect(d, (x, y0, x + S(14), y1), PVC_HI, PVC_HI, PVC_SH, ow=3)   # end caps
    d.rounded_rectangle(((x0 + x1) // 2 - 22, y1 - 5, (x0 + x1) // 2 + 22, y1 + 8), 4, fill=PVC_SH, outline=INK, width=2)   # pull tab
    grime(im, BOX, 30, 41)
    return im


def shutter_down():
    im = box_up(); d = ImageDraw.Draw(im)
    x0, x1 = BOX[0] + 6, BOX[2] - 6
    y = BOX[3]
    slat = S(17)
    while y < FLOOR - slat:
        d.rectangle((x0, y, x1, y + slat), fill=(214, 209, 192, 255))
        d.line((x0, y + 2, x1, y + 2), fill=PVC_HI, width=2)
        d.line((x0, y + slat - 3, x1, y + slat - 3), fill=PVC_SH, width=2)
        d.line((x0, y + slat, x1, y + slat), fill=PVC_DK, width=2)
        for vx in range(x0 + 24, x1 - 24, 48): d.rectangle((vx, y + slat // 2 - 1, vx + 10, y + slat // 2 + 1), fill=(170, 165, 148, 255))
        y += slat
    bevel_rect(d, (x0, FLOOR - slat - 6, x1, FLOOR), (214, 210, 196, 255), PVC_HI, PVC_SH, ow=3)   # bottom bar
    d.rectangle(((x0 + x1) // 2 - 14, FLOOR - slat + 2, (x0 + x1) // 2 + 14, FLOOR - 6), fill=STEEL, outline=INK, width=2)   # lock
    for gx in (BOX[0], BOX[2] - S(12)): bevel_rect(d, (gx, BOX[3], gx + S(12), FLOOR), PVC, PVC_HI, PVC_SH, ow=3)   # guide rails
    d.rectangle((x0, BOX[3], x1, FLOOR), outline=INK, width=3)
    grime(im, (x0, BOX[3], x1, FLOOR), 90, 42)
    return im


def radiator():
    im = canvas(); d = ImageDraw.Draw(im)
    rx0, rx1 = S(250), S(560)
    ry0, ry1 = S(422), S(500)
    n = 16
    w = (rx1 - rx0) / n
    CREAM = (236, 228, 206, 255); CREAM_HI = (250, 246, 232, 255); CREAM_SH = (196, 186, 160, 255)
    d.rectangle((rx0 - 4, ry0 + 12, rx1 + 4, ry0 + 22), fill=CREAM_SH, outline=INK, width=2)     # top manifold
    for i in range(n):
        x = int(rx0 + i * w)
        d.rounded_rectangle((x + 2, ry0, int(x + w) - 2, ry1), 7, fill=CREAM, outline=INK, width=3)
        d.line((x + 6, ry0 + 6, x + 6, ry1 - 8), fill=CREAM_HI, width=3)
        d.line((int(x + w) - 6, ry0 + 8, int(x + w) - 6, ry1 - 6), fill=CREAM_SH, width=3)
    # the valve and the pipes going down behind the counter
    vx = rx1 + 8
    d.rectangle((vx, ry0 + 14, vx + 26, ry0 + 24), fill=(170, 140, 70, 255), outline=INK, width=2)
    d.ellipse((vx + 18, ry0 - 2, vx + 40, ry0 + 20), fill=(150, 40, 36, 255), outline=INK, width=2)
    d.rectangle((vx + 22, ry0 + 20, vx + 34, ry1 + 40), fill=CREAM_SH, outline=INK, width=2)
    d.rectangle((rx0 - 20, ry1 - 30, rx0 - 8, ry1 + 40), fill=CREAM_SH, outline=INK, width=2)
    d.rectangle((rx0 - 20, ry1 - 30, rx0 + 6, ry1 - 20), fill=CREAM_SH, outline=INK, width=2)
    # wall brackets' shadow behind it
    sh = Image.new("RGBA", im.size, (0, 0, 0, 0)); ImageDraw.Draw(sh).rectangle((rx0 + 8, ry0 + 8, rx1 + 8, ry1 + 6), fill=(0, 0, 0, 60))
    out = canvas(); out.alpha_composite(sh); out.alpha_composite(im)
    grime(out, (rx0, ry0, rx1, ry1), 120, 51, col=(150, 132, 96, 80))
    return out


def linoleum():
    im = canvas(); d = ImageDraw.Draw(im)
    BASE = (150, 112, 74, 255); ALT = (168, 128, 86, 255); LINE = (110, 80, 52, 255)
    d.rectangle((0, FLOOR, W, H), fill=BASE)
    # a square tile print in perspective toward the vanishing point
    rows = []
    z = 1.0
    y = FLOOR
    while y < H + 40:
        rows.append(y)
        z *= 0.86
        y = VP[1] + (FLOOR - VP[1]) / z
    cols = range(-40, 41)
    tile = S(120)
    for r in range(len(rows) - 1):
        ya, yb = rows[r], rows[r + 1]
        ka = (ya - VP[1]) / (FLOOR - VP[1]); kb = (yb - VP[1]) / (FLOOR - VP[1])
        for c in cols:
            xa0 = VP[0] + (c * tile - (VP[0] - 0) % tile) * ka; xa1 = VP[0] + ((c + 1) * tile - (VP[0] - 0) % tile) * ka
            xb0 = VP[0] + (c * tile - (VP[0] - 0) % tile) * kb; xb1 = VP[0] + ((c + 1) * tile - (VP[0] - 0) % tile) * kb
            if max(xa1, xb1) < 0 or min(xa0, xb0) > W: continue
            d.polygon([(xa0, ya), (xa1, ya), (xb1, yb), (xb0, yb)], fill=ALT if (r + c) % 2 else BASE, outline=LINE)
    rnd = random.Random(61)
    for _ in range(900):
        x = rnd.randint(0, W - 2); yy = rnd.randint(FLOOR, H - 2)
        d.point((x, yy), fill=(120, 88, 58, 255) if rnd.random() < 0.6 else (190, 150, 104, 255))
    d.line((0, FLOOR, W, FLOOR), fill=INK, width=3)
    # a worn path toward the counter
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); ImageDraw.Draw(ov).ellipse((S(-60), FLOOR + 30, S(260), H + 120), fill=(220, 200, 170, 40))
    im.alpha_composite(ov)
    return im


LAYERS = {
    "termopan-front-frame": front_frame, "termopan-front-door-closed": front_door_closed, "termopan-front-door-open": front_door_open,
    "termopan-workshop-closed": lambda: ws_frame_and_leaf(False), "termopan-workshop-open": lambda: ws_frame_and_leaf(True),
    "pvc-shutter-up": box_up, "pvc-shutter-down": shutter_down, "radiator": radiator, "floor-linoleum": linoleum,
}

if __name__ == "__main__":
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    for name, fn in LAYERS.items(): fn().save(os.path.join(out, name + ".png"))
    print("ok")
