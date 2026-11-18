# Structural regressions: complete owned-part journeys across two PCs, not only fitting once.
extends "res://tools/test_support.gd"
const Build = preload("res://scripts/rules/pc_build.gd")
const Findings = preload("res://scripts/rules/findings.gd")
const Report = preload("res://scripts/rules/work_report.gd")

func _initialize() -> void:
    call_deferred("run_checks")


# This checks existing shop-stock custody. It deliberately does not pretend that slot-derived
# CUSTOMER uids already implement the future physical-part registry (L1).
func check_custody(gs: Node, night: Node, label: String) -> void:
    var claims: Dictionary = {}
    var valid: bool = true
    var stock_ids: Dictionary = {}
    for record: Dictionary in gs.player_inventory:
        var key: String = str(record["uid"])
        valid = valid and not stock_ids.has(key)
        stock_ids[key] = true
    for job: Dictionary in night.jobs(gs):
        for kind: String in job.get("shop_custody", []):
            var key: String = str(job.get("service_replacement_ids", {}).get(kind, ""))
            valid = valid and key != "" and not claims.has(key)
            claims[key] = str(job["id"])
        for fitted: Dictionary in job.get("shop_fitted", {}).values():
            var key: String = str(fitted.get("uid", ""))
            valid = valid and key != "" and not claims.has(key)
            claims[key] = str(job["id"])
    for key: String in claims:
        var record: Dictionary = gs._record(key)
        valid = valid and not record.is_empty() and str(record.get("fitted_in", "")) == claims[key] and not gs.stock_available(key)
    for record: Dictionary in gs.player_inventory:
        valid = valid and str(record.get("fitted_in", "")) == str(claims.get(str(record["uid"]), ""))
    check(valid, label + ": each owned uid has at most one PC claim and matching stock custody")


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "part_lifecycle_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.new_game(false)
    gs.money = 1000
    check(night.start(gs), "create two customer PCs with the same GPU model")
    var first: String = night.active_id
    var second: String = str(night.tickets[1]["id"])
    check(gs.job["parts"]["gpus"][0] == night.tickets[1]["parts"]["gpus"][0] and not "gpu" in gs.job["broken_parts"] and "gpu" in night.tickets[1]["broken_parts"],
        "identical original models have different health on the two PCs")
    check(gs.buy_service_stock("gpu", "similar"), "obtain a second shop GPU of the same model")
    var other_gpu: String = ""
    for record: Dictionary in gs.player_inventory:
        if record["kind"] == "gpu" and record["tier"] == "similar" and record["uid"] != "trial_gpu": other_gpu = str(record["uid"])
    check(other_gpu != "" and Build.stock_model(gs._record(other_gpu)) == Build.stock_model(gs._record("trial_gpu")),
        "identical shop models have distinct physical stock uids")
    var starting_stock: int = gs.player_inventory.size()
    var starting_money: int = gs.money

    gs.set_service_part_fitted("gpu", false)
    check(gs.fit_inventory_part("gpu", "trial_gpu") and gs.fit_catalog_stock("trial_ram_a", "ram_2"), "first PC takes its own test GPU and RAM")
    check_custody(gs, night, "first fit")
    var first_configuration: Array = Findings.configuration(gs.job)
    check("\n".join(first_configuration).contains("trial_gpu") and "\n".join(first_configuration).contains("trial_ram_a"),
        "observed configuration names the actual test-part identities")
    check(night.switch_pc(gs, second), "switch to the second PC")
    gs.set_service_part_fitted("gpu", false)
    check(not gs.fit_inventory_part("gpu", "trial_gpu") and gs.fit_inventory_part("gpu", other_gpu),
        "one fitted uid cannot serve two PCs; the second identical spare can")
    check(gs.fit_catalog_stock("trial_ram_b", "ram_2") and gs.player_inventory.size() == starting_stock and gs.money == starting_money,
        "cross-PC temporary fits do not manufacture stock or charge again")
    check_custody(gs, night, "both PCs fitted")

    check(gs.damage_service_part("gpu") and gs.set_service_part_fitted("gpu", false), "damage and remove the second test GPU")
    check(gs._record(other_gpu).get("condition", "") == "broken" and gs._record("trial_gpu").get("condition", "") == "working",
        "damage follows only the second of two identical spares")
    check("gpu" in gs.job["broken_parts"] and not "gpu" in gs.job["damaged_parts"],
        "the second customer's original remains hidden-broken, not player-damaged")
    check_custody(gs, night, "damage return")
    check(night.checkpoint(gs), "save both PCs with active and inactive test-part custody")
    night.run_id = ""
    check(gs.load_game() and night.ensure(gs) and night.active_id == second, "reload the same active PC and complete queue")
    check(gs._record(other_gpu).get("condition", "") == "broken", "reload does not repair or discard the damaged stock record")
    check_custody(gs, night, "reload")

    check(night.switch_pc(gs, first) and Findings.configuration(gs.job) == first_configuration, "the inactive first PC retains its exact test-part configuration")
    check(gs.set_service_part_fitted("gpu", false) and not "gpu" in gs.job["broken_parts"], "restoring the first original preserves its healthy condition")
    check(gs.stock_available("trial_gpu") and gs.fit_inventory_part("gpu", "trial_gpu"), "the exact first spare can be returned and refitted without a copy")
    gs.record_test("hardware", {"ok": true})
    var measured: String = str(gs.job["tests"]["hardware"]["sig"])
    check(gs.unfit_catalog_stock("trial_ram_a") and Report.signature(gs.job) != measured, "returning a test part makes the old measurement historical")
    check(gs.fit_catalog_stock("trial_ram_a", "ram_2"), "refit the original test RAM uid before handover")
    check_custody(gs, night, "before collection")
    var delivered: Dictionary = Build.effective(gs.job)
    var card: Dictionary = gs.collect_active()
    check(card.get("kind", "") == "collected" and Build.effective(card["job"]) == delivered and Build.effective(gs.job) == delivered,
        "collection changes ownership without changing the delivered machine")
    check(gs._record("trial_gpu").is_empty() and gs._record("trial_ram_a").is_empty() and gs._record(other_gpu).get("condition", "") == "broken",
        "collection consumes only the first PC's spares, retaining the other damaged GPU")
    var after_collection: int = gs.player_inventory.size()
    check(gs.settle_custody().is_empty() and gs.player_inventory.size() == after_collection and Build.effective(gs.job) == delivered,
        "repeat settlement neither duplicates originals nor removes more parts")
    check(night.checkpoint(gs) and night.switch_pc(gs, second), "the other PC remains available after collection")
    check_custody(gs, night, "after collection")
    check(gs.unfit_catalog_stock("trial_ram_b") and gs.stock_available("trial_ram_b"), "the other PC can still return its own exact RAM uid")
    check(gs.set_service_part_fitted("gpu", true) and "gpu" in gs.job["broken_parts"], "the second original's hidden fault survives the whole journey")
    check(night.checkpoint(gs), "checkpoint the remaining PC")
    night.run_id = ""
    check(gs.load_game() and night.ensure(gs), "reload after one customer has collected")
    check(gs._record("trial_gpu").is_empty() and gs._record("trial_ram_a").is_empty() and gs.stock_available("trial_ram_b"),
        "reload cannot recreate the handed-over spares or lose the returned spare")
    check_custody(gs, night, "final reload")

    # RC-3: optional fields are tested missing and malformed, not just with complete happy-path data.
    var malformed: Array = [{"kind": "work", "text": "Known work"}, {"kind": "measurement", "text": "Known reading", "night": {}, "minute": [], "until": "bad", "incomplete": "yes"}, null, {"kind": "guess", "text": "Hidden conclusion"}]
    var clean: Array = Findings.sanitize(malformed)
    check(clean.size() == 2 and clean[0]["night"] == 1 and clean[1]["minute"] == 0 and not clean[1]["incomplete"],
        "missing/nested malformed optional notebook fields normalize without a missing-key crash")
    check(Findings.sanitize({"kind": "work"}).is_empty() and Report.sanitize_tests({"hardware": {}, "games": {"counter_stroke_2": {"fps": "bad"}}}) == {"games": {}},
        "malformed external containers do not certify measurements")
    _remove_save_files(manifest)
    restore_save(gs)
    finish("Part lifecycle")
