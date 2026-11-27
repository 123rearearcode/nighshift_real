# 0.58.9, by Claude (Opus 5.5, model id claude-opus-5-5). Export the approved wall drafts as runtime layers and prove the layers rebuild the approved pictures.
import sys
import numpy as np
from PIL import Image
src = open('walls.py').read().split('opts = [')[0]
exec(src)
OUT = sys.argv[1]
REPO = sys.argv[2]
names = {"cream_tiles": (wall_cream_tiles, 1), "oil_paint": (wall_oil_paint, 2), "pine_wallpaper": (wall_wood_wallpaper, 3), "blue_plaster": (wall_blue_plaster, 4)}
def render_with_layer(layer, label):
    # the same steps as render(), with the wall coming from the saved layer
    global render
    c = Image.new("RGBA", (W, H), (0x15,0x23,0x2b,255))
    flat.full(c, "shell"); flat.flat_wall(c)
    c.alpha_composite(layer, (0, 0))
    return c
for name, (fn, idx) in names.items():
    c = Image.new("RGBA", (W, H), (0x15,0x23,0x2b,255)); flat.full(c, "shell"); flat.flat_wall(c)
    shellc = c.copy(); w = fn(); m = np.asarray(keep_mask(shellc)).astype(float)/255.0
    a = np.asarray(w).copy()
    a[:, :, 3] = (a[:, :, 3].astype(float) * (1.0 - m[:FLOOR, :])).astype(np.uint8) if a.shape[0] == FLOOR else a[:, :, 3]
    layer = Image.fromarray(a)
    layer.save(f"{OUT}/wall_{name}.png")
    # rebuild: shell + layer must equal shell + wall + keep paste (what the approved draft used)
    ref = shellc.copy(); ref.alpha_composite(w, (0,0)); ref.paste(shellc, (0,0), keep_mask(shellc))
    test = shellc.copy(); test.alpha_composite(layer, (0,0))
    diff = np.abs(np.asarray(ref).astype(int) - np.asarray(test).astype(int)).max()
    print(name, "layer vs draft wall step max diff:", diff)
