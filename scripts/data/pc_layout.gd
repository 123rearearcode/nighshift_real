# Shared case/board geometry, in logical cells. Rendering never changes compatibility.
extends RefCounted
const ComponentData = preload("res://scripts/data/component_data.gd")

static func profile(id: String = "tower") -> Dictionary:
    if id == "laptop": return laptop()
    var compact: bool = id == "compact"
    var board: Dictionary = ComponentData.demo_board()
    if compact:
        board = board.duplicate(true)
        board["id"] = "board_compact_step"
        board["display_name"] = "Compact stepped board"
        board["size"] = Vector2i(9, 9)
        board["rows"] = ["######...", "######...", "######...", "######...", "#########", "#########", "#########", "#########", "########."]
    return {"id": id, "name": "Compact case" if compact else "Tower case",
        "size": Vector2i(15, 14) if compact else Vector2i(18, 16),
        "depth": 5 if compact else 8, "board_origin": Vector2i(3, 2), "board": board,
        "fan": Rect2(0, 3, 2, 3), "psu": Rect2(1, 12, 8, 2),
        "filter": Rect2(13, 1, 1, 10) if compact else Rect2(16, 1, 1, 13)}

# 0.59.1 (D185): a laptop, seen from below with its bottom cover off. 0.59.2 (user: "The laptop is way too
# big ... it needs a lot more work to show the space constraints and components of a laptop"): 14 x 9 cells and
# drawn at a tower's cell size (display()), so it is visibly smaller and tightly packed. Its motherboard is part
# of the chassis and has only what a laptop lets you change: two lying RAM slots and one drive slot. The
# processor and graphics are soldered under the heatsink ("cpu" marks where the heatsink sits; nothing is fitted
# or taken out there). "fan" is the blower fan, "filter" the exhaust fins beside it, "psu" the battery (drawn
# only; not a dust spot). The Wi-Fi card, speakers, ribbons and jacks are in the picture only.
# Art: tools/art_batch_f/laptop.py.
static func laptop() -> Dictionary:
    var board: Dictionary = {"id": "board_laptop", "display_name": "Laptop board", "size": Vector2i(9, 4),
        "rows": ["#########", "#########", "#########", "#########"],
        "connectors": [
            {"id": "ram_1", "label": "RAM slot 1", "short_label": "R1", "type": "DDR4_DIMM",
                "origin": Vector2i(5, 0), "footprint": Vector2i(4, 1), "allowed_rotations": [1]},
            {"id": "ram_2", "label": "RAM slot 2", "short_label": "R2", "type": "DDR4_DIMM",
                "origin": Vector2i(5, 1), "footprint": Vector2i(4, 1), "allowed_rotations": [1]},
            {"id": "m2_1", "label": "Drive slot", "short_label": "D1", "type": "STORAGE_SLOT",
                "origin": Vector2i(5, 3), "footprint": Vector2i(2, 1)},
            {"id": "cpu", "label": "Soldered processor and graphics (under the heatsink)", "short_label": "CPU", "type": "SOLDERED",
                "origin": Vector2i(1, 0), "footprint": Vector2i(3, 3)}]}
    return {"id": "laptop", "name": "Laptop", "size": Vector2i(14, 9), "depth": 2, "board_origin": Vector2i(4, 1),
        "board": board, "fan": Rect2(1, 1, 3, 3), "psu": Rect2(1, 6, 12, 2), "filter": Rect2(0, 1, 1, 3)}

static func display(profile_data: Dictionary, area: Rect2) -> Dictionary:
    var size: Vector2i = profile_data["size"]
    var cell: float = minf(area.size.x / size.x, area.size.y / size.y)
    if str(profile_data.get("id", "")) == "laptop":   # 0.59.2: at a tower's scale, so a laptop looks as small as it is
        var tower: Vector2i = profile("tower")["size"]
        cell = minf(area.size.x / tower.x, area.size.y / tower.y)
    var origin: Vector2 = area.position + (area.size - Vector2(size) * cell) * 0.5
    return {"cell": cell, "origin": origin, "case_rect": Rect2(origin, Vector2(size) * cell)}

static func cell_rect(rect: Rect2, layout: Dictionary) -> Rect2:
    return Rect2(layout["origin"] + rect.position * float(layout["cell"]), rect.size * float(layout["cell"]))

static func board_rect(profile_data: Dictionary, layout: Dictionary) -> Rect2:
    return cell_rect(Rect2(Vector2(profile_data["board_origin"]), Vector2(profile_data["board"]["size"])), layout)

static func connector_rect(profile_data: Dictionary, layout: Dictionary, id: String) -> Rect2:
    for c: Dictionary in profile_data["board"]["connectors"]:
        if c["id"] == id:
            var origin: Vector2i = profile_data["board_origin"] + c["origin"]
            return cell_rect(Rect2(Vector2(origin), Vector2(c["footprint"])), layout)
    return Rect2()

