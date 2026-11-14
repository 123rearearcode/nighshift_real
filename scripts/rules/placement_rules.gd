# RULES ONLY: decides whether a placement is allowed and explains why.
# No drawing and no mouse handling here. Takes data in, returns a result out.
# Result keys: ok (bool), connector_id (String, "" if none), label (String), message (String)
extends RefCounted


const DIRECTION_NAMES := ["Up", "Right", "Down", "Left"]


static func direction_name(rot: int) -> String:
    return DIRECTION_NAMES[posmod(rot, 4)]


# Facings a connector accepts (0 = Up, 1 = Right, 2 = Down, 3 = Left). Default: all four.
static func allowed_rotations(connector: Dictionary) -> Array:
    return connector.get("allowed_rotations", [0, 1, 2, 3])


static func facing_text(connector: Dictionary) -> String:
    var names := PackedStringArray()
    for r: int in allowed_rotations(connector):
        names.append(direction_name(r))
    return " / ".join(names)


static func in_grid_bounds(board: Dictionary, cell: Vector2i) -> bool:
    var size: Vector2i = board["size"]
    return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


static func is_cell_on_board(board: Dictionary, cell: Vector2i) -> bool:
    if not in_grid_bounds(board, cell):
        return false
    var rows: Array = board["rows"]
    var row: String = rows[cell.y]
    return row.substr(cell.x, 1) == "#"


static func connector_at(board: Dictionary, cell: Vector2i) -> Dictionary:
    var connectors: Array = board["connectors"]
    for connector: Dictionary in connectors:
        var origin: Vector2i = connector["origin"]
        var fp: Vector2i = connector["footprint"]
        if cell.x >= origin.x and cell.x < origin.x + fp.x \
                and cell.y >= origin.y and cell.y < origin.y + fp.y:
            return connector
    return {}


# Footprint for a facing: 0 = Up, 1 = Right, 2 = Down, 3 = Left.
# Odd facings (sideways) swap width and height.
static func rotated_footprint(footprint: Vector2i, rot: int) -> Vector2i:
    if posmod(rot, 2) == 1:
        return Vector2i(footprint.y, footprint.x)
    return footprint


# occupied maps connector id -> component id for parts already installed.
# rot = the part's facing: 0 = Up, 1 = Right, 2 = Down, 3 = Left.
static func check_placement(board: Dictionary, component: Dictionary, rot: int, cell: Vector2i, occupied: Dictionary, case_depth: int = -1) -> Dictionary:
    if case_depth >= 0 and int(component.get("height", 0)) > case_depth:
        return _result(false, "", "", "Part is too tall for this case.")
    if not validate_board(board).is_empty():
        return _result(false, "", "", "Invalid motherboard layout.")
    if not in_grid_bounds(board, cell):
        return _result(false, "", "", "That spot is not on the motherboard. Drop the part onto a slot.")
    if not is_cell_on_board(board, cell):
        return _result(false, "", "", "That area is a board cutout. Nothing can be mounted there.")

    var connector: Dictionary = connector_at(board, cell)
    if connector.is_empty():
        return _result(false, "", "", "There is no connector here. Parts must sit on a labelled slot.")

    var cid: String = connector["id"]
    var label: String = connector["label"]
    if connector.has("requires") and not occupied.has(str(connector["requires"])):
        return _result(false, "", "", "%s needs the %s filled first - fit that part, then this one." % [connector["label"], str(connector["requires"])])
    var slot_type: String = connector["type"]
    var part_type: String = component["connector_type"]
    if slot_type != part_type:
        return _result(false, cid, label,
            "Wrong connector type: %s is a %s slot, but %s needs %s." % [label, slot_type, component["display_name"], part_type])

    var slot_fp: Vector2i = connector["footprint"]
    var part_fp: Vector2i = rotated_footprint(component["footprint"], rot)
    if slot_fp != part_fp:
        if slot_fp == Vector2i(part_fp.y, part_fp.x):
            return _result(false, cid, label,
                "Wrong orientation: the part is %d x %d but %s is %d x %d. Press R to rotate (Shift+R turns the other way)." % [part_fp.x, part_fp.y, label, slot_fp.x, slot_fp.y])
        return _result(false, cid, label, "The part's size does not match %s." % label)

    if not allowed_rotations(connector).has(posmod(rot, 4)):
        return _result(false, cid, label,
            "Wrong facing: %s needs the part facing %s, but it faces %s. Press R to rotate (Shift+R turns the other way)." % [label, facing_text(connector), direction_name(rot)])

    if occupied.has(cid):
        return _result(false, cid, label, "%s is already occupied. Remove the part there first." % label)

    return _result(true, cid, label, "Compatible.")


# Sanity-checks the board data itself. Returns a list of problem strings (empty = fine).
static func validate_board(board: Dictionary) -> Array:
    var problems: Array = []
    var size: Vector2i = board["size"]
    var rows: Array = board["rows"]
    if rows.size() != size.y:
        problems.append("Board has %d rows but size says %d." % [rows.size(), size.y])
    for row: String in rows:
        if row.length() != size.x:
            problems.append("A board row has length %d, expected %d." % [row.length(), size.x])
    if not problems.is_empty():
        return problems
    var seen: Dictionary = {}
    var connectors: Array = board["connectors"]
    for connector: Dictionary in connectors:
        var origin: Vector2i = connector["origin"]
        var fp: Vector2i = connector["footprint"]
        for y in range(origin.y, origin.y + fp.y):
            for x in range(origin.x, origin.x + fp.x):
                var c := Vector2i(x, y)
                if not is_cell_on_board(board, c):
                    problems.append("Connector %s covers off-board cell %s." % [connector["id"], str(c)])
                if seen.has(c):
                    problems.append("Connectors overlap at cell %s." % str(c))
                seen[c] = true
    return problems


static func _result(ok: bool, connector_id: String, label: String, message: String) -> Dictionary:
    return {"ok": ok, "connector_id": connector_id, "label": label, "message": message}
