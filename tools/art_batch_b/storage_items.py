# ART-10: storage silhouettes, top-down look into the under-counter storage. 22 native px per cell
# (44 px on screen at 2x, matching the proposed look-under grid). Footprints from storage_data.gd,
# hardware_catalog.gd and storage_sources.gd. Drawn at rotation 0, then turned; the outline and the
# top-left light are applied after turning so the light stays fixed.
import os, sys, json, math
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(__file__))
from px import canvas, c, mix, outline, light, OUT

CELL = 22
ITEMS = {}


def item(name, cells):
    def deco(fn):
        ITEMS[name] = (cells, fn)
        return fn
    return deco


def rr(d, box, fill, r=3):
    d.rounded_rectangle(box, r, fill=c(fill))


@item("pc_tower", (8, 6))
def pc_tower(d, w, h):
    rr(d, (2, 6, w - 3, h - 7), "#3b4049", 2)
    d.rectangle((2, 6, 22, h - 7), fill=c("#2a2e35"))                  # front bezel
    for y in range(14, 60, 9):
        d.line((6, y, 18, y), fill=c("#1e2126"))                          # drive bays
    d.ellipse((8, h - 30, 16, h - 22), fill=c("#59606b"))                 # power button
    d.point((12, h - 26), fill=c("#7fd18a"))
    d.rectangle((24, 10, w - 18, h - 11), fill=c("#454b55"))             # side panel
    d.rectangle((30, 16, w - 24, h - 17), fill=c("#4a515b"))             # pressed panel
    for y in range(22, 54, 4):                                            # vent holes
        for x in range(w - 70, w - 30, 4):
            d.point((x, y), fill=c("#262a30"))
    d.rectangle((w - 17, 6, w - 3, h - 7), fill=c("#30343b"))           # rear
    for y in range(16, h - 40, 6):
        d.line((w - 14, y, w - 6, y), fill=c("#1f2227"))                  # slot covers
    for y in (14, h - 18):
        d.ellipse((w - 13, y - 2, w - 9, y + 2), fill=c("#8a929c"))      # thumb screws
    for k in range(0, 60, 2):                                             # faint sheen on the panel
        d.point((40 + k, 20 + k // 2), fill=c("#525a65"))
    d.line((26, 64, 36, 64), fill=c("#c8b27a"))                           # string
    d.polygon([(36, 58), (52, 58), (56, 64), (52, 70), (36, 70)], fill=c("#e2d8bd"))   # blank repair tag
    d.point((40, 64), fill=c("#3b4049"))


@item("pc_compact", (7, 5))
def pc_compact(d, w, h):
    rr(d, (2, 6, w - 3, h - 7), "#3b4049", 2)
    d.rectangle((2, 6, 18, h - 7), fill=c("#2a2e35"))
    for y in range(14, 40, 9):
        d.line((5, y, 15, y), fill=c("#1e2126"))
    d.ellipse((6, h - 26, 13, h - 19), fill=c("#59606b"))
    d.point((9, h - 23), fill=c("#7fd18a"))
    d.rectangle((20, 10, w - 16, h - 11), fill=c("#454b55"))
    d.rectangle((26, 15, w - 22, h - 16), fill=c("#4a515b"))
    for y in range(20, 44, 4):
        for x in range(w - 58, w - 26, 4):
            d.point((x, y), fill=c("#262a30"))
    d.rectangle((w - 15, 6, w - 3, h - 7), fill=c("#30343b"))
    for y in range(14, h - 30, 6):
        d.line((w - 12, y, w - 6, y), fill=c("#1f2227"))
    for y in (13, h - 17):
        d.ellipse((w - 11, y - 2, w - 7, y + 2), fill=c("#8a929c"))


@item("gpu", (8, 1))
def gpu(d, w, h):
    d.rectangle((9, 4, w - 3, h - 5), fill=c("#2d3138"))                # shroud edge
    d.rectangle((9, 4, w - 3, 6), fill=c("#5b636d"))                     # backplate
    for x in range(16, w - 22, 3):
        d.line((x, 9, x, h - 8), fill=c("#7d8793"))                       # fins seen through the edge
    d.rectangle((2, 2, 8, h - 3), fill=c("#b8c0c8"))                     # bracket
    d.line((5, 5, 5, h - 6), fill=c("#7d8793"))
    d.rectangle((w - 22, 3, w - 13, 7), fill=c("#17191d"))               # power connector


@item("ram", (1, 4))
def ram(d, w, h):
    d.rectangle((4, 2, w - 5, h - 3), fill=c("#2f6b45"))                 # PCB
    for y in range(4, h - 4, 2):
        if 50 <= y <= 53: continue                                         # key notch
        d.line((4, y, 6, y), fill=c("#d8b04a"))                           # gold contacts
    d.rectangle((4, 50, 6, 53), fill=(0, 0, 0, 0))
    for i in range(4):
        y = 6 + i * 20
        d.rectangle((9, y, w - 7, y + 13), fill=c("#1b1d22"))            # chips
        d.line((9, y, w - 7, y), fill=c("#3a3e46"))


@item("cpu", (3, 3))
def cpu(d, w, h):
    rr(d, (2, 2, w - 3, h - 3), "#b9c6d0", 5)                             # clamshell tray
    rr(d, (6, 6, w - 7, h - 7), "#a7b5c0", 4)
    d.rectangle((13, 13, w - 14, h - 14), fill=c("#2f6b45"))             # substrate
    d.rectangle((17, 17, w - 18, h - 18), fill=c("#b7bec6"))             # heat spreader
    d.rectangle((20, 20, w - 21, h - 21), fill=c("#c6ccd3"))
    d.polygon([(14, h - 15), (18, h - 15), (14, h - 19)], fill=c("#d8b04a"))   # pin-1 mark


@item("storage_hdd", (2, 1))
def storage_hdd(d, w, h):
    d.rectangle((2, 3, w - 4, h - 4), fill=c("#9aa3ab"))
    d.ellipse((5, 6, 14, 15), fill=c("#7d8690"))                          # spindle cover
    d.ellipse((8, 9, 11, 12), fill=c("#b8c0c8"))
    d.rectangle((17, 5, w - 7, h - 6), fill=c("#d9d6cc"))                # blank label
    d.rectangle((w - 4, 4, w - 3, h - 5), fill=c("#1b1d22"))             # connectors


@item("storage_ssd", (2, 1))
def storage_ssd(d, w, h):
    d.rectangle((4, 4, w - 6, h - 5), fill=c("#3a3f47"))
    d.rectangle((9, 6, w - 11, h - 7), fill=c("#cfd2d6"))                # blank label
    d.line((9, 6, w - 11, 6), fill=c("#4f86c6"))
    d.rectangle((w - 6, 6, w - 4, h - 7), fill=c("#1b1d22"))


@item("psu", (3, 2))
def psu(d, w, h):
    d.rectangle((2, 2, w - 3, h - 3), fill=c("#26292e"))
    d.rectangle((3, 8, 7, h - 9), fill=c("#17191d"))                      # power socket end
    d.rectangle((4, 12, 6, h - 13), fill=c("#3a3e46"))
    cx, cy, r = 40, h // 2, 16
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=c("#1c1e22"))
    for rad in (13, 9, 5):
        d.ellipse((cx - rad, cy - rad, cx + rad, cy + rad), outline=c("#4a4f58"))
    d.line((cx - r, cy, cx + r, cy), fill=c("#4a4f58"))
    d.line((cx, cy - r, cx, cy + r), fill=c("#4a4f58"))
    d.rectangle((11, 8, 20, h - 9), fill=c("#b9bcc0"))                   # blank rating sticker


@item("cooler", (2, 2))
def cooler(d, w, h):
    rr(d, (3, 3, w - 4, h - 4), "#202226", 6)
    cx, cy = w // 2 - 0.5, h // 2 - 0.5
    d.ellipse((5, 5, w - 6, h - 6), fill=c("#2d3036"))
    for k in range(7):
        a = k * 2 * math.pi / 7
        for t in range(6, 17):
            bend = a + t * 0.05
            d.point((round(cx + t * math.cos(bend)), round(cy + t * math.sin(bend))), fill=c("#4a4f58"))
    d.ellipse((cx - 6, cy - 6, cx + 6, cy + 6), fill=c("#1b1d21"))
    d.ellipse((cx - 3, cy - 3, cx + 3, cy + 3), fill=c("#8d949d"))


@item("vacuum", (4, 2))
def vacuum(d, w, h):
    # Electronics vacuum / blower: cylinder body, loop handle, cone, crevice nozzle, vented end, cord.
    d.line((84, 22, 86, 22), fill=c("#1b1d21")); d.line((86, 22, 86, 30), fill=c("#1b1d21"))   # cord
    d.rectangle((2, 21, 12, 24), fill=c("#202226"))                                   # crevice nozzle
    d.line((2, 21, 12, 21), fill=c("#3a3d44"))
    d.polygon([(12, 18), (24, 13), (24, 33), (12, 27)], fill=c("#2a2c31"))            # cone
    d.line((13, 19, 23, 14), fill=c("#4a4e57"))
    d.rounded_rectangle((22, 12, 72, 34), 4, fill=c("#5a7fa6"))                       # body
    d.rectangle((24, 13, 70, 16), fill=c("#86aad0"))                                   # top light
    d.rectangle((24, 28, 70, 33), fill=c("#3e5a7a"))                                   # underside
    d.line((26, 14, 66, 14), fill=c("#c4dbef"))                                        # glint
    d.rectangle((22, 12, 25, 34), fill=c("#1f2125")); d.rectangle((68, 12, 72, 34), fill=c("#1f2125"))   # rubber caps
    d.rounded_rectangle((32, 3, 60, 13), 4, fill=c("#3e5a7a"))                        # loop handle
    d.rectangle((36, 7, 56, 11), fill=(0, 0, 0, 0))
    d.line((34, 4, 58, 4), fill=c("#86aad0"))
    d.rectangle((44, 2, 49, 4), fill=c("#e0b84e")); d.point((45, 2), fill=c("#f6dd8a"))   # switch
    d.rectangle((72, 14, 84, 32), fill=c("#2b3a4d"))                                   # vented end
    for y in range(16, 31, 3):
        d.line((74, y, 82, y), fill=c("#5a7fa6")); d.line((74, y + 1, 82, y + 1), fill=c("#1b2430"))
    for x in (36, 46, 56):
        d.line((x, 18, x, 26), fill=c("#4b6c8f"))                                      # seams


@item("brush", (3, 1))
def brush(d, w, h):
    # Anti-static cleaning brush: tapered handle with hanging hole, crimped ferrule, splayed bristles.
    d.polygon([(3, 9), (8, 7), (36, 8), (40, 7), (40, 15), (36, 14), (8, 15), (3, 13)], fill=c("#8c2f2a"))
    d.line((8, 8, 36, 9), fill=c("#c0504a")); d.line((8, 14, 36, 13), fill=c("#5e1f1c"))
    d.rectangle((5, 10, 7, 12), fill=(0, 0, 0, 0))                                     # hanging hole
    d.rectangle((40, 6, 47, 16), fill=c("#b8c0c8"))                                    # ferrule
    d.line((40, 6, 47, 6), fill=c("#e6ebef")); d.line((40, 16, 47, 16), fill=c("#7d8793"))
    for x in (42, 45):
        d.line((x, 6, x, 16), fill=c("#8a939d"))                                       # crimps
    d.polygon([(47, 6), (63, 2), (63, 20), (47, 16)], fill=c("#26262a"))              # bristles
    for k, y in enumerate(range(3, 20, 2)):
        d.line((48, 8 + (y - 3) * 6 // 17, 62, y), fill=c("#3e3e45" if k % 2 else "#4c4c54"))
    for y in range(3, 20, 3):
        d.point((63, y), fill=c("#6a6a72"))                                            # tips


@item("pick", (2, 1))
def pick(d, w, h):
    # Cleaning pick: steel shaft with a bent tip, ribbed plastic handle.
    d.line((3, 8, 5, 10), fill=c("#c9d0d6")); d.line((5, 10, 20, 10), fill=c("#b8c0c8"))   # hooked tip + shaft
    d.line((6, 11, 20, 11), fill=c("#7d8793"))
    d.rounded_rectangle((20, 7, 41, 14), 3, fill=c("#d0675d"))                         # handle
    d.line((22, 8, 39, 8), fill=c("#ec9a90")); d.line((22, 13, 39, 13), fill=c("#9c4038"))
    for x in range(26, 39, 3):
        d.line((x, 9, x, 12), fill=c("#a8483f"))                                       # grip ribs
    d.rectangle((19, 9, 21, 12), fill=c("#8a939d"))                                    # collar


@item("cloth", (2, 2))
def cloth(d, w, h):
    # Folded microfibre cloth: layered edges, stitched hem, a turned-back corner.
    d.polygon([(6, 8), (39, 6), (41, 39), (8, 41)], fill=c("#3f7770"))                # lower layers
    d.polygon([(4, 5), (37, 3), (39, 36), (6, 38)], fill=c("#62a59b"))                # top layer
    for y in range(6, 37, 2):
        for x in range(6 + (y // 2) % 2, 37, 3):
            d.point((x, y), fill=c("#5a978e"))                                          # weave
    for t in range(0, 31, 3):
        d.point((7 + t, 6 - t // 15), fill=c("#a6d4cb")); d.point((8 + t, 35 - t // 15), fill=c("#3f7770"))   # stitched hem
        d.point((7, 7 + t), fill=c("#a6d4cb")); d.point((36, 6 + t), fill=c("#3f7770"))
    d.polygon([(26, 3), (37, 3), (38, 15)], fill=c("#86c3b9"))                         # turned-back corner
    d.line((26, 3, 38, 15), fill=c("#3f7770"))
    d.line((39, 37, 41, 39), fill=c("#2e5853")); d.line((6, 38, 8, 41), fill=c("#2e5853"))


@item("syringe", (1, 2))
def syringe(d, w, h):
    # Thermal paste syringe: thumb pad, plunger, flange, marked barrel with grey paste, tip and cap.
    d.rectangle((6, 1, 15, 2), fill=c("#9aa2aa")); d.line((6, 1, 15, 1), fill=c("#d3d9de"))   # thumb pad
    d.rectangle((9, 3, 12, 8), fill=c("#b8bec4")); d.line((9, 3, 9, 8), fill=c("#e1e6ea"))   # plunger rod
    d.rectangle((3, 9, 18, 11), fill=c("#c9ced3")); d.line((3, 9, 18, 9), fill=c("#eef1f3"))  # flange
    d.rectangle((6, 12, 15, 34), fill=c("#dfe3e6"))                                    # barrel
    d.rectangle((7, 19, 14, 34), fill=c("#8f979e"))                                    # paste
    d.line((8, 20, 8, 33), fill=c("#b9c0c6"))                                          # paste sheen
    d.line((7, 13, 7, 34), fill=c("#f6f8f9"))                                          # barrel glint
    for y in range(14, 34, 4):
        d.line((13, y, 15, y), fill=c("#5d646c"))                                      # marks, no numbers
    d.polygon([(7, 35), (14, 35), (12, 40), (9, 40)], fill=c("#b8bec4"))              # tip
    d.rectangle((9, 40, 12, 43), fill=c("#e07a3c")); d.line((9, 40, 12, 40), fill=c("#f3a36e"))   # cap


def render(name, rot=0):
    (cw, ch), fn = ITEMS[name]
    im, d = canvas(cw * CELL, ch * CELL)
    fn(d, cw * CELL, ch * CELL)
    a = np.array(im)
    a = np.rot90(a, -rot)          # clockwise quarter turns, matching footprint(size, rotation) swap
    im = Image.fromarray(np.ascontiguousarray(a))
    im = outline(im)
    return light(im, 0.18, 0.28)


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    manifest = {}
    for name, ((cw, ch), _) in ITEMS.items():
        for r in range(4):
            im = render(name, r)
            fw, fh = (ch, cw) if r % 2 else (cw, ch)
            assert im.size == (fw * CELL, fh * CELL), (name, r, im.size)
            im.save(os.path.join(out, f"{name}_r{r}.png"))
        manifest[name] = {"footprint_cells": [cw, ch], "native_px": [cw * CELL, ch * CELL]}
    json.dump(manifest, open(os.path.join(out, "footprints.json"), "w"), indent=1)
    print(len(ITEMS), "items")
