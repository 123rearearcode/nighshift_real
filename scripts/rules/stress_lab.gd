# RULES ONLY: the Stress lab, the diagnostic computer's standalone long load test (D150, 0.47.0).
# Pure. It reports what a person watching the run would see: temperature readings on the night clock,
# the fans getting loud, the PC crashing and when. It never names a cause or a faulty part, and it
# cannot see anything a load test does not exercise. Same input, same result: no random rolls.
# Numbers are trial proposals (the run length is NightClock.LONG_STRESS_MINUTES).
extends RefCounted

const Legacy = preload("res://scripts/state/game_state.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")

const READING_EVERY: int = 5      # minutes between temperature readings
const WARM_UP: int = 10           # minutes until the temperature settles at its load value
const CRASH_MINUTE: Dictionary = {"crashing": 3, "marginal": 14}


static func minutes() -> int:
    return Clock.LONG_STRESS_MINUTES


# Temperature `minute` minutes into the run: from the idle reading up to the load value.
static func temp_at(idle: float, load: float, minute: int) -> float:
    return lerpf(idle, load, clampf(float(minute) / float(WARM_UP), 0.0, 1.0))


# The idle reading before the load starts: a CPU kept busy by something already running is warmer.
static func idle_temp(job: Dictionary, load: float) -> float:
    return minf(Legacy.BASE_TEMP + Malware.live_heat(job), load)


# A full run started at night minute `start`. `load` is the PC's temperature under load (the same value
# the game test reads). Returns {complete, crashed, minutes, readings [[minute, temp]], max_temp,
# loud_from (-1 = never), lines}. The caller has already checked that the PC boots.
static func run(job: Dictionary, load: float, start: int) -> Dictionary:
    var length: int = minutes()
    var crash_at: int = -1
    if int(Overclock.settings(job)["mult"]) > 0:
        crash_at = int(CRASH_MINUTE.get(Overclock.state(job, load), -1))
    var ran: int = length if crash_at < 0 else mini(crash_at, length)
    var idle: float = idle_temp(job, load)
    var readings: Array = []
    var loud_from: int = -1
    var max_temp: float = idle
    var minute: int = 0
    while minute <= ran:
        var t: float = temp_at(idle, load, minute)
        readings.append([minute, t])
        max_temp = maxf(max_temp, t)
        if loud_from < 0 and t > PickupScore.COOL_TEMP + 10.0: loud_from = minute
        if minute == ran: break
        minute = mini(minute + READING_EVERY, ran)
    var lines: Array = []
    var stamps: Array = readings.map(func(r: Array) -> String: return "%s %.0f°C" % [Clock.label(start + int(r[0])), float(r[1])])
    lines.append("Readings: " + " · ".join(stamps))
    if loud_from >= 0: lines.append("Fans: loud from %s (minute %d)." % [Clock.label(start + loud_from), loud_from])
    else: lines.append("Fans: stayed quiet.")
    var oc: Dictionary = Overclock.settings(job)
    var settings_text: String = "CPU multiplier +%d, voltage %d" % [int(oc["mult"]), int(oc["volt"])] if int(oc["mult"]) > 0 or int(oc["volt"]) > 0 else "stock CPU settings"
    if crash_at >= 0 and crash_at <= length:
        lines.append("The PC CRASHED at %s, minute %d of %d (blue screen, restart). Settings during the run: %s." % [Clock.label(start + crash_at), crash_at, length, settings_text])
    else:
        lines.append("The PC ran the full %d minutes under load without crashing. Settings during the run: %s." % [length, settings_text])
    lines.append("A load test shows how the PC behaves under this load only; it does not point at a part.")
    return {"complete": crash_at < 0, "crashed": crash_at >= 0, "minutes": ran, "readings": readings, "max_temp": max_temp,
        "loud_from": loud_from, "lines": lines}


static func message(result: Dictionary, start: int) -> String:
    return "STRESS LAB · long load test · %s–%s\n%s" % [Clock.label(start), Clock.label(start + int(result["minutes"])), "\n".join(result["lines"])]
