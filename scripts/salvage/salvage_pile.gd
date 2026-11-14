# Side-view item/contents records. Native bodies in SalvagePhysics own physical movement.
extends RefCounted
const Data = preload("res://scripts/salvage/salvage_data.gd")
const BIN := Rect2(40,174,590,448)
const SORT := Rect2(654,174,196,448)
var objects: Dictionary = {}
var order: Array[String] = []
var impacts: int = 0
var spawn_seed: int = 0

func add(kind: String, center: Vector2, size: Vector2, uid: String, rng: RandomNumberGenerator, parent: String = "") -> void:
    objects[uid] = {"uid":uid,"kind":kind,"center":center,"size":size,"velocity":Vector2.ZERO,
        "angle":0.0,"spin":0.0,"rotation":0,"zone":"hidden" if parent != "" else "pile",
        "parent":parent,"mass":float(Data.MASSES.get(kind,2.0 if kind == "pc" else 1.5 if size.x>110 else 1.0 if kind in ["bag","box"] else 0.7)),"opened":false,"tier":"budget","condition":"broken" if rng.randf()<0.35 else "working",
        "known_condition":"untested","power":Data.POWER.get(kind,0),"owner":"unclaimed","children":[]}
    if kind in ["gpu","pc","cpu"] and rng.randf()<0.25:
        objects[uid]["tier"] = "similar"
        objects[uid]["power"] = 100
    order.append(uid)
    if parent != "": objects[parent]["children"].append(uid)

func generate(site: String, visit: int, seed_override: int = -1, identity_prefix: String = "") -> void:
    objects.clear()
    order.clear()
    impacts = 0
    var rng := RandomNumberGenerator.new()
    if seed_override<0: rng.randomize()
    else: rng.seed = seed_override
    spawn_seed = rng.seed
    var prefix: String = "%s:%d:%s:%d:"%[site,visit,identity_prefix,spawn_seed]
    var kinds: Array[String] = []
    var chance: float = float(Data.SITES[site]["hardware_chance"])
    for i in range(rng.randi_range(14,22)):
        var roll: float = rng.randf()
        kinds.append(Data.loot(rng,site) if roll<chance else "bag" if roll<chance+(1.0-chance)*0.4 else "box" if roll<0.88 else "junk")
    for i in range(rng.randi_range(1,2)): kinds.append("concrete" if rng.randf()<0.5 else "appliance")
    # Shuffle with this RNG (Array.shuffle uses the global stream and breaks seeded reproduction).
    for i in range(kinds.size()-1,0,-1):
        var j: int = rng.randi_range(0,i)
        var swap: String = kinds[i]
        kinds[i] = kinds[j]
        kinds[j] = swap
    var occupied: Array[Rect2] = []
    for i in range(kinds.size()):
        if objects.size()>=Data.MAX_OBJECTS: break
        var kind: String = kinds[i]
        var size: Vector2 = Vector2(Data.SHAPES[kind])*rng.randf_range(24,28) if Data.SHAPES.has(kind) else Vector2(rng.randf_range(65,120),rng.randf_range(40,78))
        if kind == "box": size = Vector2(rng.randf_range(88,135),rng.randf_range(64,92))
        if kind == "concrete": size = Vector2(rng.randf_range(110,145),rng.randf_range(52,68))
        if kind == "appliance": size = Vector2(rng.randf_range(88,110),rng.randf_range(95,120))
        var angle: float = rng.randf_range(-0.12,0.12)
        var bounds := Vector2(absf(cos(angle))*size.x+absf(sin(angle))*size.y,absf(sin(angle))*size.x+absf(cos(angle))*size.y)
        var point: Vector2 = _spawn_point(rng,bounds,occupied)
        if point == Vector2.INF: continue # bounded pile; never force an overlap or exceed the ceiling
        var uid: String = prefix+"find%d"%i
        add(kind,point,size,uid,rng)
        objects[uid]["angle"] = angle
        occupied.append(Rect2(point-bounds*0.5,bounds))
        var contents: Array[String] = []
        if kind == "pc":
            contents = ["ram","psu"]
            if rng.randf()<0.7: contents.append("motherboard" if rng.randf()<0.5 else Data.loot(rng,site))
        elif kind in ["bag","box"]:
            for child in range(rng.randi_range(0,3)):
                contents.append(Data.loot(rng,site) if rng.randf()<chance else "junk")
        for child in range(contents.size()):
            if objects.size()>=Data.MAX_OBJECTS-(kinds.size()-i-1): break
            var child_kind: String = contents[child]
            var physical: Vector2 = Vector2(Data.SHAPES[child_kind])*22 if Data.SHAPES.has(child_kind) else Vector2(38,28)
            # Nested sealed PCs are disallowed; exposed PC contents stay physical manageable pieces.
            if child_kind == "pc": child_kind = "cpu"; physical = Vector2(28,28)
            add(child_kind,point,physical,uid+":inside%d"%child,rng,uid)

func _spawn_point(rng: RandomNumberGenerator,size: Vector2,occupied: Array[Rect2]) -> Vector2:
    var chosen := Vector2.INF
    for attempt in range(24):
        var x: float = rng.randf_range(54+size.x*0.5,612-size.x*0.5)
        var y: float = 612-size.y*0.5
        for rect: Rect2 in occupied:
            if x+size.x*0.5+5>rect.position.x and x-size.x*0.5-5<rect.end.x:
                y = minf(y,rect.position.y-size.y*0.5-6)
        if y-size.y*0.5<174: continue
        if chosen == Vector2.INF or y>chosen.y: chosen = Vector2(x,y)
    return chosen

func extent(item: Dictionary) -> Vector2:
    var size: Vector2 = item["size"]
    return Vector2(size.y,size.x)*0.5 if posmod(int(item["rotation"]),2) else size*0.5

func raise_item(uid: String) -> void:
    order.erase(uid)
    order.append(uid)

func open(uid: String) -> Array:
    var item: Dictionary = objects[uid]
    if item["opened"] or not item["kind"] in ["bag","box","pc"]: return []
    item["opened"] = true
    var exposed: Array = []
    var stack_y: float = Vector2(item["size"]).y*0.5-8
    for i in range(item["children"].size()):
        var id: String = item["children"][i]
        var child: Dictionary = objects[id]
        child["zone"] = item["zone"]
        child["parent"] = ""
        var child_size: Vector2 = child["size"]
        var room_x: float = maxf(0,(Vector2(item["size"]).x-child_size.x)*0.5-7)
        var offset := Vector2(clampf(-6+i*12,-room_x,room_x),stack_y-child_size.y*0.5)
        stack_y -= child_size.y+4
        if item["kind"] == "bag": offset = Vector2((i-(item["children"].size()-1)*0.5)*42,-46)
        var angle: float = float(item["angle"])
        var half := Vector2(absf(cos(angle))*child_size.x+absf(sin(angle))*child_size.y,absf(sin(angle))*child_size.x+absf(cos(angle))*child_size.y)*0.5
        var bounds := Rect2(646,146,196,466) if item["zone"] == "sort" else Rect2(52,146,560,466)
        child["center"] = (Vector2(item["center"])+offset.rotated(angle)).clamp(bounds.position+half,bounds.end-half)
        child["angle"] = float(item["angle"])
        child["velocity"] = Vector2(item["velocity"])+Vector2(-30+i*60,-60)
        raise_item(id)
        exposed.append(id)
    # The stripped PC remains a case; it no longer claims to contain those parts.
    item["children"] = []
    if item["kind"] == "bag":
        item["size"] = Vector2(Vector2(item["size"]).x,18)
        item["mass"] = 0.25
    if item["kind"] == "pc":
        item["condition"] = "incomplete"
        item["known_condition"] = "incomplete"
        item["power"] = 0
    return exposed

func clamp_item(item: Dictionary) -> void:
    var bounds: Rect2 = SORT if item["zone"] == "sort" else BIN
    var half: Vector2 = extent(item)
    item["center"] = Vector2(item["center"]).clamp(bounds.position+half,bounds.end-half)
