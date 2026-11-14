# Bounded top-down physical pile. Identity/contents generated once per site cycle.
extends RefCounted
const Data = preload("res://scripts/salvage/salvage_data.gd")
const BIN := Rect2(40,174,590,448)
const SORT := Rect2(654,174,196,448)
var objects: Dictionary = {}
var order: Array[String] = []
var sequence: int = 0
var impacts: int = 0
var solver_steps: int = 0

func add(kind: String, center: Vector2, size: Vector2, uid: String, rng: RandomNumberGenerator, parent: String = "") -> void:
    objects[uid] = {"uid":uid,"kind":kind,"center":center,"size":size,"velocity":Vector2.ZERO,
        "angle":0.0,"spin":0.0,"rotation":0,"zone":"hidden" if parent != "" else "pile",
        "parent":parent,"mass":2.0 if kind == "pc" else 1.5 if size.x>110 else 1.0 if kind in ["bag","box"] else 0.7,"opened":false,"tier":"budget","condition":"broken" if rng.randf()<0.35 else "working",
        "known_condition":"untested","power":Data.POWER.get(kind,0),"owner":"unclaimed","children":[]}
    if kind in ["gpu","pc"] and rng.randf()<0.25:
        objects[uid]["tier"] = "similar"
        objects[uid]["power"] = 100
    order.append(uid)
    if parent != "": objects[parent]["children"].append(uid)

func generate(site: String, cycle: int) -> void:
    objects.clear()
    order.clear()
    var rng := RandomNumberGenerator.new()
    rng.seed = 4907 + cycle*7919 + (0 if site == "mixed" else 65537)
    var prefix: String = "%s:%d:" % [site,cycle]
    # Five lanes keep clues exposed while larger obstructions overlap finds.
    for i in range(8):
        var point := Vector2(112+(i%4)*139,263+(i/4)*219)
        var uid: String = prefix+"find%d"%i
        var chance: float = float(Data.SITES[site]["hardware_chance"])
        if rng.randf() < chance:
            var kind: String = ["gpu","ram","psu","drive","pc"][rng.randi_range(0,4)]
            var physical: Vector2 = Vector2(Data.SHAPES[kind])*26
            add(kind,point+Vector2(-22,0),physical,uid,rng)
            if kind == "pc":
                add("ram",point,Vector2(52,26),uid+":ram",rng,uid)
                add("gpu",point,Vector2(78,26),uid+":gpu",rng,uid)
        else:
            add("junk",point,Vector2(48,38),uid,rng)
        var shell: String = "bag" if rng.randf()<0.55 else "box"
        var cover: String = prefix+"cover%d"%i
        add(shell,point+Vector2(13,-4),Vector2(91,79),cover,rng)
        if rng.randf()<0.65:
            var child_kind: String = "drive" if rng.randf()<chance else "junk"
            add(child_kind,point,Vector2(52,32),cover+":inside",rng,cover)
    # One loose obstruction adds a different weight without always guaranteeing loot.
    add("box",Vector2(325,395),Vector2(122,93),prefix+"heavy",rng)

func extent(item: Dictionary) -> Vector2:
    var size: Vector2 = item["size"]
    return Vector2(size.y,size.x)*0.5 if posmod(int(item["rotation"]),2) else size*0.5

func hit(point: Vector2) -> String:
    for i in range(order.size()-1,-1,-1):
        var item: Dictionary = objects[order[i]]
        if not item["zone"] in ["pile","sort"]: continue
        var half: Vector2 = extent(item)
        if Rect2(Vector2(item["center"])-half,half*2).has_point(point): return order[i]
    return ""

func blocker(uid: String) -> String:
    var item: Dictionary = objects.get(uid,{})
    if item.is_empty() or item["zone"] != "pile": return ""
    var half: Vector2 = extent(item)
    var area := Rect2(Vector2(item["center"])-half,half*2)
    var at: int = order.find(uid)
    for i in range(order.size()-1,at,-1):
        var above: Dictionary = objects[order[i]]
        if above["zone"] != "pile": continue
        var other_half: Vector2 = extent(above)
        var overlap: Rect2 = area.intersection(Rect2(Vector2(above["center"])-other_half,other_half*2))
        if overlap.has_area() and overlap.get_area()>area.get_area()*0.30: return order[i]
    return ""

func raise_item(uid: String) -> void:
    order.erase(uid)
    order.append(uid)

func open(uid: String) -> Array:
    var item: Dictionary = objects[uid]
    if item["opened"] or not item["kind"] in ["bag","box","pc"]: return []
    item["opened"] = true
    var exposed: Array = []
    for i in range(item["children"].size()):
        var id: String = item["children"][i]
        var child: Dictionary = objects[id]
        child["zone"] = item["zone"]
        child["parent"] = ""
        child["center"] = Vector2(item["center"])+Vector2(-35+i*66,36)
        child["velocity"] = Vector2(-35+i*70,25)
        clamp_item(child)
        raise_item(id)
        exposed.append(id)
    # The stripped PC remains a case; it no longer claims to contain those parts.
    item["children"] = []
    if item["kind"] == "pc":
        item["condition"] = "incomplete"
        item["known_condition"] = "incomplete"
        item["power"] = 0
    return exposed

func clamp_item(item: Dictionary) -> void:
    var bounds: Rect2 = SORT if item["zone"] == "sort" else BIN
    var half: Vector2 = extent(item)
    item["center"] = Vector2(item["center"]).clamp(bounds.position+half,bounds.end-half)

func step(delta: float, held: String) -> void:
    var dt: float = minf(delta,1.0/30.0)
    for uid: String in order:
        var item: Dictionary = objects[uid]
        if uid == held or not item["zone"] in ["pile","sort"]: continue
        var velocity: Vector2 = item["velocity"]
        if velocity.length_squared()<1 and absf(float(item["spin"]))<0.005:
            item["angle"] = move_toward(float(item["angle"]),0,dt*0.8)
            continue
        solver_steps += 1
        var old: Vector2 = item["center"]
        item["center"] = old+velocity*dt
        var before: Vector2 = item["center"]
        clamp_item(item)
        for axis in range(2):
            if absf(before[axis]-Vector2(item["center"])[axis])>0.001:
                velocity[axis] *= -clampf(0.35/float(item["mass"]),0.15,0.45)
                impacts += 1
        item["velocity"] = velocity*exp(-6*dt)
        item["angle"] = clampf(float(item["angle"])+float(item["spin"])*dt,-0.22,0.22)
        item["spin"] = float(item["spin"])*exp(-8*dt)

func nudge_neighbours(uid: String, speed: Vector2) -> void:
    if speed.length()<130: return
    var item: Dictionary = objects[uid]
    var half: Vector2 = extent(item)
    for other: String in order:
        var target: Dictionary = objects[other]
        if other == uid or target["zone"] != item["zone"]: continue
        var other_half: Vector2 = extent(target)
        if Rect2(Vector2(item["center"])-half,half*2).intersects(Rect2(Vector2(target["center"])-other_half,other_half*2)):
            target["velocity"] = Vector2(target["velocity"])+speed.limit_length(80)*0.3/float(target["mass"])
            target["spin"] = clampf(speed.x*0.0008,-0.7,0.7)
