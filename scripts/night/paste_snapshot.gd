# The physical paste field belongs to its PC, not to the bench screen.
extends RefCounted
const Materials = preload("res://scripts/data/paste_materials.gd")
const Paste = preload("res://scripts/bench/paste_sim.gd")
static func capture(paste: RefCounted) -> Dictionary:
    return {"version":1,"height_bytes":Marshalls.raw_to_base64(paste.h.to_byte_array()),"deposited":paste.total_deposited,"material":paste.material}
static func restore(paste: RefCounted,raw: Variant) -> bool:
    if not raw is Dictionary or raw.get("version",0) != 1: return false
    if not raw.get("height_bytes",null) is String: return false
    var bytes: PackedByteArray = Marshalls.base64_to_raw(raw["height_bytes"])
    if bytes.size() != Paste.GRID*Paste.GRID*4: return false
    var field: PackedFloat32Array = bytes.to_float32_array()
    if not raw.get("material","") in Materials.IDS: return false
    if not typeof(raw.get("deposited",null)) in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(raw["deposited"])) or raw["deposited"]<0: return false
    for value: Variant in field:
        if not typeof(value) in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(value)) or value<0 or value>10000: return false
    paste.clear()
    paste.h = PackedFloat32Array(field)
    paste.total_deposited = float(raw["deposited"])
    paste.material = raw["material"]
    for i in range(field.size()):
        if field[i]>0:
            var x: int = i%Paste.GRID
            var y: int = i/Paste.GRID
            paste.min_x = mini(paste.min_x,x)
            paste.max_x = maxi(paste.max_x,x)
            paste.min_y = mini(paste.min_y,y)
            paste.max_y = maxi(paste.max_y,y)
    paste.mark_changed()
    return true
