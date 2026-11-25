# Presentation only: draws the dust bundles and the cleaning side panel (progress bars per part and
# fan speeds). Moved unchanged from bench_view.gd in 0.11.1. Reads the sim; changes nothing.
extends RefCounted

const DustSim = preload("res://scripts/bench/dust_sim.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const Layout = preload("res://scripts/data/layout.gd")
const UiStyle = preload("res://scripts/view/ui_style.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const DustMotes = preload("res://scripts/bench/dust_motes.gd")
const ItemArt = preload("res://scripts/view/item_art.gd")   # 0.57.8: approved bin and dust art

const COLOR_DUST := Color(0.86, 0.76, 0.58, 1.0)
const COLOR_DUST_LOOSENED := Color(1.0, 0.92, 0.72, 1.0)


static func draw_dust(canvas: CanvasItem, dust: DustSim) -> void:
    draw_dust_films(canvas, dust)
    for b in range(dust.count):
        var st: int = dust.b_state[b]
        if st == DustSim.GONE: continue
        if dust.is_hidden(b):
            var tail: PackedVector2Array = dust.tail_nodes(b)
            if tail.size() > 1:
                canvas.draw_polyline(tail,Color("8b7355"),4.0,true)
                canvas.draw_polyline(tail,COLOR_DUST.lerp(Color("fff0b5"),dust.b_stress[b]),2.0,true)
                for k in range(1,tail.size()): canvas.draw_circle(tail[k],1.8,COLOR_DUST)
            continue
        var nodes: PackedVector2Array = dust.shown[b]
        var color: Color = COLOR_DUST
        if st == DustSim.STUCK:
            color = COLOR_DUST.lerp(COLOR_DUST_LOOSENED, (1.0 - dust.b_loosen[b]) / (1.0 - DustSim.LOOSEN_FLOOR))
        elif st == DustSim.TOSSED:
            color = COLOR_DUST_LOOSENED
        else:
            color.a = 0.85
        if nodes.size() > 1: canvas.draw_polyline(nodes, color, 3.0)
        for p: Vector2 in nodes:
            canvas.draw_circle(p, 1.7 if nodes.size() == 1 else 2.4, color)
        if nodes.size() > 1: canvas.draw_circle(nodes[0], 3.4, color.darkened(0.25))   # the anchored end
    for blocker: Dictionary in dust.blockers:
        var trapped: int = dust.trapped_count(str(blocker["id"]))
        if trapped > 0:
            var rect: Rect2 = blocker["rect"]
            UiStyle.label(canvas,rect.position+Vector2(2,rect.size.y+12),"Trapped: %d" % trapped,11,Color("e2bd7b"))


static func draw_panel(canvas: CanvasItem, dust: DustSim, zones: Array, zone_done: Array, done_count: int, panel_x: float, cooler_rpm: float, case_rpm: float) -> void:
    var removed: float = 1.0 - dust.remaining_fraction()
    UiStyle.label(canvas, Vector2(panel_x, 304), "Dust removed from the whole PC: %d%%" % roundi(removed * 100.0), 17)
    UiStyle.bar(canvas, Rect2(panel_x, 312, 520, 12), removed, UiStyle.TONE_COLORS[1] if done_count == zones.size() else Color(0.35, 0.65, 0.95))
    for i in range(zones.size()):
        var z: Dictionary = zones[i]
        var y: float = 350.0 + i * 18.0
        var part_removed: float = 1.0 if bool(zone_done[i]) else dust.removed_fraction(i)
        UiStyle.label(canvas, Vector2(panel_x, y), str(z["label"]), 14)
        UiStyle.bar(canvas, Rect2(panel_x + 190, y - 12, 240, 12), part_removed, UiStyle.TONE_COLORS[1] if bool(zone_done[i]) else Color(0.35, 0.65, 0.95), DustZones.CLEAN_AT)
        UiStyle.label(canvas, Vector2(panel_x + 442, y), "clean" if bool(zone_done[i]) else "%d%%" % roundi(part_removed * 100.0), 14, UiStyle.TONE_COLORS[1] if bool(zone_done[i]) else UiStyle.COLOR_TEXT)
    UiStyle.label(canvas, Vector2(panel_x, 520), "CPU cooler fan: %d RPM    Case fan: %d RPM" % [roundi(cooler_rpm), roundi(case_rpm)], 15)
    UiStyle.label(canvas, Vector2(panel_x, 536), "Blades turn at exactly these speeds (demo scale; real fans are faster).", 11)


# Floating dust: faint specks that fade in and out as they drift.
# The PC's power button on the case. Lit green when on; grey when off; brighter under the cursor.
static func draw_power(canvas: CanvasItem, on: bool, hovered: bool) -> void:
    var rect: Rect2 = Layout.BENCH_POWER
    canvas.draw_rect(rect, Color("222a31"))
    canvas.draw_rect(rect, Color("5a6872"), false, 2.0)
    var center: Vector2 = rect.get_center()
    var glow: Color = Color("72d9ad") if on else Color("5a6872")
    if hovered: glow = glow.lightened(0.25)
    canvas.draw_arc(center, 7.0, -PI * 0.35, PI * 1.35, 12, glow, 2.5, true)
    canvas.draw_line(center + Vector2(0, -9), center + Vector2(0, -2), glow, 2.5)
    UiStyle.label(canvas, Vector2(rect.position.x - 32, rect.position.y + 18), "PWR", 12, glow)


# The trash can. It opens its lid while a carried item hovers over it.
static func draw_trash(canvas: CanvasItem, ready_to_eat: bool) -> void:
    var rect: Rect2 = Layout.BENCH_TRASH
    var body := Rect2(rect.position + Vector2(4, 12), rect.size - Vector2(8, 12))
    canvas.draw_rect(body, Color("37414b"))
    canvas.draw_rect(body, Color("5a6872"), false, 2.0)
    for k in range(3):
        var x: float = body.position.x + body.size.x * (0.3 + 0.2 * float(k))
        canvas.draw_line(Vector2(x, body.position.y + 6), Vector2(x, body.end.y - 6), Color("2a333b"), 2.0)
    var lid := Rect2(rect.position + Vector2(0, 4), Vector2(rect.size.x, 8))
    if ready_to_eat:
        canvas.draw_set_transform(lid.position + Vector2(2, 8), -0.5)
        canvas.draw_rect(Rect2(Vector2.ZERO, lid.size), Color("72d9ad"))
        canvas.draw_set_transform(Vector2.ZERO, 0.0)
    else:
        canvas.draw_rect(lid, Color("46535e"))
    UiStyle.label(canvas, Vector2(rect.position.x + 2, rect.end.y + 14), "trash", 12, Color(0.7, 0.75, 0.8))


# Loose items on the bench (scripts/bench/bench_items.gd). The carried one rides the cursor, lifted.
static func draw_items(canvas: CanvasItem, items: RefCounted) -> void:
    for i in range(items.count()):
        var at: Vector2 = items.centers[i]
        var held: bool = i == items.carried
        if held:
            canvas.draw_circle(at + Vector2(4, 7), 9.0, Color(0, 0, 0, 0.3))
            at -= Vector2(0, 6)
        if items.kinds[i] == "coin":
            canvas.draw_circle(at, 8.0, Color("8a6d1a"))
            canvas.draw_circle(at, 6.5, Color("d9b13b"))
            canvas.draw_arc(at, 4.0, 0.0, TAU, 14, Color("8a6d1a"), 1.5)
        else:
            canvas.draw_rect(Rect2(at - Vector2(3, 8), Vector2(6, 16)), Color("9aa4ad"))
            canvas.draw_rect(Rect2(at - Vector2(7, 10), Vector2(14, 5)), Color("7f8a93"))


static func draw_motes(canvas: CanvasItem, motes: DustMotes) -> void:
    for i in range(motes.count()):
        var fade: float = sin(PI * clampf(motes.age[i] / motes.life[i], 0.0, 1.0))
        canvas.draw_circle(motes.pos[i], motes.size[i], Color(COLOR_DUST.r, COLOR_DUST.g, COLOR_DUST.b, 0.55 * fade))


# The vacuum's dust bin: a canister on the bench with a fill meter. The hose is anchored to it.
static func draw_bin(canvas: CanvasItem, bin: DustBin, hovered: bool) -> void:
    var rect: Rect2 = DustBin.RECT
    var level: float = bin.fraction()
    var bin_art: Texture2D = ItemArt.tool("dust_bin_body")
    var meter := Rect2(rect.position + Vector2(8, 16), Vector2(rect.size.x - 16, 8))
    if bin_art != null:           # the pixel bin; the fill shows in its clear window
        canvas.draw_texture_rect(bin_art, rect, false)
        meter = Rect2(rect.position + Vector2(12, 22), Vector2(rect.size.x - 24, 8))
    else:
        canvas.draw_rect(rect.grow(2), Color("171d22"))
        canvas.draw_rect(rect, Color("46535e"))
    canvas.draw_rect(meter, Color("0e1317"))
    var tone: Color = UiStyle.TONE_COLORS[2] if level >= DustBin.WARN_AT else COLOR_DUST
    var filled: float = meter.size.x * level
    canvas.draw_rect(Rect2(meter.position, Vector2(filled, meter.size.y)), tone)
    canvas.draw_rect(meter, Color("8aa0ad"), false, 1.0)
    if bin_art == null: canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x, 12)), Color("5d6d7a"))
    UiStyle.label(canvas, rect.position + Vector2(4, 10), "BIN %d%%" % roundi(level * 100.0), 10)
    if bin.is_full():
        UiStyle.label(canvas, rect.position + Vector2(-92, 30), "FULL: Empty bin button", 12, UiStyle.TONE_COLORS[2])
    elif hovered and bin.fill > 0.0:
        UiStyle.label(canvas, rect.position + Vector2(-82, 30), "click to empty", 12)


# 0.57.8: a film of dust (ART-17) on every dusty surface, fading as that surface is cleaned. It follows the
# surface (a lifted part carries its dust) and is skipped where a part covers it.
static func draw_dust_films(canvas: CanvasItem, dust: DustSim) -> void:
    var film: Texture2D = ItemArt.tiled(ItemArt.bench("dust/dust_film_heavy"))
    if film == null: return
    for z in range(mini(dust.zone_count(), dust.zone_center.size())):
        if dust.hidden_zones.has(z) or dust.zone_weight[z] <= 0.00001: continue
        var left: float = 1.0 - dust.removed_fraction(z)
        if left <= 0.02: continue
        var half: Vector2 = dust.zone_half[z]
        canvas.draw_set_transform(dust.zone_center[z], dust.zone_angle[z])
        canvas.draw_texture_rect(film, Rect2(-half, half * 2.0), true, Color(1, 1, 1, 0.85 * left))
    canvas.draw_set_transform(Vector2.ZERO)
