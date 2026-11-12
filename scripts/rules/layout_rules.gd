# Pure case/board containment checks; no input, drawing or state.
extends RefCounted
const Rules = preload("res://scripts/rules/placement_rules.gd")

static func validate(profile_data: Dictionary) -> Array:
    var errors: Array = Rules.validate_board(profile_data["board"])
    var size: Vector2i = profile_data["size"]
    var origin: Vector2i = profile_data["board_origin"]
    var board: Dictionary = profile_data["board"]
    if origin.x < 0 or origin.y < 0 or origin.x + board["size"].x > size.x or origin.y + board["size"].y > size.y:
        errors.append("Motherboard exceeds case cells.")
    for key: String in ["fan", "psu", "filter"]:
        var r: Rect2 = profile_data[key]
        if not Rect2(Vector2.ZERO, Vector2(size)).encloses(r):
            errors.append(key + " exceeds case cells.")
        for y in range(origin.y, origin.y + board["size"].y):
            for x in range(origin.x, origin.x + board["size"].x):
                if Rules.is_cell_on_board(board, Vector2i(x, y) - origin) and r.has_point(Vector2(x, y)):
                    errors.append(key + " overlaps motherboard.")
    return errors
