# Counter wall finishes (0.58.5 drafts; 0.58.9 approved: the user, 27 November 2026, "i kinda f with all of them").
# Draws each wall over the flat counter shell and composes the review pictures in art/drafts/walls/. Run from a
# folder holding flat.py (this folder) and the termopan layers in termo/ (art/rooms/counter_termopan/).
# walls_export.py turns the same walls into the runtime layers in art/rooms/counter_walls/ and checks that
# they rebuild the approved pictures exactly. By Claude (Opus 5.5, model id claude-opus-5-5).
import sys, random, colorsys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, '.')
import flat
D = 'termo'
def L(n): return Image.open(f"{D}/{n}.png").convert("RGBA")
K = flat.K
W, H, FLOOR = 1280, 720, 505
def full(c, im, a=1.0):
    s = im.resize((round(im.width * K), round(im.height * 720 / 941)), Image.NEAREST)
    if a < 1: s.putalpha(s.getchannel("A").point(lambda v: int(v * a)))
    c.alpha_composite(s)
INK = (18, 20, 24)
def grime(d, box, n, seed, col):
    rnd = random.Random(seed)
    for _ in range(n):
        x = rnd.randint(box[0], box[2]-3); y = rnd.randint(box[1], box[3]-3); r = rnd.choice((1,1,2))
        d.rectangle((x, y, x+r, y+r), fill=col)
def wall_cream_tiles():
    im = Image.new("RGBA", (W, FLOOR), (0,0,0,0)); d = ImageDraw.Draw(im); rnd = random.Random(5)
    d.rectangle((0,0,W,FLOOR), fill=(120,108,86,255)); p = 20
    for y in range(0, FLOOR, p):
        for x in range(0, W, p):
            j = rnd.randint(-6, 6); col = (226+j, 214+j, 184+j, 255)
            if rnd.random() < 0.03: col = (196+j, 176+j, 140+j, 255)
            d.rectangle((x+1, y+1, x+p-2, y+p-2), fill=col); d.line((x+2, y+1, x+p-3, y+1), fill=(246,238,214,255))
    for y0 in (300, 322):      # a brown decorative band at waist height
        for x in range(0, W, p):
            d.rectangle((x+1, y0+1, x+p-2, y0+p-2), fill=(126,74,40,255) if (x//p)%2 else (150,92,52,255))
    grime(d, (0,0,W,FLOOR), 900, 6, (150,132,100,90))
    return im
def wall_oil_paint():
    im = Image.new("RGBA", (W, FLOOR), (0,0,0,0)); d = ImageDraw.Draw(im)
    split = 250
    for y in range(0, split):    # whitewashed upper wall, a little dirty toward the ceiling
        t = y / split; d.line((0,y,W,y), fill=(int(214+12*t), int(210+12*t), int(192+10*t), 255))
    for y in range(split, FLOOR):  # glossy oil paint below
        t = (y - split) / (FLOOR - split); d.line((0,y,W,y), fill=(int(78-12*t), int(122-14*t), int(110-12*t), 255))
    d.line((0, split, W, split), fill=(40,58,52,255), width=5); d.line((0, split+5, W, split+5), fill=(150,190,176,255), width=1)
    rnd = random.Random(8)
    for _ in range(160):          # gloss highlights and scuffs on the oil paint
        x = rnd.randint(0, W); y = rnd.randint(split+10, FLOOR-6)
        d.line((x, y, x + rnd.randint(8, 40), y), fill=(120,170,156,120))
    for _ in range(40):            # chipped paint
        x = rnd.randint(0, W); y = rnd.randint(split+8, FLOOR-6); r = rnd.randint(2,5)
        d.ellipse((x, y, x+r*2, y+r), fill=(196,190,170,255))
    grime(d, (0,0,W,split), 700, 9, (170,160,138,80))
    return im
def wall_wood_wallpaper():
    im = Image.new("RGBA", (W, FLOOR), (0,0,0,0)); d = ImageDraw.Draw(im); rnd = random.Random(11)
    split = 230
    d.rectangle((0,0,W,split), fill=(196,150,96,255))   # 70s wallpaper: ochre with brown-orange circles
    for y in range(-20, split+40, 56):
        for x in range(-20, W+40, 56):
            ox = 28 if (y//56)%2 else 0
            d.ellipse((x+ox-18, y-18, x+ox+18, y+18), outline=(150,86,44,255), width=4)
            d.ellipse((x+ox-8, y-8, x+ox+8, y+8), fill=(214,120,56,255))
    for x in range(0, W, 26):     # varnished pine boards (lambriu)
        j = rnd.randint(-10, 10)
        d.rectangle((x, split, x+25, FLOOR), fill=(166+j, 108+j, 58+j, 255))
        d.line((x, split, x, FLOOR), fill=(96,58,28,255), width=2)
        for k in range(3):
            gy = rnd.randint(split+10, FLOOR-10); d.arc((x+4, gy-6, x+20, gy+6), 0, 180, fill=(130,82,40,255))
        d.line((x+3, split+2, x+3, FLOOR), fill=(196,140,84,255))
    d.rectangle((0, split-6, W, split+4), fill=(120,72,34,255)); d.line((0, split-6, W, split-6), fill=(176,120,66,255))
    return im
def wall_blue_plaster():
    im = Image.new("RGBA", (W, FLOOR), (0,0,0,0)); d = ImageDraw.Draw(im); rnd = random.Random(14)
    d.rectangle((0,0,W,FLOOR), fill=(150,176,196,255))
    arr = np.asarray(im).astype(np.int16); noise = np.random.RandomState(3).randint(-7, 8, (FLOOR, W, 1)); arr[:,:,:3] += noise
    im = Image.fromarray(np.clip(arr,0,255).astype(np.uint8)); d = ImageDraw.Draw(im)
    d.rectangle((0, FLOOR-34, W, FLOOR), fill=(70,86,98,255)); d.line((0, FLOOR-34, W, FLOOR-34), fill=(40,50,58,255), width=3)  # dark skirting paint
    for _ in range(26):            # cracks
        x = rnd.randint(0, W); y = rnd.randint(20, FLOOR-60); pts = [(x,y)]
        for k in range(rnd.randint(3,7)): x += rnd.randint(-8, 8); y += rnd.randint(4, 12); pts.append((x,y))
        d.line(pts, fill=(104,124,138,255), width=1)
    grime(d, (0,0,W,FLOOR), 800, 15, (110,128,140,90))
    return im
def keep_mask(shell):
    rgb = np.asarray(shell.convert("RGB")).astype(float) / 255
    mx = rgb.max(2); mn = rgb.min(2); delta = mx - mn
    sat = np.where(mx > 0, delta / np.maximum(mx, 1e-6), 0)
    r, g, b = rgb[:,:,0], rgb[:,:,1], rgb[:,:,2]
    hue = np.zeros_like(mx)
    m = delta > 1e-6
    hr = (mx == r) & m; hg = (mx == g) & m & ~hr; hb = m & ~hr & ~hg
    hue[hr] = ((g - b)[hr] / delta[hr]) % 6
    hue[hg] = ((b - r)[hg] / delta[hg]) + 2
    hue[hb] = ((r - g)[hb] / delta[hb]) + 4
    hue = hue / 6
    tile = (hue > 0.42) & (hue < 0.60) & (sat > 0.18)          # teal tiles and their dark grout
    keep = np.zeros(mx.shape, bool)
    for x0,y0,x1,y1 in [(588,0,958,86),(936,0,1042,172)]:       # the lamp and the pipe
        keep[y0:y1, x0:x1] = ~tile[y0:y1, x0:x1]
    keep[98:FLOOR+10, 1046:1280] = True                          # the workshop doorway and its frame
    return Image.fromarray((keep*255).astype(np.uint8))
def sign(c, text, rect):
    d = ImageDraw.Draw(c); x,y,w,h = rect
    d.rectangle((x+3,y+4,x+w+3,y+h+4), fill=(0,0,0,90)); d.rectangle((x,y,x+w,y+h), fill=(31,58,95,255), outline=(14,26,43,255), width=2)
    d.rectangle((x+4,y+4,x+w-4,y+h-4), outline=(232,226,208,255), width=2)
    for cx,cy in [(x+8,y+8),(x+w-8,y+8),(x+8,y+h-8),(x+w-8,y+h-8)]: d.ellipse((cx-2,cy-2,cx+2,cy+2), fill=(154,163,173,255))
    f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 22); tw = d.textlength(text, font=f)
    d.text((x+(w-tw)/2+1, y+h/2-12+1), text, font=f, fill=(14,26,43,255)); d.text((x+(w-tw)/2, y+h/2-12), text, font=f, fill=(241,234,214,255))
def render(wall=None, label=""):
    c = Image.new("RGBA", (W, H), (0x15,0x23,0x2b,255))
    flat.full(c, "shell"); flat.flat_wall(c)
    if wall is not None:
        shellc = c.copy(); w = wall()
        c.alpha_composite(w, (0,0))
        m = keep_mask(shellc); c.paste(shellc, (0,0), m)
    full(c, L("floor-linoleum"))
    for (x,y,w,h) in [(52,106,161,399),(213,106,391,304)]:
        flat.region(c, "morning", (280+x*1.032, 302+y*1.032, w*1.032, h*1.032), (x,y,w,h))
    for n in ["radiator","termopan-front-frame","termopan-front-door-closed"]: full(c, L(n))
    flat.region(c, "sign", (269,249,486,984), (400,128,60,122))
    for n in ["termopan-workshop-closed","pvc-shutter-up"]: full(c, L(n))
    sign(c, "THE COUNTER", (640, 86, 300, 46))
    m = Image.open(flat.R + "art/customers/t001_mara.png").convert("RGBA").resize((240,344), Image.NEAREST); c.alpha_composite(m, (560, 144))
    flat.full(c, "counter")
    d = ImageDraw.Draw(c); f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 20)
    d.rectangle((0, H-34, W, H), fill=(0,0,0,210)); d.text((14, H-30), label, font=f, fill=(255,255,255))
    return c.convert("RGB")
opts = [(None, "Now: teal tiles"), (wall_cream_tiles, "A: cream faience tiles with a brown band"), (wall_oil_paint, "B: two-tone oil paint (whitewash over glossy green)"),
        (wall_wood_wallpaper, "C: pine panelling under 70s wallpaper"), (wall_blue_plaster, "D: pale blue plaster, cracked, dark skirting")]
ims = [render(f, l) for f, l in opts]
for i, im in enumerate(ims): im.save(f"wall_opt{i}.png")
sheet = Image.new("RGB", (2560, 2160), (0,0,0))
for i, im in enumerate(ims[1:]): sheet.paste(im, ((i%2)*1280, (i//2)*720))
sheet.paste(ims[0], (640, 1440)); sheet.save("wall_sheet.png")
print("ok")
