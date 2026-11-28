# Pure furniture/placement rules. Sources own items; this model owns only shelf allocations.
extends RefCounted
const Data = preload("res://scripts/storage/storage_data.gd")
const Backpack = preload("res://scripts/rules/backpack.gd")   # 0.58.4: the player's backpack is one more unit
const Laptop = preload("res://scripts/rules/laptop.gd")       # 0.59.1 (D185): laptops stack
var items: Dictionary = {}
var units: Array = []
var fixed_units: Array = [{"id":Data.COUNTER_ID,"model":Data.COUNTER_ID,"room_cell":Vector2i(-1,-1)},   # 0.55.0: not in the room
    {"id":Backpack.ID,"model":Backpack.ID,"room_cell":Vector2i(-1,-1)},                            # 0.58.4: carried, never auto-filled
    {"id":Data.TOP_ID,"model":Data.TOP_ID,"room_cell":Vector2i(-1,-1)},                            # 0.59.2: handed over, on the counter
    {"id":Data.ARMS_ID,"model":Data.ARMS_ID,"room_cell":Vector2i(-1,-1)}]                          # 0.59.2: one thing in your arms
const FIXED_IDS: Array = [Data.COUNTER_ID, Backpack.ID, Data.TOP_ID, Data.ARMS_ID]
var backpack_size: Vector2i = Backpack.LEVELS[0]["size"]
var placements: Dictionary = {}
var next_unit: int = 1
var held: String = ""
var held_rotation: int = 0

func setup(sources: Dictionary, saved: Dictionary = {}, backpack: Vector2i = Vector2i(-1,-1)) -> void:
    # 0.58.4: the backpack's size is the best one owned (asked of GameState unless given), set BEFORE the saved
    # placements are restored so nothing carried falls out.
    if backpack.x > 0 and backpack.y > 0: backpack_size = backpack
    elif Engine.get_main_loop() is SceneTree and (Engine.get_main_loop() as SceneTree).root.has_node("GameState"):
        backpack_size = Backpack.size_for((Engine.get_main_loop() as SceneTree).root.get_node("GameState").upgrades)
    items = sources.duplicate(true)
    units.clear()
    placements.clear()
    held = ""
    next_unit = 1
    var raw_units: Variant = saved.get("units",[])
    var seen: Dictionary = {}
    if raw_units is Array:
        for raw: Variant in raw_units:
            if not raw is Dictionary or units.size() >= Data.MAX_UNITS: continue
            var uid: String = str(raw.get("id",""))
            var kind: String = str(raw.get("model",""))
            if uid == "" or uid.length()>80 or seen.has(uid) or uid in FIXED_IDS or not Data.MODELS.has(kind): continue
            units.append({"id":uid,"model":kind,"room_cell":Vector2i(-1,-1)})
            var rc: Variant = raw.get("room_cell",null)
            if rc is Array and rc.size() == 2 and _integer(rc[0]) and _integer(rc[1]):
                var cell := Vector2i(int(rc[0]),int(rc[1]))
                if can_place_furniture(uid,cell): units.back()["room_cell"] = cell
            seen[uid] = true
    for entry: Dictionary in units:
        if entry["room_cell"] == Vector2i(-1,-1): entry["room_cell"] = free_room_cell()
    if units.is_empty(): add_unit("rack")
    var raw_places: Variant = saved.get("placements",{})
    if raw_places is Dictionary:
        var order: Array = items.keys()   # 0.59.1: what lies under a laptop goes back first
        order.sort_custom(func(a: String, b: String) -> bool: return _saved_level(raw_places, a) < _saved_level(raw_places, b) if _saved_level(raw_places, a) != _saved_level(raw_places, b) else a < b)
        for uid: String in order:
            var raw: Variant = raw_places.get(uid,{})
            if not raw is Dictionary: continue
            var xy: Variant = raw.get("cell",null)
            if not xy is Array or xy.size()!=2 or not _integer(xy[0]) or not _integer(xy[1]): continue
            if not _integer(raw.get("shelf",null)) or not _integer(raw.get("rotation",null)): continue
            place(uid,str(raw.get("unit","")),int(raw["shelf"]),Vector2i(int(xy[0]),int(xy[1])),int(raw["rotation"]))
    fill_unplaced()

static func _saved_level(raw_places: Dictionary, uid: String) -> int:
    var raw: Variant = raw_places.get(uid, {})
    return clampi(int(raw.get("level", 0)), 0, Laptop.STACK_MAX - 1) if raw is Dictionary and _integer(raw.get("level", 0)) else 0


static func _integer(value: Variant) -> bool:
    return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(value)) and absf(float(value))<=2147483647 and float(value) == floorf(float(value))

func unit(id: String) -> Dictionary:
    for entry: Dictionary in units + fixed_units:
        if entry["id"] == id: return entry
    return {}

func add_unit(kind: String, cell: Vector2i = Vector2i(-1,-1)) -> String:
    if not Data.MODELS.has(kind) or units.size() >= Data.MAX_UNITS: return ""
    if cell == Vector2i(-1,-1): cell = free_room_cell()
    if not can_place_furniture("",cell): return ""
    var id: String = "storage_%d"%next_unit
    while not unit(id).is_empty():
        next_unit += 1
        id = "storage_%d"%next_unit
    units.append({"id":id,"model":kind,"room_cell":cell})
    next_unit += 1
    return id

func can_place_furniture(id: String, cell: Vector2i) -> bool:
    if not Rect2i(Vector2i.ZERO,Data.ROOM_SIZE).has_point(cell): return false
    for entry: Dictionary in units:
        if entry["id"] != id and entry.get("room_cell",Vector2i(-1,-1)) == cell: return false
    return true

func free_room_cell() -> Vector2i:
    for y in range(Data.ROOM_SIZE.y):
        for x in range(Data.ROOM_SIZE.x):
            var cell := Vector2i(x,y)
            if can_place_furniture("",cell): return cell
    return Vector2i(-1,-1)

func move_unit(id: String, cell: Vector2i) -> bool:
    if held != "" or unit(id).is_empty() or not can_place_furniture(id,cell): return false
    unit(id)["room_cell"] = cell
    return true

func remove_unit(id: String) -> bool:
    if units.size() <= 1 or held != "": return false
    for p: Dictionary in placements.values():
        if p["unit"] == id: return false
    for i in range(units.size()):
        if units[i]["id"] == id:
            units.remove_at(i)
            return true
    return false

# A unit's shape: the backpack's depends on the one owned (0.58.4).
func spec_of(model_id: String) -> Dictionary:
    return Backpack.spec(backpack_size) if model_id == Backpack.ID else Data.spec(model_id)

func can_place(uid: String, unit_id: String, shelf: int, cell: Vector2i, rotation: int, stack_ok: bool = true) -> bool:
    return not _spot(uid, unit_id, shelf, cell, rotation, stack_ok).is_empty()

# 0.59.1 (D185): where an item would rest: {"on": uid it rests on ("" = the shelf itself), "level": 0 = on the
# shelf}, or {} when it cannot go there. Only a laptop (items[uid].stackable) may rest on something: on a
# desktop or another laptop, wholly on top of it (its footprint inside the other's), on the top of that pile
# (nothing else on it), with the pile at most Laptop.STACK_MAX high. Anything else needs free shelf cells.
func _spot(uid: String, unit_id: String, shelf: int, cell: Vector2i, rotation: int, stack_ok: bool = true) -> Dictionary:
    if not items.has(uid): return {}
    var furniture: Dictionary = unit(unit_id)
    if furniture.is_empty(): return {}
    var spec: Dictionary = spec_of(str(furniture["model"]))
    if not items[uid]["category"] in spec["accepts"] or shelf<0 or shelf>=int(spec["shelves"]): return {}
    if items[uid]["category"] == "pc" and bool(spec.get("pc_if_stackable", false)) and not bool(items[uid].get("stackable", false)): return {}   # 0.59.2: a laptop fits a backpack, a desktop does not
    if spec.has("max_items") and in_unit(unit_id).filter(func(other: String) -> bool: return other != uid).size() >= int(spec["max_items"]): return {}   # 0.59.2: one thing in your arms
    var area := Rect2i(cell,Data.footprint(items[uid],rotation))
    if not Rect2i(Vector2i.ZERO,spec["size"]).encloses(area): return {}
    var touched: Array = []
    for other: String in placements:
        if other == uid or _rests_on(other, uid): continue
        var p: Dictionary = placements[other]
        if p["unit"] == unit_id and p["shelf"] == shelf and area.intersects(Rect2i(p["cell"],Data.footprint(items[other],p["rotation"]))): touched.append(other)
    if touched.is_empty(): return {"on": "", "level": 0}
    if not stack_ok or not bool(items[uid].get("stackable", false)): return {}
    var top: String = ""
    for other: String in touched:
        if top == "" or level(other) > level(top): top = other
    if items[top]["category"] != "pc" or not on_top_of(top).is_empty() or level(top) + 1 >= Laptop.STACK_MAX: return {}
    var under: Dictionary = placements[top]
    if not Rect2i(under["cell"],Data.footprint(items[top],under["rotation"])).encloses(area): return {}
    for other: String in touched:   # everything it touches must be that pile, below the top
        if other != top and not _rests_on(top, other): return {}
    return {"on": top, "level": level(top) + 1}

func place(uid: String, unit_id: String, shelf: int, cell: Vector2i, rotation: int, stack_ok: bool = true) -> bool:
    var spot: Dictionary = _spot(uid, unit_id, shelf, cell, rotation, stack_ok)
    if spot.is_empty(): return false
    placements[uid] = {"unit":unit_id,"shelf":shelf,"cell":cell,"rotation":posmod(rotation,4)}
    if str(spot["on"]) != "": placements[uid]["on"] = str(spot["on"])   # only a piled laptop carries "on"
    return true

# 0.59.1: how high an item rests (0 = on the shelf), what rests directly on it, and whether `a` rests
# (directly or through others) on `b`.
func level(uid: String) -> int:
    var n: int = 0
    var at: String = str(placements.get(uid, {}).get("on", ""))
    while at != "" and n < Laptop.STACK_MAX:
        n += 1
        at = str(placements.get(at, {}).get("on", ""))
    return n

# 0.59.2: how many things rest on `uid`, directly or through others (a pile's weight on it).
func above_count(uid: String) -> int:
    return placements.keys().filter(func(other: String) -> bool: return _rests_on(other, uid)).size()

func on_top_of(uid: String) -> Array:
    return placements.keys().filter(func(other: String) -> bool: return str(placements[other].get("on", "")) == uid)

func _rests_on(a: String, b: String) -> bool:
    var at: String = str(placements.get(a, {}).get("on", ""))
    var guard: int = 0
    while at != "" and guard < Laptop.STACK_MAX:
        if at == b: return true
        at = str(placements.get(at, {}).get("on", ""))
        guard += 1
    return false

# Why an item cannot be picked up now ("" = it can): something rests on it.
func blocked(uid: String) -> String:
    return "" if on_top_of(uid).is_empty() else "Lift the laptop on top off first."

func begin(uid: String) -> bool:
    if held != "" or not items.has(uid) or blocked(uid) != "": return false
    held = uid
    held_rotation = int(placements.get(uid,{}).get("rotation",0))
    return true

func rotate(step: int) -> void:
    if held != "": held_rotation = posmod(held_rotation+step,4)

func drop(unit_id: String, shelf: int, cell: Vector2i) -> bool:
    if held == "" or not place(held,unit_id,shelf,cell,held_rotation): return false
    cancel()
    return true

func cancel() -> void:
    held = "" # committed placement was never edited while in the hand

func overflow() -> Array:
    var result: Array = []
    for uid: String in items:
        if not placements.has(uid): result.append(uid)
    return result

func fill_unplaced() -> void:
    var ids: Array = overflow()
    ids.sort_custom(func(a: String,b: String) -> bool:
        var aa: Vector2i = items[a]["size"]
        var bb: Vector2i = items[b]["size"]
        return aa.x*aa.y>bb.x*bb.y if aa.x*aa.y != bb.x*bb.y else a<b)
    for uid: String in ids:
        var stored: bool = false
        if bool(items[uid].get("at_counter", false)) and place_first(uid, Data.TOP_ID): continue   # 0.59.2: handed over, it waits on the counter
        for stack_ok: bool in [false, true]:   # 0.59.1: free shelf space first; a laptop then goes on a pile
            for furniture: Dictionary in units:
                var spec: Dictionary = Data.MODELS[furniture["model"]]
                for shelf in range(spec["shelves"]):
                    for rotation in [0,1]:
                        for y in range(spec["size"].y):
                            for x in range(spec["size"].x):
                                if place(uid,furniture["id"],shelf,Vector2i(x,y),rotation,stack_ok):
                                    stored = true
                                    break
                            if stored: break
                        if stored: break
                    if stored: break
                if stored: break
            if stored: break

func arrange() -> void:
    cancel()
    for uid: String in placements.keys():   # 0.55.0: what you keep under the counter stays there (0.58.4: and in your backpack)
        if not placements[uid]["unit"] in FIXED_IDS: placements.erase(uid)   # 0.59.2: and on the counter, and in your arms
    fill_unplaced()

# 0.55.0: the first free spot in one unit (either rotation). False when it does not fit.
func place_first(uid: String, unit_id: String) -> bool:
    var furniture: Dictionary = unit(unit_id)
    if furniture.is_empty() or not items.has(uid): return false
    var spec: Dictionary = spec_of(str(furniture["model"]))
    for stack_ok: bool in [false, true]:   # 0.59.1: free space first, then on top of a pile
        for shelf in range(int(spec["shelves"])):
            for rotation in [0,1]:
                for y in range(spec["size"].y):
                    for x in range(spec["size"].x):
                        if place(uid,unit_id,shelf,Vector2i(x,y),rotation,stack_ok): return true
    return false

# 0.55.0: back to the stock room: off the counter, onto the first free room shelf (or "waiting for space").
func to_room(uid: String) -> bool:
    if held != "" or not placements.has(uid) or blocked(uid) != "": return false
    placements.erase(uid)
    fill_unplaced()
    return true

func in_unit(unit_id: String) -> Array:
    return placements.keys().filter(func(uid: String) -> bool: return placements[uid]["unit"] == unit_id)

func snapshot() -> Dictionary:
    var result: Dictionary = {}
    for uid: String in placements:
        var p: Dictionary = placements[uid]
        result[uid] = {"unit":p["unit"],"shelf":p["shelf"],"cell":[p["cell"].x,p["cell"].y],"rotation":p["rotation"]}
        if level(uid) > 0: result[uid]["level"] = level(uid)   # 0.59.1: piles restore bottom first
    var room_units: Array = []
    for entry: Dictionary in units:
        var cell: Vector2i = entry["room_cell"]
        room_units.append({"id":entry["id"],"model":entry["model"],"room_cell":[cell.x,cell.y]})
    return {"version":2,"units":room_units,"placements":result}
