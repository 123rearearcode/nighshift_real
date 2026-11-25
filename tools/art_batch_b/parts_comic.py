# ART-10 parts, revision 2 (user, 23 Nov 2026: "Parts are supposed to be in a completely different style;
# comic book but semi-realistic"). Illustrated, not pixel art: drawn at 4x and reduced to the logical size
# (44 px per storage cell, 1:1 on the 1280 x 720 screen). Bold ink outline, flat comic tones, a fixed
# top-left light and halftone dots in the shade, applied after turning so the light never rotates.
import os, sys, math
import numpy as np
from PIL import Image, ImageDraw

S = 4                 # supersampling
CELL = 44             # logical px per cell
INK = (21, 22, 26, 255)


def C(h, a=255):
    return (int(h[1:3], 16), int(h[3:5], 16), int(h[5:7], 16), a)


class Pen:
    def __init__(self, w, h):
        self.im = Image.new("RGBA", (w * S, h * S), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)

    def _b(self, box):
        return [v * S for v in box]

    def rect(self, box, fill, ink=1.0, r=0):
        w = round(ink * S) if ink else 0
        if r:
            self.d.rounded_rectangle(self._b(box), r * S, fill=C(fill), outline=INK if w else None, width=w)
        else:
            self.d.rectangle(self._b(box), fill=C(fill), outline=INK if w else None, width=w)

    def grad(self, box, c0, c1, ink=1.0, r=0, angle=0.0, shape="rect"):
        """Linear gradient (angle 0 = top to bottom) clipped to a rect/rounded rect/ellipse, then inked."""
        x0, y0, x1, y1 = [round(v * S) for v in box]
        w, h = max(1, x1 - x0 + 1), max(1, y1 - y0 + 1)
        yy, xx = np.mgrid[0:h, 0:w]
        t = (yy / max(1, h - 1)) * math.cos(angle) + (xx / max(1, w - 1)) * math.sin(angle)
        t = (t - t.min()) / max(1e-6, (t.max() - t.min()))
        a0, a1 = np.array(C(c0), float), np.array(C(c1), float)
        g = (a0[None, None, :] * (1 - t[..., None]) + a1[None, None, :] * t[..., None]).astype(np.uint8)
        tile = Image.fromarray(g, "RGBA")
        mask = Image.new("L", (w, h), 0)
        md = ImageDraw.Draw(mask)
        if shape == "ellipse": md.ellipse((0, 0, w - 1, h - 1), fill=255)
        elif r: md.rounded_rectangle((0, 0, w - 1, h - 1), r * S, fill=255)
        else: md.rectangle((0, 0, w - 1, h - 1), fill=255)
        self.im.paste(tile, (x0, y0), mask)
        wd = round(ink * S) if ink else 0
        if wd:
            if shape == "ellipse": self.d.ellipse((x0, y0, x1, y1), outline=INK, width=wd)
            elif r: self.d.rounded_rectangle((x0, y0, x1, y1), r * S, outline=INK, width=wd)
            else: self.d.rectangle((x0, y0, x1, y1), outline=INK, width=wd)

    def glint(self, x, y, length=6, width=1.0):
        self.line([(x, y), (x + length, y - length * 0.5)], (255, 255, 255, 230), width)

    def ell(self, box, fill, ink=1.0):
        w = round(ink * S) if ink else 0
        self.d.ellipse(self._b(box), fill=C(fill) if fill else None, outline=INK if w else None, width=w)

    def ring(self, box, col, width=1.0):
        self.d.ellipse(self._b(box), outline=C(col) if isinstance(col, str) else col, width=max(1, round(width * S)))

    def poly(self, pts, fill, ink=1.0):
        p = [(x * S, y * S) for x, y in pts]
        self.d.polygon(p, fill=C(fill))
        if ink:
            self.d.line(p + [p[0]], fill=INK, width=round(ink * S), joint="curve")

    def line(self, pts, col, width=1.0):
        self.d.line([(x * S, y * S) for x, y in pts], fill=C(col) if isinstance(col, str) else col,
                    width=max(1, round(width * S)), joint="curve")


PARTS = {}


def part(name, cells):
    def deco(fn):
        PARTS[name] = (cells, fn)
        return fn
    return deco


@part("gpu", (8, 1))
def gpu(p, w, h):
    # The card lying in the storage tilted towards you, so the fan side reads at grazing angle.
    p.grad((14, 4, w - 6, h - 5), "#4a525d", "#22262c", 1.6, r=4)              # shroud face
    p.grad((14, 4, w - 6, 9), "#6f7884", "#4b535e", 1.0)                         # backplate edge
    for x in range(22, w - 12, 9):
        p.line([(x, 6), (x + 4, 6)], "#97a1ac", 0.6)
    p.poly([(14, h - 6), (36, h - 6), (52, 10), (26, 10)], "#353b44", 1.0)       # angular facets
    p.poly([(w - 60, 10), (w - 30, 10), (w - 8, h - 6), (w - 44, h - 6)], "#353b44", 1.0)
    for cx in (110, 236):                                                         # two fans, foreshortened
        p.grad((cx - 62, 11, cx + 62, h - 8), "#2a2e34", "#111215", 1.2, shape="ellipse")
        for k in range(9):
            x = cx - 54 + k * 13
            p.line([(x, 15), (x + 9, h - 12)], "#4a505a", 1.0)                    # blades, edge-on
        p.ell((cx - 13, 18, cx + 13, h - 15), "#0f1012", 1.0)
        p.ell((cx - 8, 20, cx + 8, h - 18), "#8f98a1", 0.8)                       # blank hub caps
        p.ring((cx - 62, 11, cx + 62, h - 8), "#6c7480", 0.8)
    p.line([(56, h - 7), (w - 70, h - 7)], "#4fb7a8", 1.0)                       # accent strip, no logo
    p.rect((w - 64, 4, w - 40, 11), "#121316", 1.0)                              # 8-pin power
    for x in range(w - 61, w - 42, 4):
        p.rect((x, 6, x + 2, 9), "#3a3d44", 0)
    p.grad((3, 2, 14, h - 3), "#e1e7ec", "#8f98a1", 1.4, angle=math.pi / 2)     # bracket
    for y in range(7, h - 7, 6):
        p.rect((6, y, 11, y + 3), "#4b525b", 0.6)
    p.glint(20, h - 8, 10); p.glint(w - 30, 18, 8)


@part("ram", (1, 4))
def ram(p, w, h):
    p.grad((9, 3, w - 6, h - 4), "#35805a", "#1f5537", 1.6, r=2, angle=0.4)   # PCB
    for y in range(6, h - 6, 3):
        if 104 <= y <= 110: continue
        p.line([(4, y), (10, y)], "#e0b84e", 1.4)                               # gold fingers
    p.rect((3, 104, 9, 110), "#000000", 0)
    p.d.rectangle(p._b((3, 104, 9, 110)), fill=(0, 0, 0, 0))                    # key notch
    for i in range(4):
        y = 10 + i * 32
        p.rect((15, y, w - 11, y + 22), "#1d1f24", 1.0, r=1)                    # memory chips
        p.line([(18, y + 7), (28, y + 7)], "#4a4e57", 0.6)                      # unreadable marking
        p.line([(18, y + 11), (25, y + 11)], "#4a4e57", 0.6)
        p.line([(16, y + 2), (w - 12, y + 2)], "#3a3e46", 0.6)
    for y in range(140, 150, 4):
        for x in (14, 20, 26):
            p.rect((x, y, x + 3, y + 2), "#c79a5a", 0)                          # SMD parts
    p.rect((13, 154, w - 10, h - 8), "#e9e6dc", 0.8)                            # blank label
    for x in range(16, w - 12, 2):
        p.line([(x, 158), (x, 162 + (x % 3))], "#6a6a66", 0.5)                   # barcode, no text
    p.line([(30, 6), (30, 136)], "#3f8a5d", 0.5)                                 # traces


@part("cpu", (3, 3))
def cpu(p, w, h):
    p.grad((3, 3, w - 4, h - 4), "#e3eaef", "#a9b6c0", 1.6, r=12, angle=0.7)   # clamshell tray
    p.rect((10, 10, w - 11, h - 11), "#b5c2cc", 1.0, r=9)
    p.line([(16, 8), (w - 18, 8)], "#f3f7fa", 1.4)
    p.rect((22, 22, w - 23, h - 23), "#2d6a45", 1.4, r=2)                       # substrate
    for k in range(6):
        p.rect((26 + k * 3, h - 28, 27 + k * 3, h - 26), "#c79a5a", 0)         # caps
        p.rect((w - 28, 30 + k * 3, w - 26, 31 + k * 3), "#c79a5a", 0)
    p.grad((31, 31, w - 32, h - 32), "#e4e9ed", "#8e979f", 1.4, r=4, angle=0.7)   # heat spreader
    for k in range(8):
        p.line([(34, 36 + k * 8), (w - 36, 36 + k * 8)], (255, 255, 255, 40), 0.5)    # brushing
    p.glint(40, 50, 14, 1.4); p.glint(48, 52, 6)
    p.line([(40, 40), (w - 58, 40)], "#f2f5f7", 1.0)
    for y in (58, 64, 70):
        p.line([(46, y), (w - 46 - (y % 7) * 2, y)], "#9ba3ab", 0.8)              # engraved marks, unreadable
    p.poly([(24, h - 24), (31, h - 24), (24, h - 31)], "#e0b84e", 0.6)          # pin-1 triangle


@part("psu", (3, 2))
def psu(p, w, h):
    p.grad((3, 3, w - 4, h - 4), "#3b3f47", "#1c1e22", 1.8, r=3, angle=0.6)    # casing
    p.rect((6, 22, 18, h - 22), "#141518", 1.0)                                  # AC socket
    p.rect((9, 27, 15, h - 27), "#3a3e45", 0.6)
    p.rect((7, 10, 17, 18), "#141518", 0.8)                                      # switch
    p.rect((22, 10, 44, h - 10), "#b8bec4", 1.0)                                 # rating sticker
    for y in range(16, h - 14, 5):
        p.line([(25, y), (41 - (y % 4) * 2, y)], "#7c838a", 0.6)                 # unreadable lines
    cx, cy, r = 88, h / 2, 37
    p.ell((cx - r, cy - r, cx + r, cy + r), "#16171a", 1.4)
    for k in range(9):                                                            # fan blades under the grille
        a = k * 2 * math.pi / 9
        pts = [(cx + 9 * math.cos(a), cy + 9 * math.sin(a)), (cx + 33 * math.cos(a + 0.25), cy + 33 * math.sin(a + 0.25)),
               (cx + 33 * math.cos(a + 0.55), cy + 33 * math.sin(a + 0.55)), (cx + 9 * math.cos(a + 0.5), cy + 9 * math.sin(a + 0.5))]
        p.poly(pts, "#3b3f47", 0.5)
    for rad in (34, 27, 20, 13):
        p.ring((cx - rad, cy - rad, cx + rad, cy + rad), "#8d959e", 1.1)          # wire grille
    p.line([(cx - r, cy), (cx + r, cy)], "#8d959e", 1.1)
    p.line([(cx, cy - r), (cx, cy + r)], "#8d959e", 1.1)
    p.ell((cx - 7, cy - 7, cx + 7, cy + 7), "#2a2d33", 1.0)
    p.glint(cx - 26, cy - 14, 9)
    for x, y in [(8, 7), (w - 9, 7), (8, h - 8), (w - 9, h - 8)]:
        p.ell((x - 2, y - 2, x + 2, y + 2), "#7c838a", 0.6)


@part("cooler", (2, 2))
def cooler(p, w, h):
    p.grad((4, 4, w - 5, h - 5), "#d3d9de", "#79828b", 1.6, r=8, angle=0.7)    # aluminium fins at the corners
    for k in range(8, w - 8, 3):
        p.line([(k, 6), (k, 11)], "#c9d0d6", 0.6); p.line([(k, h - 11), (k, h - 6)], "#c9d0d6", 0.6)
    cx, cy = w / 2, h / 2
    p.grad((7, 7, w - 8, h - 8), "#2f3238", "#121316", 1.4, shape="ellipse", angle=0.7)   # fan shroud
    for k in range(7):
        a = k * 2 * math.pi / 7
        pts = [(cx + 10 * math.cos(a), cy + 10 * math.sin(a)), (cx + 34 * math.cos(a + 0.35), cy + 34 * math.sin(a + 0.35)),
               (cx + 33 * math.cos(a + 0.8), cy + 33 * math.sin(a + 0.8)), (cx + 10 * math.cos(a + 0.7), cy + 10 * math.sin(a + 0.7))]
        p.poly(pts, "#3a3e46", 0.6)
        p.line([pts[0], pts[1]], "#5c626c", 0.6)
    p.ell((cx - 11, cy - 11, cx + 11, cy + 11), "#17181b", 1.0)
    p.ell((cx - 7, cy - 7, cx + 7, cy + 7), "#a9b0b7", 0.8)                       # blank hub sticker
    for x, y in [(9, 9), (w - 10, 9), (9, h - 10), (w - 10, h - 10)]:
        p.ell((x - 4, y - 4, x + 4, y + 4), "#121316", 0.8)                       # push pins
        p.ell((x - 2, y - 2, x + 2, y + 2), "#e8e8e4", 0)


@part("storage_hdd", (2, 1))
def storage_hdd(p, w, h):
    p.grad((3, 3, w - 6, h - 4), "#d1d8de", "#8c959e", 1.6, r=2, angle=0.6)    # aluminium lid
    p.rect((7, 7, 32, h - 8), "#b9c0c7", 0.8, r=3)                               # raised platter cover
    p.ell((11, 13, 29, 31), "#9aa2aa", 1.0)                                       # spindle
    p.ell((17, 19, 23, 25), "#d3d9de", 0.6)
    p.glint(8, 14, 8)
    p.rect((36, 6, w - 10, h - 7), "#f0ede4", 0.8)                                # blank label
    p.rect((38, 9, 54, 15), "#c4473c", 0)                                          # colour block, no logo text
    for x in range(40, w - 13, 2):
        p.line([(x, 28), (x, 33)], "#55554f", 0.5)                                # barcode
    for y in (19, 23):
        p.line([(40, y), (w - 16, y)], "#a3a199", 0.6)
    p.rect((w - 6, 9, w - 3, h - 10), "#141518", 0.6)                             # connectors
    for x, y in [(6, 6), (6, h - 7), (33, 6), (33, h - 7)]:
        p.ell((x - 1.5, y - 1.5, x + 1.5, y + 1.5), "#5d646c", 0)


@part("storage_ssd", (2, 1))
def storage_ssd(p, w, h):
    p.grad((8, 4, w - 9, h - 5), "#525965", "#262a30", 1.6, r=3, angle=0.6)    # 2.5" case
    p.rect((14, 8, w - 15, h - 9), "#d9dde1", 0.8)                                # blank label
    p.rect((14, 8, w - 15, 13), "#3f7fc4", 0.6)                                    # colour band
    for y in (18, 22, 26):
        p.line([(18, y), (w - 22 - (y % 5) * 3, y)], "#8a9097", 0.6)
    p.rect((w - 9, 11, w - 5, h - 12), "#141518", 0.6)                            # SATA


def light_pass(im):
    a = np.array(im).astype(np.float32)
    alpha = a[:, :, 3] > 0
    ink = alpha & (a[:, :, :3].sum(axis=2) < 90)
    body = alpha & ~ink

    def shifted(m, dx, dy):
        out = np.zeros_like(m)
        H, W = m.shape
        out[max(dy, 0):H + min(dy, 0), max(dx, 0):W + min(dx, 0)] = m[max(-dy, 0):H + min(-dy, 0), max(-dx, 0):W + min(-dx, 0)]
        return out
    hi = body & ~shifted(alpha, 2 * S, 2 * S)
    sh = body & ~shifted(alpha, -5 * S, -5 * S) & ~hi
    a[hi, :3] += (255 - a[hi, :3]) * 0.28
    a[sh, :3] *= 0.70
    yy, xx = np.mgrid[0:a.shape[0], 0:a.shape[1]]
    hatch = ((xx + yy) % (3 * S)) < max(1, S // 2)
    a[sh & hatch, :3] *= 0.55                                                       # comic hatching in the shade
    dots = (((xx % (4 * S)) - 2 * S) ** 2 + ((yy % (4 * S)) - 2 * S) ** 2) < (0.8 * S) ** 2
    mid = body & ~hi & ~sh & shifted(alpha, -9 * S, -9 * S) & ~shifted(alpha, -12 * S, -12 * S)
    a[mid & dots, :3] *= 0.8                                                         # halftone where light turns
    out = Image.fromarray(a.clip(0, 255).astype(np.uint8))
    thick = shifted(alpha, round(1.5 * S), round(2 * S)) & ~alpha                     # the part's own thickness
    base = np.zeros_like(np.array(out)); base[thick] = (12, 13, 16, 255)
    under = Image.fromarray(base); under.alpha_composite(out)
    return under


def ink_outline(im, width=1.6):
    a = np.array(im)
    m = a[:, :, 3] > 0
    r = round(width * S)
    grown = np.zeros_like(m)
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy <= r * r:
                grown |= np.roll(np.roll(m, dy, 0), dx, 1)
    base = np.zeros_like(a)
    base[grown] = INK
    out = Image.fromarray(base)
    out.alpha_composite(im)
    return out


def render(name, rot=0):
    (cw, ch), fn = PARTS[name]
    pad = 2
    p = Pen(cw * CELL, ch * CELL)
    fn(p, cw * CELL, ch * CELL)
    a = np.rot90(np.array(p.im), -rot)
    im = Image.fromarray(np.ascontiguousarray(a))
    im = light_pass(im)
    im = ink_outline(im, 1.5)
    fw, fh = (ch, cw) if rot % 2 else (cw, ch)
    return im.resize((fw * CELL, fh * CELL), Image.LANCZOS)


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for name in PARTS:
        for r in range(4):
            render(name, r).save(os.path.join(out, f"{name}_r{r}.png"))
    print(len(PARTS), "parts")
