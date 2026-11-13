# Presentation only: draws the paste stage (socket, paste picture, pressing plate, legend) and the
# paste side panel. Moved unchanged from bench_view.gd in 0.11.1. Reads the sim and the mount
# session; decides nothing and changes nothing.
extends RefCounted

const PasteSim = preload("res://scripts/bench/paste_sim.gd")
const MountSession = preload("res://scripts/bench/mount_session.gd")
const UiStyle = preload("res://scripts/view/ui_style.gd")

const COLOR_CPU := Color(0.26, 0.32, 0.47)
const COLOR_CPU_EDGE := Color(0.62, 0.70, 0.88)
const PASTE_THIN := Color(0.55, 0.85, 0.95)
const PASTE_THICK := Color(1.0, 1.0, 1.0)
const TOOTH_THIN := Color(0.70, 0.95, 0.85)    # toothpaste: minty white
const TOOTH_THICK := Color(0.98, 1.0, 0.98)
const PASTE_EDGE := Color(0.20, 0.55, 0.70)
const COLOR_BARE := Color(1.0, 0.25, 0.25, 0.55)
const COLOR_SQUEEZED := Color(1.0, 0.72, 0.2, 0.95)


static func _paste_at(paste: PasteSim, x: int, y: int) -> float:
    if x < 0 or y < 0 or x >= PasteSim.GRID or y >= PasteSim.GRID:
        return 0.0
    return paste.h[y * PasteSim.GRID + x]


# Paste picture: thickness shading, a dark rim on every edge. Paste outside the CPU is orange
# while mounting and after; red = bare CPU cells is shown only after mounting.
static func refresh_image(paste: PasteSim, image: Image, texture: ImageTexture, show_result: bool, show_outside: bool) -> void:
    var stamp: Array = [paste.get_instance_id(),paste.revision,paste.material,show_result,show_outside,image.get_instance_id()]
    if texture.get_meta("paste_stamp",[]) == stamp: return
    var grid: int = PasteSim.GRID
    for y in range(grid):
        for x in range(grid):
            var v: float = paste.h[y * grid + x]
            var on_cpu: bool = x >= PasteSim.CPU_MIN and x < PasteSim.CPU_MAX and y >= PasteSim.CPU_MIN and y < PasteSim.CPU_MAX
            var c := Color(0, 0, 0, 0)
            if v >= 0.015:
                var t: float = clampf(sqrt(v) / 1.2, 0.0, 1.0)
                c = TOOTH_THIN.lerp(TOOTH_THICK, t) if paste.material == "toothpaste" else PASTE_THIN.lerp(PASTE_THICK, t)
                c.a = 0.92
                var rim: bool = _paste_at(paste, x + 1, y) < 0.015 or _paste_at(paste, x - 1, y) < 0.015 or _paste_at(paste, x, y + 1) < 0.015 or _paste_at(paste, x, y - 1) < 0.015
                if show_outside and not on_cpu:
                    c = COLOR_SQUEEZED
                elif rim:
                    c = PASTE_EDGE
            elif show_result and on_cpu:
                c = COLOR_BARE
            image.set_pixel(x, y, c)
    texture.update(image)
    texture.set_meta("paste_stamp",stamp)
    texture.set_meta("paste_uploads",int(texture.get_meta("paste_uploads",0))+1)


static func draw_stage(canvas: CanvasItem, paste: PasteSim, texture: ImageTexture, origin: Vector2, cell_px: int, mount: MountSession) -> void:
    var side: float = PasteSim.GRID * cell_px
    var region := Rect2(origin, Vector2(side, side))
    canvas.draw_rect(region.grow(14.0), Color(0.16, 0.17, 0.2))
    canvas.draw_rect(region, Color(0.07, 0.08, 0.10))
    var cpu_pos: Vector2 = origin + Vector2(PasteSim.CPU_MIN, PasteSim.CPU_MIN) * cell_px
    var cpu_side: float = (PasteSim.CPU_MAX - PasteSim.CPU_MIN) * cell_px
    var cpu := Rect2(cpu_pos, Vector2(cpu_side, cpu_side))
    canvas.draw_rect(cpu, COLOR_CPU)
    canvas.draw_rect(cpu, COLOR_CPU_EDGE, false, 3.0)
    # Aim guide: faint crosshair and ring at the centre, hidden once paste is down.
    var mid: Vector2 = cpu.get_center()
    if paste.total_deposited < 25.0 and not mount.active:
        var guide := Color(1, 1, 1, 0.28)
        canvas.draw_line(mid + Vector2(-20, 0), mid + Vector2(20, 0), guide, 2.0)
        canvas.draw_line(mid + Vector2(0, -20), mid + Vector2(0, 20), guide, 2.0)
        canvas.draw_arc(mid, 24.0, 0.0, TAU, 32, guide, 2.0)
        UiStyle.label(canvas, mid + Vector2(-34, 46), "aim here", 13, Color(1, 1, 1, 0.5))
    UiStyle.label(canvas, cpu.position + Vector2(8, 20), "CPU heat spreader", 14, Color(0.85, 0.9, 1.0))
    canvas.draw_texture_rect(texture, region, false)
    UiStyle.label(canvas, region.position + Vector2(0, -22), "CPU SOCKET (top view)", 16)
    if mount.active:
        var plate: Rect2 = region.grow(lerpf(30.0, 4.0, mount.pressure))
        canvas.draw_rect(plate, Color(0.45, 0.55, 0.75, 0.08 + 0.22 * mount.pressure))
        canvas.draw_rect(plate, Color(0.7, 0.8, 1.0, 0.7), false, 3.0)
        UiStyle.label(canvas, plate.position + Vector2(8, 22), "cooler pressing down...", 14)
    # Legend under the socket.
    var ly: float = origin.y + side + 36.0
    _legend_item(canvas, Vector2(origin.x, ly), Color(0.85, 0.97, 1.0), "paste")
    _legend_item(canvas, Vector2(origin.x + 110, ly), COLOR_BARE, "bare CPU (after mounting)")
    _legend_item(canvas, Vector2(origin.x + 330, ly), COLOR_SQUEEZED, "squeezed out")


# The cooler's retention lever beside the socket. Up = open (while mounting it can be pulled), down =
# locked. It glows while it can be pulled and brighter under the cursor. Drawing only.
static func draw_lever(canvas: CanvasItem, rect: Rect2, can_pull: bool, locked: bool, hovered: bool, time: float) -> void:
    var pivot := Vector2(rect.get_center().x, rect.end.y - 18.0)
    canvas.draw_rect(Rect2(pivot - Vector2(16, 10), Vector2(32, 22)), Color(0.30, 0.33, 0.38))
    canvas.draw_rect(Rect2(pivot - Vector2(16, 10), Vector2(32, 22)), Color(0.62, 0.66, 0.72), false, 2.0)
    var up: bool = not locked
    # Open: standing straight up. Locked: folded down flat, pointing away from the socket.
    var tip: Vector2 = pivot + (Vector2(0, -(rect.size.y - 46.0)) if up else Vector2(84, 0))
    var arm: Color = Color(0.78, 0.80, 0.84) if not can_pull else Color(0.95, 0.85, 0.45)
    if can_pull:
        var glow: float = 0.35 + 0.25 * sin(time * 6.0) + (0.3 if hovered else 0.0)
        canvas.draw_line(pivot, tip, Color(1.0, 0.85, 0.3, glow * 0.5), 16.0)
    canvas.draw_line(pivot, tip, arm, 7.0)
    canvas.draw_circle(tip, 9.0, Color(0.85, 0.22, 0.20) if can_pull else Color(0.55, 0.58, 0.62))
    canvas.draw_circle(pivot, 5.0, Color(0.15, 0.16, 0.18))
    var label: String = "LEVER\nclick to lock" if can_pull else ("locked" if locked else "lever")
    UiStyle.label(canvas, Vector2(rect.position.x - 4, rect.end.y + 16), label, 12, Color(1.0, 0.9, 0.5) if can_pull else Color(0.7, 0.75, 0.8))


static func _legend_item(canvas: CanvasItem, pos: Vector2, color: Color, text: String) -> void:
    canvas.draw_rect(Rect2(pos, Vector2(16, 16)), color)
    canvas.draw_rect(Rect2(pos, Vector2(16, 16)), Color(1, 1, 1, 0.6), false, 1.0)
    UiStyle.label(canvas, pos + Vector2(22, 13), text, 13)


static func draw_panel(canvas: CanvasItem, paste: PasteSim, panel_x: float, mount: MountSession, has_result: bool, live_stats: Dictionary) -> void:
    var tone: int = paste.gauge_tone()
    UiStyle.label(canvas, Vector2(panel_x, 310), "Paste on the CPU socket: %d units" % roundi(paste.total_deposited), 17)
    UiStyle.label(canvas, Vector2(panel_x, 332), "Gauge: " + paste.gauge_text(), 15, UiStyle.TONE_COLORS[tone])
    var full: float = PasteSim.GAUGE_FULL
    var bar := Rect2(panel_x, 342, 520, 14)
    UiStyle.bar(canvas, bar, paste.total_deposited / full, UiStyle.TONE_COLORS[tone])
    var ideal_a: float = bar.position.x + bar.size.x * PasteSim.GAUGE_GOOD_MIN / full
    var ideal_b: float = bar.position.x + bar.size.x * PasteSim.GAUGE_GOOD_MAX / full
    canvas.draw_rect(Rect2(ideal_a, bar.position.y - 4.0, ideal_b - ideal_a, bar.size.y + 8.0), Color(0.25, 0.95, 0.35, 0.25))
    UiStyle.label(canvas, Vector2(panel_x + 280, 330), "Green zone = about a pea of paste", 12)
    if mount.active or has_result:
        var cov: float = live_stats["coverage"]
        var over: float = live_stats["overflow"]
        if mount.active:
            UiStyle.label(canvas, Vector2(panel_x, 380), "Pressure (hold mouse over socket, or Space)", 14)
            UiStyle.bar(canvas, Rect2(panel_x, 386, 520, 14), mount.pressure, Color(0.45, 0.6, 0.9))
        UiStyle.label(canvas, Vector2(panel_x, 420), "CPU covered: %d%%   (line = %d%%)" % [roundi(cov * 100.0), roundi(MountSession.TARGET_COVER * 100.0)], 14)
        UiStyle.bar(canvas, Rect2(panel_x, 426, 520, 14), cov, UiStyle.TONE_COLORS[1] if cov >= MountSession.TARGET_COVER else Color(0.35, 0.65, 0.95), MountSession.TARGET_COVER)
        UiStyle.label(canvas, Vector2(panel_x, 460), "Squeezed out: %d%%   (stay under the line)" % roundi(over * 100.0), 14)
        UiStyle.bar(canvas, Rect2(panel_x, 466, 520, 14), over / MountSession.OVERFLOW_SCALE, UiStyle.TONE_COLORS[2] if over > MountSession.OVERFLOW_LIMIT else COLOR_SQUEEZED, MountSession.OVERFLOW_LIMIT / MountSession.OVERFLOW_SCALE)
        if mount.active:
            UiStyle.label(canvas, Vector2(panel_x, 500), "Time left: %.1f s" % maxf(0.0, mount.time_left), 14)
            UiStyle.bar(canvas, Rect2(panel_x + 130, 492, 390, 8), mount.time_left / MountSession.MOUNT_TIME, Color(0.8, 0.8, 0.85))
