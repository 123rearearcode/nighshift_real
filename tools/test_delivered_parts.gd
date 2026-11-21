# A complete physical journey, including identical neighbours, delivery, comeback receipt, refitting,
# removal to stock, repeated collection and reload. Not a claim that legacy originals have migrated.
extends "res://tools/test_support.gd"
const Build = preload("res://scripts/rules/pc_build.gd")
const Customer = preload("res://scripts/rules/customer_pc.gd")
const Condition = preload("res://scripts/rules/part_condition.gd")
const Instances = preload("res://scripts/rules/part_instances.gd")
const Checks = preload("res://scripts/rules/software_checks.gd")
const Report = preload("res://scripts/rules/work_report.gd")
const Morning = preload("res://scripts/rules/morning.gd")
func _initialize() -> void: call_deferred("run_checks")

func stock(uid: String, kind: String, model: String, actual: String) -> Dictionary:
    var record: Dictionary = {"uid":uid,"kind":kind,"tier":"model","model":model,"owner":"player","condition":actual,"known":Condition.fresh("untested","Salvage")}
    var defect: String = Condition.sanitize_defect(kind,actual,"")
    if defect != "": record["defect"] = defect
    return record

func unfit_customer(gs: Node, key: String) -> void:
    var snapshot: Dictionary = Customer.placements(gs.job,{})
    snapshot[Customer.uid(gs.job,key)] = {"location":"drawer","cell":[0,0],"rotation":0}
    gs.apply_bench(snapshot)

func ready(gs: Node) -> void:
    gs.job["paste_grade"] = "GOOD ENOUGH"
    gs.job["paste_done"] = true
    gs.job["gpu_screws"] = 2
    gs.job["cooler_film_peeled"] = true
    gs.job["install_faults"] = []
    gs.job["pc_powered"] = true

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs,"delivered_parts_test.json")
    var manifest: String = gs.save_path+".night.json"
    _remove_save_files(manifest)
    gs.new_game(false)
    gs.money = 10000
    check(night.start(gs),"two PCs exist for active/inactive receipt recovery")
    var first: String = night.active_id
    var second: String = str(night.tickets[1]["id"])
    var source: Dictionary = stock("worn_gpu","gpu","gpu_gtx1660","degraded")
    gs.player_inventory.append(source)
    gs.player_inventory.append(stock("dead_ram","ram","ram_8gb","broken"))
    gs.player_inventory.append(stock("good_ram","ram","ram_8gb","working"))
    check(gs.set_service_part_fitted("gpu",false) and gs.fit_inventory_part("gpu","worn_gpu"),"fit the actual degraded source GPU")
    unfit_customer(gs,"ram_a")
    check((gs.job["parts"]["ram"] as Array).is_empty(),"customer RAM is outside before fitting two same-model spares")
    check(gs.fit_catalog_stock("dead_ram","ram_3") and gs.fit_catalog_stock("good_ram","ram_1"),"fit identical RAM with different condition in reverse slot order")
    ready(gs)
    var actual: Dictionary = Build.effective(gs.job)
    check(int(actual["ram_gb"]) == 8 and Build.unstable_minute(gs.job) == 12,"only the working RAM contributes; GPU artifacts remain real")
    var cash: int = gs.money
    var collected: Dictionary = gs.collect_active()
    check(collected.get("kind","") == "collected" and Build.effective(gs.job) == actual,"collection preserves the entire effective machine instead of healing it")
    check(Build.unstable_minute(gs.job) == 12 and "artifacts" in Build.defects(gs.job),"the delivered GPU keeps its real degraded behaviour")
    var physical: Dictionary = gs.job["part_instances"]
    check(physical["gpu"]["uid"] == "worn_gpu" and physical["gpu"]["condition"] == "degraded" and physical["gpu"]["defect"] == "artifacts","delivery retains physical identity and exact hidden defect")
    check(physical["ram_1"]["uid"] == "dead_ram" and physical["ram_2"]["uid"] == "good_ram","compacted model arrays retain the corresponding physical identities")
    check(physical["ram_1"]["condition"] == "broken" and physical["ram_2"]["condition"] == "working","same-model neighbours never exchange health")
    check(str(physical["gpu"]["owner"]) == "customer:"+str(gs.job["customer_id"]) and physical["gpu"]["known"] == source["known"],"ownership changes but actual knowledge is not invented or erased")
    check(gs._record("worn_gpu").is_empty() and gs._record("dead_ram").is_empty() and gs._record("good_ram").is_empty(),"handover removes each consumed stock instance exactly once")
    var paid_cash: int = gs.money
    var count: int = gs.player_inventory.size()
    var receipt: Dictionary = Instances.snapshot(gs.job)
    check(gs.settle_custody().is_empty() and gs.player_inventory.size() == count and gs.money == paid_cash and Instances.snapshot(gs.job) == receipt,"repeat settlement is idempotent and preserves the receipt")
    check(gs.money >= cash,"receipt preservation adds no extra part charge")
    var pending: Array = gs.comebacks.filter(func(e: Dictionary) -> bool: return Condition.UNSTABLE_FAULT in e["faults"])
    check(not pending.is_empty() and pending[0]["pc_snapshot"] == receipt,"delayed instability keeps the actual delivered PC receipt")
    check(night.checkpoint(gs) and night.switch_pc(gs,second),"save and leave the delivered PC inactive")
    night.run_id = ""
    check(gs.load_game() and night.ensure(gs) and night.switch_pc(gs,first),"reload another active PC, then restore the delivered one")
    check(Instances.snapshot(gs.job) == receipt and Build.effective(gs.job) == actual,"inactive receipt, identities and condition survive reload")
    gs.job["shop_condition"] = {"gpu":{"condition":"working"}}
    gs.refresh_shop_condition()
    check(Build.unstable_minute(gs.job) == 12,"a stale derived shop cache cannot repair a delivered customer part")
    var first_morning: Array = gs.advance_comebacks()
    check(first_morning.is_empty(),"two-day return is still delayed")
    gs.save_game()
    check(gs.load_game(),"pending comeback reloads")
    var due: Array = gs.advance_comebacks()
    var complaints: Array = due.filter(func(e: Dictionary) -> bool: return e.has("pc_snapshot"))
    check(not complaints.is_empty() and complaints[0]["pc_snapshot"] == receipt,"due comeback returns the unchanged receipt, not a healthy model-only PC")
    var evidence: String = str(Customer.service_component(gs.job,"gpu")["details"])
    check(not evidence.contains("artifacts") and not evidence.contains("degraded"),"customer hover data does not expose hidden delivered condition")

    # The existing comeback is a report, not a new automatic repair ticket. Reopen that same saved PC
    # as a fixture to exercise the real hardware mutators a future returned-ticket path will use.
    gs.job["state"] = "open"
    var before_swap: String = Report.signature(gs.job)
    var snapshot: Dictionary = Customer.placements(gs.job,{})
    snapshot[Customer.uid(gs.job,"ram_a")]["location"] = "ram_2"
    snapshot[Customer.uid(gs.job,"ram_b")]["location"] = "ram_1"
    check(gs.apply_bench(snapshot),"same-model RAM reorder commits a physical-instance change")
    check(gs.job["part_instances"]["ram_1"]["uid"] == "good_ram" and gs.job["part_instances"]["ram_2"]["uid"] == "dead_ram","record identity follows each RAM through reordering")
    check(Report.signature(gs.job) != before_swap and int(Build.effective(gs.job)["ram_gb"]) == 8,"reordering invalidates old measurements without changing the health of either stick")
    var unchanged_hardware: String = Report.signature(gs.job)
    gs.job["part_instances"]["ram_1"]["known"] = Condition.fresh("working","Marked by player")
    check(Report.signature(gs.job) == unchanged_hardware,"editing a label or evidence does not invalidate an unchanged physical measurement")
    unfit_customer(gs,"ram_b")
    var loose: Array = Customer.loose(gs.job)
    check(loose.size() == 1 and loose[0]["instance"]["uid"] == "dead_ram" and loose[0]["broken"],"delivered dead RAM moves outside with its actual record")
    gs.save_game()
    check(gs.load_game() and Customer.loose(gs.job)[0]["instance"]["uid"] == "dead_ram","loose instance survives normalization/reload")
    snapshot = Customer.placements(gs.job,{})
    snapshot[Customer.uid(gs.job,"loose_0")] = {"location":"ram_2","cell":[0,0],"rotation":0}
    gs.apply_bench(snapshot)
    check(gs.job["part_instances"]["ram_2"]["uid"] == "dead_ram" and int(Build.effective(gs.job)["ram_gb"]) == 8,"refitting keeps dead RAM dead and the identical good stick good")
    check(gs.set_service_part_fitted("gpu",false) and gs.fit_inventory_part("gpu","trial_gpu"),"temporarily replace the delivered degraded GPU")
    check(Build.unstable_minute(gs.job) == -1,"known-good substitution removes the symptom while fitted")
    check(gs.set_service_part_fitted("gpu",false) and gs.set_service_part_fitted("gpu",true),"undo the substitution and refit the customer's own card")
    check(Instances.get_part(gs.job,"gpu")["uid"] == "worn_gpu" and Build.unstable_minute(gs.job) == 12,"undo restores the original physical UID and fault")
    check(gs.set_service_part_fitted("gpu",false) and gs.fit_inventory_part("gpu","trial_gpu"),"make the good replacement permanent at the next collection")
    ready(gs)
    gs.collect_active()
    check(gs._record("worn_gpu")["condition"] == "degraded" and gs._record("worn_gpu")["defect"] == "artifacts","the customer's removed GPU returns to shop stock with the SAME physical UID and defect")
    check(gs._record("worn_gpu")["known"]["label"] == "untested" and gs.player_inventory.filter(func(r: Dictionary) -> bool: return r["uid"] == "worn_gpu").size() == 1,"D158 untested-original rule stays intact without duplicating the physical part")
    var returned: Dictionary = gs._record("worn_gpu").duplicate(true)
    gs.settle_custody()
    gs.save_game()
    check(gs.load_game() and gs._record("worn_gpu") == returned and gs._record("trial_gpu").is_empty(),"repeat collection and reload neither duplicate nor heal the returned original")

    # Every stockable kind retains its physical contents and degraded/broken contribution at handover.
    for kind: String in ["gpu","cooler","cpu","ram","storage","psu"]:
        for condition: String in ["degraded","broken"]:
            gs.new_game(false)
            var models: Dictionary = {"gpu":"gpu_gtx1660","cooler":"cool_stock_box","cpu":"cpu_i5_6060","ram":"ram_8gb","storage":"sto_hdd_500","psu":"psu_cv450"}
            var id: String = "probe_"+kind+"_"+condition
            gs.player_inventory.append(stock(id,kind,str(models[kind]),condition))
            var fitted: bool = false
            if kind in ["gpu","cooler"]:
                gs.set_service_part_fitted(kind,false)
                fitted = gs.fit_inventory_part(kind,id)
            else:
                var key: String = {"cpu":"cpu","ram":"ram_a","storage":"storage_a","psu":"psu"}[kind]
                unfit_customer(gs,key)
                fitted = gs.fit_catalog_stock(id,str({"cpu":"cpu","ram":"ram_1","storage":"m2_1","psu":"psu_bay"}[kind]))
            check(fitted,"fit %s %s fixture"%[condition,kind])
            ready(gs)
            var before: Dictionary = Build.effective(gs.job)
            var defects: Array = Build.defects(gs.job)
            var booted: Dictionary = Checks.boot(gs.job)
            gs.settle_custody()
            check(Build.effective(gs.job) == before and Build.defects(gs.job) == defects and Checks.boot(gs.job) == booted,"%s %s retains effective stats, defects and boot symptoms at delivery"%[condition,kind])
            gs.save_game()
            check(gs.load_game() and Build.effective(gs.job) == before and Build.defects(gs.job) == defects,"%s %s retains physical condition after load"%[condition,kind])

    # A removed delivered component which was not replaced goes home in a bag, never vanishes.
    gs.new_game(false)
    gs.player_inventory.append(stock("bag_ram","ram","ram_8gb","degraded"))
    unfit_customer(gs,"ram_a")
    gs.fit_catalog_stock("bag_ram","ram_1")
    gs.settle_custody()
    unfit_customer(gs,"ram_a")
    gs.settle_custody()
    check(Customer.loose(gs.job).size() == 1 and Customer.loose(gs.job)[0]["instance"]["uid"] == "bag_ram" and gs._record("bag_ram").is_empty(),"unreplaced removed part leaves in the customer's bag with its identity, not as free shop stock")
    var bag: Dictionary = Instances.snapshot(gs.job)
    gs.settle_custody()
    gs.save_game()
    check(gs.load_game() and Instances.snapshot(gs.job) == bag and bag["loose_parts"][0]["instance"]["condition"] == "degraded","bag identity and condition survive repeat settlement, receipt sanitization and reload")
    check(Instances.sanitize(null).is_empty() and Instances.sanitize({"ram_1":[],"bad":{}}).is_empty(),"missing/malformed optional record containers are safe")
    var duplicate: Dictionary = stock("same","ram","ram_8gb","degraded")
    check(Instances.sanitize({"ram_1":duplicate,"ram_2":duplicate}).size() == 1,"duplicate external identities cannot create two physical records")
    check(Instances.sanitize_snapshot({"parts":[]}).is_empty() and Morning.sanitize_pending([{"faults":[Condition.UNSTABLE_FAULT],"pc_snapshot":[]}])[0].get("pc_snapshot",{}).is_empty(),"malformed receipt fields cannot invent a healthy returned machine")
    var legacy: Dictionary = gs._make_job()
    legacy.erase("part_instances")
    gs.job = legacy
    gs.save_game()
    check(gs.load_game() and gs.job["part_instances"].is_empty(),"old saves migrate without inventing already-lost physical identities")
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Delivered parts")
