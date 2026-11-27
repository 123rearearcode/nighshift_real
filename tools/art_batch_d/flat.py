# Helper for walls.py (0.58.5): the flat counter front built from the approved Batch A pictures; mirrors counter_art.gd.
# Preview of the flat front-wall layout built only from the approved Batch A pictures (mirrors counter_art.gd).
import sys
from PIL import Image
A = "/home/claude/nighshift_real/art/rooms/counter_batch_a/"
R = "/home/claude/nighshift_real/"
SRC = (1672, 941); SCR = (1280, 720)
K = SCR[0] / SRC[0]
FILES = dict(shell="room-shell-v2.png", counter="counter-foreground-v2.png", morning="exterior-morning-v2.png", dusk="exterior-dusk-v2.png",
             front_closed="front-door-closed-v2.png", front_open="front-door-open-v2.png", sign="hanging-sign-v2.png",
             workshop_closed="workshop-door-closed-v2.png", workshop_open="workshop-door-open-v2.png",
             shutter_up="shutter-up-v2.png", shutter_down="shutter-down-v2.png", light="light-overlay-v2.png")
T = {k: Image.open(A + v).convert("RGBA") for k, v in FILES.items()}

FLOOR_Y = 505
GLASS = (52, 106, 552, 399)
DOOR = (52, 106, 161, 399)
STILE = 18
TILE_SRC_X, TILE_SRC_W = 641, 134          # 4 whole tiles of the shell's flat wall
TILE_PITCH_Y = 31.9
WALL_SRC_H = 660                            # source wall height above the floor line
TILE_OFFSETS = [0, 2, 4, 1, 3, 5]           # vertical tile offsets per strip so stains do not line up
SHUTTER = (44, 56, 568, 50)
SH_BAND = (291, 698)                        # ten whole slats of the down shutter
SIGN = (390, 128, 60, 122)


def region(c, key, src, dst):
    sx, sy, sw, sh = src; dx, dy, dw, dh = dst
    dw_i, dh_i = max(1, round(dw)), max(1, round(dh))
    p = T[key].crop((round(sx), round(sy), round(sx + sw), round(sy + sh))).resize((dw_i, dh_i), Image.NEAREST)
    c.alpha_composite(p, (round(dx), round(dy)))


def full(c, key, a=1.0):
    im = T[key]
    s = im.resize((round(im.width * K), round(im.height * SCR[1] / SRC[1])), Image.NEAREST)
    if a < 1: s.putalpha(s.getchannel("A").point(lambda v: int(v * a)))
    c.alpha_composite(s)


ROWS=[28, 62, 95, 128, 161, 193, 226, 257, 288, 319, 349, 381, 412, 445, 478, 511, 544, 577, 610]
SHIFTS=[0, 6, 13, 3, 9]
def flat_wall(c):
    ky = SCR[1] / SRC[1]
    w = 169 * K; x = 606 * K - w; i = 0
    while x > -w:
        cut = ROWS[SHIFTS[i % len(SHIFTS)]]
        y = 0.0
        for a, b in [(0, ROWS[0]), (cut, ROWS[-1]), (ROWS[0], cut), (ROWS[-1], SRC[1])]:
            if b <= a: continue
            h = (b - a) * ky
            region(c, "shell", (606, a, 169, b - a), (x, y, w + 0.5, h + 0.5)); y += h
        x -= w; i += 1


def frame(c):
    gx, gy, gw, gh = GLASS
    stile = (242, 450, 60, 650)             # the door's own left stile (no hinges in this stretch)
    rail = (330, 107, 300, 64)              # the door's own top rail
    for x in (gx, DOOR[0] + DOOR[2] - STILE, gx + gw - STILE):
        region(c, "front_closed", stile, (x, gy, STILE, gh))
    region(c, "front_closed", rail, (gx, gy, gw, STILE + 1))


def shutter_down(c):
    x, y, w, _ = SHUTTER
    s = w / 1610
    region(c, "shutter_down", (82, 87, 1610, SH_BAND[0] - 87), (x, y, w, (SH_BAND[0] - 87) * s))
    bottom_h = (804 - SH_BAND[1]) * s
    yy = y + (SH_BAND[0] - 87) * s
    end = FLOOR_Y - bottom_h
    band = (SH_BAND[1] - SH_BAND[0]) * s
    while yy < end - 0.5:
        h = min(band, end - yy)
        region(c, "shutter_down", (82, SH_BAND[0], 1610, h / s), (x, yy, w, h))
        yy += h
    region(c, "shutter_down", (82, SH_BAND[1], 1610, 804 - SH_BAND[1]), (x, end, w, bottom_h))


def render(morning=True, front_open=False, ws_open=False, shutter=False, customer=True):
    c = Image.new("RGBA", SCR, (0x15, 0x23, 0x2b, 255))
    full(c, "shell")
    flat_wall(c)
    gx, gy, gw, gh = GLASS
    region(c, "morning" if morning else "dusk", (280 + gx * 1.032, 302 + gy * 1.032, gw * 1.032, gh * 1.032), GLASS)
    frame(c)
    if front_open:
        s = DOOR[3] / 1325
        h = 1409 * s
        region(c, "front_open", (298, 84, 419, 1409), (DOOR[0], DOOR[1] - (h - DOOR[3]) / 2, 419 * s, h))
    else:
        region(c, "front_closed", (242, 108, 540, 1325), DOOR)
    region(c, "sign", (269, 249, 486, 984), SIGN)
    region(c, "workshop_open" if ws_open else "workshop_closed", (246, 20, 536, 1494) if ws_open else (225, 114, 579, 1308),
           (1109, 100, 139, 395) if ws_open else (1062, 118, 186, 372))
    if shutter: shutter_down(c)
    else: region(c, "shutter_up", (82, 87, 1611, 142), SHUTTER)
    if customer and not shutter:
        m = Image.open(R + "art/customers/t001_mara.png").convert("RGBA"); m = m.resize((240, 344), Image.NEAREST)
        c.alpha_composite(m, (680 - 120, 488 - 344))
    full(c, "counter")
    if not morning: full(c, "light", 0.25)
    return c


if __name__ == "__main__":
    out = sys.argv[1]
    shots = [render(), render(front_open=True, ws_open=True), render(morning=False), render(morning=False, shutter=True, customer=False)]
    sheet = Image.new("RGB", (2560, 1440))
    for i, im in enumerate(shots):
        sheet.paste(im.convert("RGB"), ((i % 2) * 1280, (i // 2) * 720))
    sheet.save(out)
