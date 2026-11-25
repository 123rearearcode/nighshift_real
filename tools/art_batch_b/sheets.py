# Review sheets for the user (not game assets). The room mockup uses the user's room draft and Codex's
# counter draft only as a backdrop to judge scale.
import os, sys
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, os.path.dirname(__file__))
from px import up
from storage_items import render as px_render, CELL
import parts_comic


def item_img(name, r):
    """Parts: illustrated comic style at 1:1. PCs and tools: pixel art at 2x."""
    if name in parts_comic.PARTS: return parts_comic.render(name, r)
    return up(px_render(name, r))

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
REV = os.path.join(HERE, "review")
os.makedirs(REV, exist_ok=True)
F = lambda s: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", s)
FB = lambda s: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", s)
BG = (21, 30, 39, 255)
INK = (226, 222, 210)
DIM = (150, 160, 168)
L = lambda p: Image.open(os.path.join(OUT, p)).convert("RGBA")


def paste(sheet, im, xy):
    sheet.alpha_composite(im, (int(xy[0]), int(xy[1])))


def room_mockup(room_path, counter_path):
    room = Image.open(room_path).convert("RGBA").resize((1280, 720), Image.LANCZOS)
    counter = Image.open(counter_path).convert("RGBA").resize((1280, 720), Image.LANCZOS)
    s = room.copy()
    paste(s, up(L("ART-08/mara_neutral.png")), (500, 236))
    s.alpha_composite(counter)
    paste(s, up(L("ART-09/pc_tower_closed.png")), (800, 360))
    paste(s, up(L("ART-06/clipboard_resting.png")), (330, 498))
    d = ImageDraw.Draw(s)
    d.rectangle((0, 684, 1280, 720), fill=(0, 0, 0, 190))
    d.text((12, 692), "MOCKUP for scale only. Backdrop: your room draft + the earlier counter draft (Batch A, not mine). "
           "Mine: Mara, PC tower, clipboard (shown at 2x).", font=F(15), fill=INK)
    s.convert("RGB").save(os.path.join(REV, "1_room_mockup.png"))


def people_sheet():
    s = Image.new("RGBA", (1400, 760), BG); d = ImageDraw.Draw(s)
    d.text((24, 18), "ART-08  Customers: look-review sketches (one neutral pose each)", font=FB(24), fill=INK)
    for i, (n, title, notes) in enumerate([
            ("mara", "Mara V.  (t001_mara)", ["Hotel front-desk clerk, polite, in a hurry.", "Hotel blazer, blouse, blank name badge,",
                                             "handbag strap, hair pulled back in a low bun."]),
            ("relu", "Relu D.  (t002_relu)", ["Economics student, ranked gamer, chatty.", "Hoodie, headphones round the neck,",
                                             "glasses, short messy hair, a confident grin."])]):
        x = 40 + i * 690
        im = L(f"ART-08/{n}_neutral.png")
        paste(s, up(im, 3), (x, 70))
        d.text((x + 385, 70), "1x native", font=F(13), fill=DIM)
        paste(s, up(im, 1), (x + 385, 90))
        d.text((x + 385, 272), "2x, as in game", font=F(13), fill=DIM)
        paste(s, up(im, 2), (x + 385, 292))
        d.text((x, 600), title, font=FB(20), fill=INK)
        for k, line in enumerate(notes):
            d.text((x, 632 + k * 22), line, font=F(16), fill=DIM)
    d.text((40, 726), "Native 120 x 172 px. Light from the window (left). Everything below the waist is hidden by the counter.", font=F(15), fill=DIM)
    s.convert("RGB").save(os.path.join(REV, "2_customers.png"))


def props_sheet():
    s = Image.new("RGBA", (1280, 800), BG); d = ImageDraw.Draw(s)
    d.text((24, 18), "ART-06 clipboard  ·  ART-09 customer PC  ·  ART-07 ticket close-up skin", font=FB(24), fill=INK)
    paste(s, up(L("ART-06/clipboard_resting.png"), 4), (30, 70))
    d.text((40, 220), "On the counter (4x)", font=F(15), fill=DIM)
    paste(s, up(L("ART-06/clipboard_upright.png"), 4), (300, 70))
    d.text((300, 270), "Picked up / hover (4x)", font=F(15), fill=DIM)
    paste(s, up(L("ART-09/pc_tower_closed.png"), 4), (40, 300))
    d.text((40, 700), "Customer tower, closed (4x). One generic case,\nreused for every customer; the ticket identifies it.", font=F(15), fill=DIM)
    paste(s, up(L("ART-07/ticket_closeup_skin.png"), 2), (660, 70))
    d.text((660, 50), "Ticket close-up skin at 2x (as in game). Paper is blank: the game writes the text.", font=F(14), fill=DIM)
    s.convert("RGB").save(os.path.join(REV, "3_props.png"))


def storage_sheet():
    s = Image.new("RGBA", (1280, 760), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-10 rev 2  Storage: parts in comic style, tools refined (44 px cells on screen)", font=FB(22), fill=INK)
    gx, gy, cs = 40, 60, CELL * 2
    d.rectangle((gx - 6, gy - 6, gx + 20 * cs + 6, gy + 10 * cs + 6), fill=(61, 50, 41, 255))
    d.rectangle((gx, gy, gx + 20 * cs, gy + 10 * cs), fill=(28, 32, 38, 255))
    for x in range(21): d.line((gx + x * cs, gy, gx + x * cs, gy + 10 * cs), fill=(46, 52, 60, 255))
    for y in range(11): d.line((gx, gy + y * cs, gx + 20 * cs, gy + y * cs), fill=(46, 52, 60, 255))
    for name, r, (cx, cy) in [("pc_tower", 0, (0, 0)), ("gpu", 1, (8, 0)), ("ram", 0, (9, 0)), ("ram", 1, (10, 0)),
                              ("cpu", 0, (10, 1)), ("psu", 0, (14, 0)), ("cooler", 0, (17, 0)), ("storage_hdd", 0, (14, 2)),
                              ("storage_ssd", 1, (16, 2)), ("vacuum", 0, (0, 6)), ("brush", 0, (4, 6)), ("pick", 0, (4, 7)),
                              ("cloth", 0, (6, 7)), ("syringe", 0, (8, 8)), ("pc_compact", 0, (13, 5))]:
        paste(s, item_img(name, r), (gx + cx * cs, gy + cy * cs))
    tx = gx + 20 * cs + 30
    d.text((tx, gy), "In this demo:", font=FB(16), fill=INK)
    for k, line in enumerate(["Tower PC 8x6, compact PC 7x5", "GPU 8x1 (turned), RAM 1x4", "(one turned), CPU 3x3 in its tray,",
                              "PSU 3x2, cooler 2x2, HDD and", "SSD 2x1, vacuum 4x2, brush 3x1,", "pick 2x1, cloth 2x2, syringe 1x2.",
                              "", "Grid lines, frame and the", "dark floor are placeholders:", "the game draws the grid and",
                              "Batch A draws the storage", "itself (ART-05).", "", "Parts: illustrated, inked,", "full resolution.",
                              "Tools and PCs: pixel art.", "", "Each item has 4 turns;", "the light stays top-left."]):
        d.text((tx, gy + 26 + k * 21), line, font=F(15), fill=DIM)
    y = gy + 10 * cs + 30
    d.text((gx, y), "All four turns (R / Q / E):", font=FB(16), fill=INK)
    x = gx
    for name in ("vacuum", "psu", "syringe"):
        for r in range(4):
            im = item_img(name, r); paste(s, im, (x, y + 30)); x += im.width + 10
        x += 24
    s.convert("RGB").save(os.path.join(REV, "4_storage_items.png"))


if __name__ == "__main__":
    room_mockup(sys.argv[1], sys.argv[2])
    people_sheet(); props_sheet(); storage_sheet()
    print("ok")
