# PHYSICS/STATE: dust travelling inside the vacuum hose. What the vacuum swallows enters the hose at
# the nozzle and rides the air to the dust bin; it only reaches the bin (and fills it) when it
# arrives. With the suction off, dust in the hose stays where it is. Cleaning progress does not
# wait for it: the part counts as cleaned the moment the dust is swallowed. No drawing, no input.
# Not saved: like the bin, a reloaded bench starts with an empty hose.
extends RefCounted

const TRAVEL_SECONDS: float = 0.7     # nozzle to bin with full suction
const MAX_CLUMPS: int = 60            # beyond this, new dust joins the newest clump

var t := PackedFloat32Array()         # 0 = at the nozzle, 1 = at the bin
var amount := PackedFloat32Array()    # dust units in each clump


func count() -> int:
    return t.size()


func carried() -> float:
    var total: float = 0.0
    for a: float in amount:
        total += a
    return total


func add(units: float) -> void:
    if units <= 0.0:
        return
    if t.size() >= MAX_CLUMPS:
        amount[amount.size() - 1] += units
        return
    t.append(0.0)
    amount.append(units)


# Move the dust along. `suction` 0..1. `room` is how much the bin can still take. Returns the dust
# that reached the bin this step (never more than `room`; the rest waits at the bin end).
func step(delta: float, suction: float, room: float) -> float:
    var delivered: float = 0.0
    var advance: float = clampf(suction, 0.0, 1.0) * delta / TRAVEL_SECONDS
    var i: int = t.size() - 1
    while i >= 0:
        t[i] = minf(1.0, t[i] + advance)
        if t[i] >= 1.0:
            var take: float = clampf(room - delivered, 0.0, amount[i])
            delivered += take
            amount[i] -= take
            if amount[i] <= 0.0001:
                t.remove_at(i)
                amount.remove_at(i)
        i -= 1
    return delivered


func clear() -> void:
    t = PackedFloat32Array()
    amount = PackedFloat32Array()
