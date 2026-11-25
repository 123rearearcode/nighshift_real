# ART-14: the open-case / motherboard presentation kit for ONE existing layout: the tower case (18 x 16
# cells) and its demo L-shaped board (10 x 10 cells, top-right 4 x 4 cut away), from pc_layout.gd and
# component_data.gd. Comic-book, semi-realistic like the parts (close-up hardware, D168). Master scale
# 64 px per cell; the game scales it to its cell size. Every connector sits exactly on its cell rectangle,
# so when a part is lifted out the empty slot/socket underneath is already there (the under-part surface).
import os, sys, math, random
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))   # shared comic/pixel helpers
import parts_comic as pc

U = 64                        # px per cell (master)
INK = pc.INK


def cells(x0, y0, x1, y1):
    return (x0 * U, y0 * U, x1 * U, y1 * U)


def finish(p, light=True):
    im = p.im
    if light: im = pc.light_pass(im)
    im = pc.ink_outline(im, 1.2)
    return im


# ---------------- motherboard ----------------

def board():
    old = pc.S; pc.S = 4
    try:
        W = H = 10 * U
        p = pc.Pen(W, H)
        p.grad((2, 2, W - 3, H - 3), "#24584a", "#163a30", 0, angle=0.6)
        rnd = random.Random(14)
        for _ in range(70):                                                                   # copper traces
            x, y = rnd.randrange(8, W - 8), rnd.randrange(8, H - 8)
            if x > 6 * U - 4 and y < 4 * U + 4: continue
            pts = [(x, y)]
            for _ in range(3):
                d = rnd.choice([(1, 0), (0, 1), (1, 1), (1, -1)])
                L = rnd.randrange(16, 70)
                x, y = x + d[0] * L, y + d[1] * L
                pts.append((min(W - 6, x), max(6, min(H - 6, y))))
            p.line(pts, (64, 132, 104, 120), 1.0)
        for (x, y) in [(22, 22), (350, 22), (22, 618), (618, 618), (618, 278), (350, 236), (470, 450)]:
            p.ell((x - 9, y - 9, x + 9, y + 9), "#c9b98a", 0.8); p.ell((x - 4, y - 4, x + 4, y + 4), "#121315", 0)   # mounting holes
        # VRM heatsinks beside the socket
        p.grad((8, 8, 186, 56), "#7b8590", "#3b424b", 1.4, r=4, angle=0.4)
        for x in range(16, 182, 8): p.line([(x, 12), (x, 52)], "#2a2f35", 1.0)
        p.grad((198, 8, 250, 248), "#7b8590", "#3b424b", 1.4, r=4, angle=0.9)
        for y in range(16, 244, 8): p.line([(202, y), (246, y)], "#2a2f35", 1.0)
        # CPU socket (0,1) 3x3
        p.grad((4, 68, 188, 252), "#d5dbe0", "#7f8892", 1.6, r=6, angle=0.7)                # retention frame
        p.rect((22, 86, 168, 232), "#1b1d21", 1.2, r=3)
        p.rect((32, 96, 158, 222), "#5a4a2a", 0.8)
        for y in range(100, 220, 5):
            for x in range(36 + (y // 5) % 2 * 2, 156, 5):
                p.rect((x, y, x + 1.6, y + 1.6), "#e2c062", 0)                               # LGA pin field
        p.poly([(24, 230), (38, 230), (24, 216)], "#e0b84e", 0.6)                             # pin-1 mark
        p.line([(180, 74), (180, 244)], "#e6ebef", 3.2); p.line([(180, 74), (180, 244)], INK, 0.8)   # lever
        p.line([(180, 244), (166, 248)], "#e6ebef", 3.2)
        p.glint(12, 90, 18, 1.4)
        # Cooler mount (0,4) 2x2: backplate holes and outline
        for (x, y) in [(20, 276), (108, 276), (20, 364), (108, 364)]:
            p.ell((x - 10, y - 10, x + 10, y + 10), "#b7bfc7", 1.0); p.ell((x - 4, y - 4, x + 4, y + 4), "#26292e", 0)
        for k in range(0, 76, 8):
            p.line([(26 + k, 270), (30 + k, 270)], (230, 236, 240, 150), 0.8); p.line([(26 + k, 370), (30 + k, 370)], (230, 236, 240, 150), 0.8)
        # Chokes and small parts in the free area (2..5, 4..6)
        for i, (x, y) in enumerate([(150, 276), (196, 276), (242, 276), (150, 326), (196, 326)]):
            p.grad((x, y, x + 36, y + 36), "#6b7079", "#2f3338", 1.0, r=4, angle=0.7)
            p.ell((x + 10, y + 10, x + 26, y + 26), "#8b919a", 0.6)
        for x in range(250, 312, 9):
            p.rect((x, 340, x + 5, 346), "#c79a5a", 0)
        # DIMM slots: ram_2 (4,0) and ram_1 (5,0) upright 1x4, ram_3 (0,8) lying 4x1
        def dimm_v(cx):
            p.rect((cx - 14, 14, cx + 14, 242), "#25272c", 1.4, r=3)
            p.rect((cx - 4, 22, cx + 4, 234), "#101113", 0.6)
            for y in range(26, 232, 4):
                if 150 <= y <= 158: continue
                p.line([(cx - 2, y), (cx + 2, y)], "#c9a64e", 0.6)
            for y0 in (0, 240):
                p.grad((cx - 18, y0, cx + 18, y0 + 16), "#e8e8e4", "#a9adb2", 1.2, r=3)    # latches
        dimm_v(288); dimm_v(352)
        p.rect((14, 530, 242, 558), "#25272c", 1.4, r=3)
        p.rect((22, 540, 234, 548), "#101113", 0.6)
        for x in range(26, 232, 4):
            if 150 <= x <= 158: continue
            p.line([(x, 542), (x, 546)], "#c9a64e", 0.6)
        for x0 in (0, 240):
            p.grad((x0, 526, x0 + 16, 562), "#e8e8e4", "#a9adb2", 1.2, r=3)
        # PCIe x16 slots (0,6) and (0,7), 8x1, with steel armour and an end latch
        for row in (6, 7):
            cy = row * U + 32
            p.grad((8, cy - 14, 488, cy + 14), "#dfe5ea", "#8f98a1", 1.4, r=3)                # armour
            p.rect((16, cy - 7, 480, cy + 7), "#121315", 0.8)
            p.d.rectangle(p._b((92, cy - 7, 98, cy + 7)), fill=pc.C("#8f98a1"))               # key
            for x in range(20, 476, 4):
                if 90 <= x <= 100: continue
                p.line([(x, cy - 3), (x, cy + 3)], "#c9a64e", 0.5)
            p.poly([(488, cy - 16), (508, cy - 10), (508, cy + 10), (488, cy + 16)], "#e8e8e4", 1.2)   # latch
        # M.2 drive slots (4,8) and (6,8): connector, length marks, standoff
        for x0 in (256, 384):
            p.rect((x0 + 6, 532, x0 + 26, 556), "#1a1b1e", 1.0, r=2)
            for y in range(536, 553, 3): p.line([(x0 + 10, y), (x0 + 22, y)], "#c9a64e", 0.6)
            for k in (60, 84, 108):
                p.ell((x0 + k - 3, 541, x0 + k + 3, 547), "#c9b98a", 0)                     # length marks
            p.ell((x0 + 108, 536, x0 + 124, 552), "#d8c48a", 0.9); p.ell((x0 + 113, 541, x0 + 119, 547), "#2a2c30", 0)
        # 24-pin power connector (5,4) 3x2
        p.grad((332, 282, 500, 360), "#3a3d43", "#141518", 1.6, r=4, angle=0.3)
        for r_ in range(2):
            for k in range(12):
                x = 338 + k * 13.5; y = 292 + r_ * 32
                p.rect((x, y, x + 10, y + 24), "#0c0d0f", 0.6, r=2)
                p.rect((x + 3, y + 8, x + 7, y + 16), "#b9a46a", 0)
        p.rect((404, 272, 428, 284), "#3a3d43", 1.0, r=2)                                     # latch
        # right column: capacitors, chipset heatsink, CMOS battery, SATA ports
        for (x, y) in [(530, 270), (566, 270), (602, 270), (530, 312), (566, 312), (602, 312)]:
            p.ell((x, y, x + 30, y + 30), "#3b2e4a", 1.0); p.ell((x + 5, y + 5, x + 25, y + 25), "#b7bfc7", 0.6)
            p.line([(x + 15, y + 8), (x + 15, y + 22)], "#6c737c", 0.8); p.line([(x + 8, y + 15), (x + 22, y + 15)], "#6c737c", 0.8)
        p.grad((522, 392, 630, 478), "#8e98a3", "#3f4750", 1.4, r=6, angle=0.8)
        for k in range(-80, 110, 10):
            p.line([(530 + max(0, k), 400 + max(0, -k)), (530 + min(92, k + 78), 400 + min(70, 78 - k))], "#5a636d", 0.8)
        p.ell((548, 494, 604, 550), "#cfd6dc", 1.4); p.ell((556, 502, 596, 542), "#b3bbc3", 0.6)   # CMOS battery
        p.glint(560, 512, 10)
        for k in range(3):
            y = 562 + k * 24
            p.rect((540, y, 630, y + 20), "#2a2c31", 1.0, r=2); p.rect((548, y + 6, 616, y + 12), "#0c0d0f", 0)
        # bottom headers (front panel, USB, fans)
        for x0, n in [(16, 5), (110, 5), (204, 4), (290, 4), (380, 6)]:
            p.rect((x0, 590, x0 + n * 13 + 6, 622), "#17181b", 1.0, r=2)
            for k in range(n):
                for r_ in range(2):
                    p.ell((x0 + 6 + k * 13, 596 + r_ * 13, x0 + 10 + k * 13, 600 + r_ * 13), "#d8b04a", 0)
        # silkscreen around the socket and slots (no text)
        for box in [(0, 62, 192, 258), (266, 4, 374, 252), (2, 520, 254, 568)]:
            p.d.rectangle(p._b(box), outline=(225, 232, 228, 120), width=3)
        p.d.rectangle(p._b((6 * U, 0, W + 1, 4 * U - 1)), fill=(0, 0, 0, 0))                # the L cut-out, cut last
        p.line([(2, 2), (384, 2), (384, 256), (638, 256), (638, 638), (2, 638), (2, 2)], INK, 2.0)  # board edge ink
        return finish(p)
    finally:
        pc.S = old


# ---------------- the tower case, side panel off ----------------

def case_tower():
    old = pc.S; pc.S = 3
    try:
        W, H = 18 * U, 16 * U
        p = pc.Pen(W, H)
        p.grad((0, 0, W - 1, H - 1), "#59626e", "#2a3038", 0, r=10, angle=0.5)               # case frame
        p.grad((14, 14, W - 15, H - 15), "#3d4652", "#232930", 1.6, r=6, angle=0.6)           # back panel inside
        for x in range(4 * U, 15 * U, 18):                                                     # top honeycomb vent
            for k, y in enumerate(range(24, 52, 14)):
                xx = x + (9 if k % 2 else 0)
                p.ell((xx - 5, y - 5, xx + 5, y + 5), "#1a1e23", 0)
        # rear: fan mount behind the exhaust fan (0,3) 2x3 and the I/O shield beside the board
        r0 = cells(0, 3, 2, 6)
        p.rect((r0[0] + 18, r0[1] + 8, r0[2] - 4, r0[3] - 8), "#2c333b", 1.0, r=6)
        for yy in range(r0[1] + 22, r0[3] - 16, 12):
            for xx in range(r0[0] + 26, r0[2] - 10, 12):
                p.ell((xx - 4, yy - 4, xx + 4, yy + 4), "#151a1f", 0)
        io = cells(2, 2, 3, 7)
        p.grad((io[0] + 14, io[1] + 6, io[2] - 6, io[3] - 6), "#c9d0d6", "#7c858f", 1.2, r=2, angle=1.2)
        for k, h in enumerate([20, 14, 14, 26, 14, 20, 14]):
            y = io[1] + 20 + sum([20, 14, 14, 26, 14, 20, 14][:k]) + k * 8
            if y + h < io[3] - 12: p.rect((io[0] + 22, y, io[2] - 16, y + h), "#1b1e22", 0.6, r=2)
        # expansion slot covers at the rear, in line with the two PCIe rows (case rows 8 and 9)
        for row in (8, 9, 10):
            y = row * U + 10
            p.grad((24, y, 3 * U - 6, y + U - 20), "#aeb6bf", "#6e7781", 1.2, r=2, angle=1.4)
            for xx in range(40, 3 * U - 20, 10): p.line([(xx, y + 10), (xx, y + U - 30)], "#59616b", 1.0)
        # standoffs peeking around the board footprint (3..13, 2..12)
        for (cx, cy) in [(3, 2), (13, 6), (3, 12), (13, 12), (9, 2), (9, 6)]:
            x, y = cx * U, cy * U
            p.ell((x - 8, y - 8, x + 8, y + 8), "#c9b98a", 0.8)
        # cable cut-outs with rubber grommets right of the board
        for y in (3, 6, 9):
            p.rect((13 * U + 24, y * U, 13 * U + 52, y * U + 2 * U - 20), "#0e1013", 1.4, r=12)
            p.rect((13 * U + 28, y * U + 6, 13 * U + 48, y * U + 2 * U - 26), "#26292e", 0, r=9)
        p.rect((4 * U, 12 * U + 6, 9 * U, 12 * U + 24), "#0e1013", 1.2, r=8)
        # PSU shroud along the bottom (the PSU itself sits at 1..9, 12..14)
        sh = cells(0, 12, 16, 16)
        p.grad((sh[0] + 14, sh[1] + 30, sh[2], sh[3] - 15), "#4a535f", "#2b3139", 1.6, r=6, angle=0.2)
        for xx in range(10 * U, 15 * U, 16):
            for yy in range(12 * U + 52, 14 * U + 20, 16):
                p.ell((xx - 4, yy - 4, xx + 4, yy + 4), "#161a1f", 0)
        p.line([(sh[0] + 30, sh[1] + 34), (sh[2] - 20, sh[1] + 34)], (255, 255, 255, 60), 1.4)
        # front: drive cage/frame behind the front filter (16, 1) 1x13
        fr = cells(15, 0, 18, 16)
        p.grad((fr[0] + 8, fr[1] + 14, fr[2] - 15, fr[3] - 15), "#444d58", "#262c33", 1.6, r=4, angle=1.2)
        for k in range(4):
            y = 2 * U + k * 2 * U
            p.rect((fr[0] + 16, y, 16 * U - 4, y + U + 20), "#30373f", 1.0, r=3)
            p.line([(fr[0] + 24, y + 12), (16 * U - 12, y + 12)], "#59626e", 1.0)
        p.glint(30, 40, 30, 1.6); p.glint(W - 120, 30, 24, 1.4)
        return finish(p, light=False)
    finally:
        pc.S = old


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    board().resize((10 * U, 10 * U), Image.LANCZOS).save(os.path.join(out, "board_demo_l.png"))
    case_tower().resize((18 * U, 16 * U), Image.LANCZOS).save(os.path.join(out, "case_tower_interior.png"))
    print("ok")
