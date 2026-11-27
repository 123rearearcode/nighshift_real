# RULES ONLY: build requests (Wave 3 session 3.7 / 0.51.0, D159). Pure functions.
#
# A customer comes with a USE (the rescaled uses table, approved 20 November 2026), maybe a few WANTS and a
# BUDGET. Needs are hard minimums; wants are soft extras that move the reaction (D140). The customer pays
# their budget, half up front and half on collection; the shop's profit is the budget minus what the parts
# cost, and nobody pays more than their budget (user, 20 November 2026). Assembly costs night time.
# The shop starts each build with an empty basic case and the cheapest motherboard that fits it (both
# charged from the deposit); cases and boards can be swapped while the case is empty.
#
# A request is only offered when the cheapest build that meets the needs exists in the catalogue and the
# shop can pay for it with its cash plus the deposit, so every build request can end well.
#
# Scam hooks kept on purpose (user, 20 November 2026: "yeah, agreed"; standing instruction to leave room):
#   - salvaged or untested parts sold at new prices: delivered() counts parts by what the shop KNEW;
#   - a cheaper part than the customer asked for (a want or the brand quietly skipped): review() names it;
#   - charging the full budget for a much cheaper PC: delivered() keeps the catalogue value next to the
#     budget. No consequences are simulated yet; they are recorded for a later scam system.
# All numbers and texts are trial proposals.
extends RefCounted

const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Games = preload("res://scripts/data/games.gd")
const Ids = preload("res://scripts/data/ids.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const FpsSim = preload("res://scripts/rules/fps_sim.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")
const PartCondition = preload("res://scripts/rules/part_condition.gd")

const FIRST_NIGHT: int = 4          # user: "build requests start on nights 4-5"
const SURE_NIGHT: int = 5           # the first arrival of night 5 is always a build request
const CHANCE: float = 0.3           # any other arrival from night 4 on
const DEPOSIT_SHARE: float = 0.5    # half up front, half on collection
const GAME: String = "counter_stroke_2"

# Rescaled uses table (catalogue scale 0..100; user approved 20 November 2026). "from" = first night it
# can be asked for. Gaming and streaming are worked out from the game and the frame rate the customer wants.
const USES: Dictionary = {
    "light_office": {"label": "Light office work", "processing": 10, "graphics": 0, "ram_gb": 8, "storage_gb": 250, "from": 4,
        "say": "I need a simple PC for email, documents and browsing."},
    "medium_office": {"label": "Medium office work", "processing": 20, "graphics": 0, "ram_gb": 16, "storage_gb": 500, "from": 4,
        "say": "I work from home: spreadsheets, video calls and lots of browser tabs at once."},
    "school": {"label": "School / kid's PC", "processing": 15, "graphics": 10, "ram_gb": 8, "storage_gb": 500, "from": 4,
        "say": "A PC for my kid: homework, and a few light games on weekends."},
    "gaming": {"label": "Gaming", "from": 4, "say": "I want a PC for Counter Stroke 2."},
    "heavy_office": {"label": "Heavy office work", "processing": 30, "graphics": 10, "ram_gb": 32, "storage_gb": 1000, "from": 6,
        "say": "Big spreadsheets, databases and three monitors. It has to keep up."},
    "music": {"label": "Music production", "processing": 30, "graphics": 0, "ram_gb": 32, "storage_gb": 1000, "from": 6,
        "say": "I record and mix music: lots of tracks and sample libraries."},
    "video": {"label": "Video editing", "processing": 40, "graphics": 30, "ram_gb": 32, "storage_gb": 2000, "from": 6,
        "say": "I edit videos for clients, mostly 4K footage."},
    "streaming": {"label": "Gaming and streaming", "from": 6, "say": "I play Counter Stroke 2 and stream it live at the same time."},
    "mining": {"label": "Crypto mining", "processing": 10, "graphics": 60, "ram_gb": 8, "storage_gb": 250, "from": 6, "tower": true,
        "say": "I want a mining rig. Graphics power, nothing else matters."},
}
const GAME_USES: Array = ["gaming", "streaming"]
const STREAM_EXTRA: Dictionary = {"processing": 15, "ram_gb": 16, "storage_gb": 500}
const FPS_EARLY: Array = [60, 90]
const FPS_LATER: Array = [60, 90, 120, 144]

# Wants (user, 20 November 2026: quiet, headroom, a favourite brand, extra storage).
const QUIET := "quiet"
const HEADROOM := "headroom"
const BRAND := "brand"
const STORAGE := "storage"
const WANTS: Array = [QUIET, HEADROOM, BRAND, STORAGE]
const HEADROOM_SHARE: float = 1.3   # a third more processing / graphics / frames than needed
const STORAGE_SHARE: float = 2.0    # twice the storage
const BRANDS: Dictionary = {"cpu": ["Intol", "AMB"], "gpu": ["Nvidya", "AMB"]}
# Fans: a cooler or PSU working near its limit spins loud. A sound-dampened case hides one loud fan.
const COOLER_QUIET_LOAD: float = 0.75
const PSU_QUIET_LOAD: float = 0.8

const MISSED_NEED_COST: float = 40.0
const MISSED_WANT_COST: float = 10.0

# Night minutes per assembly step (fitting only; taking a part out again is quick and free).
const MINUTES: Dictionary = {"cpu": 5, "ram": 3, "storage": 4, "psu": 8, "gpu": 5, "cooler": 10, "board": 10, "case": 15}
const PLACEHOLDER_GPU := "gpu_gtx1550ti"        # never shown: a build's first GPU slot is empty (removed_parts)
const PLACEHOLDER_COOLER := "cool_wraith_stelth"
const PASTE_GRADE := "GOOD ENOUGH"              # a build cooler goes on with its pre-applied paste (proposal)


static func is_build(job: Dictionary) -> bool:
    return PcBuild.is_build(job)


static func minutes(kind: String) -> int:
    return int(MINUTES.get(kind, 0))


# ---- the request ----

# Whether arrival `slot` of `night` is a build request. `r` is its own generator (the repair draw is unchanged).
static func wanted(r: RandomNumberGenerator, night: int, slot: int) -> bool:
    if night < FIRST_NIGHT: return false
    if night == SURE_NIGHT and slot == 0: return true
    return r.randf() < CHANCE


static func uses_for(night: int) -> Array:
    return USES.keys().filter(func(id: String) -> bool: return int(USES[id]["from"]) <= night)


# The stat minimums of a use: {processing, graphics, ram_gb, storage_gb, game: {} or {game_id, min_fps}}.
static func needs_for(use: String, fps: int) -> Dictionary:
    var u: Dictionary = USES.get(use, USES["light_office"])
    if not use in GAME_USES:
        return {"processing": int(u["processing"]), "graphics": int(u["graphics"]), "ram_gb": int(u["ram_gb"]), "storage_gb": int(u["storage_gb"]), "game": {}}
    var game: Dictionary = Games.game(GAME)
    var share: float = float(fps) / Games.BASE_FPS
    var needs: Dictionary = {"processing": ceili(float(game["cpu_demand"]) * share), "graphics": ceili(float(game["gpu_demand"]) * share),
        "ram_gb": int(game["ram_min"]), "storage_gb": int(game["size_gb"]), "game": {"game_id": GAME, "min_fps": fps}}
    if use == "streaming":
        for key: String in STREAM_EXTRA: needs[key] = int(needs[key]) + int(STREAM_EXTRA[key])
    return needs


# Rebuilds a saved build record from known shapes only ({} when it is not a build record).
static func sanitize(raw: Variant) -> Dictionary:
    if not raw is Dictionary: return {}
    var r: Dictionary = raw
    var use: String = str(r.get("use", ""))
    if not USES.has(use): return {}
    var needs: Dictionary = needs_for(use, 60)
    var raw_needs: Variant = r.get("needs", {})
    if raw_needs is Dictionary:
        for key: String in ["processing", "graphics", "ram_gb", "storage_gb"]:
            var v: Variant = (raw_needs as Dictionary).get(key, needs[key])
            if typeof(v) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(v)): needs[key] = clampi(int(v), 0, 100000)
        var g: Variant = (raw_needs as Dictionary).get("game", {})
        if g is Dictionary and not Games.game(str((g as Dictionary).get("game_id", ""))).is_empty() and typeof((g as Dictionary).get("min_fps", 0)) in [TYPE_INT, TYPE_FLOAT]:
            needs["game"] = {"game_id": str(g["game_id"]), "min_fps": clampi(int(g["min_fps"]), 1, 500)}
        elif not use in GAME_USES: needs["game"] = {}
    var wants: Array = []
    var raw_wants: Variant = r.get("wants", [])
    if raw_wants is Array:
        for w: Variant in raw_wants:
            var clean: Dictionary = _want(w)
            if not clean.is_empty() and not wants.any(func(x: Dictionary) -> bool: return x["id"] == clean["id"]): wants.append(clean)
    var out: Dictionary = {"use": use, "needs": needs, "wants": wants}
    for key: String in ["budget", "deposit"]:
        var v: Variant = r.get(key, 0)
        out[key] = clampi(int(v), 0, 1000000) if typeof(v) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(v)) else 0
    out["deposit"] = mini(int(out["deposit"]), int(out["budget"]))
    var raw_delivered: Variant = r.get("delivered", {})
    if raw_delivered is Dictionary and not (raw_delivered as Dictionary).is_empty():
        var d: Dictionary = {}
        for key: String in ["value", "parts", "new", "untested", "tested", "salvaged"]:
            var v: Variant = (raw_delivered as Dictionary).get(key, 0)
            d[key] = clampi(int(v), 0, 1000000) if typeof(v) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(v)) else 0
        out["delivered"] = d
    return out


static func _want(raw: Variant) -> Dictionary:
    if not raw is Dictionary: return {}
    var id: String = str((raw as Dictionary).get("id", ""))
    if not id in WANTS: return {}
    if id != BRAND: return {"id": id}
    var part: String = str((raw as Dictionary).get("part", ""))
    var brand: String = str((raw as Dictionary).get("brand", ""))
    if not BRANDS.has(part) or not brand in BRANDS[part]: return {}
    return {"id": id, "part": part, "brand": brand}


static func record(job: Dictionary) -> Dictionary:
    return sanitize(job.get("build", {}))


# ---- what a set of parts gives, and whether it meets a request ----

# Parts record -> stats, through the same rules every PC uses.
static func stats_of(parts: Dictionary) -> Dictionary:
    return PcBuild.stats(parts)


# The fans that would be loud: the cooler or the PSU working close to its limit, or a hot PC.
static func loud_sources(stats: Dictionary, temp: float) -> Array:
    var out: Array = []
    if int(stats["cooler_w"]) > 0 and float(stats["cpu_heat_w"]) > float(stats["cooler_w"]) * COOLER_QUIET_LOAD: out.append("the CPU cooler fan")
    if int(stats["psu_w"]) > 0 and float(stats["draw_w"]) > float(stats["psu_w"]) * PSU_QUIET_LOAD: out.append("the power supply fan")
    if temp > PickupScore.COOL_TEMP + 10.0: out.append("every fan: it runs hot")
    return out


static func quiet(stats: Dictionary, temp: float, case_id: String) -> bool:
    var loud: int = loud_sources(stats, temp).size()
    return loud == 0 or (loud == 1 and bool(Catalog.CASES.get(case_id, {}).get("quiet", false)))


static func _brand(id: String) -> String:
    return str(Catalog.part(id).get("brand", "")) if id != "" else ""


# What the PC as delivered misses. `stats` = PcBuild.effective of the job (or stats of a parts record),
# `parts` its parts, `cpu_factor` the overclock factor. Returns {needs: [texts], wants: [texts]}.
static func review(build: Dictionary, stats: Dictionary, parts: Dictionary, case_id: String, temp: float, cpu_factor: float = 1.0) -> Dictionary:
    var needs: Dictionary = build.get("needs", {})
    var missed: Array = []
    var processing: float = float(stats["processing"]) * cpu_factor
    if processing < float(needs.get("processing", 0)): missed.append("not enough processing power (%d, needs %d)" % [roundi(processing), int(needs["processing"])])
    if int(stats.get("gpu_count", 0)) == 0: missed.append("no graphics card")
    elif float(stats["graphics"]) < float(needs.get("graphics", 0)): missed.append("not enough graphics power (%d, needs %d)" % [roundi(float(stats["graphics"])), int(needs["graphics"])])
    if int(stats["ram_gb"]) < int(needs.get("ram_gb", 0)): missed.append("not enough memory (%d GB, needs %d GB)" % [int(stats["ram_gb"]), int(needs["ram_gb"])])
    if int(stats["storage_gb"]) < int(needs.get("storage_gb", 0)): missed.append("not enough storage (%d GB, needs %d GB)" % [int(stats["storage_gb"]), int(needs["storage_gb"])])
    var game: Dictionary = needs.get("game", {})
    var frames: int = -1
    if not game.is_empty():
        frames = FpsSim.fps(float(stats["graphics"]), processing, float(stats["ram_gb"]), Games.game(str(game["game_id"])), temp)
        if frames < int(game["min_fps"]): missed.append("%s runs at %d FPS, they wanted %d" % [str(Games.game(str(game["game_id"]))["title"]), frames, int(game["min_fps"])])
    var wants_missed: Array = []
    for w: Dictionary in build.get("wants", []):
        var want: String = str(w["id"])
        if want == QUIET:
            var loud: Array = loud_sources(stats, temp)
            if not quiet(stats, temp, case_id): wants_missed.append("they wanted it quiet: " + ", ".join(loud) + (" is" if loud.size() == 1 else " are") + " loud")
        elif want == HEADROOM:
            var short: bool = processing < float(needs.get("processing", 0)) * HEADROOM_SHARE
            if float(needs.get("graphics", 0)) > 0.0 and float(stats["graphics"]) < float(needs["graphics"]) * HEADROOM_SHARE: short = true
            if frames >= 0 and float(frames) < float(game["min_fps"]) * HEADROOM_SHARE: short = true
            if short: wants_missed.append("they wanted room to grow, and it only just does the job")
        elif want == BRAND:
            var gpus: Array = parts.get("gpus", [])
            var id: String = str(parts.get("cpu", "")) if str(w["part"]) == "cpu" else (str(gpus[0]) if not gpus.is_empty() else "")
            if _brand(id) != str(w["brand"]): wants_missed.append("they wanted " + want_text(w))
        elif want == STORAGE:
            if float(stats["storage_gb"]) < float(needs.get("storage_gb", 0)) * STORAGE_SHARE: wants_missed.append("they wanted extra storage (%d GB, hoped for %d GB)" % [int(stats["storage_gb"]), roundi(float(needs.get("storage_gb", 0)) * STORAGE_SHARE)])
    return {"needs": missed, "wants": wants_missed}


# A pickup result ({score, misses}) adjusted by the build's needs and wants.
static func adjust(result: Dictionary, review_result: Dictionary) -> Dictionary:
    var out: Dictionary = result.duplicate(true)
    var points: float = float(out["score"])
    points -= MISSED_NEED_COST * (review_result["needs"] as Array).size()
    points -= MISSED_WANT_COST * (review_result["wants"] as Array).size()
    (out["misses"] as Array).append_array(review_result["needs"])
    (out["misses"] as Array).append_array(review_result["wants"])
    out["score"] = clampi(roundi(points), 0, 100)
    return out


# ---- the cheapest build that meets a request (solvability and budget) ----

static func _cheapest(type: String, ok: Callable) -> String:
    var best: String = ""
    for id: String in Catalog.of_type(type):
        if ok.call(Catalog.part(id)) and (best == "" or int(Catalog.part(id)["price"]) < int(Catalog.part(best)["price"])): best = id
    return best


static func _price(id: String) -> int:
    return int(Catalog.part(id).get("price", 0)) if id != "" else 0


# Cheapest list of up to `most` parts of `type` whose "gb" adds up to at least `need`.
static func _cheapest_sum(type: String, need: int, most: int) -> Array:
    var ids: Array = Catalog.of_type(type)
    var best: Array = []
    var best_price: int = -1
    var combos: Array = [[]]
    for n in range(most):
        var next: Array = []
        for combo: Array in combos:
            var start: int = 0 if combo.is_empty() else ids.find(combo[combo.size() - 1])
            for i in range(start, ids.size()):
                var c: Array = combo.duplicate()
                c.append(ids[i])
                next.append(c)
        combos = next
        for combo: Array in combos:
            var gb: int = 0
            var price: int = 0
            for id: Variant in combo:
                gb += int(Catalog.part(str(id))["gb"])
                price += _price(str(id))
            if gb >= need and (best_price < 0 or price < best_price):
                best = combo
                best_price = price
    return best


# GPU sets to try: every single card, and (tower only) every pair.
static func _gpu_sets(form: String) -> Array:
    var ids: Array = Catalog.of_type(Catalog.GPU)
    var out: Array = []
    for i in range(ids.size()):
        out.append([ids[i]])
        if form == "tower":
            for k in range(i, ids.size()): out.append([ids[i], ids[k]])
    return out


# {cost, parts} of the cheapest catalogue build in this form that meets the needs (and `wants`, when
# given). {} when none exists. Includes the case and the motherboard.
# B57: cheapest() is a pure function of its arguments and the fixed catalogue, so its answers are remembered
# (a morning draws up to 12 attempts per build slot, two searches each, and the same needs come back often).
# A low-cash shop used to stall for 0.2–0.3 s per slot. Callers get a copy, so the cache cannot be changed.
const CACHE_LIMIT := 512
static var use_cache: bool = true       # tests turn it off to compare against the plain search
static var searches: int = 0            # how many real searches ran (tests)
static var _cache: Dictionary = {}


static func cheapest(needs: Dictionary, form: String, wants: Array = []) -> Dictionary:
    if not use_cache: return _search(needs, form, wants)
    var key: String = JSON.stringify([needs, form, wants], "", true, true)
    if not _cache.has(key):
        if _cache.size() >= CACHE_LIMIT: _cache.clear()
        _cache[key] = _search(needs, form, wants)
    return (_cache[key] as Dictionary).duplicate(true)


static func _search(needs: Dictionary, form: String, wants: Array) -> Dictionary:
    searches += 1
    var want_ids: Array = wants.map(func(w: Dictionary) -> String: return str(w["id"]))
    var share: float = HEADROOM_SHARE if HEADROOM in want_ids else 1.0
    var need_p: float = float(needs.get("processing", 0)) * share
    var need_g: float = float(needs.get("graphics", 0)) * share
    var game: Dictionary = needs.get("game", {})
    if not game.is_empty():
        var g: Dictionary = Games.game(str(game["game_id"]))
        var fps_share: float = float(game["min_fps"]) * share / Games.BASE_FPS
        need_p = maxf(need_p, float(g["cpu_demand"]) * fps_share)
        need_g = maxf(need_g, float(g["gpu_demand"]) * fps_share)
    var ram: Array = _cheapest_sum(Catalog.RAM, int(needs.get("ram_gb", 0)), 3)
    var storage: Array = _cheapest_sum(Catalog.STORAGE, roundi(float(needs.get("storage_gb", 0)) * (STORAGE_SHARE if STORAGE in want_ids else 1.0)), 2)
    if ram.is_empty() or storage.is_empty(): return {}
    var brand: Dictionary = {}
    for w: Dictionary in wants:
        if str(w["id"]) == BRAND: brand = w
    var board: String = Catalog.cheapest_board(form)
    var best: Dictionary = {}
    for cpu: String in Catalog.of_type(Catalog.CPU):
        if float(Catalog.part(cpu)["processing"]) < need_p: continue
        if str(brand.get("part", "")) == "cpu" and _brand(cpu) != str(brand["brand"]): continue
        for gpus: Array in _gpu_sets(form):
            if str(brand.get("part", "")) == "gpu" and _brand(str(gpus[0])) != str(brand["brand"]): continue
            var scores: Array = gpus.map(func(id: String) -> int: return int(Catalog.part(id)["graphics"]))
            if PcBuild.combined_graphics(scores) < need_g: continue
            for case_id: String in Catalog.CASES:
                if str(Catalog.CASES[case_id]["form"]) != form: continue
                var quiet_case: bool = bool(Catalog.CASES[case_id]["quiet"])
                if QUIET in want_ids and not quiet_case and case_id != str(Catalog.DEFAULT_CASE[form]): continue   # a plain non-default case only adds cost
                if not QUIET in want_ids and case_id != str(Catalog.DEFAULT_CASE[form]): continue
                var parts: Dictionary = {"cpu": cpu, "gpus": gpus, "ram": ram, "storage": storage, "psu": "", "cooler": "", "board": board, "case": case_id}
                # B57: a cooler and PSU only add to the price, so a combination already no cheaper than the best
                # cannot win (the comparison below is strict); skipping it leaves the answer unchanged.
                if not best.is_empty() and value_of(parts) >= int(best["cost"]): continue
                var heat: int = int(Catalog.part(cpu)["watts"])
                # Quiet: no loud fan, or one hidden by a sound-dampened case (try the cooler quiet first, then the PSU).
                var options: Array = [[1.0, 1.0]]
                if QUIET in want_ids: options = [[COOLER_QUIET_LOAD, PSU_QUIET_LOAD]] + ([[1.0, PSU_QUIET_LOAD], [COOLER_QUIET_LOAD, 1.0]] if quiet_case else [])
                for opt: Array in options:
                    var cooler: String = _cheapest(Catalog.COOLER, func(p: Dictionary) -> bool: return float(heat) <= float(p["capacity"]) * float(opt[0]))
                    if cooler == "": continue
                    parts["cooler"] = cooler
                    parts["psu"] = ""
                    var draw: int = int(PcBuild.stats(parts)["draw_w"])
                    var psu: String = _cheapest(Catalog.PSU, func(p: Dictionary) -> bool: return float(draw) <= float(p["watts"]) * float(opt[1]))
                    if psu == "": continue
                    parts["psu"] = psu
                    var cost: int = value_of(parts)
                    if best.is_empty() or cost < int(best["cost"]): best = {"cost": cost, "parts": parts.duplicate(true)}
    return best


# Catalogue value of a parts record: every part, the motherboard and the case.
static func value_of(parts: Dictionary) -> int:
    var total: int = _price(str(parts.get("cpu", ""))) + _price(str(parts.get("psu", ""))) + _price(str(parts.get("cooler", "")))
    for key: String in ["gpus", "ram", "storage"]:
        for id: Variant in parts.get(key, []): total += _price(str(id))
    total += int(Catalog.BOARDS.get(str(parts.get("board", "")), {}).get("price", 0))
    total += int(Catalog.CASES.get(str(parts.get("case", "")), {}).get("price", 0))
    return total


# ---- a build job ----

# The parts physically in a build right now (fitted shop parts included, dead ones too: they are in it).
static func fitted_parts(job: Dictionary) -> Dictionary:
    var p: Dictionary = PcBuild.sanitize(job.get("parts", {}))
    var removed: Array = job.get("removed_parts", []) if job.get("removed_parts", []) is Array else []
    var replaced: Dictionary = job.get("service_replacements", {}) if job.get("service_replacements", {}) is Dictionary else {}
    var out: Dictionary = {"cpu": str(p["cpu"]), "gpus": [], "ram": (p["ram"] as Array).duplicate(), "storage": (p["storage"] as Array).duplicate(),
        "psu": str(p["psu"]), "cooler": "", "board": "" if PcBuild.board_out(job) else PcBuild.board_model(job), "case": PcBuild.case_model(job)}
    if not Ids.GPU in removed: (out["gpus"] as Array).append(PcBuild.model_of(str(replaced.get(Ids.GPU, "")), Ids.GPU, str(p["gpus"][0])))
    if not Ids.COOLER in removed: out["cooler"] = PcBuild.model_of(str(replaced.get(Ids.COOLER, "")), Ids.COOLER, str(p["cooler"]))
    for slot: String in PcBuild.shop_fitted(job):
        var model: String = str(PcBuild.shop_fitted(job)[slot])
        if slot == PcBuild.CPU_SLOT: out["cpu"] = model
        elif slot == PcBuild.PSU_SLOT: out["psu"] = model
        elif slot in PcBuild.RAM_SLOTS: (out["ram"] as Array).append(model)
        elif slot in PcBuild.STORAGE_SLOTS: (out["storage"] as Array).append(model)
        elif slot == PcBuild.GPU2_SLOT: (out["gpus"] as Array).append(model)
    return out


# Catalogue value of everything in the build now (what the parts would cost new).
static func value(job: Dictionary) -> int:
    var parts: Dictionary = fitted_parts(job)
    if PcBuild.board_out(job): parts["board"] = PcBuild.board_model(job)   # out of the case, still bought for it
    return value_of(parts)


# Turns a fresh job into an empty build in `form`: the basic case, the cheapest board fitted, nothing
# else; clean; the first GPU slot and the cooler mount empty. `spec` = the sanitized build record.
static func setup(job: Dictionary, spec: Dictionary, form: String, dust_zones: Array) -> void:
    job["ticket"] = {"request": "build", "ready": false, "called": false, "nights": 0}
    job["layout"] = form
    job["parts"] = PcBuild.sanitize({"cpu": "", "gpus": [PLACEHOLDER_GPU], "ram": [], "storage": [], "psu": "", "cooler": PLACEHOLDER_COOLER,
        "board": Catalog.cheapest_board(form), "case": str(Catalog.DEFAULT_CASE[form])})
    job["pc_specs"] = PcBuild.specs(job["parts"])
    job["removed_parts"] = [Ids.GPU, Ids.COOLER]
    job["broken_parts"] = []
    job["damaged_parts"] = []
    job["dead_slots"] = []
    job["loose_parts"] = []
    job["gpu_screws"] = 0
    job["board_out"] = false
    var dust: Dictionary = {}
    for zone: Dictionary in dust_zones: dust[str(zone["id"])] = 1.0   # a new build is clean
    job["dust"] = dust
    job["cleaned"] = true
    job["paste_grade"] = ""
    job["paste_done"] = false
    job["infection"] = ""
    job["overclock"] = {"mult": 0, "volt": 0}
    job["build"] = spec
    job["complaint"] = str(USES[spec["use"]]["say"])
    job["payout"] = int(spec["budget"]) - int(spec["deposit"])


# The arrival cost of a build: the basic case and the cheapest board the shop puts it in.
static func starter_cost(form: String) -> int:
    return int(Catalog.CASES[Catalog.DEFAULT_CASE[form]]["price"]) + int(Catalog.BOARDS[Catalog.cheapest_board(form)]["price"])


# ---- texts ----

static func needs_text(build: Dictionary) -> String:
    var needs: Dictionary = build.get("needs", {})
    var bits: Array = []
    var game: Dictionary = needs.get("game", {})
    if not game.is_empty(): bits.append("%s at %d FPS or more" % [str(Games.game(str(game["game_id"])).get("title", "")), int(game["min_fps"])])
    bits.append("processing %d" % int(needs.get("processing", 0)))
    bits.append("graphics %d" % int(needs.get("graphics", 0)) if int(needs.get("graphics", 0)) > 0 else "any graphics card")
    bits.append("RAM %d GB" % int(needs.get("ram_gb", 0)))
    bits.append("storage %d GB" % int(needs.get("storage_gb", 0)))
    return " · ".join(bits)


static func want_text(w: Dictionary) -> String:
    var id: String = str(w.get("id", ""))
    if id == QUIET: return "quiet (no loud fans)"
    if id == HEADROOM: return "room to grow (about a third more power than needed)"
    if id == BRAND: return "%s %s %s" % ["an" if str(w["brand"]).left(1) in ["A", "I"] else "a", str(w["brand"]), "processor" if str(w["part"]) == "cpu" else "graphics card"]
    if id == STORAGE: return "extra storage (twice what is needed)"
    return ""


static func wants_text(build: Dictionary) -> String:
    var out: Array = []
    for w: Dictionary in build.get("wants", []): out.append(want_text(w))
    return ", ".join(out) if not out.is_empty() else "nothing special"


# Ticket lines for a build request (the ticket window).
static func ticket_lines(job: Dictionary) -> Array:
    var b: Dictionary = record(job)
    if b.is_empty(): return []
    var worth: int = value(job)
    return [
        "Build request: %s" % str(USES[b["use"]]["label"]),
        "Needs (hard minimums): %s" % needs_text(b),
        "Would like: %s" % wants_text(b),
        "Budget $%d: $%d paid up front, $%d on collection. They pay the budget, never more." % [int(b["budget"]), int(b["deposit"]), int(b["budget"]) - int(b["deposit"])],
        "In the build now, at new prices: $%d (case and motherboard included) · the budget minus that: $%d" % [worth, int(b["budget"]) - worth],
        "Assembly takes night time: %s." % ", ".join(MINUTES.keys().map(func(k: String) -> String: return "%s %d min" % [k, int(MINUTES[k])])),
    ]


# ---- scam hook: what was delivered, by what the shop knew ----

# Counts the parts in a build by the shop's knowledge (new / untested / tested) and where they came from.
# `records` = the stock records of the shop parts in it (before collection).
static func delivered(job: Dictionary, records: Array) -> Dictionary:
    var out: Dictionary = {"value": value(job), "parts": records.size(), "new": 0, "untested": 0, "tested": 0, "salvaged": 0}
    for record: Variant in records:
        if not record is Dictionary: continue
        var k: Dictionary = PartCondition.known(record)
        var label: String = str(k["label"])
        if label == PartCondition.NEW: out["new"] = int(out["new"]) + 1
        elif label == PartCondition.UNTESTED: out["untested"] = int(out["untested"]) + 1
        else: out["tested"] = int(out["tested"]) + 1
        if str(k["source"]).begins_with("Found at the salvage"): out["salvaged"] = int(out["salvaged"]) + 1
    return out
