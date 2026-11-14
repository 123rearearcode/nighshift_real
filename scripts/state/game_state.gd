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
const GOOD_PASTE: Array = ["PERFECT", "GOOD ENOUGH"]   # mount results good enough to complete the repaste

const SAVE_PATH: String = "user://nightshift_save.json"
# Bump only when the saved data changes shape incompatibly (and log it in CHANGELOG.md).
const SAVE_FORMAT: int = 1
const START_MONEY: int = 100
const PAYOUT: int = 60
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
var money: int = START_MONEY
var job: Dictionary = {}
var upgrades: Dictionary = {}   # upgrade id -> true once bought


func _ready() -> void:
    if not load_game():
        new_game(false)   # title screen must not create/overwrite a save just by opening


func has_saved_game() -> bool:
    return SaveStore.read(save_path) is Dictionary


func new_game(persist: bool = true) -> void:
    money = START_MONEY
    ticket_sequence = 1
    job = _make_job()
    player_inventory = _starter_inventory()
    inventory_layout = {}
    inventory_sequence = 10
    upgrades = {}
    if persist:
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
        "customer_id": "t001_mara",   # key into scripts/data/customers.gd
        "customer": "Mara V.",
        "complaint": "PC overheats and the fan is very loud.",
        "state": "open",          # "open" or "done"
        "cleaned": false,         # true only when every dusty part is clean (derived from "dust")
        "dust_state": {},
        "dust": _fresh_dust(),               # zone id -> share of that part's dust removed (0..1)
        "paste_grade": "",        # "" = no fresh paste
        "paste_coverage": 0.0,
        "paste_overflow": 0.0,
        "paste_done": false,      # the player pressed Complete repaste on a good result
        "paste_graded_units": 0.0, # paste on the CPU when the grade was given (0 = no graded mount this session)
        "required_power": 60,     # the PC must output at least this much graphics power (D79; will be renamed)
        "pc_powered": true,       # the case power button (D83): fans stop while off
        "paste_material": "thermal",   # what is under the cooler: "thermal" or "toothpaste"
        "scams": [],              # what the customer was cheated on in this job (e.g. "toothpaste"); consequences not simulated yet
        "temp": 0.0,              # last final-check temperature, 0 = not checked
        "payout": PAYOUT,
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
        {"uid":"stock_cooler_budget","kind":Ids.COOLER,"tier":"budget","owner":"player","condition":"working"}]

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


# A finished mount: the result is recorded, but the repaste only counts once completed.
func set_paste(result: Dictionary, cpu_units: float = 0.0) -> void:
    job["paste_grade"] = result["grade"]
    job["paste_coverage"] = result["coverage"]
    job["paste_overflow"] = result["overflow"]
    job["paste_graded_units"] = cpu_units   # gauge units on the CPU at grading; the grade survives light wiping above 95% of this
    job["paste_done"] = false
    save_game()


func clear_paste() -> void:
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


# The Complete repaste button. `material` is what was squeezed ("thermal" or "toothpaste").
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
        if not under.is_empty() and float(under["heat_penalty"]) > 0.0:
            temp += float(under["heat_penalty"])
            notes.append("%s under the cooler (+%d C). The customer will not notice today; it dries out. Consequences are not simulated yet." % [under["label"], int(under["heat_penalty"])])
    # Graphics power (D79): a dead GPU outputs 0; a replacement outputs its tier's power.
    var required_power: int = int(job.get("required_power", 60))
    var gpu_power: int = 100
    if Ids.GPU in job["broken_parts"]:
        gpu_power = 0
    elif job["service_replacements"].has(Ids.GPU):
        gpu_power = int(ServiceParts.option(Ids.GPU, str(job["service_replacements"][Ids.GPU])).get("power", 100))
    if gpu_power < required_power:
        notes.append("Graphics output is %d; this PC needs at least %d. Fit a working graphics card." % [gpu_power, required_power])
    var removed_parts: Array = job.get("removed_parts", [])
    if not removed_parts.is_empty(): notes.append("Refit removed components before testing: " + ", ".join(removed_parts))
    var broken: Array = job["broken_parts"]
    if not broken.is_empty(): notes.append("Damaged parts must be replaced: " + ", ".join(broken))
    for id: String in job["service_replacements"]:
        var replacement: Dictionary = ServiceParts.option(id, str(job["service_replacements"][id]))
        temp += float(replacement["heat_penalty"])
        if replacement["performance"] < 100:
            notes.append("Downgrade: %s is %d%% of the original specification%s. Customer consequences are not simulated yet." % [id, replacement["performance"], " (+8 C)" if id == "cooler" else ""])
    # D87 (user, 2026-11-14): leftover dust is NOT a blocker. It only matters through the temperature
    # it adds (the notes keep saying where it is). The check passes while the PC is under the limit
    # and every part is functional: nothing broken, nothing left out, enough graphics output.
    var passed: bool = temp < PASS_TEMP and removed_parts.is_empty() and broken.is_empty() and gpu_power >= required_power
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
            if uid == "" or seen_stock.has(uid) or not kind in ["ram", Ids.GPU, Ids.COOLER] or not tier in ["similar","budget"]: continue
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
    job["required_power"] = maxi(0, int(job.get("required_power", 60)))
    if Customers.customer(str(job.get("customer_id", ""))).is_empty():
        job["customer_id"] = "t001_mara"
        job["customer"] = Customers.customer("t001_mara")["name"]
    job["pc_powered"] = bool(job.get("pc_powered", true))
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
