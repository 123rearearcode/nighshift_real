# STATE LAYER helper (0.58.3, D173): where the cable box is kept. One small JSON file next to the save
# ("<save>.cables.json", written safely by SaveStore and copied by the morning backups). The box belongs to
# a playthrough: a file from another run (an older game in the same slot) is ignored and a fresh box is
# used (the lesson of B63). Rules live in scripts/rules/cable_box.gd.
extends RefCounted

const Store = preload("res://scripts/state/save_store.gd")
const CableBox = preload("res://scripts/rules/cable_box.gd")
const SUFFIX := ".cables.json"


static func path(save_path: String) -> String:
    return save_path + SUFFIX


# The playthrough the main save belongs to (the night session's run marker on the active job).
static func run_of(gs: Node) -> String:
    var trial: Variant = gs.job.get("hardware_trial", {})
    if not trial is Dictionary: return ""
    var marker: Variant = (trial as Dictionary).get("night_session", {})
    return str((marker as Dictionary).get("run", "")) if marker is Dictionary else ""


static func load_box(gs: Node) -> Dictionary:
    var run: String = run_of(gs)
    var raw: Variant = Store.read(path(gs.save_path), func(data: Dictionary) -> bool: return str(data.get("run", "")) == run)
    return CableBox.sanitize(raw, run)


static func save_box(gs: Node, state: Dictionary) -> bool:
    state["run"] = run_of(gs)
    return Store.write(path(gs.save_path), state)
