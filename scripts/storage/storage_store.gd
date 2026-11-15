# Auxiliary layout persistence only. GameState remains the authority for items/money/PCs.
extends RefCounted
const SafeStore = preload("res://scripts/state/save_store.gd")
var path: String = "user://nightshift_storage.json"
var read_only: bool = false
var status: String = ""

func read() -> Dictionary:
    var raw: Variant = SafeStore.read(path)
    read_only = false
    status = ""
    if not raw is Dictionary: return {}
    var version: Variant = raw.get("version",0)
    if typeof(version) in [TYPE_INT,TYPE_FLOAT] and float(version)>1:
        read_only = true
        status = "Newer storage layout found. Editing is disabled to protect it."
    return raw

func write(model: RefCounted) -> bool:
    if read_only: return false
    if not SafeStore.write(path,model.snapshot()):
        status = "Layout not saved. Your previous save is safe. Use Save layout to retry."
        return false
    status = ""
    return true
