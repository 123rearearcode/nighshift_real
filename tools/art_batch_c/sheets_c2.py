# Review sheets for Batch C round 2 (ART-16, ART-17, ART-18). Not game art.
import os, sys, math, json
from PIL import Image, ImageDraw, ImageFont
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "art_batch_b"))
O = os.path.join(HERE, "out"); R = os.path.join(HERE, "review"); os.makedirs(R, exist_ok=True)
F = lambda s: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", s)
FB = lambda s: ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", s)
BG, INK, DIM = (21, 30, 39, 255), (226, 222, 210), (150, 160, 168)
L = lambda p: Image.open(os.path.join(O, p)).convert("RGBA")
from sheets_c1 import assembled
U = 64


def tile_fill(tile, size):
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    for y in range(0, size[1], tile.height):
        for x in range(0, size[0], tile.width):
            out.alpha_composite(tile, (x, y))
    return out


def bench_mock():
    """The repair bench at its real size: case + board + parts (cell 25), dust on the dusty zones, the case
    fan, the tools lying on the tray at the game's half-size sprites."""
    s = Image.new("RGBA", (700, 600), (28, 31, 38, 255))
    case = assembled(True)
    # dust films on the zones dust_zones.gd lists (cooler, RAM, GPU, PSU, filter, case fan)
    dusty = case.copy()
    for (x0, y0, x1, y1, kind) in [(3, 7, 5, 9, "heavy"), (7, 2, 9, 6, "medium"), (3, 8, 11, 9, "medium"), (1, 12, 9, 14, "light"), (16, 1, 17, 14, "heavy")]:
        box = (x0 * U, y0 * U, x1 * U, y1 * U)
        film = tile_fill(L(f"ART-17/dust/dust_film_{kind}.png").resize((256, 256)), (box[2] - box[0], box[3] - box[1]))
        dusty.alpha_composite(film, box[:2])
    fr = L("ART-17/fan/fan_frame.png").resize((2 * U, 2 * U), Image.LANCZOS); ro = L("ART-17/fan/fan_rotor.png").resize((2 * U - 16, 2 * U - 16), Image.LANCZOS)
    dusty.alpha_composite(ro, (8, int(3.5 * U) + 8)); dusty.alpha_composite(fr, (0, int(3.5 * U)))
    dusty.alpha_composite(L("ART-17/dust/dust_bunny_1.png"), (int(5 * U), int(11.5 * U)))
    dusty.alpha_composite(L("ART-17/dust/dust_bunny_2.png"), (int(12.4 * U), int(4 * U)))
    cell = 25.0
    g = dusty.resize((round(18 * cell), round(16 * cell)), Image.LANCZOS)
    s.alpha_composite(g, (40 + (620 - g.width) // 2, 10))
    ImageDraw.Draw(s).rectangle((40, 430, 660, 540), fill=(40, 54, 68, 255), outline=(155, 167, 169, 255), width=2)
    for i, n in enumerate(["vacuum", "brush", "pick", "syringe", "screwdriver"]):
        t = L(f"ART-16/tool_{n}.png").resize((80, 100), Image.LANCZOS).rotate(-15 + i * 8, resample=Image.BICUBIC)
        s.alpha_composite(t, (70 + i * 110, 435))
    s.alpha_composite(L("ART-16/dust_bin_body.png").resize((72, 52), Image.LANCZOS), (582, 476))
    return s


def sheet_tools():
    s = Image.new("RGBA", (1280, 760), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-16 repair-tool skins (comic style; they turn in 15° steps on the bench)", font=FB(22), fill=INK)
    for i, n in enumerate(["vacuum", "brush", "pick", "syringe", "screwdriver"]):
        im = L(f"ART-16/tool_{n}.png"); x = 24 + i * 176
        d.rectangle((x, 60, x + 160, 260), outline=(60, 70, 80, 255))
        s.alpha_composite(im, (x, 60))
        d.ellipse((x + 44 - 4, 60 + 148 - 4, x + 44 + 4, 60 + 148 + 4), outline=(255, 95, 210, 255), width=2)
        d.text((x, 266), n, font=F(13), fill=DIM)
        for k, a in enumerate((0, 45, 90)):
            t = im.rotate(-a, resample=Image.BICUBIC, center=(80, 100)).resize((80, 100), Image.LANCZOS)
            s.alpha_composite(t, (x + k * 52 - 8, 300))
    d.text((24, 410), "Above: master size (2x; pink ring = the working tip), and turned at the game's real size. Code-drawn parts keep moving:", font=F(15), fill=DIM)
    d.text((24, 432), "bristles (new dark colours), the cloth's shape (new texture) and the hose (new texture).", font=F(15), fill=DIM)
    s.alpha_composite(tile_fill(L("ART-16/cloth_tile.png"), (200, 140)), (24, 470)); d.text((24, 616), "Cloth texture (tiles)", font=F(13), fill=DIM)
    hose = tile_fill(L("ART-16/hose_tile.png"), (320, 24)); s.alpha_composite(hose, (250, 500)); d.text((250, 530), "Hose texture (repeats along the hose)", font=F(13), fill=DIM)
    s.alpha_composite(L("ART-16/hose_clamp.png"), (250, 560)); d.text((250, 624), "Hose clamp", font=F(13), fill=DIM)
    s.alpha_composite(L("ART-16/dust_bin_body.png"), (460, 560)); d.text((460, 668), "Dust bin (fill shows in the window)", font=F(13), fill=DIM)
    s.alpha_composite(L("ART-16/fx_suction.png"), (680, 500)); d.text((680, 632), "Suction glow", font=F(13), fill=DIM)
    s.alpha_composite(L("ART-16/fx_dust_puff.png"), (830, 510)); d.text((830, 610), "Dust puff", font=F(13), fill=DIM)
    for k, c in enumerate(["#2c2a2a", "#4a4744"]):
        d.rectangle((980 + k * 60, 520, 1030 + k * 60, 570), fill=c); d.text((980, 580), "Bristle colours", font=F(13), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c4_tools.png"))


def sheet_layers():
    s = Image.new("RGBA", (1400, 760), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-17 dust, paste and fan layers  ·  mock of the repair bench at real size", font=FB(22), fill=INK)
    s.alpha_composite(bench_mock(), (10, 50))
    x0 = 730
    for i, n in enumerate(["light", "medium", "heavy"]):
        base = Image.new("RGBA", (128, 128), (31, 77, 58, 255)); base.alpha_composite(L(f"ART-17/dust/dust_film_{n}.png"))
        s.alpha_composite(base, (x0 + i * 140, 60)); d.text((x0 + i * 140, 192), "dust " + n, font=F(13), fill=DIM)
    for i in range(3): s.alpha_composite(L(f"ART-17/dust/dust_bunny_{i + 1}.png"), (x0 + i * 80, 216))
    s.alpha_composite(L("ART-17/dust/dust_mote.png").resize((24, 24)), (x0 + 250, 236)); d.text((x0, 284), "dust bunnies · mote", font=F(13), fill=DIM)
    st = L("ART-17/paste/paste_socket_stage.png").resize((204, 204), Image.LANCZOS)
    st2 = st.copy(); st2.alpha_composite(L("ART-17/paste/paste_old_dried.png").resize((204, 204), Image.LANCZOS))
    s.alpha_composite(st, (x0, 320)); s.alpha_composite(st2, (x0 + 220, 320))
    d.text((x0, 530), "CPU socket stage · with old dried paste", font=F(13), fill=DIM)
    s.alpha_composite(L("ART-17/paste/paste_thickness_ramp.png").resize((300, 16)), (x0, 556)); d.text((x0 + 310, 554), "paste thin → thick", font=F(13), fill=DIM)
    fr = L("ART-17/fan/fan_frame.png").resize((150, 150), Image.LANCZOS)
    a = Image.new("RGBA", (150, 150)); a.alpha_composite(L("ART-17/fan/fan_rotor.png").resize((150, 150), Image.LANCZOS)); a.alpha_composite(fr)
    b = Image.new("RGBA", (150, 150)); b.alpha_composite(L("ART-17/fan/fan_blur.png").resize((150, 150), Image.LANCZOS)); b.alpha_composite(fr)
    s.alpha_composite(a, (x0 + 460, 320)); s.alpha_composite(b, (x0 + 460, 480))
    d.text((x0 + 460, 632), "fan rotor · blur", font=F(13), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c5_layers.png"))


TELL_TEXT = {"gpu_broken": "GPU broken: scorch at the power connector", "gpu_degraded": "GPU worn: two domed capacitors",
             "gpu_herring": "Harmless: back-plate scratches, sticker residue", "cpu_broken": "CPU broken: burn spot on two pads",
             "cpu_degraded": "CPU worn: heat-discoloured spreader", "cpu_herring": "Harmless: old paste dried on the edges",
             "ram_broken": "RAM broken: crack across a chip", "ram_degraded": "RAM worn: dull, greenish contacts",
             "ram_herring": "Harmless: label half peeled", "psu_degraded": "PSU worn: grille caked with dust",
             "psu_herring": "Harmless: frayed cable sleeves", "cooler_broken": "Cooler broken: fan cable cut halfway",
             "cooler_degraded": "Cooler worn: a chipped blade", "cooler_herring": "Harmless: dust between the fins",
             "storage_broken": "Drive broken: dented casing", "storage_degraded": "Drive worn: scribbled note on the label",
             "storage_herring": "Harmless: dust in the connector"}


def sheet_damage():
    s = Image.new("RGBA", (1400, 980), BG); d = ImageDraw.Draw(s)
    d.text((24, 14), "ART-17 damage clues: shown ONLY when the game reveals that clue (the PSU's smell has no picture)", font=FB(20), fill=INK)
    for i, k in enumerate(TELL_TEXT):
        kind = k.split("_")[0]
        im = L(f"ART-15/inspect/inspect_{kind}.png"); im.alpha_composite(L(f"ART-17/damage/{k}.png"))
        x, y = 20 + (i % 5) * 274, 56 + (i // 5) * 228
        d.rectangle((x, y, x + 260, y + 174), fill=(35, 47, 42, 255))
        s.alpha_composite(im.resize((260, 174), Image.LANCZOS), (x, y))
        d.text((x, y + 178), TELL_TEXT[k], font=F(12), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c6_damage.png"))


def sheet_ui():
    s = Image.new("RGBA", (1280, 720), (30, 36, 44, 255)); d = ImageDraw.Draw(s)
    d.rectangle((48, 104, 894, 620), fill=(16, 25, 29, 255))
    m = L("ART-18/monitor_bezel.png"); s.alpha_composite(m.resize((m.width * 2, m.height * 2), Image.NEAREST), (32, 88))
    d.text((80, 140), "(the diagnostic screen's live text shows here)", font=F(16), fill=(117, 212, 176))
    ph = Image.new("RGBA", (400, 600), (0, 0, 0, 0)); pd = ImageDraw.Draw(ph)
    pd.rounded_rectangle((12, 12, 388, 588), 28, fill=(239, 230, 207, 255)); pd.text((28, 28), "(review app shows here)", font=F(15), fill=(60, 60, 60))
    ph.alpha_composite(L("ART-18/phone_shell.png").resize((400, 600), Image.NEAREST))
    s.alpha_composite(ph.resize((280, 420), Image.LANCZOS), (960, 200))
    d.text((24, 20), "ART-18 frames for the existing screens (pixel art, 2x): diagnostic monitor and your phone", font=FB(20), fill=INK)
    d.text((24, 680), "Screens are transparent: the live UI stays as it is. The phone has a small crack in one corner.", font=F(15), fill=DIM)
    s.convert("RGB").save(os.path.join(R, "c7_screens.png"))


if __name__ == "__main__":
    sheet_tools(); sheet_layers(); sheet_damage(); sheet_ui(); print("ok")
