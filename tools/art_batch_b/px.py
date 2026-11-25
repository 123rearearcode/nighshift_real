# Small pixel-art helpers: aliased PIL drawing on RGBA canvases plus outline and light passes.
from PIL import Image, ImageDraw
import numpy as np

OUT = (20, 22, 30, 255)


def canvas(w, h):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def c(rgb, a=255):
    if isinstance(rgb, str):
        rgb = tuple(int(rgb[i:i + 2], 16) for i in (1, 3, 5))
    return (rgb[0], rgb[1], rgb[2], a)


def mix(a, b, t):
    a = c(a); b = c(b)
    return tuple(int(round(a[i] * (1 - t) + b[i] * t)) for i in range(3)) + (255,)


def outline(im, colour=OUT, inner=False):
    """Outer 1 px outline around the alpha mask (or recolour the edge pixels when inner=True)."""
    a = np.array(im)
    m = a[:, :, 3] > 0
    pad = np.pad(m, 1)
    nb = pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:]
    allnb = pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:]
    if inner:
        edge = m & ~allnb
    else:
        edge = ~m & nb
    a[edge] = colour
    return Image.fromarray(a)


def light(im, hi=0.22, lo=0.30, skip=OUT):
    """Fixed top-left light: pixels whose upper/left neighbour is outline/empty get a highlight,
    lower/right ones a shade. Applied after rotation so the light never turns with the item."""
    a = np.array(im).astype(np.int32)
    m = a[:, :, 3] > 0
    isout = m & (a[:, :, 0] == skip[0]) & (a[:, :, 1] == skip[1]) & (a[:, :, 2] == skip[2])
    body = m & ~isout
    pad = np.pad(body, 1)
    up = pad[:-2, 1:-1]; left = pad[1:-1, :-2]; down = pad[2:, 1:-1]; right = pad[1:-1, 2:]
    hl = body & (~up | ~left)
    sh = body & (~down | ~right) & ~hl
    out = a.copy()
    out[hl, :3] = (a[hl, :3] + (255 - a[hl, :3]) * hi).astype(np.int32)
    out[sh, :3] = (a[sh, :3] * (1 - lo)).astype(np.int32)
    return Image.fromarray(out.clip(0, 255).astype(np.uint8))


def up(im, k=2):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def dither_rect(d, box, col_a, col_b):
    x0, y0, x1, y1 = box
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            d.point((x, y), fill=col_a if (x + y) % 2 == 0 else col_b)
