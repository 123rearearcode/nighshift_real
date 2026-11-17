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
const GOOD_PASTE: Array = ["PERFECT", "GOOD ENOUGH"]   # mount results good enough to complete the repaste

const SAVE_PATH: String = "user://nightshift_save.json"
const SETTINGS_PATH: String = "user://nightshift_settings.json"
const HISTORY_KEEP: int = 10    # pickup history entries kept per customer (D106, proposal)
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
        "gpu_screws": 2,          # D131: GPU bracket screw turns done (2 = tight). Removing or replacing the GPU at the hardware bench resets it to 0
        "install_faults": [],     # D130: hidden mistakes of the last locked mount (install_faults.gd); felt only at pickup
        "parts": PcBuild.sanitize(who.get("pc", {})),   # D148 (0.45.0): the customer's PC as catalogue parts
        "pc_specs": PcBuild.specs(who.get("pc", {})),   # derived from "parts" (processing, RAM) for the fps simulation (D94)
        "ticket": {"request": "repair", "ready": false, "called": false, "nights": 0},   # D134/D135: pickup flags (ticket.gd); the record itself is derived
        "cured": "",              # D133: strain the anti-virus removed on this ticket (for the work report)
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
    job["dust"] = fractions.duplicate()
    job["dust_state"] = physics
    _refresh_cleaned()
    save_game()


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
    save_game()
    return true

func replace_service_part(part_id: String, tier: String) -> bool:
    for record: Dictionary in player_inventory:
        if record["kind"] == part_id and record["tier"] == tier and stock_available(record["uid"]):
            return fit_inventory_part(part_id,record["uid"])
    return false

func fit_inventory_part(part_id: String, uid: String) -> bool:
    if job["state"] == "done" or not part_id in job["broken_parts"] or not part_id in job["removed_parts"]: return false
    var index: int = -1
    for i in range(player_inventory.size()):
        if player_inventory[i]["uid"] == uid: index = i
    if index < 0 or not stock_available(uid): return false
    var record: Dictionary = player_inventory[index]
    if record["kind"] != part_id or ServiceParts.option(part_id,record["tier"]).is_empty(): return false
    job["removed_component_records"].append({"uid":job["service_replacement_ids"].get(part_id,"customer_"+str(job["id"])+"_"+part_id),"kind":part_id,"tier":job["service_replacements"].get(part_id,"similar"),"condition":"broken","owner":"customer"})
    player_inventory.remove_at(index)
    inventory_layout.erase(uid)
    job["broken_parts"].erase(part_id)
    job["removed_parts"].erase(part_id)
    if part_id == Ids.GPU:
        job["gpu_screws"] = 0   # D131: a new card is not screwed in yet
    job["service_replacements"][part_id] = record["tier"]
    job["service_replacement_ids"][part_id] = uid
    if part_id == Ids.COOLER:
        job["paste_grade"] = ""
        job["paste_coverage"] = 0.0
        job["paste_overflow"] = 0.0
        job["paste_done"] = false
        job["scams"].erase("toothpaste")
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
    return [{"uid":"trial_ram_a","kind":"ram","tier":"similar","owner":"player","condition":"working"},
        {"uid":"trial_ram_b","kind":"ram","tier":"similar","owner":"player","condition":"working"},
        {"uid":"trial_gpu","kind":Ids.GPU,"tier":"similar","owner":"player","condition":"working"},
        {"uid":"stock_gpu_budget","kind":Ids.GPU,"tier":"budget","owner":"player","condition":"working"},
        {"uid":"stock_cooler_similar","kind":Ids.COOLER,"tier":"similar","owner":"player","condition":"working"},
        {"uid":"stock_cooler_budget","kind":Ids.COOLER,"tier":"budget","owner":"player","condition":"working"},
        # Last on purpose: the drawer packs in list order, and everything before keeps its cells.
        {"uid":"stock_cpu_demo","kind":"cpu","tier":"similar","owner":"player","condition":"working"}]

func inventory_components() -> Array:
    var stock: Array = []
    for record: Dictionary in player_inventory:
        var component: Dictionary
        if record["kind"] == "ram":
            component = ComponentData.ram_stick()
            component["id"] = record["uid"]
        elif record["kind"] == "cpu":
            component = ComponentData.cpu_chip()
            component["id"] = record["uid"]
        else: component = ServiceParts.component(record["uid"],record["kind"],record["tier"])
        stock.append(component)
    return stock

func stock_available(uid: String) -> bool:
    for record: Dictionary in player_inventory:
        if record["uid"] == uid:
            var placement: Variant = inventory_layout.get(uid,{})
            return record["condition"] == "working" and record["owner"] == "player" and (not placement is Dictionary or str(placement.get("location","drawer")) == "drawer")
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
    player_inventory.append({"uid":uid,"kind":kind,"tier":tier,"owner":"player","condition":"working"})
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
    if fitted:
        job["removed_parts"].erase(part_id)
    else:
        job["removed_parts"].append(part_id)
        if part_id == Ids.GPU:
            job["gpu_screws"] = 0
    save_game()
    return true


# D131: what the customer finds at pickup: recorded cooler-mount faults plus an unscrewed GPU.
func pickup_faults(temp: float = -1.0) -> Array:
    var at: float = float(job.get("temp", 0.0)) if temp < 0.0 else temp
    var faults: Array = InstallFaults.pickup_faults(job.get("install_faults", []), not Ids.GPU in job["removed_parts"], int(job.get("gpu_screws", 2)))
    faults.append_array(Malware.pickup_faults(job))      # D132
    faults.append_array(Overclock.pickup_faults(job, at))
    return faults


# D132: remove the infection the anti-virus found. Returns false when there is nothing to remove.
func clean_infection() -> bool:
    if job["state"] == "done" or not Malware.infected(job):
        return false
    job["cured"] = Malware.strain(job)
    job["infection"] = ""
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
    job["overclock"] = Overclock.sanitize({"mult": mult, "volt": volt})
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
    for id: String in job["service_replacements"]:
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
        "ticket_sequence": ticket_sequence,
        "upgrades": upgrades,
        "owned_games": owned_games,
        "customer_state": customer_state,
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
            if uid == "" or seen_stock.has(uid) or not kind in ["ram", "cpu", Ids.GPU, Ids.COOLER] or not tier in ["similar","budget"]: continue
            if str(record.get("owner","player")) != "player" or str(record.get("condition","working")) != "working": continue
            player_inventory.append({"uid":uid,"kind":kind,"tier":tier,"owner":"player","condition":"working"})
            seen_stock[uid] = true
    # Saves from before the CPU existed gain the demo CPU once (D116); later loads keep it.
    if raw_stock is Array and not (raw_stock as Array).is_empty() and not seen_stock.has("stock_cpu_demo"):
        player_inventory.append({"uid":"stock_cpu_demo","kind":"cpu","tier":"similar","owner":"player","condition":"working"})
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
    customer_state = {}
    var raw_customers: Variant = data.get("customer_state", {})
    if raw_customers is Dictionary:
        for cid: Variant in raw_customers:
            var record: Dictionary = Customers.customer(str(cid))
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
                    past.append({"ticket": str(v.get("ticket", "")), "score": clampi(int(v.get("score", 0)), 0, 100),
                        "misses": misses, "comeback_days": maxi(0, int(v.get("comeback_days", 0))), "scams": scams})
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
    var default_pc: Dictionary = Customers.customer(str(job.get("customer_id", ""))).get("pc", {})
    job["parts"] = PcBuild.sanitize(job["parts"] if job.get("parts", null) is Dictionary else default_pc)
    job["pc_specs"] = PcBuild.specs(job["parts"])
    if Customers.customer(str(job.get("customer_id", ""))).is_empty():
        job["customer_id"] = "t001_mara"
        job["customer"] = Customers.customer("t001_mara")["name"]
    job["pc_powered"] = bool(job.get("pc_powered", false))
    job["infection"] = Malware.sanitize(job.get("infection", ""))
    job["cured"] = Malware.sanitize(job.get("cured", ""))
    job["ticket"] = Ticket.sanitize(job.get("ticket", {}))
    job["tests"] = WorkReport.sanitize_tests(job.get("tests", {}))
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
            if not ServiceParts.option(str(id), tier).is_empty(): valid_replacements[str(id)] = tier
    job["service_replacements"] = valid_replacements
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
    var who: Dictionary = Customers.customer(id)
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
    var specs: Dictionary = job.get("pc_specs", {"cpu_power": 100, "ram_gb": 8})
    var felt: Array = pickup_faults(temp) if faults == null else faults
    var result: Dictionary = PickupScore.score(who, temp, float(current_gpu_power()), float(specs["cpu_power"]) * Overclock.cpu_factor(job), float(specs["ram_gb"]), PASS_TEMP, felt)
    if not boots:
        result["score"] = 0   # 0.44.0: a PC handed back that does not start
        (result["misses"] as Array).push_front("the PC does not start")
    var days: int = PickupScore.comeback_days(int(result["score"]))
    var trust: int = clampi(int(who["trust"]) + (Morning.NO_BOOT_TRUST if not boots else trust_step(int(result["score"]))), 0, 100)
    tickets_taken += 1   # the NEXT ticket goes to the next customer in the rotation (D104)
    var entry: Dictionary = {"ticket": str(job["id"]), "score": int(result["score"]), "misses": result["misses"],
        "comeback_days": days, "scams": (job["scams"] as Array).duplicate()}
    var state: Dictionary = customer_state.get(str(who["id"]), {"trust": int(who["trust"]), "history": []})
    state["trust"] = trust
    (state["history"] as Array).append(entry)
    while (state["history"] as Array).size() > HISTORY_KEEP:
        (state["history"] as Array).pop_front()
    customer_state[str(who["id"])] = state
    return {"score": int(result["score"]), "misses": result["misses"], "comeback_days": days, "trust": trust, "trust_before": int(who["trust"])}


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
    job["state"] = "done"
    job["temp"] = temp
    if not (faults["later"] as Array).is_empty():
        comebacks.append({"customer_id": str(job["customer_id"]), "customer": str(job["customer"]), "ticket": str(job["id"]),
            "faults": faults["later"], "nights_left": Morning.COMEBACK_NIGHTS})
    save_game()
    var score: int = int(pickup.get("score", 0))
    return {"kind": "collected", "ticket": str(job["id"]), "customer": str(job["customer"]), "customer_id": str(job["customer_id"]),
        "paid": paid, "boots": boots, "score": score, "reaction": Morning.reaction(score, boots), "misses": pickup.get("misses", []),
        "trust": int(pickup.get("trust", 0)), "trust_change": int(pickup.get("trust", 0)) - int(pickup.get("trust_before", 0)),
        "temp": temp, "job": job.duplicate(true)}


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
        cards.append({"kind": "comeback", "ticket": str(entry["ticket"]), "customer": str(entry["customer"]), "customer_id": str(entry["customer_id"]),
            "misses": Morning.complaints(entry["faults"]), "trust": int(state["trust"]), "trust_change": change,
            "reaction": "Came back about the repair of ticket %s." % entry["ticket"]})
    save_game()
    return cards


# A fresh repair job for one customer, with the next ticket number (does not replace the active job).
func make_ticket_job(customer_id: String) -> Dictionary:
    ticket_sequence += 1
    var fresh: Dictionary = _make_job()
    var who: Dictionary = Customers.customer(customer_id)
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
