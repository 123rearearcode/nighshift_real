# RULES ONLY: the monitor's "Work + match" tab and the Hardware check (D133). Pure functions.
# The match NEVER peeks at the simulation: it only shows what the player has MEASURED (hardware check,
# game tests, stress tests), and says when a measurement is missing or older than the PC's last change.
# Hidden faults (film, screws, D130/D131) are deliberately not part of any of this.
extends RefCounted

const ServiceParts = preload("res://scripts/data/service_parts.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const PasteMaterials = preload("res://scripts/data/paste_materials.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const Games = preload("res://scripts/data/games.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")

const OK := "[OK] "
const NO := "[NO] "
const UNKNOWN := "[??] "


static func quiet_max() -> float:
    return PickupScore.COOL_TEMP + 10.0


# A short fingerprint of everything a measurement depends on. A stored result with another
# fingerprint is outdated: the PC changed after it was measured.
static func signature(job: Dictionary) -> String:
    var dust: Dictionary = job.get("dust", {})
    var keys: Array = dust.keys()
    keys.sort()
    var text: String = ""
    for key: Variant in keys:
        text += "%s=%.3f;" % [str(key), float(dust[key])]
    var removed: Array = (job.get("removed_parts", []) as Array).duplicate()
    var broken: Array = (job.get("broken_parts", []) as Array).duplicate()
    removed.sort()
    broken.sort()
    var replaced: Dictionary = job.get("service_replacements", {})
    var parts: Array = replaced.keys()
    parts.sort()
    for part: Variant in parts:
        text += "%s:%s;" % [str(part), str(replaced[part])]
    var oc: Dictionary = Overclock.settings(job)
    text += "|%s|%s|%s|%s|%s|%d|%d|%s" % [str(job.get("paste_grade", "")), str(bool(job.get("paste_done", false))), str(job.get("paste_material", "")), ",".join(removed), ",".join(broken), int(oc["mult"]), int(oc["volt"]), Malware.strain(job)]
    return str(text.hash())


static func _number(value: Variant) -> bool:
    return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))


# Rebuilds saved measurements from known shapes only.
static func sanitize_tests(raw: Variant) -> Dictionary:
    var out: Dictionary = {"games": {}}
    if not raw is Dictionary: return out
    var hardware: Variant = raw.get("hardware", null)
    if hardware is Dictionary and hardware.get("ok", null) is bool:
        out["hardware"] = {"ok": bool(hardware["ok"]), "sig": str(hardware.get("sig", ""))}
    var temp: Variant = raw.get("temp", null)
    if temp is Dictionary and _number(temp.get("value", null)):
        out["temp"] = {"value": float(temp["value"]), "sig": str(temp.get("sig", ""))}
    var games: Variant = raw.get("games", null)
    if games is Dictionary:
        for id: Variant in games:
            var entry: Variant = games[id]
            if str(id) in Games.IDS and entry is Dictionary and _number(entry.get("fps", null)) and _number(entry.get("temp", null)):
                out["games"][str(id)] = {"fps": int(entry["fps"]), "temp": float(entry["temp"]), "sig": str(entry.get("sig", ""))}
    return out


# The Hardware check: is every part in place, working, and the cooler locked? Nothing about
# temperature, performance or how WELL anything was installed.
static func hardware_check(job: Dictionary) -> Dictionary:
    var lines: Array = ["CPU and RAM: in place."]
    var ok: bool = true
    for part_id: String in ServiceParts.IDS:
        var s: Dictionary = PartStates.state(job, part_id)
        if bool(s["fitted"]) and bool(s["working"]):
            lines.append("%s: in place and working." % part_id.to_upper())
        else:
            ok = false
            lines.append("%s: %s." % [part_id.to_upper(), str(s["text"])])
    if str(job.get("paste_grade", "")) == "":
        ok = false
        lines.append("COOLER LOCK: not locked. At the repair bench: paste, mount the cooler and click its lever.")
    else:
        lines.append("COOLER LOCK: locked.")
    var head: String = "HARDWARE CHECK PASSED: everything is in place." if ok else "HARDWARE CHECK FAILED: something is missing, broken or not locked."
    return {"ok": ok, "lines": lines, "message": head + "\n\n" + "\n".join(lines) + "\n\nThis check says nothing about temperature or performance: run a game or a stress test for those."}


static func clean_parts(job: Dictionary) -> Array:
    var zones: Array = DustZones.zones(str(job.get("layout", "tower")))
    var done: int = 0
    for zone: Dictionary in zones:
        if clampf(float((job.get("dust", {}) as Dictionary).get(zone["id"], 0.0)), 0.0, 1.0) >= DustZones.CLEAN_AT: done += 1
    return [done, zones.size()]


# What has been done to this PC so far, one line each.
static func work_lines(job: Dictionary) -> Array:
    var lines: Array = []
    var clean: Array = clean_parts(job)
    lines.append("Dust: %d of %d parts clean." % clean)
    var grade: String = str(job.get("paste_grade", ""))
    if grade == "":
        lines.append("Thermal paste: not redone.")
    elif bool(job.get("paste_done", false)):
        lines.append("Thermal paste: redone (%s, %s)." % [grade, str(PasteMaterials.material(str(job.get("paste_material", "thermal"))).get("label", "paste"))])
    else:
        lines.append("Thermal paste: applied, contact not acceptable (%s)." % grade)
    for part_id: String in ServiceParts.IDS:
        var s: Dictionary = PartStates.state(job, part_id)
        if not bool(s["fitted"]): lines.append("%s: taken out." % part_id.to_upper())
        elif not bool(s["working"]): lines.append("%s: still broken." % part_id.to_upper())
        elif str(s["tier"]) != "": lines.append("%s: replaced (%s)." % [part_id.to_upper(), str(s["tier"])])
    var cured: String = Malware.sanitize(job.get("cured", ""))
    if cured != "": lines.append("Anti-virus: removed %s." % str(Malware.STRAINS[cured]["label"]))
    var oc: Dictionary = Overclock.settings(job)
    if int(oc["mult"]) > 0 or int(oc["volt"]) > 0:
        lines.append("Overclock: multiplier +%d, voltage %d." % [int(oc["mult"]), int(oc["volt"])])
    return lines


static func _fresh(entry: Variant, sig: String) -> bool:
    return entry is Dictionary and str(entry.get("sig", "")) == sig


# How the PC, AS MEASURED, matches what the customer asked for. `needs` is the stated need.
static func match_lines(job: Dictionary, needs: Dictionary, pass_limit: float) -> Array:
    var lines: Array = []
    var tests: Dictionary = sanitize_tests(job.get("tests", {}))
    var sig: String = signature(job)
    var hardware: Variant = tests.get("hardware", null)
    if hardware == null:
        lines.append(UNKNOWN + "Working PC: not checked. Run Hardware check.")
    elif not _fresh(hardware, sig):
        lines.append(UNKNOWN + "Working PC: the PC changed since the last Hardware check. Run it again.")
    else:
        lines.append((OK if bool(hardware["ok"]) else NO) + "Working PC: hardware check %s." % ("passed" if bool(hardware["ok"]) else "failed"))
    for target: Dictionary in needs.get("games", []):
        var id: String = str(target.get("game_id", ""))
        var title: String = str(Games.game(id).get("title", id))
        var wanted: int = int(target.get("min_fps", 0))
        var result: Variant = (tests["games"] as Dictionary).get(id, null)
        if result == null:
            lines.append(UNKNOWN + "%s at %d FPS or more: not tested. Run the game (%d night minutes)." % [title, wanted, Clock.GAME_TEST_MINUTES])
        elif not _fresh(result, sig):
            lines.append(UNKNOWN + "%s at %d FPS or more: last test showed %d FPS, but the PC changed since. Test again." % [title, wanted, int(result["fps"])])
        else:
            lines.append((OK if int(result["fps"]) >= wanted else NO) + "%s: %d FPS measured, wanted %d." % [title, int(result["fps"]), wanted])
    var temp: Variant = tests.get("temp", null)
    var stale: bool = temp != null and not _fresh(temp, sig)
    if bool(needs.get("quiet", false)):
        if temp == null: lines.append(UNKNOWN + "Quiet operation: no temperature measured. Run a stress test or a game.")
        elif stale: lines.append(UNKNOWN + "Quiet operation: last reading %.0f°C, but the PC changed since. Measure again." % float(temp["value"]))
        else: lines.append((OK if float(temp["value"]) <= quiet_max() else NO) + "Quiet operation: %.0f°C under load (quiet up to %.0f°C)." % [float(temp["value"]), quiet_max()])
    if temp == null: lines.append(UNKNOWN + "Temperature: not measured. Run a stress test or a game.")
    elif stale: lines.append(UNKNOWN + "Temperature: last reading %.0f°C, but the PC changed since." % float(temp["value"]))
    else: lines.append((OK if float(temp["value"]) < pass_limit else NO) + "Temperature: %.0f°C under load (limit %.0f°C)." % [float(temp["value"]), pass_limit])
    return lines


static func text(job: Dictionary, needs: Dictionary, pass_limit: float) -> String:
    return "WORK DONE\n" + "\n".join(work_lines(job)) + "\n\nMATCH TO THE REQUEST\n" + "\n".join(match_lines(job, needs, pass_limit))
