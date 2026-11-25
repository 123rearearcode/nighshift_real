# ART-15 (part 1): the hardware family at board scale for the close-ups (hardware board, repair bench).
# The SAME drawings as the approved ART-10 storage parts (parts_comic.py), so a part never looks different
# from one view to the next, rendered larger: a 64 px per cell master the game scales to its cell size
# (about 25-26 px today). Adds the bare CPU (out of its tray, for the socket). Four quarter turns each,
# light fixed top-left.
import os, sys, math
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))   # shared comic/pixel helpers
import parts_comic as pc
from parts_comic import part

MASTER_CELL = 64


@part("cpu_bare", (3, 3))
def cpu_bare(p, w, h):
    # The processor alone: green substrate with its small parts, the nickel heat spreader, pin-1 mark.
    p.grad((5, 5, w - 6, h - 6), "#35805a", "#1f5537", 1.6, r=3, angle=0.5)        # substrate
    for k in range(10):
        p.rect((10 + k * 4, h - 13, 11 + k * 4, h - 11), "#c79a5a", 0)              # capacitors on the edges
        p.rect((w - 13, 12 + k * 4, w - 11, 13 + k * 4), "#c79a5a", 0)
    p.grad((16, 16, w - 17, h - 17), "#e9edf0", "#8a939b", 1.6, r=5, angle=0.7)   # heat spreader
    for k in range(10):
        p.line([(20, 21 + k * 9), (w - 21, 21 + k * 9)], (255, 255, 255, 38), 0.5)  # brushing
    p.rect((26, 26, w - 27, h - 27), "#c9cfd5", 0.8, r=3)                            # stamped inner field
    for y in (52, 60, 68):
        p.line([(34, y), (w - 34 - (y % 7) * 2, y)], "#98a0a8", 0.9)                # engraved marks, unreadable
    p.glint(24, 40, 18, 1.6); p.glint(32, 42, 7)
    p.poly([(7, h - 7), (16, h - 7), (7, h - 16)], "#e0b84e", 0.7)                  # pin-1 triangle


def render_scaled(name, rot=0, out_cell=MASTER_CELL, supersample=6):
    """Draw a part's 44-unit design at a larger supersampling and reduce it to out_cell px per cell."""
    old = pc.S
    pc.S = supersample
    try:
        (cw, ch), fn = pc.PARTS[name]
        p = pc.Pen(cw * pc.CELL, ch * pc.CELL)
        fn(p, cw * pc.CELL, ch * pc.CELL)
        a = np.rot90(np.array(p.im), -rot)
        im = Image.fromarray(np.ascontiguousarray(a))
        im = pc.light_pass(im)
        im = pc.ink_outline(im, 1.5)
        fw, fh = (ch, cw) if rot % 2 else (cw, ch)
        return im.resize((fw * out_cell, fh * out_cell), Image.LANCZOS)
    finally:
        pc.S = old


NAMES = ["gpu", "ram", "cpu_bare", "cooler", "psu", "storage_hdd", "storage_ssd"]

if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for n in NAMES:
        for r in range(4):
            render_scaled(n, r).save(os.path.join(out, f"{n}_r{r}.png"))
    print("ok", len(NAMES) * 4)
