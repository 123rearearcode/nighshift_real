# Logical sandbox inventory and installation. No drawing, input or save IO.
extends RefCounted
const Data = preload("res://scripts/data/component_data.gd")
const Rules = preload("res://scripts/rules/placement_rules.gd")
const SIZE := Vector2i(12, 8)
var items: Array = []
var board: Dictionary = {}
var case_depth: int = 0
var held: int = -1
var before: Dictionary = {}

func setup(new_board: Dictionary, depth: int, saved: Dictionary = {}, stock: Variant = null) -> void:
    board = new_board
    case_depth = depth
    held = -1
    items = []
    for part: Dictionary in (Data.drawer_stock() if stock == null else stock):
        items.append({"part":part, "location":"drawer", "cell":Vector2i(-100,-100), "rotation":0})
    for i in range(items.size()):
        var item: Dictionary = items[i]
        var raw: Variant = saved.get(item["part"]["id"], {})
        var restored: bool = false
        if raw is Dictionary:
            var rot_value: Variant = raw.get("rotation", 0)
            item["rotation"] = posmod(int(rot_value), 4) if typeof(rot_value) in [TYPE_INT, TYPE_FLOAT] else 0
            var location: String = str(raw.get("location", "drawer"))
            if location == "drawer":
                var xy: Variant = raw.get("cell", [])
                if xy is Array and xy.size() == 2 and typeof(xy[0]) in [TYPE_INT, TYPE_FLOAT] and typeof(xy[1]) in [TYPE_INT, TYPE_FLOAT]:
                    var candidate := Vector2i(int(xy[0]), int(xy[1]))
                    if can_store(i, candidate):
                        item["cell"] = candidate
                        restored = true
            else:
                for connector: Dictionary in board["connectors"]:
                    if connector["id"] == location:
                        var result: Dictionary = Rules.check_placement(board, item["part"], item["rotation"], connector["origin"], occupied(i), case_depth)
                        if result["ok"]:
                            item["location"] = location
                            restored = true
        if not restored:
            item["location"] = "drawer"
            item["rotation"] = 0
            item["cell"] = first_space(i)

func footprint(i: int) -> Vector2i:
    return Rules.rotated_footprint(items[i]["part"]["footprint"], items[i]["rotation"])

func occupied(exclude: int = -1) -> Dictionary:
    var result: Dictionary = {}
    for i in range(items.size()):
        var location: String = items[i]["location"]
        if i != held and i != exclude and location != "drawer": result[location] = items[i]["part"]["id"]
    return result

func can_store(i: int, cell: Vector2i) -> bool:
    var fp: Vector2i = footprint(i)
    if cell.x < 0 or cell.y < 0 or cell.x + fp.x > SIZE.x or cell.y + fp.y > SIZE.y: return false
    var rect := Rect2i(cell, fp)
    for other in range(items.size()):
        if other == i or other == held or items[other]["location"] != "drawer": continue
        if rect.intersects(Rect2i(items[other]["cell"], footprint(other))): return false
    return true

func first_space(i: int) -> Vector2i:
    for y in range(SIZE.y):
        for x in range(SIZE.x):
            if can_store(i, Vector2i(x,y)): return Vector2i(x,y)
    return Vector2i(-100,-100) # stock is fixed and guaranteed to fit; never a gameplay deletion

func begin(i: int) -> void:
    if held != -1 or i < 0 or i >= items.size(): return
    before = items[i].duplicate(true)
    held = i

func rotate(step: int) -> void:
    if held >= 0: items[held]["rotation"] = posmod(int(items[held]["rotation"]) + step, 4)

func store(cell: Vector2i) -> bool:
    if held < 0 or not can_store(held, cell): return false
    items[held]["location"] = "drawer"
    items[held]["cell"] = cell
    held = -1
    before = {}
    return true

func install(cell: Vector2i) -> Dictionary:
    if held < 0: return {"ok":false, "message":"Pick up a part first.", "connector_id":""}
    var item: Dictionary = items[held]
    var result: Dictionary = Rules.check_placement(board, item["part"], item["rotation"], cell, occupied(), case_depth)
    if result["ok"]:
        item["location"] = result["connector_id"]
        held = -1
        before = {}
    return result

func cancel() -> void:
    if held >= 0: items[held] = before.duplicate(true)
    held = -1
    before = {}

func snapshot() -> Dictionary:
    var result: Dictionary = {}
    for i in range(items.size()):
        var item: Dictionary = before if i == held else items[i]
        var cell: Vector2i = item["cell"] if item["location"] == "drawer" else Vector2i.ZERO
        result[item["part"]["id"]] = {"location":item["location"], "cell":[cell.x,cell.y], "rotation":item["rotation"]}
    return result
