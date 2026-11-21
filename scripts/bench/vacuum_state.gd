# STATE ONLY: the vacuum's saved contents (0.48.1; user, 18 November 2026: the bin and the hose stay full
# across screens and reloads, so reopening the bench is no free emptying). Pure helpers: what is saved is
# the bin's fill and the dust clumps riding in the hose, [t, amount] pairs (t 0 = nozzle, 1 = bin).
extends RefCounted

const DustBin = preload("res://scripts/bench/dust_bin.gd")
const HoseFlow = preload("res://scripts/bench/hose_flow.gd")


static func _number(value: Variant) -> float:
    return float(value) if typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) else 0.0


# Rebuilds saved contents from known shapes only: a bin within its capacity, at most MAX_CLUMPS clumps.
static func sanitize(raw: Variant) -> Dictionary:
    var out: Dictionary = {"bin": 0.0, "hose": []}
    if not raw is Dictionary: return out
    out["bin"] = clampf(_number((raw as Dictionary).get("bin", 0.0)), 0.0, DustBin.CAPACITY)
    var hose: Variant = (raw as Dictionary).get("hose", [])
    if hose is Array:
        for clump: Variant in hose:
            if not clump is Array or (clump as Array).size() != 2: continue
            var amount: float = _number(clump[1])
            if amount <= 0.0: continue
            (out["hose"] as Array).append([clampf(_number(clump[0]), 0.0, 1.0), minf(amount, DustBin.CAPACITY)])
            if (out["hose"] as Array).size() >= HoseFlow.MAX_CLUMPS: break
    return out


# The live hose as [t, amount] pairs.
static func capture(flow: RefCounted) -> Array:
    var out: Array = []
    for i in range(flow.count()): out.append([float(flow.t[i]), float(flow.amount[i])])
    return out


# Puts saved contents back into a bin and a hose (both are replaced).
static func restore(state: Dictionary, bin: RefCounted, flow: RefCounted) -> void:
    var clean: Dictionary = sanitize(state)
    bin.fill = float(clean["bin"])
    flow.clear()
    for clump: Array in clean["hose"]:
        flow.t.append(float(clump[0]))
        flow.amount.append(float(clump[1]))
