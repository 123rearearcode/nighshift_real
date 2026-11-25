# ART-06 clipboard (room scale), ART-07 ticket close-up skin, ART-09 customer PC tower (room scale).
# Native pixels; the game shows them at exactly 2x nearest-neighbour. Light: cool window fill from the
# left, so left/top faces are lighter and right faces darker.
import os, sys
from PIL import Image
sys.path.insert(0, os.path.dirname(__file__))
from px import canvas, c, mix, outline, OUT


def clipboard_resting():
    """Lying flat on the counter top, turned a little, seen from the shop floor. The board is laid out
    in its own flat coordinates (u across, v from the clip end) and projected: turned 14 degrees, then
    foreshortened to half depth like the counter top. The clip lever lies flat, as on a real board."""
    import math
    im, d = canvas(54, 36)
    a, k, ox, oy = math.radians(-14), 0.5, 27, 19

    def P(u, v):                       # board space (centre origin) -> sprite pixels
        x = u * math.cos(a) - v * math.sin(a)
        y = u * math.sin(a) + v * math.cos(a)
        return (round(ox + x), round(oy + y * k))

    def quad(u0, v0, u1, v1):
        return [P(u0, v0), P(u1, v0), P(u1, v1), P(u0, v1)]
    d.polygon([(x, y + 1) for x, y in quad(-15, -21, 15, 21)], fill=c("#5e4029"))     # board edge
    d.polygon(quad(-15, -21, 15, 21), fill=c("#8a6240"))                              # board
    d.line([P(-14, -21), P(14, -21)], fill=c("#a67b55"))
    d.polygon(quad(-12, -15, 12, 19), fill=c("#ebe4d0"))                               # paper
    d.line([P(-12, -15), P(12, -15)], fill=c("#f6f1e3"))
    d.line([P(12, -14), P(12, 19)], fill=c("#d2c9b0"))
    d.polygon([(x, y + 1) for x, y in quad(-8, -21, 8, -12)], fill=c("#59616b"))   # clip thickness
    d.polygon(quad(-8, -21, 8, -12), fill=c("#9aa3ab"))                                 # clip plate
    d.line([P(-8, -21), P(8, -21)], fill=c("#d3d9de"))
    d.polygon(quad(-6, -25, 6, -20), fill=c("#b8c0c8"))                                 # lever, lying flat
    d.line([P(-6, -25), P(6, -25)], fill=c("#e6ebef"))
    for u in (-5, 5):
        d.point(P(u, -15), fill=c("#4a5059"))                                           # rivets
    d.line([P(-8, -11), P(8, -11)], fill=c("#cfc6ad"))                                  # clip shadow on paper
    return outline(im)


def clipboard_upright():
    """Frontal, held up / hover state."""
    im, d = canvas(36, 48)
    d.rounded_rectangle((2, 6, 33, 45), 3, fill=c("#8a6240"))
    d.line((4, 7, 31, 7), fill=c("#a67b55"))
    d.line((3, 44, 32, 44), fill=c("#6f4e33")); d.line((32, 8, 32, 44), fill=c("#6f4e33"))
    d.rectangle((5, 11, 30, 41), fill=c("#ebe4d0"))
    d.line((5, 11, 30, 11), fill=c("#f6f1e3")); d.line((30, 12, 30, 41), fill=c("#cfc6ad"))
    d.rectangle((10, 6, 25, 12), fill=c("#9aa3ab"))
    d.line((10, 6, 25, 6), fill=c("#c9d0d6")); d.line((10, 12, 25, 12), fill=c("#6b737c"))
    d.point((12, 9), fill=c("#5d646d")); d.point((23, 9), fill=c("#5d646d"))
    d.rounded_rectangle((12, 1, 23, 7), 2, outline=c("#b8c0c8"))                      # lever loop
    d.line((13, 1, 22, 1), fill=c("#e6ebef"))
    return outline(im)


def ticket_skin():
    """Close-up: a big frontal clipboard with a blank sheet. Text is drawn by the game."""
    W, H = 300, 350
    im, d = canvas(W, H)
    d.rounded_rectangle((4, 22, W - 5, H - 5), 12, fill=c("#8a6240"))
    for k in range(14):                                               # hardboard grain
        y = 34 + k * 22
        d.line((12, y, W - 14, y + (k % 3) - 1), fill=c("#80593a"))
    d.line((10, H - 7, W - 12, H - 7), fill=c("#6a4a30"))
    d.line((W - 6, 32, W - 6, H - 14), fill=c("#6a4a30"))
    d.line((12, 23, W - 14, 23), fill=c("#a47a55"))
    # paper with a lifted bottom-right corner
    d.polygon([(22, 52), (W - 22, 52), (W - 22, H - 44), (W - 44, H - 22), (22, H - 22)], fill=c("#ebe4d0"))
    d.polygon([(W - 22, H - 44), (W - 44, H - 22), (W - 44, H - 44)], fill=c("#d6cdb3"))
    d.line((W - 22, H - 44, W - 44, H - 22), fill=c("#b9ae92"))
    d.line((22, 52, W - 22, 52), fill=c("#f6f1e3"))
    d.line((W - 23, 53, W - 23, H - 45), fill=c("#d9d1b9"))
    d.line((23, H - 23, W - 45, H - 23), fill=c("#d9d1b9"))
    for x in range(30, W - 30, 7):                                    # faint paper fibre, no lines
        for y in range(60 + (x % 3) * 5, H - 30, 23):
            d.point((x, y), fill=c("#e4dcc6"))
    # clip
    cx = W // 2
    d.rounded_rectangle((cx - 52, 10, cx + 52, 64), 6, fill=c("#8f98a1"))
    d.rounded_rectangle((cx - 48, 14, cx + 48, 60), 5, fill=c("#a9b2ba"))
    d.line((cx - 46, 15, cx + 46, 15), fill=c("#d3d9de"))
    d.rectangle((cx - 48, 54, cx + 48, 60), fill=c("#7d8690"))
    for x in (cx - 36, cx + 36):
        d.ellipse((x - 4, 34, x + 4, 42), fill=c("#6b737c"))
        d.point((x - 1, 36), fill=c("#c3cad1"))
    d.rounded_rectangle((cx - 30, 2, cx + 30, 18), 7, outline=c("#c3cad1"), width=4)   # lever
    d.line((cx - 26, 3, cx + 26, 3), fill=c("#e8ecef"))
    return outline(im)


def pc_tower():
    """Closed customer tower, three-quarter view: front, right side and a sliver of top."""
    im, d = canvas(64, 98)
    fx0, fx1, y0, y1, dx, dy = 3, 36, 12, 94, 22, 8
    d.polygon([(fx1, y0), (fx1 + dx, y0 - dy), (fx1 + dx, y1 - dy), (fx1, y1)], fill=c("#2a2e34"))   # side
    d.polygon([(fx0, y0), (fx0 + dx, y0 - dy), (fx1 + dx, y0 - dy), (fx1, y0)], fill=c("#505762"))   # top
    d.rectangle((fx0, y0, fx1, y1), fill=c("#3a3f47"))                                                # front
    d.line((fx0, y0, fx1, y0), fill=c("#68707c"))
    d.line((fx0, y0, fx0, y1), fill=c("#4a515b"))
    # front details
    d.rectangle((fx0 + 3, y0 + 4, fx1 - 3, y0 + 10), fill=c("#30343b"))      # 5.25" bay cover
    d.rectangle((fx0 + 3, y0 + 12, fx1 - 3, y0 + 18), fill=c("#30343b"))
    d.line((fx0 + 3, y0 + 4, fx1 - 3, y0 + 4), fill=c("#454b55"))
    d.line((fx0 + 3, y0 + 12, fx1 - 3, y0 + 12), fill=c("#454b55"))
    d.ellipse((fx0 + 4, y0 + 22, fx0 + 10, y0 + 28), fill=c("#59606b"))     # power button
    d.point((fx0 + 7, y0 + 25), fill=c("#2a2e34"))
    d.point((fx0 + 13, y0 + 25), fill=c("#7fd18a"))                         # power LED
    d.rectangle((fx1 - 12, y0 + 23, fx1 - 9, y0 + 27), fill=c("#17191d"))  # USB
    d.rectangle((fx1 - 7, y0 + 23, fx1 - 4, y0 + 27), fill=c("#17191d"))
    for y in range(y0 + 34, y1 - 6, 3):                                      # front mesh
        for x in range(fx0 + 4 + (y % 2), fx1 - 3, 2):
            d.point((x, y), fill=c("#2b2f35"))
    d.rectangle((fx0 + 1, y1 - 2, fx0 + 6, y1), fill=c("#1b1d21"))         # feet
    d.rectangle((fx1 - 6, y1 - 2, fx1 - 1, y1), fill=c("#1b1d21"))
    # side vents and thumb screws
    for k in range(6):
        y = y0 + 20 + k * 4
        d.line((fx1 + 6, y - 2, fx1 + dx - 6, y - 2 - 5), fill=c("#212429"))
    d.line((fx1 + 1, y0, fx1 + 1, y1), fill=c("#353a41"))
    for y in (y0 + 6, y1 - 14):
        d.point((fx1 + dx - 3, y - dy + 2), fill=c("#8a929c"))
    return outline(im)


if __name__ == "__main__":
    out = sys.argv[1]
    for name, fn in [("ART-06/clipboard_resting", clipboard_resting), ("ART-06/clipboard_upright", clipboard_upright),
                     ("ART-07/ticket_closeup_skin", ticket_skin), ("ART-09/pc_tower_closed", pc_tower)]:
        os.makedirs(os.path.join(out, os.path.dirname(name)), exist_ok=True)
        fn().save(os.path.join(out, name + ".png"))
    print("ok")
