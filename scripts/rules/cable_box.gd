# RULES (0.58.3, D173): the cable box. Pure data in, data out; no drawing, no files.
# User, 27 November 2026: the cables live in a "cable box" that "can be moved from room to room" (one box;
# the first piece of multi-room inventory management, automated later through the van's trunk / outside);
# it is "openable" and shows "the cables in their state"; "Tangles happen when the box is moved and there
# are loose cables inside"; untangling is physics-based (scripts/view/cable_box_view.gd); the shop sells
# things that help; and cables "can break".
#
# A knot holds two cables together. Each cable can slip out of a knot only through ONE of its ends (its
# "open" end): pulling that end slides the knot along the cable and off it; pulling the other end tightens
# the knot, and pulled too hard the cable snaps. Tied cables (zip tie or velcro strap) never tangle.
extends RefCounted

const VERSION: int = 1
const KINDS: Dictionary = {
    "atx24": {"label": "24-pin motherboard cable", "points": 24, "width": 10.0},
    "pcie8": {"label": "8-pin graphics card cable", "points": 18, "width": 7.0},
}
# Where the box can stand. (Automation will later carry it through the van's trunk; not built.)
const ROOMS: Dictionary = {"counter": "the counter", "workshop": "the workshop", "outside": "the van outside"}
const START_ROOM := "workshop"
const STARTER: Array = [["c1", "atx24"], ["c2", "atx24"], ["c3", "pcie8"], ["c4", "pcie8"], ["c5", "pcie8"]]
# Sold at the store down the street (scripts/night/shop_activity_view.gd).
const SUPPLIES: Dictionary = {
    "zip_ties": {"label": "Zip ties (pack of 10)", "price": 4, "count": 10, "blurb": "Tie a cable so it never tangles. Cutting one off uses it up."},
    "velcro": {"label": "Velcro straps (pack of 4)", "price": 12, "count": 4, "blurb": "Reusable straps: untie a cable and the strap goes back in the box."},
}
const MAX_KNOTS_PER_PAIR: int = 2
const BREAK_STRAIN: float = 1.0


static func fresh(run: String = "") -> Dictionary:
    var cables: Array = []
    for entry: Array in STARTER:
        cables.append({"id": str(entry[0]), "kind": str(entry[1]), "tie": "", "broken": false})
    return {"version": VERSION, "run": run, "room": START_ROOM, "carried": false, "moves": 0, "cables": cables, "knots": [],
        "zip_ties": 0, "velcro": 0}


# A loaded state, checked field by field; anything unusable falls back to a fresh box.
static func sanitize(raw: Variant, run: String = "") -> Dictionary:
    if not raw is Dictionary or int(raw.get("version", 0)) != VERSION: return fresh(run)
    var state: Dictionary = fresh(run)
    state["room"] = str(raw.get("room", START_ROOM)) if ROOMS.has(str(raw.get("room", ""))) else START_ROOM
    state["carried"] = bool(raw.get("carried", false))
    state["moves"] = maxi(0, int(raw.get("moves", 0)))
    state["zip_ties"] = maxi(0, int(raw.get("zip_ties", 0)))
    state["velcro"] = maxi(0, int(raw.get("velcro", 0)))
    var cables: Array = []
    var ids: Dictionary = {}
    if raw.get("cables", null) is Array:
        for c: Variant in raw["cables"]:
            if not c is Dictionary or not KINDS.has(str(c.get("kind", ""))): continue
            var id: String = str(c.get("id", ""))
            if id == "" or ids.has(id): continue
            var tie: String = str(c.get("tie", ""))
            cables.append({"id": id, "kind": str(c["kind"]), "tie": tie if tie in ["", "zip", "velcro"] else "", "broken": bool(c.get("broken", false))})
            ids[id] = true
    state["cables"] = cables
    var knots: Array = []
    if raw.get("knots", null) is Array:
        for k: Variant in raw["knots"]:
            if not k is Dictionary: continue
            var a: String = str(k.get("a", "")); var b: String = str(k.get("b", ""))
            if a == b or not ids.has(a) or not ids.has(b): continue
            knots.append({"a": a, "b": b, "open_a": clampi(int(k.get("open_a", 0)), 0, 1), "open_b": clampi(int(k.get("open_b", 0)), 0, 1),
                "at_a": clampf(float(k.get("at_a", 0.5)), 0.0, 1.0), "at_b": clampf(float(k.get("at_b", 0.5)), 0.0, 1.0),
                "strain": clampf(float(k.get("strain", 0.0)), 0.0, BREAK_STRAIN)})
    state["knots"] = knots
    for c: Dictionary in cables:      # a tied or broken cable is never in a knot
        if c["tie"] != "" or c["broken"]: _drop_knots(state, str(c["id"]))
    return state


static func cable(state: Dictionary, id: String) -> Dictionary:
    for c: Dictionary in state["cables"]:
        if c["id"] == id: return c
    return {}


# Cables lying loose in the box: not tied, not broken. Only these can tangle.
static func loose(state: Dictionary) -> Array:
    return (state["cables"] as Array).filter(func(c: Dictionary) -> bool: return c["tie"] == "" and not c["broken"]).map(func(c: Dictionary) -> String: return str(c["id"]))


static func knots_of(state: Dictionary, id: String) -> Array:
    var found: Array = []
    for i in range((state["knots"] as Array).size()):
        var k: Dictionary = state["knots"][i]
        if k["a"] == id or k["b"] == id: found.append(i)
    return found


static func is_free(state: Dictionary, id: String) -> bool:
    return knots_of(state, id).is_empty()


# ---- moving the box ----

static func pick_up(state: Dictionary) -> void:
    state["carried"] = true


# Puts the box down in `room`. Moved to another room, every pair of loose cables may tangle (more loose
# cables, more knots). Returns how many new knots formed; -1 if the room cannot hold the box.
static func put_down(state: Dictionary, room: String) -> int:
    if not ROOMS.has(room): return -1
    state["carried"] = false
    if room == state["room"]: return 0
    state["room"] = room
    state["moves"] = int(state["moves"]) + 1
    var ids: Array = loose(state)
    ids.sort()
    var made: int = 0
    var chance: float = clampf(0.25 + 0.06 * ids.size(), 0.0, 0.7)
    for i in range(ids.size()):
        for j in range(i + 1, ids.size()):
            var rng := RandomNumberGenerator.new()
            rng.seed = hash("%d:%s:%s" % [int(state["moves"]), ids[i], ids[j]])
            if rng.randf() >= chance or _pair_knots(state, ids[i], ids[j]) >= MAX_KNOTS_PER_PAIR: continue
            (state["knots"] as Array).append({"a": ids[i], "b": ids[j], "open_a": rng.randi_range(0, 1), "open_b": rng.randi_range(0, 1),
                "at_a": rng.randf_range(0.3, 0.7), "at_b": rng.randf_range(0.3, 0.7), "strain": 0.0})
            made += 1
    return made


static func _pair_knots(state: Dictionary, a: String, b: String) -> int:
    var n: int = 0
    for k: Dictionary in state["knots"]:
        if (k["a"] == a and k["b"] == b) or (k["a"] == b and k["b"] == a): n += 1
    return n


# ---- untangling (the physics view calls these) ----

# The knot slid off cable `id` through its open end: it is undone.
static func free_knot(state: Dictionary, index: int) -> void:
    if index >= 0 and index < (state["knots"] as Array).size(): (state["knots"] as Array).remove_at(index)


# Pulling the wrong end of cable `id` strains knot `index`. Returns true if the cable snapped.
static func strain(state: Dictionary, index: int, id: String, amount: float) -> bool:
    if index < 0 or index >= (state["knots"] as Array).size(): return false
    var k: Dictionary = state["knots"][index]
    k["strain"] = clampf(float(k["strain"]) + amount, 0.0, BREAK_STRAIN)
    if float(k["strain"]) < BREAK_STRAIN: return false
    snap(state, id)
    return true


static func relax(state: Dictionary, amount: float) -> void:
    for k: Dictionary in state["knots"]: k["strain"] = maxf(0.0, float(k["strain"]) - amount)


# The cable breaks; its knots fall apart.
static func snap(state: Dictionary, id: String) -> void:
    var c: Dictionary = cable(state, id)
    if c.is_empty(): return
    c["broken"] = true
    _drop_knots(state, id)


static func _drop_knots(state: Dictionary, id: String) -> void:
    state["knots"] = (state["knots"] as Array).filter(func(k: Dictionary) -> bool: return k["a"] != id and k["b"] != id)


# ---- ties, supplies, broken cables ----

static func can_tie(state: Dictionary, id: String, strap: String) -> bool:
    var c: Dictionary = cable(state, id)
    if c.is_empty() or c["broken"] or c["tie"] != "" or not is_free(state, id): return false
    return strap in ["zip", "velcro"] and int(state.get("zip_ties" if strap == "zip" else "velcro", 0)) > 0


static func tie(state: Dictionary, id: String, strap: String) -> bool:
    if not can_tie(state, id, strap): return false
    var key: String = "zip_ties" if strap == "zip" else "velcro"
    state[key] = int(state[key]) - 1
    cable(state, id)["tie"] = strap
    return true


# A zip tie is cut off (used up); a velcro strap goes back in the box.
static func untie(state: Dictionary, id: String) -> bool:
    var c: Dictionary = cable(state, id)
    if c.is_empty() or c["tie"] == "": return false
    if c["tie"] == "velcro": state["velcro"] = int(state["velcro"]) + 1
    c["tie"] = ""
    return true


static func add_supply(state: Dictionary, supply: String) -> bool:
    if not SUPPLIES.has(supply): return false
    state[supply] = int(state.get(supply, 0)) + int(SUPPLIES[supply]["count"])
    return true


static func throw_away(state: Dictionary, id: String) -> bool:
    var c: Dictionary = cable(state, id)
    if c.is_empty() or not c["broken"]: return false
    state["cables"] = (state["cables"] as Array).filter(func(x: Dictionary) -> bool: return x["id"] != id)
    return true


# Cables of `kind` ready to use: whole and not caught in a knot.
static func usable(state: Dictionary, kind: String) -> Array:
    return (state["cables"] as Array).filter(func(c: Dictionary) -> bool: return c["kind"] == kind and not c["broken"] and is_free(state, str(c["id"]))).map(func(c: Dictionary) -> String: return str(c["id"]))


static func summary(state: Dictionary) -> String:
    var tied: int = 0; var broken: int = 0
    for c: Dictionary in state["cables"]:
        if c["tie"] != "": tied += 1
        if c["broken"]: broken += 1
    return "%d cables · %d tied · %d knot%s%s" % [(state["cables"] as Array).size(), tied, (state["knots"] as Array).size(),
        "" if (state["knots"] as Array).size() == 1 else "s", (" · %d broken" % broken) if broken > 0 else ""]
