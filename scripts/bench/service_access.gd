# Service-access controller: original mounts, tray positions and drag state. No drawing/input.
extends RefCounted
const TRAY := Rect2(40, 540, 620, 110)
const MOVABLE := ["cooler", "gpu"]
var homes: Dictionary = {}
var parked: Dictionary = {}
var removed: Dictionary = {}
var dragging: String = ""
var drag_offset := Vector2.ZERO
var drag_rect := Rect2()

func setup(zones: Array, origin: Vector2, saved: Array) -> void:
    homes.clear()
    parked.clear()
    removed.clear()
    dragging = ""
    for z: Dictionary in zones:
        var id: String = str(z["id"])
        if id in MOVABLE:
            var rect: Rect2 = z["rect"]
            rect.position += origin
            homes[id] = rect
            parked[id] = Rect2(Vector2(65, 563) if id == "cooler" else Vector2(260, 585), rect.size)
            removed[id] = id in saved

func current_rect(id: String) -> Rect2:
    if dragging == id:
        return drag_rect
    return parked[id] if bool(removed.get(id, false)) else homes[id]

func begin(point: Vector2) -> bool:
    for id: String in MOVABLE:
        var rect: Rect2 = current_rect(id)
        if rect.has_point(point):
            dragging = id
            drag_rect = rect
            drag_offset = point - rect.position
            return true
    return false

func move(point: Vector2) -> void:
    if dragging != "":
        drag_rect.position = point - drag_offset

# Snap only to the service tray or original slot. Invalid releases return to prior position.
func finish(point: Vector2) -> Dictionary:
    if dragging == "": return {"changed": false, "message": ""}
    var id: String = dragging
    var before: bool = bool(removed[id])
    var valid: bool = true
    if TRAY.has_point(point): removed[id] = true
    elif (homes[id] as Rect2).grow(12).has_point(point): removed[id] = false
    else: valid = false
    dragging = ""
    return {"changed": before != bool(removed[id]), "id": id,
        "message": ("Removed " + id + "; clean its surface in the tray and the exposed dust underneath." if bool(removed[id]) else "Refitted " + id + " into its original mount.") if valid else "Drop on the tray or the original mount. Returned to its previous position."}

func set_removed(id: String, value: bool) -> void:
    if id in MOVABLE: removed[id] = value

func removed_ids() -> Array:
    var ids: Array = []
    for id: String in MOVABLE:
        if bool(removed.get(id, false)): ids.append(id)
    return ids

func blockers() -> Array:
    var out: Array = []
    for id: String in MOVABLE:
        if not bool(removed.get(id, false)): out.append({"id": id, "rect": homes[id]})
    return out
