# RULES ONLY: the overclocker (D132). Pure functions, no scene. Two settings on the customer's CPU:
# a multiplier step (more power) and a voltage step (more stability, more heat). Heat is VISIBLE: it
# raises the temperature every check shows. Stability is the delayed-discovery part: a quick stress test
# only catches a PC that is clearly crashing; a marginal setting passes it, fails a long test, and (if left)
# makes the customer's games crash at home. A hot PC is less stable than a cool one.
# All numbers are trial proposals.
extends RefCounted

const MAX_MULT: int = 5
const MAX_VOLT: int = 4
const POWER_PER_STEP: float = 0.06    # +6% CPU power per multiplier step
const HEAT_PER_MULT: float = 4.0
const HEAT_PER_VOLT: float = 3.0
const WASTE_HEAT: float = 4.0         # voltage two or more steps above what the multiplier needs
const HOT_C: float = 80.0             # at or above this the PC is one step less stable
const LONG_TEST_COST: int = 2         # shop cash for the long test's electricity

const UNSTABLE := "oc_unstable"
const CRASHING := "oc_crash"
const FAULT_IDS: Array = [UNSTABLE, CRASHING]
const ANNOYANCE: Dictionary = {UNSTABLE: 30.0, CRASHING: 50.0}
const COMPLAINT: Dictionary = {
    UNSTABLE: "games crash at random: the overclock was never really stable",
    CRASHING: "the PC blue-screens within minutes: the overclock was left far too high",
}


static func settings(job: Dictionary) -> Dictionary:
    var raw: Variant = job.get("overclock", {})
    var mult: int = 0
    var volt: int = 0
    if raw is Dictionary:
        mult = clampi(int(raw.get("mult", 0)), 0, MAX_MULT)
        volt = clampi(int(raw.get("volt", 0)), 0, MAX_VOLT)
    return {"mult": mult, "volt": volt}


static func sanitize(raw: Variant) -> Dictionary:
    return settings({"overclock": raw})


static func need_volt(mult: int) -> int:
    return int(ceil(float(mult) * 0.7))


static func cpu_factor(job: Dictionary) -> float:
    return 1.0 + POWER_PER_STEP * float(settings(job)["mult"])


static func heat(job: Dictionary) -> float:
    var s: Dictionary = settings(job)
    var total: float = HEAT_PER_MULT * float(s["mult"]) + HEAT_PER_VOLT * float(s["volt"])
    if int(s["volt"]) - need_volt(int(s["mult"])) >= 2: total += WASTE_HEAT
    return total


# volt - needed volt, minus one when the PC is hot. >= 0 stable, -1 marginal, <= -2 crashing.
static func margin(job: Dictionary, temp: float) -> int:
    var s: Dictionary = settings(job)
    var m: int = int(s["volt"]) - need_volt(int(s["mult"]))
    if temp >= HOT_C and int(s["mult"]) > 0: m -= 1
    return m


static func state(job: Dictionary, temp: float) -> String:
    var m: int = margin(job, temp)
    if m <= -2: return "crashing"
    if m == -1: return "marginal"
    return "stable"


# A stress test. quick: only a crashing PC fails. long: a marginal one fails too.
static func stress(job: Dictionary, temp: float, long_test: bool) -> Dictionary:
    var st: String = state(job, temp)
    var settings_text: String = "x+%d / voltage %d" % [int(settings(job)["mult"]), int(settings(job)["volt"])]
    if int(settings(job)["mult"]) == 0:
        return {"ok": true, "message": "Stock settings: nothing to stress. The CPU is not overclocked."}
    if st == "crashing":
        return {"ok": false, "message": "CRASH during the %s stress test (%s at %.1f°C). Lower the multiplier or raise the voltage." % ["long" if long_test else "quick", settings_text, temp]}
    if st == "marginal" and long_test:
        return {"ok": false, "message": "Long stress test FAILED after 20 minutes (%s at %.1f°C): not stable. Raise the voltage or lower the multiplier." % [settings_text, temp]}
    return {"ok": true, "message": "%s stress test passed (%s at %.1f°C)." % ["Long" if long_test else "Quick", settings_text, temp] + ("" if long_test else " A quick test cannot prove a setting is stable.")}


# Hidden pickup faults of the setting left on the PC.
static func pickup_faults(job: Dictionary, temp: float) -> Array:
    var st: String = state(job, temp)
    if int(settings(job)["mult"]) == 0: return []
    if st == "crashing": return [CRASHING]
    if st == "marginal": return [UNSTABLE]
    return []


static func annoyance(faults: Array) -> float:
    var total: float = 0.0
    for f: Variant in faults: total += float(ANNOYANCE.get(str(f), 0.0))
    return total


static func complaint(fault: String) -> String:
    return str(COMPLAINT.get(fault, ""))
