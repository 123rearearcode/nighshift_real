# RULES ONLY: what the shop KNOWS about its own parts, and what the testing bay can find out (session 3.6 /
# 0.50.0, D158). Pure functions. PART_LIFECYCLE invariant 7: actual condition and player knowledge stay
# separate. A stock record's `condition` (working / degraded / broken) and `defect` are hidden truth;
# `known` is the player's side: a label, notes in observation form, the tests done and where the part came
# from. Every text here describes what was seen or measured, never "this part is degraded".
#
# Scam hook kept on purpose (user, 20 November 2026: "leave room for that"): the label is the PLAYER'S
# call and can disagree with the evidence. `known.tests` records what was actually done, so a later scam
# system can tell an honestly tested part from one merely sold as "tested".
# All numbers and texts are trial proposals.
extends RefCounted

const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")

const NEW := "new"             # bought new: known good
const UNTESTED := "untested"   # salvaged, or a customer's old part: nobody knows
const WORKING := "working"     # the player marked it working
const DEGRADED := "degraded"   # the player marked it degraded
const DEAD := "dead"           # the player marked it dead, or damaged it themselves
const LABELS: Array = [NEW, UNTESTED, WORKING, DEGRADED, DEAD]
const PLAYER_LABELS: Array = [WORKING, DEGRADED, DEAD]
const LABEL_TEXT: Dictionary = {NEW: "New", UNTESTED: "Untested", WORKING: "Marked working", DEGRADED: "Marked degraded", DEAD: "Marked dead"}
const NOTES_KEEP: int = 30

const INSPECT_MINUTES: int = 1
const QUICK_MINUTES: int = 5
const LONG_MINUTES: int = 20
const SCRAP: Dictionary = {"gpu": 8, "cpu": 5, "psu": 4, "storage": 3, "ram": 2, "cooler": 2}
const JUNK_SCRAP: int = 1      # salvage finds the shop cannot stock (fans, cards, boards, whole PCs)

const UNSTABLE_FAULT := "part_unstable"   # delayed: a crashing part left in a customer's PC (comes back)


static func fresh(label: String, source: String) -> Dictionary:
    return {"label": label if label in LABELS else UNTESTED, "notes": [], "tests": [], "source": source.left(120)}


# Rebuilds saved knowledge. Old records without it: a broken one was damaged by the player (known
# dead); anything else was bought or given at start (new).
static func sanitize_known(raw: Variant, condition: String) -> Dictionary:
    var fallback: String = DEAD if condition == PcBuild.BROKEN else NEW
    if not raw is Dictionary: return fresh(fallback, "")
    var r: Dictionary = raw
    var label: String = str(r.get("label", fallback))
    var out: Dictionary = fresh(label if label in LABELS else fallback, str(r.get("source", "")))
    for key: String in ["notes", "tests"]:
        var list: Variant = r.get(key, [])
        if list is Array:
            for item: Variant in list:
                var text: String = str(item).strip_edges().left(240)
                if text != "" and not text in out[key]: (out[key] as Array).append(text)
        out[key] = (out[key] as Array).slice(maxi(0, (out[key] as Array).size() - NOTES_KEEP))
    return out


static func sanitize_condition(raw: Variant) -> String:
    var c: String = str(raw)
    return c if c in [PcBuild.WORKING, PcBuild.DEGRADED, PcBuild.BROKEN] else PcBuild.WORKING


static func sanitize_defect(kind: String, condition: String, raw: Variant) -> String:
    if condition != PcBuild.DEGRADED: return ""
    return str(PcBuild.DEFECTS.get(kind, ""))   # one defect per kind


static func known(record: Dictionary) -> Dictionary:
    return sanitize_known(record.get("known", null), sanitize_condition(record.get("condition", "working")))


# Can the player use it (drawer, fitting, tests)? Their own "dead" call takes it out of use. The real
# condition is never consulted here, so a part does not vanish because of something hidden.
static func usable(record: Dictionary) -> bool:
    return str(known(record)["label"]) != DEAD


# Counted as a known-good spare by the solvability proof (diagnosis.gd): new, or tested and marked working.
static func known_good(record: Dictionary) -> bool:
    return str(known(record)["label"]) in [NEW, WORKING]


static func label_text(record: Dictionary) -> String:
    return str(LABEL_TEXT[known(record)["label"]])


# The hover/inspection summary: the label, where it came from, the latest notes.
static func describe(record: Dictionary, notes: int = 3) -> String:
    var k: Dictionary = known(record)
    var lines: Array = [str(LABEL_TEXT[k["label"]])]
    if str(k["source"]) != "": lines.append(str(k["source"]))
    var list: Array = k["notes"]
    for note: Variant in list.slice(maxi(0, list.size() - notes)): lines.append("· " + str(note))
    return "\n".join(lines)


static func scrap_value(kind: String) -> int:
    return int(SCRAP.get(kind, JUNK_SCRAP))


# ---- physical inspection: spots on the part, and what each one shows ----

const SPOTS: Dictionary = {
    "gpu": ["Fans", "Power connector", "PCIe contacts", "Capacitors", "Back plate"],
    "cpu": ["Contact pads", "Heat spreader", "Edges"],
    "ram": ["Gold contacts", "Memory chips", "Label"],
    "psu": ["Fan grille", "Cable ends", "Smell", "Case vents"],
    "cooler": ["Fan blades", "Fins", "Base plate", "Fan cable"],
    "storage": ["Connector", "Label", "Casing"],
}
# kind -> condition -> [spot, what it shows]. A tell is not guaranteed (see CLUE_CHANCE).
const TELLS: Dictionary = {
    "gpu": {"broken": ["Power connector", "A scorched, brown mark around the power connector."], "degraded": ["Capacitors", "Two capacitors look slightly domed on top."]},
    "cpu": {"broken": ["Contact pads", "A dark burn spot on two of the contact pads."], "degraded": ["Heat spreader", "The heat spreader is discoloured, as if it ran very hot for a long time."]},
    "ram": {"broken": ["Memory chips", "One memory chip has a tiny crack across it."], "degraded": ["Gold contacts", "The gold contacts are dull and slightly green."]},
    "psu": {"broken": ["Smell", "It smells of burnt electronics."], "degraded": ["Fan grille", "The fan grille is caked with dust; the fan turns stiffly by hand."]},
    "cooler": {"broken": ["Fan cable", "The fan cable is cut halfway through."], "degraded": ["Fan blades", "One fan blade is chipped and the fan wobbles when spun."]},
    "storage": {"broken": ["Casing", "The casing is dented, as if it was dropped."], "degraded": ["Label", "A handwritten note on the label: 'slow??'"]},
}
const RED_HERRINGS: Dictionary = {
    "gpu": ["Back plate", "Scratches and a sticker residue on the back plate."], "cpu": ["Edges", "Old thermal paste dried on the edges."],
    "ram": ["Label", "The label is half peeled off."], "psu": ["Cable ends", "Cable sleeves are frayed at the ends."],
    "cooler": ["Fins", "Dust between the fins."], "storage": ["Connector", "A little dust in the connector."],
}
const CLUE_CHANCE: Dictionary = {"broken": 0.7, "degraded": 0.55, "working": 0.2}
const NEUTRAL: String = "Nothing unusual."


static func spots(kind: String) -> Array:
    return SPOTS.get(kind, ["Surface"])


# 0.56.0 (D162): whether a spot is looked at through the magnifying glass. The user: "depends on the
# faults; there will be multiple types". Today every spot needs the lens; a later fault type that shows to
# the bare eye (a smell, a dented casing) can return false here and be inspected another way.
static func needs_lens(_kind: String, _spot: String) -> bool:
    return true


# Whether this particular part shows its tell at all (fixed per part: looking twice changes nothing).
static func _shows_tell(uid: String, condition: String) -> bool:
    var r := RandomNumberGenerator.new()
    r.seed = hash("tell:" + uid)
    return r.randf() < float(CLUE_CHANCE.get(condition, 0.0))


static func spot_text(record: Dictionary, spot: String) -> String:
    var kind: String = str(record.get("kind", ""))
    var condition: String = sanitize_condition(record.get("condition", "working"))
    var uid: String = str(record.get("uid", ""))
    if condition != PcBuild.WORKING and _shows_tell(uid, condition):
        var tell: Array = (TELLS.get(kind, {}) as Dictionary).get(condition, [])
        if tell.size() == 2 and str(tell[0]) == spot: return str(tell[1])
    if condition == PcBuild.WORKING and _shows_tell(uid, "working"):
        var herring: Array = RED_HERRINGS.get(kind, [])
        if herring.size() == 2 and str(herring[0]) == spot: return str(herring[1])
    return NEUTRAL


# ---- rig tests: a quick check and a long run, per kind. Observations with numbers. ----
# A quick check finds dead parts and the steady degradations (heat, weak output, slow reads); the
# intermittent ones (GPU artifacts, memory errors) only show in a long run.

const RESULTS: Dictionary = {
    "gpu": {"working": ["Render test: steady image, 0 errors, 64°C.", "Long render: steady image for 20 minutes, peak 71°C."],
        "artifacts": ["Render test: steady image, 0 errors, 66°C.", "Long render: coloured blocks flickered after 12 minutes, then the driver crashed."],
        "broken": ["Render test: no signal from the card; its fans never spin.", "Long render: no signal from the card."]},
    "ram": {"working": ["Memory test, pass 1: 0 errors.", "Memory test, 4 passes: 0 errors."],
        "errors": ["Memory test, pass 1: 0 errors.", "Memory test, 4 passes: 7 errors in pass 3, always at the same addresses."],
        "broken": ["The rig beeps three times: the stick is not detected.", "The rig beeps three times: the stick is not detected."]},
    "cpu": {"working": ["Five-minute load on the rig: 68°C, steady.", "Twenty-minute load: 72°C, steady clocks."],
        "hot": ["Five-minute load on the rig: 83°C and climbing.", "Twenty-minute load: 89°C, clocks dropping (throttling)."],
        "broken": ["The rig's fans spin but there is no image.", "The rig's fans spin but there is no image."]},
    "cooler": {"working": ["Fan spins evenly; it holds the rig CPU at 61°C.", "Twenty minutes: the rig CPU stays at 63°C."],
        "weak": ["Fan spins unevenly; the rig CPU reaches 79°C.", "Twenty minutes: the rig CPU climbs to 86°C."],
        "broken": ["The fan does not spin; the rig switched itself off at 95°C.", "The fan does not spin; the rig switched itself off."]},
    "psu": {"working": ["PSU tester: all rails in range; full label output under load.", "Twenty minutes at full load: rails steady."],
        "weak": ["PSU tester: rails sag at about 70% of the label output; it clicks under full load.", "Twenty minutes: rails sag from 70% of the label and the fan screams."],
        "broken": ["PSU tester: no output at all.", "PSU tester: no output at all."]},
    "storage": {"working": ["Drive health: good; normal read speed.", "Full surface scan: no bad sectors."],
        "slow": ["Drive health: 41 reallocated sectors; reads at a third of the normal speed.", "Full surface scan: 41 reallocated sectors, slow reads throughout."],
        "broken": ["The drive is not detected.", "The drive is not detected."]},
}
const TEST_NAMES: Dictionary = {"gpu": "render test", "ram": "memory test", "cpu": "load test", "cooler": "cooling test", "psu": "PSU tester", "storage": "drive health check"}


static func test_name(kind: String, long_test: bool) -> String:
    return ("Long " if long_test else "Quick ") + str(TEST_NAMES.get(kind, "test"))


static func test_result(record: Dictionary, long_test: bool) -> String:
    var kind: String = str(record.get("kind", ""))
    var condition: String = sanitize_condition(record.get("condition", "working"))
    var key: String = "working"
    if condition == PcBuild.BROKEN: key = "broken"
    elif condition == PcBuild.DEGRADED: key = str(PcBuild.DEFECTS.get(kind, ""))
    var table: Dictionary = RESULTS.get(kind, {})
    var pair: Array = table.get(key, table.get("working", ["Test finished.", "Test finished."]))
    return str(pair[1 if long_test else 0])


# ---- consequences for a customer who takes a crashing part home ----

static func pickup_faults(job: Dictionary) -> Array:
    return [UNSTABLE_FAULT] if PcBuild.unstable_minute(job) >= 0 else []


static func annoyance(faults: Array) -> float:
    return 25.0 if UNSTABLE_FAULT in faults else 0.0


static func complaint(fault: String) -> String:
    return "it crashes at random during games, and the screen sometimes flickers" if fault == UNSTABLE_FAULT else ""
