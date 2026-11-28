#!/usr/bin/env python3
"""Windough 98 and NightBoot USB: the customer PC's screens on the diagnostic monitor (0.59.0, drafts, revision 2).

The user, 28 November 2026: replace the per-part tests with "the PC desktop boot screen. It has to look somewhat
like a goofy windows. We will have it booted in our own boot tool." Picked: the parody OS is "Windough 98"
(start button "Begin", a lumpy dough-ball logo), the shop's boot stick is "NightBoot USB". On revision 1: "make
sure the info of the bios doesnt give anything away, maybe its best to remove any info there. spend a bit more
time on the details of this, making it have a better feel."

Revision 2: the BIOS says nothing about the parts (no CPU, memory, drives, fans or test results); a PC that does
not start only shows the monitor's NO SIGNAL; NightBoot is a text-mode boot menu with a countdown; the logo is
hand-shaded pixel dough; titles are bold; the desktop has a selected icon, a readme from the last technician, a
Begin menu, tray icons and a pixel cursor; windows have a menu bar and buttons; a faint CRT scanline sits over
every screen.

Pixel art at the monitor's native 423 x 258, shown at exactly 2x inside the approved bezel. This script draws the
reusable pieces and composes the review frames from them and the 5 x 7 font (font5x7.py); the game draws
frames, text and scanlines by the same rules. By Claude (Opus 5.5, model id claude-opus-5-5); original drawing,
no real logos or company names.

Usage: python3 -I tools/art_batch_e/windough.py <out_dir> [monitor_bezel.png]
"""
import json
import math
import os
import random
import sys
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import font5x7

W, H = 423, 258            # the monitor's screen, native pixels (2x on screen)
TASKBAR = 15
TEAL = (24, 120, 120)
GREY = (192, 192, 192)
LIGHT = (255, 255, 255)
SHADE = (128, 128, 128)
DARK = (34, 34, 34)
NAVY = (0, 0, 128)
TITLE_END = (24, 136, 208)
SELECT = (0, 0, 128)
INK = (24, 20, 18)
DOUGH_HI = (252, 236, 200)
DOUGH = (236, 206, 150)
DOUGH_SHADE = (208, 166, 106)
DOUGH_DEEP = (160, 116, 64)
DOUGH_LINE = (96, 62, 30)


# ---------------------------------------------------------------- text (5 x 7, advance 6; bold adds one pixel)
def text(img, s, x, y, colour, scale=1, shadow=None, bold=False):
    d = img.load()
    adv = 7 if bold else 6
    def put(px, py, c):
        if 0 <= px < img.width and 0 <= py < img.height: d[px, py] = c
    for layer in ([shadow] if shadow is not None else []) + [colour]:
        off = scale if layer is shadow and shadow is not None else 0
        for i, ch in enumerate(s):
            rows = font5x7.G.get(ch, font5x7.G["?"])
            for r, row in enumerate(rows):
                for c, cell in enumerate(row):
                    if cell != "#": continue
                    for b in ([0, 1] if bold else [0]):
                        for sy in range(scale):
                            for sx in range(scale):
                                put(x + (i * adv + c + b) * scale + sx + off, y + r * scale + sy + off, layer)
    return x + len(s) * adv * scale


def text_width(s, scale=1, bold=False):
    return len(s) * (7 if bold else 6) * scale - scale


def wrap(s, chars):
    out, line = [], ""
    for word in s.split(" "):
        if line and len(line) + 1 + len(word) > chars:
            out.append(line); line = word
        else:
            line = (line + " " + word).strip()
    if line: out.append(line)
    return out


# ---------------------------------------------------------------- frames and bevels (the game draws these the same way)
def bevel(d, box, raised=True):
    x0, y0, x1, y1 = box
    a, b = (LIGHT, DARK) if raised else (SHADE, LIGHT)
    d.line((x0, y0, x1, y0), fill=a); d.line((x0, y0, x0, y1), fill=a)
    d.line((x0, y1, x1, y1), fill=b); d.line((x1, y0, x1, y1), fill=b)
    if raised:
        d.line((x0 + 1, y1 - 1, x1 - 1, y1 - 1), fill=SHADE); d.line((x1 - 1, y0 + 1, x1 - 1, y1 - 1), fill=SHADE)
    else:
        d.line((x0 + 1, y0 + 1, x1 - 1, y0 + 1), fill=DARK); d.line((x0 + 1, y0 + 1, x0 + 1, y1 - 1), fill=DARK)


def button(img, box, label, pressed=False, bold=False):
    d = ImageDraw.Draw(img)
    d.rectangle(box, fill=GREY); bevel(d, box, raised=not pressed)
    w = text_width(label, bold=bold)
    text(img, label, (box[0] + box[2]) // 2 - w // 2 + (1 if pressed else 0), (box[1] + box[3]) // 2 - 3 + (1 if pressed else 0), INK, bold=bold)


def title_bar(img, box, title, icon=None, active=True):
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = box
    a, b = (NAVY, TITLE_END) if active else ((128, 128, 128), (184, 184, 184))
    for x in range(x0, x1 + 1):                    # a smooth 98-style gradient, in 4-pixel steps
        t = ((x - x0) // 4 * 4) / max(1, x1 - x0)
        d.line((x, y0, x, y1), fill=tuple(int(a[k] + (b[k] - a[k]) * t) for k in range(3)))
    tx = x0 + 3
    if icon is not None:
        img.alpha_composite(icon.resize((11, 11), Image.NEAREST), (x0 + 2, y0 + 1)); tx = x0 + 16
    text(img, title, tx, y0 + 3, LIGHT, bold=True)
    for k, glyph in enumerate(["x", "o", "_"]):    # close, maximise, minimise (from the right)
        bx = x1 - 13 - k * 12 - (2 if k else 0)
        bb = (bx, y0 + 2, bx + 10, y1 - 2)
        d.rectangle(bb, fill=GREY); bevel(d, bb)
        if glyph == "o":
            d.rectangle((bx + 2, y0 + 4, bx + 8, y1 - 4), outline=INK); d.line((bx + 2, y0 + 5, bx + 8, y0 + 5), fill=INK)
        elif glyph == "_":
            d.rectangle((bx + 2, y1 - 5, bx + 6, y1 - 4), fill=INK)
        else:
            for o in (0, 1):
                d.line((bx + 2 + o, y0 + 4, bx + 6 + o, y1 - 4), fill=INK); d.line((bx + 6 + o, y0 + 4, bx + 2 + o, y1 - 4), fill=INK)


def window(img, box, title, lines, icon=None, status="", menu=("File", "Edit", "Panic"), buttons=()):
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = box
    d.rectangle(box, fill=GREY); bevel(d, box)
    title_bar(img, (x0 + 3, y0 + 3, x1 - 3, y0 + 16), title, icon)
    mx = x0 + 6
    for m in menu:                                  # the menu bar, first letters underlined
        text(img, m, mx, y0 + 20, INK); d.line((mx, y0 + 28, mx + 4, y0 + 28), fill=INK); mx += text_width(m) + 10
    bottom = y1 - (17 if status else 4) - (18 if buttons else 0)
    body = (x0 + 4, y0 + 31, x1 - 4, bottom)
    d.rectangle(body, fill=(255, 255, 255)); bevel(d, body, raised=False)
    y = body[1] + 5
    for line in lines:
        if line == "":
            y += 5; continue
        for part in wrap(line, (body[2] - body[0] - 10) // 6):
            if y + 8 > body[3] - 2: break
            text(img, part, body[0] + 5, y, INK); y += 9
    bx = x1 - 6
    for label in reversed(buttons):
        w = max(48, text_width(label) + 14)
        button(img, (bx - w, bottom + 4, bx, bottom + 17), label); bx -= w + 6
    if status:
        sb = (x0 + 4, y1 - 14, x1 - 4, y1 - 4)
        bevel(d, sb, raised=False)
        text(img, status, x0 + 7, y1 - 12, INK)


def scanlines(img2x):
    """A faint CRT scanline over every screen (every second screen row 10 % darker)."""
    px = img2x.load()
    for y in range(1, img2x.height, 2):
        for x in range(img2x.width):
            r, g, b = px[x, y][:3]
            px[x, y] = (int(r * 0.9), int(g * 0.9), int(b * 0.9))
    return img2x


# ---------------------------------------------------------------- the pieces
def dough_logo():
    """32 x 32 hand-shaded pixel dough: lumpy outline, light from the top left, a grin, flour and four sprinkles."""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    cx, cy = 15.5, 16.5
    def radius(a):
        return 12.6 + 0.9 * math.sin(a * 3 + 0.6) + 0.5 * math.sin(a * 5 + 2.1)
    inside = lambda x, y: math.hypot((x - cx), (y - cy) * 1.12) <= radius(math.atan2((y - cy) * 1.12, x - cx))
    for y in range(32):
        for x in range(32):
            if not inside(x, y): continue
            edge = not (inside(x - 1, y) and inside(x + 1, y) and inside(x, y - 1) and inside(x, y + 1))
            if edge:
                px[x, y] = DOUGH_LINE + (255,); continue
            # light from the top left: a dot product with a fake normal
            nx, ny = (x - cx) / 13.0, (y - cy) / 12.0
            light = -0.62 * nx - 0.78 * ny + 0.35 * (1 - min(1, nx * nx + ny * ny))
            col = DOUGH_DEEP if light < -0.42 else DOUGH_SHADE if light < -0.05 else DOUGH if light < 0.42 else DOUGH_HI
            px[x, y] = col + (255,)
    for (x, y) in [(9, 9), (10, 9), (9, 10), (11, 8)]: px[x, y] = (255, 248, 230, 255)        # shine
    for (x, y) in [(11, 15), (11, 16), (19, 15), (19, 16)]: px[x, y] = INK + (255,)          # eyes
    for (x, y) in [(10, 20), (11, 21), (12, 22), (13, 22), (14, 22), (15, 22), (16, 22), (17, 22), (18, 21), (19, 20)]:
        px[x, y] = DOUGH_LINE + (255,)                                                          # the grin
    for (x, y) in [(9, 18), (21, 18)]: px[x, y] = (232, 150, 120, 255)                          # cheeks
    for (x, y), col in zip([(13, 7), (18, 8), (22, 11), (7, 12)], [(222, 60, 50), (60, 170, 70), (50, 110, 220), (240, 196, 40)]):
        px[x, y] = col + (255,); px[x + 1, y] = col + (255,)                                     # sprinkles
    rnd = random.Random(4)
    for _ in range(9):                                                                          # flour
        x, y = rnd.randint(7, 24), rnd.randint(9, 26)
        if px[x, y][3] and px[x, y][:3] not in (INK, DOUGH_LINE): px[x, y] = (255, 251, 240, 255)
    return img


def icon(kind):
    img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if kind == "boot":            # a work boot
        d.polygon([(6, 3), (13, 3), (13, 14), (20, 16), (21, 20), (4, 20), (4, 14)], fill=(122, 74, 38), outline=(52, 30, 14))
        d.line((7, 4, 7, 14), fill=(160, 104, 60))
        d.rectangle((4, 20, 21, 21), fill=(52, 30, 14))
        for y in (6, 9, 12): d.line((8, y, 11, y), fill=(232, 210, 160))
    elif kind == "hardware":      # a chip
        d.rectangle((6, 6, 17, 17), fill=(44, 120, 66), outline=(20, 60, 30))
        d.rectangle((9, 9, 14, 14), fill=(190, 190, 196)); d.line((9, 9, 14, 9), fill=(236, 236, 240))
        for k in range(4):
            for x0, y0, x1, y1 in [(8 + k * 3, 2, 8 + k * 3, 5), (8 + k * 3, 18, 8 + k * 3, 21), (2, 8 + k * 3, 5, 8 + k * 3), (18, 8 + k * 3, 21, 8 + k * 3)]:
                d.line((x0, y0, x1, y1), fill=(214, 180, 60))
    elif kind == "taskmanajer":   # a clipboard with a bug on it
        d.rectangle((5, 4, 18, 21), fill=(170, 120, 70), outline=(80, 50, 24))
        d.rectangle((7, 7, 16, 19), fill=(250, 250, 244))
        d.rectangle((9, 3, 14, 5), fill=(160, 160, 166))
        d.ellipse((9, 11, 14, 17), fill=(200, 40, 40)); d.line((11, 11, 11, 17), fill=INK)
        for y in (12, 14, 16): d.line((7, y, 9, y - 1), fill=INK); d.line((14, y - 1, 16, y), fill=INK)
    elif kind == "vapor":         # Vapor, the parody game store: a shopping bag letting off steam
        d.rectangle((5, 10, 18, 21), fill=(70, 96, 150), outline=(30, 40, 70))
        d.arc((8, 6, 15, 14), 180, 360, fill=(30, 40, 70), width=1)
        text(img, "V", 9, 12, (236, 240, 248))
        for x, k in ((7, 0), (12, 1), (16, 0)):
            d.point((x, 7 - k), fill=(200, 214, 230)); d.point((x + 1, 5 - k), fill=(200, 214, 230)); d.point((x, 3 - k), fill=(200, 214, 230))
    elif kind == "game":          # Counter Stroke 2: a crosshair
        d.ellipse((4, 4, 19, 19), outline=(232, 120, 30), width=2)
        d.line((11, 1, 11, 9), fill=(232, 120, 30)); d.line((11, 14, 11, 22), fill=(232, 120, 30))
        d.line((1, 11, 9, 11), fill=(232, 120, 30)); d.line((14, 11, 22, 11), fill=(232, 120, 30))
        d.point((11, 11), fill=(232, 40, 30))
    elif kind == "stress":        # the Stress lab: a flask over a flame
        d.polygon([(9, 3), (14, 3), (14, 9), (19, 18), (4, 18), (9, 9)], fill=(200, 230, 240), outline=(60, 90, 110))
        d.polygon([(7, 14), (16, 14), (18, 17), (5, 17)], fill=(230, 80, 60))
        d.point((10, 12), fill=(255, 255, 255)); d.point((13, 11), fill=(255, 255, 255))
        d.polygon([(10, 19), (12, 21), (14, 19), (12, 22)], fill=(250, 170, 40))
    elif kind == "overclock":     # a speedometer in the red
        d.pieslice((3, 5, 20, 22), 180, 360, fill=(230, 230, 230), outline=(60, 60, 60))
        d.pieslice((3, 5, 20, 22), 300, 360, fill=(220, 70, 50))
        d.line((11, 13, 18, 8), fill=INK, width=2)
        d.rectangle((3, 13, 20, 15), fill=(60, 60, 60))
    elif kind == "bin":           # the Bin of Regret
        d.rectangle((6, 7, 17, 21), fill=(170, 176, 184), outline=(70, 74, 80))
        d.rectangle((4, 4, 19, 6), fill=(140, 146, 154), outline=(70, 74, 80))
        for x in (9, 12, 15): d.line((x, 9, x, 19), fill=(150, 156, 164))
        d.point((9, 12), fill=INK); d.point((14, 12), fill=INK)
        d.line((10, 16, 13, 16), fill=INK); d.point((9, 17), fill=INK); d.point((14, 17), fill=INK)
    elif kind == "readme":        # a text file with a dog-ear
        d.polygon([(6, 3), (15, 3), (19, 7), (19, 21), (6, 21)], fill=(250, 250, 250), outline=(80, 80, 80))
        d.polygon([(15, 3), (15, 7), (19, 7)], fill=(200, 200, 200), outline=(80, 80, 80))
        for y in (10, 13, 16, 19): d.line((8, y, 17 if y < 19 else 13, y), fill=(60, 80, 160))
    elif kind == "usb":           # the NightBoot stick (taskbar tray, 10 x 10 used)
        d.rectangle((2, 7, 18, 16), fill=(30, 36, 70), outline=(10, 14, 30))
        d.rectangle((18, 9, 22, 14), fill=(200, 200, 210))
        d.ellipse((5, 9, 10, 14), fill=(240, 196, 92))
    elif kind == "speaker":
        d.rectangle((4, 9, 8, 15), fill=INK); d.polygon([(8, 9), (14, 4), (14, 20), (8, 15)], fill=INK)
        d.arc((12, 6, 20, 18), 300, 60, fill=INK)
    return img


ICONS = [("boot", "Boot check"), ("hardware", "Hardware check"), ("taskmanajer", "Task Manajer"), ("vapor", "Vapor"),
         ("game", "Counter Stroke 2"), ("stress", "Stress lab"), ("overclock", "Overclocker"), ("readme", "readme.txt"),
         ("bin", "Bin of Regret")]


def icon_spot(i):
    col, row = divmod(i, 5)
    return 4 + col * 64, 5 + row * 46


def wallpaper():
    img = Image.new("RGBA", (W, H - TASKBAR), TEAL + (255,))
    px = img.load()
    for y in range(H - TASKBAR):           # a very light 98-style dither so the teal is not flat
        for x in range(W):
            if (x * 7 + y * 13) % 29 == 0: px[x, y] = (30, 128, 128, 255)
    big = dough_logo().resize((96, 96), Image.NEAREST)
    big.putalpha(big.getchannel("A").point(lambda v: int(v * 0.13)))
    img.alpha_composite(big, (W - 96 - 64, (H - TASKBAR - 96) // 2 - 10))
    return img


def taskbar():
    img = Image.new("RGBA", (W, TASKBAR), GREY + (255,))
    d = ImageDraw.Draw(img)
    d.line((0, 1, W, 1), fill=LIGHT)
    bevel(d, (W - 62, 2, W - 3, TASKBAR - 2), raised=False)
    img.alpha_composite(icon("speaker").resize((9, 9), Image.NEAREST), (W - 59, 3))
    img.alpha_composite(icon("usb").resize((9, 9), Image.NEAREST), (W - 48, 3))
    return img


def begin_button(pressed=False):
    img = Image.new("RGBA", (48, 12), GREY + (255,))
    d = ImageDraw.Draw(img)
    bevel(d, (0, 0, 47, 11), raised=not pressed)
    img.alpha_composite(dough_logo().resize((10, 10), Image.NEAREST), (2 + pressed, 1 + pressed))
    text(img, "Begin", 13 + pressed, 3 + pressed, INK, bold=True)
    return img


def cursor():
    rows = ["X...........", "XX..........", "X#X.........", "X##X........", "X###X.......", "X####X......", "X#####X.....",
            "X######X....", "X#######X...", "X########X..", "X#####XXXXX.", "X##X##X.....", "X#X.X##X....", "XX..X##X....",
            "X....X##X...", ".....X##X...", "......XX...."]
    img = Image.new("RGBA", (12, 17), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c == "X": img.putpixel((x, y), (0, 0, 0, 255))
            elif c == "#": img.putpixel((x, y), (255, 255, 255, 255))
    return img


def splash_windough(fraction):
    img = Image.new("RGBA", (W, H), (120, 170, 220, 255))
    d = ImageDraw.Draw(img)
    for y in range(H):                      # sky, banded like a 98 boot screen
        t = round(y / H * 7) / 7
        d.line((0, y, W, y), fill=(int(64 + 96 * t), int(116 + 84 * t), int(198 + 44 * t)))
    for (x, y, w) in [(26, 34, 64), (306, 22, 84), (262, 212, 74), (34, 206, 56), (356, 118, 52), (110, 92, 40)]:
        for k in range(3):
            d.ellipse((x + k * w // 4, y - 6 + (k % 2) * 3, x + k * w // 4 + w // 2, y + 8), fill=(236, 244, 252))
        d.line((x + 4, y + 8, x + w - 4, y + 8), fill=(206, 222, 238))
    img.alpha_composite(dough_logo().resize((64, 64), Image.NEAREST), ((W - 64) // 2, 44))
    x = (W - text_width("Windough 98", 3, bold=True)) // 2
    x = text(img, "Windough ", x, 120, (255, 255, 255), 3, shadow=(26, 44, 88), bold=True)
    text(img, "98", x, 120, (250, 170, 50), 3, shadow=(26, 44, 88), bold=True)
    t = "Second Rising Edition"; text(img, t, (W - text_width(t)) // 2, 150, (255, 244, 220), shadow=(26, 44, 88))
    # the loading bar: dough rising along a baking tray
    tray = (W // 2 - 90, 176, W // 2 + 90, 188)
    d.rectangle(tray, fill=(60, 60, 70)); d.rectangle((tray[0] + 1, tray[1] + 1, tray[2] - 1, tray[3] - 1), fill=(96, 96, 108))
    if fraction is not None:                # None: the empty tray the game fills while it loads
        end = tray[0] + 2 + int((tray[2] - tray[0] - 4) * fraction)
        for x in range(tray[0] + 2, end):
            bump = 1 if (x // 5) % 2 else 0
            d.line((x, tray[1] + 3 - bump, x, tray[3] - 2), fill=DOUGH if (x // 5) % 3 else DOUGH_SHADE)
        d.line((tray[0] + 2, tray[1] + 3, end, tray[1] + 3), fill=DOUGH_HI)
    t = "Please knead patiently..."; text(img, t, (W - text_width(t)) // 2, 196, (255, 255, 255), shadow=(26, 44, 88))
    t = "(c) 1998 Bakeware Corp. All rights rising."; text(img, t, (W - text_width(t)) // 2, H - 14, (220, 232, 248))
    return img


def bios():
    """A BIOS that tells nothing about the parts (the user: "make sure the info of the bios doesnt give anything away")."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    grey, bright, amber = (176, 176, 176), (236, 236, 236), (240, 196, 92)
    # top right: the board maker's little mascot (a sleepy moon), our stand-in for the energy logo
    d.ellipse((W - 46, 8, W - 14, 40), fill=amber); d.ellipse((W - 38, 4, W - 6, 34), fill=(0, 0, 0))
    d.line((W - 40, 26, W - 36, 26), fill=(0, 0, 0)); text(img, "z", W - 26, 8, grey); text(img, "z", W - 20, 2, grey)
    text(img, "Nightshift BIOS", 8, 8, bright, bold=True)
    text(img, "Version 0.98 'Night Owl'", 8, 18, grey)
    text(img, "(c) 1998 Nightshift PC Repair. No warranty.", 8, 28, grey)
    y = 52
    for line in ["Power-on self test ............... done", "", "Boot order:", "  1. NightBoot USB", "  2. whatever is inside", "",
                 "Booting from NightBoot USB"]:
        if line: text(img, line, 8, y, bright if line.startswith("Booting") else grey)
        y += 10
    text(img, "_", 8 + text_width("Booting from NightBoot USB") + 4, y - 10, bright)
    d.line((0, H - 22, W, H - 22), fill=(60, 60, 60))
    text(img, "DEL: Setup (please don't)    F12: Boot menu (also don't)", 8, H - 14, grey)
    return img


def nightboot(seconds):
    """The boot stick's own text-mode menu (blue, like a real repair disc), counting down to Windough 98."""
    img = Image.new("RGBA", (W, H), (0, 0, 120, 255))
    d = ImageDraw.Draw(img)
    hi, txt, dim, amber = (255, 255, 255), (200, 210, 255), (130, 140, 220), (240, 196, 92)
    d.rectangle((0, 0, W, 12), fill=(0, 140, 160)); text(img, "NightBoot USB 1.0", 4, 3, hi, bold=True)
    text(img, "Nightshift PC Repair", W - text_width("Nightshift PC Repair") - 4, 3, hi)
    cx, cy = 50, 52                          # the stick's mark: a crescent moon with a wrench through it
    d.ellipse((cx - 20, cy - 20, cx + 20, cy + 20), fill=amber)
    d.ellipse((cx - 11, cy - 26, cx + 27, cy + 12), fill=(0, 0, 120))
    d.line((cx - 22, cy + 18, cx + 10, cy - 14), fill=(200, 206, 220), width=3)
    d.ellipse((cx + 6, cy - 20, cx + 17, cy - 9), fill=(200, 206, 220)); d.ellipse((cx + 10, cy - 18, cx + 15, cy - 13), fill=(0, 0, 120))
    text(img, "NightBoot", 92, 34, amber, 2, bold=True)
    text(img, "The shop's own boot stick. Leaves their disk alone.", 92, 56, txt)
    box = (40, 88, W - 40, 176)
    d.rectangle(box, outline=txt); d.rectangle((box[0] + 2, box[1] + 2, box[2] - 2, box[3] - 2), outline=dim)
    items = ["Windough 98 diagnostics", "Memtest (out of order)", "Boot from their disk (not tonight)", "Reboot"]
    for i, item in enumerate(items):
        y = box[1] + 10 + i * 16
        if i == 0:
            d.rectangle((box[0] + 6, y - 3, box[2] - 6, y + 9), fill=(200, 210, 255)); text(img, " " + item, box[0] + 10, y, (0, 0, 120), bold=True)
        else:
            text(img, " " + item, box[0] + 10, y, dim)
    if seconds is not None:                 # None: the game writes the countdown itself
        t = "Starting Windough 98 diagnostics in %d ..." % seconds
        text(img, t, (W - text_width(t)) // 2, 190, hi)
        text(img, "Click or press Enter to start now", (W - text_width("Click or press Enter to start now")) // 2, 204, dim)
    return img


def no_signal():
    """A PC that does not start: the monitor's own message, nothing from the PC."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    box = (W // 2 - 70, H // 2 - 22, W // 2 + 70, H // 2 + 22)
    d.rectangle(box, fill=(20, 20, 70), outline=(120, 120, 200))
    text(img, "NO SIGNAL", W // 2 - text_width("NO SIGNAL", 2, True) // 2, H // 2 - 14, (230, 230, 255), 2, bold=True)
    t = "Check the cable. Or the PC."; text(img, t, W // 2 - text_width(t) // 2, H // 2 + 7, (160, 160, 220))
    return img


def desktop(selected=-1):
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    img.alpha_composite(wallpaper(), (0, 0))
    d = ImageDraw.Draw(img)
    for i, (kind, label) in enumerate(ICONS):
        x, y = icon_spot(i)
        ic = icon(kind)
        if i == selected:                       # a selected icon: a navy checkerboard over the picture, navy label
            ic = ic.copy(); ipx = ic.load()
            for yy in range(ic.height):
                for xx in range(ic.width):
                    if ipx[xx, yy][3] and (xx + yy) % 2 == 0: ipx[xx, yy] = SELECT + (255,)
        img.alpha_composite(ic, (x + 18, y))
        for k, part in enumerate(wrap(label, 9)):
            tx = x + 30 - text_width(part) // 2
            if i == selected:
                d.rectangle((tx - 1, y + 25 + k * 9, tx + text_width(part), y + 33 + k * 9), fill=SELECT)
                text(img, part, tx, y + 26 + k * 9, LIGHT)
            else:
                text(img, part, tx, y + 26 + k * 9, LIGHT, shadow=(8, 44, 44))
    img.alpha_composite(taskbar(), (0, H - TASKBAR))
    img.alpha_composite(begin_button(), (2, H - TASKBAR + 2))
    text(img, "02:14", W - 34, H - TASKBAR + 5, INK)
    return img


def taskbar_button(img, x, label, active=True):
    d = ImageDraw.Draw(img)
    tb = (x, H - TASKBAR + 2, x + 104, H - 2)
    d.rectangle(tb, fill=(212, 212, 212) if active else GREY); bevel(d, tb, raised=not active)
    text(img, label[:15], x + 5, H - TASKBAR + 5, INK, bold=active)


def begin_menu(img):
    d = ImageDraw.Draw(img)
    items = [("hardware", "Programs", True), ("readme", "Documents", True), ("taskmanajer", "Settings", False),
             ("readme", "Help (none)", False), (None, "", False), ("boot", "Shut Down...", False)]
    top = H - TASKBAR - 4 - 6 - len(items) * 16 + 10
    box = (2, top, 132, H - TASKBAR - 1)
    d.rectangle(box, fill=GREY); bevel(d, box)
    for y in range(box[1] + 3, box[3] - 2):     # the side banner
        t = (y - box[1]) / (box[3] - box[1])
        d.line((box[0] + 3, y, box[0] + 18, y), fill=(int(0 + 30 * t), int(0 + 60 * t), int(128 + 40 * t)))
    banner = Image.new("RGBA", (80, 10), (0, 0, 0, 0))
    text(banner, "Windough", 0, 1, (255, 255, 255), bold=True)
    text(banner, "98", 58, 1, (250, 170, 50), bold=True)
    banner = banner.rotate(90, expand=True)
    img.alpha_composite(banner, (box[0] + 6, box[3] - 84))
    y = box[1] + 5
    for kind, label, arrow in items:
        if kind is None:
            d.line((box[0] + 22, y + 3, box[2] - 4, y + 3), fill=SHADE); d.line((box[0] + 22, y + 4, box[2] - 4, y + 4), fill=LIGHT); y += 8; continue
        if label == "Programs":
            d.rectangle((box[0] + 20, y - 1, box[2] - 3, y + 13), fill=SELECT)
        img.alpha_composite(icon(kind).resize((12, 12), Image.NEAREST), (box[0] + 23, y))
        text(img, label, box[0] + 39, y + 3, LIGHT if label == "Programs" else INK)
        if arrow: text(img, "▸", box[2] - 10, y + 3, LIGHT if label == "Programs" else INK)
        y += 16
    sub_h = 7 * 15 + 5                      # Programs ▸ the shop's apps, moved up to stay above the taskbar
    sub_top = min(box[1] + 3, H - TASKBAR - 1 - sub_h)
    sub = (box[2] - 2, sub_top, box[2] + 118, sub_top + sub_h)
    d.rectangle(sub, fill=GREY); bevel(d, sub)
    for k, (kind, label) in enumerate([i for i in ICONS if i[0] not in ("bin", "readme")]):
        yy = sub[1] + 3 + k * 15
        img.alpha_composite(icon(kind).resize((12, 12), Image.NEAREST), (sub[0] + 4, yy))
        text(img, label, sub[0] + 20, yy + 3, INK)


# ---------------------------------------------------------------- review frames (the whole game screen)
def frame(screen, bezel_path, caption, pointer=None):
    s = screen.copy()
    if pointer is not None: s.alpha_composite(cursor(), pointer)
    out = Image.new("RGB", (1280, 720), (0x15, 0x1e, 0x27))
    big = scanlines(s.convert("RGB").resize((W * 2, H * 2), Image.NEAREST))
    out.paste(big, (48, 104))
    if bezel_path and os.path.exists(bezel_path):
        bez = Image.open(bezel_path).convert("RGBA").resize((878, 574), Image.NEAREST)
        o = out.convert("RGBA"); o.alpha_composite(bez, (32, 88)); out = o.convert("RGB")
    d = ImageDraw.Draw(out)
    d.text((982, 110), "CUSTOMER PC  (side panel unchanged)", fill=(220, 220, 220))
    for box in [(1016, 159, 1206, 299), (982, 324, 1246, 376), (982, 384, 1246, 418), (982, 424, 1246, 604)]:
        d.rectangle(box, outline=(110, 124, 136))
    d.rectangle((0, 682, 1280, 720), fill=(0, 0, 0))
    d.text((16, 694), caption, fill=(255, 255, 255))
    return out


def export_runtime(out):
    """0.59.0: the approved pieces as the game's files (art/ui/windough/). The screens that change while they show
    (the countdown, the rising dough) are exported without the moving part; the game draws it by the same rule."""
    os.makedirs(out, exist_ok=True)
    pieces = {"logo_dough": dough_logo(), "wallpaper": wallpaper(), "taskbar": taskbar(), "begin_button": begin_button(),
              "begin_button_pressed": begin_button(True), "cursor": cursor(), "bios": bios(), "no_signal": no_signal(),
              "nightboot_base": nightboot(None), "splash_windough_base": splash_windough(None)}
    for kind in [k for k, _ in ICONS] + ["usb", "speaker"]: pieces["icon_" + kind] = icon(kind)
    for name, img in pieces.items(): img.save(os.path.join(out, name + ".png"))
    chars = list(font5x7.G.keys())           # the font as a white atlas, 16 glyphs a row, 6 x 8 cells
    atlas = Image.new("RGBA", (16 * 6, ((len(chars) + 15) // 16) * 8), (0, 0, 0, 0))
    for i, ch in enumerate(chars):
        ox, oy = (i % 16) * 6, (i // 16) * 8
        for r, row in enumerate(font5x7.G[ch]):
            for c, cell in enumerate(row):
                if cell == "#": atlas.putpixel((ox + c, oy + r), (255, 255, 255, 255))
    atlas.save(os.path.join(out, "font5x7.png"))
    json.dump({"cell": [6, 8], "columns": 16, "advance": 6, "chars": "".join(chars)}, open(os.path.join(out, "font5x7.json"), "w"), ensure_ascii=False)
    return sorted(os.listdir(out))


def main(argv):
    if len(argv) > 2 and argv[1] == "--runtime":
        print(export_runtime(argv[2])); return
    out = argv[1]
    bezel = argv[2] if len(argv) > 2 else ""
    os.makedirs(out, exist_ok=True)
    for old in os.listdir(out):
        if old.endswith(".png") or old.endswith(".json"): os.remove(os.path.join(out, old))
    pieces = {"logo_dough": dough_logo(), "wallpaper": wallpaper(), "taskbar": taskbar(), "begin_button": begin_button(),
              "begin_button_pressed": begin_button(True), "cursor": cursor()}
    for kind in [k for k, _ in ICONS] + ["usb", "speaker"]: pieces["icon_" + kind] = icon(kind)
    for name, img in pieces.items(): img.save(os.path.join(out, name + ".png"))
    json.dump({"width": 5, "height": 7, "advance": 6, "line": 9, "glyphs": font5x7.G}, open(os.path.join(out, "font5x7.json"), "w"), ensure_ascii=False)

    hw = icon("hardware")
    s5 = desktop()
    begin_menu(s5)
    s5.alpha_composite(begin_button(True), (2, H - TASKBAR + 2))
    s6 = desktop()
    taskbar_button(s6, 54, "Hardware check")
    window(s6, (122, 16, 414, 236), "Hardware check", [
        "Hardware check (1 night minute)", "",
        "CPU .................. in place", "Memory ............... in place", "Graphics card ........ in place",
        "Disk ................. in place", "Power supply ......... in place", "CPU cooler ........... locked", "",
        "Everything is in place. No temperatures here:", "try the Stress lab."], hw, status="Done. Written in Findings.",
        buttons=("Run again", "Close"))
    frames = [
        (bios(), "1  Power on: the BIOS says only that it is booting the shop's stick (nothing about the parts)", None),
        (no_signal(), "1b A PC that does not start: just the monitor's NO SIGNAL", None),
        (nightboot(3), "2  NightBoot USB: the shop's boot stick, a text-mode menu counting down", None),
        (splash_windough(0.62), "3  Windough 98, Second Rising Edition: the dough rises along the tray", None),
        (desktop(selected=1), "4  The desktop: the shop's apps as icons (one selected), readme.txt, Bin of Regret, Begin, the night clock", (128, 92)),
        (s5, "5  Begin menu: Programs (the apps), Shut Down... turns the PC off", (160, 120)),
        (s6, "6  An app in a window: menu bar, report, buttons, status line; results go into Findings as before", (330, 214)),
    ]
    rendered = []
    for i, (s, cap, ptr) in enumerate(frames):
        name = "screen_%d" % (i + 1)
        s.save(os.path.join(out, name + ".png"))
        f = frame(s, bezel, cap, ptr); f.save(os.path.join(out, "mock_%d.png" % (i + 1))); rendered.append(f)
    sheet = Image.new("RGB", (1280, 360 * 4), (0, 0, 0))
    for i, f in enumerate(rendered[:8]): sheet.paste(f.resize((640, 360)), ((i % 2) * 640, (i // 2) * 360))
    sheet.save(os.path.join(out, "windough_sheet.png"))
    print("ok")


if __name__ == "__main__":
    main(sys.argv)
