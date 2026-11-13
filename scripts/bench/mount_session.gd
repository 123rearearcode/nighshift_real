# SIM LAYER: the timed cooler-mounting pressure session. No drawing, no mouse or keyboard reading:
# the view passes in whether the player is pressing. Pressure rises while pressing and falls when
# released; more pressure lowers the paste yield thickness, so paste flows more. The grade is still
# worked out by PasteSim.evaluate(). Numbers moved unchanged from bench_view.gd in 0.11.1.
extends RefCounted

const PasteSim = preload("res://scripts/bench/paste_sim.gd")

const MOUNT_TIME: float = 10.0         # seconds of pressing; after that the paste has set and only the lever is left
const PRESS_RISE: float = 0.45         # pressure gained per second while pressing
const PRESS_FALL: float = 0.9          # pressure lost per second when released
const TARGET_COVER: float = PasteSim.PERFECT_COVER      # coverage that counts as PERFECT
const OVERFLOW_LIMIT: float = PasteSim.MESSY_OVERFLOW   # squeezed-out share that starts to count as messy
const OVERFLOW_SCALE: float = 0.60     # squeezed-out share that fills its bar

var active: bool = false
var pressure: float = 0.0
var time_left: float = 0.0


func start() -> void:
    active = true
    pressure = 0.0
    time_left = MOUNT_TIME


func finish() -> void:
    active = false
    pressure = 0.0


# One tick. Returns true once time has run out: pressing then does nothing more and the cooler waits
# for the player to pull the securing lever (0.15.1: securing is never automatic).
func step(delta: float, pressing: bool, paste: PasteSim) -> bool:
    if time_left <= 0.0:
        pressing = false
    if pressing:
        pressure = minf(1.0, pressure + PRESS_RISE * delta)
    else:
        pressure = maxf(0.0, pressure - PRESS_FALL * delta)
    var yield_h: float = PasteSim.yield_for_pressure(pressure)
    for k in range(PasteSim.PRESS_STEPS_PER_TICK):
        paste.step(yield_h)
    time_left = maxf(0.0, time_left - delta)
    return time_left <= 0.0
