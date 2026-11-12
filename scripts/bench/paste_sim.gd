# PHYSICS + SCORING ONLY: thermal paste as a height field on a grid.
# Paste behaves like a thick paste: a cell only flows when it is thicker than a
# yield level, and thicker cells flow faster. So a blob spreads when the cooler
# presses on it, and stops as a thin film. Closed edges (nothing leaves the grid).
# Numbers were tuned in a Python prototype (not in Godot).
# Real-world rule used for scoring: a thin even film is the goal; too much only
# makes a mess, too little leaves bare spots.
extends RefCounted

const GRID: int = 51
const CPU_MIN: int = 8        # CPU covers cells CPU_MIN .. CPU_MAX-1 on both axes
const CPU_MAX: int = 43
const FLOW_K: float = 0.24
const YIELD_H: float = 0.04
const MOBILITY: float = 10.0
const COVER_H: float = 0.03
const DEPOSIT_RADIUS: float = 3.0
# Mounting is a pressure minigame: pressing harder lowers the yield thickness, so paste flows more.
const YIELD_LIGHT: float = 0.25       # yield thickness with no pressure (paste barely moves)
const YIELD_HARD: float = 0.01        # yield thickness at full pressure (paste flows almost everywhere)
const PRESS_STEPS_PER_TICK: int = 3   # flow steps run per 60 Hz tick while mounting
const EDGE_EPS: float = 0.004
const WIPE_EXTRA: float = 0.05       # extra paste removed per wipe tick so thin films vanish
const WIPE_ZERO_BELOW: float = 0.02  # a cell thinner than this after wiping is set to empty

var h: PackedFloat32Array = PackedFloat32Array()
var flow: PackedFloat32Array = PackedFloat32Array()
var total_deposited: float = 0.0
var min_x: int = GRID
var max_x: int = -1
var min_y: int = GRID
var max_y: int = -1


func _init() -> void:
    clear()


func clear() -> void:
    h.resize(GRID * GRID)
    flow.resize(GRID * GRID)
    h.fill(0.0)
    flow.fill(0.0)
    total_deposited = 0.0
    min_x = GRID
    max_x = -1
    min_y = GRID
    max_y = -1


# Add paste around (cx, cy) in cell coordinates (floats; cell x covers x..x+1).
func deposit(cx: float, cy: float, volume: float) -> void:
    var x0: int = maxi(0, floori(cx - DEPOSIT_RADIUS))
    var x1: int = mini(GRID - 1, ceili(cx + DEPOSIT_RADIUS))
    var y0: int = maxi(0, floori(cy - DEPOSIT_RADIUS))
    var y1: int = mini(GRID - 1, ceili(cy + DEPOSIT_RADIUS))
    var center := Vector2(cx, cy)
    var total_w: float = 0.0
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            total_w += maxf(0.0, 1.0 - Vector2(x + 0.5, y + 0.5).distance_to(center) / DEPOSIT_RADIUS)
    if total_w <= 0.0:
        return
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            var w: float = maxf(0.0, 1.0 - Vector2(x + 0.5, y + 0.5).distance_to(center) / DEPOSIT_RADIUS)
            var share: float = volume * w / total_w
            h[y * GRID + x] += share
            if x >= CPU_MIN and x < CPU_MAX and y >= CPU_MIN and y < CPU_MAX:
                total_deposited += share   # the gauge counts paste on the CPU only
    min_x = mini(min_x, x0)
    max_x = maxi(max_x, x1)
    min_y = mini(min_y, y0)
    max_y = maxi(max_y, y1)


# Yield thickness for a pressure between 0 (resting) and 1 (full).
static func yield_for_pressure(pressure: float) -> float:
    return lerpf(YIELD_LIGHT, YIELD_HARD, clampf(pressure, 0.0, 1.0))


# Rub paste off with a cloth centred on (cx, cy), in cell coordinates. Each cell within `radius`
# loses a share of its paste (`strength` at the centre, fading to zero at the edge) plus a little
# extra, so thin films vanish completely. A round cloth measures distance in a straight line; a
# square cloth (`square` true) uses the larger of the x and y distances, so it covers a square of
# side 2 * radius, about 27% more area, including the corners. Returns the amount removed.
func wipe(cx: float, cy: float, radius: float, strength: float, square: bool = false) -> float:
    var x0: int = maxi(0, floori(cx - radius))
    var x1: int = mini(GRID - 1, ceili(cx + radius))
    var y0: int = maxi(0, floori(cy - radius))
    var y1: int = mini(GRID - 1, ceili(cy + radius))
    var center := Vector2(cx, cy)
    var removed: float = 0.0
    var removed_on_cpu: float = 0.0   # only this part lowers the gauge: paste beside the CPU never counted
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            var i: int = y * GRID + x
            var v: float = h[i]
            if v <= 0.0:
                continue
            var d: float
            if square:
                d = maxf(absf(x + 0.5 - cx), absf(y + 0.5 - cy))
            else:
                d = Vector2(x + 0.5, y + 0.5).distance_to(center)
            if d >= radius:
                continue
            var f: float = strength * (1.0 - d / radius)
            var nv: float = v * (1.0 - f) - WIPE_EXTRA * f
            if nv < WIPE_ZERO_BELOW:
                nv = 0.0
            removed += v - nv
            if x >= CPU_MIN and x < CPU_MAX and y >= CPU_MIN and y < CPU_MAX:
                removed_on_cpu += v - nv
            h[i] = nv
    total_deposited = maxf(0.0, total_deposited - removed_on_cpu)
    return removed


# One relaxation step (the cooler pressing). `yield_h` is the thickness below which paste does not
# move. Returns how much paste moved.
func step(yield_h: float = YIELD_H) -> float:
    if max_x < 0:
        return 0.0
    var x0: int = maxi(min_x - 1, 0)
    var x1: int = mini(max_x + 1, GRID - 1)
    var y0: int = maxi(min_y - 1, 0)
    var y1: int = mini(max_y + 1, GRID - 1)
    var moved: float = 0.0
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            var i: int = y * GRID + x
            var hi: float = h[i]
            if hi <= yield_h:
                continue
            var k: float = FLOW_K * minf(1.0, (hi - yield_h) * MOBILITY)
            var diff: float
            var f: float
            if x + 1 < GRID:
                diff = hi - h[i + 1]
                if diff > 0.0:
                    f = k * diff
                    flow[i] -= f
                    flow[i + 1] += f
                    moved += f
            if x > 0:
                diff = hi - h[i - 1]
                if diff > 0.0:
                    f = k * diff
                    flow[i] -= f
                    flow[i - 1] += f
                    moved += f
            if y + 1 < GRID:
                diff = hi - h[i + GRID]
                if diff > 0.0:
                    f = k * diff
                    flow[i] -= f
                    flow[i + GRID] += f
                    moved += f
            if y > 0:
                diff = hi - h[i - GRID]
                if diff > 0.0:
                    f = k * diff
                    flow[i] -= f
                    flow[i - GRID] += f
                    moved += f
    # Apply the flow, clear it, and recompute the active bounds.
    var nmin_x: int = GRID
    var nmax_x: int = -1
    var nmin_y: int = GRID
    var nmax_y: int = -1
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            var j: int = y * GRID + x
            var nv: float = h[j] + flow[j]
            flow[j] = 0.0
            h[j] = nv
            if nv > EDGE_EPS:
                nmin_x = mini(nmin_x, x)
                nmax_x = maxi(nmax_x, x)
                nmin_y = mini(nmin_y, y)
                nmax_y = maxi(nmax_y, y)
    min_x = nmin_x
    max_x = nmax_x
    min_y = nmin_y
    max_y = nmax_y
    return moved


# Squeeze-gauge text and tone for the amount deposited so far (tone: 0 info, 1 good, 2 warn).
func gauge_text() -> String:
    if total_deposited < 1.0:
        return "no paste yet"
    if total_deposited < 70.0:
        return "too little"
    if total_deposited < 110.0:
        return "a bit light"
    if total_deposited <= 145.0:
        return "pea-sized, about right"
    return "a lot - it will squeeze out"


func gauge_tone() -> int:
    if total_deposited < 1.0:
        return 0
    if total_deposited >= 110.0 and total_deposited <= 145.0:
        return 1
    return 2


# Current coverage of the CPU and share of paste outside it. Keys: coverage, overflow.
func measure() -> Dictionary:
    var inside_cells: int = 0
    var covered: int = 0
    var total: float = 0.0
    var outside: float = 0.0
    for y in range(GRID):
        for x in range(GRID):
            var v: float = h[y * GRID + x]
            total += v
            if x >= CPU_MIN and x < CPU_MAX and y >= CPU_MIN and y < CPU_MAX:
                inside_cells += 1
                if v >= COVER_H:
                    covered += 1
            else:
                outside += v
    var overflow: float = 0.0
    if total > 0.0:
        overflow = outside / total
    return {"coverage": float(covered) / float(inside_cells), "overflow": overflow}


# Score the pressed paste. Keys: coverage, overflow, volume, grade, message, tone (1 good, 2 warn, 3 bad)
func evaluate() -> Dictionary:
    var m: Dictionary = measure()
    var coverage: float = m["coverage"]
    var overflow: float = m["overflow"]
    var grade: String
    var message: String
    var tone: int
    if coverage < 0.60:
        grade = "TOO LITTLE"
        message = "Most of the CPU is bare. It will overheat. Wipe it and use more paste."
        tone = 3
    elif coverage < 0.90:
        grade = "BALD SPOTS"
        message = "Parts of the CPU are bare, which causes hot spots. Add more paste."
        tone = 3
    elif coverage < 0.95 and overflow <= 0.20:
        grade = "GOOD ENOUGH"
        message = "Nearly full coverage; a few corners are bare."
        tone = 2
    elif overflow <= 0.20:
        grade = "PERFECT"
        message = "Even film across the whole CPU with very little squeezed out."
        tone = 1
    else:
        grade = "MESSY"
        message = "The CPU is covered, but a lot of paste squeezed out. It still works, but it is untidy and wasteful."
        tone = 2
    return {
        "coverage": coverage,
        "overflow": overflow,
        "volume": total_deposited,
        "grade": grade,
        "message": message,
        "tone": tone,
    }
