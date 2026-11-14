# Standalone outing rules. Deliberately no GameState/save/inventory writes.
extends RefCounted
const Data = preload("res://scripts/salvage/salvage_data.gd")
const Pile = preload("res://scripts/salvage/salvage_pile.gd")
const Grid = preload("res://scripts/salvage/cargo_grid.gd")
static var demo: RefCounted
var day: int = 1
var remaining: float = Data.NIGHT_MINUTES
var car: String = "hatch"
var site: String = ""
var piles: Dictionary = {}
var cycles: Dictionary = {}
var grids: Dictionary = {}
var cargo: Dictionary = {}
var shelf: Dictionary = {}
var pile: RefCounted
var reserve: float = 0
var paused: bool = false
var held: String = ""
var rotation: int = 0
var effort: Dictionary = {}
var original: Dictionary = {}
var message: String = "Choose a site and car. Cargo and piles last for this app session only."
var physics_mode: bool = false

func _init() -> void:
    for id: String in Data.CARS:
        var grid := Grid.new()
        grid.size = Data.CARS[id]["grid"]
        grids[id] = grid
        cargo[id] = {}

static func shared_demo() -> RefCounted:
    if demo == null: demo = load("res://scripts/salvage/salvage_session.gd").new()
    return demo

func travel(location: String) -> float:
    return float(Data.SITES[location]["travel"])/float(Data.CARS[car]["speed"])

func cycle_for(location: String) -> int:
    return (day-1)/int(Data.SITES[location]["refresh"])

func depart(location: String) -> bool:
    if site != "" or not Data.SITES.has(location) or remaining < travel(location)*2: return false
    var cycle: int = cycle_for(location)
    if not piles.has(location) or int(cycles[location]) != cycle:
        var created := Pile.new()
        created.generate(location,cycle)
        piles[location] = created
        cycles[location] = cycle
    site = location
    pile = piles[site]
    reserve = travel(site)
    remaining -= reserve
    paused = false
    message = "Hold and pull. Lift finds over the rim before packing. E opens containers / strips a PC."
    return true

func next_night() -> bool:
    if site != "": return false
    day += 1
    remaining = Data.NIGHT_MINUTES
    message = "Another demo night. Sites refresh on their own few-day schedule; cargo stays."
    return true

func find(uid: String) -> Dictionary:
    if cargo[car].has(uid): return cargo[car][uid]
    if site != "" and pile.objects.has(uid):
        var item: Dictionary = pile.objects[uid]
        if item["zone"] in ["pile","sort","hidden"]: return item
    return {}

func start_effort(uid: String, action: String) -> bool:
    if paused or site == "" or held != "" or not effort.is_empty(): return false
    var item: Dictionary = find(uid)
    if item.is_empty() or item["zone"] == "hidden": return false
    if not action in ["grab","open"]: return false
    if action == "open" and (item["zone"] == "cargo" or item["opened"] or not item["kind"] in ["bag","box","pc"]): return false
    var duration: float = 0.32 if item["zone"] == "sort" or item["zone"] == "cargo" else 0.60
    if float(item["mass"])>1.0: duration = 0.85
    if item["kind"] == "pc": duration = 1.1
    if action == "open": duration = 1.0
    var cost: float = float(item["mass"]) if action == "grab" else 3.0*(2.0 if item["kind"] == "pc" else 1.0)
    if remaining-reserve < cost:
        message = "Keep enough time for the drive home. Return or choose a cheaper action."
        return false
    message = "Opening / stripping... Esc cancels; effort already spent is not refunded." if action == "open" else "Lifting... release to cancel. Effort already spent is not refunded."
    effort = {"uid":uid,"action":action,"elapsed":0.0,"duration":duration,"cost":cost}
    return true

func cancel_effort() -> void:
    if not effort.is_empty(): message = "Stopped. Time already spent on the effort is not refunded."
    effort.clear() # partial effort is already charged, not refunded

func step(delta: float, target: Vector2) -> void:
    if paused or site == "": return
    var dt: float = clampf(delta,0,1.0/30.0)
    if not effort.is_empty():
        var advance: float = minf(dt,float(effort["duration"])-float(effort["elapsed"]))
        remaining -= float(effort["cost"])*advance/float(effort["duration"])
        effort["elapsed"] += advance
        if float(effort["elapsed"]) >= float(effort["duration"])-0.00001:
            var uid: String = effort["uid"]
            var action: String = effort["action"]
            effort.clear()
            if action == "open":
                var exposed: Array = pile.open(uid)
                message = "Opened: %d objects revealed. Nothing rerolled."%exposed.size()
            else:
                held = uid
                var item: Dictionary = find(uid)
                original = {"center":item["center"],"zone":item["zone"],"rotation":item["rotation"]}
                rotation = item["rotation"]
                if pile.objects.has(uid): pile.raise_item(uid)
                message = "Drag to the sorting area or trunk. Q/E or wheel rotates. Esc cancels."

func turn(step_by: int) -> void:
    if held == "" or paused: return
    rotation = posmod(rotation+step_by,4)
    find(held)["rotation"] = rotation

func drop_world(point: Vector2) -> bool:
    if held == "" or paused: return false
    if not Pile.BIN.has_point(point) and not Pile.SORT.has_point(point):
        cancel_hand()
        return false
    var item: Dictionary = find(held)
    if physics_mode: point = item["center"]
    if not _finish_move(point):
        cancel_hand()
        return false
    grids[car].placements.erase(held)
    cargo[car].erase(held)
    pile.objects[held] = item
    if not pile.order.has(held): pile.order.append(held)
    for child_id: String in item.get("packed_children",{}):
        pile.objects[child_id] = item["packed_children"][child_id]
        if not pile.order.has(child_id): pile.order.append(child_id)
    item.erase("packed_children")
    item["zone"] = "sort" if Pile.SORT.has_point(point) else "pile"
    if not physics_mode:
        item["center"] = point
        pile.clamp_item(item)
        item["velocity"] = Vector2.ZERO
    held = ""
    original.clear()
    return true

func drop_cargo(cell: Vector2i) -> bool:
    if held == "" or paused: return false
    var item: Dictionary = find(held)
    if not Data.SHAPES.has(item["kind"]) or not grids[car].can_place(held,item["kind"],cell,rotation):
        message = "That does not fit. Returned to its last safe spot."
        cancel_hand()
        return false
    if physics_mode and not _clear_of_bin(item):
        message = "Lift the whole object over the rim before packing it."
        cancel_hand()
        return false
    var target: Vector2 = Data.CARGO_ORIGIN+(Vector2(cell)+Vector2(Data.footprint(item["kind"],rotation))*0.5)*Data.CELL
    if not _finish_move(target):
        cancel_hand()
        return false
    grids[car].place(held,item["kind"],cell,rotation)
    item["center"] = target
    item["zone"] = "cargo"
    item["owner"] = "player"
    item["velocity"] = Vector2.ZERO
    cargo[car][held] = item
    if pile.objects.has(held):
        var children: Dictionary = {}
        for child_id: String in item["children"]:
            children[child_id] = pile.objects[child_id]
            pile.objects.erase(child_id)
            pile.order.erase(child_id)
        if not children.is_empty(): item["packed_children"] = children
        pile.objects.erase(held)
        pile.order.erase(held)
    held = ""
    original.clear()
    message = "Packed. Condition remains untested; this is demo cargo, not repair stock."
    return true

func _finish_move(target: Vector2) -> bool:
    if physics_mode: return true # actual travelled grip distance was already charged
    var item: Dictionary = find(held)
    var cost: float = Vector2(item["center"]).distance_to(target)*0.001
    if cost > remaining-reserve:
        message = "Not enough search time for that move. Return travel is protected."
        return false
    remaining -= cost
    return true

func _clear_of_bin(item: Dictionary) -> bool:
    var size: Vector2 = item["size"]
    var angle: float = item["angle"]
    var half_width: float = (absf(cos(angle))*size.x+absf(sin(angle))*size.y)*0.5
    return Vector2(item["center"]).x-half_width > Pile.BIN.end.x+6

func charge_motion(distance: float) -> void:
    remaining = maxf(reserve,remaining-maxf(0,distance)*0.001)
    if remaining <= reserve+0.000001 and held != "":
        cancel_hand()
        message = "Search time used. Object released safely; the drive home is reserved."

func cancel_hand() -> void:
    cancel_effort()
    if held == "": return
    var item: Dictionary = find(held)
    if not physics_mode or original.get("zone","") == "cargo":
        for key: String in original: item[key] = original[key]
        item["velocity"] = Vector2.ZERO
    held = ""
    original.clear()

func return_home() -> bool:
    if site == "": return false
    cancel_hand()
    remaining = maxf(0,remaining-reserve)
    reserve = 0
    site = ""
    paused = false
    message = "Returned with %d items in this car. Inspect the trunk or unload to the demo shelf."%cargo[car].size()
    return true

func unload() -> int:
    if site != "": return 0
    var count: int = cargo[car].size()
    for uid: String in cargo[car]: shelf[uid] = cargo[car][uid]
    cargo[car].clear()
    grids[car].placements.clear()
    message = "%d items moved once to the demo shelf (%d total). No campaign stock awarded."%[count,shelf.size()]
    return count
