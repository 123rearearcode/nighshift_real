# Presentation only: draws the dust bundles and the cleaning side panel (progress bars per part and
# fan speeds). Moved unchanged from bench_view.gd in 0.11.1. Reads the sim; changes nothing.
extends RefCounted

const DustSim = preload("res://scripts/bench/dust_sim.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const UiStyle = preload("res://scripts/view/ui_style.gd")

const COLOR_DUST := Color(0.86, 0.76, 0.58, 1.0)
const COLOR_DUST_LOOSENED := Color(0.86, 0.78, 0.58, 0.95)


static func draw_dust(canvas: CanvasItem, dust: DustSim) -> void:
    for b in range(dust.count):
        var st: int = dust.b_state[b]
        if st == DustSim.GONE or dust.is_hidden(b):
            continue
        var nodes: PackedVector2Array = dust.shown[b]
        var color: Color = COLOR_DUST
        if st == DustSim.STUCK:
            color = COLOR_DUST.lerp(COLOR_DUST_LOOSENED, (1.0 - dust.b_loosen[b]) / (1.0 - DustSim.LOOSEN_FLOOR))
        else:
            color.a = 0.85
        if nodes.size() > 1: canvas.draw_polyline(nodes, color, 3.0)
        for p: Vector2 in nodes:
            canvas.draw_circle(p, 1.7 if nodes.size() == 1 else 2.4, color)
        if nodes.size() > 1: canvas.draw_circle(nodes[0], 3.4, color.darkened(0.25))   # the anchored end


static func draw_panel(canvas: CanvasItem, dust: DustSim, zones: Array, zone_done: Array, done_count: int, panel_x: float, cooler_rpm: float, case_rpm: float) -> void:
    var removed: float = 1.0 - dust.remaining_fraction()
    UiStyle.label(canvas, Vector2(panel_x, 268), "Dust removed from the whole PC: %d%%" % roundi(removed * 100.0), 17)
    UiStyle.bar(canvas, Rect2(panel_x, 276, 520, 14), removed, UiStyle.TONE_COLORS[1] if done_count == zones.size() else Color(0.35, 0.65, 0.95))
    for i in range(zones.size()):
        var z: Dictionary = zones[i]
        var y: float = 310.0 + i * 22.0
        var part_removed: float = 1.0 if bool(zone_done[i]) else dust.removed_fraction(i)
        UiStyle.label(canvas, Vector2(panel_x, y), str(z["label"]), 14)
        UiStyle.bar(canvas, Rect2(panel_x + 190, y - 12, 240, 12), part_removed, UiStyle.TONE_COLORS[1] if bool(zone_done[i]) else Color(0.35, 0.65, 0.95), DustZones.CLEAN_AT)
        UiStyle.label(canvas, Vector2(panel_x + 442, y), "clean" if bool(zone_done[i]) else "%d%%" % roundi(part_removed * 100.0), 14, UiStyle.TONE_COLORS[1] if bool(zone_done[i]) else UiStyle.COLOR_TEXT)
    UiStyle.label(canvas, Vector2(panel_x, 510), "CPU cooler fan: %d RPM    Case fan: %d RPM" % [roundi(cooler_rpm), roundi(case_rpm)], 15)
    UiStyle.label(canvas, Vector2(panel_x, 526), "Blades turn at exactly these speeds (demo scale; real fans are faster).", 11)
