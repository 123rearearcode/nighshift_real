# RULES ONLY: what a salvage find becomes when it reaches the shop (session 3.6 / 0.50.0; user, 20 November
# 2026: connect the salvage runs to stock). Pure. A find the shop can stock becomes one UNTESTED part: an
# older catalogue model of that kind and a hidden real condition (working, degraded or dead); the
# testing bay finds out which. Anything else (fans, add-in cards, boards, whole PCs, bags, junk) is scrap.
# Same find uid + world seed = same part. Odds and models are trial proposals.
extends RefCounted

const PcBuild = preload("res://scripts/rules/pc_build.gd")
const PartCondition = preload("res://scripts/rules/part_condition.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")

# Salvage find kind -> catalogue type.
const KIND_TYPE: Dictionary = {"gpu": "gpu", "ram": "ram", "psu": "psu", "cpu": "cpu", "cooler": "cooler",
    "ssd": "storage", "hdd": "storage", "drive": "storage"}
# Older, common models a dump turns up (D22: older consumer parts are widely found).
const MODELS: Dictionary = {
    "gpu": ["gpu_gtx1550ti", "gpu_gtx1660", "gpu_rx6060"],
    "ram": ["ram_4gb", "ram_8gb", "ram_8gb"],
    "psu": ["psu_cv450", "psu_600w"],
    "cpu": ["cpu_pentium_g4650", "cpu_i5_6060", "cpu_rysen5_3060"],
    "cooler": ["cool_stock_box", "cool_stock_box", "cool_hyper212"],
    "ssd": ["sto_ssd_500"], "hdd": ["sto_hdd_500"], "drive": ["sto_hdd_500", "sto_ssd_500"],
}
# The pile already decided whether a find works (its hidden "condition"); a find that works may still
# be worn out: degraded, with this chance. A find without a pile condition rolls DEAD_CHANCE.
const DEGRADED_CHANCE: float = 0.3
const DEAD_CHANCE: float = 0.35


static func stockable(kind: String) -> bool:
    return KIND_TYPE.has(kind)


# The stock record for one find, or {} when the shop cannot stock that kind (it is scrapped instead).
static func stock_for(find: Dictionary, seed: int, uid: String) -> Dictionary:
    var kind: String = str(find.get("kind", ""))
    if not stockable(kind): return {}
    var r := RandomNumberGenerator.new()
    r.seed = hash("salvage:%d:%s" % [seed, str(find.get("uid", uid))])
    var models: Array = MODELS[kind]
    var model: String = str(models[r.randi_range(0, models.size() - 1)])
    var type: String = str(KIND_TYPE[kind])
    if not Catalog.is_type(model, type): return {}
    var pile_condition: String = str(find.get("condition", ""))
    var dead: bool = pile_condition == "broken" if pile_condition in ["working", "broken"] else r.randf() < DEAD_CHANCE
    var condition: String = PcBuild.BROKEN if dead else (PcBuild.DEGRADED if r.randf() < DEGRADED_CHANCE else PcBuild.WORKING)
    return {"uid": uid, "kind": type, "tier": "model", "model": model, "owner": "player", "condition": condition,
        "defect": str(PcBuild.DEFECTS.get(type, "")) if condition == PcBuild.DEGRADED else "",
        "known": PartCondition.fresh(PartCondition.UNTESTED, "Found at the salvage dump")}
