# GAME STATE (autoload named "GameState"): cash, the current repair ticket, save/load.
# Saves to user://nightshift_save.json after every change. No drawing, no UI here.
# All numbers are demo values for the trial, not approved balance.
extends Node
const Ids = preload("res://scripts/data/ids.gd")

const ComponentData = preload("res://scripts/data/component_data.gd")
const GridInventory = preload("res://scripts/bench/grid_inventory.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const SaveStore = preload("res://scripts/state/save_store.gd")
const PasteMaterials = preload("res://scripts/data/paste_materials.gd")
const Customers = preload("res://scripts/data/customers.gd")
const Games = preload("res://scripts/data/games.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const Software = preload("res://scripts/rules/software_checks.gd")
const FpsSim = preload("res://scripts/rules/fps_sim.gd")
const PickupScore = preload("res://scripts/rules/pickup_score.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const WorkReport = preload("res://scripts/rules/work_report.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const Morning = preload("res://scripts/rules/morning.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const Findings = preload("res://scripts/rules/findings.gd")
const TicketRating = preload("res://scripts/rules/shop_rating.gd")
const VacuumState = preload("res://scripts/bench/vacuum_state.gd")
const PartCondition = preload("res://scripts/rules/part_condition.gd")
const SalvageStock = preload("res://scripts/rules/salvage_stock.gd")
const NightClock = preload("res://scripts/rules/night_clock.gd")
const BuildRequest = preload("res://scripts/rules/build_request.gd")
const Reviews = preload("res://scripts/rules/reviews.gd")
const GOOD_PASTE: Array = ["PERFECT", "GOOD ENOUGH"]   # mount results good enough to complete the repaste

const SAVE_PATH: String = "user://nightshift_save.json"
const SETTINGS_PATH: String = "user://nightshift_settings.json"
const HISTORY_KEEP: int = 10    # pickup history entries kept per customer (D106, proposal)
const REVIEWS_KEEP: int = 40    # 0.52.0: reviews kept (the phone lists them; the latest 10 make the rating)
const PROFESSIONS: Array = ["regular", "gamer", "clueless"]
# Bump only when the saved data changes shape incompatibly (and log it in CHANGELOG.md).
const SAVE_FORMAT: int = 1
const START_MONEY: int = 100
const PASS_TEMP: float = 75.0        # final check passes below this temperature (C)
const BASE_TEMP: float = 42.0
const UPGRADE_PRICES: Dictionary = {"square_cloth": 40, "long_hose": 40}   # demo prices
const NO_PASTE_PENALTY: float = 40.0
const PASTE_PENALTY: Dictionary = {
    "PERFECT": 0.0,
    "GOOD ENOUGH": 4.0,
    "MESSY": 3.0,
    "BALD SPOTS": 18.0,
    "TOO LITTLE": 35.0,
}

var save_path: String = SAVE_PATH # injectable for isolated regression tests
var player_inventory: Array = []
var inventory_layout: Dictionary = {}
var inventory_sequence: int = 10
var ticket_sequence: int = 1
var night_minutes: int = 0     # D133: night minutes spent on timed monitor tests (night_clock.gd); reset each morning (0.44.0)
var night_number: int = 1      # D136 (0.44.0): which night this is; +1 every morning
var comebacks: Array = []      # D136 (0.44.0): delayed hidden faults waiting to bring a customer back (morning.gd)
var money: int = START_MONEY
var job: Dictionary = {}
var upgrades: Dictionary = {}   # upgrade id -> true once bought
var owned_games: Array = []     # game ids the shop bought to test with (D94); kept across tickets
var customer_state: Dictionary = {}   # customer id -> {"trust": int, "history": Array}; what the shop EARNED (kept across tickets)
var tickets_taken: int = 0      # how many tickets the shop has COMPLETED; picks the next customer (D104); kept across tickets
var people: Dictionary = {}     # 0.48.0 (D153): generated customers by id ("p0001"...): who they are, their PC and needs; kept like customer_state
var person_sequence: int = 1    # 0.48.0: the next generated customer's number
var reviews: Array = []         # 0.52.0 (D160): review records {stars, text, kind, night, ticket, author}, newest last (reviews.gd); 0.48.0 saves held plain scores
var trust_points: int = 0       # 0.52.0 (D160): the shop's trustworthiness: up with good work, down only when customers find out; sets the shop level
var fake_orders: Array = []     # 0.52.0: nights on which fake reviews were bought (the review site's checks read them)
var vacuum_state: Dictionary = {"bin": 0.0, "hose": []}   # 0.48.1 (user): the vacuum keeps its bin and hose contents across screens and reloads (a shop tool, not per PC)
var world_seed: int = 0         # 0.48.0: seeds every generated morning, so the same save always gets the same customers
var sound_volume: float = 1.0   # master volume 0..1 (D107); lives in its own settings file, never in the game save
var settings_path: String = SETTINGS_PATH # injectable for isolated regression tests


func _ready() -> void:
    _load_settings()
    if not load_game():
        new_game(false)   # title screen must not create/overwrite a save just by opening


func has_saved_game() -> bool:
    return SaveStore.read(save_path) is Dictionary


func new_game(persist: bool = true) -> void:
    money = START_MONEY
    ticket_sequence = 1
    night_minutes = 0
    night_number = 1
    comebacks = []
    job = _make_job()
    player_inventory = _starter_inventory()
    inventory_layout = {}
    inventory_sequence = 10
    upgrades = {}
    # owned_games and customer_state are NOT reset: the games and the relationships belong to the shop.
    # 0.48.0: neither are the generated customers, the reviews or the world seed (one is made if missing).
    if world_seed == 0: world_seed = _new_seed()
    vacuum_state = {"bin": 0.0, "hose": []}   # 0.48.1: a new shop starts with an empty vacuum
    if persist:
        save_game()


# The next ticket's customer rotates with every COMPLETED ticket (D104): finish Mara's PC and
# Relu brings his in; abandon a ticket and the same customer is still waiting on it.
func _make_job() -> Dictionary:
    var cid: String = Customers.IDS[tickets_taken % Customers.IDS.size()]
    var who: Dictionary = Customers.customer(cid)
    return {
        "id": "T%03d" % ticket_sequence,
        "removed_component_records": [],
        "service_replacement_ids": {},
        "layout": "tower",
        "dust_schema": 2,
        "removed_parts": [],
        "service_table_positions": {},
        "broken_parts": [],
        "service_replacements": {},
        "hardware_trial": {},
        "customer_id": cid,           # key into scripts/data/customers.gd; rotates per ticket (D104)
        "customer": str(who["name"]),
        "complaint": str(who["complaint"]),
        "state": "open",          # "open" or "done"
        "cleaned": false,         # true only when every dusty part is clean (derived from "dust")
        "dust_state": {},
        "dust": _fresh_dust(),               # zone id -> share of that part's dust removed (0..1)
        "paste_grade": "",        # "" = no fresh paste
        "paste_coverage": 0.0,
        "paste_overflow": 0.0,
        "paste_done": false,      # the player pressed Complete repaste on a good result
        "paste_graded_units": 0.0, # paste on the CPU when the grade was given (0 = no graded mount this session)
        "cooler_film_peeled": false, # D130: the clear plastic film on the cooler base was taken off
        "damaged_parts": [],      # D150 (0.46.2): parts the player VISIBLY damaged (a subset of broken_parts; may be shown)
        "shop_condition": {},     # 0.50.0: DERIVED copy of fitted shop parts' real condition (authority: the stock record)
        "shop_fitted": {},        # D150: slot -> {uid, model}: shop parts fitted for a test; still the shop's until collection
        "shop_custody": [],       # D150: "gpu"/"cooler" whose first-slot replacement is still the shop's until collection
        "dead_slots": [],         # D150: slots holding a customer part that does not work (hidden; today only "pcie_2")
        "loose_parts": [],        # D149 (0.46.0): the customer's parts lying in the hardware drawer, out of the PC: [{id, broken}]
        "gpu_screws": 2,          # D131: GPU bracket screw turns done (2 = tight). Removing or replacing the GPU at the hardware bench resets it to 0
        "install_faults": [],     # D130: hidden mistakes of the last locked mount (install_faults.gd); felt only at pickup
        "parts": PcBuild.sanitize(who.get("pc", {})),   # D148 (0.45.0): the customer's PC as catalogue parts
        "pc_specs": PcBuild.specs(who.get("pc", {})),   # derived from "parts" (processing, RAM) for the fps simulation (D94)
        "ticket": {"request": "repair", "ready": false, "called": false, "nights": 0},   # D134/D135: pickup flags (ticket.gd); the record itself is derived
        "cured": "",              # D133: strain the anti-virus removed on this ticket (for the work report)
        "board_out": false,       # 0.48.1: the motherboard is out of the case (only once every other part is out)
        "build": {},              # 0.51.0 (D159): a build request's use, needs, wants, budget and deposit (build_request.gd); {} for a repair
        "findings": [],           # D150 (0.47.0): the Findings notebook (findings.gd): seen / measured / done, on the night clock
        "tests": {},              # D133: what the monitor MEASURED (work_report.gd): hardware check, game fps, temperature
        "infection": "",          # D132: malware strain id (malware.gd) or "" when clean; felt only at pickup unless cured
        "overclock": {"mult": 0, "volt": 0},   # D132: CPU overclock steps (overclock.gd); heat is visible, instability is felt at pickup
        "pc_powered": false,      # delivered switched off; live tests require deliberate power-on
        "paste_material": "thermal",   # what is under the cooler: canonical PasteMaterials ID
        "scams": [],              # what the customer was cheated on in this job (e.g. "toothpaste"); consequences not simulated yet
        "temp": 0.0,              # last final-check temperature, 0 = not checked
        "payout": int(who["payout"]),
    }


# ----- dust -----

func dust_fraction(zone_id: String) -> float:
    var d: Dictionary = job["dust"]
    return clampf(float(d.get(zone_id, 0.0)), 0.0, 1.0)


# Store the removed share for every part at once: {zone id: fraction}. Recomputes "cleaned".
func set_dust(fractions: Dictionary, physics: Dictionary = {}) -> void:
    var was_clean: Array = _clean_zone_labels()
    job["dust"] = fractions.duplicate()
    job["dust_state"] = physics
    _refresh_cleaned()
    var now_clean: Array = _clean_zone_labels()
    var newly: Array = now_clean.filter(func(label: String) -> bool: return not label in was_clean)
    if not newly.is_empty() and job["state"] != "done":
        note(Findings.WORK, "Cleaned: %s (%d of %d parts clean)." % [", ".join(newly), now_clean.size(), DustZones.zones(str(job.get("layout", "tower"))).size()], "repair_bench")
    save_game()


func _clean_zone_labels() -> Array:
    var out: Array = []
    for zone: Dictionary in DustZones.zones(str(job.get("layout", "tower"))):
        if dust_fraction(str(zone["id"])) >= DustZones.CLEAN_AT: out.append(str(zone["label"]))
    return out


func _refresh_cleaned() -> void:
    job["cleaned"] = parts_clean_count() == DustZones.zones().size()


func parts_clean_count() -> int:
    var n: int = 0
    for z: Dictionary in DustZones.zones():
        if dust_fraction(str(z["id"])) >= DustZones.CLEAN_AT:
            n += 1
    return n


# Service accidents and replacements are persistent; grades are derived from known tiers.
# ONE source of truth for the state of a customer's serviceable part (D115): binary per part.
# Everything that talks about parts (ticket, final check, benches) reads this, never its own copy.
func part_state(part_id: String) -> Dictionary:
    return PartStates.state(job, part_id)


func damage_service_part(part_id: String) -> bool:
    if job["state"] == "done" or not part_id in ServiceParts.IDS or part_id in job["broken_parts"]:
        return false
    job["broken_parts"].append(part_id)
    if not part_id in job["damaged_parts"]: job["damaged_parts"].append(part_id)   # D150: the player saw it happen
    note(Findings.WORK, "%s visibly damaged while handling it." % part_id.to_upper(), "repair_bench")
    save_game()
    return true

func replace_service_part(part_id: String, tier: String) -> bool:
    for record: Dictionary in player_inventory:
        if record["kind"] == part_id and record["tier"] == tier and stock_available(record["uid"]):
            return fit_inventory_part(part_id,record["uid"])
    return false

func fit_inventory_part(part_id: String, uid: String) -> bool:
    if job["state"] == "done" or not part_id in job["removed_parts"] or PcBuild.board_out(job): return false
    var index: int = -1
    for i in range(player_inventory.size()):
        if player_inventory[i]["uid"] == uid: index = i
    if index < 0 or not stock_available(uid): return false
    var record: Dictionary = player_inventory[index]
    var before: Array = Findings.configuration(job)
    # D150 (0.46.2): fitting is a TEST until the customer collects. Any owned, suitable part may go in
    # whatever the customer's part's health (no health oracle); it stays the shop's; the customer's
    # original stays theirs, lying in the drawer. Collection settles it (settle_custody).
    var tier: String = ("model:" + str(record.get("model", ""))) if str(record["tier"]) == "model" else str(record["tier"])
    if record["kind"] != part_id or ServiceParts.option(part_id,tier).is_empty(): return false
    if job["service_replacements"].has(part_id) and part_id in job["shop_custody"]: return false   # slot 1 already holds a shop part
    # 0.51.0 (D159): in a build there is no customer original to set aside, fitting costs night time and the
    # cooler needs the CPU under it.
    var build: bool = PcBuild.is_build(job)
    if build and (assembly_blocker(part_id) != "" or (part_id == Ids.COOLER and str(BuildRequest.fitted_parts(job)["cpu"]) == "")): return false
    if not build:
        (job["loose_parts"] as Array).append({"id": CustomerPC.catalog_id(job, CustomerPC.uid(job, part_id)), "broken": part_id in job["broken_parts"],
            "damaged": part_id in job["damaged_parts"], "original_of": part_id})
    record["fitted_in"] = str(job["id"])
    record["slot"] = part_id
    inventory_layout.erase(uid)
    if not part_id in job["shop_custody"]: job["shop_custody"].append(part_id)
    job["damaged_parts"].erase(part_id)
    job["broken_parts"].erase(part_id)
    job["removed_parts"].erase(part_id)
    if part_id == Ids.GPU:
        job["gpu_screws"] = 0   # D131: a new card is not screwed in yet
    job["service_replacements"][part_id] = tier
    job["service_replacement_ids"][part_id] = uid
    _carry_condition(part_id, record)   # 0.50.0: the test part behaves as it really is
    if build:
        night_minutes += BuildRequest.minutes(part_id)
    if part_id == Ids.COOLER and build:
        # A build cooler goes on with its pre-applied paste (proposal, D159): nothing to rework at the repair bench.
        job["paste_grade"] = BuildRequest.PASTE_GRADE
        job["paste_done"] = true
        job["paste_material"] = "thermal"
        job["cooler_film_peeled"] = true
        job["install_faults"] = []
    elif part_id == Ids.COOLER:
        job["paste_grade"] = ""
        job["paste_coverage"] = 0.0
        job["paste_overflow"] = 0.0
        job["paste_done"] = false
        job["scams"].erase("toothpaste")
    _note_build(before)
    save_game()
    return true

func _fresh_dust() -> Dictionary:
    var fractions: Dictionary = {}
    for zone: Dictionary in DustZones.zones(): fractions[zone["id"]] = 1.0 if zone["id"] == "case_interior" else 0.0
    return fractions

func start_repair_ticket() -> void:
    ticket_sequence += 1
    job = _make_job()
    save_game()

func _starter_inventory() -> Array:
    return [{"uid":"trial_ram_a","kind":"ram","tier":"similar","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")},
        {"uid":"trial_ram_b","kind":"ram","tier":"similar","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")},
        {"uid":"trial_gpu","kind":Ids.GPU,"tier":"similar","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")},
        {"uid":"stock_gpu_budget","kind":Ids.GPU,"tier":"budget","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")},
        {"uid":"stock_cooler_similar","kind":Ids.COOLER,"tier":"similar","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")},
        {"uid":"stock_cooler_budget","kind":Ids.COOLER,"tier":"budget","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")},
        # Last on purpose: the drawer packs in list order, and everything before keeps its cells.
        {"uid":"stock_cpu_demo","kind":"cpu","tier":"similar","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")}]

# The player's stock as bench components. Parts fitted in a customer PC for a test are left out
# (the hardware bench shows the current PC's fitted ones on their slots: fitted_components()).
func inventory_components() -> Array:
    var stock: Array = []
    for record: Dictionary in player_inventory:
        if str(record.get("fitted_in","")) != "": continue
        var component: Dictionary
        if record["kind"] == "ram" and str(record["tier"]) != "model":
            component = ComponentData.ram_stick()
            component["id"] = record["uid"]
        elif str(record["tier"]) == "model":
            component = Catalog.component(record["uid"],str(record["model"]))   # D149: any catalogue part
            component["details"].append(["Owner","Player stock"])
        elif record["kind"] == "cpu":
            component = ComponentData.cpu_chip()
            component["id"] = record["uid"]
        else: component = ServiceParts.component(record["uid"],record["kind"],record["tier"])
        # 0.50.0 (D158): what the shop KNOWS, never the hidden condition.
        component["details"].append(["Known", PartCondition.describe(record, 1)])
        stock.append(component)
    return stock

func stock_available(uid: String) -> bool:
    for record: Dictionary in player_inventory:
        if record["uid"] == uid:
            var placement: Variant = inventory_layout.get(uid,{})
            if str(record.get("fitted_in","")) != "": return false   # D150: fitted in a customer PC for a test
            # 0.50.0: usable unless the player marked it dead (or damaged it); hidden condition is not read.
            return PartCondition.usable(record) and record["owner"] == "player" and (not placement is Dictionary or str(placement.get("location","drawer")) == "drawer")
    return false

func stock_count(kind: String, tier: String) -> int:
    var count: int = 0
    for record: Dictionary in player_inventory:
        if record["kind"] == kind and record["tier"] == tier and stock_available(record["uid"]): count += 1
    return count

func buy_service_stock(kind: String, tier: String) -> bool:
    var option: Dictionary = ServiceParts.option(kind,tier)
    if option.is_empty() or money < int(option["cost"]): return false
    var uid: String = "player_stock_%d" % inventory_sequence
    while player_inventory.any(func(item: Dictionary) -> bool: return item["uid"] == uid):
        inventory_sequence += 1
        uid = "player_stock_%d" % inventory_sequence
    var parts: Array = inventory_components()
    parts.append(ServiceParts.component(uid,kind,tier))
    var grid := GridInventory.new()
    var pc: Dictionary = PCLayout.profile(str(job["layout"]))
    grid.setup(pc["board"],pc["depth"],inventory_layout,parts)
    var new_index: int = grid.items.size()-1
    if not grid.can_store(new_index,grid.items[new_index]["cell"]): return false
    money -= int(option["cost"])
    inventory_sequence += 1
    player_inventory.append({"uid":uid,"kind":kind,"tier":tier,"owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")})
    inventory_layout = grid.snapshot()
    save_game()
    return true

func set_inventory_layout(snapshot: Dictionary) -> void:
    inventory_layout = snapshot.duplicate(true)
    save_game()

# ----- upgrades -----

func has_upgrade(upgrade_id: String) -> bool:
    return bool(upgrades.get(upgrade_id, false))


# Spend money on an upgrade. Returns false if already owned or too expensive.
func buy_upgrade(upgrade_id: String) -> bool:
    if has_upgrade(upgrade_id) or not UPGRADE_PRICES.has(upgrade_id):
        return false
    var price: int = int(UPGRADE_PRICES[upgrade_id])
    if money < price:
        return false
    money -= price
    upgrades[upgrade_id] = true
    save_game()
    return true


# A finished mount: the result is recorded, but the repaste only counts once completed.
func set_paste(result: Dictionary, cpu_units: float = 0.0) -> void:
    job["paste_grade"] = result["grade"]
    job["paste_coverage"] = result["coverage"]
    job["paste_overflow"] = result["overflow"]
    job["paste_graded_units"] = cpu_units   # gauge units on the CPU at grading; the grade survives light wiping above 95% of this
    job["paste_done"] = false
    save_game()


# D130: the last locked mount's hidden mistakes. They are never listed by run_final_check.
func set_install_faults(faults: Array) -> void:
    job["install_faults"] = InstallFaults.sanitize(faults)
    save_game()


# D131: turn one GPU bracket screw (needs the screwdriver, enforced by the view). True if a turn was made.
func turn_gpu_screw() -> bool:
    if Ids.GPU in job["removed_parts"] or int(job["gpu_screws"]) >= InstallFaults.GPU_SCREW_COUNT:
        return false
    job["gpu_screws"] = int(job["gpu_screws"]) + 1
    save_game()
    return true


# D131: the hardware bench moves the customer's GPU/cooler between the board and the drawer. The job's
# removed_parts is the one record both benches read. Taking a GPU out unscrews it.
func set_service_part_fitted(part_id: String, fitted: bool) -> bool:
    if job["state"] == "done" or not part_id in ServiceParts.IDS:
        return false
    var removed: bool = part_id in job["removed_parts"]
    if fitted == not removed:
        return false
    if fitted and PcBuild.board_out(job): return false   # 0.48.1: nothing goes in without the motherboard
    if not fitted and part_id in job["shop_custody"]:
        return return_replacement(part_id)
    var before: Array = Findings.configuration(job)
    if fitted:
        job["removed_parts"].erase(part_id)
    else:
        job["removed_parts"].append(part_id)
        if part_id == Ids.GPU:
            job["gpu_screws"] = 0
    _note_build(before)
    save_game()
    return true


# D131: what the customer finds at pickup: recorded cooler-mount faults plus an unscrewed GPU.
func pickup_faults(temp: float = -1.0) -> Array:
    var at: float = float(job.get("temp", 0.0)) if temp < 0.0 else temp
    var faults: Array = InstallFaults.pickup_faults(job.get("install_faults", []), not Ids.GPU in job["removed_parts"], int(job.get("gpu_screws", 2)))
    faults.append_array(Malware.pickup_faults(job))      # D132
    faults.append_array(Overclock.pickup_faults(job, at))
    faults.append_array(PartCondition.pickup_faults(job))   # 0.50.0: a crashing shop part left in the PC
    return faults


# D132: remove the infection the anti-virus found. Returns false when there is nothing to remove.
func clean_infection() -> bool:
    if job["state"] == "done" or not Malware.infected(job):
        return false
    job["cured"] = Malware.strain(job)
    job["infection"] = ""
    note(Findings.WORK, "Anti-virus removed: %s." % str(Malware.STRAINS[job["cured"]]["label"]), "monitor")
    save_game()
    return true


# D133: store a monitor measurement on the ticket, stamped with the PC's current fingerprint.
# kind: "hardware" {ok}, "temp" {value}, or "games" {fps, temp} with a game id.
func record_test(kind: String, data: Dictionary, game_id: String = "") -> void:
    if job["state"] == "done": return
    var tests: Dictionary = WorkReport.sanitize_tests(job.get("tests", {}))
    var entry: Dictionary = data.duplicate()
    entry["sig"] = WorkReport.signature(job)
    if kind == "games": tests["games"][game_id] = entry
    else: tests[kind] = entry
    job["tests"] = WorkReport.sanitize_tests(tests)
    save_game()


# D133: timed monitor tests spend night minutes.
func advance_night(minutes: int) -> void:
    night_minutes += maxi(0, minutes)
    save_game()


# D132: the overclocker's two settings, clamped to their ranges.
func set_overclock(mult: int, volt: int) -> bool:
    if job["state"] == "done": return false
    var was: Dictionary = Overclock.settings(job)
    job["overclock"] = Overclock.sanitize({"mult": mult, "volt": volt})
    if job["overclock"] != was:
        note(Findings.WORK, "Overclocker set to CPU multiplier +%d, voltage %d." % [int(job["overclock"]["mult"]), int(job["overclock"]["volt"])], "monitor")
    save_game()
    return true


# D132: the long stress test costs a little shop cash (electricity).
func charge_long_stress() -> bool:
    if money < Overclock.LONG_TEST_COST: return false
    money -= Overclock.LONG_TEST_COST
    save_game()
    return true


func peel_cooler_film() -> void:
    job["cooler_film_peeled"] = true
    save_game()


func clear_paste() -> void:
    job["install_faults"] = []
    job["paste_grade"] = ""
    job["paste_coverage"] = 0.0
    job["paste_overflow"] = 0.0
    job["paste_graded_units"] = 0.0
    job["paste_done"] = false
    job["scams"].erase("toothpaste")
    save_game()


func set_pc_powered(on: bool) -> void:
    job["pc_powered"] = on
    save_game()


func can_complete_repaste() -> bool:
    return job["state"] != "done" and not bool(job["paste_done"]) and str(job["paste_grade"]) in GOOD_PASTE


# The Complete repaste button. `material` is what was squeezed (canonical PasteMaterials ID).
# Thermal paste costs a little; toothpaste is free and is recorded as a scam on this job.
# Returns {ok, cost, message}.
func complete_repaste(material: String) -> Dictionary:
    var kind: Dictionary = PasteMaterials.material(material)
    if kind.is_empty() or not can_complete_repaste():
        return {"ok": false, "cost": 0, "message": "Only a PERFECT or GOOD ENOUGH result can be completed."}
    var cost: int = int(kind["cost"])
    if money < cost:
        return {"ok": false, "cost": cost, "message": "You need $%d for the thermal paste." % cost}
    money -= cost
    job["paste_done"] = true
    job["paste_material"] = material
    job["scams"].erase("toothpaste")
    if bool(kind["scam"]):
        job["scams"].append("toothpaste")
    note(Findings.WORK, "Repaste completed: %s, cooler contact %s." % [str(kind.get("label", material)), str(job["paste_grade"])], "repair_bench")
    save_game()
    return {"ok": true, "cost": cost, "message": ""}


# Estimated CPU temperature from the work done. Pays out once, the first time it passes.
# Returns: temp, passed, notes (Array of String), paid (int), already_done (bool)
# The PC as the shop's own check sees it: temperature, notes and whether it starts. Changes nothing
# but the derived "cleaned" flag. Used by the final check and by the morning collection (0.44.0).
func assess() -> Dictionary:
    var temp: float = BASE_TEMP
    var notes: Array = []
    _refresh_cleaned()
    var dirty_parts: Array = []
    for z: Dictionary in DustZones.zones():
        var left: float = 1.0 - dust_fraction(str(z["id"]))
        var add: float = float(z["temp_penalty"]) * left
        temp += add
        if dust_fraction(str(z["id"])) < DustZones.CLEAN_AT:
            dirty_parts.append(str(z["label"]))
            notes.append("%s still has dust (+%d C)." % [z["label"], roundi(add)])
    var grade: String = str(job["paste_grade"])
    var penalty: float = NO_PASTE_PENALTY
    var completed: bool = grade != "" and bool(job["paste_done"])
    if completed:
        penalty = float(PASTE_PENALTY.get(grade, NO_PASTE_PENALTY))
    temp += penalty
    if grade == "":
        notes.append("There is no fresh thermal paste on the CPU (+%d C)." % int(NO_PASTE_PENALTY))
    elif not completed:
        notes.append("The repaste was not completed: press Complete repaste on the bench after a good mount (+%d C)." % int(NO_PASTE_PENALTY))
    elif penalty > 0.0:
        notes.append("Paste result was %s (+%d C)." % [grade, int(penalty)])
    if completed:
        var under: Dictionary = PasteMaterials.material(str(job["paste_material"]))
        if not under.is_empty() and float(under["heat_penalty"]) != 0.0:
            temp += float(under["heat_penalty"])
            var effect: String = "%s under the cooler (%+d C)." % [under["label"], int(under["heat_penalty"]) ]
            if bool(under["scam"]): effect += " The customer will not notice today; it dries out. Consequences are not simulated yet."
            notes.append(effect)
    # D115: one binary line per serviceable part, with the exact place to fix it. This replaced
    # the old aggregate notes after a playtest where a broken GPU left the player with no path.
    notes.append_array(PartStates.problem_lines(job))
    var cooling: float = PcBuild.cooling_heat(job)   # D148: a cooler too small for the CPU's heat
    if cooling > 0.0:
        temp += cooling
        notes.append("The cooler cannot remove all of the CPU's heat (+%d C)." % roundi(cooling))
    var oc_heat: float = Overclock.heat(job)   # D132: overclock heat is visible to the shop's own check
    if oc_heat > 0.0:
        temp += oc_heat
        notes.append("Overclock adds %d C." % roundi(oc_heat))
    var case_heat: float = PcBuild.case_heat(job)   # 0.51.0: the case's airflow (0 for the default cases)
    if case_heat != 0.0:
        temp += case_heat
        notes.append("The case's airflow: %+d C." % roundi(case_heat))
    for id: String in job["service_replacements"]:
        if PcBuild.is_build(job): break   # 0.51.0: a build has no original specification to fall short of
        var replacement: Dictionary = ServiceParts.option(id, str(job["service_replacements"][id]))
        temp += float(replacement["heat_penalty"])
        if replacement["performance"] < 100:
            notes.append("Downgrade: %s is %d%% of the original specification%s. Customer consequences are not simulated yet." % [id, replacement["performance"], " (+8 C)" if id == "cooler" else ""])
    # D87 (user, 2026-11-14): leftover dust is NOT a blocker. It only matters through the temperature
    # it adds (the notes keep saying where it is). The check passes while the PC is under the limit
    # and every part is functional: nothing broken, nothing left out, enough graphics output.
    # Boot test (D97): any power output is fine as long as the PC starts. It starts when every part is
    # fitted and nothing is broken. Temperature stays the other half of the pass.
    var boot: Dictionary = Software.boot(job)
    var boots: bool = boot["ok"]
    notes.append(boot["message"])
    return {"temp": temp, "notes": notes, "boots": boots}


func run_final_check() -> Dictionary:
    var check: Dictionary = assess()
    var temp: float = check["temp"]
    var notes: Array = check["notes"]
    var boots: bool = check["boots"]
    var passed: bool = temp < PASS_TEMP and boots
    var already_done: bool = job["state"] == "done"
    var paid: int = 0
    var pickup: Dictionary = {}
    if passed and not already_done:
        settle_custody()   # D150: the PC leaves as it is
        job["state"] = "done"
        paid = int(job["payout"])
        money += paid
        pickup = _record_pickup(temp)
    job["temp"] = temp
    save_game()
    return {"temp": temp, "passed": passed, "boots": boots, "notes": notes, "paid": paid, "already_done": already_done, "pickup": pickup}


# The project version, set in project.godot as config/version (single source of truth).
func game_version() -> String:
    return str(ProjectSettings.get_setting("application/config/version", "unknown"))


func save_game() -> void:
    var data: Dictionary = {
        "save_format": SAVE_FORMAT,
        "game_version": game_version(),
        "money": money,
        "player_inventory": player_inventory,
        "inventory_layout": inventory_layout,
        "inventory_sequence": inventory_sequence,
        "starter_cpu_seeded": true, # pre-D116 saves get a CPU once; handing it over never respawns it
        "ticket_sequence": ticket_sequence,
        "upgrades": upgrades,
        "owned_games": owned_games,
        "customer_state": customer_state,
        "people": people,
        "person_sequence": person_sequence,
        "reviews": reviews,
        "trust_points": trust_points,
        "fake_orders": fake_orders,
        "world_seed": world_seed,
        "vacuum_state": vacuum_state,
        "tickets_taken": tickets_taken,
        "night_minutes": night_minutes,
        "night_number": night_number,
        "comebacks": comebacks,
        "job": job,
    }
    SaveStore.write(save_path, data)


func load_game() -> bool:
    var parsed: Variant = SaveStore.read(save_path)
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    var data: Dictionary = parsed
    # Saves before 0.5.1 stored the format as "version": 1.
    var fmt: int = int(data.get("save_format", data.get("version", 1)))
    if fmt > SAVE_FORMAT:
        push_warning("Save file format %d is newer than this build (%d); loading what is recognised." % [fmt, SAVE_FORMAT])
    money = int(data.get("money", START_MONEY))
    ticket_sequence = maxi(1,int(data.get("ticket_sequence",1)))
    inventory_sequence = maxi(10,int(data.get("inventory_sequence",10)))
    player_inventory = []
    var raw_stock: Variant = data.get("player_inventory",_starter_inventory())
    var seen_stock: Dictionary = {}
    if raw_stock is Array:
        for record: Variant in raw_stock:
            if not record is Dictionary: continue
            var uid: String = str(record.get("uid",""))
            var kind: String = str(record.get("kind",""))
            var tier: String = str(record.get("tier",""))
            var raw_condition: String = str(record.get("condition", "working"))
            if str(record.get("owner","player")) != "player" or not raw_condition in [PcBuild.WORKING, PcBuild.DEGRADED, PcBuild.BROKEN]: continue
            var condition: String = raw_condition
            if tier == "model":   # D149: a part bought from the catalogue
                var model: String = str(record.get("model",""))
                if uid == "" or seen_stock.has(uid) or not Catalog.is_type(model,kind): continue
                player_inventory.append(_custody(_with_knowledge({"uid":uid,"kind":kind,"tier":"model","model":model,"owner":"player","condition":condition}, record), record))
                seen_stock[uid] = true
                continue
            if uid == "" or seen_stock.has(uid) or not kind in ["ram", "cpu", Ids.GPU, Ids.COOLER] or not tier in ["similar","budget"]: continue
            player_inventory.append(_custody(_with_knowledge({"uid":uid,"kind":kind,"tier":tier,"owner":"player","condition":condition}, record), record))
            seen_stock[uid] = true
    # Saves from before the CPU existed gain the demo CPU once (D116); later loads keep it.
    if not bool(data.get("starter_cpu_seeded", false)) and raw_stock is Array and not (raw_stock as Array).is_empty() and not seen_stock.has("stock_cpu_demo"):
        player_inventory.append({"uid":"stock_cpu_demo","kind":"cpu","tier":"similar","owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")})
    var saved_layout: Variant = data.get("inventory_layout",{})
    inventory_layout = saved_layout if saved_layout is Dictionary else {}
    var saved_up: Variant = data.get("upgrades", {})
    upgrades = {}
    if typeof(saved_up) == TYPE_DICTIONARY:
        var up_dict: Dictionary = saved_up
        for key in up_dict:
            if UPGRADE_PRICES.has(key) and bool(up_dict[key]):
                upgrades[key] = true
    owned_games = []
    var raw_games: Variant = data.get("owned_games", [])
    if raw_games is Array:
        for g: Variant in raw_games:
            if not Games.game(str(g)).is_empty() and not str(g) in owned_games: owned_games.append(str(g))
    # 0.48.0: generated customers first, so their trust, history and tickets load like the story ones.
    people = {}
    var raw_people: Variant = data.get("people", {})
    if raw_people is Dictionary:
        for pid: Variant in raw_people:
            var person_record: Dictionary = _person_from(str(pid), raw_people[pid])
            if not person_record.is_empty(): people[str(pid)] = person_record
    person_sequence = maxi(1, int(data.get("person_sequence", people.size() + 1))) if typeof(data.get("person_sequence", 1)) in [TYPE_INT, TYPE_FLOAT] else people.size() + 1
    reviews = Reviews.sanitize(data.get("reviews", []))   # 0.52.0: records; an old plain score becomes a pickup review
    reviews = reviews.slice(maxi(0, reviews.size() - REVIEWS_KEEP))
    trust_points = maxi(0, int(data.get("trust_points", 0))) if typeof(data.get("trust_points", 0)) in [TYPE_INT, TYPE_FLOAT] else 0
    fake_orders = []
    var raw_orders: Variant = data.get("fake_orders", [])
    if raw_orders is Array:
        for n: Variant in raw_orders:
            if typeof(n) in [TYPE_INT, TYPE_FLOAT]: fake_orders.append(maxi(1, int(n)))
    fake_orders = fake_orders.slice(maxi(0, fake_orders.size() - 10))
    world_seed = int(data.get("world_seed", 0)) if typeof(data.get("world_seed", 0)) in [TYPE_INT, TYPE_FLOAT] else 0
    vacuum_state = VacuumState.sanitize(data.get("vacuum_state", {}))
    if world_seed == 0: world_seed = _new_seed()
    customer_state = {}
    var raw_customers: Variant = data.get("customer_state", {})
    if raw_customers is Dictionary:
        for cid: Variant in raw_customers:
            var record: Dictionary = person(str(cid))
            if record.is_empty(): continue
            var entry: Variant = raw_customers[cid]
            if not entry is Dictionary: continue
            # D106: each history entry is rebuilt field by field; anything that is not a
            # Dictionary (hand-edited or damaged saves) is dropped instead of crashing the shop.
            var past: Array = []
            var raw_past: Variant = (entry as Dictionary).get("history", [])
            if raw_past is Array:
                for visit: Variant in raw_past:
                    if not visit is Dictionary: continue
                    var v: Dictionary = visit
                    var misses: Array = []
                    var raw_misses: Variant = v.get("misses", [])
                    if raw_misses is Array:
                        for miss: Variant in raw_misses: misses.append(str(miss))
                    var scams: Array = []
                    var raw_scams: Variant = v.get("scams", [])
                    if raw_scams is Array:
                        for scam: Variant in raw_scams: scams.append(str(scam))
                    var kept_visit: Dictionary = {"ticket": str(v.get("ticket", "")), "score": clampi(int(v.get("score", 0)), 0, 100),
                        "misses": misses, "comeback_days": maxi(0, int(v.get("comeback_days", 0))), "scams": scams}
                    var raw_build: Variant = v.get("build", null)   # 0.51.0: a build's budget and value at new prices
                    if raw_build is Dictionary and typeof(raw_build.get("budget", null)) in [TYPE_INT, TYPE_FLOAT] and typeof(raw_build.get("value", null)) in [TYPE_INT, TYPE_FLOAT]:
                        kept_visit["build"] = {"budget": clampi(int(raw_build["budget"]), 0, 1000000), "value": clampi(int(raw_build["value"]), 0, 1000000)}
                    past.append(kept_visit)
            while past.size() > HISTORY_KEEP: past.pop_front()
            customer_state[str(cid)] = {"trust": clampi(int((entry as Dictionary).get("trust", int(record.get("trust_start", 50)))), 0, 100),
                "history": past}
    tickets_taken = maxi(0, int(data.get("tickets_taken", 0)))
    night_minutes = maxi(0, int(data.get("night_minutes", 0))) if typeof(data.get("night_minutes", 0)) in [TYPE_INT, TYPE_FLOAT] else 0
    night_number = maxi(1, int(data.get("night_number", 1))) if typeof(data.get("night_number", 1)) in [TYPE_INT, TYPE_FLOAT] else 1
    comebacks = Morning.sanitize_pending(data.get("comebacks", []))
    job = _make_job()
    var saved: Variant = data.get("job", {})
    if typeof(saved) == TYPE_DICTIONARY:
        var saved_job: Dictionary = saved
        for key in saved_job:
            if job.has(key):
                job[key] = saved_job[key]
        if not saved_job.has("dust_schema") and bool(saved_job.get("cleaned", false)) and saved_job.has("dust") and typeof(job["dust"]) == TYPE_DICTIONARY:
            job["dust"]["under_cooler"] = 1.0
            job["dust"]["under_gpu"] = 1.0
        # Before 0.7.0 only the cooler was cleaned and the save held just a "cleaned" flag.
        if not saved_job.has("dust") and bool(saved_job.get("cleaned", false)):
            job["dust"] = {Ids.COOLER: 1.0}
    if typeof(job["dust"]) != TYPE_DICTIONARY:
        job["dust"] = {}
    if not job["service_table_positions"] is Dictionary: job["service_table_positions"] = {}
    var valid_removed: Array = []
    if typeof(job["removed_parts"]) == TYPE_ARRAY:
        for id in job["removed_parts"]:
            if str(id) in Ids.SERVICE_PARTS and not str(id) in valid_removed: valid_removed.append(str(id))
    job["removed_parts"] = valid_removed
    if not job["hardware_trial"] is Dictionary: job["hardware_trial"] = {}
    if not data.has("inventory_layout"):
        var old_layout: Variant = job["hardware_trial"].get(str(job["layout"]),{})
        if old_layout is Dictionary: inventory_layout = old_layout.duplicate(true)
    if not job["removed_component_records"] is Array: job["removed_component_records"] = []
    # 0.15.0: a save from before Complete repaste existed counts its grade as completed thermal paste.
    if typeof(saved) == TYPE_DICTIONARY and not (saved as Dictionary).has("paste_done"):
        job["paste_done"] = str(job["paste_grade"]) != ""
    job["paste_done"] = bool(job["paste_done"]) if typeof(job["paste_done"]) == TYPE_BOOL else false
    job["paste_graded_units"] = maxf(0.0, float(job.get("paste_graded_units", 0.0)))
    job["cooler_film_peeled"] = bool(job.get("cooler_film_peeled", false)) if typeof(job.get("cooler_film_peeled", false)) == TYPE_BOOL else false
    job["install_faults"] = InstallFaults.sanitize(job.get("install_faults", []))
    job["gpu_screws"] = clampi(int(job.get("gpu_screws", 2)), 0, InstallFaults.GPU_SCREW_COUNT) if typeof(job.get("gpu_screws", 2)) in [TYPE_INT, TYPE_FLOAT] else InstallFaults.GPU_SCREW_COUNT
    job.erase("required_power")   # 0.25.0 (D97): the boot test replaced the power threshold
    var specs: Variant = job.get("pc_specs", {})
    if not specs is Dictionary: specs = {}
    # D148 (0.45.0): the parts are the truth; pc_specs is derived from them. Old saves get the customer's PC.
    var default_pc: Dictionary = person(str(job.get("customer_id", ""))).get("pc", {})
    job["parts"] = PcBuild.sanitize(job["parts"] if job.get("parts", null) is Dictionary else default_pc)
    job["pc_specs"] = PcBuild.specs(job["parts"])
    job["loose_parts"] = CustomerPC.loose(job)
    if person(str(job.get("customer_id", ""))).is_empty():
        job["customer_id"] = "t001_mara"
        job["customer"] = Customers.customer("t001_mara")["name"]
    job["pc_powered"] = bool(job.get("pc_powered", false))
    job["infection"] = Malware.sanitize(job.get("infection", ""))
    job["cured"] = Malware.sanitize(job.get("cured", ""))
    job["ticket"] = Ticket.sanitize(job.get("ticket", {}))
    job["build"] = BuildRequest.sanitize(job.get("build", {})) if PcBuild.is_build(job) else {}   # 0.51.0
    job["tests"] = WorkReport.sanitize_tests(job.get("tests", {}))
    job["findings"] = Findings.sanitize(job.get("findings", []))
    job["board_out"] = PcBuild.board_out(job)
    job["overclock"] = Overclock.sanitize(job.get("overclock", {}))
    if not str(job["paste_material"]) in PasteMaterials.IDS: job["paste_material"] = "thermal"
    var valid_scams: Array = []
    if job["scams"] is Array:
        for scam in job["scams"]:
            if str(scam) == "toothpaste" and not "toothpaste" in valid_scams: valid_scams.append("toothpaste")
    job["scams"] = valid_scams
    if not job["service_replacement_ids"] is Dictionary: job["service_replacement_ids"] = {}
    var valid_broken: Array = []
    if typeof(job["broken_parts"]) == TYPE_ARRAY:
        for id in job["broken_parts"]:
            if str(id) in ServiceParts.IDS and not str(id) in valid_broken: valid_broken.append(str(id))
    job["broken_parts"] = valid_broken
    var valid_replacements: Dictionary = {}
    if typeof(job["service_replacements"]) == TYPE_DICTIONARY:
        for id in job["service_replacements"]:
            var tier: String = str(job["service_replacements"][id])
            if not ServiceParts.option(str(id), tier).is_empty(): valid_replacements[str(id)] = tier   # includes "model:<id>" (D149)
    job["service_replacements"] = valid_replacements
    # D150 (0.46.2): visible damage, shop test parts and dead slots, from known shapes only.
    var raw_damaged: Variant = job.get("damaged_parts", [])
    job["damaged_parts"] = (raw_damaged as Array).filter(func(id: Variant) -> bool: return str(id) in job["broken_parts"]) if raw_damaged is Array else []
    var raw_custody: Variant = job.get("shop_custody", [])
    job["shop_custody"] = (raw_custody as Array).filter(func(id: Variant) -> bool: return str(id) in ServiceParts.IDS and job["service_replacements"].has(str(id))) if raw_custody is Array else []
    var raw_dead: Variant = job.get("dead_slots", [])
    job["dead_slots"] = (raw_dead as Array).filter(func(id: Variant) -> bool: return str(id) == CustomerPC.GPU2_SLOT) if raw_dead is Array else []
    var shop: Dictionary = {}
    var raw_shop: Variant = job.get("shop_fitted", {})
    if raw_shop is Dictionary:
        for slot: Variant in raw_shop:
            var entry: Variant = raw_shop[slot]
            if entry is Dictionary and str(slot) in PcBuild.shop_fitted({"shop_fitted": {str(slot): entry}}): shop[str(slot)] = {"uid": str(entry.get("uid", "")), "model": str(entry["model"])}
    job["shop_fitted"] = shop
    _refresh_shop_condition()   # 0.50.0: rebuilt from the stock records, never trusted from the save
    job["dust_schema"] = 2
    # Never trust old or malformed containers/grades as proof of completed work.
    if not str(job["layout"]) in ["tower", "compact"]:
        job["layout"] = "tower"
    var clean_dust: Dictionary = {}
    for z: Dictionary in DustZones.zones():
        var raw: Variant = job["dust"].get(z["id"], 1.0 if z["id"] == "case_interior" else 0.0)
        clean_dust[z["id"]] = clampf(float(raw), 0.0, 1.0) if typeof(raw) in [TYPE_FLOAT, TYPE_INT] else 0.0
    job["dust"] = clean_dust
    if not job["dust_state"] is Dictionary: job["dust_state"] = {}
    if not PASTE_PENALTY.has(str(job["paste_grade"])):
        job["paste_grade"] = ""
    if not str(job["state"]) in ["open", "done"]:
        job["state"] = "open"
    _refresh_cleaned()
    return true


# ----- customers (D92-D95) -----

# The shop's live view of a customer: the data-file person plus earned trust and history.
func customer_view(id: String) -> Dictionary:
    var who: Dictionary = person(id)
    if who.is_empty(): return {}
    var state: Dictionary = customer_state.get(id, {})
    who["trust"] = clampi(int(state.get("trust", who.get("trust_start", 50))), 0, 100)
    who["history"] = state.get("history", [])
    return who


# The GPU power of the PC as it stands (original 100, a replacement its tier, broken 0).
# D148: the PC's combined graphics score (0 when its only card is broken or out).
func current_gpu_power() -> int:
    return roundi(float(PcBuild.effective(job)["graphics"]))


# Buying a game to test with (D94). Returns false when unknown, owned already or unaffordable.
func buy_game(game_id: String) -> bool:
    var game: Dictionary = Games.game(game_id)
    if game.is_empty() or game_id in owned_games or money < int(game["price"]): return false
    money -= int(game["price"])
    owned_games.append(game_id)
    save_game()
    return true


func owns_game(game_id: String) -> bool:
    return game_id in owned_games


# D105: a happy visit always gains at least 1 trust, an unhappy one always loses at least 1;
# bigger gaps move more (about 1 per 10 points from the threshold). Integer division used to
# swallow small scores entirely (Codex's cross-review of 0.25.0, finding 2).
func trust_step(score: int) -> int:
    var step: int = roundi((score - PickupScore.HAPPY_FROM) / 10.0)
    return maxi(1, step) if score >= PickupScore.HAPPY_FROM else mini(-1, step)


# ----- settings (D107): app-level, own file, never part of the game save -----

func set_sound_volume(value: float, persist: bool = true) -> void:
    sound_volume = clampf(value, 0.0, 1.0)
    var bus: int = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_mute(bus, sound_volume <= 0.001)
    AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(sound_volume, 0.001)))
    if persist:
        SaveStore.write(settings_path, {"sound_volume": sound_volume})


func _load_settings() -> void:
    var parsed: Variant = SaveStore.read(settings_path)
    var value: float = 1.0
    if parsed is Dictionary:
        value = float((parsed as Dictionary).get("sound_volume", 1.0))
    set_sound_volume(value, false)


# Called once, when the ticket first passes: score the pickup (D95) and write trust and history.
func _record_pickup(temp: float, faults: Variant = null, boots: bool = true) -> Dictionary:
    var who: Dictionary = customer_view(str(job.get("customer_id", "")))
    if who.is_empty(): return {}
    var specs: Dictionary = PcBuild.effective(job)   # 0.46.2: what is actually in the PC, test parts included
    var felt: Array = pickup_faults(temp) if faults == null else faults
    var result: Dictionary = PickupScore.score(who, temp, float(current_gpu_power()), float(specs["processing"]) * Overclock.cpu_factor(job), float(specs["ram_gb"]), PASS_TEMP, felt)
    var build: Dictionary = BuildRequest.record(job) if PcBuild.is_build(job) else {}
    if not build.is_empty():   # 0.51.0 (D159): a build is judged on its needs (hard) and wants (soft)
        result = BuildRequest.adjust(result, BuildRequest.review(build, specs, BuildRequest.fitted_parts(job), PcBuild.case_model(job), temp, Overclock.cpu_factor(job)))
    if not boots:
        result["score"] = 0   # 0.44.0: a PC handed back that does not start
        (result["misses"] as Array).push_front("the PC does not start")
    var days: int = PickupScore.comeback_days(int(result["score"]))
    var trust: int = clampi(int(who["trust"]) + (Morning.NO_BOOT_TRUST if not boots else trust_step(int(result["score"]))), 0, 100)
    tickets_taken += 1   # the NEXT ticket goes to the next customer in the rotation (D104)
    # 0.52.0 (D160): every pickup is a written review (customers are not always fair), and good work earns trust.
    var review: Dictionary = Reviews.pickup_review(world_seed, str(job["id"]), str(who["name"]), night_number, int(result["score"]), result["misses"], boots, not build.is_empty())
    _add_review(review)
    var earned: int = Reviews.pickup_points(int(result["score"]), boots)
    trust_points += earned
    var entry: Dictionary = {"ticket": str(job["id"]), "score": int(result["score"]), "misses": result["misses"],
        "comeback_days": days, "scams": (job["scams"] as Array).duplicate()}
    # 0.51.0 scam hook: what a build cost at new prices next to what the customer paid (no consequence yet).
    if not build.is_empty(): entry["build"] = {"budget": int(build["budget"]), "value": BuildRequest.value(job)}
    var state: Dictionary = customer_state.get(str(who["id"]), {"trust": int(who["trust"]), "history": []})
    state["trust"] = trust
    (state["history"] as Array).append(entry)
    while (state["history"] as Array).size() > HISTORY_KEEP:
        (state["history"] as Array).pop_front()
    customer_state[str(who["id"])] = state
    return {"score": int(result["score"]), "misses": result["misses"], "comeback_days": days, "trust": trust, "trust_before": int(who["trust"]),
        "review": review, "points": earned}


# ----- the morning (D136, Wave 3 session 3.2) -----

# The customer of the ACTIVE job collects it: the shop's own assessment, the hidden faults they notice
# now (the rest are queued to come back later), pay if it starts, trust and history. Marks the job done.
func collect_active() -> Dictionary:
    if job["state"] == "done": return {}
    job["pc_powered"] = true   # the customer switches it on at home, whatever state the shop left it in
    var check: Dictionary = assess()
    var temp: float = check["temp"]
    var boots: bool = check["boots"]
    var faults: Dictionary = Morning.split(pickup_faults(temp))
    var pickup: Dictionary = _record_pickup(temp, faults["now"], boots)
    var paid: int = Morning.pay(int(job["payout"]), boots)
    money += paid
    var is_build: bool = PcBuild.is_build(job)
    var handed: Array = _build_records()
    if is_build and job["build"] is Dictionary and not (job["build"] as Dictionary).is_empty():
        job["build"]["delivered"] = BuildRequest.delivered(job, handed)   # scam hook: what was handed over, by what the shop knew
    var hidden: Array = _hidden_deceptions(handed)
    var stock_before: Array = player_inventory.map(func(r: Dictionary) -> String: return str(r["uid"]))
    var kept: Array = settle_custody()   # D150: test parts become the customer's; needlessly replaced originals become yours
    if is_build and boots: _deliver_build()
    # 0.52.0 (D160): a working part of theirs kept by the shop is a deception they may find out about.
    if player_inventory.any(func(r: Dictionary) -> bool: return not str(r["uid"]) in stock_before and str(r.get("condition", "")) == PcBuild.WORKING): hidden.append("kept_part")
    var found: Array = Reviews.discoveries(world_seed, str(job["id"]), customer_view(str(job["customer_id"])), hidden)
    job["state"] = "done"
    job["temp"] = temp
    if not (faults["later"] as Array).is_empty():
        comebacks.append({"customer_id": str(job["customer_id"]), "customer": str(job["customer"]), "ticket": str(job["id"]),
            "faults": faults["later"], "nights_left": Morning.COMEBACK_NIGHTS})
    for f: Dictionary in found:   # each deception they will find out comes back on its own morning
        comebacks.append({"customer_id": str(job["customer_id"]), "customer": str(job["customer"]), "ticket": str(job["id"]),
            "faults": [str(f["fault"])], "nights_left": int(f["nights"])})
    save_game()
    var score: int = int(pickup.get("score", 0))
    return {"kind": "collected", "ticket": str(job["id"]), "customer": str(job["customer"]), "customer_id": str(job["customer_id"]),
        "paid": paid, "boots": boots, "score": score, "reaction": Morning.reaction(score, boots).replace("repair", "build") if is_build else Morning.reaction(score, boots), "misses": pickup.get("misses", []),
        "trust": int(pickup.get("trust", 0)), "trust_change": int(pickup.get("trust", 0)) - int(pickup.get("trust_before", 0)),
        "temp": temp, "kept": kept, "job": job.duplicate(true), "review": pickup.get("review", {}), "points": int(pickup.get("points", 0))}


# One morning passes for every queued comeback. Due ones cost trust and become report cards.
func advance_comebacks() -> Array:
    var ticked: Dictionary = Morning.tick(comebacks)
    comebacks = ticked["pending"]
    var cards: Array = []
    for entry: Dictionary in ticked["due"]:
        var who: Dictionary = customer_view(str(entry["customer_id"]))
        if who.is_empty(): continue
        var change: int = Morning.comeback_trust(entry["faults"])
        var state: Dictionary = customer_state.get(str(who["id"]), {"trust": int(who["trust"]), "history": []})
        state["trust"] = clampi(int(who["trust"]) + change, 0, 100)
        customer_state[str(who["id"])] = state
        # 0.52.0 (D160): they found something out and went online. Honest mistakes and scams both cost trustworthiness.
        var complaints: Array = Morning.complaints(entry["faults"])
        var review: Dictionary = Reviews.found_review(entry["faults"], complaints, night_number, str(entry["ticket"]), str(entry["customer"]))
        _add_review(review)
        var lost: int = Reviews.found_points(entry["faults"])
        trust_points = maxi(0, trust_points - lost)
        var scam: bool = (entry["faults"] as Array).any(func(f: Variant) -> bool: return Reviews.is_found(str(f)))
        cards.append({"kind": "comeback", "ticket": str(entry["ticket"]), "customer": str(entry["customer"]), "customer_id": str(entry["customer_id"]),
            "misses": complaints, "trust": int(state["trust"]), "trust_change": change, "review": review, "points": -lost,
            "reaction": ("Found out what you did on ticket %s, and wrote about it." if scam else "Came back about the repair of ticket %s.") % entry["ticket"]})
    save_game()
    return cards


# A fresh repair job for one customer, with the next ticket number (does not replace the active job).
func make_ticket_job(customer_id: String) -> Dictionary:
    ticket_sequence += 1
    var fresh: Dictionary = _make_job()
    var who: Dictionary = person(customer_id)
    if who.is_empty(): return fresh
    fresh["customer_id"] = customer_id
    fresh["customer"] = str(who["name"])
    fresh["complaint"] = str(who["complaint"])
    fresh["payout"] = int(who["payout"])
    fresh["parts"] = PcBuild.sanitize(who.get("pc", {}))
    fresh["pc_specs"] = PcBuild.specs(fresh["parts"])
    return fresh


func start_next_night() -> void:
    night_number += 1
    night_minutes = 0
    save_game()


# ----- 0.46.0: hardware bench parts (Wave 3 session 3.3b, D149) -----

# Buys any catalogue part into the drawer. False when unknown, unaffordable or the drawer is full.
func buy_catalog_part(id: String) -> bool:
    var p: Dictionary = Catalog.part(id)
    if p.is_empty() or money < int(p["price"]): return false
    var uid: String = "player_stock_%d" % inventory_sequence
    while player_inventory.any(func(item: Dictionary) -> bool: return item["uid"] == uid):
        inventory_sequence += 1
        uid = "player_stock_%d" % inventory_sequence
    var parts: Array = inventory_components()
    parts.append(Catalog.component(uid, id))
    var grid := GridInventory.new()
    var pc: Dictionary = PCLayout.profile(str(job["layout"]))
    grid.setup(pc["board"],pc["depth"],inventory_layout,parts)
    var new_index: int = grid.items.size()-1
    if not grid.can_store(new_index,grid.items[new_index]["cell"]): return false
    money -= int(p["price"])
    inventory_sequence += 1
    player_inventory.append({"uid":uid,"kind":str(p["type"]),"tier":"model","model":id,"owner":"player","condition":"working","known":PartCondition.fresh(PartCondition.NEW,"Bought new")})
    inventory_layout = grid.snapshot()
    save_game()
    return true


# Fits a bought catalogue part from the drawer into an EMPTY slot of the customer's PC (CPU socket,
# RAM, drive, PSU, or the second PCIe slot). Custody stays with the shop until collection.
func fit_catalog_stock(uid: String, slot: String) -> bool:
    if job["state"] == "done" or PcBuild.board_out(job): return false
    var record: Dictionary = _record(uid)
    if record.is_empty() or not stock_available(uid): return false
    var model: String = PcBuild.stock_model(record)
    var type: String = str(Catalog.part(model).get("type", ""))
    var p: Dictionary = PcBuild.sanitize(job.get("parts", {}))
    var shop: Dictionary = job.get("shop_fitted", {})
    if shop.has(slot): return false
    # D150 (0.46.2): the slot must be physically free; the part stays the shop's (a test) until collection.
    var free: bool = false
    if slot == CustomerPC.CPU_SLOT: free = type == Catalog.CPU and str(p["cpu"]) == ""
    elif slot == CustomerPC.PSU_SLOT: free = type == Catalog.PSU and str(p["psu"]) == ""
    elif slot in CustomerPC.RAM_SLOTS: free = type == Catalog.RAM and (p["ram"] as Array).size() + shop.keys().filter(func(k: String) -> bool: return k in CustomerPC.RAM_SLOTS).size() < CustomerPC.RAM_SLOTS.size()
    elif slot in CustomerPC.STORAGE_SLOTS: free = type == Catalog.STORAGE and (p["storage"] as Array).size() + shop.keys().filter(func(k: String) -> bool: return k in CustomerPC.STORAGE_SLOTS).size() < CustomerPC.STORAGE_SLOTS.size()
    elif slot == CustomerPC.GPU2_SLOT: free = type == Catalog.GPU and (p["gpus"] as Array).size() < 2
    if not free: return false
    if PcBuild.is_build(job) and assembly_blocker(type) != "": return false   # 0.51.0: assembly costs night time
    var before: Array = Findings.configuration(job)
    if PcBuild.is_build(job): night_minutes += BuildRequest.minutes(type)
    shop[slot] = {"uid": uid, "model": model}
    _carry_condition(slot, _record(uid))   # 0.50.0
    job["shop_fitted"] = shop
    record["fitted_in"] = str(job["id"])
    record["slot"] = slot
    inventory_layout.erase(uid)
    _note_build(before)
    save_game()
    return true


# Writes a hardware-bench snapshot of the customer's parts back into the job. Returns true when the
# PC's contents changed (the bench then re-projects). `snapshot`: GridInventory.snapshot().
func apply_bench(snapshot: Dictionary) -> bool:
    if job["state"] == "done": return false
    if PcBuild.board_out(job):   # 0.48.1: with the motherboard out, nothing can sit on a slot
        for key: Variant in snapshot:
            if snapshot[key] is Dictionary and str((snapshot[key] as Dictionary).get("location", "drawer")) != "drawer": return false
    var before: String = str([job.get("parts", {}), job.get("loose_parts", []), job.get("service_replacements", {}), job.get("removed_parts", []), job.get("dead_slots", [])])
    var configured: Array = Findings.configuration(job)
    var result: Dictionary = CustomerPC.apply(job, snapshot)
    var loose: Array = result["loose_parts"]
    var p: Dictionary = result["parts"]
    # A customer's own card or cooler dropped on the first slot takes over from the one that was there.
    for kind: String in result["first"]:
        var entry: Dictionary = result["first"][kind]
        if not kind in job["removed_parts"] or kind in job["shop_custody"]:
            loose.append(entry)
            continue
        # D150: health never decides this; a part that does not work goes in and simply does not work.
        loose.append({"id": CustomerPC.catalog_id(job, CustomerPC.uid(job, kind)), "broken": kind in job["broken_parts"],
            "damaged": kind in job["damaged_parts"], "original_of": ""})
        if kind == Ids.GPU: p["gpus"][0] = entry["id"]
        else: p["cooler"] = entry["id"]
        job["service_replacements"].erase(kind)
        job["service_replacement_ids"].erase(kind)
        job["broken_parts"].erase(kind)
        job["damaged_parts"].erase(kind)
        if bool(entry["broken"]): job["broken_parts"].append(kind)
        if bool(entry["damaged"]): job["damaged_parts"].append(kind)
        job["removed_parts"].erase(kind)
        if kind == Ids.GPU: job["gpu_screws"] = 0
        else:
            job["paste_grade"] = ""
            job["paste_done"] = false
    for entry: Dictionary in loose: entry.erase("cell")
    job["parts"] = PcBuild.sanitize(p)
    job["pc_specs"] = PcBuild.specs(job["parts"])
    job["loose_parts"] = loose
    job["dead_slots"] = result.get("dead_slots", [])
    var changed: bool = before != str([job["parts"], job["loose_parts"], job.get("service_replacements", {}), job.get("removed_parts", []), job.get("dead_slots", [])])
    if changed:
        _note_build(configured)
        save_game()
    return changed


# ----- 0.50.0: real condition, knowledge and the testing bay (D158) -----

# Loads a record's hidden defect and the player's knowledge. Same shape as freshly made records (a
# defect key only on a degraded part), so a reload never makes stock look different.
func _with_knowledge(clean: Dictionary, raw: Dictionary) -> Dictionary:
    var defect: String = PartCondition.sanitize_defect(str(clean["kind"]), str(clean["condition"]), raw.get("defect", ""))
    if defect != "": clean["defect"] = defect
    clean["known"] = PartCondition.sanitize_known(raw.get("known", null), str(clean["condition"]))
    return clean


# Copies a fitted shop part's real condition into the job (rules read it from there). A dead
# first-slot GPU/cooler also counts as broken there, so the existing symptoms and return path apply.
func _carry_condition(key: String, record: Dictionary) -> void:
    if not job.get("shop_condition", {}) is Dictionary: job["shop_condition"] = {}
    if record.is_empty():
        (job["shop_condition"] as Dictionary).erase(key)
        return
    var condition: String = PartCondition.sanitize_condition(record.get("condition", "working"))
    job["shop_condition"][key] = {"condition": condition, "defect": str(record.get("defect", ""))}
    if condition == PcBuild.BROKEN and key in [Ids.GPU, Ids.COOLER] and not key in job["broken_parts"]: job["broken_parts"].append(key)


# Rebuilds the derived copy from the stock records (load, PC switch).
func _refresh_shop_condition() -> void:
    job["shop_condition"] = {}
    for kind: String in [Ids.GPU, Ids.COOLER]:
        if kind in job.get("shop_custody", []): _carry_condition(kind, _record(str(job["service_replacement_ids"].get(kind, ""))))
    var shop: Variant = job.get("shop_fitted", {})
    if shop is Dictionary:
        for slot: Variant in shop: _carry_condition(str(slot), _record(str((shop[slot] as Dictionary).get("uid", ""))))


func refresh_shop_condition() -> void:
    _refresh_shop_condition()


# Stock parts the testing bay can work on: the shop's, in the drawer, not fitted in a PC.
func bay_parts() -> Array:
    var out: Array = []
    for record: Dictionary in player_inventory:
        if str(record.get("fitted_in", "")) != "" or str(record["owner"]) != "player": continue
        var placement: Variant = inventory_layout.get(str(record["uid"]), {})
        if placement is Dictionary and str(placement.get("location", "drawer")) != "drawer": continue
        out.append(str(record["uid"]))
    return out


func stock_record(uid: String) -> Dictionary:
    return _record(uid).duplicate(true)


func _bay_kind(record: Dictionary) -> String:
    var kind: String = str(record.get("kind", ""))
    return "storage" if kind in ["storage", "sto"] else kind


func _note_part(record: Dictionary, text: String, test_id: String = "") -> void:
    var k: Dictionary = PartCondition.known(record)
    (k["notes"] as Array).append("Night %d · %s · %s" % [night_number, NightClock.label(night_minutes), text])
    if test_id != "" and not test_id in k["tests"]: (k["tests"] as Array).append(test_id)
    record["known"] = PartCondition.sanitize_known(k, str(record["condition"]))


# Looks closely at one spot of a stock part. The first look at a spot costs a minute; looking again
# only repeats what was seen. Returns {ok, text, message}.
func inspect_part(uid: String, spot: String) -> Dictionary:
    var record: Dictionary = _record(uid)
    if record.is_empty() or not uid in bay_parts(): return {"ok": false, "message": "That part is not on the testing bay."}
    if not spot in PartCondition.spots(_bay_kind(record)): return {"ok": false, "message": "Nothing to look at there."}
    var text: String = PartCondition.spot_text(_view_record(record), spot)
    var test_id: String = "inspect:" + spot
    if test_id in PartCondition.known(record)["tests"]: return {"ok": true, "text": text, "message": "%s: %s (already noted)" % [spot, text]}
    if not NightClock.fits(night_minutes, PartCondition.INSPECT_MINUTES): return {"ok": false, "message": "It is too close to 06:00 to start anything."}
    advance_night(PartCondition.INSPECT_MINUTES)
    _note_part(record, "Looked at the %s: %s" % [spot.to_lower(), text], test_id)
    save_game()
    return {"ok": true, "text": text, "message": "%s: %s" % [spot, text]}


# Runs the rig test on a stock part (quick or long), on the night clock. Returns {ok, message}.
func test_part(uid: String, long_test: bool) -> Dictionary:
    var record: Dictionary = _record(uid)
    if record.is_empty() or not uid in bay_parts(): return {"ok": false, "message": "That part is not on the testing bay."}
    var minutes: int = PartCondition.LONG_MINUTES if long_test else PartCondition.QUICK_MINUTES
    if not NightClock.fits(night_minutes, minutes): return {"ok": false, "message": "This test takes %d minutes and would run past 06:00. Not started." % minutes}
    var name_text: String = PartCondition.test_name(_bay_kind(record), long_test)
    var result: String = PartCondition.test_result(_view_record(record), long_test)
    advance_night(minutes)
    _note_part(record, "%s (%d min): %s" % [name_text, minutes, result], "long" if long_test else "quick")
    save_game()
    return {"ok": true, "message": "%s · %d night minutes\n%s" % [name_text, minutes, result]}


# The player's own call on a part. Free: it is a sticker, not a test. (Scam hook: it may disagree with
# the evidence; the tests list stays the honest record.)
func label_part(uid: String, label: String) -> bool:
    var record: Dictionary = _record(uid)
    if record.is_empty() or not label in PartCondition.PLAYER_LABELS or not uid in bay_parts(): return false
    var k: Dictionary = PartCondition.known(record)
    if str(k["label"]) == PartCondition.NEW and label == PartCondition.WORKING: return true
    k["label"] = label
    record["known"] = PartCondition.sanitize_known(k, str(record["condition"]))
    _note_part(record, "You marked it %s." % label)
    save_game()
    return true


# Sells a stock part for scrap. Returns the cash (0 when it could not be scrapped).
func scrap_part(uid: String) -> int:
    var record: Dictionary = _record(uid)
    if record.is_empty() or not uid in bay_parts(): return 0
    var cash: int = PartCondition.scrap_value(_bay_kind(record))
    player_inventory = player_inventory.filter(func(r: Dictionary) -> bool: return str(r["uid"]) != uid)
    inventory_layout.erase(uid)
    money += cash
    save_game()
    return cash


# A stock record as the rules see it (the bay's catalogue kind for storage records).
func _view_record(record: Dictionary) -> Dictionary:
    var view: Dictionary = record.duplicate(true)
    view["kind"] = _bay_kind(record)
    return view


# Salvage finds unloaded at the shop (0.50.0, user D158: "connect salvage runs to stock"). Each find
# becomes one untested stock part with a hidden real condition, or scrap when the shop cannot stock
# that kind. `finds` = [{uid, kind, site}]. Deterministic per find uid and the world seed.
func receive_salvage(finds: Array) -> Dictionary:
    var added: Array = []
    var scrap_cash: int = 0
    for find: Variant in finds:
        if not find is Dictionary: continue
        var made: Dictionary = SalvageStock.stock_for(find as Dictionary, world_seed, "salvage_%d" % inventory_sequence)
        if made.is_empty():
            scrap_cash += PartCondition.JUNK_SCRAP
            continue
        inventory_sequence += 1
        player_inventory.append(made)
        added.append(made)
    money += scrap_cash
    save_game()
    return {"added": added, "scrap_cash": scrap_cash}


# ----- 0.48.1: the motherboard (user, 18 November 2026) -----

# Why the motherboard cannot come out right now ("" = it can): every other part must be out first.
func board_blocker() -> String:
    if PcBuild.board_out(job): return "The motherboard is already out of the case."
    var p: Dictionary = PcBuild.sanitize(job.get("parts", {}))
    var still: Array = []
    if str(p["cpu"]) != "": still.append("CPU")
    if not Ids.COOLER in job["removed_parts"]: still.append("cooler")
    if not Ids.GPU in job["removed_parts"]: still.append("graphics card")
    if (p["gpus"] as Array).size() > 1: still.append("second graphics card")
    if not (p["ram"] as Array).is_empty(): still.append("memory")
    if not (p["storage"] as Array).is_empty(): still.append("drives")
    if str(p["psu"]) != "": still.append("power supply")
    var shop: Variant = job.get("shop_fitted", {})
    if shop is Dictionary and not (shop as Dictionary).is_empty(): still.append("your test parts")
    if still.is_empty(): return ""
    return "Take out every part first. Still fitted: %s." % ", ".join(still)


func take_out_board() -> bool:
    if job["state"] == "done" or board_blocker() != "": return false
    var before: Array = Findings.configuration(job)
    job["board_out"] = true
    _note_build(before)
    save_game()
    return true


func fit_board_back() -> bool:
    if job["state"] == "done" or not PcBuild.board_out(job): return false
    if PcBuild.is_build(job) and assembly_blocker("board") != "": return false   # 0.51.0
    var before: Array = Findings.configuration(job)
    if PcBuild.is_build(job): night_minutes += BuildRequest.minutes("board")
    job["board_out"] = false
    _note_build(before)
    save_game()
    return true


# ----- 0.51.0: build requests (session 3.7, D159) -----

# Why this assembly step cannot start now ("" = it can). Only builds charge assembly time.
func assembly_blocker(kind: String) -> String:
    if not PcBuild.is_build(job): return ""
    var minutes: int = BuildRequest.minutes(kind)
    if NightClock.fits(night_minutes, minutes): return ""
    return "Fitting the %s takes %d night minutes: it would run past 06:00." % [kind.to_upper() if kind.length() <= 3 else kind, minutes]


# A build request arrives: the customer pays half the budget; the basic case and the cheapest board the
# build starts in are paid from it. `arrival` is the new (not active) job. Returns the cash kept.
func take_build_deposit(arrival: Dictionary) -> int:
    var b: Dictionary = BuildRequest.sanitize(arrival.get("build", {}))
    if b.is_empty(): return 0
    var net: int = int(b["deposit"]) - BuildRequest.starter_cost(str(arrival.get("layout", "tower")))
    money += net
    save_game()
    return net


# Swaps a build's case (it must be empty: every part and the motherboard out). The old case goes back to
# the supplier unused (refunded), the new one is paid. A case of the other size takes a motherboard of its
# size: the board is swapped too (the cheapest that fits) when the current one does not fit. Returns
# {ok, message}.
func choose_build_case(id: String) -> Dictionary:
    if job["state"] == "done" or not PcBuild.is_build(job): return {"ok": false, "message": "Only a build's case can be swapped (repairs keep the customer's case)."}
    if not Catalog.is_case(id): return {"ok": false, "message": "Unknown case."}
    var current: String = PcBuild.case_model(job)
    if id == current: return {"ok": false, "message": "The build is already in that case."}
    if not PcBuild.board_out(job): return {"ok": false, "message": "A case is swapped empty: take every part out, then the motherboard, first."}
    var form: String = str(Catalog.CASES[id]["form"])
    var board_now: String = PcBuild.board_model(job)
    var board_new: String = board_now if str(Catalog.BOARDS[board_now]["form"]) == form else Catalog.cheapest_board(form)
    var cost: int = int(Catalog.CASES[id]["price"]) - int(Catalog.CASES[current]["price"]) + int(Catalog.BOARDS[board_new]["price"]) - int(Catalog.BOARDS[board_now]["price"])
    if money < cost: return {"ok": false, "message": "You need $%d more for that case." % (cost - money)}
    if not NightClock.fits(night_minutes, BuildRequest.minutes("case")): return {"ok": false, "message": "Swapping the case takes %d night minutes: it would run past 06:00." % BuildRequest.minutes("case")}
    money -= cost
    night_minutes += BuildRequest.minutes("case")
    var before_name: String = str(Catalog.case_model(current)["name"])
    job["layout"] = form
    job["parts"]["case"] = id
    job["parts"]["board"] = board_new
    job["parts"] = PcBuild.sanitize(job["parts"])
    var text: String = "Case swapped: %s out (refunded), %s in." % [before_name, Catalog.case_model(id)["name"]]
    if board_new != board_now: text += " The motherboard did not fit it: %s swapped for %s." % [Catalog.board(board_now)["name"], Catalog.board(board_new)["name"]]
    note(Findings.WORK, text, "hardware")
    save_game()
    return {"ok": true, "message": text + (" Cost $%d." % cost if cost >= 0 else " Refund $%d." % -cost)}


# Swaps a build's motherboard for another of the case's size while it is out of the case (refund the old,
# pay the new). Fitting it back costs the board's assembly time. Returns {ok, message}.
func choose_build_board(id: String) -> Dictionary:
    if job["state"] == "done" or not PcBuild.is_build(job): return {"ok": false, "message": "Only a build's motherboard can be swapped."}
    if not Catalog.is_board(id) or str(Catalog.BOARDS[id]["form"]) != ("compact" if str(job["layout"]) == "compact" else "tower"): return {"ok": false, "message": "That motherboard does not fit this case."}
    var current: String = PcBuild.board_model(job)
    if id == current: return {"ok": false, "message": "That motherboard is already the build's."}
    if not PcBuild.board_out(job): return {"ok": false, "message": "Take the motherboard out first (every part must be out)."}
    var cost: int = int(Catalog.BOARDS[id]["price"]) - int(Catalog.BOARDS[current]["price"])
    if money < cost: return {"ok": false, "message": "You need $%d more for that motherboard." % (cost - money)}
    money -= cost
    job["parts"]["board"] = id
    job["parts"] = PcBuild.sanitize(job["parts"])
    var text: String = "Motherboard swapped: %s out (refunded), %s in its place beside the case." % [Catalog.board(current)["name"], Catalog.board(id)["name"]]
    note(Findings.WORK, text, "hardware")
    save_game()
    return {"ok": true, "message": text + (" Cost $%d." % cost if cost >= 0 else " Refund $%d." % -cost)}


# The stock records of the shop parts in the active PC (first-slot ones and slot ones).
func _build_records() -> Array:
    var out: Array = []
    for kind: String in job.get("shop_custody", []): out.append(_record(str(job["service_replacement_ids"].get(kind, ""))).duplicate(true))
    for slot: String in job.get("shop_fitted", {}): out.append(_record(str(job["shop_fitted"][slot]["uid"])).duplicate(true))
    return out.filter(func(r: Dictionary) -> bool: return not r.is_empty())


# After a build is collected: the customer now owns that PC (a later visit brings it).
func _deliver_build() -> void:
    var who: Dictionary = person(str(job.get("customer_id", "")))
    if who.is_empty() or not bool(who.get("generated", false)): return
    who["pc"] = PcBuild.sanitize(job["parts"])
    remember_person(who)


func set_vacuum(bin_fill: float, hose: Array) -> void:
    vacuum_state = VacuumState.sanitize({"bin": bin_fill, "hose": hose})


# ----- 0.48.0: customers who are not in the data file (D153) -----

# Anyone who can bring a ticket: a story customer from customers.gd or a generated one. {} when unknown.
func person(id: String) -> Dictionary:
    var who: Dictionary = Customers.customer(id)
    if not who.is_empty(): return who
    var made: Variant = people.get(id, {})
    return (made as Dictionary).duplicate(true) if made is Dictionary else {}


# Stores (or updates) a generated customer's record.
func remember_person(record: Dictionary) -> void:
    var clean: Dictionary = _person_from(str(record.get("id", "")), record)
    if not clean.is_empty(): people[str(clean["id"])] = clean


func next_person_id() -> String:
    var id: String = "p%04d" % person_sequence
    person_sequence += 1
    return id


# Every customer the shop knows: story ones first, then generated ones by id.
func known_customers() -> Array:
    var ids: Array = Customers.IDS.duplicate()
    var made: Array = people.keys()
    made.sort()
    ids.append_array(made)
    return ids


# The online rating (stars) and the reputation (average trust of customers served).
func shop_rating() -> float:
    return TicketRating.rating(reviews)


# ----- 0.52.0: reviews, trustworthiness, the shop level, fake reviews (D160) -----

func _add_review(review: Dictionary) -> void:
    reviews.append(review)
    while reviews.size() > REVIEWS_KEEP: reviews.pop_front()


func shop_level() -> int:
    return Reviews.level(trust_points)


func standing_text() -> String:
    return Reviews.standing_text(trust_points)


# The deceptions in the active PC as it leaves the shop (before custody settles): toothpaste, shop parts
# that were not new, a build sold far above its parts' worth. `handed` = the shop parts' stock records.
func _hidden_deceptions(handed: Array) -> Array:
    var out: Array = []
    if "toothpaste" in job.get("scams", []): out.append("toothpaste")
    if handed.any(func(r: Dictionary) -> bool: return str(PartCondition.known(r)["label"]) != PartCondition.NEW): out.append("used_parts")
    var b: Dictionary = BuildRequest.record(job) if PcBuild.is_build(job) else {}
    if not b.is_empty() and float(BuildRequest.value(job)) < float(b["budget"]) * Reviews.OVERPRICED_SHARE: out.append("overpriced")
    return out


# The phone's ReviewBoost button: three five-star reviews for cash. Returns false when unaffordable.
func buy_fake_reviews() -> bool:
    if money < Reviews.FAKE_PRICE: return false
    money -= Reviews.FAKE_PRICE
    for review: Dictionary in Reviews.fake_reviews(world_seed, night_number, fake_orders.size()): _add_review(review)
    fake_orders.append(night_number)
    fake_orders = fake_orders.slice(maxi(0, fake_orders.size() - 10))
    save_game()
    return true


# The review site's morning check (`night` = the night that just ended). Caught: every bought review is
# removed, the site posts a notice and the shop loses trustworthiness. Returns a morning card or {}.
func check_fake_reviews(night: int) -> Dictionary:
    var chance: float = Reviews.catch_chance(fake_orders, night, reviews)
    if chance <= 0.0 or not Reviews.caught(world_seed, night, chance): return {}
    var removed: int = reviews.filter(func(r: Variant) -> bool: return r is Dictionary and str(r.get("kind", "")) == Reviews.FAKE).size()
    reviews = reviews.filter(func(r: Variant) -> bool: return not (r is Dictionary and str(r.get("kind", "")) == Reviews.FAKE))
    var text: String = "%s removed %d review%s it believes were bought, and flagged the shop's page." % [Reviews.SITE, removed, "" if removed == 1 else "s"]
    _add_review(Reviews.record(1, text, Reviews.NOTICE, night, "", Reviews.SITE))
    trust_points = maxi(0, trust_points - Reviews.CAUGHT_FAKES_POINTS)
    fake_orders = []
    save_game()
    return {"kind": "notice", "ticket": "", "customer": Reviews.SITE, "customer_id": "", "reaction": text, "points": -Reviews.CAUGHT_FAKES_POINTS}


func shop_reputation() -> int:
    var trusts: Array = []
    for id: Variant in customer_state: trusts.append(int(customer_state[id].get("trust", 50)))
    return TicketRating.reputation(trusts)


static func _new_seed() -> int:
    var value: int = 0
    while value == 0: value = int(Crypto.new().generate_random_bytes(4).decode_u32(0)) & 0x3fffffff
    return value


# Rebuilds a saved generated customer from known fields only ({} when it cannot be trusted).
func _person_from(id: String, raw: Variant) -> Dictionary:
    if not raw is Dictionary or not id.begins_with("p") or id.length() > 12 or not Customers.customer(id).is_empty(): return {}
    var r: Dictionary = raw
    var name_text: String = str(r.get("name", "")).strip_edges().left(40)
    var kind: String = str(r.get("profession", ""))
    if name_text == "" or not kind in PROFESSIONS: return {}
    var out: Dictionary = {"id": id, "name": name_text, "portrait": "", "scripted": false, "generated": true, "profession": kind}
    for key: String in ["persona", "about", "uses", "habits", "patience", "complaint"]: out[key] = str(r.get(key, "")).left(400)
    for key: String in ["trust_start", "budget", "payout"]:
        out[key] = clampi(int(r.get(key, 50 if key == "trust_start" else 0)), 0, 100000) if typeof(r.get(key, 0)) in [TYPE_INT, TYPE_FLOAT] else (50 if key == "trust_start" else 0)
    out["trust_start"] = clampi(int(out["trust_start"]), 0, 100)
    out["pc"] = PcBuild.sanitize(r.get("pc", {}))
    var needs: Variant = r.get("needs", {})
    if kind == "clueless" and needs is Dictionary and (needs as Dictionary).has("real"):
        out["needs"] = {"stated": _needs_from(needs.get("stated", {})), "real": _needs_from(needs.get("real", {}))}
    else:
        out["needs"] = _needs_from(needs)
    return out


static func _needs_from(raw: Variant) -> Dictionary:
    var out: Dictionary = {"boots": true}
    if not raw is Dictionary: return out
    if bool((raw as Dictionary).get("quiet", false)): out["quiet"] = true
    var games: Array = []
    var raw_games: Variant = (raw as Dictionary).get("games", [])
    if raw_games is Array:
        for g: Variant in raw_games:
            if g is Dictionary and not Games.game(str(g.get("game_id", ""))).is_empty() and typeof(g.get("min_fps", 0)) in [TYPE_INT, TYPE_FLOAT]:
                games.append({"game_id": str(g["game_id"]), "min_fps": clampi(int(g["min_fps"]), 1, 500)})
    if not games.is_empty(): out["games"] = games
    return out


# ----- 0.47.0: the Findings notebook (D150) -----

# Writes one notebook entry on the active ticket, stamped with the night clock, the night number and
# the PC's current fingerprint. Does NOT save (callers save once). Only text the player was shown.
func note(kind: String, text: String, source: String = "", until: int = -1, incomplete: bool = false, minute: int = -1) -> bool:
    if job["state"] == "done" or text.strip_edges() == "": return false
    var notes: Array = Findings.sanitize(job.get("findings", []))
    var at: int = night_minutes if minute < 0 else minute
    var added: bool = Findings.add(notes, Findings.entry(kind, text, night_number, at, WorkReport.signature(job), source, until, incomplete))
    job["findings"] = notes
    return added


# The same, saved. For the monitor's tests and the benches' inspections.
func record_finding(kind: String, text: String, source: String = "", until: int = -1, incomplete: bool = false, minute: int = -1) -> bool:
    var added: bool = note(kind, text, source, until, incomplete, minute)
    if added: save_game()
    return added


func findings_text() -> String:
    return Findings.text(job, WorkReport.signature(job))


# For solvability checks only (diagnosis.gd): what the shop can test with right now.
func diagnosis_capabilities() -> Dictionary:
    var stock: Dictionary = {}
    var models: Dictionary = {}
    for record: Dictionary in player_inventory:
        if not stock_available(str(record["uid"])) or not PartCondition.known_good(record): continue   # 0.50.0: untested spares prove nothing
        var kind: String = str(record["kind"])
        stock[kind] = int(stock.get(kind, 0)) + 1
        var model: String = PcBuild.stock_model(record)
        if model != "":
            if not models.has(kind): models[kind] = []
            (models[kind] as Array).append(model)
    # D153 option B: what the shop can afford to buy counts too (diagnosis.gd).
    return {"stock": stock, "models": models, "games": owned_games.duplicate(), "money": money, "buy": true}


func _note_build(before: Array) -> void:
    var change: String = Findings.change_text(before, Findings.configuration(job))
    if change != "": note(Findings.WORK, change, "hardware")


# ----- 0.46.2: custody of test parts and settlement at collection (D150) -----

func _record(uid: String) -> Dictionary:
    for record: Dictionary in player_inventory:
        if record["uid"] == uid: return record
    return {}


# The shop part in the first GPU slot / cooler mount comes out: it goes back to the drawer as stock,
# the slot is empty, and the customer's original (lying in the drawer) is again "the part that is out".
func return_replacement(part_id: String) -> bool:
    if job["state"] == "done" or not part_id in job["shop_custody"]: return false
    var before: Array = Findings.configuration(job)
    var record: Dictionary = _record(str(job["service_replacement_ids"].get(part_id, "")))
    if not record.is_empty():
        # Damage belongs to the removed shop component, not the original waiting in the drawer.
        if part_id in job["broken_parts"]: record["condition"] = "broken"
        if part_id in job["damaged_parts"]:   # the player saw it happen: they know (0.50.0)
            var k: Dictionary = PartCondition.known(record)
            k["label"] = PartCondition.DEAD
            (k["notes"] as Array).append("Damaged while you handled it in %s's PC." % str(job.get("customer", "a customer")))
            record["known"] = PartCondition.sanitize_known(k, str(record["condition"]))
        record.erase("fitted_in")
        record.erase("slot")
    job["shop_custody"].erase(part_id)
    job["service_replacements"].erase(part_id)
    job["service_replacement_ids"].erase(part_id)
    (job["shop_condition"] as Dictionary).erase(part_id)
    job["broken_parts"].erase(part_id)
    job["damaged_parts"].erase(part_id)
    var loose: Array = CustomerPC.loose(job)
    for i in range(loose.size()):
        if str(loose[i]["original_of"]) == part_id:
            if part_id == Ids.GPU: job["parts"]["gpus"][0] = str(loose[i]["id"])
            else: job["parts"]["cooler"] = str(loose[i]["id"])
            if bool(loose[i]["broken"]) and not part_id in job["broken_parts"]: job["broken_parts"].append(part_id)
            if bool(loose[i]["damaged"]) and not part_id in job["damaged_parts"]: job["damaged_parts"].append(part_id)
            loose.remove_at(i)
            break
    job["loose_parts"] = loose
    if not part_id in job["removed_parts"]: job["removed_parts"].append(part_id)
    if part_id == Ids.GPU: job["gpu_screws"] = 0
    job["pc_specs"] = PcBuild.specs(job["parts"])
    _note_build(before)
    save_game()
    return true


# Shop parts fitted in THIS PC on other slots, as bench components (they stay the shop's).
func fitted_components() -> Array:
    var out: Array = []
    for slot: String in job.get("shop_fitted", {}):
        var entry: Dictionary = job["shop_fitted"][slot]
        var component: Dictionary = Catalog.component(str(entry["uid"]), str(entry["model"]))
        if component.is_empty(): continue
        component["details"].append(["Owner","Your stock, fitted for a test until the customer collects"])
        out.append(component)
    return out


func unfit_catalog_stock(uid: String) -> bool:
    for slot: String in (job.get("shop_fitted", {}) as Dictionary).keys():
        if str(job["shop_fitted"][slot]["uid"]) == uid:
            var before: Array = Findings.configuration(job)
            job["shop_fitted"].erase(slot)
            (job["shop_condition"] as Dictionary).erase(slot)
            var record: Dictionary = _record(uid)
            record.erase("fitted_in")
            record.erase("slot")
            _note_build(before)
            save_game()
            return true
    return false


# At collection the PC leaves as it is. Shop parts in it become the customer's (they were paid for when
# bought: no second charge). A customer's WORKING part that a shop part replaced was a needless
# replacement: the player bears that cost and the original enters player stock. Other loose customer
# parts leave with the customer. Returns the names of originals kept in stock (for the morning report).
func settle_custody() -> Array:
    var kept: Array = []
    var consumed: Array = []
    var types_fitted: Dictionary = {}
    var permanent: Dictionary = PcBuild.sanitize(job.get("parts", {}))
    for part_id: String in job.get("shop_custody", []):
        consumed.append(str(job["service_replacement_ids"].get(part_id, "")))
        var original: String = str(permanent["gpus"][0]) if part_id == Ids.GPU else str(permanent["cooler"])
        var model: String = PcBuild.model_of(str(job["service_replacements"][part_id]), part_id, original)
        if part_id == Ids.GPU: permanent["gpus"][0] = model
        else: permanent["cooler"] = model
    for slot: String in job.get("shop_fitted", {}):
        consumed.append(str(job["shop_fitted"][slot]["uid"]))
        var model: String = str(job["shop_fitted"][slot]["model"])
        var type: String = str(Catalog.part(model).get("type", ""))
        types_fitted[type] = int(types_fitted.get(type, 0)) + 1
        # Transfer physical contents before clearing temporary custody. effective_parts() cannot
        # be used here: it removes faulty fitted parts, which must still travel with this PC.
        if slot == CustomerPC.CPU_SLOT: permanent["cpu"] = model
        elif slot == CustomerPC.PSU_SLOT: permanent["psu"] = model
        elif slot in CustomerPC.RAM_SLOTS: (permanent["ram"] as Array).append(model)
        elif slot in CustomerPC.STORAGE_SLOTS: (permanent["storage"] as Array).append(model)
        elif slot == CustomerPC.GPU2_SLOT: (permanent["gpus"] as Array).append(model)
    player_inventory = player_inventory.filter(func(record: Dictionary) -> bool: return not str(record["uid"]) in consumed)
    for entry: Dictionary in CustomerPC.loose(job):
        var type: String = str(Catalog.part(str(entry["id"])).get("type", ""))
        var replaced: bool = str(entry["original_of"]) in job.get("shop_custody", [])
        if not replaced and int(types_fitted.get(type, 0)) > 0:
            replaced = true
            types_fitted[type] = int(types_fitted[type]) - 1
        # 0.50.0 (user, D158): every replaced original stays with the shop, faulty or not, as UNTESTED
        # stock with its real condition hidden: the testing bay finds out. (Scam hook: reusing or
        # reselling a customer's old part.) Other loose customer parts leave with the customer.
        if replaced:
            var uid: String = "player_stock_%d" % inventory_sequence
            inventory_sequence += 1
            var actual: String = PcBuild.BROKEN if bool(entry["broken"]) or bool(entry["damaged"]) else PcBuild.WORKING
            var known_now: Dictionary = PartCondition.fresh(PartCondition.UNTESTED, "Taken out of %s's PC (%s)" % [str(job.get("customer", "")), str(job.get("id", ""))])
            if bool(entry["damaged"]):
                known_now["label"] = PartCondition.DEAD
                (known_now["notes"] as Array).append("You damaged it while working on it.")
            player_inventory.append({"uid":uid,"kind":type,"tier":"model","model":str(entry["id"]),"owner":"player","condition":actual,"known":known_now})
            kept.append(str(Catalog.part(str(entry["id"]))["name"]))
    job["parts"] = permanent
    job["pc_specs"] = PcBuild.specs(permanent)
    job["shop_custody"] = []
    job["shop_fitted"] = {}
    job["shop_condition"] = {}
    job["loose_parts"] = []
    return kept


# Keeps a saved record's custody marks (fitted in a customer PC for a test) when they are well formed.
func _custody(clean: Dictionary, raw: Dictionary) -> Dictionary:
    var where: Variant = raw.get("fitted_in", "")
    if where is String and where != "":
        clean["fitted_in"] = where
        clean["slot"] = str(raw.get("slot", ""))
    return clean

