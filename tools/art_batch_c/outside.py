# The Outside room at street level (user, 25 November 2026: "if the shop is on the side of the road, it
# should be a street-level view"; "the outside of the shop I mean"). Pixel art, native 640 x 360, shown at
# exactly 2x as art/rooms/outside.png. You stand on the far pavement at eye level and look across the road
# at the ground floor of an apartment block: the store (tools and upgrades), the parts supplier (shutter
# down: later), the block's entrance, and your shop. Your van is parked at the kerb. Dusk, matching the
# street seen through the shop window. No text anywhere: signs are icons. Hotspot boxes for this layout
# are in HOTSPOTS (logical 1280 x 720 px).
import os, sys, random, json
from PIL import Image, ImageDraw
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))
from px import c, mix, outline

W, H = 640, 360
HOTSPOTS = {"Store": [40, 380, 300, 150], "Supplier": [400, 380, 260, 150], "ShopDoor": [840, 360, 110, 170],
            "Van": [96, 452, 420, 160]}


def sky(d):
    top, mid, low = (34, 44, 92), (92, 78, 128), (206, 128, 110)
    for y in range(0, 90):
        t = y / 89
        col = mix(top, mid, t * 1.6) if t < 0.6 else mix(mid, low, (t - 0.6) / 0.4)
        d.line((0, y, W, y), fill=col)
    rnd = random.Random(2)
    for _ in range(9):                                                   # pink-lit clouds
        x, y, w = rnd.randrange(0, W), rnd.randrange(12, 60), rnd.randrange(40, 110)
        d.rectangle((x, y, x + w, y + 3), fill=c("#9b6b8e")); d.line((x + 6, y, x + w - 8, y), fill=c("#e39a86"))


def block(d):
    d.rectangle((0, 46, W, 196), fill=c("#8d8f95"))                    # apartment block
    for y in range(46, 196, 6): d.line((0, y, W, y), fill=c("#86888e"))  # panel seams
    for x in range(0, W, 80): d.line((x, 46, x, 196), fill=c("#7c7e84"))
    d.rectangle((0, 40, W, 46), fill=c("#6f7177")); d.line((0, 40, W, 40), fill=c("#a7a9ae"))
    for x in (60, 190, 330, 470, 590):
        d.rectangle((x, 30, x + 8, 40), fill=c("#5e6066")); d.line((x, 30, x + 8, 30), fill=c("#8a8c92"))   # chimneys
    rnd = random.Random(5)
    for row, y in enumerate((56, 92, 128, 162)):
        for k, x in enumerate(range(18, W - 10, 40)):
            lit = rnd.random() < 0.33
            d.rectangle((x, y, x + 20, y + 22), fill=c("#2b3446"))
            if lit:
                d.rectangle((x + 1, y + 1, x + 19, y + 21), fill=c("#e9b86a")); d.rectangle((x + 1, y + 1, x + 19, y + 6), fill=c("#f5d494"))
            else:
                d.line((x + 1, y + 1, x + 19, y + 1), fill=c("#55658a"))
            d.line((x + 10, y, x + 10, y + 22), fill=c("#d7d9dd")); d.line((x, y + 22, x + 20, y + 22), fill=c("#b9bbc0"))
            if k % 4 == 1 and row < 3:                                   # balconies
                d.rectangle((x - 4, y + 22, x + 24, y + 30), fill=c("#a9abb0")); d.line((x - 4, y + 22, x + 24, y + 22), fill=c("#c9cbd0"))
            if rnd.random() < 0.12: d.rectangle((x + 21, y + 12, x + 27, y + 18), fill=c("#d4d6da"))   # AC unit


def ground_floor(d):
    d.rectangle((0, 196, W, 262), fill=c("#2e5a63"))                    # tiled ground floor
    for x in range(0, W, 8): d.line((x, 196, x, 262), fill=c("#29525a"))
    for y in range(196, 262, 8): d.line((0, y, W, y), fill=c("#29525a"))
    d.line((0, 196, W, 196), fill=c("#4b7a83"))
    # the store: lit window with shelves, door, striped awning, tool icon sign
    d.rectangle((24, 206, 150, 258), fill=c("#f0c27a")); d.rectangle((26, 208, 148, 256), fill=c("#d9a35c"))
    for y in (220, 234, 248):
        d.line((28, y, 120, y), fill=c("#7a5532"))
        for x in range(30, 118, 9): d.rectangle((x, y - 7, x + 5, y - 1), fill=c(random.Random(x + y).choice(["#c0504a", "#4f74a0", "#e0b84e", "#6f8f5a"])))
    d.rectangle((124, 212, 146, 258), fill=c("#3a2f2a")); d.point((128, 236), fill=c("#e0b84e"))
    for x in range(20, 156, 8): d.rectangle((x, 198, x + 3, 205), fill=c("#c0504a")); d.rectangle((x + 4, 198, x + 7, 205), fill=c("#ece6da"))
    d.rectangle((60, 186, 104, 196), fill=c("#2a2e35")); d.line((70, 191, 94, 191), fill=c("#e6ebef")); d.rectangle((90, 188, 94, 194), fill=c("#e6ebef"))   # wrench icon
    # the parts supplier: roller shutter down (later)
    d.rectangle((200, 204, 330, 260), fill=c("#7d8590"))
    for y in range(206, 260, 4): d.line((200, y, 330, y), fill=c("#646b75"))
    d.rectangle((246, 186, 284, 196), fill=c("#2a2e35"))
    d.rectangle((258, 188, 272, 194), fill=c("#3e7f5a")); d.point((265, 191), fill=c("#e0b84e"))   # chip icon
    # the block's entrance with a lamp
    d.rectangle((346, 210, 378, 262), fill=c("#1c2228")); d.rectangle((350, 214, 374, 262), fill=c("#3b2f28"))
    d.rectangle((358, 202, 366, 206), fill=c("#f5d494"))
    # your shop: wide glazing, glass door with the hanging sign, blue icon sign above
    d.rectangle((396, 204, 632, 262), fill=c("#1b2a33"))
    d.rectangle((400, 208, 628, 262), fill=c("#20323b"))
    for x in range(400, 628, 2):                                         # warm light from the back room
        d.point((x, 252 + (x % 6) // 2), fill=c("#3c4a4f"))
    d.rectangle((520, 228, 600, 250), fill=c("#6b5a48")); d.line((520, 228, 600, 228), fill=c("#9c8670"))   # the counter inside
    d.rectangle((604, 214, 626, 262), fill=c("#d9a35c"))                # lit doorway to the workshop at the back
    for x in (470, 520, 576): d.line((x, 208, x, 262), fill=c("#59646e"))
    d.rectangle((420, 210, 466, 262), fill=c("#2a3b44")); d.line((420, 210, 420, 262), fill=c("#9aa7b0")); d.line((466, 210, 466, 262), fill=c("#9aa7b0"))
    d.line((432, 230, 432, 246), fill=c("#c9d0d6"))                     # door handle
    d.rectangle((436, 222, 452, 238), fill=c("#d8873c")); d.line((444, 214, 444, 222), fill=c("#1c1d20"))   # hanging sign
    d.rectangle((440, 226, 448, 231), fill=c("#2a2e35")); d.line((439, 235, 449, 233), fill=c("#2a2e35"))
    d.rectangle((470, 184, 600, 200), fill=c("#2b4c94")); d.line((470, 184, 600, 184), fill=c("#4f72b8"))   # blue sign, icon only
    d.rectangle((520, 187, 534, 196), fill=c("#e6ebef")); d.rectangle((523, 189, 531, 194), fill=c("#2b4c94"))
    d.line((540, 196, 552, 187), fill=c("#e6ebef")); d.line((540, 187, 552, 196), fill=c("#e6ebef"))


def street(d):
    d.rectangle((0, 262, W, 280), fill=c("#8a8d92"))                    # far pavement (the shops' side)
    for x in range(0, W, 24): d.line((x, 262, x - 6, 280), fill=c("#7b7e83"))
    d.line((0, 262, W, 262), fill=c("#a6a9ad"))
    d.rectangle((0, 280, W, 284), fill=c("#b4b7bb")); d.line((0, 284, W, 284), fill=c("#55585d"))   # kerb
    d.rectangle((0, 285, W, 344), fill=c("#3b3e44"))                    # road
    for x in range(10, W, 60): d.rectangle((x, 314, x + 30, 316), fill=c("#d9d6c8"))
    d.rectangle((0, 344, W, 360), fill=c("#7f8287"))                    # near pavement where you stand
    d.line((0, 344, W, 344), fill=c("#b4b7bb"))
    rnd = random.Random(9)
    for _ in range(70):                                                  # fallen leaves
        x, y = rnd.randrange(W), rnd.choice([rnd.randrange(264, 280), rnd.randrange(286, 344), rnd.randrange(346, 360)])
        d.point((x, y), fill=c(rnd.choice(["#d9893a", "#c2662c", "#e8b04a"])))


def lamp_and_trees(d):
    d.rectangle((384, 120, 386, 280), fill=c("#3a3f46")); d.line((384, 120, 396, 116), fill=c("#3a3f46"))
    d.rectangle((394, 114, 404, 118), fill=c("#2a2e35")); d.rectangle((396, 118, 402, 120), fill=c("#f5e1a8"))
    for (tx, top) in [(180, 120), (612, 130)]:
        d.rectangle((tx - 2, top + 50, tx + 2, 280), fill=c("#3b2c22"))
        d.line((tx, top + 70, tx - 16, top + 40), fill=c("#3b2c22")); d.line((tx, top + 60, tx + 18, top + 34), fill=c("#3b2c22"))
        rnd = random.Random(tx)
        for _ in range(26):                                              # leaf clumps
            x = tx + rnd.randint(-28, 28); y = top + rnd.randint(6, 56); r = rnd.randint(5, 10)
            if (x - tx) ** 2 / 32 ** 2 + (y - top - 32) ** 2 / 32 ** 2 <= 1:
                d.ellipse((x - r, y - r * 0.8, x + r, y + r * 0.8), fill=c(rnd.choice(["#c2662c", "#b5582a", "#d9893a"])))
        for _ in range(420):
            x = tx + rnd.randint(-36, 36); y = top + rnd.randint(0, 64)
            if (x - tx) ** 2 / 36 ** 2 + (y - top - 32) ** 2 / 34 ** 2 <= 1:
                d.point((x, y), fill=c(rnd.choice(["#e8b04a", "#f0c060", "#8e4a24", "#d9893a"])))


def van(d):
    x0, y0 = 50, 230                                                     # parked at the far kerb
    d.rectangle((x0 + 4, y0 + 60, x0 + 206, y0 + 66), fill=(0, 0, 0, 90))     # shadow
    d.rounded_rectangle((x0, y0, x0 + 170, y0 + 58), 4, fill=c("#d6d9dc"))     # cargo box
    d.polygon([(x0 + 170, y0 + 14), (x0 + 196, y0 + 18), (x0 + 210, y0 + 36), (x0 + 210, y0 + 58), (x0 + 170, y0 + 58)], fill=c("#cdd1d4"))   # cab
    d.polygon([(x0 + 174, y0 + 18), (x0 + 194, y0 + 21), (x0 + 205, y0 + 35), (x0 + 174, y0 + 35)], fill=c("#3a4a5c"))   # cab window
    d.line((x0 + 176, y0 + 20, x0 + 190, y0 + 22), fill=c("#7d93ab"))
    d.line((x0 + 2, y0 + 2, x0 + 168, y0 + 2), fill=c("#f2f4f5"))
    d.rectangle((x0 + 80, y0 + 6, x0 + 82, y0 + 56), fill=c("#9aa0a6"))          # sliding door seam
    d.line((x0 + 72, y0 + 30, x0 + 78, y0 + 30), fill=c("#5d646c"))
    d.rectangle((x0, y0 + 40, x0 + 210, y0 + 44), fill=c("#d8873c"))             # orange stripe like the shop sign
    d.rectangle((x0 + 204, y0 + 46, x0 + 210, y0 + 50), fill=c("#f5d494"))       # headlight
    for wx in (x0 + 36, x0 + 172):
        d.ellipse((wx - 13, y0 + 46, wx + 13, y0 + 72), fill=c("#17181b")); d.ellipse((wx - 6, y0 + 53, wx + 6, y0 + 65), fill=c("#8a9097"))


def draw():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    d = ImageDraw.Draw(im)
    sky(d); block(d); ground_floor(d); street(d); lamp_and_trees(d)
    van_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0)); van(ImageDraw.Draw(van_layer))
    im.alpha_composite(outline(van_layer))
    return im


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    draw().convert("RGB").save(os.path.join(out, "outside.png"))
    json.dump({"native": [W, H], "shown": [1280, 720], "scale": 2, "hotspots_logical": HOTSPOTS}, open(os.path.join(out, "outside_layout.json"), "w"), indent=1)
    print("ok")
