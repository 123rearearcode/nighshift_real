# Tiny trial replacement choices, NOT the final parts catalogue.
extends RefCounted
const Ids = preload("res://scripts/data/ids.gd")
const IDS: Array = Ids.SERVICE_PARTS

static func option(part_id: String, tier: String) -> Dictionary:
    if not part_id in IDS or not tier in ["similar", "budget"]: return {}
    var budget: bool = tier == "budget"
    return {"label": ("Budget " if budget else "Equivalent ") + ("cooler" if part_id == Ids.COOLER else "GPU"),
        "cost": (7 if budget else 16) if part_id == Ids.COOLER else (18 if budget else 40),
        "performance": 65 if budget else 100,
        "heat_penalty": 8.0 if budget and part_id == Ids.COOLER else 0.0}


static func component(uid: String, kind: String, tier: String) -> Dictionary:
    var choice: Dictionary = option(kind,tier)
    if choice.is_empty(): return {}
    return {"id":uid,"category":kind.to_upper(),"display_name":choice["label"],"short_label":kind.to_upper(),
        "connector_type":"PCIE_X16" if kind == Ids.GPU else "COOLER_MOUNT",
        "footprint":Vector2i(8,1) if kind == Ids.GPU else Vector2i(2,2),"height":2,
        "details":[["Tier",tier],["Specification",str(choice["performance"])+"%"],["Owner","Player stock"]]}
