# RULES ONLY: the customer's PC as the hardware bench sees it (D131, closing the "two PCs" gap of
# BUGS.md RC-1). The ticket's job is the single record: this script PROJECTS it into bench parts and
# a board layout, and APPLIES bench moves back. Nothing here stores a second copy of the PC.
# Pure functions: no scene, no input, no drawing, no save IO.
extends RefCounted

const Ids = preload("res://scripts/data/ids.gd")
const ComponentData = preload("res://scripts/data/component_data.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")

const PREFIX := "customer_"
const SLOT_OF: Dictionary = {Ids.GPU: "pcie", Ids.COOLER: "cooler_mount"}
const RAM_SLOTS: Array = ["ram_1", "ram_2", "ram_3"]
const FIXED: Array = ["cpu", "ram"]   # shown fitted and locked: this ticket gives the bench no CPU/RAM changes (yet)


static func uid(job: Dictionary, part: String) -> String:
    return "%s%s_%s" % [PREFIX, str(job.get("id", "job")), part]


static func is_customer(part_uid: String) -> bool:
    return part_uid.begins_with(PREFIX)


# "gpu" / "cooler" / "cpu" / "ram_a" ... from a customer uid ("customer_<ticket>_<part>").
static func part_of(part_uid: String) -> String:
    var pieces: PackedStringArray = part_uid.split("_")
    if pieces.size() < 3: return ""
    var tail: String = pieces[pieces.size() - 1]
    if tail in ["a", "b", "c"] and pieces[pieces.size() - 2] == "ram": return "ram"
    return tail


static func is_fixed(part_uid: String) -> bool:
    return is_customer(part_uid) and part_of(part_uid) in FIXED


static func ram_sticks(job: Dictionary) -> int:
    var gb: int = int((job.get("pc_specs", {}) as Dictionary).get("ram_gb", 8))
    return clampi(int(ceil(float(gb) / 8.0)), 1, RAM_SLOTS.size())


# The customer's parts as bench components. Order matters: CPU first (the cooler mount needs it),
# RAM, then GPU and cooler (the two that can travel to the drawer).
static func components(job: Dictionary) -> Array:
    var out: Array = []
    var cpu: Dictionary = ComponentData.cpu_chip()
    cpu["id"] = uid(job, "cpu")
    cpu["display_name"] = "Customer's CPU"
    cpu["details"] = [["Owner", "Customer's PC"], ["Condition", "working"], ["Note", "Fixed in this ticket"]]
    out.append(cpu)
    var letters: Array = ["a", "b", "c"]
    for i in range(ram_sticks(job)):
        var ram: Dictionary = ComponentData.ram_stick()
        ram["id"] = uid(job, "ram_" + str(letters[i]))
        ram["display_name"] = "Customer's RAM"
        ram["details"] = [["Owner", "Customer's PC"], ["Condition", "working"], ["Note", "Fixed in this ticket"]]
        out.append(ram)
    for part: String in [Ids.GPU, Ids.COOLER]:
        out.append(service_component(job, part))
    return out


static func service_component(job: Dictionary, part: String) -> Dictionary:
    var tier: String = str((job.get("service_replacements", {}) as Dictionary).get(part, "similar"))
    var component: Dictionary = ServiceParts.component(uid(job, part), part, tier)
    var replaced: bool = (job.get("service_replacements", {}) as Dictionary).has(part)
    var label: String = "GPU" if part == Ids.GPU else "cooler"
    component["display_name"] = ("Replacement " if replaced else "Customer's ") + label
    var broken: bool = part in (job.get("broken_parts", []) as Array)
    var details: Array = [["Owner", "Customer's PC"], ["Condition", "BROKEN" if broken else "working"]]
    if part == Ids.GPU:
        details.append(["Screws", "tight" if int(job.get("gpu_screws", 2)) >= 2 else "NOT tight"])
    component["details"] = details
    return component


static func is_broken(job: Dictionary, part_uid: String) -> bool:
    var part: String = part_of(part_uid)
    return part in (job.get("broken_parts", []) as Array)


# Where each customer part sits NOW: fitted parts on their slot; removed GPU/cooler in the drawer at the
# cell the player left them (`saved`: job["hardware_trial"]["bench"]) or the first free cell.
static func placements(job: Dictionary, saved: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    out[uid(job, "cpu")] = {"location": "cpu", "cell": [0, 0], "rotation": 0}
    var letters: Array = ["a", "b", "c"]
    for i in range(ram_sticks(job)):
        out[uid(job, "ram_" + str(letters[i]))] = {"location": RAM_SLOTS[i], "cell": [0, 0], "rotation": 0}
    for part: String in [Ids.GPU, Ids.COOLER]:
        var key: String = uid(job, part)
        if part in (job.get("removed_parts", []) as Array):
            var memory: Variant = saved.get(key, {})
            if memory is Dictionary and str(memory.get("location", "")) == "drawer":
                out[key] = memory
        else:
            out[key] = {"location": SLOT_OF[part], "cell": [0, 0], "rotation": 0}
    return out


# Is `part` (gpu / cooler) sitting on its slot in this bench snapshot (uid -> {location,...})?
static func fitted_in(job: Dictionary, snapshot: Dictionary, part: String) -> bool:
    var entry: Variant = snapshot.get(uid(job, part), {})
    return entry is Dictionary and str(entry.get("location", "drawer")) == SLOT_OF[part]


# Only the drawer positions of the customer's loose parts are worth remembering (fitted ones are
# derived from the job every time).
static func memory(job: Dictionary, snapshot: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    for part: String in [Ids.GPU, Ids.COOLER]:
        var key: String = uid(job, part)
        var entry: Variant = snapshot.get(key, {})
        if entry is Dictionary and str(entry.get("location", "")) == "drawer":
            out[key] = {"location": "drawer", "cell": (entry.get("cell", [0, 0]) as Array).duplicate(), "rotation": int(entry.get("rotation", 0))}
    return out
