# Review sheets for Batch C round 1 (ART-14, ART-15). Not game art.
import os, sys, json
from PIL import Image, ImageDraw, ImageFont
HERE = os.path.dirname(os.path.abspath(__file__))
O = os.path.join(HERE, "out")
R = os.path.join(HERE, "review"); os.makedirs(R, exist_ok=True)
F = lambda s: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", s)
FB = lambda s: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", s)
BG, INK, DIM = (21, 30, 39, 255), (226, 222, 210), (150, 160, 168)
L = lambda p: Image.open(os.path.join(O, p)).convert("RGBA")
U = 64
# where each part sits (board cells), from component_data.demo_board(); board origin (3, 2) in the case
PLACED = [("cpu_bare", 0, (0, 1)), ("cooler", 0, (0, 4)), ("ram", 0, (4, 0)), ("ram", 0, (5, 0)), ("gpu", 0, (0, 6)),
          ("storage_ssd", 0, (4, 8)), ("psu", 0, (5, 4))]


def assembled(with_parts=True):
    case = L("ART-14/case_tower_interior.png")
    case.alpha_composite(L("ART-14/board_demo_l.png"), (3 * U, 2 * U))
    if with_parts:
        for n, r, (x, y) in PLACED:
            case.alpha_composite(L(f"ART-15/board/{n}_r{r}.png"), ((3 + x) * U, (2 + y) * U))
    return case


def sheet_case():
    s = Image.new("RGBA", (1280, 760), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-14 open case + board kit  ·  ART-15 parts on the board (comic style)", font=FB(22), fill=INK)
    empty = assembled(False); full = assembled(True)
    cell = 26.25                                     # the hardware board's cell size in game (640x420 area, 18x16 case)
    for i, im in enumerate([empty, full]):
        g = im.resize((round(18 * cell), round(16 * cell)), Image.LANCZOS)
        s.alpha_composite(g, (24 + i * 500, 60))
        d.text((24 + i * 500, 490), ["Empty: every slot and socket is part of the board", "With parts, at the game's real size (26 px cells)"][i], font=F(15), fill=DIM)
    z = full.crop((3 * U, 2 * U, 13 * U, 12 * U)).resize((256, 256), Image.LANCZOS)
    s.alpha_composite(z, (1008, 60)); d.text((1008, 322), "Board close-up", font=F(15), fill=DIM)
    for k, line in enumerate(["Tower case 18 x 16 cells, demo L board 10 x 10 (one existing layout).",
                              "Master 64 px per cell; the game scales it to its cell size.",
                              "Parts are the same drawings as the approved storage parts, plus a bare CPU",
                              "for the socket. Four turns each. Real slots: CPU socket, cooler mount,",
                              "3 RAM slots, 2 PCIe x16, 2 drive slots, 24-pin power. No text anywhere."]):
        d.text((24, 530 + k * 24), line, font=F(16), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c1_case_board.png"))


def sheet_inspect():
    S = json.load(open(os.path.join(O, "ART-15/inspect/inspect_spots.json")))
    s = Image.new("RGBA", (1420, 760), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-15 testing-bay inspection pictures (healthy parts; faults are separate overlays)", font=FB(22), fill=INK)
    for i, k in enumerate(["gpu", "cpu", "ram", "psu", "cooler", "storage"]):
        x, y = 20 + (i % 3) * 466, 56 + (i // 3) * 346
        d.rectangle((x, y, x + 450, y + 300), fill=(35, 47, 42, 255), outline=(95, 122, 104, 255), width=2)
        s.alpha_composite(L(f"ART-15/inspect/inspect_{k}.png").resize((450, 300), Image.LANCZOS), (x, y))
        for n, (fx, fy) in S[k].items():
            cx, cy = x + fx * 450, y + fy * 300
            d.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), outline=(255, 95, 210, 255), width=2)
            d.text((cx + 9, cy - 8), n, font=F(12), fill=(255, 170, 230))
        d.text((x, y + 304), k.upper() + " (shown at the bay's 450 x 300 panel)", font=F(13), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c2_inspection.png"))


def sheet_parts():
    s = Image.new("RGBA", (1280, 560), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-15 board-scale parts (64 px per cell master, shown here at half size)", font=FB(22), fill=INK)
    x, y = 24, 60
    for n in ["gpu", "ram", "cpu_bare", "cooler", "psu", "storage_hdd", "storage_ssd"]:
        im = L(f"ART-15/board/{n}_r0.png"); im = im.resize((im.width // 2, im.height // 2), Image.LANCZOS)
        if x + im.width > 1250: x, y = 24, y + 150
        s.alpha_composite(im, (x, y)); x += im.width + 24
    d.text((24, 470), "Same designs as the approved storage pictures, drawn bigger; the CPU appears bare (out of its tray) for the socket.", font=F(15), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c3_parts.png"))


if __name__ == "__main__":
    sheet_case(); sheet_inspect(); sheet_parts(); print("ok")
