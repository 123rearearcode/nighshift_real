# Pure report. No payout, pickup, completion, trust change or save writes.
extends RefCounted
const Legacy = preload("res://scripts/state/game_state.gd")
const Zones = preload("res://scripts/data/dust_zones.gd")
const Materials = preload("res://scripts/data/paste_materials.gd")
const Parts = preload("res://scripts/data/service_parts.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const Games = preload("res://scripts/data/games.gd")
const Software = preload("res://scripts/rules/software_checks.gd")
const Frames = preload("res://scripts/rules/fps_sim.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")

static func evaluate(job: Dictionary,owned_games: Array) -> Dictionary:
    var temp: float = Legacy.BASE_TEMP
    var notes: Array = []
    for zone: Dictionary in Zones.zones(str(job.get("layout","tower"))):
        var fraction: float = clampf(float(job["dust"].get(zone["id"],0.0)),0,1)
        var heat: float = float(zone["temp_penalty"])*(1.0-fraction)
        temp += heat
        if heat>0.2: notes.append("%s: dust adds %.1f°C."%[zone["label"],heat])
    var grade: String = str(job.get("paste_grade",""))
    if grade == "":
        temp += Legacy.NO_PASTE_PENALTY
        notes.append("CPU: no graded cooler contact. Apply paste, seat the cooler and lock its lever.")
    elif not job.get("paste_done",false):
        temp += Legacy.NO_PASTE_PENALTY
        notes.append("Cooler contact: %s. Rework the paste and lock the lever; contact is not acceptable."%grade)
    else:
        temp += float(Legacy.PASTE_PENALTY.get(grade,Legacy.NO_PASTE_PENALTY))
        var material: Dictionary = Materials.material(str(job.get("paste_material","thermal")))
        temp += float(material.get("heat_penalty",0))
        notes.append("Cooler contact: %s. Material: %s."%[grade,material.get("label","Unknown")])
    notes.append_array(PartStates.problem_lines(job))   # D115: binary per part, with the exact repair path
    var pc: Dictionary = PcBuild.effective(job)   # D148: the PC's own parts
    var gpu: float = float(pc["graphics"])
    for id: String in job.get("service_replacements",{}):
        var replacement: Dictionary = Parts.option(id,str(job["service_replacements"][id]))
        if float(replacement.get("performance",100))<100: notes.append("%s replacement: %d%% of original output."%[id.to_upper(),replacement["performance"]])
    temp += PcBuild.defect_heat(job)   # 0.50.0: a degraded shop CPU runs hot (hidden cause, visible degrees)
    var cooling: float = PcBuild.cooling_heat(job)
    if cooling > 0.0:
        temp += cooling
        notes.append("The cooler cannot remove all of the CPU's heat (+%.0f°C)."%cooling)
    var oc_heat: float = Overclock.heat(job)
    if oc_heat > 0.0:
        temp += oc_heat
        notes.append("Overclock: +%.0f°C from the CPU settings." % oc_heat)
    if Malware.live_heat(job) > 0.0:
        temp += Malware.live_heat(job)
        notes.append("The CPU is busy even though nothing should be running.")
    var boot: Dictionary = Software.boot(job)
    var boots: bool = boot["ok"]
    notes.push_front(boot["message"])
    for id: String in owned_games:
        var game: Dictionary = Games.game(id)
        if boots and not game.is_empty(): notes.append("%s: %d simulated fps."%[game["title"],Frames.fps(gpu if boots else 0,float(pc["processing"]) * Overclock.cpu_factor(job) * Malware.cpu_share(job),float(pc["ram_gb"]),game,temp)])
    return {"temp":temp,"boots":boots,"passed":boots and temp<Legacy.PASS_TEMP,"notes":notes}
