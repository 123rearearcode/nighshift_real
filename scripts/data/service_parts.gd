# Repair-bench replacement stock: two tiers per serviceable part, each a catalogue model (D148).
extends RefCounted
const Ids = preload("res://scripts/data/ids.gd")
const IDS: Array = Ids.SERVICE_PARTS
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")

# D148 (0.45.0): the two stock tiers are catalogue models (pc_build.gd SERVICE_MODELS). "performance" is
# the share of the demo PCs' original part, for the old notes; heat now comes from the cooler's capacity.
static func option(part_id: String, tier: String) -> Dictionary:
    if not part_id in IDS: return {}
    var catalog_tier: bool = tier.begins_with("model:") and Catalog.is_type(tier.trim_prefix("model:"), Catalog.GPU if part_id == Ids.GPU else Catalog.COOLER)
    if not tier in ["similar", "budget"] and not catalog_tier: return {}
    var model: Dictionary = Catalog.part(PcBuild.model_of(tier, part_id, ""))
    var original: Dictionary = Catalog.part(str(PcBuild.SERVICE_MODELS[part_id]["similar"]))
    var key: String = "graphics" if part_id == Ids.GPU else "capacity"
    var share: int = roundi(100.0 * float(model[key]) / float(original[key]))
    return {"label": ("Budget: " if tier == "budget" else ("Catalogue: " if catalog_tier else "Equivalent: ")) + str(model["name"]),
        "model": str(model["id"]),
        "cost": int(model["price"]),
        "performance": share,
        "power": share,
        "heat_penalty": 0.0}


static func component(uid: String, kind: String, tier: String) -> Dictionary:
    var choice: Dictionary = option(kind,tier)
    if choice.is_empty(): return {}
    return {"id":uid,"category":kind.to_upper(),"display_name":choice["label"],"short_label":kind.to_upper(),
        "connector_type":"PCIE_X16" if kind == Ids.GPU else "COOLER_MOUNT",
        "footprint":Vector2i(8,1) if kind == Ids.GPU else Vector2i(2,2),"height":2,
        "details":[["Model",str(choice["label"]).split(": ")[1]],["Tier",tier],["Specification",str(choice["performance"])+"% of the original"],["Owner","Player stock"]]}
