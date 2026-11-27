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
const BuildRequest = preload("res://scripts/rules/build_request.gd")
const Reviews = preload("res://scripts/rules/reviews.gd")
const Backups = preload("res://scripts/state/save_backups.gd")   # B59 (0.57.11): morning backups
var tickets: Array = []
var run_id: String = ""
var active_id: String = ""
var bound_path: String = ""
var status: String = ""
var read_only: bool = false
var last_report: Dictionary = {}   # D136 (0.44.0): the morning report just produced; its customers walk in at the counter
var restored_note: String = ""     # B59 (0.57.11): what the last restore put back, shown once at the counter
var visits_pending: bool = false   # 0.53.0 (D161): true from the end of the night until the counter has shown every customer

func _marker(gs: Node) -> Dictionary:
    var trial: Variant = gs.job.get("hardware_trial",{})
    if not trial is Dictionary: return {}
    var marker: Variant = trial.get("night_session",{})
    return marker if marker is Dictionary else {}

func _tag(job: Dictionary,id: String,pc_id: String,kind: String = "repair") -> void:
    job["hardware_trial"]["night_session"] = {"run":run_id,"ticket":id,"pc":pc_id,"kind":kind}

func _path(gs: Node) -> String:
    return gs.save_path+".night.json"

func start(gs: Node, introduce_customers: bool = false) -> bool:
    run_id = Crypto.new().generate_random_bytes(12).hex_encode()
    bound_path = gs.save_path
    read_only = false
    status = ""
    visits_pending = false   # No later-morning report; opening intake has its own saved queue.
    last_report = {}
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
    # Introduce these SAME PCs, not generated copies, before the first night. Direct demo/test
    # callers retain the existing start() contract; the title's New game opts into the opening.
    gs.opening_customers = tickets.map(func(entry: Dictionary) -> String: return str(entry["id"])) if introduce_customers else []
    gs.ticket_sequence += 1
    gs.save_game()
    if not _main_saved(gs):
        status = "New night could not be saved. Repair progress is only in memory; retry Save before quitting."
        return false
    if not _write(gs): return false
    Backups.take(gs.save_path, int(gs.night_number))   # B59: the first morning is backed up too
    return true

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
    # B59 (0.57.11): a manifest of this format from another run is skipped like a damaged file, so the good
    # backup behind it is found. Anything else (a newer format, damaged tickets) is still read and protected.
    var raw: Variant = Store.read(_path(gs), func(data: Dictionary) -> bool: return data.get("version",0) != 1 or data.get("run","") == run_id)
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
    for key: String in ["job","money","player_inventory","inventory_layout","inventory_sequence","ticket_sequence","upgrades","owned_games","customer_state","tickets_taken","opening_customers"]:
        if raw.get(key,null) != JSON.parse_string(JSON.stringify(gs.get(key))): return false
    return true

func jobs(gs: Node) -> Array:
    # Read-only projection must never initialize a campaign or manufacture work.
    if bound_path != gs.save_path or run_id == "" or _marker(gs).get("run","") != run_id: return [gs.job.duplicate(true)]
    capture(gs)
    return tickets.duplicate(true)

func switch_pc(gs: Node,id: String) -> bool:
    if not gs.opening_customers.is_empty():
        status = "Serve the opening day's customers at the counter before starting night work."
        return false
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

# Opening intake uses existing jobs and public customer facts, not an end-night report. Its only
# persistent progress is GameState.opening_customers, saved with the main campaign record.
func opening_cards(gs: Node) -> Array:
    var cards: Array = []
    for id: String in gs.opening_customers:
        var entry: Dictionary = ticket_job(gs, id)
        if entry.is_empty() or entry.get("state", "open") == "done":
            status = "An opening customer has no matching repair ticket. Restore the saved ticket manifest before continuing."
            return []
        cards.append({"kind":"new", "ticket":id, "customer_id":str(entry["customer_id"]),
            "customer":str(entry["customer"]), "complaint":str(entry["complaint"]), "payout":int(entry["payout"])})
    return cards

func accept_opening_customer(gs: Node, id: String) -> bool:
    if gs.opening_customers.is_empty() or gs.opening_customers[0] != id:
        status = "That is not the customer waiting at the counter."
        return false
    if not ensure(gs) or opening_cards(gs).is_empty(): return false
    var before: Array = gs.opening_customers.duplicate()
    gs.opening_customers.pop_front()
    if not checkpoint(gs):
        var failure: String = status
        gs.opening_customers = before
        gs.save_game() # Restore pending progress if the main write succeeded but the manifest did not.
        status = failure
        return false
    return true

# ----- B59 (0.57.11): recovery from a damaged ticket book -----

# True when the protected state leaves no way on: the ticket manifest could not be trusted (switching and
# saving are refused), or customers wait at the counter whose tickets cannot be found.
func needs_recovery(gs: Node) -> bool:
    if str(_marker(gs).get("run","")) == "": return false   # no ticket book yet: nothing to recover, and no migration here
    if not ensure(gs) and read_only: return true
    return not gs.opening_customers.is_empty() and opening_cards(gs).is_empty()


# The user (27 November 2026): "try to restore it". Puts back the newest morning backup that loads and whose
# ticket book checks out, newest first. Nothing is deleted: the damaged files are kept aside by Backups.
# On failure the game stays protected, as before.
func restore_morning(gs: Node) -> bool:
    var originals: String = ""
    for morning: String in Backups.mornings(gs.save_path):
        var aside: String = Backups.restore(gs.save_path, morning)
        if aside == "": continue
        if originals == "": originals = aside
        bound_path = ""
        run_id = ""
        tickets = []
        if gs.load_game() and ensure(gs) and (gs.opening_customers.is_empty() or not opening_cards(gs).is_empty()):
            status = "Restored the shop as it was on the morning of night %d." % Backups.night_of(morning)
            restored_note = status
            return true
    if originals != "" and Backups.set_aside(gs.save_path) != "": Backups.copy_in(gs.save_path, originals)   # the player's own files back
    bound_path = ""
    run_id = ""
    tickets = []
    gs.load_game()
    ensure(gs)
    status = "No morning backup could be restored. The damaged files are kept in the backups folder next to the save."
    return false


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
        # 0.51.0 (session 3.7, D159): from night 4 some arrivals are build requests. A separate generator
        # decides, so a repair arrival draws exactly the case it drew before builds existed.
        var fresh_job: Dictionary = gs.make_ticket_job("")
        if BuildRequest.wanted(Generator.rng_for(int(gs.world_seed),night,slot+100),night,slot):
            who = Generator.new_person(r,gs.next_person_id())
            var order: Dictionary = Generator.draw_build(fresh_job,who,int(gs.money),night,r)
            if not order.is_empty():
                gs.remember_person(order["person"])
                var build_job: Dictionary = order["job"]
                _tag(build_job,str(build_job["id"]),run_id+":pc:"+str(build_job["id"]))
                var net: int = gs.take_build_deposit(build_job)
                tickets.append(build_job)
                present.append(str(build_job["customer_id"]))
                var spec: Dictionary = order["build"]
                cards.append({"kind":"new","ticket":str(build_job["id"]),"customer":str(build_job["customer"]),"customer_id":str(build_job["customer_id"]),
                    "returning":false,"paid":net,"build":true,
                    "reaction":"New customer. Build request: %s. %s Budget $%d: they paid $%d up front; the basic case and motherboard ($%d) came out of it."%[
                        str(BuildRequest.USES[spec["use"]]["label"]),str(build_job["complaint"]),int(spec["budget"]),int(spec["deposit"]),BuildRequest.starter_cost(str(build_job["layout"]))],
                    "job":build_job.duplicate(true)})
                continue
        if r.randf() < Generator.RETURN_CHANCE and who.is_empty():
            var known: Array = []
            for id: String in gs.known_customers():
                if not id in present and gs.customer_state.has(id) and int(gs.customer_view(id).get("trust",0)) >= Generator.RETURN_MIN_TRUST: known.append(id)
            if not known.is_empty():
                who = gs.customer_view(str(known[r.randi_range(0,known.size()-1)]))
                pc = who.get("pc",{})
                returning = true
        if who.is_empty(): who = Generator.new_person(r,gs.next_person_id())
        var drawn: Dictionary = Generator.draw_case(fresh_job,who,pc,caps,night,r)
        if not bool(drawn["person"].get("scripted",false)): gs.remember_person(drawn["person"])
        var fresh: Dictionary = drawn["job"]
        _tag(fresh,str(fresh["id"]),run_id+":pc:"+str(fresh["id"]))
        tickets.append(fresh)
        present.append(str(fresh["customer_id"]))
        cards.append({"kind":"new","ticket":str(fresh["id"]),"customer":str(fresh["customer"]),"customer_id":str(fresh["customer_id"]),
            "returning":returning,"reaction":("Back again. " if returning else "New customer. ")+"New ticket: %s"%str(fresh["complaint"]),"job":fresh.duplicate(true)})
    gs.save_game()
    return {"cards":cards,"summary":ShopRating.summary(stars,Reviews.counted(gs.reviews),rep,count),"rating":stars,"reputation":rep,"count":count}

# Ends the night: earlier comebacks arrive, called customers collect, everyone else waits one more
# night, collected PCs leave and new customers bring theirs, the clock resets. Returns the report.
func end_night(gs: Node) -> Dictionary:
    if not gs.opening_customers.is_empty():
        return {"ok":false,"message":"Serve the opening day's customers before closing the night."}
    if not ensure(gs): return {"ok":false,"message":status}
    if not checkpoint(gs): return {"ok":false,"message":status}
    var night: int = int(gs.night_number)
    var level_before: int = gs.shop_level()   # 0.52.0: the report says when the shop level changed
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
    # 0.52.0 (D160): the review site checks the shop's new reviews before the morning's customers read them.
    var notice: Dictionary = gs.check_fake_reviews(night)
    if not notice.is_empty(): cards.append(notice)
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
    Backups.take(gs.save_path, int(gs.night_number))   # B59 (0.57.11): every morning is backed up; the last 3 are kept
    var earned: int = 0
    for card: Dictionary in cards: earned += int(card.get("paid",0))
    visits_pending = true
    last_report = {"ok":true,"night":night,"cards":cards,"earned":earned,"cash":int(gs.money),"arrivals":arrivals["summary"],
        "rating":arrivals["rating"],"reputation":arrivals["reputation"],"standing":gs.standing_text(),"level":gs.shop_level(),"level_before":level_before}
    return last_report
