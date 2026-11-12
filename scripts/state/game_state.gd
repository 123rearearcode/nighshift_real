# GAME STATE (autoload named "GameState"): cash, the current repair ticket, save/load.
# Saves to user://nightshift_save.json after every change. No drawing, no UI here.
# All numbers are demo values for the trial, not approved balance.
extends Node

const ComponentData = preload("res://scripts/data/component_data.gd")
const GridInventory = preload("res://scripts/bench/grid_inventory.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const SaveStore = preload("res://scripts/state/save_store.gd")

const SAVE_PATH: String = "user://nightshift_save.json"
# Bump only when the saved data changes shape incompatibly (and log it in CHANGELOG.md).
const SAVE_FORMAT: int = 1
const START_MONEY: int = 100
const PAYOUT: int = 60
const PASS_TEMP: float = 75.0        # final check passes below this temperature (C)
const BASE_TEMP: float = 42.0
const UPGRADE_PRICES: Dictionary = {"square_cloth": 40}   # demo prices
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
var money: int = START_MONEY
var job: Dictionary = {}
var upgrades: Dictionary = {}   # upgrade id -> true once bought


func _ready() -> void:
    if not load_game():
        new_game()


func new_game() -> void:
    money = START_MONEY
    ticket_sequence = 1
    job = _make_job()
    player_inventory = _starter_inventory()
    inventory_layout = {}
    inventory_sequence = 10
    upgrades = {}
    save_game()


func _make_job() -> Dictionary:
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
        "customer": "Customer A (placeholder)",
        "complaint": "PC overheats and the fan is very loud.",
        "state": "open",          # "open" or "done"
        "cleaned": false,         # true only when every dusty part is clean (derived from "dust")
        "dust": _fresh_dust(),               # zone id -> share of that part's dust removed (0..1)
        "paste_grade": "",        # "" = no fresh paste
        "paste_coverage": 0.0,
        "paste_overflow": 0.0,
        "temp": 0.0,              # last final-check temperature, 0 = not checked
        "payout": PAYOUT,
    }


# ----- dust -----

func dust_fraction(zone_id: String) -> float:
    var d: Dictionary = job["dust"]
    return clampf(float(d.get(zone_id, 0.0)), 0.0, 1.0)


# Store the removed share for every part at once: {zone id: fraction}. Recomputes "cleaned".
func set_dust(fractions: Dictionary) -> void:
    job["dust"] = fractions.duplicate()
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
    job["service_replacements"][part_id] = record["tier"]
    job["service_replacement_ids"][part_id] = uid
    if part_id == "cooler":
        job["paste_grade"] = ""
        job["paste_coverage"] = 0.0
        job["paste_overflow"] = 0.0
    save_game()
    return true

func _fresh_dust() -> Dictionary:
    var fractions: Dictionary = {}
    for zone: Dictionary in DustZones.zones(): fractions[zone["id"]] = 0.0
    return fractions

func start_repair_ticket() -> void:
    ticket_sequence += 1
    job = _make_job()
    save_game()

func _starter_inventory() -> Array:
    return [{"uid":"trial_ram_a","kind":"ram","tier":"similar","owner":"player","condition":"working"},
        {"uid":"trial_ram_b","kind":"ram","tier":"similar","owner":"player","condition":"working"},
        {"uid":"trial_gpu","kind":"gpu","tier":"similar","owner":"player","condition":"working"},
        {"uid":"stock_gpu_budget","kind":"gpu","tier":"budget","owner":"player","condition":"working"},
        {"uid":"stock_cooler_similar","kind":"cooler","tier":"similar","owner":"player","condition":"working"},
        {"uid":"stock_cooler_budget","kind":"cooler","tier":"budget","owner":"player","condition":"working"}]

func inventory_components() -> Array:
    var stock: Array = []
    for record: Dictionary in player_inventory:
        var component: Dictionary
        if record["kind"] == "ram":
            component = ComponentData.ram_stick()
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


func set_paste(result: Dictionary) -> void:
    job["paste_grade"] = result["grade"]
    job["paste_coverage"] = result["coverage"]
    job["paste_overflow"] = result["overflow"]
    save_game()


func clear_paste() -> void:
    job["paste_grade"] = ""
    job["paste_coverage"] = 0.0
    job["paste_overflow"] = 0.0
    save_game()


# Estimated CPU temperature from the work done. Pays out once, the first time it passes.
# Returns: temp, passed, notes (Array of String), paid (int), already_done (bool)
func run_final_check() -> Dictionary:
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
    if grade != "":
        penalty = float(PASTE_PENALTY.get(grade, NO_PASTE_PENALTY))
    temp += penalty
    if grade == "":
        notes.append("There is no fresh thermal paste on the CPU (+%d C)." % int(NO_PASTE_PENALTY))
    elif penalty > 0.0:
        notes.append("Paste result was %s (+%d C)." % [grade, int(penalty)])
    var removed_parts: Array = job.get("removed_parts", [])
    if not removed_parts.is_empty(): notes.append("Refit removed components before testing: " + ", ".join(removed_parts))
    var broken: Array = job["broken_parts"]
    if not broken.is_empty(): notes.append("Damaged parts must be replaced: " + ", ".join(broken))
    for id: String in job["service_replacements"]:
        var replacement: Dictionary = ServiceParts.option(id, str(job["service_replacements"][id]))
        temp += float(replacement["heat_penalty"])
        if replacement["performance"] < 100:
            notes.append("Downgrade: %s is %d%% of the original specification%s. Customer consequences are not simulated yet." % [id, replacement["performance"], " (+8 C)" if id == "cooler" else ""])
    var passed: bool = temp < PASS_TEMP and dirty_parts.is_empty() and removed_parts.is_empty() and broken.is_empty()
    if dirty_parts.is_empty() == false and temp < PASS_TEMP:
        notes.append("Every part must be cleaned before the job counts as done.")
    var already_done: bool = job["state"] == "done"
    var paid: int = 0
    if passed and not already_done:
        job["state"] = "done"
        paid = int(job["payout"])
        money += paid
    job["temp"] = temp
    save_game()
    return {"temp": temp, "passed": passed, "notes": notes, "paid": paid, "already_done": already_done}


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
            if uid == "" or seen_stock.has(uid) or not kind in ["ram","gpu","cooler"] or not tier in ["similar","budget"]: continue
            if str(record.get("owner","player")) != "player" or str(record.get("condition","working")) != "working": continue
            player_inventory.append({"uid":uid,"kind":kind,"tier":tier,"owner":"player","condition":"working"})
            seen_stock[uid] = true
    var saved_layout: Variant = data.get("inventory_layout",{})
    inventory_layout = saved_layout if saved_layout is Dictionary else {}
    var saved_up: Variant = data.get("upgrades", {})
    upgrades = {}
    if typeof(saved_up) == TYPE_DICTIONARY:
        var up_dict: Dictionary = saved_up
        for key in up_dict:
            if UPGRADE_PRICES.has(key) and bool(up_dict[key]):
                upgrades[key] = true
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
            job["dust"] = {"cooler": 1.0}
    if typeof(job["dust"]) != TYPE_DICTIONARY:
        job["dust"] = {}
    if not job["service_table_positions"] is Dictionary: job["service_table_positions"] = {}
    var valid_removed: Array = []
    if typeof(job["removed_parts"]) == TYPE_ARRAY:
        for id in job["removed_parts"]:
            if str(id) in ["cooler", "gpu"] and not str(id) in valid_removed: valid_removed.append(str(id))
    job["removed_parts"] = valid_removed
    if not job["hardware_trial"] is Dictionary: job["hardware_trial"] = {}
    if not data.has("inventory_layout"):
        var old_layout: Variant = job["hardware_trial"].get(str(job["layout"]),{})
        if old_layout is Dictionary: inventory_layout = old_layout.duplicate(true)
    if not job["removed_component_records"] is Array: job["removed_component_records"] = []
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
        var raw: Variant = job["dust"].get(z["id"], 0.0)
        clean_dust[z["id"]] = clampf(float(raw), 0.0, 1.0) if typeof(raw) in [TYPE_FLOAT, TYPE_INT] else 0.0
    job["dust"] = clean_dust
    if not PASTE_PENALTY.has(str(job["paste_grade"])):
        job["paste_grade"] = ""
    if not str(job["state"]) in ["open", "done"]:
        job["state"] = "open"
    _refresh_cleaned()
    return true
