#!/usr/bin/env python3
"""Repair-bench background drafts from the user's desk painting (27 November 2026).

The user supplied a painted desk: worn wooden boards, a teal work mat with a dark rim, and a dark tool tray
on the right. They asked for it on the repair bench "and maybe pixelate the mat a bit more". The bench keeps
its own layout (the PC and tray on the left, the controls panel from x 700), so this script rebuilds the
picture at the game's 1280 x 720 instead of stretching it:

- wood: the user's boards, scaled to 1280 x 720; where the mat and tray were, the same boards are continued
  from the clean left part of each row (so the plank lines run on);
- mat: nine-sliced from the user's mat (corners and rim kept, interior texture reused) and fitted to the
  layout, then pixelated in blocks of N game pixels with a small palette;
- option A: the mat under the PC and tray, the controls on the dark tray material;
- option B: one wide mat under both, a narrow tool tray at the right edge.

Drafts only (art rule D167): nothing here is loaded by the game until the user approves an exact file.
Usage: python3 -I tools/art_batch_d/bench_mat.py <source.png> <out_dir> [case_interior.png]
"""
import sys
from PIL import Image, ImageDraw, ImageEnhance

W, H = 1280, 720
SCALE = W / 1672.0
MAT_SRC = (182, 121, 1406, 838)          # outer edge of the mat's rim in the source painting
MAT_IN = (225, 165, 1368, 798)           # the teal interior, clear of the rim's shadow
POCKET_SRC = (1500, 228, 1660, 826)      # the long pocket of the tool tray
SMALL_POCKET_SRC = (1500, 50, 1660, 200)
STRIP_SRC = (1486, 0, 1672, 941)


def wood_canvas(src):
    """The user's boards with the mat and tray painted out, at source size, then scaled to 1280 x 720."""
    out = src.copy()
    px, opx = out.load(), src.load()
    for y in range(src.height):
        band = MAT_SRC[1] - 2 <= y <= MAT_SRC[3] + 2
        # Plain boards to continue from: left of the mat inside its band; mid-desk above and below it
        # (the left corner has the cup rings and the lamp's glow).
        # Right of x 1486 the boards are mirrored from just left of it, so there is no seam where the tray was.
        clean = list(range(40, 182)) if band else list(range(1485, 1299, -1))
        span = len(clean)
        x0 = MAT_SRC[0] - 2 if band else 1486
        for x in range(x0, src.width):
            if band and MAT_SRC[2] + 2 < x < 1486: continue      # original wood between mat and tray
            k = (x - x0) % (2 * span)
            sx = clean[k] if k < span else clean[2 * span - 1 - k]
            px[x, y] = opx[sx, y]
    return out.resize((W, H), Image.LANCZOS)


def nine_slice(piece, size, corner):
    """Stretch a framed piece to `size`, keeping `corner`-pixel corners; edges and centre stretch."""
    w, h = piece.size
    tw, th = size
    c = corner
    out = Image.new("RGBA", size)
    xs = [(0, c, 0, c), (c, w - c, c, tw - c), (w - c, w, tw - c, tw)]
    ys = [(0, c, 0, c), (c, h - c, c, th - c), (h - c, h, th - c, th)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            if dx1 <= dx0 or dy1 <= dy0: continue
            out.paste(piece.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.LANCZOS), (dx0, dy0))
    return out


def mat_piece(src, size, block):
    """The mat at `size` game pixels: rim nine-sliced (lightly pixelated), interior texture stretched to fit and
    pixelated in `block`-pixel blocks."""
    tw, th = size
    rim = src.crop(MAT_SRC).convert("RGBA")
    rim = rim.resize((round(rim.width * SCALE), round(rim.height * SCALE)), Image.LANCZOS)
    frame = pixelate(nine_slice(rim, size, 18), 2, 32)
    iw, ih = tw - 30, th - 30
    inner = src.crop(MAT_IN).resize((iw, ih), Image.LANCZOS)
    inner = ImageEnhance.Contrast(inner).enhance(1.4)        # the grime reads as pixels instead of a smooth wash
    frame.paste(pixelate(inner, block, 9), (15, 15))
    return frame


def pixelate(img, block, colours):
    """Blocks of `block` game pixels and a small palette, no dithering."""
    small = img.convert("RGB").resize((max(1, img.width // block), max(1, img.height // block)), Image.BOX)
    small = small.quantize(colors=colours, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    out = small.resize((small.width * block, small.height * block), Image.NEAREST)
    canvas = img.convert("RGB").copy()
    canvas.paste(out, (0, 0))
    return canvas


def pocket(src, box, size, block):
    piece = src.crop(box).convert("RGBA")
    piece = piece.resize((round(piece.width * SCALE), round(piece.height * SCALE)), Image.LANCZOS)
    return pixelate(nine_slice(piece, size, 16), max(2, block // 2), 24)


def build(src, option, block, wood_block=1):
    bg = wood_canvas(src)
    if wood_block > 1: bg = pixelate(bg, wood_block, 48)       # user's pick: the desk lightly pixelated to match
    if option == "A":
        mat_rect = (28, 96, 672, 662)
        panel = (684, 96, 1268, 662)
        bg.paste(pocket(src, POCKET_SRC, (panel[2] - panel[0], panel[3] - panel[1]), block), panel[:2])
    else:
        mat_rect = (24, 96, 1222, 662)
        strip = (1230, 96, 1274, 662)
        bg.paste(pocket(src, SMALL_POCKET_SRC, (strip[2] - strip[0], 120), block), strip[:2])
        bg.paste(pocket(src, POCKET_SRC, (strip[2] - strip[0], strip[3] - strip[1] - 132), block), (strip[0], strip[1] + 132))
    size = (mat_rect[2] - mat_rect[0], mat_rect[3] - mat_rect[1])
    bg.paste(mat_piece(src, size, block), mat_rect[:2])
    return bg


def mock_ui(img, case_png):
    """Review only: where the PC, tray and controls sit on top (not part of the art)."""
    out = img.convert("RGBA")
    d = ImageDraw.Draw(out)
    if case_png:
        case = Image.open(case_png).convert("RGBA").resize((620, 400), Image.NEAREST)
        out.alpha_composite(case, (40, 110))
    d.rectangle((40, 540, 660, 650), outline=(155, 167, 169), width=2)
    d.text((48, 546), "SERVICE TRAY / move parts here, then refit", fill=(240, 240, 240))
    d.text((40, 24), "NIGHTSHIFT - clean the PC  (title line)", fill=(240, 240, 240))
    for i, (x, y, w, h) in enumerate([(700, 110, 250, 40), (960, 110, 250, 40), (700, 160, 120, 36), (830, 160, 120, 36),
                                     (960, 160, 120, 36), (1090, 160, 120, 36), (700, 210, 520, 40), (700, 556, 520, 85)]):
        d.rectangle((x, y, x + w, y + h), fill=(52, 62, 74, 230), outline=(180, 190, 200))
    d.text((708, 566), "status line: what the bench says now", fill=(240, 240, 240))
    d.rectangle((1164, 20, 1252, 62), fill=(52, 62, 74, 230), outline=(180, 190, 200))
    d.text((1180, 34), "Pause", fill=(240, 240, 240))
    return out.convert("RGB")


def main(argv):
    src = Image.open(argv[1]).convert("RGB")
    out_dir = argv[2].rstrip("/")
    case_png = argv[3] if len(argv) > 3 else ""
    blocks = (3, 4, 6)
    swatches = []
    for option in ("A", "B"):
        for block in blocks:
            img = build(src, option, block)
            img.save("%s/bench_bg_%s_px%d.png" % (out_dir, option, block))
            mock_ui(img, case_png).save("%s/preview_%s_px%d.png" % (out_dir, option, block))
            if option == "B": swatches.append(img.crop((720, 280, 940, 380)).resize((660, 300), Image.NEAREST))
    # Side-by-side close-up of the mat: the user's painting at game size, then each pixel size.
    orig = src.resize((W, H), Image.LANCZOS).crop((720, 280, 940, 380)).resize((660, 300), Image.NEAREST)
    sheet = Image.new("RGB", (660 * 2 + 30, 300 * 2 + 70), (20, 22, 26))
    d = ImageDraw.Draw(sheet)
    for i, (label, sw) in enumerate([("your painting (at game size)", orig)] + [("pixel %d" % b, s) for b, s in zip(blocks, swatches)]):
        x, y = 10 + (i % 2) * 670, 30 + (i // 2) * 335
        sheet.paste(sw, (x, y))
        d.text((x, y - 18), label + "  (3x zoom)", fill=(235, 235, 235))
    sheet.save("%s/mat_pixel_sizes.png" % out_dir)
    # The user's picks (27 Nov): layout A, mat pixel 4, wood lightly pixelated (2). This is the file to approve.
    final = build(src, "A", 4, 2)
    final.save("%s/bench_background.png" % out_dir)
    mock_ui(final, case_png).save("%s/preview_bench_background.png" % out_dir)


if __name__ == "__main__":
    main(sys.argv)
