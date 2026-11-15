# Live checks only. Pure reports: no payout, pickup, saves or modifications to customer hardware.
extends RefCounted
const Games = preload("res://scripts/data/games.gd")
const Frames = preload("res://scripts/rules/fps_sim.gd")
const Parts = preload("res://scripts/data/service_parts.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")

static func boot(job: Dictionary) -> Dictionary:
    if not bool(job.get("pc_powered",false)):
        return {"ok":false,"message":"Power is off. Use the PC power button before running live tests."}
    var problems: Array = PartStates.problem_lines(job)
    if not job.get("broken_parts",[]).is_empty() or not job.get("removed_parts",[]).is_empty():
        return {"ok":false,"message":"Boot FAILED. Fit and repair the missing/broken parts first.\n"+"\n".join(problems)}
    return {"ok":true,"message":"Boot OK: the PC starts. This alone does not confirm temperatures or game performance."}

static func game_test(job: Dictionary,owned: Array,game_id: String,temp: float) -> Dictionary:
    var game: Dictionary = Games.game(game_id)
    if game.is_empty(): return {"ok":false,"message":"Unknown game."}
    var start: Dictionary = boot(job)
    if not start["ok"]: return start
    if not game_id in owned: return {"ok":false,"message":"Buy this game in Vapor before running its test. The licence belongs to the shop."}
    var gpu: float = 100.0
    var replacement: String = str(job.get("service_replacements",{}).get("gpu",""))
    if replacement != "": gpu = float(Parts.option("gpu",replacement).get("performance",100))
    var specs: Dictionary = job.get("pc_specs",{})
    # D132: the overclock adds CPU power; a hidden miner takes a share of it.
    var cpu: float = float(specs.get("cpu_power",100)) * Overclock.cpu_factor(job) * Malware.cpu_share(job)
    var fps: int = Frames.fps(gpu,cpu,float(specs.get("ram_gb",8)),game,temp)
    return {"ok":true,"fps":fps,"message":"%s: %d simulated FPS at %.1f°C. Trial simulation, not a real benchmark."%[game["title"],fps,temp]}


# D132: the anti-virus. Needs a booted PC like every live test.
static func antivirus(job: Dictionary) -> Dictionary:
    var start: Dictionary = boot(job)
    if not start["ok"]: return start
    var report: Dictionary = Malware.scan(job)
    report["ok"] = true
    return report

# D132: the overclocker's stress test. Needs a booted PC.
static func stress(job: Dictionary,temp: float,long_test: bool) -> Dictionary:
    var start: Dictionary = boot(job)
    if not start["ok"]: return start
    return Overclock.stress(job,temp,long_test)
