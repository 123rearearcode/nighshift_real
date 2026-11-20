# RULES ONLY (pure, no scene or autoload access): what the player can KNOW about a customer PC's
# serviceable parts. D115 named broken parts outright; D150 (0.46.2) supersedes that: hidden health
# never reaches the player through texts, checks or permissions. Known absence (a part is out) and
# damage the player visibly caused ("damaged_parts") may be shown; a hidden fault only shows through
# what the player would observe (boot_symptoms). `job` is any job Dictionary.
extends RefCounted

const ServiceParts = preload("res://scripts/data/service_parts.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Ids = preload("res://scripts/data/ids.gd")

const MISSING_TEXT: String = "NOT FITTED - it is out of the PC; refit it or fit a part from your stock"
const BUILD_MISSING_TEXT: String = "NOT FITTED YET - fit one from your stock at the hardware bench"
# What a boot attempt shows when a fitted part does not work (D150: observation, never the cause).
const SLOT_SYMPTOMS: Dictionary = {
    "psu": "Nothing happens when you press the power button: no fans, no lights.",
    "ram": "The PC powers on, beeps three times and shows nothing.",
    "storage": "The PC starts, then stops on a black screen: 'No boot device found'.",
}
const SYMPTOMS: Dictionary = {
    Ids.GPU: "The PC powers on and the fans spin, but there is no image on the screen.",
    Ids.COOLER: "The PC powers on, then switches itself off after a few seconds.",
}


# {fitted, working, damaged, tier, text}. `working` is INTERNAL truth for rules; never show it.
static func state(job: Dictionary, part_id: String) -> Dictionary:
    var fitted: bool = not part_id in job.get("removed_parts", [])
    var working: bool = not part_id in job.get("broken_parts", [])
    var damaged: bool = part_id in job.get("damaged_parts", [])
    var tier: String = str(job.get("service_replacements", {}).get(part_id, ""))
    var missing: String = BUILD_MISSING_TEXT if PcBuild.is_build(job) else MISSING_TEXT   # 0.51.0: a build has no original to refit
    var text: String = missing if not fitted else ("fitted" + (" (from your stock)" if PcBuild.is_build(job) else (" (replacement from your stock)" if tier != "" else "")))
    if damaged and fitted: text += ", visibly DAMAGED"
    return {"fitted": fitted, "working": working, "damaged": damaged, "tier": tier, "text": text}


# Known problems only: a part out of the PC, an empty essential slot, visible damage. Empty when none.
static func problem_lines(job: Dictionary) -> Array:
    var lines: Array = []
    for part_id: String in ServiceParts.IDS:
        var s: Dictionary = state(job, part_id)
        if not bool(s["fitted"]) or bool(s["damaged"]):
            lines.append("%s: %s." % [part_id.to_upper(), str(s["text"])])
    for line: String in PcBuild.missing(job): lines.append(line + ".")   # D149: CPU, RAM, drive, PSU out
    return lines


# What a boot attempt shows for fitted parts that do not work. One line per distinct observation.
static func boot_symptoms(job: Dictionary) -> Array:
    var lines: Array = []
    for part_id: String in ServiceParts.IDS:
        var s: Dictionary = state(job, part_id)
        if bool(s["fitted"]) and not bool(s["working"]) and not SYMPTOMS[part_id] in lines: lines.append(SYMPTOMS[part_id])
    # 0.50.0: a dead shop part in a hardware-bench slot (testing bay, D158): fitted, so not "missing",
    # but it does nothing. What the player sees, never which part. A dead PSU hides everything else.
    if PcBuild.missing(job).is_empty():
        var e: Dictionary = PcBuild.effective_parts(job)
        if str(e["psu"]) == "": return [SLOT_SYMPTOMS["psu"]]
        if str(e["cpu"]) == "" and not SYMPTOMS[Ids.GPU] in lines: lines.append(SYMPTOMS[Ids.GPU])
        if (e["ram"] as Array).is_empty(): lines.append(SLOT_SYMPTOMS["ram"])
        if (e["storage"] as Array).is_empty(): lines.append(SLOT_SYMPTOMS["storage"])
    return lines   # a dead SECOND card does not stop the boot: the first card still drives the screen


# Every serviceable part on one line, for a ticket: presence and visible damage only.
static func summary(job: Dictionary) -> String:
    var parts: Array = []
    for part_id: String in ServiceParts.IDS:
        var s: Dictionary = state(job, part_id)
        parts.append("%s %s" % [part_id.to_upper(), ("DAMAGED" if bool(s["damaged"]) else "fitted") if bool(s["fitted"]) else "NOT FITTED"])
    return " | ".join(parts)
