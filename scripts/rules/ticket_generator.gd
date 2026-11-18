# RULES ONLY: generated tickets (Wave 3 session 3.5 / 0.48.0). Pure functions; every random draw comes
# from a RandomNumberGenerator seeded from the save's world seed, the night and the arrival slot, so the
# same save always produces the same mornings.
#
# User decisions, 18 November 2026 (D153): a case may need a known-good part the shop does not own,
# buying it counts as a way to solve it ("having a variety of parts is gonna be important"); new tickets
# arrive in the morning, as many as the shop's reputation and online rating bring; difficulty rises with
# the night; the pool is the existing problems plus PCs the customer overclocked and the clueless customer
# whose stated need is wrong; generated customers are parody names with a profession.
#
# A case is only offered when (1) diagnosis.gd finds an evidence path for every problem with what the shop
# owns or can afford, (2) its difficulty fits the night, and (3) the PC, once properly repaired, can meet
# the customer's real needs (a happy pickup is reachable). Otherwise it is redrawn; after a few failed
# draws a plain dusty PC is offered instead. Numbers are trial proposals (D154).
extends RefCounted

const People = preload("res://scripts/data/generated_people.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Ids = preload("res://scripts/data/ids.gd")
const Games = preload("res://scripts/data/games.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const FpsSim = preload("res://scripts/rules/fps_sim.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")
const Diagnosis = preload("res://scripts/rules/diagnosis.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Legacy = preload("res://scripts/state/game_state.gd")

const RETURN_CHANCE: float = 0.35    # an arrival is a returning customer rather than a new one
const RETURN_MIN_TRUST: int = 40     # who still trusts the shop enough to come back
const DRAWS: int = 12                # attempts before falling back to a plain dusty PC
const GAME: String = "counter_stroke_2"
const FPS_STEPS: Array = [30, 45, 60, 90, 120, 144]

# Problem pool. level = how evident it usually is (diagnosis.gd assesses the real case);
# groups = problems that cannot share one PC (both stop the start, both concern the GPU, ...).
const EVENTS: Dictionary = {
    "dust": {"level": 1, "groups": ["dust"], "say": "It gets hot and the fans are really loud."},
    "gpu_out": {"level": 1, "groups": ["start", "gpu"], "say": "I took the graphics card out to clean it and couldn't get it back in; it's in the bag."},
    "ram_out": {"level": 1, "groups": ["start", "ram"], "say": "I pulled the memory out to check something and now it won't start; the sticks are in the bag."},
    "psu_small": {"level": 1, "groups": ["start", "gpu"], "say": "I fitted a bigger graphics card myself and now it won't turn on."},
    "adware": {"level": 2, "groups": ["malware"], "say": "Pop-ups everywhere, and the browser keeps opening strange sites."},
    "miner": {"level": 2, "groups": ["malware"], "say": "It's slow and hot even when I'm not doing anything."},
    "overclock": {"level": 2, "groups": ["oc"], "say": "A friend made it \"faster\" in some settings; now it crashes after a while under load."},
    "gpu_fault": {"level": 3, "groups": ["start", "gpu"], "say": "It powers on and the fans spin, but the screen stays black."},
    "cooler_fault": {"level": 3, "groups": ["start", "cooler"], "say": "It switches itself off a few seconds after I turn it on."},
    "dead_gpu2": {"level": 3, "groups": ["gpu"], "say": "It has two graphics cards, but games run as if it only had one."},
}


static func rng_for(seed: int, night: int, slot: int) -> RandomNumberGenerator:
    var r := RandomNumberGenerator.new()
    r.seed = hash("%d:%d:%d" % [seed, night, slot])
    return r


static func _pick(r: RandomNumberGenerator, list: Array) -> Variant:
    return list[r.randi_range(0, list.size() - 1)]


# ---- how hard tonight's cases may be (how many arrive: shop_rating.gd) ----

static func max_level(night: int) -> int:
    if night <= 1: return Diagnosis.EVIDENT
    if night <= 3: return Diagnosis.TESTED
    return Diagnosis.COMPARED


static func extra_problems(night: int) -> int:
    if night <= 2: return 0
    if night <= 4: return 1
    return 2


# ---- the person ----

static func profession(r: RandomNumberGenerator) -> String:
    var total: int = 0
    for p: String in People.PROFESSIONS: total += int(People.PROFESSION_WEIGHTS[p])
    var roll: int = r.randi_range(1, total)
    for p: String in People.PROFESSIONS:
        roll -= int(People.PROFESSION_WEIGHTS[p])
        if roll <= 0: return p
    return "regular"


# A new fictional customer (no needs or PC yet: those come with their first case).
static func new_person(r: RandomNumberGenerator, id: String) -> Dictionary:
    var job_kind: String = profession(r)
    var texts: Dictionary = People.TEXTS[job_kind]
    return {"id": id, "name": "%s %s." % [_pick(r, People.FIRST_NAMES), People.INITIALS[r.randi_range(0, People.INITIALS.length() - 1)]],
        "portrait": "", "scripted": false, "generated": true, "profession": job_kind,
        "persona": _pick(r, texts["persona"]), "about": _pick(r, texts["about"]), "uses": _pick(r, texts["uses"]),
        "habits": _pick(r, texts["habits"]), "patience": _pick(r, texts["patience"]), "complaint": "",
        "trust_start": r.randi_range(40, 65), "budget": 0, "payout": 0, "needs": {"boots": true}, "pc": {}}


# ---- the PC they bring ----

static func _cheapest(type: String, ok: Callable) -> String:
    var best: String = ""
    for id: String in Catalog.of_type(type):
        if ok.call(Catalog.part(id)) and (best == "" or int(Catalog.part(id)["price"]) < int(Catalog.part(best)["price"])): best = id
    return best


# A healthy PC that suits the profession; later nights allow better parts.
static func build_pc(r: RandomNumberGenerator, job_kind: String, night: int) -> Dictionary:
    var cpus: Array = ["cpu_pentium_g4650", "cpu_i5_6060"]
    var gpus: Array = ["gpu_gtx1550ti", "gpu_gtx1660"]
    var ram: Array = ["ram_4gb", "ram_8gb"]
    var drives: Array = ["sto_hdd_500", "sto_ssd_500"]
    if job_kind == "gamer":
        cpus = ["cpu_i5_6060", "cpu_rysen5_3060"]
        gpus = ["gpu_gtx1660", "gpu_rx6060"]
        ram = ["ram_8gb", "ram_16gb"]
        drives = ["sto_ssd_500", "sto_nvme_1tb"]
        if night >= 4:
            cpus.append("cpu_i7_12070")
            gpus.append("gpu_rtx3800")
    var cpu: String = _pick(r, cpus)
    var gpu: String = _pick(r, gpus)
    var sticks: Array = []
    for i in range(r.randi_range(1, 2)): sticks.append(_pick(r, ram))
    var parts: Dictionary = {"cpu": cpu, "gpus": [gpu], "ram": sticks, "storage": [_pick(r, drives)], "psu": "", "cooler": ""}
    var heat: int = int(Catalog.part(cpu)["watts"])
    parts["cooler"] = _cheapest(Catalog.COOLER, func(p: Dictionary) -> bool: return int(p["capacity"]) >= heat)
    fit_psu(parts)
    return parts


# The cheapest power supply that runs these parts.
static func fit_psu(parts: Dictionary) -> void:
    parts["psu"] = ""
    var draw: int = int(PcBuild.stats(parts)["draw_w"])
    parts["psu"] = _cheapest(Catalog.PSU, func(p: Dictionary) -> bool: return int(p["watts"]) >= draw)


# ---- problems ----

static func _conflicts(chosen: Array, id: String) -> bool:
    for other: String in chosen:
        for g: String in EVENTS[other]["groups"]:
            if g in EVENTS[id]["groups"]: return true
    return false


# The problems of one case: one at the target level, plus easier extras on later nights.
static func choose_events(r: RandomNumberGenerator, night: int) -> Array:
    var target: int = r.randi_range(1, max_level(night))
    var main: Array = EVENTS.keys().filter(func(id: String) -> bool: return int(EVENTS[id]["level"]) == target)
    var chosen: Array = [_pick(r, main)]
    for i in range(r.randi_range(0, extra_problems(night))):
        var pool: Array = EVENTS.keys().filter(func(id: String) -> bool: return int(EVENTS[id]["level"]) <= target and not id in chosen and not _conflicts(chosen, id))
        if pool.is_empty(): break
        chosen.append(_pick(r, pool))
    return chosen


# Applies the problems to a fresh job (its parts already the customer's PC). Returns false when a
# problem cannot apply to this PC (the draw is then retried).
static func apply_events(job: Dictionary, events: Array, r: RandomNumberGenerator) -> bool:
    var parts: Dictionary = PcBuild.sanitize(job["parts"])
    var dust: Dictionary = job["dust"]
    if not "dust" in events:
        # A customer who keeps the PC fairly clean: some parts arrive clean, at least one never.
        var zones: Array = dust.keys().filter(func(z: String) -> bool: return z != "case_interior")
        for z: String in zones: dust[z] = 1.0 if r.randf() < 0.6 else 0.0
        if not zones.is_empty(): dust[_pick(r, zones)] = 0.0
    for id: String in events:
        match id:
            "gpu_out":
                job["removed_parts"].append(Ids.GPU)
                job["gpu_screws"] = 0
            "ram_out":
                for stick: Variant in parts["ram"]: job["loose_parts"].append({"id": str(stick), "broken": false, "damaged": false, "original_of": ""})
                parts["ram"] = []
            "psu_small":
                parts["gpus"] = ["gpu_rtx3800"]
                if int(Catalog.part(str(parts["cpu"]))["watts"]) < 80: parts["cpu"] = "cpu_rysen5_3060"
                var heat: int = int(Catalog.part(str(parts["cpu"]))["watts"])
                if int(Catalog.part(str(parts["cooler"]))["capacity"]) < heat:
                    parts["cooler"] = _cheapest(Catalog.COOLER, func(p: Dictionary) -> bool: return int(p["capacity"]) >= heat)
                var draw: int = int(PcBuild.stats(parts)["draw_w"])
                var small: String = ""
                for psu: String in Catalog.of_type(Catalog.PSU):
                    var w: int = int(Catalog.part(psu)["watts"])
                    if w < draw and (small == "" or w > int(Catalog.part(small)["watts"])): small = psu
                if small == "": return false
                parts["psu"] = small
            "adware": Malware.infect(job, Malware.ADWARE)
            "miner": Malware.infect(job, Malware.MINER)
            "overclock": job["overclock"] = {"mult": r.randi_range(1, 2), "volt": 0}
            "gpu_fault": job["broken_parts"].append(Ids.GPU)
            "cooler_fault": job["broken_parts"].append(Ids.COOLER)
            "dead_gpu2":
                parts["gpus"] = [parts["gpus"][0], parts["gpus"][0]]
                job["layout"] = "tower"
                job["dead_slots"] = [PcBuild.GPU2_SLOT]
                fit_psu(parts)
    job["parts"] = PcBuild.sanitize(parts)
    job["pc_specs"] = PcBuild.specs(job["parts"])
    return true


# What the customer says: one sentence per problem, in the order drawn. Never names a hidden part.
static func complaint(events: Array) -> String:
    var lines: Array = []
    for id: String in events: lines.append(str(EVENTS[id]["say"]))
    return " ".join(lines)


static func payout(events: Array) -> int:
    var pay: int = 30
    for id: String in events: pay += 15 * int(EVENTS[id]["level"])
    return pay


# ---- proving the case can end well ----

# The job as it would stand after a proper repair (for the happy-ending proof only): clean, perfect
# paste, no malware or overclock, parts back in, faulty parts replaced like for like, a power supply
# that runs it (bought, when the shop can afford one). {} when the repair is out of reach.
static func repaired(job: Dictionary, money: int) -> Dictionary:
    var fixed: Dictionary = job.duplicate(true)
    for z: Variant in fixed["dust"]: fixed["dust"][z] = 1.0
    fixed["paste_grade"] = "PERFECT"
    fixed["paste_done"] = true
    fixed["paste_material"] = "thermal"
    fixed["infection"] = ""
    fixed["overclock"] = {"mult": 0, "volt": 0}
    fixed["broken_parts"] = []
    fixed["dead_slots"] = []
    fixed["removed_parts"] = []
    var parts: Dictionary = PcBuild.sanitize(fixed["parts"])
    for item: Variant in fixed.get("loose_parts", []):
        if item is Dictionary and Catalog.is_type(str(item["id"]), Catalog.RAM): (parts["ram"] as Array).append(str(item["id"]))
    fixed["loose_parts"] = []
    if not bool(PcBuild.stats(parts)["powered"]):
        var draw: int = int(PcBuild.stats(parts)["draw_w"])
        var psu: String = _cheapest(Catalog.PSU, func(p: Dictionary) -> bool: return int(p["watts"]) >= draw)
        if psu == "" or int(Catalog.part(psu)["price"]) > money: return {}
        parts["psu"] = psu
    fixed["parts"] = PcBuild.sanitize(parts)
    fixed["pc_specs"] = PcBuild.specs(fixed["parts"])
    return fixed


# FPS of the healthy PC in the test game, at its repaired temperature.
static func healthy_fps(fixed: Dictionary) -> int:
    var s: Dictionary = PcBuild.effective(fixed)
    var temp: float = float(Diagnostics.evaluate(fixed, [])["temp"])
    return FpsSim.fps(float(s["graphics"]), float(s["processing"]), float(s["ram_gb"]), Games.game(GAME), temp)


# What this person needs from this PC, so that a proper repair can satisfy them.
static func needs_for(person: Dictionary, fixed: Dictionary, r: RandomNumberGenerator) -> Dictionary:
    var quiet: bool = r.randf() < 0.5
    match str(person["profession"]):
        "gamer":
            var fps: int = healthy_fps(fixed)
            var want: int = 0
            for step: int in FPS_STEPS:
                if step <= int(fps * 0.95): want = step
            if want == 0: return {"boots": true}
            return {"boots": true, "games": [{"game_id": GAME, "min_fps": want}]}
        "clueless":
            return {"stated": People.DECOY_NEED.duplicate(true), "real": {"boots": true, "quiet": quiet}}
    return {"boots": true, "quiet": quiet}


# Checks a drawn case. Returns {ok, level, reason}.
static func check(job: Dictionary, person: Dictionary, caps: Dictionary, night: int) -> Dictionary:
    var temp: float = float(Diagnostics.evaluate(job, [])["temp"])
    if not Diagnosis.solvable(job, temp, caps): return {"ok": false, "level": Diagnosis.UNSOLVABLE, "reason": "no evidence path"}
    var level: int = Diagnosis.difficulty(job, temp, caps)
    if level > max_level(night): return {"ok": false, "level": level, "reason": "too hard for this night"}
    var fixed: Dictionary = repaired(job, int(caps.get("money", 0)))
    if fixed.is_empty(): return {"ok": false, "level": level, "reason": "the repair is out of reach"}
    var s: Dictionary = PcBuild.effective(fixed)
    var fixed_temp: float = float(Diagnostics.evaluate(fixed, [])["temp"])
    if not bool(s["powered"]) or fixed_temp >= Legacy.PASS_TEMP: return {"ok": false, "level": level, "reason": "even repaired it fails"}
    var result: Dictionary = PickupScore.score(person, fixed_temp, float(s["graphics"]), float(s["processing"]), float(s["ram_gb"]), Legacy.PASS_TEMP, [])
    if int(result["score"]) < PickupScore.HAPPY_FROM: return {"ok": false, "level": level, "reason": "the customer could not be satisfied"}
    return {"ok": true, "level": level, "reason": ""}


# Draws one case for `person` onto `job` (a fresh job for them). `pc` = the PC they own ({} = new one).
# Returns {job, person, events, level, fallback}. The person record gets their PC, needs and pay terms.
static func draw_case(job: Dictionary, person: Dictionary, pc: Dictionary, caps: Dictionary, night: int, r: RandomNumberGenerator) -> Dictionary:
    var base_pc: Dictionary = pc if not pc.is_empty() else build_pc(r, str(person["profession"]), night)
    for attempt in range(DRAWS):
        var trial: Dictionary = job.duplicate(true)
        var who: Dictionary = person.duplicate(true)
        trial["parts"] = PcBuild.sanitize(base_pc)
        trial["layout"] = "tower" if r.randf() < 0.5 else "compact"
        var events: Array = choose_events(r, night)
        if not apply_events(trial, events, r): continue
        # 0.48.1: a motherboard model that fits the case (the layout is final once the problems are applied).
        trial["parts"]["board"] = _pick(r, Catalog.boards_for("compact" if str(trial["layout"]) == "compact" else "tower"))
        var fixed: Dictionary = repaired(trial, int(caps.get("money", 0)))
        if fixed.is_empty(): continue
        if not bool(person.get("scripted", false)): who["needs"] = needs_for(who, fixed, r)
        var verdict: Dictionary = check(trial, who, caps, night)
        if not bool(verdict["ok"]): continue
        return _finish(trial, who, base_pc, events, int(verdict["level"]), false)
    # Fallback: their PC, dusty, nothing else wrong (always evident and always fixable).
    var plain: Dictionary = job.duplicate(true)
    plain["parts"] = PcBuild.sanitize(base_pc)
    plain["pc_specs"] = PcBuild.specs(plain["parts"])
    var simple: Dictionary = person.duplicate(true)
    if not bool(person.get("scripted", false)): simple["needs"] = {"boots": true}
    return _finish(plain, simple, base_pc, ["dust"], Diagnosis.EVIDENT, true)


static func _finish(job: Dictionary, person: Dictionary, pc: Dictionary, events: Array, level: int, fallback: bool) -> Dictionary:
    job["complaint"] = complaint(events)
    job["payout"] = payout(events)
    job["customer_id"] = str(person["id"])
    job["customer"] = str(person["name"])
    person["pc"] = PcBuild.sanitize(pc)
    person["complaint"] = job["complaint"]
    person["payout"] = job["payout"]
    person["budget"] = int(job["payout"]) + 60
    return {"job": job, "person": person, "events": events, "level": level, "fallback": fallback}
