# Pure furniture/placement rules. Sources own items; this model owns only shelf allocations.
extends RefCounted
const Data = preload("res://scripts/storage/storage_data.gd")
var items: Dictionary = {}
var units: Array = []
var placements: Dictionary = {}
var next_unit: int = 1
var held: String = ""
var held_rotation: int = 0

func setup(sources: Dictionary, saved: Dictionary = {}) -> void:
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
            if uid == "" or uid.length()>80 or seen.has(uid) or not Data.MODELS.has(kind): continue
            units.append({"id":uid,"model":kind})
            seen[uid] = true
    if units.is_empty(): add_unit("rack")
    var raw_places: Variant = saved.get("placements",{})
    if raw_places is Dictionary:
        for uid: String in items:
            var raw: Variant = raw_places.get(uid,{})
            if not raw is Dictionary: continue
            var xy: Variant = raw.get("cell",null)
            if not xy is Array or xy.size()!=2 or not _integer(xy[0]) or not _integer(xy[1]): continue
            if not _integer(raw.get("shelf",null)) or not _integer(raw.get("rotation",null)): continue
            place(uid,str(raw.get("unit","")),int(raw["shelf"]),Vector2i(int(xy[0]),int(xy[1])),int(raw["rotation"]))
    fill_unplaced()

static func _integer(value: Variant) -> bool:
    return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(value)) and float(value) == floorf(float(value))

func unit(id: String) -> Dictionary:
    for entry: Dictionary in units:
        if entry["id"] == id: return entry
    return {}

func add_unit(kind: String) -> String:
    if not Data.MODELS.has(kind) or units.size() >= Data.MAX_UNITS: return ""
    var id: String = "storage_%d"%next_unit
    while not unit(id).is_empty():
        next_unit += 1
        id = "storage_%d"%next_unit
    units.append({"id":id,"model":kind})
    next_unit += 1
    return id

func remove_unit(id: String) -> bool:
    if units.size() <= 1 or held != "": return false
    for p: Dictionary in placements.values():
        if p["unit"] == id: return false
    for i in range(units.size()):
        if units[i]["id"] == id:
            units.remove_at(i)
            return true
    return false

func can_place(uid: String, unit_id: String, shelf: int, cell: Vector2i, rotation: int) -> bool:
    if not items.has(uid): return false
    var furniture: Dictionary = unit(unit_id)
    if furniture.is_empty(): return false
    var spec: Dictionary = Data.MODELS[furniture["model"]]
    if not items[uid]["category"] in spec["accepts"] or shelf<0 or shelf>=int(spec["shelves"]): return false
    var area := Rect2i(cell,Data.footprint(items[uid],rotation))
    if not Rect2i(Vector2i.ZERO,spec["size"]).encloses(area): return false
    for other: String in placements:
        if other == uid: continue
        var p: Dictionary = placements[other]
        if p["unit"] == unit_id and p["shelf"] == shelf and area.intersects(Rect2i(p["cell"],Data.footprint(items[other],p["rotation"]))): return false
    return true

func place(uid: String, unit_id: String, shelf: int, cell: Vector2i, rotation: int) -> bool:
    if not can_place(uid,unit_id,shelf,cell,rotation): return false
    placements[uid] = {"unit":unit_id,"shelf":shelf,"cell":cell,"rotation":posmod(rotation,4)}
    return true

func begin(uid: String) -> bool:
    if held != "" or not items.has(uid): return false
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
        for furniture: Dictionary in units:
            var spec: Dictionary = Data.MODELS[furniture["model"]]
            for shelf in range(spec["shelves"]):
                for rotation in [0,1]:
                    for y in range(spec["size"].y):
                        for x in range(spec["size"].x):
                            if place(uid,furniture["id"],shelf,Vector2i(x,y),rotation):
                                stored = true
                                break
                        if stored: break
                    if stored: break
                if stored: break
            if stored: break

func arrange() -> void:
    cancel()
    placements.clear()
    fill_unplaced()

func snapshot() -> Dictionary:
    var result: Dictionary = {}
    for uid: String in placements:
        var p: Dictionary = placements[uid]
        result[uid] = {"unit":p["unit"],"shelf":p["shelf"],"cell":[p["cell"].x,p["cell"].y],"rotation":p["rotation"]}
    return {"version":1,"units":units.duplicate(true),"placements":result}
