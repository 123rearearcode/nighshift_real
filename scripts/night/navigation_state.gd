# UI-only resume preferences. Bound to the current run; never owns PCs or salvage items.
extends RefCounted
const Store = preload("res://scripts/state/save_store.gd")
const ACTIVITIES := "res://scenes/activities.tscn"
const ROOM := "res://scenes/storage.tscn"
const REPAIR := "res://scenes/night_bench.tscn"
const HARDWARE := "res://scenes/night_hardware.tscn"
const MONITOR := "res://scenes/software.tscn"
const PATHS: Array = [ACTIVITIES,ROOM,REPAIR,HARDWARE,MONITOR,"res://scenes/night_salvage.tscn","res://scenes/night_shop.tscn","res://scenes/night_bay.tscn"]
static func _run(gs: Node) -> String:
    return str(gs.job.get("hardware_trial",{}).get("night_session",{}).get("run",""))
static func _read(gs: Node) -> Dictionary:
    var raw: Variant = Store.read(gs.save_path+".navigation.json")
    if not raw is Dictionary or raw.get("version",0) != 1 or raw.get("run","") != _run(gs): return {}
    return raw
static func _write(gs: Node,data: Dictionary) -> bool:
    var existing: Variant = Store.read(gs.save_path+".navigation.json")
    if existing is Dictionary and typeof(existing.get("version",0)) in [TYPE_INT,TYPE_FLOAT] and existing.get("version",0)>1: return false
    return Store.write(gs.save_path+".navigation.json",data)
static func enter(gs: Node,path: String) -> bool:
    if not path in PATHS or _run(gs) == "": return true
    var data := _read(gs)
    data["version"] = 1
    data["run"] = _run(gs)
    data["scene"] = path
    if path in [REPAIR,HARDWARE,MONITOR]:
        var old: Variant = data.get("workbench_views",{})
        var views: Dictionary = old if old is Dictionary else {}
        if views.size()>64: views.clear()
        views[str(gs.job["id"])] = path
        data["workbench_views"] = views
    return _write(gs,data)
static func resume_path(gs: Node) -> String:
    var path: Variant = _read(gs).get("scene",ACTIVITIES)
    if not path is String or not path in PATHS: return ACTIVITIES
    if path in [REPAIR,HARDWARE,MONITOR] and gs.job.get("hardware_trial",{}).get("night_session",{}).get("pc","") == "": return ROOM
    return path
static func repair_stage(gs: Node) -> int:
    var stages: Variant = _read(gs).get("repair_stages",{})
    return 1 if stages is Dictionary and stages.get(str(gs.job.get("id","")),0) == 1 else 0
static func set_repair_stage(gs: Node,stage: int) -> bool:
    if _run(gs) == "": return true
    var data := _read(gs)
    var old: Variant = data.get("repair_stages",{})
    var stages: Dictionary = old if old is Dictionary else {}
    if stages.size() > 64: stages.clear()
    stages[str(gs.job["id"])] = 1 if stage == 1 else 0
    data["repair_stages"] = stages
    data["version"] = 1
    data["run"] = _run(gs)
    return _write(gs,data)

static func workbench_path(gs: Node) -> String:
    var views: Variant = _read(gs).get("workbench_views",{})
    if not views is Dictionary: return REPAIR
    var path: Variant = views.get(str(gs.job.get("id","")),REPAIR)
    return path if path in [REPAIR,HARDWARE,MONITOR] else REPAIR
