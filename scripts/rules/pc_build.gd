# RULES ONLY (pure): a PC's six stats from its parts (Wave 3 session 3.3, D148).
# Performance stats: processing, graphics, RAM, storage. Support stats: the PSU must cover what the
# parts draw (or the PC does not start) and the cooler must remove the CPU's heat (or it runs hot).
# `parts` = {cpu: id, gpus: [ids], ram: [ids], storage: [ids], psu: id, cooler: id} (hardware_catalog.gd).
# The job's serviceable parts (the FIRST GPU and the cooler) can be broken, removed or replaced; the
# job-aware `effective()` applies that. All numbers are trial proposals.
extends RefCounted

const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Ids = preload("res://scripts/data/ids.gd")

const BASE_WATTS: int = 50              # board, fans and drives
const EXTRA_GPU_SHARE: float = 0.5      # each further GPU adds half of what the one before it added
const HEAT_PER_EXCESS_WATT: float = 0.5 # degrees C per watt of CPU heat the cooler cannot remove
# Shown when an old save or a broken record names no parts: the 0.44 demo PC.
const FALLBACK: Dictionary = {"cpu": "cpu_i5_6060", "gpus": ["gpu_gtx1660"], "ram": ["ram_8gb"], "storage": ["sto_hdd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"}
# Service replacement tiers (repair-bench stock) as catalogue models. "similar" = the same model as the
# demo PCs' parts, "budget" = the cheaper one below it (0.44 numbers kept).
const SERVICE_MODELS: Dictionary = {"gpu": {"similar": "gpu_gtx1660", "budget": "gpu_gtx1550ti"}, "cooler": {"similar": "cool_stock_box", "budget": "cool_wraith_stelth"}}


static func _one(raw: Variant, type: String, fallback: String) -> String:
    return str(raw) if Catalog.is_type(str(raw), type) else fallback


static func _many(raw: Variant, type: String, fallback: Array, most: int) -> Array:
    var out: Array = []
    if raw is Array:
        for id: Variant in raw:
            if Catalog.is_type(str(id), type) and out.size() < most: out.append(str(id))
    return out if not out.is_empty() else fallback.duplicate()


# Rebuilds a parts record from known catalogue ids only (unknown ids fall back to the demo part).
static func sanitize(raw: Variant) -> Dictionary:
    var r: Dictionary = raw if raw is Dictionary else {}
    return {"cpu": _one(r.get("cpu", ""), Catalog.CPU, FALLBACK["cpu"]),
        "gpus": _many(r.get("gpus", []), Catalog.GPU, FALLBACK["gpus"], 4),
        "ram": _many(r.get("ram", []), Catalog.RAM, FALLBACK["ram"], 4),
        "storage": _many(r.get("storage", []), Catalog.STORAGE, FALLBACK["storage"], 4),
        "psu": _one(r.get("psu", ""), Catalog.PSU, FALLBACK["psu"]),
        "cooler": _one(r.get("cooler", ""), Catalog.COOLER, FALLBACK["cooler"])}


# Combined graphics of several cards: best first, each next card adds half of the previous share.
static func combined_graphics(scores: Array) -> float:
    var sorted: Array = scores.duplicate()
    sorted.sort()
    sorted.reverse()
    var total: float = 0.0
    var share: float = 1.0
    for s: Variant in sorted:
        total += float(s) * share
        share *= EXTRA_GPU_SHARE
    return total


# Plain stats of a parts record, everything fitted and working.
static func stats(parts: Dictionary) -> Dictionary:
    var p: Dictionary = sanitize(parts)
    return _stats(p["cpu"], p["gpus"], p["ram"], p["storage"], p["psu"], p["cooler"])


static func _stats(cpu: String, gpus: Array, ram: Array, storage: Array, psu: String, cooler: String) -> Dictionary:
    var c: Dictionary = Catalog.part(cpu)
    var graphics: Array = []
    var draw: int = BASE_WATTS + (int(c.get("watts", 0)) if not c.is_empty() else 0)
    for id: String in gpus:
        var g: Dictionary = Catalog.part(id)
        graphics.append(int(g["graphics"]))
        draw += int(g["watts"])
    var ram_gb: int = 0
    for id: String in ram: ram_gb += int(Catalog.part(id)["gb"])
    var storage_gb: int = 0
    for id: String in storage: storage_gb += int(Catalog.part(id)["gb"])
    var psu_w: int = int(Catalog.part(psu).get("watts", 0)) if psu != "" else 0
    var cpu_heat: int = int(c.get("watts", 0))
    var capacity: int = int(Catalog.part(cooler).get("capacity", 0)) if cooler != "" else 0
    return {"processing": float(c.get("processing", 0)), "graphics": combined_graphics(graphics), "gpu_count": gpus.size(),
        "ram_gb": ram_gb, "storage_gb": storage_gb, "draw_w": draw, "psu_w": psu_w, "powered": psu_w >= draw,
        "cpu_heat_w": cpu_heat, "cooler_w": capacity, "excess_heat_w": maxi(0, cpu_heat - capacity) if cooler != "" else cpu_heat}


# The parts actually in the customer's PC tonight: a replacement replaces the first GPU or the cooler;
# a broken or removed first GPU gives no graphics (other cards still count); no cooler, no cooling.
static func effective_parts(job: Dictionary) -> Dictionary:
    var p: Dictionary = sanitize(job.get("parts", {}))
    var replaced: Dictionary = job.get("service_replacements", {}) if job.get("service_replacements", {}) is Dictionary else {}
    var gpus: Array = (p["gpus"] as Array).duplicate()
    if replaced.has(Ids.GPU): gpus[0] = str(SERVICE_MODELS["gpu"].get(str(replaced[Ids.GPU]), gpus[0]))
    if replaced.has(Ids.COOLER): p["cooler"] = str(SERVICE_MODELS["cooler"].get(str(replaced[Ids.COOLER]), p["cooler"]))
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    var broken: Array = job.get("broken_parts", []) if job.get("broken_parts", []) is Array else []
    if Ids.GPU in removed or Ids.GPU in broken: gpus.remove_at(0)
    if Ids.COOLER in removed or Ids.COOLER in broken: p["cooler"] = ""
    p["gpus"] = gpus
    return p


static func effective(job: Dictionary) -> Dictionary:
    var p: Dictionary = effective_parts(job)
    return _stats(p["cpu"], p["gpus"], p["ram"], p["storage"], p["psu"], p["cooler"])


# Extra degrees from a cooler too small for the CPU (0 when it copes).
static func cooling_heat(job: Dictionary) -> float:
    var s: Dictionary = effective(job)
    if int(s["cooler_w"]) <= 0: return 0.0   # no cooler at all is a missing part, reported elsewhere
    return float(s["excess_heat_w"]) * HEAT_PER_EXCESS_WATT


# The "pc_specs" the fps simulation and the pickup read (processing and RAM of the whole PC).
static func specs(parts: Dictionary) -> Dictionary:
    var s: Dictionary = stats(parts)
    return {"cpu_power": int(s["processing"]), "ram_gb": int(s["ram_gb"])}


# One line per part, with its name, for the ticket and the work tab.
static func part_lines(job: Dictionary) -> Array:
    var p: Dictionary = effective_parts(job)
    var original: Dictionary = sanitize(job.get("parts", {}))
    var lines: Array = []
    lines.append("CPU: %s (%s)" % [Catalog.part(p["cpu"])["name"], Catalog.stat_text(p["cpu"])])
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    var broken: Array = job.get("broken_parts", []) if job.get("broken_parts", []) is Array else []
    var gpus: Array = original["gpus"]
    for i in range(gpus.size()):
        var shown: String = str(gpus[i])
        if i == 0:
            if Ids.GPU in removed or Ids.GPU in broken:
                lines.append("GPU: %s (not working or not fitted)" % Catalog.part(shown)["name"])
                continue
            shown = str((p["gpus"] as Array)[0])
        lines.append("GPU: %s (%s)" % [Catalog.part(shown)["name"], Catalog.stat_text(shown)])
    for id: String in p["ram"]: lines.append("RAM: %s" % Catalog.part(id)["name"])
    for id: String in p["storage"]: lines.append("Storage: %s" % Catalog.part(id)["name"])
    lines.append("PSU: %s (%s)" % [Catalog.part(p["psu"])["name"], Catalog.stat_text(p["psu"])])
    if str(p["cooler"]) != "": lines.append("Cooler: %s (%s)" % [Catalog.part(p["cooler"])["name"], Catalog.stat_text(p["cooler"])])
    else: lines.append("Cooler: %s (not working or not fitted)" % Catalog.part(original["cooler"])["name"])
    return lines


# The six stats on one line.
static func summary_line(job: Dictionary) -> String:
    var s: Dictionary = effective(job)
    return "Processing %d · Graphics %d%s · RAM %d GB · Storage %d GB · PSU %d/%d W · Cooler %d/%d W" % [
        int(s["processing"]), roundi(float(s["graphics"])), " (%d cards)" % int(s["gpu_count"]) if int(s["gpu_count"]) > 1 else "",
        int(s["ram_gb"]), int(s["storage_gb"]), int(s["draw_w"]), int(s["psu_w"]), int(s["cpu_heat_w"]), int(s["cooler_w"])]
