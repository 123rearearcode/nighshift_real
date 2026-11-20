# Live checks only. Pure reports: no payout, pickup, saves or modifications to customer hardware.
extends RefCounted
const Games = preload("res://scripts/data/games.gd")
const Frames = preload("res://scripts/rules/fps_sim.gd")
const Parts = preload("res://scripts/data/service_parts.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")

static func boot(job: Dictionary) -> Dictionary:
    if not bool(job.get("pc_powered",false)):
        return {"ok":false,"message":"Power is off. Use the PC power button before running live tests."}
    # D150 (0.46.2): a missing part is known and named; a part that does not work only shows as what
    # the player would see on the screen. The boot never names the faulty part.
    if not job.get("removed_parts",[]).is_empty() or not PcBuild.missing(job).is_empty():
        return {"ok":false,"message":"Boot FAILED: parts are missing.\n"+"\n".join(PartStates.problem_lines(job))}
    var symptoms: Array = PartStates.boot_symptoms(job)
    if not symptoms.is_empty():
        return {"ok":false,"message":"Boot FAILED.\n"+"\n".join(symptoms)}
    var s: Dictionary = PcBuild.effective(job)   # D148: the PSU must cover what the parts draw
    if not bool(s["powered"]):
        return {"ok":false,"message":"Boot FAILED: the power supply cannot run this PC (it needs %d W, the PSU gives %d W). Fit a bigger PSU."%[int(s["draw_w"]),int(s["psu_w"])]}
    var slow: String = "\nStarting took unusually long, and the drive clicked a few times." if "slow" in PcBuild.defects(job) else ""   # 0.50.0
    return {"ok":true,"message":"Boot OK: the PC starts. This alone does not confirm temperatures or game performance."+slow}

static func game_test(job: Dictionary,owned: Array,game_id: String,temp: float) -> Dictionary:
    var game: Dictionary = Games.game(game_id)
    if game.is_empty(): return {"ok":false,"message":"Unknown game."}
    var start: Dictionary = boot(job)
    if not start["ok"]: return start
    if not game_id in owned: return {"ok":false,"message":"Buy this game in Vapor before running its test. The licence belongs to the shop."}
    var s: Dictionary = PcBuild.effective(job)   # D148: the PC's own parts
    # D132: the overclock adds CPU power; a hidden miner takes a share of it.
    var cpu: float = float(s["processing"]) * Overclock.cpu_factor(job) * Malware.cpu_share(job)
    var fps: int = Frames.fps(float(s["graphics"]),cpu,float(s["ram_gb"]),game,temp)
    var message: String = "%s: %d simulated FPS at %.1f°C. Trial simulation, not a real benchmark."%[game["title"],fps,temp]
    # 0.50.0: what a degraded shop part does during a long game session (observations, no cause named).
    var found: Array = PcBuild.defects(job)
    if "artifacts" in found: message += "\nDuring the match, flickering coloured blocks appeared on the screen."
    if PcBuild.unstable_minute(job) >= 0: message += "\nThe game crashed to the desktop after %d minutes." % PcBuild.unstable_minute(job)
    return {"ok":true,"fps":fps,"message":message}


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
