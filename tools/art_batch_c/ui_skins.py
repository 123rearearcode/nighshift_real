# ART-18 (only where it helps): frames for the two existing screens, pixel art at 2x like the other room
# objects. The screen areas are transparent so the game's live UI shows through unchanged.
# - Phone (phone_panel.gd, 400 x 600): native 200 x 300, 6 px bezel; the app's labels start inside it.
# - Diagnostic monitor (software_view.gd): bezel Rect2(32,88,878,550), screen Rect2(48,104,846,516),
#   neck Rect2(420,638,100,17), foot Rect2(364,654,212,8) -> one picture covering (32,88)-(910,662),
#   native 439 x 287 with the screen hole at (8,8)-(430,265).
import os, sys
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))   # shared comic/pixel helpers
from px import canvas, c, outline, OUT


def phone():
    im, d = canvas(200, 300)
    d.rounded_rectangle((0, 0, 199, 299), 20, fill=c("#2a2e35"))
    d.rounded_rectangle((1, 1, 198, 298), 19, outline=c("#4b525c"))
    d.line((14, 1, 186, 1), fill=c("#6a727e"))                                   # lit top edge
    d.rounded_rectangle((5, 5, 194, 294), 15, fill=c("#14171b"))
    d.rounded_rectangle((6, 6, 193, 293), 14, fill=(0, 0, 0, 0))                # the screen: transparent
    d.ellipse((97, 1, 102, 4), fill=c("#0b0c0e")); d.point((98, 2), fill=c("#3d5a7a"))   # camera
    d.line((198, 60, 198, 84), fill=c("#59606b")); d.line((198, 96, 198, 110), fill=c("#59606b"))   # side buttons
    d.line((8, 282, 22, 268), fill=c("#9fb4c4")); d.line((10, 286, 18, 278), fill=c("#9fb4c4"))   # a small crack in the corner
    return im


def monitor():
    W, H = 439, 287
    im, d = canvas(W, H)
    d.rectangle((166, 283, 271, 286), fill=c("#45505a"))                          # foot
    d.line((166, 283, 271, 283), fill=c("#6b7884"))
    d.rectangle((194, 271, 243, 283), fill=c("#3a444e"))                          # neck
    d.line((194, 271, 194, 283), fill=c("#56626d"))
    d.rounded_rectangle((0, 0, W - 1, 274), 6, fill=c("#2f3842"))                 # bezel
    d.line((4, 1, W - 5, 1), fill=c("#55626f"))
    d.line((1, 4, 1, 270), fill=c("#46525e"))
    d.rectangle((7, 7, W - 8, 266), fill=c("#11161a"))                            # inner lip
    d.rectangle((8, 8, W - 9, 265), fill=(0, 0, 0, 0))                            # the screen: transparent
    d.rectangle((W - 40, 268, W - 34, 271), fill=c("#1b2025"))                    # power LED housing (LED is live)
    for x in range(20, 60, 3): d.point((x, 270), fill=c("#262e36"))              # speaker dots
    return im


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    outline(phone()).save(os.path.join(out, "phone_shell.png"))
    outline(monitor()).save(os.path.join(out, "monitor_bezel.png"))
    print("ok")
