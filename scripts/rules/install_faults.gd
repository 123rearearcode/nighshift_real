# RULES ONLY: the hidden installation mistakes of the cooler mount (D130). Pure functions, no scene.
# Two real habits decide them: peeling the clear plastic film off the cooler's base, and tightening
# the four mounting screws in a cross pattern (opposite corners, never round the square), two
# passes each. A mistake is NOT shown by the shop's own final check: it surfaces only when the
# customer uses the PC (pickup_score.gd), exactly like the delayed-discovery design (D95).
extends RefCounted

const FILM := "film_left"          # plastic film still on the cooler base: the classic overheating mistake
const UNEVEN := "uneven_mount"     # screws tightened round the square: tilted cooler, poor contact
const LOOSE := "loose_screws"      # screws skipped or left half-turned: the cooler rattles and contact is poor
const GPU_LOOSE := "gpu_loose"     # D131: a GPU that was removed or replaced and never screwed back in
const IDS: Array = [FILM, UNEVEN, LOOSE, GPU_LOOSE]

# D131: the install ritual, in order. The screwdriver is a real tool; the screws come AFTER the press
# (the paste has set), and BEFORE the lever that locks the cooler.
const STEPS: Array = ["Film", "Paste", "Mount+press", "Screws (screwdriver)", "Lever"]
const GPU_SCREW_COUNT: int = 2     # the card's bracket screws; both need one tight turn each

const SCREW_COUNT: int = 4         # corners: 0 top-left, 1 top-right, 2 bottom-left, 3 bottom-right
const TURNS_NEEDED: int = 2        # a snug pass, then a tight pass
const SLIPS_ALLOWED: int = 1       # one wrong pair is forgiven; two or more make the mount uneven
const OPPOSITE: Dictionary = {0: 3, 3: 0, 1: 2, 2: 1}
const SCREW_INSET: float = 22.0    # distance from the socket area's corner to a screw centre
const SCREW_RADIUS: float = 15.0

# Trial numbers. HEAT is extra temperature the customer's own PC shows (added only at pickup);
# ANNOYANCE is the flat pickup-score cost of a problem the customer has to notice and report.
const HEAT: Dictionary = {FILM: 30.0, UNEVEN: 10.0, LOOSE: 15.0, GPU_LOOSE: 0.0}
const ANNOYANCE: Dictionary = {FILM: 30.0, UNEVEN: 12.0, LOOSE: 25.0, GPU_LOOSE: 20.0}
const COMPLAINT: Dictionary = {
    FILM: "ran hot at home: the clear plastic film was still on the cooler base",
    UNEVEN: "cooler sits crooked: the screws were not tightened evenly",
    LOOSE: "cooler rattles: the mounting screws were left loose",
    GPU_LOOSE: "the graphics card sags and the picture glitches: its bracket screws were never tightened",
}


static func turns(clicks: Array, screw: int) -> int:
    var n: int = 0
    for c: Variant in clicks:
        if int(c) == screw: n += 1
    return n


# A screw takes at most TURNS_NEEDED turns; further clicks on it do nothing.
static func can_turn(clicks: Array, screw: int) -> bool:
    return screw >= 0 and screw < SCREW_COUNT and turns(clicks, screw) < TURNS_NEEDED


# Clicks are taken in pairs (1st+2nd, 3rd+4th ...): each pair should be OPPOSITE corners.
static func slips(clicks: Array) -> int:
    var wrong: int = 0
    var i: int = 0
    while i + 1 < clicks.size():
        if int(OPPOSITE.get(int(clicks[i]), -1)) != int(clicks[i + 1]):
            wrong += 1
        i += 2
    return wrong


# Which mistakes this mount made. `film_peeled`: the player took the film off before locking.
static func evaluate(film_peeled: bool, clicks: Array) -> Array:
    var faults: Array = []
    if not film_peeled:
        faults.append(FILM)
    if clicks.size() < SCREW_COUNT * TURNS_NEEDED:
        faults.append(LOOSE)
    elif slips(clicks) > SLIPS_ALLOWED:
        faults.append(UNEVEN)
    return faults


static func sanitize(raw: Variant) -> Array:
    var out: Array = []
    if raw is Array:
        for id: Variant in raw:
            if str(id) in IDS and not str(id) in out:
                out.append(str(id))
    return out


static func heat(faults: Array) -> float:
    var total: float = 0.0
    for id: Variant in faults:
        total += float(HEAT.get(str(id), 0.0))
    return total


static func annoyance(faults: Array) -> float:
    var total: float = 0.0
    for id: Variant in faults:
        total += float(ANNOYANCE.get(str(id), 0.0))
    return total


static func complaint(id: String) -> String:
    return str(COMPLAINT.get(id, ""))


# D131: faults the customer finds at pickup = the recorded cooler-mount faults, plus a GPU that was
# touched (removed or replaced) and left unscrewed. `gpu_turns` is the job's gpu_screws (2 = tight).
static func pickup_faults(recorded: Array, gpu_fitted: bool, gpu_turns: int) -> Array:
    var faults: Array = sanitize(recorded)
    faults.erase(GPU_LOOSE)
    if gpu_fitted and gpu_turns < GPU_SCREW_COUNT:
        faults.append(GPU_LOOSE)
    return faults


# The GPU's two bracket screws, on its metal I/O bracket at the rear of the case (the left end of the card,
# just outside the board), one above the other: the card's row and the row above it. 0.48.1 (user report):
# until then they were drawn on the row below the card, which is the second PCIe slot.
static func gpu_screw_centers(slot: Rect2, cell: float) -> Array:
    var x: float = slot.position.x - cell * 0.5
    var y: float = slot.position.y + slot.size.y * 0.5
    return [Vector2(x, y), Vector2(x, y - cell)]


# The bracket plate the screws sit on (drawn under them).
static func gpu_bracket_rect(slot: Rect2, cell: float) -> Rect2:
    return Rect2(slot.position.x - cell * 0.95, slot.position.y - cell * 1.05, cell * 0.9, slot.size.y + cell * 1.1)


static func gpu_screw_radius(cell: float) -> float:
    return minf(SCREW_RADIUS, cell * 0.42)


# Index (0 or 1) of the GPU screw under `point`, or -1.
static func gpu_screw_at(slot: Rect2, cell: float, point: Vector2) -> int:
    var centers: Array = gpu_screw_centers(slot, cell)
    for i in range(centers.size()):
        if (centers[i] as Vector2).distance_to(point) <= gpu_screw_radius(cell) + 3.0:
            return i
    return -1


# Screw centres for a socket area `region`: its four corners, pulled in by SCREW_INSET.
static func screw_centers(region: Rect2) -> Array:
    var a: Vector2 = region.position + Vector2(SCREW_INSET, SCREW_INSET)
    var b: Vector2 = region.end - Vector2(SCREW_INSET, SCREW_INSET)
    return [a, Vector2(b.x, a.y), Vector2(a.x, b.y), b]


# Index of the screw under `point`, or -1.
static func screw_at(region: Rect2, point: Vector2) -> int:
    var centers: Array = screw_centers(region)
    for i in range(centers.size()):
        if (centers[i] as Vector2).distance_to(point) <= SCREW_RADIUS:
            return i
    return -1
