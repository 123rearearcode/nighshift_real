# 0.59.2 (D186) drafts from the user's notebook, 28 November 2026. Nothing here is loaded by the game until the
# user approves an exact revision (AGENTS rule 11).
#   - "Floor looks bad, it's supposed to be linoleum": a sheet linoleum floor for the counter room (replaces the
#     0.58.5 checker print; same canvas and floor line as tools/art_batch_d/termopan.py).
#   - "The stock room needs some work. Let's create same Balkanic post-communist vibe w/ it" (and: "Should have
#     some tiles in it (part w the common wall w the hallway)"; "each PC fills one shelf row, seen from the
#     front"): the stock room's back wall, a front-on steel rack, and PCs seen from the front.
#   - "In the repair bench, there should be extra steps ... moving the PC onto the table, and opening the case":
#     the closed side panels (tower, compact) and a laptop's bottom cover, on the cells of PCLayout.
#   python3 -I tools/art_batch_f/day1.py <out dir>
import os, sys, json, math, random, hashlib
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(HERE, "..", "art_batch_b"))
from px import canvas, c, outline, light, OUT   # noqa: E402
import parts_comic as pc                        # noqa: E402

INK = (18, 20, 24, 255)


def load(path):
    return Image.open(os.path.join(ROOT, path)).convert("RGBA")


def chunky(im, k):
    """Draw small, show big: the Batch A pixel look."""
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


# ---------------- counter room: sheet linoleum ----------------

W, H = 1672, 941                     # Batch A source canvas
F = W / 1280
FLOOR = int(round(505 * F))
VP = (int(round(640 * F)), int(round(330 * F)))


def linoleum():
    """One continuous sheet, not tiles: a faded brown-and-ochre parquet print of the 1980s, its pattern
    projected on the floor plane toward the vanishing point; a seam where two widths meet, a worn grey path
    from the door to the counter, scuffs, and a dark skirting strip along the wall. Drawn at a third of the
    size and enlarged, so its pixels match the room."""
    k = 3
    w, h = W // k + 1, H // k + 1
    fl, vx, vy = FLOOR // k, VP[0] / k, VP[1] / k
    ys, xs = np.mgrid[0:h, 0:w].astype(float)
    below = ys > fl
    z = np.where(below, (fl - vy) / np.maximum(ys - vy, 1e-3), 1.0)        # 1 at the wall line, smaller nearer
    u = (xs - vx) * z / 9.0                                                  # floor-plane coordinates
    v = (1.0 / np.maximum(z, 1e-3)) * 6.0
    # herringbone-like print: blocks of three strips, alternating direction
    bu, bv = np.floor(u / 3.0), np.floor(v / 3.0)
    across = ((bu + bv) % 2 == 0)
    strip = np.where(across, np.floor(v) % 3, np.floor(u) % 3)
    tones = np.array([[150, 108, 66], [166, 124, 78], [140, 100, 62]], float)
    img = tones[strip.astype(int) % 3]
    edge = np.where(across, (v % 1.0) < 0.07, (u % 1.0) < 0.07)
    img[edge] = img[edge] * 0.78
    rnd = np.random.default_rng(186)
    img *= (0.94 + 0.08 * rnd.random(img.shape[:2]))[..., None]              # printed grain
    img = img * 0.82 + np.array([196, 170, 128]) * 0.18                      # faded by years of sun
    # worn path from the front door (left) to the counter
    path = np.exp(-(((u + 7.0) * 0.18 - (v - 10.0) * 0.10) ** 2) * 0.9) * np.clip((v - 4) / 6, 0, 1)
    img = img * (1 - 0.35 * path[..., None]) + np.array([170, 160, 140]) * 0.35 * path[..., None]
    img[(np.abs(u - 2.0) < 0.04 * np.maximum(1, 1 / z))] *= 0.7               # the seam between two widths
    a = np.zeros((h, w, 4), np.uint8)
    a[..., :3] = np.clip(img, 0, 255).astype(np.uint8)
    a[..., 3] = np.where(below, 255, 0)
    im = Image.fromarray(a)
    d = ImageDraw.Draw(im)
    r = random.Random(186)
    for _ in range(70):                                                      # scuffs
        x = r.randint(0, w); y = r.randint(fl + 6, h)
        d.line((x, y, x + r.randint(3, 12), y + r.randint(-1, 1)), fill=(92, 70, 48, 140))
    d.rectangle((0, fl - 2, w, fl + 1), fill=(58, 46, 36, 255))              # skirting strip
    d.line((0, fl - 3, w, fl - 3), fill=INK)
    im = chunky(im, k).crop((0, 0, W, H))
    return im


# ---------------- stock room: back wall, a steel rack and PCs, from the front ----------------

ROOM = (1200, 920)                    # world size: 4 x 2 bays of 300 x 460 (storage_data.gd BAY_STRIDE)


def stock_wall():
    """The stock room's back wall, behind the racks (world pixels, drawn at half and enlarged): lower half the
    green oil paint of every Balkan office, a dark band, whitewash above with water stains and a crack, a
    fluorescent tube, a plug on surface conduit, a 1990s wall calendar; the left quarter is white-and-blue
    tiles, the wall shared with the tiled hallway; a concrete floor strip with a drain."""
    k = 2
    w, h = ROOM[0] // k, ROOM[1] // k
    im = Image.new("RGBA", (w, h), (226, 222, 206, 255)); d = ImageDraw.Draw(im)
    dado = int(h * 0.52)
    d.rectangle((0, dado, w, h), fill=(70, 106, 86, 255))                    # oil-paint green
    d.rectangle((0, dado - 4, w, dado), fill=(44, 70, 56, 255))              # painted band
    r = random.Random(7)
    for _ in range(900):                                                     # paint wear and grime
        x, y = r.randrange(w), r.randrange(h)
        if y > dado: d.point((x, y), fill=(84, 122, 100, 255) if r.random() < 0.5 else (58, 90, 72, 255))
        else: d.point((x, y), fill=(212, 206, 188, 255))
    for cx, cy, rr in ((w * 0.62, 40, 46), (w * 0.88, 120, 30)):             # water stains
        for k2 in range(3):
            d.ellipse((cx - rr + k2 * 6, cy - rr * 0.6 + k2 * 4, cx + rr - k2 * 6, cy + rr * 0.6 - k2 * 4), outline=(196, 180, 146, 255))
    pts = [(w * 0.72, 0)]
    for _ in range(8): pts.append((pts[-1][0] + r.randint(-6, 8), pts[-1][1] + r.randint(10, 20)))
    d.line(pts, fill=(150, 142, 124, 255), width=1)                          # crack
    tw = int(w * 0.26)                                                       # tiles: the hallway wall
    for y in range(0, h - 40, 14):
        for x in range(0, tw, 14):
            col = (226, 232, 234, 255) if (x // 14 + y // 14) % 7 else (128, 164, 188, 255)
            if r.random() < 0.03: col = (196, 200, 196, 255)                 # a chipped one
            d.rectangle((x, y, x + 13, y + 13), fill=col, outline=(150, 158, 160, 255))
    d.rectangle((tw, 0, tw + 3, h - 40), fill=(150, 146, 136, 255))          # edge trim
    d.rectangle((0, h - 40, w, h), fill=(124, 120, 112, 255))                # concrete floor
    for _ in range(500):
        x, y = r.randrange(w), r.randrange(h - 40, h)
        d.point((x, y), fill=(104, 100, 94, 255) if r.random() < 0.5 else (140, 136, 128, 255))
    d.ellipse((w * 0.5 - 10, h - 22, w * 0.5 + 10, h - 12), fill=(70, 68, 64, 255))   # drain
    d.rectangle((w * 0.35, 18, w * 0.65, 26), fill=(240, 244, 236, 255), outline=INK)  # fluorescent tube
    d.rectangle((w * 0.33, 14, w * 0.67, 18), fill=(150, 154, 156, 255), outline=INK)
    d.line((w * 0.94, dado - 30, w * 0.94, 0), fill=(186, 182, 170, 255), width=3)     # conduit + socket
    d.rectangle((w * 0.94 - 6, dado - 40, w * 0.94 + 6, dado - 28), fill=(232, 228, 214, 255), outline=INK)
    cal = (int(w * 0.80), 60, int(w * 0.80) + 54, 140)                       # wall calendar (no text)
    d.rectangle(cal, fill=(238, 232, 214, 255), outline=INK)
    d.rectangle((cal[0] + 4, cal[1] + 4, cal[2] - 4, cal[1] + 40), fill=(118, 150, 170, 255))
    for yy in range(cal[1] + 46, cal[3] - 4, 6):
        for xx in range(cal[0] + 6, cal[2] - 6, 7): d.point((xx, yy), fill=(90, 90, 90, 255))
    return chunky(im, k)


# Front-view sizes in world pixels (storage_data.gd CELL = 18): width = the footprint's width in cells, height
# = what the stock room draws (storage_view.gd FRONT_HEIGHT). Shelf boards sit under each shelf rectangle.
CELLW = 18
SHELF_TOP, SHELF_H, SHELF_GAP, SHELF_X = 52, 108, 20, 30


def rack_front():
    """A front-on steel rack for one bay (280 x 440 world px, drawn at half): grey-green angle-iron uprights
    with slot holes, three painted steel shelf boards with a lip under the game's three shelf rows, bolts,
    rust chips."""
    k = 2
    w, h = 280 // k, 440 // k
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    STEEL, HI, SH = (104, 122, 112, 255), (140, 160, 148, 255), (66, 80, 72, 255)
    for x0 in (4, w - 11):
        d.rectangle((x0, 18, x0 + 6, h - 2), fill=STEEL, outline=INK)
        d.line((x0 + 1, 19, x0 + 1, h - 3), fill=HI)
        for y in range(24, h - 6, 8): d.rectangle((x0 + 2, y, x0 + 4, y + 3), fill=SH)
    r = random.Random(3)
    for i in range(3):
        y = (SHELF_TOP + SHELF_H + i * (SHELF_H + SHELF_GAP)) // k
        d.rectangle((6, y, w - 7, y + 6), fill=STEEL, outline=INK)
        d.line((7, y + 1, w - 8, y + 1), fill=HI)
        for x in (9, w - 14): d.ellipse((x, y + 2, x + 3, y + 5), fill=(170, 172, 168, 255))
        for _ in range(5):
            x = r.randrange(12, w - 16); d.rectangle((x, y + 2, x + 2, y + 3), fill=(150, 104, 72, 255))
    return chunky(im, k)


def pc_face(w_cells, h_px, side=False):
    """A customer desktop from the front (or its side, when it is turned on the shelf), one shelf row high:
    pixel art at half size, enlarged 2x. Width = its footprint's width in cells."""
    k = 2
    cw, ch = w_cells * CELLW // k, h_px // k
    im, d = canvas(cw, ch)
    d.rectangle((1, 1, cw - 2, ch - 1), fill=c("#3a3f47")); d.rectangle((1, 1, cw - 2, 3), fill=c("#505762"))
    if side:
        d.rectangle((4, 6, cw - 5, ch - 4), fill=c("#454b55"))                    # side panel
        for y in range(10, ch - 8, 3):
            for x in range(cw - 22, cw - 8, 3): d.point((x, y), fill=c("#262a30"))
        for y in (6, ch - 7): d.point((3, y), fill=c("#8a929c"))                   # thumbscrews
    else:
        d.rectangle((4, 6, cw // 3, 9), fill=c("#30343b")); d.rectangle((4, 11, cw // 3, 14), fill=c("#30343b"))
        d.ellipse((cw - 14, 6, cw - 8, 12), fill=c("#59606b")); d.point((cw - 11, 9), fill=c("#7fd18a"))
        for y in range(17, ch - 3, 2):
            for x in range(4 + y % 2, cw - 4, 2): d.point((x, y), fill=c("#2b2f35"))
    d.line((cw // 2, ch - 1, cw // 2 + 4, ch - 1), fill=c("#c8b27a"))           # repair tag string
    return chunky(light(outline(im), 0.16, 0.26), k)


def laptop_face(finish, w_cells):
    """A closed laptop from the front (6 cells) or its side (4 cells): a thin slab with the lid seam."""
    col = {"silver": ("#b9b4a6", "#97927f", "#7d786a"), "graphite": ("#3e434b", "#2c3036", "#24272c")}[finish]
    im, d = canvas(w_cells * CELLW // 2, 6)
    W2 = im.width
    d.rectangle((1, 1, W2 - 2, 2), fill=c(col[0])); d.rectangle((1, 3, W2 - 2, 4), fill=c(col[2]))
    d.line((1, 3, W2 - 2, 3), fill=c(col[1]))
    d.point((4, 4), fill=c("#7fd18a")); d.point((7, 4), fill=c("#d9b25a"))
    return chunky(outline(im), 2)


def stock_mock():
    """Part of the new stock room at zoom 1, in the game's own geometry: back wall, two bays with racks, a
    tower (front) with a two-laptop pile on it, a compact turned sideways, parts boxes, a laptop alone."""
    room = stock_wall().crop((0, 0, 620, 470)).copy()
    def shelf(bay, i): return (10 + bay * 300 + SHELF_X, 10 + SHELF_TOP + i * (SHELF_H + SHELF_GAP))
    for bay in (0, 1): room.alpha_composite(rack_front(), (10 + bay * 300, 10))
    x, y = shelf(0, 0); bottom = y + SHELF_H
    t = pc_face(8, 92); room.alpha_composite(t, (x, bottom - t.height))
    top = bottom - t.height
    for f in ("graphite", "silver"):
        lf = laptop_face(f, 6); room.alpha_composite(lf, (x + 18, top - lf.height)); top -= lf.height
    x, y = shelf(1, 0); bottom = y + SHELF_H
    cs = pc_face(5, 78, side=True); room.alpha_composite(cs, (x, bottom - cs.height))
    d = ImageDraw.Draw(room)
    x, y = shelf(0, 1); bottom = y + SHELF_H
    for (cx, wc, hh) in ((0, 4, 30), (5, 2, 20), (8, 4, 40)):
        d.rectangle((x + cx * CELLW, bottom - hh, x + (cx + wc) * CELLW - 2, bottom), fill=(176, 140, 96, 255), outline=INK)
        d.line((x + cx * CELLW, bottom - hh + 8, x + (cx + wc) * CELLW - 2, bottom - hh + 8), fill=(150, 116, 78, 255))
    x, y = shelf(1, 1); bottom = y + SHELF_H
    lf = laptop_face("graphite", 6); room.alpha_composite(lf, (x + 6 * CELLW, bottom - lf.height))
    return room


# ---------------- repair bench: what has to come off first ----------------

U = 64


def side_panel(cells_w, cells_h, vent=True):
    """A tower's (or compact's) steel side panel, the PC lying on its side: brushed steel, pressed rim, a vent
    grille, the two thumbscrew holes at the rear edge (the game draws the screws, so they can be turned)."""
    old = pc.S; pc.S = 3
    try:
        W2, H2 = cells_w * U, cells_h * U
        p = pc.Pen(W2, H2)
        p.grad((0, 0, W2 - 1, H2 - 1), "#5d6570", "#343a42", 1.6, r=10, angle=0.6)
        p.grad((40, 40, W2 - 41, H2 - 41), "#646d78", "#3b424b", 1.2, r=8, angle=0.6)   # pressed panel
        for k in range(0, int(W2 * 0.7), 14):
            p.line([(60 + k, 60 + k // 3), (90 + k, 60 + k // 3)], (150, 158, 168, 70), 0.8)   # brushing
        if vent:
            for y in range(int(H2 * 0.25), int(H2 * 0.6), 22):
                for x in range(int(W2 * 0.55), int(W2 * 0.85), 22):
                    p.ell((x - 6, y - 6, x + 6, y + 6), "#20242a", 0)
        for y in (U, H2 - U):
            p.ell((16, y - 12, 40, y + 12), "#26292e", 1.0)                       # thumbscrew holes, rear edge
        p.glint(60, 50, 40, 1.6)
        return pc.ink_outline(p.im, 1.2)
    finally:
        pc.S = old


def laptop_cover():
    """A laptop's bottom cover (14 x 9 cells): ribbed intake vents over the fan, four rubber feet, eight
    screw holes (drawn by the game), a blank regulatory sticker, a battery-latch outline."""
    old = pc.S; pc.S = 3
    try:
        W2, H2 = 14 * U, 9 * U
        p = pc.Pen(W2, H2)
        p.grad((0, 0, W2 - 1, H2 - 1), "#40444c", "#22252a", 1.6, r=22, angle=0.5)
        p.grad((16, 16, W2 - 17, H2 - 17), "#3a3e45", "#26292e", 1.0, r=16, angle=0.5)
        for x in range(U + 10, 4 * U - 10, 12):                                  # intake slots over the fan
            p.rect((x, U + 14, x + 6, 4 * U - 14), "#121316", 0, r=2)
        for x in range(5 * U, 12 * U, 14):                                       # vents over the board
            p.rect((x, U + 30, x + 7, U + 70), "#16181c", 0, r=2)
        for (x, y) in [(40, 40), (W2 - 40, 40), (40, H2 - 40), (W2 - 40, H2 - 40)]:
            p.ell((x - 22, y - 14, x + 22, y + 14), "#151618", 1.0)                 # rubber feet
        p.rect((6 * U, 6 * U, 9 * U, 7 * U + 20), "#e9e6dc", 0.8, r=3)             # blank sticker
        for x in range(6 * U + 12, 9 * U - 12, 5): p.line([(x, 6 * U + 14), (x, 6 * U + 30)], "#6a6a66", 0.6)
        p.rect((2 * U, 6 * U - 10, 12 * U, 8 * U + 10), None or "#2b2e34", 0.8, r=10)   # battery area seam
        p.glint(50, 30, 30, 1.6)
        return pc.ink_outline(p.im, 1.2)
    finally:
        pc.S = old


def bench_case_mock():
    """The repair bench before the case is opened: the closed tower on the mat with its two thumbscrews."""
    bg = load("art/bench/background/bench_background.png").resize((1280, 720), Image.LANCZOS)
    area = (40, 110, 620, 400); cell = min(area[2] / 18, area[3] / 16)
    ox = area[0] + (area[2] - 18 * cell) / 2; oy = area[1] + (area[3] - 16 * cell) / 2
    panel = side_panel(18, 16).resize((int(18 * cell), int(16 * cell)), Image.LANCZOS)
    bg.alpha_composite(panel, (int(ox), int(oy)))
    d = ImageDraw.Draw(bg)
    for y in (cell, 15 * cell):
        cx, cy = ox + 0.4 * cell, oy + y
        d.ellipse((cx - 9, cy - 9, cx + 9, cy + 9), fill=(196, 200, 204), outline=(20, 22, 26), width=2)
        d.line((cx - 5, cy, cx + 5, cy), fill=(80, 84, 90), width=2)
    lap = laptop_cover().resize((int(14 * cell), int(9 * cell)), Image.LANCZOS)
    bg.alpha_composite(lap, (700, 180))
    for (x, y) in [(1.2, 0.5), (6, 0.5), (12.8, 0.5), (0.5, 4.5), (13.5, 4.5), (1.2, 8.5), (7, 8.5), (12.8, 8.5)]:
        cx, cy = 700 + x * cell, 180 + y * cell
        d.ellipse((cx - 5, cy - 5, cx + 5, cy + 5), fill=(170, 174, 178), outline=(20, 22, 26), width=1)
        d.line((cx - 3, cy, cx + 3, cy), fill=(70, 74, 80)); d.line((cx, cy - 3, cx, cy + 3), fill=(70, 74, 80))
    return bg


def runtime_files():
    out = {
        "rooms/counter_termopan/floor-linoleum.png": linoleum(),
        "rooms/stock/stock_wall.png": stock_wall(),
        "rooms/stock/rack_front.png": rack_front(),
        "storage/front/pc_tower_front.png": pc_face(8, 92), "storage/front/pc_tower_side.png": pc_face(6, 92, True),
        "storage/front/pc_compact_front.png": pc_face(7, 78), "storage/front/pc_compact_side.png": pc_face(5, 78, True),
        "bench/case/side_panel_tower.png": side_panel(18, 16).resize((18 * U, 16 * U), Image.LANCZOS),
        "bench/case/side_panel_compact.png": side_panel(15, 14).resize((15 * U, 14 * U), Image.LANCZOS),
        "bench/case/laptop_cover.png": laptop_cover().resize((14 * U, 9 * U), Image.LANCZOS),
    }
    for f in ("silver", "graphite"):
        out["storage/front/laptop_%s_front.png" % f] = laptop_face(f, 6)
        out["storage/front/laptop_%s_side.png" % f] = laptop_face(f, 4)
    return out


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    files = runtime_files()
    for rel, im in files.items():
        path = os.path.join(out, "pieces", rel); os.makedirs(os.path.dirname(path), exist_ok=True); im.save(path)
    shell = load("art/rooms/counter_batch_a/room-shell-v2.png")
    shell.alpha_composite(files["rooms/counter_termopan/floor-linoleum.png"])
    shell.alpha_composite(load("art/rooms/counter_batch_a/counter-foreground-v2.png"))
    shell.resize((1280, 720), Image.LANCZOS).save(os.path.join(out, "1_counter_linoleum.png"))
    stock_mock().save(os.path.join(out, "2_stock_room_front.png"))
    files["rooms/counter_termopan/floor-linoleum.png"].crop((0, FLOOR - 40, W, H)).resize((1280, int((H - FLOOR + 40) / F)), Image.LANCZOS).save(os.path.join(out, "4_linoleum_alone.png"))
    bench_case_mock().save(os.path.join(out, "3_bench_closed_case_and_laptop_cover.png"))
    hashes = {rel: hashlib.sha256(open(os.path.join(out, "pieces", rel), "rb").read()).hexdigest() for rel in files}
    json.dump({"revision": 1, "sha256": hashes}, open(os.path.join(out, "manifest.json"), "w"), indent=1)
    print("drafts ok", len(files))
