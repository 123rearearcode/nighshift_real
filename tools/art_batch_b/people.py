# ART-08 look-review sketches: Mara V. (t001_mara, hotel front-desk clerk, polite, in a hurry) and
# Relu D. (t002_relu, economics student, ranked gamer, chatty). Upper body standing behind the counter;
# the bottom rows are hidden by the counter front. Native 120 x 172, shown at 2x. Window light from the
# left (viewer's left): left planes lighter, right planes in shadow.
import os, sys
from PIL import Image
sys.path.insert(0, os.path.dirname(__file__))
from px import canvas, c, mix, outline, OUT

W, H = 120, 172


def body(d, cloth, cloth_sh, cloth_hi, n=0):
    d.polygon([(30 + n, 74), (50, 66), (70, 66), (90 - n, 74), (100 - n, 86), (104 - n, H), (16 + n, H), (20 + n, 86)], fill=c(cloth))
    d.polygon([(90 - n, 74), (100 - n, 86), (104 - n, H), (84 - n, H), (86 - n, 96)], fill=c(cloth_sh))        # shadow side
    d.polygon([(30 + n, 74), (40 + n, 70), (34 + n, 82), (24 + n, 96), (20 + n, 86)], fill=c(cloth_hi))       # lit shoulder
    d.line((30 + n, 100, 32 + n, H), fill=c(cloth_sh))                                              # arms at the sides
    d.line((89 - n, 100, 88 - n, H), fill=c(mix(cloth_sh, "#000000", 0.25)))


def head(d, skin, sh, hi, deep, jaw=0):
    d.rectangle((53, 54, 67, 72), fill=c(skin))                                           # neck
    d.rectangle((60, 54, 67, 72), fill=c(sh))
    d.polygon([(53, 56), (67, 56), (67, 62), (53, 60)], fill=c(deep))                      # under the chin
    d.ellipse((41, 36, 46, 46), fill=c(skin)); d.ellipse((74, 36, 79, 46), fill=c(sh))    # ears
    d.point((43, 41), fill=c(sh)); d.point((77, 41), fill=c(deep))
    d.ellipse((44, 14, 76, 54), fill=c(skin))                                             # skull/face
    d.polygon([(45, 40), (75, 40), (72 + jaw, 52), (64, 59), (56, 59), (48 - jaw, 52)], fill=c(skin))   # jaw
    d.polygon([(68, 22), (76, 34), (74, 46), (70 + jaw, 53), (63, 59), (66, 50), (70, 40)], fill=c(sh))  # shadow side
    d.point((48, 44), fill=c(hi)); d.point((49, 45), fill=c(hi)); d.point((48, 30), fill=c(hi))


def face(d, skin, sh, hi, deep, lip, brow, iris, smile=0, grin=False):
    for x in range(49, 56):
        d.point((x, 33 - (1 if 51 <= x <= 53 else 0)), fill=c(brow))                      # brows
    for x in range(65, 72):
        d.point((x, 33 - (1 if 67 <= x <= 69 else 0)), fill=c(brow))
    for ex in (50, 66):                                                                     # eyes
        d.line((ex, 37, ex + 5, 37), fill=c("#2a1f1c"))
        d.point((ex, 38), fill=c("#e8e4de")); d.point((ex + 5, 38), fill=c(sh))
        d.rectangle((ex + 2, 38, ex + 3, 39), fill=c(iris))
        d.point((ex + 2, 38), fill=c("#f2efe9"))
        d.line((ex + 1, 40, ex + 4, 40), fill=c(sh))
    d.line((61, 39, 62, 45), fill=c(sh))                                                   # nose
    d.point((60, 40), fill=c(hi)); d.point((60, 42), fill=c(hi))
    d.point((58, 47), fill=c(deep)); d.point((63, 47), fill=c(deep)); d.line((59, 48, 62, 48), fill=c(sh))
    if grin:
        d.line((55, 52, 66, 51), fill=c(lip)); d.line((57, 53, 65, 53), fill=c(deep))
        d.point((66, 50), fill=c(lip)); d.line((58, 52, 63, 52), fill=c("#efe9df"))
    else:
        d.line((56, 52, 64, 52), fill=c(lip)); d.point((55, 51 - smile), fill=c(lip)); d.point((65, 51 - smile), fill=c(lip))
        d.line((57, 54, 63, 54), fill=c(sh))
    d.point((51, 44), fill=c(mix(skin, lip, 0.35))); d.point((52, 44), fill=c(mix(skin, lip, 0.35)))


def mara():
    im, d = canvas(W, H)
    skin, sh, hi, deep = "#d6a88a", "#b0836a", "#e8c3a6", "#8c6152"
    hair, hair_sh, hair_hi = "#3e2a22", "#2a1c18", "#62443a"
    d.ellipse((70, 8, 88, 26), fill=c(hair_sh))                                            # low bun behind
    d.ellipse((72, 10, 84, 20), fill=c(hair))
    body(d, "#2e3a5c", "#1f2840", "#45557f", 6)                                              # hotel blazer
    d.polygon([(52, 66), (68, 66), (60, 98)], fill=c("#e4e6e8"))                           # blouse
    d.polygon([(60, 66), (68, 66), (60, 98)], fill=c("#bfc3ca"))
    d.polygon([(50, 66), (44, 72), (54, 108), (60, 98)], fill=c("#3a4870"))                # lapels
    d.polygon([(70, 66), (76, 72), (66, 108), (60, 98)], fill=c("#26304d"))
    d.line((44, 72, 54, 108), fill=c("#1b2236")); d.line((76, 72, 66, 108), fill=c("#151b2b"))
    d.rectangle((72, 92, 82, 96), fill=c("#cfa955")); d.line((72, 92, 82, 92), fill=c("#ead08a"))   # blank name badge
    for y in (118, 136):
        d.point((60, y), fill=c("#9aa3b8"))                                                # buttons
    d.line((38, 72, 92, H - 2), fill=c("#6e3e2e")); d.line((39, 72, 93, H - 2), fill=c("#8a5440"))   # bag strap
    head(d, skin, sh, hi, deep)
    # hair pulled back, side parting, fringe swept to the right
    d.pieslice((42, 10, 78, 50), 180, 360, fill=c(hair))
    d.polygon([(42, 30), (46, 22), (56, 15), (68, 15), (77, 24), (78, 34), (74, 28), (64, 24), (52, 27), (46, 34)], fill=c(hair))
    d.polygon([(52, 27), (64, 24), (74, 28), (78, 34), (77, 24), (68, 15)], fill=c(hair_sh))
    d.line((47, 22, 56, 16), fill=c(hair_hi)); d.line((48, 24, 58, 18), fill=c(hair_hi))
    d.line((42, 30, 43, 40), fill=c(hair)); d.line((78, 32, 77, 40), fill=c(hair_sh))     # tucked behind ears
    face(d, skin, sh, hi, deep, "#a65f5c", "#3a2620", "#4a3426", smile=1)
    d.point((41, 46), fill=c("#e0c070")); d.point((79, 46), fill=c("#b89a50"))            # stud earrings
    return outline(im)


def relu():
    im, d = canvas(W, H)
    skin, sh, hi, deep = "#c49470", "#9c7056", "#dcb08e", "#7a5442"
    hair, hair_sh, hair_hi = "#24201f", "#161313", "#463d39"
    body(d, "#5c6846", "#424b32", "#79885c")                                              # hoodie
    d.polygon([(38, 70), (50, 63), (70, 63), (82, 70), (78, 80), (60, 84), (42, 80)], fill=c("#4e593b"))   # hood around the neck
    d.line((42, 80, 60, 84), fill=c("#353d28")); d.line((60, 84, 78, 80), fill=c("#353d28"))
    d.line((56, 82, 55, 112), fill=c("#d9d5c8")); d.line((64, 82, 65, 110), fill=c("#bdb8aa"))   # drawstrings
    d.rectangle((54, 112, 56, 115), fill=c("#9aa3ab")); d.rectangle((64, 110, 66, 113), fill=c("#9aa3ab"))
    d.line((34, 146, 86, 146), fill=c("#424b32")); d.line((34, 146, 30, H), fill=c("#424b32")); d.line((86, 146, 90, H), fill=c("#424b32"))  # pocket
    d.arc((45, 50, 75, 80), 180, 360, fill=c("#202227"), width=3)                   # band, behind the neck
    d.line((46, 64, 45, 70), fill=c("#202227"), width=2); d.line((74, 64, 75, 70), fill=c("#202227"), width=2)   # yokes
    head(d, skin, sh, hi, deep, jaw=1)
    # headphones round the neck: the cups rest on the collarbones facing up, the band runs behind the neck
    for x0 in (38, 68):
        d.ellipse((x0, 68, x0 + 14, 79), fill=c("#25272c"))                          # cup shell
        d.ellipse((x0 + 2, 69, x0 + 12, 75), fill=c("#4a4d55"))                      # cushion, facing up
        d.ellipse((x0 + 4, 70, x0 + 10, 73), fill=c("#33363c"))
        d.line((x0 + 2, 77, x0 + 12, 77), fill=c("#17181b"))
    d.point((44, 78), fill=c("#d0604c")); d.point((74, 78), fill=c("#b04c3c"))      # small accent, no logo
    # short hair, a bit messy on top
    d.pieslice((43, 11, 77, 47), 180, 360, fill=c(hair))
    d.polygon([(43, 30), (44, 20), (48, 13), (52, 10), (55, 13), (58, 8), (62, 12), (66, 9), (69, 13), (73, 13),
               (76, 20), (77, 30), (73, 24), (66, 22), (58, 24), (50, 23), (46, 28)], fill=c(hair))
    d.polygon([(66, 22), (73, 24), (77, 30), (76, 20), (73, 13)], fill=c(hair_sh))
    for p in [(50, 14), (51, 15), (57, 11), (58, 12), (64, 12)]:
        d.point(p, fill=c(hair_hi))
    d.line((43, 30, 44, 37), fill=c(hair)); d.line((77, 30, 76, 37), fill=c(hair_sh))      # sideburns
    face(d, skin, sh, hi, deep, "#8e5a4c", "#1e1919", "#3b2a22", grin=True)
    # glasses
    for x0 in (48, 64):
        d.rectangle((x0, 35, x0 + 8, 41), outline=c("#1f1f25"))
    d.line((57, 36, 63, 36), fill=c("#1f1f25"))
    d.line((44, 36, 47, 36), fill=c("#1f1f25")); d.line((73, 36, 76, 36), fill=c("#1f1f25"))
    d.point((49, 36), fill=c("#dfe8ee")); d.point((65, 36), fill=c("#dfe8ee"))
    return outline(im)


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    mara().save(os.path.join(out, "mara_neutral.png"))
    relu().save(os.path.join(out, "relu_neutral.png"))
    print("ok")
