# Shared case/board geometry, in logical cells. Rendering never changes compatibility.
extends RefCounted
const ComponentData = preload("res://scripts/data/component_data.gd")

static func profile(id: String = "tower") -> Dictionary:
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

static func display(profile_data: Dictionary, area: Rect2) -> Dictionary:
    var size: Vector2i = profile_data["size"]
    var cell: float = minf(area.size.x / size.x, area.size.y / size.y)
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

