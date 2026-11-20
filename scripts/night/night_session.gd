# Multi-ticket bridge while Claude owns GameState. Active PC stays in GameState.job;
# this manifest holds the inactive jobs. It never copies shop stock or money.
extends Node
const Store = preload("res://scripts/state/save_store.gd")
const Customers = preload("res://scripts/data/customers.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const Generator = preload("res://scripts/rules/ticket_generator.gd")
const ShopRating = preload("res://scripts/rules/shop_rating.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
var tickets: Array = []
var run_id: String = ""
var active_id: String = ""
var bound_path: String = ""
var status: String = ""
var read_only: bool = false
var last_report: Dictionary = {}   # D136 (0.44.0): the morning report just produced; shown by morning.tscn

func _marker(gs: Node) -> Dictionary:
    var trial: Variant = gs.job.get("hardware_trial",{})
    if not trial is Dictionary: return {}
    var marker: Variant = trial.get("night_session",{})
    return marker if marker is Dictionary else {}

func _tag(job: Dictionary,id: String,pc_id: String,kind: String = "repair") -> void:
    job["hardware_trial"]["night_session"] = {"run":run_id,"ticket":id,"pc":pc_id,"kind":kind}

func _path(gs: Node) -> String:
    return gs.save_path+".night.json"

func start(gs: Node) -> bool:
    run_id = Crypto.new().generate_random_bytes(12).hex_encode()
    bound_path = gs.save_path
    read_only = false
    status = ""
    tickets = []
    active_id = str(gs.job["id"])
    _tag(gs.job,active_id,run_id+":pc:1")
    tickets.append(gs.job.duplicate(true))
    # One extra real repair ticket, using the other existing customer (no invented persona).
    var other: Dictionary = gs.job.duplicate(true)
    var cid: String = Customers.IDS[1] if gs.job["customer_id"] == Customers.IDS[0] else Customers.IDS[0]
    var who: Dictionary = Customers.customer(cid)
    other["id"] = "T%03d"%(gs.ticket_sequence+1)
    other["customer_id"] = cid
    other["customer"] = who["name"]
    other["complaint"] = who["complaint"]
    other["payout"] = who["payout"]
    other["parts"] = PcBuild.sanitize(who.get("pc", {}))   # D148: this customer's own PC
    other["pc_specs"] = PcBuild.specs(other["parts"])
    other["layout"] = "compact"
    other["broken_parts"] = ["gpu"] if cid == "t002_relu" else []
    other["findings"] = []   # 0.47.0: each PC keeps its own notebook
    Malware.infect(other, Malware.ADWARE)   # D132: the second demo PC arrives with adware (the hint is in the complaint)
    _tag(other,str(other["id"]),run_id+":pc:2")
    tickets.append(other)
    gs.ticket_sequence += 1
    gs.save_game()
    if not _main_saved(gs):
        status = "New night could not be saved. Repair progress is only in memory; retry Save before quitting."
        return false
    return _write(gs)

func ensure(gs: Node) -> bool:
    var marker := _marker(gs)
    if bound_path == gs.save_path and run_id != "" and marker.get("run","") == run_id and marker.get("ticket","") == active_id:
        return not read_only
    tickets.clear()
    bound_path = gs.save_path
    read_only = false
    status = ""
    run_id = str(marker.get("run",""))
    active_id = str(marker.get("ticket",gs.job.get("id","")))
    if run_id == "":
        # Migrate existing progress as ONE real ticket; extra demo work is created only by New game.
        run_id = Crypto.new().generate_random_bytes(12).hex_encode()
        _tag(gs.job,active_id,"" if gs.job.get("state","open") == "done" else run_id+":pc:1")
        tickets.append(gs.job.duplicate(true))
        gs.save_game()
        if not _main_saved(gs):
            status = "Migrated PC could not be saved. Retry before quitting."
            return false
        return _write(gs)
    var raw: Variant = Store.read(_path(gs))
    if not raw is Dictionary or raw.get("version",0) != 1 or raw.get("run","") != run_id or not raw.get("tickets",null) is Array:
        return _protect(gs,"Ticket manifest is missing, damaged or from another run. Active PC recovered; switching is disabled to protect other jobs.")
    var ids: Dictionary = {}
    var pcs: Dictionary = {}
    for entry: Variant in raw["tickets"]:
        if not _valid(entry,gs) or ids.has(str(entry["id"])):
            return _protect(gs,"Ticket manifest contains an invalid job. Active PC recovered; switching is disabled.")
        var tag: Dictionary = entry["hardware_trial"]["night_session"]
        var pc_id: String = str(tag.get("pc",""))
        if tag.get("run","") != run_id or tag.get("ticket","") != entry["id"] or (pc_id != "" and pcs.has(pc_id)):
            return _protect(gs,"Ticket identities overlap. Switching is disabled; the original file is preserved.")
        ids[str(entry["id"])] = true
        if pc_id != "": pcs[pc_id] = true
        tickets.append(entry.duplicate(true))
    if not ids.has(active_id): return _protect(gs,"Active ticket is absent from the manifest. Switching is disabled.")
    capture(gs) # main save is authoritative for the active PC, including crash-time progress
    return true

func _valid(entry: Variant,gs: Node) -> bool:
    if not entry is Dictionary: return false
    for key: String in ["id","customer_id","customer","complaint","layout","state","paste_grade","paste_material"]:
        if not entry.get(key,null) is String: return false
    if not entry["layout"] in ["tower","compact"] or not entry["state"] in ["open","done"]: return false
    if gs.person(str(entry["customer_id"])).is_empty(): return false   # 0.48.0: story or generated customer
    for key: String in ["dust","dust_state","hardware_trial","service_table_positions","service_replacements","service_replacement_ids","pc_specs"]:
        if not entry.get(key,null) is Dictionary: return false
    for key: String in ["removed_parts","broken_parts","removed_component_records","scams"]:
        if not entry.get(key,null) is Array: return false
    for key: String in ["cleaned","paste_done","pc_powered"]:
        if not entry.get(key,null) is bool: return false
    for key: String in ["temp","payout","paste_coverage","paste_overflow","paste_graded_units"]:
        if not typeof(entry.get(key,null)) in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(entry[key])): return false
    for key: String in ["removed_parts","broken_parts","scams"]:
        for value: Variant in entry[key]:
            if not value is String: return false
    for value: Variant in entry["dust"].values():
        if not typeof(value) in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(value)) or value<0 or value>1: return false
    for value: Variant in entry["removed_component_records"]:
        if not value is Dictionary: return false
    for value: Variant in entry["service_table_positions"].values():
        if not value is Array or value.size()!=2: return false
        for coordinate: Variant in value:
            if not typeof(coordinate) in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(coordinate)): return false
    for key: String in ["cpu_power","ram_gb"]:
        if not typeof(entry["pc_specs"].get(key,null)) in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(entry["pc_specs"][key])): return false
    # B48 (0.48.0): a bought catalogue part fitted in the first slot is "model:<id>" (D149); accept every
    # option the game itself accepts, as the main save's loader does.
    for kind: Variant in entry["service_replacements"]:
        if ServiceParts.option(str(kind),str(entry["service_replacements"][kind])).is_empty(): return false
    return entry["hardware_trial"].get("night_session",null) is Dictionary

func _protect(gs: Node,message: String) -> bool:
    tickets = [gs.job.duplicate(true)]
    read_only = true
    status = message
    return false

func capture(gs: Node) -> void:
    for i in range(tickets.size()):
        if tickets[i]["id"] == active_id:
            tickets[i] = gs.job.duplicate(true)
            return

func _write(gs: Node) -> bool:
    if read_only: return false
    if not Store.write(_path(gs),{"version":1,"run":run_id,"tickets":tickets}):
        status = "Ticket progress could not be saved. Retry before switching PCs."
        return false
    status = ""
    return true

func checkpoint(gs: Node) -> bool:
    if not ensure(gs): return false
    capture(gs)
    gs.save_game()
    if not _main_saved(gs):
        status = "Active repair could not be saved. Retry before switching PCs."
        return false
    return _write(gs)

func _main_saved(gs: Node) -> bool:
    var raw: Variant = Store.read(gs.save_path)
    if not raw is Dictionary: return false
    for key: String in ["job","money","player_inventory","inventory_layout","inventory_sequence","ticket_sequence","upgrades","owned_games","customer_state","tickets_taken"]:
        if raw.get(key,null) != JSON.parse_string(JSON.stringify(gs.get(key))): return false
    return true

func jobs(gs: Node) -> Array:
    # Read-only projection must never initialize a campaign or manufacture work.
    if bound_path != gs.save_path or run_id == "" or _marker(gs).get("run","") != run_id: return [gs.job.duplicate(true)]
    capture(gs)
    return tickets.duplicate(true)

func switch_pc(gs: Node,id: String) -> bool:
    if not ensure(gs) or id == active_id: return id == active_id and not read_only
    var target: Dictionary = {}
    for entry: Dictionary in tickets:
        if entry["id"] == id: target = entry
    if target.is_empty() or target["hardware_trial"]["night_session"].get("pc","") == "": return false
    # Write ALL snapshots before switching the main save. If either write fails, keep the old PC.
    if not checkpoint(gs): return false
    var previous: Dictionary = gs.job
    gs.job = target.duplicate(true)
    gs.refresh_shop_condition()   # 0.50.0: fitted test parts behave as their stock record says
    gs.save_game()
    var written: Variant = Store.read(gs.save_path)
    if not written is Dictionary or written.get("job",{}).get("hardware_trial",{}).get("night_session",{}).get("ticket","") != id:
        gs.job = previous
        status = "Active PC could not be saved. The previous PC remains selected."
        return false
    active_id = id
    return true

# D134 (Wave 3 session 3.1): one ticket's job, active or not ({} when unknown). Read-only copy.
func ticket_job(gs: Node,id: String) -> Dictionary:
    if id == str(gs.job.get("id","")): return gs.job.duplicate(true)
    for entry: Dictionary in jobs(gs):
        if str(entry.get("id","")) == id: return entry
    return {}

# D134: applies a ticket menu action (ready sticker / call) to ANY ticket of tonight, active or stored,
# and saves both files. Returns the message to show; `status` explains a refusal.
func ticket_action(gs: Node,id: String,action: String) -> Dictionary:
    var job: Dictionary = ticket_job(gs,id)
    if job.is_empty(): return {"ok":false,"message":"That ticket is not part of tonight's work."}
    var result: Dictionary = Ticket.apply(job,action)
    if not result["ok"]: return result
    var session: bool = bound_path == gs.save_path and run_id != "" and _marker(gs).get("run","") == run_id
    if session and read_only: return {"ok":false,"message":status}
    if id == str(gs.job.get("id","")):
        gs.job["ticket"] = result["flags"]
    else:
        var found: bool = false
        for entry: Dictionary in tickets:
            if str(entry.get("id","")) == id:
                entry["ticket"] = result["flags"]
                found = true
        if not found: return {"ok":false,"message":"That ticket is not part of tonight's work."}
    if session:
        if not checkpoint(gs): return {"ok":false,"message":status}
    else:
        gs.save_game()
    return result

# ----- the morning (D136, Wave 3 session 3.2) -----

# One of tonight's tickets is a PC still in the shop (open, with a physical PC).
func _open_tickets() -> Array:
    return tickets.filter(func(entry: Dictionary) -> bool: return entry.get("state","open") != "done" and str(entry["hardware_trial"]["night_session"].get("pc","")) != "")

# 0.48.0 (session 3.5, D153): this morning's new customers. How many come follows the online rating
# and the reputation; each is a returning customer (who still trusts the shop) or a new person, and
# brings a generated case the shop can solve and can end well. Deterministic per save, night and slot.
func _arrivals(gs: Node,night: int) -> Dictionary:
    var present: Array = _open_tickets().map(func(entry: Dictionary) -> String: return str(entry["customer_id"]))
    var stars: float = gs.shop_rating()
    var rep: int = gs.shop_reputation()
    var count: int = ShopRating.arrivals(stars,rep,_open_tickets().size())
    var caps: Dictionary = gs.diagnosis_capabilities()
    var cards: Array = []
    for slot in range(count):
        var r: RandomNumberGenerator = Generator.rng_for(int(gs.world_seed),night,slot)
        var who: Dictionary = {}
        var pc: Dictionary = {}
        var returning: bool = false
        if r.randf() < Generator.RETURN_CHANCE:
            var known: Array = []
            for id: String in gs.known_customers():
                if not id in present and gs.customer_state.has(id) and int(gs.customer_view(id).get("trust",0)) >= Generator.RETURN_MIN_TRUST: known.append(id)
            if not known.is_empty():
                who = gs.customer_view(str(known[r.randi_range(0,known.size()-1)]))
                pc = who.get("pc",{})
                returning = true
        if who.is_empty(): who = Generator.new_person(r,gs.next_person_id())
        var drawn: Dictionary = Generator.draw_case(gs.make_ticket_job(""),who,pc,caps,night,r)
        if not bool(drawn["person"].get("scripted",false)): gs.remember_person(drawn["person"])
        var fresh: Dictionary = drawn["job"]
        _tag(fresh,str(fresh["id"]),run_id+":pc:"+str(fresh["id"]))
        tickets.append(fresh)
        present.append(str(fresh["customer_id"]))
        cards.append({"kind":"new","ticket":str(fresh["id"]),"customer":str(fresh["customer"]),"customer_id":str(fresh["customer_id"]),
            "returning":returning,"reaction":("Back again. " if returning else "New customer. ")+"New ticket: %s"%str(fresh["complaint"]),"job":fresh.duplicate(true)})
    gs.save_game()
    return {"cards":cards,"summary":ShopRating.summary(stars,gs.reviews.size(),rep,count),"rating":stars,"reputation":rep,"count":count}

# Ends the night: earlier comebacks arrive, called customers collect, everyone else waits one more
# night, collected PCs leave and new customers bring theirs, the clock resets. Returns the report.
func end_night(gs: Node) -> Dictionary:
    if not ensure(gs): return {"ok":false,"message":status}
    if not checkpoint(gs): return {"ok":false,"message":status}
    var night: int = int(gs.night_number)
    var cards: Array = gs.advance_comebacks()
    var collected: Array = []
    for entry: Dictionary in _open_tickets():
        if bool(Ticket.flags(entry)["called"]): collected.append(str(entry["id"]))
    for id: String in collected:
        if not switch_pc(gs,id): return {"ok":false,"message":status if status != "" else "Could not bring out ticket %s for collection."%id}
        var card: Dictionary = gs.collect_active()
        if not card.is_empty(): cards.append(card)
        if not checkpoint(gs): return {"ok":false,"message":status}
    for entry: Dictionary in _open_tickets():
        var f: Dictionary = Ticket.flags(entry)
        f["nights"] = int(f.get("nights",0)) + 1
        entry["ticket"] = f
        if str(entry["id"]) == str(gs.job["id"]): gs.job["ticket"] = f
        cards.append({"kind":"waiting","ticket":str(entry["id"]),"customer":str(entry["customer"]),"customer_id":str(entry["customer_id"]),
            "nights":int(f["nights"]),"reaction":"Still in your shop: %d night%s so far."%[int(f["nights"]),"" if int(f["nights"]) == 1 else "s"],
            "job":entry.duplicate(true)})
    # 0.48.0: new tickets come in with the morning, as many as the rating and reputation bring.
    var arrivals: Dictionary = _arrivals(gs,night+1)
    cards.append_array(arrivals["cards"])
    # The active PC must be one still in the shop.
    if gs.job.get("state","open") == "done":
        var next_id: String = str(_open_tickets()[0]["id"])
        if not switch_pc(gs,next_id): return {"ok":false,"message":status}
    tickets = tickets.filter(func(entry: Dictionary) -> bool: return entry.get("state","open") != "done" or str(entry["id"]) == active_id)
    gs.start_next_night()
    if not checkpoint(gs): return {"ok":false,"message":status}
    var earned: int = 0
    for card: Dictionary in cards: earned += int(card.get("paid",0))
    last_report = {"ok":true,"night":night,"cards":cards,"earned":earned,"cash":int(gs.money),"arrivals":arrivals["summary"],
        "rating":arrivals["rating"],"reputation":arrivals["reputation"]}
    return last_report
