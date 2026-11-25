# Presentation only. Uses the shared geometry; no compatibility or physics here.
extends RefCounted
const Ids = preload("res://scripts/data/ids.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const Rules = preload("res://scripts/rules/placement_rules.gd")
const ItemArt = preload("res://scripts/view/item_art.gd")   # 0.57.7: approved case, board, parts and fan art

static func fan(canvas: CanvasItem, center: Vector2, radius: float, angle: float) -> void:
    canvas.draw_circle(center, radius, Color("17202a"))
    for i in range(7):
        var a: float = angle + i * TAU / 7.0
        var points := PackedVector2Array([center, center + Vector2.from_angle(a) * radius * 0.9, center + Vector2.from_angle(a + 0.5) * radius * 0.8])
        canvas.draw_colored_polygon(points, Color("627e9a"))
    canvas.draw_circle(center, radius * 0.17, Color("98b5bd"))

# 0.57.7: the approved fan (ART-17): the rotor the code spins under its frame. False when the art is missing.
static func fan_art(canvas: CanvasItem, center: Vector2, size: float, angle: float, base: Transform2D = Transform2D.IDENTITY) -> bool:
    var rotor: Texture2D = ItemArt.bench("fan/fan_rotor")
    var frame: Texture2D = ItemArt.bench("fan/fan_frame")
    if rotor == null or frame == null: return false
    canvas.draw_set_transform_matrix(base * Transform2D(angle, center))
    canvas.draw_texture_rect(rotor, Rect2(Vector2.ONE * -size * 0.46, Vector2.ONE * size * 0.92), false)
    canvas.draw_set_transform_matrix(base)
    canvas.draw_texture_rect(frame, Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size), false)
    return true


static func draw_static_pc(canvas: CanvasItem, profile_id: String, area: Rect2) -> void:
    var pc: Dictionary = PCLayout.profile(profile_id)
    var layout: Dictionary = PCLayout.display(pc, area)
    var board: Dictionary = pc["board"]
    var cell: float = layout["cell"]
    var bounds: Rect2 = layout["case_rect"]
    # 0.57.7: the PC lies open on its side (user, 25 November 2026): the approved case and board pictures.
    var case_art: Texture2D = ItemArt.case_interior(profile_id)
    var board_art: Texture2D = ItemArt.board_picture(str(board.get("id", "")))
    if case_art != null and board_art != null:
        canvas.draw_texture_rect(case_art, bounds, false)
        canvas.draw_texture_rect(board_art, PCLayout.board_rect(pc, layout), false)
        return
    canvas.draw_rect(bounds.grow(5), Color("647479"))
    canvas.draw_rect(bounds, Color("18252c"))
    for y in range(pc["size"].y):
        for x in range(pc["size"].x):
            canvas.draw_rect(PCLayout.cell_rect(Rect2(x, y, 1, 1), layout), Color(0.4, 0.6, 0.7, 0.12), false)
    var board_start: Vector2 = PCLayout.board_rect(pc, layout).position
    for y in range(board["size"].y):
        for x in range(board["size"].x):
            var rect := Rect2(board_start + Vector2(x, y) * cell, Vector2.ONE * cell)
            if Rules.is_cell_on_board(board, Vector2i(x, y)):
                canvas.draw_rect(rect, Color("285942"))
                canvas.draw_rect(rect, Color("4c8061"), false)
    var font: Font = ThemeDB.fallback_font
    canvas.draw_string(font, bounds.position + Vector2(5, 16), pc["name"] + " / " + str(pc["size"]) + " cells", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

static func draw_pc(canvas: CanvasItem, profile_id: String, area: Rect2, zones: Array, case_angle: float, cooler_angle: float, part_rects: Dictionary = {}, poses: Dictionary = {}, with_static: bool = true) -> void:
    if with_static: draw_static_pc(canvas,profile_id,area)
    var pc: Dictionary = PCLayout.profile(profile_id)
    var cell: float = PCLayout.display(pc,area)["cell"]
    var font: Font = ThemeDB.fallback_font
    for z: Dictionary in zones:
        if z.has("covered_by") or z["id"] == "case_interior": continue
        var r: Rect2 = z["rect"]
        r.position += area.position
        var id: String = z["id"]
        if part_rects.has(id): r = part_rects[id]
        var base := Transform2D.IDENTITY
        if poses.has(id):
            canvas.draw_set_transform(poses[id]["shadow"],poses[id]["angle"])
            canvas.draw_rect(Rect2(-r.size*0.5,r.size),Color(0,0,0,0.30))
            canvas.draw_set_transform(poses[id]["center"],poses[id]["angle"])
            base = Transform2D(float(poses[id]["angle"]), Vector2(poses[id]["center"]))
            r = Rect2(-r.size*0.5,r.size)
        if _draw_zone_art(canvas, id, r, base, cooler_angle if id == Ids.COOLER else case_angle):
            canvas.draw_set_transform(Vector2.ZERO)
            continue
        var col: Color = Color("405267")
        if id == "psu": col = Color("75643b")
        if id == "motherboard": col = Color("7c974c")
        canvas.draw_rect(r.grow(-2), col)
        canvas.draw_rect(r, Color("a4b6a2"), false, 1.0)
        if id in [Ids.COOLER, "case_fan", Ids.GPU]:
            fan(canvas, r.get_center(), minf(r.size.x, r.size.y) * 0.42, cooler_angle if id == Ids.COOLER else case_angle)
        if id == "motherboard":
            for k in range(2):
                canvas.draw_rect(Rect2(r.position + Vector2(4 + k * cell, 4), Vector2(cell - 8, r.size.y - 8)), Color("b4d96e"))
        if id == "front_filter":
            for k in range(int(r.size.y / 8)):
                canvas.draw_line(r.position + Vector2(0, k * 8), r.position + Vector2(r.size.x, k * 8), Color("7f9296"))
        # Compact labels stay inside component bounds; progress is listed in the right panel.
        canvas.draw_string(font, r.position + Vector2(3, 13), str(z["label"]), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 4, 11, Color.WHITE)
        canvas.draw_set_transform(Vector2.ZERO)


# 0.57.7: a bench zone drawn with its approved picture (the same drawings as the storage and the hardware
# board). Returns false when there is no picture for it, and the old box is drawn instead.
static func _draw_zone_art(canvas: CanvasItem, id: String, r: Rect2, base: Transform2D, angle: float) -> bool:
    match id:
        "case_fan":
            var side: float = minf(r.size.x, r.size.y)
            return fan_art(canvas, r.get_center(), side, angle, base)
        Ids.COOLER:
            var cpu: Texture2D = ItemArt.board("cpu", 0)
            var cooler: Texture2D = ItemArt.board("cooler", 0)
            if cooler == null: return false
            var side: float = minf(r.size.x, r.size.y)
            var square := Rect2(r.get_center() - Vector2.ONE * side * 0.5, Vector2.ONE * side)
            if cpu != null: canvas.draw_texture_rect(cpu, square, false)
            canvas.draw_texture_rect(cooler, square.grow(-side * 0.06), false)
            var rotor: Texture2D = ItemArt.bench("fan/fan_rotor")
            if rotor != null:
                canvas.draw_set_transform_matrix(base * Transform2D(angle, square.get_center()))
                canvas.draw_texture_rect(rotor, Rect2(Vector2.ONE * -side * 0.36, Vector2.ONE * side * 0.72), false)
                canvas.draw_set_transform_matrix(base)
            return true
        Ids.GPU:
            var gpu: Texture2D = ItemArt.board("gpu", 0)
            if gpu == null: return false
            canvas.draw_texture_rect(gpu, r, false)
            return true
        "motherboard":            # the RAM zone: two sticks side by side
            var ram: Texture2D = ItemArt.board("ram", 0)
            if ram == null: return false
            var w: float = r.size.x * 0.5
            for k in range(2): canvas.draw_texture_rect(ram, Rect2(r.position + Vector2(k * w, 0), Vector2(w, r.size.y)), false)
            return true
        "psu":                    # in its bay under the shroud: the fan side shows at the rear end
            var psu: Texture2D = ItemArt.board("psu", 0)
            if psu == null: return false
            canvas.draw_texture_rect(psu, Rect2(r.position, Vector2(minf(r.size.x, r.size.y * 1.5), r.size.y)), false)
            return true
    return false
