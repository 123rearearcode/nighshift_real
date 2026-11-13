# STATE/RULES: loose items lying on the repair bench (a coin that fell into the PC, a stray screw).
# The player picks one up with empty hands (hand state CARRYING_ITEM, docs/HAND_STATES.md), carries it
# and drops it; dropping it on the trash can throws it away. Items are session-local for now, like the
# dust positions: they are not saved. Nothing spawns items in normal play yet (D76: random items such
# as coins come later); the tests and future features call spawn(). No drawing, no input.
extends RefCounted

const Layout = preload("res://scripts/data/layout.gd")

const HALF := Vector2(10.0, 10.0)     # half size of an item's pickup box
const KINDS: Array = ["coin", "screw"]

var kinds: Array = []                 # one entry per item
var centers := PackedVector2Array()
var angles := PackedFloat32Array()
var carried: int = -1                 # index of the item in the hand, or -1


func count() -> int:
    return kinds.size()


func spawn(kind: String, center: Vector2, angle: float = 0.0) -> int:
    kinds.append(kind if kind in KINDS else KINDS[0])
    centers.append(center)
    angles.append(angle)
    return kinds.size() - 1


func rect(i: int) -> Rect2:
    return Rect2(centers[i] - HALF, HALF * 2.0)


# The item under `point`, or -1. The carried item is never "under" the cursor.
func hit(point: Vector2) -> int:
    for i in range(kinds.size() - 1, -1, -1):
        if i != carried and rect(i).has_point(point):
            return i
    return -1


func pick(point: Vector2) -> bool:
    var i: int = hit(point)
    if i < 0:
        return false
    carried = i
    return true


func move(point: Vector2) -> void:
    if carried >= 0:
        centers[carried] = point


# Drop the carried item at `point`. On the trash can it is destroyed; otherwise it stays on the
# bench (never outside `bounds`). Returns {"kind": String, "trashed": bool}, or {} if nothing held.
func drop(point: Vector2, bounds: Rect2) -> Dictionary:
    if carried < 0:
        return {}
    var kind: String = kinds[carried]
    var trashed: bool = Layout.BENCH_TRASH.has_point(point)
    if trashed:
        kinds.remove_at(carried)
        centers.remove_at(carried)
        angles.remove_at(carried)
    else:
        centers[carried] = point.clamp(bounds.position + HALF, bounds.end - HALF)
    carried = -1
    return {"kind": kind, "trashed": trashed}
