# Review mock (not game art): the open case lying on its side with board, parts and the two clean cables.
import sys, math, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art_batch_b"))
from PIL import Image
import parts_comic as pc
U = 64
O = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out") + "/"
L = lambda p: Image.open(O + p).convert('RGBA')


def cable(img, pts, w):
    pc.S = 2
    p = pc.Pen(img.width, img.height)
    p.line(pts, (12, 13, 16, 255), w + 4)
    p.line(pts, (42, 45, 51, 255), w)
    for (a, b) in zip(pts, pts[1:]):
        dx, dy = b[0] - a[0], b[1] - a[1]; n_ = math.hypot(dx, dy) or 1; nx, ny = -dy / n_, dx / n_
        for k in range(int(n_ // 6)):
            t = k / max(1, int(n_ // 6)); x = a[0] + dx * t; y = a[1] + dy * t
            p.line([(x - nx * w * 0.4, y - ny * w * 0.4), (x + nx * w * 0.4 + dx / n_ * 4, y + ny * w * 0.4 + dy / n_ * 4)], (78, 84, 94, 200), 1.0)
    img.alpha_composite(p.im.resize(img.size, Image.LANCZOS))


def build():
    case = L('ART-14/case_tower_interior.png'); case.alpha_composite(L('ART-17c/case_tower_walls.png'))
    case.alpha_composite(L('ART-14/board_demo_l.png'), (3 * U, 2 * U))
    for n, (x, y) in [('cpu_bare', (0, 1)), ('cooler', (0, 4)), ('ram', (4, 0)), ('ram', (5, 0)), ('gpu', (0, 6)), ('storage_ssd', (4, 8))]:
        case.alpha_composite(L(f'ART-15/board/{n}_r0.png'), ((3 + x) * U, (2 + y) * U))
    case.alpha_composite(L('ART-17c/plug_24pin.png'), (8 * U, 6 * U))
    cable(case, [(13.62 * U, 7.0 * U), (11.05 * U, 7.0 * U)], 34)
    gx, gy = 3 * U + 436, 8 * U + 6
    case.alpha_composite(L('ART-17c/plug_8pin.png'), (gx, gy))
    cable(case, [(13.62 * U, 7.6 * U), (11.45 * U, 7.6 * U), (11.45 * U, 8.35 * U), (10.6 * U, 8.35 * U)], 14)
    case.alpha_composite(L('ART-17c/comb_24pin.png'), (int(12.6 * U), int(7.0 * U - 25)))
    case.alpha_composite(L('ART-17c/comb_8pin.png'), (int(12.3 * U), int(7.6 * U - 14)))
    return case


if __name__ == "__main__":
    build().save(sys.argv[1])
