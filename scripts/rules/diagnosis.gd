# RULES ONLY: diagnosis solvability and difficulty (D150 section 5.7, 0.47.0). Pure functions.
# This file READS THE HIDDEN TRUTH of a job, so nothing the player sees may ever call it: no view, no
# Findings text, no manual. It exists so tests (and later the 3.5 ticket generator) can prove that every
# offered case has an evidence path the player can actually take with what the shop owns, and can say
# how evident each issue is.
#
# Difficulty (PROPOSED levels, for Codex's review; the taxonomy is not approved player-facing design):
#   1 EVIDENT     seen on inspection or named by a basic check
#   2 TESTED      one test shows it (scan, game test, Stress lab)
#   3 COMPARED    only a controlled change shows it (an owned known-good part swapped in)
# A condition's level is the cheapest path the player can take NOW. A path that needs the PC to start
# is open once every start-blocking condition is itself solvable (a masking fault, addressed first).
extends RefCounted

const Ids = preload("res://scripts/data/ids.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")

const EVIDENT: int = 1
const TESTED: int = 2
const COMPARED: int = 3
const UNSOLVABLE: int = 99


# What the player can use: {"stock": {kind: count of working, available owned parts},
# "games": [owned game ids], "money": shop cash}. Built by GameState.diagnosis_capabilities().
static func capabilities(stock: Dictionary, games: Array, money: int) -> Dictionary:
    return {"stock": stock, "games": games, "money": money}


# Each live condition of the job with its evidence paths. A path is {"test", "level", "needs": {...},
# "boots": bool}: needs may hold "stock" (a part kind), "game" (any owned game) or "money" (cash).
static func conditions(job: Dictionary, load_temp: float) -> Array:
    var out: Array = []
    var dust: Dictionary = job.get("dust", {}) if job.get("dust", {}) is Dictionary else {}
    for zone: Dictionary in DustZones.zones(str(job.get("layout", "tower"))):
        if clampf(float(dust.get(zone["id"], 0.0)), 0.0, 1.0) < DustZones.CLEAN_AT:
            out.append({"id": "dust:" + str(zone["id"]), "paths": [_path("inspect_repair_bench", EVIDENT)]})
    if str(job.get("paste_grade", "")) == "" or not bool(job.get("paste_done", false)):
        out.append({"id": "cooler_contact", "paths": [_path("inspect_repair_bench", EVIDENT), _path("hardware_check", EVIDENT)]})
    for line: String in PcBuild.missing(job):
        out.append({"id": "missing:" + line.get_slice(":", 0).to_lower(), "paths": [_path("inspect_hardware_bench", EVIDENT)]})
    var broken: Array = job.get("broken_parts", []) if job.get("broken_parts", []) is Array else []
    var damaged: Array = job.get("damaged_parts", []) if job.get("damaged_parts", []) is Array else []
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    for kind: Variant in broken:
        if str(kind) in removed: continue
        if str(kind) in damaged:
            out.append({"id": "damaged:" + str(kind), "paths": [_path("inspect_repair_bench", EVIDENT)]})
            continue
        # A hidden fault: the boot attempt shows a symptom shared by several explanations; only swapping
        # in an owned working part of the same kind separates them.
        out.append({"id": "faulty:" + str(kind), "paths": [_path("swap_known_good", COMPARED, {"stock": str(kind)})]})
    if PcBuild.dead_second_card(job):
        out.append({"id": "faulty:gpu_2", "paths": [_path("game_test_with_and_without", COMPARED, {"game": true}, true),
            _path("swap_known_good", COMPARED, {"stock": Ids.GPU})]})
    var power: Dictionary = PcBuild.effective(job)
    if PcBuild.missing(job).is_empty() and not bool(power["powered"]):
        out.append({"id": "psu_too_small", "paths": [_path("boot_check", EVIDENT), _path("hardware_check", EVIDENT)]})
    if Malware.infected(job):
        out.append({"id": "malware:" + Malware.strain(job), "paths": [_path("antivirus_scan", TESTED, {}, true)]})
    if int(Overclock.settings(job)["mult"]) > 0:
        var state: String = Overclock.state(job, load_temp)
        if state == "crashing":
            out.append({"id": "overclock_crashing", "paths": [_path("quick_stress", TESTED, {}, true), _path("stress_lab", TESTED, {"money": Overclock.LONG_TEST_COST}, true)]})
        elif state == "marginal":
            out.append({"id": "overclock_unstable", "paths": [_path("stress_lab", TESTED, {"money": Overclock.LONG_TEST_COST}, true)]})
    return out


static func _path(test: String, level: int, needs: Dictionary = {}, boots: bool = false) -> Dictionary:
    return {"test": test, "level": level, "needs": needs, "boots": boots}


static func _open(path: Dictionary, caps: Dictionary) -> bool:
    var needs: Dictionary = path["needs"]
    if needs.has("stock") and int((caps.get("stock", {}) as Dictionary).get(str(needs["stock"]), 0)) <= 0: return false
    if needs.has("game") and (caps.get("games", []) as Array).is_empty(): return false
    if needs.has("money") and int(caps.get("money", 0)) < int(needs["money"]): return false
    return true


# Conditions that stop the PC from starting (everything a "boots" path waits for).
static func _blocks_boot(id: String) -> bool:
    return id.begins_with("missing:") or id == "psu_too_small" or id in ["faulty:gpu", "faulty:cooler", "damaged:gpu", "damaged:cooler"]


# Per condition: {"id", "level"} where level is the cheapest open path, or UNSOLVABLE.
static func assess(job: Dictionary, load_temp: float, caps: Dictionary) -> Array:
    var found: Array = conditions(job, load_temp)
    var boot_reachable: bool = true
    var levels: Dictionary = {}
    for item: Dictionary in found:
        var best: int = UNSOLVABLE
        for path: Dictionary in item["paths"]:
            if not bool(path["boots"]) and _open(path, caps): best = mini(best, int(path["level"]))
        levels[item["id"]] = best
        if _blocks_boot(str(item["id"])) and best == UNSOLVABLE: boot_reachable = false
    var out: Array = []
    for item: Dictionary in found:
        var best: int = int(levels[item["id"]])
        for path: Dictionary in item["paths"]:
            if bool(path["boots"]) and boot_reachable and _open(path, caps): best = mini(best, int(path["level"]))
        out.append({"id": item["id"], "level": best})
    return out


static func solvable(job: Dictionary, load_temp: float, caps: Dictionary) -> bool:
    return assess(job, load_temp, caps).all(func(item: Dictionary) -> bool: return int(item["level"]) != UNSOLVABLE)


# The case's difficulty: its least evident condition (0 when nothing is wrong).
static func difficulty(job: Dictionary, load_temp: float, caps: Dictionary) -> int:
    var level: int = 0
    for item: Dictionary in assess(job, load_temp, caps): level = maxi(level, int(item["level"]))
    return level
