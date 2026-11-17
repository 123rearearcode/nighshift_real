# RULES ONLY (pure, no scene or autoload access): the binary state of a customer PC's serviceable
# parts, D115. Every surface that talks about parts reads it - the shop ticket, the old final check,
# the night workshop's diagnosis and ticket - so they can never disagree or leave the player
# without a named next step (BUGS.md B10/B12, RC-1/RC-2). `job` is any job Dictionary.
extends RefCounted

const ServiceParts = preload("res://scripts/data/service_parts.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")

const MISSING_TEXT: String = "MISSING - lying in the repair-bench tray; drag it back or fit a replacement"
const BROKEN_TEXT: String = "BROKEN - at the repair bench: move it to the tray, then open Replacement stock"


# {fitted: bool, working: bool, tier: String, text: String} for one part id.
static func state(job: Dictionary, part_id: String) -> Dictionary:
    var fitted: bool = not part_id in job.get("removed_parts", [])
    var working: bool = not part_id in job.get("broken_parts", [])
    var tier: String = str(job.get("service_replacements", {}).get(part_id, ""))
    var text: String
    if not fitted:
        text = MISSING_TEXT
    elif not working:
        text = BROKEN_TEXT
    else:
        text = "working" + (" (%s replacement)" % tier if tier != "" else "")
    return {"fitted": fitted, "working": working, "tier": tier, "text": text}


# One "GPU: BROKEN - ..." line per part that is not both fitted and working. Empty when all is well.
static func problem_lines(job: Dictionary) -> Array:
    var lines: Array = []
    for part_id: String in ServiceParts.IDS:
        var s: Dictionary = state(job, part_id)
        if not bool(s["fitted"]) or not bool(s["working"]):
            lines.append("%s: %s." % [part_id.to_upper(), str(s["text"])])
    for line: String in PcBuild.missing(job): lines.append(line + ".")   # D149: CPU, RAM, drive, PSU out
    return lines


# Every part on one line, for a ticket: "GPU BROKEN - ... | COOLER working".
static func summary(job: Dictionary) -> String:
    var parts: Array = []
    for part_id: String in ServiceParts.IDS:
        parts.append("%s %s" % [part_id.to_upper(), str(state(job, part_id)["text"])])
    return " | ".join(parts)
