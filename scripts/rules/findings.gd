# RULES ONLY: the Findings notebook (D150, session 3.4 / 0.47.0). Pure functions.
# Findings keep what the player SAW (observations), what a test MEASURED (measurements) and what the
# player DID (work), each stamped with the shared night clock and the night number. They never hold a
# conclusion, a hint or a hidden fault: every text written here is something the player was shown.
# An observation or measurement taken before the PC changed stays readable, marked outdated.
extends RefCounted

const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const Ids = preload("res://scripts/data/ids.gd")

const OBSERVATION := "observation"
const MEASUREMENT := "measurement"
const WORK := "work"
const KINDS: Array = [OBSERVATION, MEASUREMENT, WORK]
const LIMIT: int = 150          # oldest entries drop off first (a notebook, not an archive)
const TEXT_LIMIT: int = 900
const HEADINGS: Dictionary = {OBSERVATION: "SEEN", MEASUREMENT: "MEASURED", WORK: "DONE"}


# One notebook entry. `sig` is the PC's fingerprint (work_report.gd) when it was written; `until`
# is the end minute of a timed test (-1 for instant entries); `incomplete` marks a stopped test.
static func entry(kind: String, text: String, night: int, minute: int, sig: String, source: String = "", until: int = -1, incomplete: bool = false) -> Dictionary:
    return {"kind": kind if kind in KINDS else WORK, "text": text.strip_edges().left(TEXT_LIMIT), "night": maxi(1, night),
        "minute": maxi(0, minute), "until": until if until >= minute else -1, "sig": sig, "source": source, "incomplete": incomplete}


static func _int(value: Variant, fallback: int) -> int:
    return int(value) if typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) else fallback


# Rebuilds saved entries from known shapes only. Unknown kinds and empty texts are dropped.
static func sanitize(raw: Variant) -> Array:
    var out: Array = []
    if not raw is Array: return out
    for item: Variant in raw:
        if not item is Dictionary: continue
        var kind: String = str(item.get("kind", ""))
        var text: String = str(item.get("text", "")).strip_edges()
        if not kind in KINDS or text == "": continue
        out.append(entry(kind, text, _int(item.get("night", 1), 1), _int(item.get("minute", 0), 0), str(item.get("sig", "")),
            str(item.get("source", "")), _int(item.get("until", -1), -1), item.get("incomplete", false) is bool and bool(item.get("incomplete", false))))
    return out.slice(maxi(0, out.size() - LIMIT))


# Adds an entry. An observation identical to the latest one from the same source, with the PC
# unchanged, is not repeated (opening a bench twice is one look). Returns true when it was added.
static func add(notes: Array, item: Dictionary) -> bool:
    if item["kind"] == OBSERVATION:
        for i in range(notes.size() - 1, -1, -1):
            var old: Dictionary = notes[i]
            if old["kind"] != OBSERVATION or str(old["source"]) != str(item["source"]): continue
            if str(old["text"]) == str(item["text"]) and str(old["sig"]) == str(item["sig"]): return false
            break
    notes.append(item)
    while notes.size() > LIMIT: notes.remove_at(0)
    return true


static func stamp(item: Dictionary) -> String:
    var at: String = "Night %d · %s" % [int(item["night"]), Clock.label(int(item["minute"]))]
    if int(item["until"]) > int(item["minute"]): at += "–" + Clock.label(int(item["until"]))
    return at


# Whether the entry still describes the PC as it is now. Work is history and never goes stale.
static func current(item: Dictionary, sig: String) -> bool:
    return item["kind"] == WORK or str(item["sig"]) == sig


static func line(item: Dictionary, sig: String) -> String:
    var tags: Array = []
    if bool(item["incomplete"]): tags.append("INCOMPLETE")
    if not current(item, sig): tags.append("outdated: the PC changed since")
    var head: String = "[%s] %s" % [HEADINGS[item["kind"]], stamp(item)]
    if not tags.is_empty(): head += " (" + ", ".join(tags) + ")"
    return head + "\n" + str(item["text"])


# The whole notebook as text, newest first, under the customer's complaint. `sig` = current fingerprint.
static func text(job: Dictionary, sig: String) -> String:
    var notes: Array = sanitize(job.get("findings", []))
    var out: String = "FINDINGS · %s\nComplaint: %s\n" % [str(job.get("id", "")), str(job.get("complaint", ""))]
    if notes.is_empty():
        return out + "\nNothing written down yet. Inspections at the benches, the monitor's tests and the work you do are noted here with the night clock."
    var lines: Array = []
    for i in range(notes.size() - 1, -1, -1): lines.append(line(notes[i], sig))
    return out + "\n" + "\n\n".join(lines)


# ---- what is physically in the PC, for work history (model labels and owner, never health) ----

static func _name(id: String) -> String:
    return str(Catalog.part(id).get("name", id))


const SLOT_NAMES: Dictionary = {"cpu": "CPU", "ram_1": "RAM", "ram_2": "RAM", "ram_3": "RAM", "m2_1": "Storage", "m2_2": "Storage", "psu_bay": "PSU", "pcie_2": "GPU 2"}


# One label per part in the PC: "GPU: <model> (customer's)" or "RAM: <model> (your test part, <uid>)".
# Identical models stay separate entries; shop parts carry their own stock id.
static func configuration(job: Dictionary) -> Array:
    var p: Dictionary = PcBuild.sanitize(job.get("parts", {}))
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    var custody: Array = job.get("shop_custody", []) if job.get("shop_custody", []) is Array else []
    var replaced: Dictionary = job.get("service_replacements", {}) if job.get("service_replacements", {}) is Dictionary else {}
    var ids: Dictionary = job.get("service_replacement_ids", {}) if job.get("service_replacement_ids", {}) is Dictionary else {}
    var out: Array = []
    if str(p["cpu"]) != "": out.append("CPU: %s (customer's)" % _name(p["cpu"]))
    for id: Variant in p["ram"]: out.append("RAM: %s (customer's)" % _name(str(id)))
    for id: Variant in p["storage"]: out.append("Storage: %s (customer's)" % _name(str(id)))
    if str(p["psu"]) != "": out.append("PSU: %s (customer's)" % _name(p["psu"]))
    for kind: String in [Ids.GPU, Ids.COOLER]:
        if kind in removed: continue
        var original: String = str(p["gpus"][0]) if kind == Ids.GPU else str(p["cooler"])
        var label: String = "GPU" if kind == Ids.GPU else "Cooler"
        if replaced.has(kind) and kind in custody:
            out.append("%s: %s (your test part, %s)" % [label, _name(PcBuild.model_of(str(replaced[kind]), kind, original)), str(ids.get(kind, "stock"))])
        elif replaced.has(kind):
            out.append("%s: %s (fitted from your stock)" % [label, _name(PcBuild.model_of(str(replaced[kind]), kind, original))])
        else:
            out.append("%s: %s (customer's)" % [label, _name(original)])
    for id: Variant in (p["gpus"] as Array).slice(1): out.append("GPU 2: %s (customer's)" % _name(str(id)))
    var shop: Variant = job.get("shop_fitted", {})
    if shop is Dictionary:
        var slots: Array = (shop as Dictionary).keys()
        slots.sort()
        for slot: Variant in slots:
            var fitted: Variant = shop[slot]
            if not fitted is Dictionary: continue
            out.append("%s: %s (your test part, %s)" % [str(SLOT_NAMES.get(str(slot), str(slot))), _name(str(fitted.get("model", ""))), str(fitted.get("uid", ""))])
    return out


# The parts that left and entered the PC between two configurations (multiset difference), as one
# work-history text, or "" when nothing changed.
static func change_text(before: Array, after: Array) -> String:
    var gone: Array = before.duplicate()
    var added: Array = []
    for label: Variant in after:
        var at: int = gone.find(label)
        if at >= 0: gone.remove_at(at)
        else: added.append(label)
    var lines: Array = []
    for label: Variant in gone: lines.append("Taken out: " + str(label))
    for label: Variant in added: lines.append("Fitted: " + str(label))
    return "\n".join(lines)


# ---- inspections: only what the open bench actually shows ----

const DustZones = preload("res://scripts/data/dust_zones.gd")


# The repair bench with the case open: dust on each part, parts out of the PC, the cooler lever,
# damage the player can see. Nothing about hidden health or how well a mount was made.
static func repair_bench_observation(job: Dictionary) -> String:
    var dusty: Array = []
    var clean: Array = []
    var dust: Dictionary = job.get("dust", {}) if job.get("dust", {}) is Dictionary else {}
    for zone: Dictionary in DustZones.zones(str(job.get("layout", "tower"))):
        if clampf(float(dust.get(zone["id"], 0.0)), 0.0, 1.0) >= DustZones.CLEAN_AT: clean.append(str(zone["label"]))
        else: dusty.append(str(zone["label"]))
    var lines: Array = ["Repair bench, case open."]
    lines.append("Dust visible on: " + (", ".join(dusty) if not dusty.is_empty() else "nothing"))
    if not clean.is_empty(): lines.append("Clean: " + ", ".join(clean))
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    for kind: String in [Ids.GPU, Ids.COOLER]:
        if kind in removed: lines.append("%s: out of the PC." % ("Graphics card" if kind == Ids.GPU else "Cooler"))
    if not Ids.COOLER in removed:
        lines.append("Cooler: mounted, lever locked." if str(job.get("paste_grade", "")) != "" else "Cooler: lever not locked.")
    var damaged: Array = job.get("damaged_parts", []) if job.get("damaged_parts", []) is Array else []
    for kind: Variant in damaged: lines.append("%s: visibly damaged." % str(kind).to_upper())
    return "\n".join(lines)


# The hardware bench: which parts are in which places (model labels and owner), empty essentials,
# the customer's parts lying in the drawer and visible damage. Never whether a part works.
static func hardware_bench_observation(job: Dictionary) -> String:
    var lines: Array = ["Hardware bench."]
    lines.append("In the PC: " + "; ".join(configuration(job)))
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    var empty: Array = []
    for line: String in PcBuild.missing(job): empty.append(line.get_slice(":", 0))
    if Ids.GPU in removed: empty.append("GPU slot")
    if Ids.COOLER in removed: empty.append("cooler mount")
    if not empty.is_empty(): lines.append("Empty: " + ", ".join(empty))
    var loose: Array = job.get("loose_parts", []) if job.get("loose_parts", []) is Array else []
    var drawer: Array = []
    for item: Variant in loose:
        if item is Dictionary:
            drawer.append(_name(str(item.get("id", ""))) + (" (visibly damaged)" if bool(item.get("damaged", false)) else ""))
    if not drawer.is_empty(): lines.append("Customer's parts in the drawer: " + ", ".join(drawer))
    var damaged: Array = job.get("damaged_parts", []) if job.get("damaged_parts", []) is Array else []
    for kind: Variant in damaged:
        if not str(kind) in removed: lines.append("%s in the PC: visibly damaged." % str(kind).to_upper())
    return "\n".join(lines)
