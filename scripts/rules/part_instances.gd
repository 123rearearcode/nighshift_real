# Physical records for parts handed over from shop stock. This is the first customer-owned path;
# legacy customer originals still use their old projections (L1), not invented historical identities.
extends RefCounted
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Build = preload("res://scripts/rules/pc_build.gd")
const Condition = preload("res://scripts/rules/part_condition.gd")
const SLOTS: Array = ["gpu", "cooler", "cpu", "psu_bay", "pcie_2", "ram_1", "ram_2", "ram_3", "m2_1", "m2_2"]

static func clean(raw: Variant, expected_model: String = "") -> Dictionary:
    if not raw is Dictionary: return {}
    var uid: Variant = raw.get("uid", "")
    var model: Variant = raw.get("model", "")
    if not uid is String or uid == "" or uid.length() > 160: return {}
    if not model is String or Catalog.part(model).is_empty() or (expected_model != "" and model != expected_model): return {}
    var kind: String = str(Catalog.part(model)["type"])
    var actual: String = Condition.sanitize_condition(raw.get("condition", Build.WORKING))
    var knowledge: Variant = raw.get("known", null)
    var out: Dictionary = {"uid":uid,"model":model,"kind":kind,"owner":str(raw.get("owner", "customer")),"condition":actual,
        "known":Condition.sanitize_known(knowledge,actual) if knowledge is Dictionary else Condition.fresh(Condition.UNTESTED, "")}
    var defect: String = Condition.sanitize_defect(kind,actual,raw.get("defect", ""))
    if defect != "": out["defect"] = defect
    return out

static func sanitize(raw: Variant) -> Dictionary:
    var out: Dictionary = {}
    var ids: Dictionary = {}
    if not raw is Dictionary: return out
    for slot: Variant in raw:
        if not str(slot) in SLOTS: continue
        var record: Dictionary = clean(raw[slot])
        if record.is_empty() or ids.has(str(record["uid"])): continue
        out[str(slot)] = record
        ids[str(record["uid"])] = true
    return out

static func from_stock(record: Dictionary, customer_id: String) -> Dictionary:
    var raw: Dictionary = record.duplicate(true)
    raw["model"] = Build.stock_model(record)
    raw["owner"] = "customer:" + customer_id
    return clean(raw)

static func loose(raw: Variant) -> Array:
    var out: Array = []
    if not raw is Array: return out
    for entry: Variant in raw:
        if not entry is Dictionary or Catalog.part(str(entry.get("id", ""))).is_empty(): continue
        var original: String = str(entry.get("original_of", ""))
        var item: Dictionary = {"id":str(entry["id"]),"broken":bool(entry.get("broken",false)),"damaged":bool(entry.get("damaged",false)),
            "original_of":original if original in ["gpu","cooler"] else ""}
        var record: Dictionary = clean(entry.get("instance", {}),str(entry["id"]))
        if not record.is_empty(): item["instance"] = record
        out.append(item)
    return out

static func get_part(job: Dictionary, slot: String) -> Dictionary:
    return sanitize(job.get("part_instances", {})).get(slot, {}).duplicate(true)

static func take(job: Dictionary, slot: String) -> Dictionary:
    var records: Dictionary = sanitize(job.get("part_instances", {}))
    var record: Dictionary = records.get(slot, {}).duplicate(true)
    records.erase(slot)
    job["part_instances"] = records
    return record

# Receipts are immutable history for a comeback, not a second writable PC database. Old comeback
# records without a receipt stay that way: already-lost condition cannot be reconstructed honestly.
static func snapshot(job: Dictionary) -> Dictionary:
    var marker: Variant = job.get("hardware_trial", {})
    marker = marker.get("night_session", {}) if marker is Dictionary else {}
    return {"parts":Build.sanitize(job.get("parts", {})),"part_instances":sanitize(job.get("part_instances", {})),
        "layout":"compact" if str(job.get("layout", "tower")) == "compact" else "tower",
        "pc_id":str(marker.get("pc", "")) if marker is Dictionary else "",
        "removed_parts":_strings(job.get("removed_parts", [])),"broken_parts":_strings(job.get("broken_parts", [])),
        "dead_slots":_strings(job.get("dead_slots", [])),"loose_parts":loose(job.get("loose_parts", []))}

static func sanitize_snapshot(raw: Variant) -> Dictionary:
    if not raw is Dictionary or not raw.get("parts", null) is Dictionary: return {}
    return snapshot({"parts":raw["parts"],"part_instances":raw.get("part_instances", {}),"layout":raw.get("layout", "tower"),
        "hardware_trial":{"night_session":{"pc":str(raw.get("pc_id", ""))}},"removed_parts":raw.get("removed_parts", []),
        "broken_parts":raw.get("broken_parts", []),"dead_slots":raw.get("dead_slots", []),"loose_parts":raw.get("loose_parts", [])})

static func _strings(raw: Variant) -> Array:
    var out: Array = []
    if raw is Array:
        for value: Variant in raw:
            if value is String and value.length() < 80 and not value in out: out.append(value)
    return out
