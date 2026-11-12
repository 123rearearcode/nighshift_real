# Tool timing/risk only. No input, drawing, state or scene dependencies.
extends RefCounted

const STROKE_SECONDS: float = 0.8
const DAMAGE_CHANCE: float = 0.12 # provisional, per completed extraction attempt
var elapsed: float = 0.0
var target: String = ""
var rng := RandomNumberGenerator.new()

func _init() -> void:
    rng.randomize()

func reset() -> void:
    elapsed = 0.0
    target = ""

# Caller supplies a valid installed, working part with trapped dust.
# A forced roll is for deterministic regression checks only.
func step(delta: float, part_id: String, active: bool, forced_roll: float = -1.0) -> Dictionary:
    if not active or part_id == "":
        reset()
        return {}
    if part_id != target:
        elapsed = 0.0
        target = part_id
    elapsed += maxf(0.0, delta)
    if elapsed < STROKE_SECONDS: return {}
    elapsed = 0.0 # at most one attempt per tick; no catch-up bursts after a stall
    var roll: float = rng.randf() if forced_roll < 0.0 else forced_roll
    return {"part": part_id, "damaged": roll < DAMAGE_CHANCE}
