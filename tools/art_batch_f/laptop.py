# 0.59.1 (D185): laptop drafts. The user, 28 November 2026: "add laptops. they take up less space than a
# desktop and you can choose to store them on top of eachother or on top of desktops. you cannot change the
# case or the motherboard for a laptop ... artwork is also needed, so generate a few artworks of what the
# laptops would look like in game ... mara comes in with a laptop".
#
# The same two looks as the desktops:
#   - pixel art (storage seen from above, 22 px per cell, shown at 2x; the counter prop, shown at RoomArt
#     PIXEL_SCALE), drawn with tools/art_batch_b/px.py;
#   - comic-book, semi-realistic hardware (the open laptop on the repair and hardware benches), drawn with
#     tools/art_batch_b/parts_comic.py at 64 px per cell, exactly on the cells of PCLayout.profile("laptop"):
#       chassis 16 x 10 cells; board at (4, 1), 11 x 5; CPU/heatsink at board (1, 1), 3 x 3; RAM 1/2 at board
#       (6, 0)/(6, 1), 4 x 1 lying; drive slot at board (6, 3), 2 x 1; blower fan (1, 1) 3 x 3; exhaust fins
#       (0, 1) 1 x 3; battery (2, 7) 12 x 2.
# Nothing here is loaded by the game until the user approves an exact revision (AGENTS rule 11).
#   python3 -I tools/art_batch_f/laptop.py <out dir>            drafts + review mocks
#   python3 -I tools/art_batch_f/laptop.py --runtime <art dir>  only after approval: the runtime files
import os, sys, json, math, random, hashlib
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(HERE, "..", "art_batch_b"))
from px import canvas, c, mix, outline, light, OUT   # noqa: E402
import parts_comic as pc                             # noqa: E402

CELL = 22            # storage pixel art: native px per cell (shown at 2x)
U = 64               # comic hardware: px per cell (master)
INK = pc.INK
FOOT = (6, 4)        # storage footprint in cells: fits fully on a compact (7 x 5) and a tower (8 x 6)

FINISHES = {
    # Mara's: a cheap silver-beige office laptop of the early 2000s.
    "silver": {"lid": "#b9b4a6", "lid_hi": "#d6d1c3", "lid_lo": "#97927f", "edge": "#7d786a", "badge": "#8d8878", "hinge": "#5c5a55"},
    # Generated customers: a graphite one.
    "graphite": {"lid": "#3e434b", "lid_hi": "#555b64", "lid_lo": "#2c3036", "edge": "#24272c", "badge": "#5d636c", "hinge": "#1c1e22"},
}


# ---------------- storage: the closed laptop seen from above (pixel art) ----------------

def storage(finish):
    f = FINISHES[finish]
    w, h = FOOT[0] * CELL, FOOT[1] * CELL
    im, d = canvas(w, h)
    d.rounded_rectangle((3, 6, w - 4, h - 5), 4, fill=c(f["edge"]))                 # base edge peeking out
    d.rounded_rectangle((3, 4, w - 4, h - 8), 4, fill=c(f["lid"]))                  # lid
    d.rectangle((8, 4, w - 9, 9), fill=c(f["hinge"]))                               # hinge barrel along the back
    d.line((8, 9, w - 9, 9), fill=c(f["lid_lo"]))
    for x in (12, w - 16):
        d.rectangle((x, 5, x + 3, 8), fill=c(f["lid_lo"]))                          # hinge knuckles
    d.rectangle((10, 13, w - 11, h - 13), outline=c(f["lid_lo"]))                   # pressed lid panel
    for k in range(0, 46, 3):                                                       # brushed sheen
        d.point((22 + k, 16 + k // 3), fill=c(f["lid_hi"]))
        d.point((24 + k, 16 + k // 3), fill=c(f["lid_hi"]))
    cx, cy = w // 2, (h - 4) // 2 + 2
    d.rounded_rectangle((cx - 7, cy - 5, cx + 7, cy + 5), 2, fill=c(f["badge"]))   # blank brand badge, no text
    d.rounded_rectangle((cx - 4, cy - 2, cx + 4, cy + 2), 1, fill=c(f["lid_lo"]))
    d.rectangle((w - 22, h - 9, w - 8, h - 7), fill=c(f["lid_lo"]))                 # lid lip at the front
    for i, col in enumerate(("#7fd18a", "#d9b25a", "#3a3d44")):
        d.point((10 + i * 4, h - 6), fill=c(col))                                   # status LEDs on the front edge
    d.line((w - 30, h - 9, w - 30, h - 5), fill=c("#c8b27a"))                       # repair tag on its string
    d.polygon([(w - 34, h - 5), (w - 22, h - 5), (w - 19, h - 2), (w - 22, h + 1), (w - 34, h + 1)], fill=c("#e2d8bd"))
    return im


def storage_turned(finish, rot):
    a = np.rot90(np.array(storage(finish)), -rot)
    im = Image.fromarray(np.ascontiguousarray(a))
    return light(outline(im), 0.18, 0.28)


# ---------------- the counter prop: a closed laptop lying on the counter (pixel art) ----------------

def counter_prop(finish):
    f = FINISHES[finish]
    im, d = canvas(78, 30)
    # three-quarter view: the lid's top face (a skewed quad), then the front edge of lid + base
    top = [(10, 4), (72, 4), (66, 18), (4, 18)]
    d.polygon(top, fill=c(f["lid"]))
    d.line((10, 4, 72, 4), fill=c(f["lid_hi"]))
    d.line((12, 5, 70, 5), fill=c(f["hinge"]))                                      # hinge barrel at the back
    for k in range(0, 34, 2):
        d.point((22 + k, 8 + k // 6), fill=c(f["lid_hi"]))                          # sheen
    d.polygon([(34, 9), (44, 9), (42, 13), (32, 13)], fill=c(f["badge"]))           # blank badge
    d.polygon([(4, 18), (66, 18), (66, 21), (4, 21)], fill=c(f["lid_lo"]))          # lid front edge
    d.polygon([(4, 21), (66, 21), (66, 25), (4, 25)], fill=c(f["edge"]))            # base front
    d.line((66, 18, 72, 4), fill=c(f["lid_lo"]))
    d.polygon([(66, 18), (72, 4), (72, 11), (66, 25)], fill=c(f["edge"]))           # right side
    d.rectangle((26, 22, 44, 23), fill=c(f["lid_lo"]))                              # finger notch
    for i, col in enumerate(("#7fd18a", "#3a3d44")):
        d.point((9 + i * 3, 23), fill=c(col))                                       # LEDs
    d.rectangle((6, 25, 10, 26), fill=c("#1b1d21")); d.rectangle((58, 25, 62, 26), fill=c("#1b1d21"))   # feet
    d.line((48, 22, 52, 27), fill=c("#c8b27a"))                                     # repair tag
    d.polygon([(50, 26), (60, 26), (62, 28), (60, 30), (50, 30)], fill=c("#e2d8bd"))
    return outline(im)


# ---------------- comic hardware: the laptop open on the bench ----------------

def cells(x0, y0, x1, y1):
    return (x0 * U, y0 * U, x1 * U, y1 * U)


def finish_comic(p, lit=True):
    im = p.im
    if lit: im = pc.light_pass(im)
    return pc.ink_outline(im, 1.2)


def chassis():
    """The base with its bottom cover off: plastic tub, magnesium frame, blower-fan bay, exhaust fins,
    battery, speakers, hinge mounts, DC jack, ribbon connectors, screw posts. Board/heatsink/fan are
    separate pictures drawn over it (the fan by the game's own rotor)."""
    old = pc.S; pc.S = 3
    try:
        W, H = 16 * U, 10 * U
        p = pc.Pen(W, H)
        p.grad((0, 0, W - 1, H - 1), "#4b4f57", "#26292e", 0, r=26, angle=0.5)            # outer shell
        p.grad((12, 12, W - 13, H - 13), "#34383f", "#1d2024", 1.6, r=18, angle=0.6)      # inner tub
        rnd = random.Random(61)
        for _ in range(40):                                                                 # moulded ribs
            x = rnd.randrange(30, W - 30); y = rnd.randrange(6 * U + 40, H - 30)
            p.line([(x, y), (x + rnd.randrange(20, 60), y)], (60, 64, 72, 160), 0.8)
        # hinge mounts along the back edge (row 0)
        for x0 in (40, W - 140):
            p.grad((x0, 8, x0 + 100, 52), "#8c939b", "#4a5058", 1.4, r=6, angle=0.3)
            for k in range(3): p.ell((x0 + 16 + k * 32 - 7, 22, x0 + 16 + k * 32 + 7, 36), "#c9b98a", 0.8)
        # blower fan bay (1,1) 3x3: a round well with a housing lip; the game draws the rotor on top
        fb = cells(1, 1, 4, 4)
        p.grad((fb[0] + 6, fb[1] + 6, fb[2] - 6, fb[3] - 6), "#202328", "#0f1013", 1.4, shape="ellipse")
        p.ring((fb[0] + 14, fb[1] + 14, fb[2] - 14, fb[3] - 14), "#3c4048", 1.2)
        p.poly([(fb[0] + 4, fb[1] + U * 1.2), (fb[0] - 6 + 10, fb[1] + U * 1.0), (fb[0] + 10, fb[1] + U * 2.2), (fb[0] + 4, fb[1] + U * 2.0)], "#2b2f35", 1.0)
        # exhaust fins (0,1) 1x3 beside the fan: thin copper fin stack behind a grille
        ex = cells(0, 1, 1, 4)
        p.grad((ex[0] + 10, ex[1] + 4, ex[2] + 4, ex[3] - 4), "#c58b5a", "#7a4f2d", 1.2, r=3, angle=1.4)
        for y in range(ex[1] + 10, ex[3] - 8, 6): p.line([(ex[0] + 12, y), (ex[2] + 2, y)], "#5a3a22", 1.0)
        # board tray outline (4,1) 11x5: standoffs; the board picture covers it
        bt = cells(4, 1, 15, 6)
        p.rect((bt[0] - 4, bt[1] - 4, bt[2] + 4, bt[3] + 4), "#17191c", 1.0, r=6)
        for (cx, cy) in [(4, 1), (15, 1), (4, 6), (15, 6), (9, 1), (9, 6)]:
            p.ell((cx * U - 9, cy * U - 9, cx * U + 9, cy * U + 9), "#c9b98a", 0.8)
        # battery (2,7) 12x2: a flat pack with a blank label and its cable to the board
        bb = cells(2, 7, 14, 9)
        p.grad((bb[0], bb[1], bb[2], bb[3]), "#2a2d33", "#15171a", 1.6, r=10, angle=0.2)
        for k in range(4):
            x = bb[0] + 40 + k * 3 * U
            p.rect((x, bb[1] + 18, x + 2 * U + 40, bb[3] - 18), "#22252a", 0.8, r=6)       # cell bumps
        p.rect((bb[0] + 5 * U, bb[1] + 26, bb[0] + 8 * U, bb[3] - 26), "#e9e6dc", 0.8, r=3)  # blank label
        for x in range(bb[0] + 5 * U + 10, bb[0] + 8 * U - 10, 4):
            p.line([(x, bb[1] + 34), (x, bb[1] + 46 + (x % 3) * 2)], "#6a6a66", 0.6)
        p.line([(bb[2] - 30, bb[1]), (bb[2] - 30, 6 * U + 10)], "#d04848", 2.4)               # battery leads
        p.line([(bb[2] - 22, bb[1]), (bb[2] - 22, 6 * U + 10)], "#1b1c20", 2.4)
        # speakers in the front corners, DC jack and USB at the side
        for x0 in (12, W - 2 * U + 8):
            p.grad((x0 + 10, 7 * U + 20, x0 + U + 30, 9 * U + 30), "#24272c", "#121316", 1.2, r=10)
            for yy in range(7 * U + 36, 9 * U + 20, 10):
                for xx in range(x0 + 22, x0 + U + 22, 10): p.ell((xx - 3, yy - 3, xx + 3, yy + 3), "#0b0c0e", 0)
        p.grad((W - 40, 2 * U, W - 10, 2 * U + 46), "#9aa2aa", "#5b636b", 1.2, r=4)          # DC jack
        p.ell((W - 32, 2 * U + 14, W - 18, 2 * U + 28), "#141518", 0)
        for k in range(2): p.rect((W - 34, 3 * U + k * 40, W - 12, 3 * U + 24 + k * 40), "#1b1e22", 1.0, r=2)   # USB
        # ribbon connectors (keyboard, touchpad) between board and battery
        for x0 in (6 * U, 10 * U):
            p.rect((x0, 6 * U + 22, x0 + U + 20, 6 * U + 42), "#e7d9a8", 0.8, r=2)
            p.rect((x0 + 10, 6 * U + 26, x0 + U + 10, 6 * U + 38), "#b9a874", 0)
        # screw posts of the bottom cover around the rim
        for (x, y) in [(30, 70), (W - 30, 70), (30, H - 30), (W - 30, H - 30), (W // 2, H - 22), (W // 2, 26), (30, H // 2), (W - 30, H // 2)]:
            p.ell((x - 10, y - 10, x + 10, y + 10), "#3a3e45", 1.0); p.ell((x - 4, y - 4, x + 4, y + 4), "#9aa2aa", 0)
        p.glint(40, 30, 28, 1.6); p.glint(W - 180, 24, 22, 1.4)
        return finish_comic(p, lit=False)
    finally:
        pc.S = old


def board():
    """The laptop motherboard, 11 x 5 cells: soldered CPU and GPU dies with VRAM (under the heatsink), two
    lying SO-DIMM slots, one M.2 slot, power circuitry, the battery connector. No sockets: nothing on it
    except the RAM and the drive comes out."""
    old = pc.S; pc.S = 4
    try:
        W, H = 11 * U, 5 * U
        p = pc.Pen(W, H)
        p.grad((2, 2, W - 3, H - 3), "#1f4a3e", "#12302a", 0, angle=0.7)
        rnd = random.Random(62)
        for _ in range(60):
            x, y = rnd.randrange(8, W - 8), rnd.randrange(8, H - 8)
            pts = [(x, y)]
            for _ in range(3):
                dd = rnd.choice([(1, 0), (0, 1), (1, 1), (1, -1)]); L = rnd.randrange(14, 60)
                x, y = x + dd[0] * L, y + dd[1] * L
                pts.append((min(W - 6, x), max(6, min(H - 6, y))))
            p.line(pts, (64, 132, 104, 110), 1.0)
        # soldered CPU die (board 1,1 .. 2,2) and GPU die with four VRAM chips (board 2.2 .. 3.8)
        p.grad((U + 14, U + 14, 2 * U + 30, 2 * U + 30), "#2a2c31", "#141518", 1.4, r=4)
        p.grad((U + 34, U + 34, 2 * U + 10, 2 * U + 10), "#c9cfd5", "#8a939c", 1.0, r=2)      # bare CPU die
        p.grad((2 * U + 44, U + 70, 3 * U + 60, 3 * U + 30), "#2a2c31", "#141518", 1.4, r=4)  # GPU package
        p.grad((2 * U + 66, U + 92, 3 * U + 38, 3 * U + 8), "#b9c1c8", "#7c858e", 1.0, r=2)   # GPU die
        for (x, y) in [(2 * U + 40, U + 40), (3 * U + 44, U + 40), (2 * U + 40, 3 * U + 40), (3 * U + 44, 3 * U + 40)]:
            p.rect((x, y, x + 22, y + 16), "#1d1f24", 0.8, r=1)                              # VRAM
        for (x, y) in [(U, U), (4 * U, U), (U, 4 * U), (4 * U, 4 * U)]:
            p.ell((x - 8, y - 8, x + 8, y + 8), "#c9b98a", 0.8); p.ell((x - 3, y - 3, x + 3, y + 3), "#121315", 0)   # heatsink screw holes
        # power stages left of the dies
        for i in range(5):
            p.grad((16, 18 + i * 52, 52, 54 + i * 52), "#6b7079", "#2f3338", 1.0, r=4, angle=0.7)
        # SO-DIMM slots, lying (board 6,0 and 6,1, each 4 x 1): low slot body, gold contacts, side latches
        for row in (0, 1):
            y0 = row * U
            p.rect((6 * U + 6, y0 + 14, 10 * U - 6, y0 + 50), "#25272c", 1.4, r=3)
            p.rect((6 * U + 14, y0 + 26, 10 * U - 14, y0 + 38), "#101113", 0.6)
            for x in range(6 * U + 18, 10 * U - 18, 4):
                if 8 * U - 6 <= x <= 8 * U + 2: continue
                p.line([(x, y0 + 28), (x, y0 + 36)], "#c9a64e", 0.6)
            for x0 in (6 * U - 4, 10 * U - 14):
                p.grad((x0, y0 + 8, x0 + 18, y0 + 56), "#dfe5ea", "#8f98a1", 1.2, r=3)        # metal latches
        # M.2 slot (board 6,3, 2 x 1) with length marks and the standoff
        x0, y0 = 6 * U, 3 * U
        p.rect((x0 + 6, y0 + 18, x0 + 24, y0 + 46), "#1a1b1e", 1.0, r=2)
        for yy in range(y0 + 22, y0 + 43, 3): p.line([(x0 + 10, yy), (x0 + 20, yy)], "#c9a64e", 0.6)
        for k in (64, 92):
            p.ell((x0 + k - 3, y0 + 29, x0 + k + 3, y0 + 35), "#c9b98a", 0)
        p.ell((x0 + 112, y0 + 24, x0 + 126, y0 + 38), "#d8c48a", 0.9); p.ell((x0 + 116, y0 + 28, x0 + 122, y0 + 34), "#2a2c30", 0)
        # right side: battery connector, BIOS chip, coin cell, small parts
        p.rect((9 * U, 3 * U + 20, 10 * U + 40, 4 * U + 6), "#efe9d8", 1.0, r=3)
        for k in range(7): p.rect((9 * U + 8 + k * 12, 3 * U + 28, 9 * U + 16 + k * 12, 3 * U + 44), "#b9a46a", 0)
        p.rect((9 * U + 10, 4 * U + 20, 9 * U + 46, 4 * U + 44), "#1d1f24", 0.8, r=1)
        p.ell((10 * U + 6, 4 * U + 12, 10 * U + 50, 4 * U + 56), "#cfd6dc", 1.2)
        for x in range(5 * U, 6 * U - 6, 10):
            for y in range(3 * U + 20, 5 * U - 20, 14): p.rect((x, y, x + 5, y + 6), "#c79a5a", 0)
        for box in [(U + 6, U + 6, 4 * U - 6, 4 * U - 6), (6 * U - 6, 4, 10 * U + 6, 2 * U - 4)]:
            p.d.rectangle(p._b(box), outline=(225, 232, 228, 110), width=3)              # silkscreen, no text
        p.line([(2, 2), (W - 3, 2), (W - 3, H - 3), (2, H - 3), (2, 2)], INK, 2.0)
        return finish_comic(p)
    finally:
        pc.S = old


def heatsink():
    """The laptop's heatsink, 4 x 3 cells: a copper plate over the CPU and GPU dies (the right 3 x 3, the
    cooler's place on the board) and two flattened heatpipes through the left cell to the blower fan. It
    comes out as one piece. Spring screws numbered by dots (no text)."""
    old = pc.S; pc.S = 4
    try:
        W, H = 4 * U, 3 * U
        p = pc.Pen(W, H)
        X = U                                                                                  # the plate starts one cell in
        for dy in (U * 0.75, U * 1.55):                                                       # heatpipes to the fan
            p.line([(0, dy + 20), (X + U * 1.6, dy + 20)], "#c4844e", 10.0)
            p.line([(0, dy + 20), (X + U * 1.6, dy + 20)], INK, 0.9)
            p.line([(0, dy + 16), (X + U * 1.6, dy + 16)], (245, 210, 170, 210), 1.0)
        p.grad((2, U * 0.55, 18, U * 2.45), "#b8bec4", "#6f7780", 1.0, r=3)                   # clip into the fan housing
        p.grad((X + 22, 18, W - 14, H - 18), "#d39a63", "#8d5a31", 1.6, r=8, angle=0.7)       # copper plate
        p.grad((X + 40, 36, W - 34, H - 40), "#e4b07c", "#a8703f", 1.0, r=5, angle=0.7)       # contact block
        for k in range(0, 80, 9):
            p.line([(X + 48 + k, 44), (X + 48 + k + 30, 44 + 30)], (255, 230, 200, 90), 0.8)  # brushed copper
        for i, (x, y) in enumerate([(X + 30, 26), (W - 24, 26), (W - 24, H - 26), (X + 30, H - 26)]):  # spring screws 1..4
            p.ell((x - 11, y - 11, x + 11, y + 11), "#b9c1c8", 1.0)
            p.line([(x - 6, y), (x + 6, y)], "#3a3e44", 1.2); p.line([(x, y - 6), (x, y + 6)], "#3a3e44", 1.2)
            for k in range(i + 1): p.ell((x + 14 + k * 5 - 2, y - 16, x + 14 + k * 5 + 2, y - 12), "#f2f2ee", 0)
        p.glint(46, 40, 16, 1.4)
        return finish_comic(p)
    finally:
        pc.S = old


# ---------------- review mocks (never runtime) ----------------

def load(path):
    return Image.open(os.path.join(ROOT, path)).convert("RGBA")


def bench_mock():
    """The laptop on the repair bench at game scale: bench painting, chassis, board, heatsink, fan, one RAM
    stick and an SSD from the approved part art."""
    bg = load("art/bench/background/bench_background.png").resize((1280, 720), Image.LANCZOS)
    area = (40, 110, 620, 400)
    cell = min(area[2] / 16, area[3] / 10)
    ox = area[0] + (area[2] - 16 * cell) / 2; oy = area[1] + (area[3] - 10 * cell) / 2
    def at(x, y, w, h): return (int(round(ox + x * cell)), int(round(oy + y * cell)), int(round(w * cell)), int(round(h * cell)))
    def put(im, box):
        x, y, w, h = box
        bg.alpha_composite(im.resize((w, h), Image.LANCZOS), (x, y))
    shadow = Image.new("RGBA", (int(16 * cell) + 24, int(10 * cell) + 24), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((0, 0, shadow.width - 1, shadow.height - 1), 30, fill=(0, 0, 0, 90))
    bg.alpha_composite(shadow, (int(ox) + 4, int(oy) + 10))
    put(chassis(), at(0, 0, 16, 10))
    put(board(), at(4, 1, 11, 5))
    rotor = load("art/bench/fan/fan_rotor.png"); frame = load("art/bench/fan/fan_frame.png")
    put(rotor, at(1.25, 1.25, 2.5, 2.5)); put(frame, at(1, 1, 3, 3))
    put(heatsink(), at(4, 2, 4, 3))
    ram = load("art/hardware/parts/ram_r1.png"); put(ram, at(10, 1, 4, 1))
    ssd = load("art/hardware/parts/storage_ssd_r0.png"); put(ssd, at(10, 4, 2, 1))
    return bg


def storage_mock():
    """A storage shelf at game scale (2x): a tower with a silver laptop on top and a graphite one on that
    (a stack of three), a compact PC, and a single laptop on the shelf beside them."""
    k = 2
    W, H = 25 * CELL * k, 9 * CELL * k
    im = Image.new("RGBA", (W + 40, H + 40), (54, 52, 48, 255))
    d = ImageDraw.Draw(im)
    for x in range(0, W + 40, CELL * k): d.line((x, 0, x, H + 40), fill=(64, 62, 58, 255))
    for y in range(0, H + 40, CELL * k): d.line((0, y, W + 40, y), fill=(64, 62, 58, 255))
    def put(path_or_im, cx, cy, lift=0):   # lift: screen px a stacked level is drawn up (and left)
        sprite = path_or_im if isinstance(path_or_im, Image.Image) else load(path_or_im)
        sprite = sprite.resize((sprite.width * k, sprite.height * k), Image.NEAREST)
        x, y = 20 + cx * CELL * k - lift // 2, 20 + cy * CELL * k - lift
        if lift:   # a soft shadow under a stacked item
            sh = Image.new("RGBA", sprite.size, (0, 0, 0, 0))
            sh.putalpha(sprite.getchannel("A").point(lambda a: 70 if a else 0))
            im.alpha_composite(sh, (x + 4, y + 6))
        im.alpha_composite(sprite, (x, y))
    put("art/storage/pc_tower_r0.png", 0, 1)
    put(storage_turned("graphite", 0), 1, 1, lift=10)
    put(storage_turned("silver", 0), 1, 1, lift=22)
    put("art/storage/pc_compact_r0.png", 9, 2)
    put(storage_turned("graphite", 1), 18, 1)
    return im


def counter_mock():
    """The counter (approved shell + counter front) with the silver laptop where the customer's PC appears:
    bottom centre at CounterArt.CUSTOMER_PC_BASE (1030, 550), at RoomArt.PIXEL_SCALE 2; the tower prop beside it
    for size."""
    base = "art/rooms/counter_batch_a/"
    room = load(base + "room-shell-v2.png").resize((1280, 720), Image.LANCZOS)
    room.alpha_composite(load(base + "counter-foreground-v2.png").resize((1280, 720), Image.LANCZOS))
    tower = load("art/props/pc_tower_closed.png"); tower = tower.resize((tower.width * 2, tower.height * 2), Image.NEAREST)
    room.alpha_composite(tower, (820 - tower.width // 2, 550 - tower.height))
    prop = counter_prop("silver"); prop = prop.resize((prop.width * 2, prop.height * 2), Image.NEAREST)
    room.alpha_composite(prop, (1030 - prop.width // 2, 550 - prop.height))
    return room


def sheet(items, scale=4, pad=16, bg=(46, 44, 42, 255)):
    ims = [i.resize((i.width * scale, i.height * scale), Image.NEAREST) for i in items]
    W = sum(i.width for i in ims) + pad * (len(ims) + 1)
    H = max(i.height for i in ims) + pad * 2
    out = Image.new("RGBA", (W, H), bg)
    x = pad
    for i in ims:
        out.alpha_composite(i, (x, pad)); x += i.width + pad
    return out


def runtime_files():
    out = {}
    for f in FINISHES:
        for r in range(4): out["storage/laptop_%s_r%d.png" % (f, r)] = storage_turned(f, r)
        out["props/laptop_closed_%s.png" % f] = counter_prop(f)
    out["hardware/case_laptop_interior.png"] = chassis().resize((16 * U, 10 * U), Image.LANCZOS)
    out["hardware/board_laptop.png"] = board().resize((11 * U, 5 * U), Image.LANCZOS)
    out["hardware/laptop_heatsink.png"] = heatsink().resize((4 * U, 3 * U), Image.LANCZOS)
    return out


if __name__ == "__main__":
    if sys.argv[1] == "--runtime":
        art = sys.argv[2]
        for rel, im in runtime_files().items():
            path = os.path.join(art, rel); os.makedirs(os.path.dirname(path), exist_ok=True); im.save(path)
        print("runtime ok")
        sys.exit(0)
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    files = runtime_files()
    for rel, im in files.items():
        path = os.path.join(out, "pieces", rel); os.makedirs(os.path.dirname(path), exist_ok=True); im.save(path)
    bench_mock().save(os.path.join(out, "1_bench_open_laptop.png"))
    storage_mock().save(os.path.join(out, "2_storage_stacks.png"))
    counter_mock().save(os.path.join(out, "3_counter_mara_laptop.png"))
    sheet([files["storage/laptop_silver_r0.png"], files["storage/laptop_graphite_r0.png"], files["props/laptop_closed_silver.png"], files["props/laptop_closed_graphite.png"]]).save(os.path.join(out, "4_pixel_pieces.png"))
    hashes = {rel: hashlib.sha256(open(os.path.join(out, "pieces", rel), "rb").read()).hexdigest() for rel in files}
    json.dump({"revision": 1, "sha256": hashes}, open(os.path.join(out, "manifest.json"), "w"), indent=1)
    print("drafts ok", len(files))
