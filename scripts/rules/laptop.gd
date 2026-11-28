# RULES ONLY (pure): laptops (0.59.1, D185). The user, 28 November 2026: "add laptops. they take up less
# space than a desktop and you can choose to store them on top of eachother or on top of desktops. you cannot
# change the case or the motherboard for a laptop. its faster to service and space and airflow constraints are
# more important ... mara comes in with a laptop". Answers: only the RAM and the drive can be changed (the
# processor and graphics are soldered); "faster" means less hands-on work (fewer dusty spots, one heatsink, no
# card to unscrew); stacks are at most 3 high, each laptop fully on what is under it, the top one comes off
# first (storage_model.gd).
#
# A laptop is a job with layout "laptop". Its geometry is PCLayout.laptop(), its dust spots DustZones._laptop(),
# its case and board the catalogue's "laptop" entries (never sold, never swapped). Nothing here stores state.
extends RefCounted

const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")

const FINISHES: Array = ["silver", "graphite"]
const SIZE := Vector2i(6, 4)          # storage footprint in cells (a compact PC is 7 x 5, a tower 8 x 6)
const STACK_MAX: int = 3              # a pile is at most three things high, the desktop at the bottom counting
const RAM_MAX: int = 2
const STORAGE_MAX: int = 1
const BOARD_LOCKED := "A laptop's motherboard is built into the laptop: it does not come out, and the case cannot be swapped."
const SOLDERED := "Soldered to the laptop's motherboard: the processor and graphics chip cannot be changed."
const NO_HDD := "A 3.5-inch hard drive does not fit inside a laptop: use an SSD or an NVMe drive."
const NOT_LAPTOP_PART := "Only memory and a drive can be changed in a laptop."
const NO_OVERCLOCK := "This laptop's BIOS has no overclocking settings."
# 0.59.2 (D186; user: "Storing laptops on top of each other can cause damage, just decide on probability to add";
# and, on 5% a night: "Yes, but it goes up w more laptops on top of each other"). Each morning a laptop with
# things lying on it cracks its lid with a chance of PILE_DAMAGE for every one of them (two on it: 10%). The
# morning report says so; the customer notices at pickup (LID_ANNOYANCE points off, and a complaint). Trial numbers.
const PILE_DAMAGE: float = 0.05
const LID_CRACKED := "lid_cracked"
const LID_ANNOYANCE: float = 35.0


static func pile_damage_chance(on_top: int) -> float:
    return clampf(PILE_DAMAGE * float(maxi(0, on_top)), 0.0, 1.0)


static func pickup_faults(job: Dictionary) -> Array:
    return [LID_CRACKED] if bool(job.get(LID_CRACKED, false)) else []


static func annoyance(faults: Array) -> float:
    return LID_ANNOYANCE * float(faults.count(LID_CRACKED))


static func complaint(fault: String) -> String:
    return "the laptop's lid is cracked" if fault == LID_CRACKED else ""


# Can a catalogue model go into a laptop's free slot? Memory, and a drive that is not a 3.5-inch disk.
static func fits(job: Dictionary, model: String) -> bool:
    return why_not(job, model) == ""


static func why_not(job: Dictionary, model: String) -> String:
    if not PcBuild.is_laptop(job): return ""
    var part: Dictionary = Catalog.part(model)
    var type: String = str(part.get("type", ""))
    if type == Catalog.RAM: return ""
    if type == Catalog.STORAGE: return NO_HDD if str(part.get("kind", "")) == "HDD" else ""
    if type in [Catalog.CPU, Catalog.GPU]: return SOLDERED
    return NOT_LAPTOP_PART


# Turns a fresh job into a laptop: the laptop's own case and board, at most two sticks of memory and one drive
# (a 3.5-inch disk becomes the SSD a laptop would have), one graphics chip, no overclock, and the lid's colour.
static func make(job: Dictionary, finish: String = "graphite") -> Dictionary:
    var p: Dictionary = PcBuild.sanitize(job.get("parts", {}))
    p["ram"] = (p["ram"] as Array).slice(0, RAM_MAX)
    var drives: Array = []
    for id: Variant in p["storage"]:
        if drives.size() >= STORAGE_MAX: break
        drives.append("sto_ssd_500" if str(Catalog.part(str(id)).get("kind", "")) == "HDD" else str(id))
    if drives.is_empty(): drives = ["sto_ssd_500"]
    p["storage"] = drives
    p["gpus"] = [p["gpus"][0]]
    p["board"] = str(Catalog.DEFAULT_BOARD["laptop"])
    p["case"] = str(Catalog.DEFAULT_CASE["laptop"])
    job["layout"] = "laptop"
    job["parts"] = p
    job["pc_specs"] = PcBuild.specs(p)
    job["overclock"] = {"mult": 0, "volt": 0}
    job["laptop_finish"] = finish if finish in FINISHES else "graphite"
    job["gpu_screws"] = 2   # no card to screw in
    return job


static func finish_of(job: Dictionary) -> String:
    var f: String = str(job.get("laptop_finish", "graphite"))
    return f if f in FINISHES else "graphite"
