# ART-15 (part 2): the testing-bay inspection pictures, one per part kind, for the magnifying glass.
# Comic-book, semi-realistic like the storage parts (D168). Canvas 900 x 600, shown at the bay's part panel
# (450 x 300). Every spot the lens can examine (PartCondition.SPOTS) is a real detail of the picture; its
# position is in SPOTS below, as fractions of the panel, so the game can place the lens targets on it.
# These pictures always show a HEALTHY part: faults and red herrings are separate overlays (ART-17)
# that the game shows only when a part's tell is revealed. Nothing in the picture gives a fault away.
import os, sys, math, json
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))   # shared comic/pixel helpers
import parts_comic as pc

W, H = 900, 600
SPOTS = {}          # kind -> {spot name: [x, y] fraction}


def canvas():
    pc.S = 3
    return pc.Pen(W, H)


def done(p):
    im = pc.light_pass(p.im)
    im = pc.ink_outline(im, 1.6)
    return im.resize((W, H), Image.LANCZOS)


def fan(p, cx, cy, r, blades=9, sx=1.0, sy=1.0, hub="#a9b0b7"):
    p.grad((cx - r * sx, cy - r * sy, cx + r * sx, cy + r * sy), "#2f3238", "#101114", 1.6, shape="ellipse", angle=0.7)
    for k in range(blades):
        a = k * 2 * math.pi / blades
        P = lambda rr, aa: (cx + rr * math.cos(aa) * sx, cy + rr * math.sin(aa) * sy)
        pts = [P(r * 0.26, a), P(r * 0.92, a + 0.3), P(r * 0.9, a + 0.72), P(r * 0.26, a + 0.6)]
        p.poly(pts, "#3d424b", 1.0)
        p.line([pts[0], pts[1]], "#646b76", 1.2)
    p.ell((cx - r * 0.27 * sx, cy - r * 0.27 * sy, cx + r * 0.27 * sx, cy + r * 0.27 * sy), "#16171a", 1.2)
    p.ell((cx - r * 0.18 * sx, cy - r * 0.18 * sy, cx + r * 0.18 * sx, cy + r * 0.18 * sy), hub, 1.0)     # blank hub sticker
    p.glint(cx - r * 0.7 * sx, cy - r * 0.45 * sy, r * 0.25, 2.0)


def spots(kind, **named):
    SPOTS[kind] = {k.replace("_", " ").capitalize() if k not in ("PCIe_contacts",) else "PCIe contacts": [round(x / W, 3), round(y / H, 3)] for k, (x, y) in named.items()}


def gpu():
    p = canvas()
    p.grad((90, 118, 800, 146), "#7b848f", "#4b535e", 1.4, r=3)                        # back plate edge
    for x in range(110, 790, 22): p.line([(x, 126), (x + 10, 126)], "#9ea8b3", 1.0)
    p.grad((780, 150, 866, 430), "#2f7454", "#1b4a35", 1.6, r=4, angle=0.4)             # PCB end
    for (x, y) in [(792, 300), (826, 300), (792, 340), (826, 340), (792, 380), (826, 380)]:
        p.ell((x, y, x + 28, y + 28), "#2f2a3a", 1.0); p.ell((x + 5, y + 5, x + 23, y + 23), "#b7bfc7", 0.6)   # capacitors
    p.rect((700, 100, 784, 150), "#141518", 1.4, r=4)                                    # 8-pin power
    for k in range(4):
        for r_ in range(2): p.rect((710 + k * 18, 108 + r_ * 18, 722 + k * 18, 120 + r_ * 18), "#2f3238", 0.6, r=2)
    p.grad((90, 146, 790, 430), "#4d5561", "#22262c", 1.8, r=10, angle=0.3)              # shroud
    p.poly([(96, 420), (180, 420), (230, 156), (150, 156)], "#3a414b", 1.2)
    p.poly([(700, 156), (780, 156), (784, 420), (650, 420)], "#3a414b", 1.2)
    p.line([(140, 412), (740, 412)], "#4fb7a8", 3.0)                                      # accent strip
    fan(p, 300, 285, 118); fan(p, 560, 285, 118)
    p.grad((210, 430, 600, 468), "#f0cf6a", "#b48a2e", 1.4, angle=0)                     # PCIe contacts
    for x in range(216, 596, 7):
        if 268 <= x <= 282: continue
        p.line([(x, 434), (x, 464)], "#8a6a22", 1.0)
    p.d.rectangle(p._b((268, 430, 282, 470)), fill=(0, 0, 0, 0))                         # key notch
    p.grad((40, 106, 92, 480), "#e3e9ee", "#8e979f", 1.6, angle=math.pi / 2)              # bracket
    for y in range(140, 450, 26): p.rect((52, y, 80, y + 14), "#4b525b", 0.8, r=3)
    p.glint(110, 170, 30, 2.4)
    spots("gpu", fans=(300, 285), power_connector=(742, 125), PCIe_contacts=(400, 450), capacitors=(826, 350), back_plate=(460, 132))
    return done(p)


def cpu():
    p = canvas()
    # left: the top, heat spreader up
    p.grad((60, 120, 420, 480), "#35805a", "#1f5537", 1.8, r=8, angle=0.5)
    for k in range(16):
        p.rect((80 + k * 20, 456, 88 + k * 20, 464), "#c79a5a", 0); p.rect((396, 140 + k * 20, 404, 148 + k * 20), "#c79a5a", 0)
    p.grad((104, 164, 376, 436), "#eef2f4", "#8a939b", 1.8, r=12, angle=0.7)
    for k in range(14): p.line([(116, 180 + k * 18), (364, 180 + k * 18)], (255, 255, 255, 40), 0.8)
    p.rect((140, 200, 340, 400), "#c9cfd5", 1.0, r=6)
    for y in (270, 296, 322): p.line([(170, y), (310 - (y % 7) * 4, y)], "#98a0a8", 1.6)
    p.poly([(66, 474), (96, 474), (66, 444)], "#e0b84e", 1.0)
    p.glint(120, 230, 50, 3.0); p.glint(140, 236, 18, 1.6)
    # right: the underside, contact pads
    p.grad((480, 120, 840, 480), "#3a8a60", "#215c3b", 1.8, r=8, angle=0.5)
    for y in range(150, 452, 12):
        for x in range(510, 812, 12):
            if 610 < x < 710 and 250 < y < 350: continue
            p.ell((x, y, x + 6, y + 6), "#e6c25c", 0)
    p.rect((620, 260, 700, 340), "#2b6b45", 1.0)
    for (x, y) in [(632, 272), (660, 272), (632, 300), (660, 300), (632, 320)]:
        p.rect((x, y, x + 18, y + 10), "#c79a5a", 0.6)
    p.poly([(486, 474), (516, 474), (486, 444)], "#e0b84e", 1.0)
    spots("cpu", contact_pads=(560, 200), heat_spreader=(240, 300), edges=(240, 462))
    return done(p)


def ram():
    p = canvas()
    p.grad((60, 190, 840, 408), "#35805a", "#1f5537", 1.8, r=6, angle=0.3)              # PCB
    for x in range(90, 820, 40): p.line([(x, 200), (x + 20, 240)], (90, 170, 120, 90), 1.0)  # traces
    for k in range(6):
        x = 250 + k * 96
        p.grad((x, 232, x + 72, 362), "#2b2e34", "#121316", 1.4, r=3, angle=0.6)        # memory chips
        p.line([(x + 12, 270), (x + 50, 270)], "#4a4e57", 1.2); p.line([(x + 12, 290), (x + 40, 290)], "#4a4e57", 1.2)
        p.glint(x + 8, 248, 16, 1.4)
    p.rect((86, 228, 222, 330), "#efece2", 1.2, r=3)                                     # label (blank)
    for x in range(96, 212, 4): p.line([(x, 296), (x, 318 + (x % 3) * 2)], "#5d5d58", 1.0)
    p.rect((96, 240, 168, 252), "#c4473c", 0); p.line([(96, 266), (204, 266)], "#a3a199", 1.4); p.line([(96, 280), (180, 280)], "#a3a199", 1.4)
    for x in range(70, 830, 8):                                                           # gold contacts
        if 470 <= x <= 486: continue
        p.rect((x, 408, x + 5, 446), "#e8c35c", 0.6, r=1)
    p.d.rectangle(p._b((470, 396, 488, 450)), fill=(0, 0, 0, 0))                          # key notch
    for (x, y) in [(232, 380), (250, 380), (268, 380), (760, 380), (778, 380)]:
        p.rect((x, y, x + 10, y + 6), "#c79a5a", 0)
    spots("ram", gold_contacts=(330, 428), memory_chips=(574, 297), label=(150, 270))
    return done(p)


def psu():
    p = canvas()
    # cables leaving on the right: sleeved bundles ending in connectors
    for k, (y1, y2, end) in enumerate([(220, 150, "24"), (290, 300, "pcie"), (360, 440, "sata")]):
        p.line([(600, y1), (700, (y1 + y2) / 2), (790, y2)], "#1b1c20", 22); p.line([(600, y1), (700, (y1 + y2) / 2), (790, y2)], "#3a3d44", 14)
        for t in range(0, 180, 12): p.line([(606 + t, y1 + (y2 - y1) * t / 190 - 6), (612 + t, y1 + (y2 - y1) * t / 190 + 6)], "#5a5e66", 1.0)  # sleeve weave
    p.rect((786, 116, 846, 196), "#141518", 1.4, r=4)                                    # 24-pin end
    for k in range(4):
        for r_ in range(2): p.rect((794 + r_ * 24, 124 + k * 18, 810 + r_ * 24, 138 + k * 18), "#2f3238", 0.6, r=2)
    p.rect((786, 280, 840, 322), "#141518", 1.4, r=4)                                    # PCIe end
    p.rect((786, 424, 852, 452), "#141518", 1.4, r=3)                                    # SATA end
    # the box, fan side up
    p.grad((100, 100, 620, 500), "#3e434b", "#1a1c20", 1.8, r=8, angle=0.6)
    p.grad((112, 112, 178, 488), "#2b2e34", "#16181b", 1.2, r=4, angle=1.2)             # vented end
    for yy in range(126, 476, 14):
        for xx in range(122, 170, 14):
            p.ell((xx + (7 if (yy // 14) % 2 else 0) - 4, yy - 4, xx + (7 if (yy // 14) % 2 else 0) + 4, yy + 4), "#060708", 0)
    p.rect((190, 120, 260, 230), "#b8bec4", 1.0, r=3)                                    # rating sticker, blank
    for y in range(134, 222, 10): p.line([(198, y), (250 - (y % 4) * 4, y)], "#7c838a", 1.2)
    cx, cy, r = 420, 300, 168
    p.ell((cx - r, cy - r, cx + r, cy + r), "#121316", 1.6)
    for k in range(9):
        a = k * 2 * math.pi / 9
        P = lambda rr, aa: (cx + rr * math.cos(aa), cy + rr * math.sin(aa))
        p.poly([P(40, a), P(156, a + 0.25), P(156, a + 0.55), P(40, a + 0.5)], "#33363d", 0.8)
    for rad in (160, 128, 96, 64, 34):
        p.ring((cx - rad, cy - rad, cx + rad, cy + rad), "#9aa2ab", 1.6)
    p.line([(cx - r, cy), (cx + r, cy)], "#9aa2ab", 1.6); p.line([(cx, cy - r), (cx, cy + r)], "#9aa2ab", 1.6)
    p.ell((cx - 26, cy - 26, cx + 26, cy + 26), "#2a2d33", 1.2)
    p.glint(290, 190, 40, 2.4)
    for x, y in [(112, 110), (608, 110), (112, 490), (608, 490)]:
        p.ell((x - 5, y - 5, x + 5, y + 5), "#7c838a", 0.8)
    spots("psu", fan_grille=(470, 300), cable_ends=(816, 300), smell=(300, 300), case_vents=(146, 300))
    return done(p)


def cooler():
    p = canvas()
    # left: from above, the fan
    p.grad((70, 110, 450, 490), "#d1d8de", "#7b848c", 1.8, r=30, angle=0.7)             # fin ring
    for k in range(0, 360, 6):
        a = math.radians(k)
        p.line([(260 + 172 * math.cos(a), 300 + 172 * math.sin(a)), (260 + 188 * math.cos(a), 300 + 188 * math.sin(a))], "#9aa3ab", 1.2)
    fan(p, 260, 300, 165, blades=7)
    for (x, y) in [(96, 136), (424, 136), (96, 464), (424, 464)]:
        p.ell((x - 16, y - 16, x + 16, y + 16), "#121316", 1.2); p.ell((x - 8, y - 8, x + 8, y + 8), "#e8e8e4", 0)
    # the fan cable leaving to a 4-pin plug
    p.line([(400, 420), (470, 470), (560, 500)], "#1b1c20", 9); p.line([(400, 420), (470, 470), (560, 500)], "#3a3d44", 5)
    p.rect((556, 486, 600, 516), "#efece2", 1.2, r=3)
    # right: from the side, fins and the copper base plate
    p.grad((540, 150, 840, 196), "#2f3238", "#121316", 1.6, r=8)                        # fan frame, side
    for k in range(18):
        x = 552 + k * 16
        p.grad((x, 196, x + 10, 380), "#e1e7ec", "#8f98a1", 1.0, angle=math.pi / 2)    # fins
    p.grad((600, 380, 780, 420), "#e9a26a", "#a65d2e", 1.6, r=4)                         # copper base
    p.line([(608, 388), (772, 388)], "#f8cfa6", 2.0)
    p.glint(560, 240, 30, 2.0)
    spots("cooler", fan_blades=(200, 240), fins=(690, 290), base_plate=(690, 400), fan_cable=(478, 474))
    return done(p)


def storage():
    p = canvas()
    p.grad((110, 100, 720, 500), "#d6dde2", "#8a939b", 1.8, r=10, angle=0.6)            # aluminium lid
    p.grad((130, 120, 390, 480), "#c4cbd1", "#9aa2aa", 1.2, r=16, angle=0.6)            # raised platter cover
    p.ell((180, 210, 340, 370), "#a3abb3", 1.4); p.ell((236, 266, 284, 314), "#d9dee2", 1.0)   # spindle
    for a in range(6):
        aa = a * math.pi / 3
        p.ell((260 + 34 * math.cos(aa) - 4, 290 + 34 * math.sin(aa) - 4, 260 + 34 * math.cos(aa) + 4, 290 + 34 * math.sin(aa) + 4), "#6c737c", 0.6)
    p.rect((410, 130, 690, 400), "#f2efe6", 1.4, r=4)                                    # label (blank)
    p.rect((430, 150, 520, 180), "#c4473c", 0)
    for y in (210, 236, 262, 288): p.line([(430, y), (670 - (y % 5) * 10, y)], "#a3a199", 1.6)
    for x in range(430, 670, 4): p.line([(x, 330), (x, 372 + (x % 3) * 3)], "#55554f", 1.0)
    for (x, y) in [(126, 116), (700, 116), (126, 484), (700, 484), (400, 116), (400, 484)]:
        p.ell((x - 6, y - 6, x + 6, y + 6), "#5d646c", 0.8)
    p.rect((720, 200, 760, 400), "#141518", 1.6, r=3)                                    # SATA power + data
    for y in range(212, 300, 8): p.line([(728, y), (752, y)], "#c9a64e", 1.0)
    for y in range(320, 390, 8): p.line([(728, y), (752, y)], "#c9a64e", 1.0)
    p.glint(140, 150, 40, 2.4)
    spots("storage", connector=(740, 300), label=(560, 240), casing=(170, 470))
    return done(p)


KINDS = {"gpu": gpu, "cpu": cpu, "ram": ram, "psu": psu, "cooler": cooler, "storage": storage}

if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for k, fn in KINDS.items():
        fn().save(os.path.join(out, f"inspect_{k}.png"))
    json.dump(SPOTS, open(os.path.join(out, "inspect_spots.json"), "w"), indent=1)
    print(json.dumps(SPOTS))
