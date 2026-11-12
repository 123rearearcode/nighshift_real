# RULES/STATE: the vacuum's dust bin. Everything the vacuum swallows fills it; when it is full the
# vacuum stops pulling until the player empties it. No drawing, no input. Dust management is a
# mechanic the user wants to grow, so the numbers here are proposals.
extends RefCounted

const CAPACITY: float = 140.0         # dust units (one unit = one node of a dust bundle; a dirty PC holds about 290). 90 until 0.14.3: user found it a bit small
const WARN_AT: float = 0.8            # the meter turns to a warning colour from here
const RECT := Rect2(582, 540, 72, 52) # where the bin sits on the bench (drawn by the view, anchors the hose)

var fill: float = 0.0


static func hose_anchor() -> Vector2:
    return RECT.position + Vector2(10.0, 12.0)


# Add swallowed dust. Returns the amount that actually fit.
func add(amount: float) -> float:
    var taken: float = clampf(amount, 0.0, CAPACITY - fill)
    fill += taken
    return taken


func is_full() -> bool:
    return fill >= CAPACITY - 0.0001


func fraction() -> float:
    return clampf(fill / CAPACITY, 0.0, 1.0)


# Empty the bin. Returns how much dust was in it.
func empty() -> float:
    var had: float = fill
    fill = 0.0
    return had
