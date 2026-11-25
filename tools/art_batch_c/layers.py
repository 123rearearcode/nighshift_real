# ART-17: dust, paste, fan and damage layers, comic-book semi-realistic (D168).
# - Dust: tileable dust films (light / medium / heavy) that follow whatever surface the dust grid covers,
#   dust bunnies and a mote, so removed parts reveal the clean surface underneath (the code decides where).
# - Paste: the CPU-socket stage behind the paste simulation (408 x 408 shown; CPU = cells 8..43 of 51),
#   a colour ramp for paste thickness, and an old dried paste layer.
# - Fan: a rotor the code spins, a frame, and a motion blur disc for full speed.
# - Damage: one overlay per TELL and per RED HERRING in part_condition.gd, on the 900 x 600 inspection
#   canvas, exactly at that spot of the ART-15 picture. The game shows an overlay only when that clue is
#   revealed; a healthy part never shows one. The PSU's "smell" has no picture by design.
import os, sys, math, random, json
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))   # shared comic/pixel helpers
import parts_comic as pc

DUST = [(214, 200, 170), (190, 176, 150), (232, 222, 198), (160, 150, 132)]


def dust_tile(density, seed):
    T = 128
    S = 4
    im = Image.new("RGBA", (T * S, T * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rnd = random.Random(seed)
    film = int(70 + 120 * density)
    for _ in range(int(900 * density)):                              # soft film of fine specks
        x, y = rnd.random() * T, rnd.random() * T
        r = rnd.uniform(0.6, 1.6)
        c = rnd.choice(DUST) + (film,)
        for ox in (-T, 0, T):
            for oy in (-T, 0, T):
                d.ellipse(((x + ox - r) * S, (y + oy - r) * S, (x + ox + r) * S, (y + oy + r) * S), fill=c)
    for _ in range(int(40 * density)):                               # fibres
        x, y = rnd.random() * T, rnd.random() * T
        pts = [(x, y)]
        a = rnd.random() * math.tau
        for _ in range(5):
            a += rnd.uniform(-0.8, 0.8)
            x, y = x + math.cos(a) * 3, y + math.sin(a) * 3
            pts.append((x, y))
        c = rnd.choice(DUST) + (int(120 + 100 * density),)
        for ox in (-T, 0, T):
            for oy in (-T, 0, T):
                d.line([((px + ox) * S, (py + oy) * S) for px, py in pts], fill=c, width=S)
    im = im.filter(ImageFilter.GaussianBlur(S * 0.4)).resize((T, T), Image.LANCZOS)
    return im


def clump(seed, size=64):
    S = 4
    pc.S = S
    p = pc.Pen(size, size)
    rnd = random.Random(seed)
    cx = cy = size / 2
    for _ in range(9):
        r = rnd.uniform(size * 0.12, size * 0.24)
        x, y = cx + rnd.uniform(-size * 0.2, size * 0.2), cy + rnd.uniform(-size * 0.15, size * 0.15)
        p.ell((x - r, y - r, x + r, y + r), "#cbbd9d", 0)
    for _ in range(14):
        a = rnd.random() * math.tau; L = rnd.uniform(size * 0.25, size * 0.45)
        p.line([(cx, cy), (cx + math.cos(a) * L, cy + math.sin(a) * L * 0.8)], "#a99a7c", 0.8)
    for _ in range(6):
        r = rnd.uniform(2, 5); x, y = cx + rnd.uniform(-10, 10), cy + rnd.uniform(-8, 4)
        p.ell((x - r, y - r, x + r, y + r), "#e7ddc7", 0)
    im = pc.ink_outline(p.im, 0.8)
    return im.resize((size, size), Image.LANCZOS)


def mote():
    T = 12
    yy, xx = np.mgrid[0:T, 0:T]
    r = np.hypot(xx - 5.5, yy - 5.5) / 6
    a = np.clip(1 - r, 0, 1) ** 1.5 * 230
    img = np.zeros((T, T, 4), np.uint8); img[..., :3] = (222, 208, 178); img[..., 3] = a.astype(np.uint8)
    return Image.fromarray(img)


# ---------------- paste ----------------

def paste_stage():
    M = 816                                       # 2x of the 408 px stage; CPU heat spreader = 128..688
    pc.S = 3
    p = pc.Pen(M, M)
    p.grad((0, 0, M - 1, M - 1), "#202429", "#0e1013", 0, angle=0.6)                 # socket plastic
    p.grad((70, 70, M - 71, M - 71), "#d6dce1", "#7d868f", 2.0, r=14, angle=0.7)      # retention frame
    p.rect((96, 96, M - 97, M - 97), "#14171a", 1.4, r=6)
    p.grad((108, 108, M - 109, M - 109), "#35805a", "#1f5537", 1.6, r=8, angle=0.5)   # substrate edge
    for k in range(28):
        p.rect((116 + k * 21, M - 120, 124 + k * 21, M - 113), "#c79a5a", 0)
    p.grad((128, 128, 688, 688), "#eef2f4", "#8a939b", 2.0, r=18, angle=0.7)          # heat spreader (paste goes here)
    for k in range(26): p.line([(140, 150 + k * 21), (676, 150 + k * 21)], (255, 255, 255, 34), 1.0)
    p.glint(150, 220, 70, 3.0)
    p.poly([(110, M - 110), (140, M - 110), (110, M - 140)], "#e0b84e", 1.0)
    for (x, y) in [(40, 40), (M - 40, 40), (40, M - 40), (M - 40, M - 40)]:
        p.ell((x - 18, y - 18, x + 18, y + 18), "#b7bfc7", 1.4); p.ell((x - 8, y - 8, x + 8, y + 8), "#26292e", 0)
    im = pc.ink_outline(p.im, 1.0)
    return im.resize((M, M), Image.LANCZOS)


def paste_ramp():
    W = 256
    a = np.zeros((8, W, 4), np.uint8)
    for x in range(W):
        t = x / (W - 1)
        c = np.array([110, 118, 126]) * (1 - t) + np.array([214, 220, 226]) * t        # thin film dark grey -> thick glossy grey
        a[:, x, :3] = c
        a[:, x, 3] = int(70 + 185 * min(1.0, t * 1.6))
    return Image.fromarray(a)


def old_paste():
    M = 816
    S = 2
    im = Image.new("RGBA", (M * S, M * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rnd = random.Random(3)
    blob = [(408 + 236 * math.cos(a) * (0.92 + 0.06 * math.sin(a * 3) + 0.03 * math.sin(a * 7)), 408 + 230 * math.sin(a) * (0.9 + 0.07 * math.cos(a * 4))) for a in np.linspace(0, math.tau, 72)]
    d.polygon([(x * S, y * S) for x, y in blob], fill=(150, 150, 140, 235))
    for _ in range(140):                                                              # dry, chalky texture
        x, y = rnd.uniform(200, 616), rnd.uniform(200, 616)
        r = rnd.uniform(4, 14)
        d.ellipse(((x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S), fill=(rnd.randint(165, 190),) * 3 + (200,))
    for _ in range(26):                                                               # cracks
        x, y = rnd.uniform(220, 600), rnd.uniform(220, 600)
        a = rnd.random() * math.tau
        pts = [(x, y)]
        for _ in range(4):
            a += rnd.uniform(-0.6, 0.6); x += math.cos(a) * 26; y += math.sin(a) * 26; pts.append((x, y))
        d.line([(px * S, py * S) for px, py in pts], fill=(70, 72, 70, 230), width=3 * S)
    mask = Image.new("L", im.size, 0); ImageDraw.Draw(mask).polygon([(x * S, y * S) for x, y in blob], fill=255)
    a = np.array(im); a[..., 3] = np.minimum(a[..., 3], np.array(mask)); im = Image.fromarray(a)
    return im.resize((M, M), Image.LANCZOS)


# ---------------- fan ----------------

def fan_rotor():
    T = 256
    pc.S = 4
    p = pc.Pen(T, T)
    c = T / 2
    for k in range(7):
        a = k * math.tau / 7
        P = lambda rr, aa: (c + rr * math.cos(aa), c + rr * math.sin(aa))
        pts = [P(28, a), P(118, a + 0.32), P(116, a + 0.78), P(28, a + 0.62)]
        p.poly(pts, "#4a505a", 1.6)
        p.poly([P(30, a + 0.05), P(114, a + 0.36), P(112, a + 0.5), P(30, a + 0.25)], "#6a717c", 0)
    p.ell((c - 30, c - 30, c + 30, c + 30), "#17181b", 1.6)
    p.ell((c - 20, c - 20, c + 20, c + 20), "#a9b0b7", 1.0)                          # blank hub sticker
    im = pc.ink_outline(p.im, 1.2)
    return im.resize((T, T), Image.LANCZOS)


def fan_frame():
    T = 256
    pc.S = 4
    p = pc.Pen(T, T)
    p.grad((4, 4, T - 5, T - 5), "#30343b", "#15171a", 1.8, r=22, angle=0.7)
    p.d.ellipse(p._b((14, 14, T - 15, T - 15)), fill=(0, 0, 0, 0))
    p.ring((14, 14, T - 15, T - 15), "#5b626c", 1.6)
    for (x, y) in [(24, 24), (T - 24, 24), (24, T - 24), (T - 24, T - 24)]:
        p.ell((x - 9, y - 9, x + 9, y + 9), "#9aa3ab", 1.2); p.ell((x - 4, y - 4, x + 4, y + 4), "#26292e", 0)
    for a in (0.785, 2.356, 3.927, 5.498):                                           # struts holding the motor
        p.line([(128 + 34 * math.cos(a), 128 + 34 * math.sin(a)), (128 + 118 * math.cos(a), 128 + 118 * math.sin(a))], "#24272c", 6)
    im = pc.ink_outline(p.im, 1.2)
    return im.resize((T, T), Image.LANCZOS)


def fan_blur():
    T = 256
    yy, xx = np.mgrid[0:T, 0:T]
    r = np.hypot(xx - 127.5, yy - 127.5)
    ang = np.arctan2(yy - 127.5, xx - 127.5)
    a = np.where((r > 30) & (r < 118), 120 + 30 * np.sin(ang * 7), 0)
    a = np.where(r <= 30, 0, a)
    img = np.zeros((T, T, 4), np.uint8); img[..., :3] = (88, 95, 106); img[..., 3] = np.clip(a, 0, 255).astype(np.uint8)
    im = Image.fromarray(img).filter(ImageFilter.GaussianBlur(1.5))
    return im


# ---------------- damage overlays (900 x 600 inspection canvas) ----------------

def ov():
    pc.S = 3
    return pc.Pen(900, 600)


def ov_done(p, outline=True):
    im = pc.ink_outline(p.im, 0.8) if outline else p.im
    return im.resize((900, 600), Image.LANCZOS)


def scorch(p, cx, cy, rx, ry, seed):
    rnd = random.Random(seed)
    for k in range(18):
        r = 1 - k / 18
        x, y = cx + rnd.uniform(-8, 8), cy + rnd.uniform(-6, 6)
        p.ell((x - rx * r, y - ry * r, x + rx * r, y + ry * r), (50 + int(40 * r), 32 + int(20 * r), 20, min(235, int(90 + 160 * (1 - r)))), 0)


def overlays():
    out = {}
    # GPU broken: scorched brown mark around the power connector
    p = ov(); scorch(p, 742, 125, 70, 46, 1); out["gpu_broken"] = ov_done(p, False)
    # GPU degraded: two domed capacitors
    p = ov()
    for (x, y) in [(792, 340), (826, 380)]:
        p.ell((x - 2, y - 4, x + 30, y + 28), "#5a4636", 1.2); p.ell((x + 5, y + 2, x + 23, y + 20), "#d8c9a8", 0.8)
        p.ell((x + 9, y + 6, x + 19, y + 14), "#f2e9d6", 0)
    out["gpu_degraded"] = ov_done(p)
    # CPU broken: dark burn spot on two contact pads
    p = ov(); scorch(p, 566, 204, 26, 22, 2)
    for (x, y) in [(558, 198), (570, 198)]: p.ell((x, y, x + 6, y + 6), "#2a1c12", 0)
    out["cpu_broken"] = ov_done(p, False)
    # CPU degraded: heat-tinted heat spreader (blue/bronze discolouration)
    p = ov()
    for k in range(10):
        r = 1 - k / 10
        p.ell((240 - 128 * r, 300 - 128 * r, 240 + 128 * r, 300 + 128 * r), (110 + int(80 * (1 - r)), 90 + int(30 * r), 160 - int(100 * (1 - r)), 34), 0)
    p.ring((120, 180, 360, 420), (150, 110, 70, 120), 6.0)
    out["cpu_degraded"] = ov_done(p, False)
    # RAM broken: a hairline crack across one memory chip
    p = ov()
    p.line([(546, 248), (562, 270), (556, 290), (578, 312), (572, 336), (598, 352)], "#c9cfd6", 2.4)
    p.line([(546, 248), (562, 270), (556, 290), (578, 312), (572, 336), (598, 352)], "#0a0a0b", 1.0)
    out["ram_broken"] = ov_done(p, False)
    # RAM degraded: dull, slightly green gold contacts
    p = ov()
    rnd = random.Random(4)
    for x in range(70, 830, 8):
        if 466 <= x <= 490 or rnd.random() < 0.35: continue
        p.rect((x, 412 + rnd.randint(0, 10), x + 5, 446), (90, 140, 92, 170), 0)
    out["ram_degraded"] = ov_done(p, False)
    # PSU degraded: fan grille caked with dust
    p = ov()
    for (x, y, r) in [(420, 300, 150)]:
        p.ell((x - r, y - r, x + r, y + r), (200, 186, 156, 120), 0)
    rnd = random.Random(5)
    for _ in range(60):
        a = rnd.random() * math.tau; rr = rnd.uniform(20, 160)
        x, y = 420 + rr * math.cos(a), 300 + rr * math.sin(a); r = rnd.uniform(6, 16)
        p.ell((x - r, y - r, x + r, y + r), (214, 200, 170, 200), 0)
    out["psu_degraded"] = ov_done(p, False)
    # Cooler broken: the fan cable cut halfway, copper showing
    p = ov()
    p.line([(468, 464), (488, 482)], "#121314", 12)
    for k in range(4): p.line([(470 + k * 4, 468 + k * 3), (476 + k * 4, 476 + k * 3)], "#e39a5c", 1.6)
    p.line([(462, 470), (494, 476)], "#3a3d44", 2.0)
    out["cooler_broken"] = ov_done(p)
    # Cooler degraded: one fan blade chipped (a notch cut out of a blade edge)
    p = ov()
    p.poly([(176, 214), (214, 204), (204, 236)], "#1a1b1e", 1.4)
    p.line([(180, 216), (206, 210)], "#7b828c", 1.0)
    out["cooler_degraded"] = ov_done(p)
    # Storage broken: dented casing corner
    p = ov()
    for k in range(8):
        r = 1 - k / 8
        p.ell((170 - 66 * r, 466 - 38 * r, 170 + 66 * r, 466 + 38 * r), (30, 34, 40, int(22 + 34 * (1 - r))), 0)
    p.line([(120, 480), (150, 458), (196, 462), (226, 448)], "#f4f7f9", 2.0)
    p.line([(122, 486), (152, 466), (198, 470), (228, 456)], "#4d555d", 1.6)
    out["storage_broken"] = ov_done(p, False)
    # Storage degraded: a handwritten scribble on the label (illegible pen loops ending in two question marks)
    p = ov()
    pts = [(470 + t * 3, 330 - 10 * math.sin(t * 0.9) - (t % 7)) for t in range(40)]
    p.line(pts, "#1f3fa0", 2.2)
    for qx in (606, 630):
        p.line([(qx, 312), (qx + 8, 302), (qx + 16, 310), (qx + 8, 322), (qx + 8, 330)], "#1f3fa0", 2.2)
        p.ell((qx + 6, 338, qx + 10, 342), "#1f3fa0", 0)
    out["storage_degraded"] = ov_done(p, False)
    # --- red herrings (harmless) ---
    p = ov()
    for (a, b) in [((380, 124), (430, 136)), ((470, 122), (540, 134)), ((600, 126), (640, 138))]:
        p.line([a, b], "#d7dde2", 1.6)
    p.rect((500, 120, 560, 140), (230, 226, 210, 120), 0)
    out["gpu_herring"] = ov_done(p, False)                                             # back plate scratches + sticker residue
    p = ov()
    rnd = random.Random(6)
    for _ in range(26):
        x = rnd.uniform(70, 410); y = rnd.uniform(446, 476); r = rnd.uniform(4, 10)
        p.ell((x - r, y - r * 0.6, x + r, y + r * 0.6), (190, 190, 182, 220), 0)
    out["cpu_herring"] = ov_done(p, False)                                             # dried paste on the edges
    p = ov()
    p.poly([(186, 228), (222, 228), (222, 270)], "#d6d2c6", 1.2); p.line([(186, 228), (222, 270)], "#9a978e", 1.2)
    out["ram_herring"] = ov_done(p)                                                    # label half peeled
    p = ov()
    for (x, y) in [(786, 300)]:
        for k in range(9): p.line([(x - 4, y - 16 + k * 4), (x - 30 - (k % 3) * 6, y - 22 + k * 6)], "#9aa0a8", 1.6)
    out["psu_herring"] = ov_done(p, False)                                             # frayed sleeve ends
    p = ov()
    rnd = random.Random(7)
    for _ in range(40):
        x = rnd.uniform(560, 830); y = rnd.uniform(210, 370); r = rnd.uniform(3, 7)
        p.ell((x - r, y - r, x + r, y + r), (214, 200, 170, 210), 0)
    out["cooler_herring"] = ov_done(p, False)                                          # dust between the fins
    p = ov()
    rnd = random.Random(8)
    for _ in range(18):
        x = rnd.uniform(722, 758); y = rnd.uniform(210, 390); r = rnd.uniform(2, 5)
        p.ell((x - r, y - r, x + r, y + r), (214, 200, 170, 220), 0)
    out["storage_herring"] = ov_done(p, False)                                         # dust in the connector
    return out


if __name__ == "__main__":
    out = sys.argv[1]
    for sub in ("dust", "paste", "fan", "damage"): os.makedirs(os.path.join(out, sub), exist_ok=True)
    for name, dens, seed in [("light", 0.35, 1), ("medium", 0.7, 2), ("heavy", 1.0, 3)]:
        dust_tile(dens, seed).save(os.path.join(out, "dust", f"dust_film_{name}.png"))
    for i in range(3): clump(10 + i).save(os.path.join(out, "dust", f"dust_bunny_{i + 1}.png"))
    mote().save(os.path.join(out, "dust", "dust_mote.png"))
    paste_stage().save(os.path.join(out, "paste", "paste_socket_stage.png"))
    paste_ramp().save(os.path.join(out, "paste", "paste_thickness_ramp.png"))
    old_paste().save(os.path.join(out, "paste", "paste_old_dried.png"))
    fan_rotor().save(os.path.join(out, "fan", "fan_rotor.png"))
    fan_frame().save(os.path.join(out, "fan", "fan_frame.png"))
    fan_blur().save(os.path.join(out, "fan", "fan_blur.png"))
    for k, im in overlays().items(): im.save(os.path.join(out, "damage", f"{k}.png"))
    print("ok")
