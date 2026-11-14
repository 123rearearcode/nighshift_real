# Side-view item/contents records. Native bodies in SalvagePhysics own physical movement.
extends RefCounted
const Data = preload("res://scripts/salvage/salvage_data.gd")
const BIN := Rect2(40,174,590,448)
const SORT := Rect2(654,174,196,448)
var objects: Dictionary = {}
var order: Array[String] = []
var impacts: int = 0

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
    # Spawn four non-overlapping columns. Native gravity settles these into one physical pile.
    var tops: Array = [612.0,612.0,612.0,612.0]
    for i in range(8):
        var column: int = i%4
        var point := Vector2(112+column*139,float(tops[column]))
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
        var root: Dictionary = objects[uid]
        root["center"] = point-Vector2(0,Vector2(root["size"]).y*0.5)
        tops[column] = float(root["center"].y)-Vector2(root["size"]).y*0.5-5
        var shell: String = "bag" if rng.randf()<0.55 else "box"
        var cover: String = prefix+"cover%d"%i
        add(shell,Vector2(point.x+4,float(tops[column])-44),Vector2(86,82),cover,rng)
        tops[column] = float(objects[cover]["center"].y)-46
        if rng.randf()<0.65:
            var child_kind: String = "drive" if rng.randf()<chance else "junk"
            add(child_kind,point,Vector2(52,32),cover+":inside",rng,cover)
    # One loose obstruction adds a different weight without always guaranteeing loot.
    add("box",Vector2(325,minf(float(tops[1]),float(tops[2]))-49),Vector2(154,88),prefix+"heavy",rng)

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
    for i in range(item["children"].size()):
        var id: String = item["children"][i]
        var child: Dictionary = objects[id]
        child["zone"] = item["zone"]
        child["parent"] = ""
        var offset := Vector2(-6+i*12,-20+i*34)
        if item["kind"] == "bag": offset = Vector2(-25+i*50,-46)
        child["center"] = Vector2(item["center"])+offset.rotated(float(item["angle"]))
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
