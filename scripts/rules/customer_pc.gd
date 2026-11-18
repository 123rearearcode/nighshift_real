# RULES ONLY: the customer's PC as the hardware bench sees it (D131, closing the "two PCs" gap of
# BUGS.md RC-1). The ticket's job is the single record: this script PROJECTS it into bench parts and
# a board layout, and turns a bench snapshot back into the job's parts (`apply`). Nothing here stores a
# second copy of the PC. Pure functions: no scene, no input, no drawing, no save IO.
# 0.46.0 (Wave 3 session 3.3b, D149): every part type can come out. CPU, RAM, storage, PSU and a second
# GPU live in job["parts"] (what is fitted) and job["loose_parts"] (the customer's parts lying in the
# drawer, outside the PC). The FIRST GPU and the cooler keep their repair-bench service state
# (removed_parts / broken_parts / service_replacements), because the repair bench works on them.
extends RefCounted

const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Ids = preload("res://scripts/data/ids.gd")
const ComponentData = preload("res://scripts/data/component_data.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")

const PREFIX := "customer_"
const SLOT_OF: Dictionary = {Ids.GPU: "pcie", Ids.COOLER: "cooler_mount"}
const RAM_SLOTS: Array = ["ram_1", "ram_2", "ram_3"]
const STORAGE_SLOTS: Array = ["m2_1", "m2_2"]
const CPU_SLOT := "cpu"
const PSU_SLOT := "psu_bay"
const GPU2_SLOT := "pcie_2"
const LETTERS: Array = ["a", "b", "c"]
const FIXED: Array = []   # 0.46.0: nothing is locked any more


static func uid(job: Dictionary, part: String) -> String:
    return "%s%s_%s" % [PREFIX, str(job.get("id", "job")), part]


static func is_customer(part_uid: String) -> bool:
    return part_uid.begins_with(PREFIX)


# The part kind a customer uid stands for: cpu, ram, storage, psu, gpu, gpu_2, cooler or loose.
static func part_of(part_uid: String) -> String:
    var pieces: PackedStringArray = part_uid.split("_")
    if pieces.size() < 3: return ""
    var tail: String = pieces[pieces.size() - 1]
    var before: String = pieces[pieces.size() - 2]
    if tail in LETTERS and before in ["ram", "storage"]: return before
    if tail.is_valid_int() and before == "loose": return "loose"
    if tail == "2" and before == "gpu": return "gpu_2"
    return tail


static func is_fixed(part_uid: String) -> bool:
    return is_customer(part_uid) and part_of(part_uid) in FIXED


static func parts(job: Dictionary) -> Dictionary:
    return PcBuild.sanitize(job.get("parts", {}))


# The customer's parts lying outside the PC: [{id, broken, damaged, original_of}], known ids only.
# broken = hidden truth (never shown); damaged = visible damage the player caused; original_of = "gpu" /
# "cooler" when a shop part took its place in the first slot (0.46.2, D150 custody).
static func loose(job: Dictionary) -> Array:
    var out: Array = []
    var raw: Variant = job.get("loose_parts", [])
    if raw is Array:
        for entry: Variant in raw:
            if entry is Dictionary and not Catalog.part(str(entry.get("id", ""))).is_empty():
                var of: String = str(entry.get("original_of", ""))
                out.append({"id": str(entry["id"]), "broken": bool(entry.get("broken", false)), "damaged": bool(entry.get("damaged", false)),
                    "original_of": of if of in [Ids.GPU, Ids.COOLER] else ""})
    return out


static func ram_sticks(job: Dictionary) -> int:
    return mini((parts(job)["ram"] as Array).size(), RAM_SLOTS.size())


# The catalogue id behind a customer uid in this job ("" when unknown).
static func catalog_id(job: Dictionary, part_uid: String) -> String:
    var p: Dictionary = parts(job)
    var replaced: Dictionary = job.get("service_replacements", {}) if job.get("service_replacements", {}) is Dictionary else {}
    var kind: String = part_of(part_uid)
    var tail: String = part_uid.get_slice("_", part_uid.get_slice_count("_") - 1)
    match kind:
        "cpu": return str(p["cpu"])
        "psu": return str(p["psu"])
        "ram":
            var i: int = LETTERS.find(tail)
            return str(p["ram"][i]) if i >= 0 and i < (p["ram"] as Array).size() else ""
        "storage":
            var i: int = LETTERS.find(tail)
            return str(p["storage"][i]) if i >= 0 and i < (p["storage"] as Array).size() else ""
        "gpu": return PcBuild.model_of(str(replaced.get(Ids.GPU, "")), "gpu", str(p["gpus"][0]))
        "gpu_2": return str(p["gpus"][1]) if (p["gpus"] as Array).size() > 1 else ""
        "cooler": return PcBuild.model_of(str(replaced.get(Ids.COOLER, "")), "cooler", str(p["cooler"]))
        "loose":
            var i: int = int(tail)
            var list: Array = loose(job)
            return str(list[i]["id"]) if i >= 0 and i < list.size() else ""
    return ""


# The catalogue model of a customer part as it is in the PC now (a replacement shows its own model).
static func model_name(job: Dictionary, part: String) -> String:
    var id: String = catalog_id(job, uid(job, part))
    return "%s (%s)" % [Catalog.part(id)["name"], Catalog.stat_text(id)] if id != "" else ""


# D150: a hover card shows model, owner and where it is; never hidden health. Visible damage the
# player caused is the one condition it may name.
static func _customer_part(job: Dictionary, key: String, id: String, damaged: bool, where: String) -> Dictionary:
    var component: Dictionary = Catalog.component(uid(job, key), id)
    component["display_name"] = "Customer's " + str(Catalog.TYPE_LABELS[str(Catalog.part(id)["type"])]).to_lower()
    component["details"] = [["Model", "%s (%s)" % [Catalog.part(id)["name"], Catalog.stat_text(id)]], ["Owner", "Customer's"], ["Where", where]]
    if damaged: component["details"].append(["Condition", "DAMAGED (you broke it)"])
    return component


# The customer's parts as bench components. Order matters for restoring the layout: the CPU first (the
# cooler mount needs it), then the other fitted parts, the loose ones, and the GPU and cooler last (the
# hardware bench inserts the shop stock just before those two).
static func components(job: Dictionary) -> Array:
    var out: Array = []
    var p: Dictionary = parts(job)
    if str(p["cpu"]) != "": out.append(_customer_part(job, "cpu", str(p["cpu"]), false, "In the PC"))
    for i in range(ram_sticks(job)): out.append(_customer_part(job, "ram_" + str(LETTERS[i]), str(p["ram"][i]), false, "In the PC"))
    for i in range(mini((p["storage"] as Array).size(), STORAGE_SLOTS.size())): out.append(_customer_part(job, "storage_" + str(LETTERS[i]), str(p["storage"][i]), false, "In the PC"))
    if str(p["psu"]) != "": out.append(_customer_part(job, "psu", str(p["psu"]), false, "In the PC"))
    if (p["gpus"] as Array).size() > 1: out.append(_customer_part(job, "gpu_2", str(p["gpus"][1]), false, "In the PC (second card)"))
    var list: Array = loose(job)
    for i in range(list.size()): out.append(_customer_part(job, "loose_" + str(i), str(list[i]["id"]), bool(list[i]["damaged"]), "Out of the PC" + (" (a part from your stock is in its place)" if str(list[i]["original_of"]) != "" else "")))
    for part: String in [Ids.GPU, Ids.COOLER]:
        out.append(service_component(job, part))
    return out


static func service_component(job: Dictionary, part: String) -> Dictionary:
    var tier: String = str((job.get("service_replacements", {}) as Dictionary).get(part, "similar"))
    var component: Dictionary = ServiceParts.component(uid(job, part), part, tier)
    if component.is_empty(): component = ServiceParts.component(uid(job, part), part, "similar")
    var replaced: bool = (job.get("service_replacements", {}) as Dictionary).has(part)
    var label: String = "GPU" if part == Ids.GPU else "cooler"
    component["display_name"] = ("Replacement " if replaced else "Customer's ") + label
    var stock_backed: bool = part in (job.get("shop_custody", []) as Array)   # 0.46.2: still the shop's until collection
    var details: Array = [["Model", model_name(job, part)], ["Owner", "Your stock, fitted until the customer collects" if stock_backed else ("Customer's" if not replaced else "Customer's (a replacement)")]]
    if part in (job.get("damaged_parts", []) as Array): details.append(["Condition", "DAMAGED (you broke it)"])
    if part == Ids.GPU:
        details.append(["Screws", "tight" if int(job.get("gpu_screws", 2)) >= 2 else "NOT tight"])
    component["details"] = details
    return component


# HIDDEN truth, for rules only (never for display or permissions).
static func is_broken(job: Dictionary, part_uid: String) -> bool:
    var part: String = part_of(part_uid)
    if part == "loose":
        var i: int = int(part_uid.get_slice("_", part_uid.get_slice_count("_") - 1))
        var list: Array = loose(job)
        return i >= 0 and i < list.size() and bool(list[i]["broken"])
    if part == "gpu_2": return PcBuild.dead_second_card(job)
    return part in (job.get("broken_parts", []) as Array)


# VISIBLE damage the player caused (may be shown).
static func is_damaged(job: Dictionary, part_uid: String) -> bool:
    var part: String = part_of(part_uid)
    if part == "loose":
        var i: int = int(part_uid.get_slice("_", part_uid.get_slice_count("_") - 1))
        var list: Array = loose(job)
        return i >= 0 and i < list.size() and bool(list[i]["damaged"])
    return part in (job.get("damaged_parts", []) as Array)


# Where each customer part sits NOW: fitted parts on their slot; loose parts and a removed GPU/cooler in
# the drawer at the cell the player left them (`saved`: job["hardware_trial"]["bench"]) or the first free cell.
static func placements(job: Dictionary, saved: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    var p: Dictionary = parts(job)
    if str(p["cpu"]) != "": out[uid(job, "cpu")] = {"location": CPU_SLOT, "cell": [0, 0], "rotation": 0}
    for i in range(ram_sticks(job)):
        out[uid(job, "ram_" + str(LETTERS[i]))] = {"location": RAM_SLOTS[i], "cell": [0, 0], "rotation": 0}
    for i in range(mini((p["storage"] as Array).size(), STORAGE_SLOTS.size())):
        out[uid(job, "storage_" + str(LETTERS[i]))] = {"location": STORAGE_SLOTS[i], "cell": [0, 0], "rotation": 0}
    if str(p["psu"]) != "": out[uid(job, "psu")] = {"location": PSU_SLOT, "cell": [0, 0], "rotation": 0}
    if (p["gpus"] as Array).size() > 1: out[uid(job, "gpu_2")] = {"location": GPU2_SLOT, "cell": [0, 0], "rotation": 0}
    var keys: Array = []
    for i in range(loose(job).size()): keys.append(uid(job, "loose_" + str(i)))
    for part: String in [Ids.GPU, Ids.COOLER]:
        if part in (job.get("removed_parts", []) as Array): keys.append(uid(job, part))
        else: out[uid(job, part)] = {"location": SLOT_OF[part], "cell": [0, 0], "rotation": 0}
    for key: String in keys:
        var memory_entry: Variant = saved.get(key, {})
        if memory_entry is Dictionary and str(memory_entry.get("location", "")) == "drawer":
            out[key] = memory_entry
    return out


# Is `part` (gpu / cooler) sitting on its slot in this bench snapshot (uid -> {location,...})?
static func fitted_in(job: Dictionary, snapshot: Dictionary, part: String) -> bool:
    var entry: Variant = snapshot.get(uid(job, part), {})
    return entry is Dictionary and str(entry.get("location", "drawer")) == SLOT_OF[part]


# Only the drawer positions of the customer's loose parts are worth remembering (fitted ones are
# derived from the job every time).
static func memory(job: Dictionary, snapshot: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    for key: String in snapshot:
        if not is_customer(key): continue
        var entry: Variant = snapshot[key]
        if entry is Dictionary and str(entry.get("location", "")) == "drawer":
            out[key] = {"location": "drawer", "cell": (entry.get("cell", [0, 0]) as Array).duplicate(), "rotation": int(entry.get("rotation", 0))}
    return out


# 0.46.0: a bench snapshot back into the job's parts. Every customer part (fitted or loose, except the
# first GPU and the cooler, which keep their service state) goes where the snapshot shows it. A
# customer part dropped on the FIRST GPU slot or the cooler mount is reported in `first` so the state
# can swap it in. Returns {parts, loose_parts, first: {gpu: {id, broken}, cooler: {...}}}.
static func apply(job: Dictionary, snapshot: Dictionary) -> Dictionary:
    var p: Dictionary = parts(job)
    var slot_ids: Dictionary = {}
    var drawer: Array = []
    var first: Dictionary = {}
    for key: String in snapshot:
        if not is_customer(key) or not key.begins_with(uid(job, "")): continue
        var kind: String = part_of(key)
        if kind in [Ids.GPU, Ids.COOLER]: continue
        var id: String = catalog_id(job, key)
        if id == "": continue
        var entry: Dictionary = {"id": id, "broken": is_broken(job, key), "damaged": is_damaged(job, key), "original_of": ""}
        if kind == "loose":
            var i: int = int(key.get_slice("_", key.get_slice_count("_") - 1))
            entry["original_of"] = str(loose(job)[i]["original_of"])
        var location: String = str((snapshot[key] as Dictionary).get("location", "drawer"))
        if location == "drawer": drawer.append(entry)
        elif location == SLOT_OF[Ids.GPU] or location == SLOT_OF[Ids.COOLER]:
            first[Ids.GPU if location == SLOT_OF[Ids.GPU] else Ids.COOLER] = entry
        else: slot_ids[location] = entry
    var out: Dictionary = {"cpu": "", "gpus": [p["gpus"][0]], "ram": [], "storage": [], "psu": "", "cooler": p["cooler"]}
    var dead: Array = []
    # D150 (0.46.2): a part that does not work CAN be fitted (nothing refuses it); it simply does not work.
    for slot: String in slot_ids:
        var entry: Dictionary = slot_ids[slot]
        if slot == CPU_SLOT: out["cpu"] = entry["id"]
        elif slot == PSU_SLOT: out["psu"] = entry["id"]
        elif slot == GPU2_SLOT:
            (out["gpus"] as Array).append(entry["id"])
            if bool(entry["broken"]): dead.append(GPU2_SLOT)
    for slot: String in RAM_SLOTS:
        if slot_ids.has(slot): (out["ram"] as Array).append(slot_ids[slot]["id"])
    for slot: String in STORAGE_SLOTS:
        if slot_ids.has(slot): (out["storage"] as Array).append(slot_ids[slot]["id"])
    return {"parts": out, "loose_parts": drawer, "first": first, "dead_slots": dead}
