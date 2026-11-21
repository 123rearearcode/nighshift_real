# RULES ONLY: the simulated frame rate of a PC in a game (D94). Pure functions, no scene access.
# fps = BASE_FPS * the WORST of (gpu power / gpu demand) and (cpu power / cpu demand): the slowest
# part sets the pace. Heat throttles the GPU (dust and bad paste show up here), and too little RAM
# makes everything stutter. A PC with a dead GPU or CPU renders nothing.
extends RefCounted

const Games = preload("res://scripts/data/games.gd")

const THROTTLE_FROM_C: float = 60.0   # no throttling below this temperature
const THROTTLE_FLOOR: float = 0.5     # at or past 90 C the GPU keeps only half its power
const THROTTLE_TO_C: float = 90.0
const RAM_STARVED_SCALE: float = 0.35 # fps share kept when RAM is below the game's minimum


# Share of GPU power kept at `temp` C: 1.0 when cool, falling linearly to THROTTLE_FLOOR at 90 C.
static func thermal_factor(temp: float) -> float:
    if temp <= THROTTLE_FROM_C:
        return 1.0
    var t: float = clampf((temp - THROTTLE_FROM_C) / (THROTTLE_TO_C - THROTTLE_FROM_C), 0.0, 1.0)
    return lerpf(1.0, THROTTLE_FLOOR, t)


# Simulated fps for a game (a Dictionary from scripts/data/games.gd). 0 when it cannot render.
static func fps(gpu_power: float, cpu_power: float, ram_gb: float, game: Dictionary, temp: float = 0.0) -> int:
    if game.is_empty() or gpu_power <= 0.0 or cpu_power <= 0.0:
        return 0
    var gpu_share: float = gpu_power * thermal_factor(temp) / float(game["gpu_demand"])
    var cpu_share: float = cpu_power / float(game["cpu_demand"])
    var frames: float = Games.BASE_FPS * minf(gpu_share, cpu_share)
    if ram_gb < float(game["ram_min"]):
        frames *= RAM_STARVED_SCALE
    return int(floor(frames))
