# Pure identity/footprint packing. Held records stay committed until a valid drop.
extends RefCounted
const Data = preload("res://scripts/salvage/salvage_data.gd")
var size := Vector2i(8,5)
var placements: Dictionary = {}

func can_place(uid: String, kind: String, cell: Vector2i, rotation: int) -> bool:
    var area := Rect2i(cell,Data.footprint(kind,rotation))
    if not Rect2i(Vector2i.ZERO,size).encloses(area): return false
    for id: String in placements:
        if id == uid: continue
        var p: Dictionary = placements[id]
        if area.intersects(Rect2i(p["cell"],Data.footprint(p["kind"],p["rotation"]))): return false
    return true

func place(uid: String, kind: String, cell: Vector2i, rotation: int) -> bool:
    if not Data.SHAPES.has(kind) or not can_place(uid,kind,cell,rotation): return false
    placements[uid] = {"kind":kind,"cell":cell,"rotation":posmod(rotation,4)}
    return true

func at(cell: Vector2i) -> String:
    for id: String in placements:
        var p: Dictionary = placements[id]
        if Rect2i(p["cell"],Data.footprint(p["kind"],p["rotation"])).has_point(cell): return id
    return ""
