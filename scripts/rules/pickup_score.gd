# RULES ONLY: how happy a customer is at PICKUP (D95), 0-100. Pure function, no scene access.
# The score measures whether their REAL needs were met, not whether the shop's check passed:
# a gamer whose frame rate is short goes home disappointed even though the PC "works".
# Scams are NOT scored here: at pickup nobody has discovered anything yet; delayed discovery
# adjusts trust later (D95, not built yet). An unhappy customer comes back sooner (comeback_days).
extends RefCounted

const FpsSim = preload("res://scripts/rules/fps_sim.gd")
const Games = preload("res://scripts/data/games.gd")

const COOL_TEMP: float = 55.0         # at or under this the temperature part is perfect
const TEMP_WEIGHT: float = 25.0       # how many points the temperature part is worth
const MISSED_GAME_COST: float = 35.0  # points lost per game that misses its minimum fps
const MISSED_NEED_COST: float = 40.0  # points lost when a stated/real need (quiet, cool) is missed
const HAPPY_FROM: int = 70            # at or above this the customer leaves happy (no comeback)


# `customer` from scripts/data/customers.gd; `temp` the final-check temperature; `gpu_power`,
# `cpu_power`, `ram_gb` the PC as handed back. Returns {score: int, misses: Array of String}.
static func score(customer: Dictionary, temp: float, gpu_power: float, cpu_power: float, ram_gb: float, pass_limit: float) -> Dictionary:
    var points: float = 100.0
    var misses: Array = []
    # Temperature: full marks when cool, scaling off toward the pass limit.
    if temp > COOL_TEMP:
        var over: float = clampf((temp - COOL_TEMP) / maxf(1.0, pass_limit - COOL_TEMP), 0.0, 1.0)
        points -= TEMP_WEIGHT * over
        if over >= 1.0:
            misses.append("runs right at the limit")
    var needs: Dictionary = customer.get("needs", {})
    if str(customer.get("profession", "")) == "clueless":
        needs = needs.get("real", {})   # the stated need is a decoy; the real one decides (D93)
    for entry: Dictionary in needs.get("games", []):
        var game: Dictionary = Games.game(str(entry.get("game_id", "")))
        var frames: int = FpsSim.fps(gpu_power, cpu_power, ram_gb, game, temp)
        if frames < int(entry.get("min_fps", 0)):
            points -= MISSED_GAME_COST
            misses.append("%s runs at %d fps, wanted %d" % [str(game.get("title", "?")), frames, int(entry.get("min_fps", 0))])
    if bool(needs.get("quiet", false)) and temp > COOL_TEMP + 10.0:
        points -= MISSED_NEED_COST   # hot PCs are loud PCs: the fans give it away
        misses.append("still loud under load")
    return {"score": clampi(roundi(points), 0, 100), "misses": misses}


# How many days until an unhappy customer is back at the counter (D95: variable, angrier is sooner).
# Happy customers (score >= HAPPY_FROM) do not come back about this repair: 0.
static func comeback_days(pickup: int) -> int:
    if pickup >= HAPPY_FROM:
        return 0
    if pickup < 40:
        return 1
    if pickup < 60:
        return 2
    return 3
