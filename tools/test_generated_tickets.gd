# 0.48.0 / session 3.5 (D153, D154): generated tickets. Online rating, reputation and arrivals; seeded,
# repeatable generation; difficulty by night; every offered case solvable (buying a part counts) and
# repairable to a happy pickup; generated customers saved and loaded; mornings bring generated tickets.
extends "res://tools/test_support.gd"
const Generator = preload("res://scripts/rules/ticket_generator.gd")
const ShopRating = preload("res://scripts/rules/shop_rating.gd")
const Diagnosis = preload("res://scripts/rules/diagnosis.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const Ids = preload("res://scripts/data/ids.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const HIDDEN_WORDS: Array = ["broken", "faulty", "dead", "fault", "miner", "adware", "virus", "overclock"]

func _initialize() -> void:
    call_deferred("run_checks")


func _caps(gs: Node, money: int = 100) -> Dictionary:
    var caps: Dictionary = gs.diagnosis_capabilities()
    caps["money"] = money
    return caps


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "generated_tickets_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.customer_state = {}
    gs.people = {}
    gs.reviews = []
    gs.new_game(false)

    # ---- rating, reputation, arrivals ----
    check(is_equal_approx(ShopRating.rating([]), 3.0) and is_equal_approx(ShopRating.rating([100, 100]), 5.0) and is_equal_approx(ShopRating.rating([0]), 1.0), "the rating starts at 3 stars and follows pickup scores from 1 to 5")
    var old_and_new: Array = [0, 0, 0, 0, 0]
    for i in range(10): old_and_new.append(100)
    check(is_equal_approx(ShopRating.rating(old_and_new), 5.0), "only the latest ten reviews count")
    check(ShopRating.reputation([]) == 50 and ShopRating.reputation([40, 80]) == 60, "reputation is the average trust of customers served")
    check(ShopRating.arrivals(3.0, 50, 0) == 1 and ShopRating.arrivals(3.6, 50, 0) == 2 and ShopRating.arrivals(4.6, 65, 0) == ShopRating.MAX_ARRIVALS, "a better rating and reputation bring more customers")
    check(ShopRating.arrivals(2.0, 30, 2) == 0 and ShopRating.arrivals(2.0, 30, 0) == 1, "a poor rating brings nobody new, but an empty shop always gets one walk-in")
    check(ShopRating.arrivals(4.6, 65, ShopRating.MAX_OPEN - 1) == 1 and ShopRating.arrivals(4.6, 65, ShopRating.MAX_OPEN) == 0, "never more PCs than the shop can hold")
    check(ShopRating.summary(4.2, 1, 55, 2).contains("4.2★ (1 review)") and ShopRating.summary(4.2, 1, 55, 2).contains("2 new customers"), "the morning says why this many came")

    # ---- seeded, repeatable generation ----
    var a: RandomNumberGenerator = Generator.rng_for(1234, 3, 0)
    var b: RandomNumberGenerator = Generator.rng_for(1234, 3, 0)
    var person_a: Dictionary = Generator.new_person(a, "p0001")
    var person_b: Dictionary = Generator.new_person(b, "p0001")
    check(person_a == person_b and Generator.new_person(Generator.rng_for(1234, 3, 1), "p0001") != person_a, "the same seed, night and slot give the same person; another slot gives another")
    var case_a: Dictionary = Generator.draw_case(gs.make_ticket_job(""), person_a, {}, _caps(gs), 3, a)
    var case_b: Dictionary = Generator.draw_case(gs.make_ticket_job(""), person_b, {}, _caps(gs), 3, b)
    case_a["job"].erase("id")
    case_b["job"].erase("id")
    check(case_a["job"] == case_b["job"] and case_a["events"] == case_b["events"], "the same draw gives the same case")
    check(str(person_a["name"]).ends_with(".") and person_a["profession"] in ["regular", "gamer", "clueless"] and not bool(person_a["scripted"]), "a generated customer is a parody name with a profession")

    # ---- every offered case: solvable, fits the night, repairable to a happy pickup ----
    var seen_levels: Dictionary = {}
    var seen_events: Dictionary = {}
    var bad: Array = []
    var leaks: Array = []
    var fallbacks: int = 0
    var professions: Dictionary = {}
    for n: int in [1, 2, 3, 4, 6, 8]:
        for slot in range(24):
            var r: RandomNumberGenerator = Generator.rng_for(777, n, slot)
            var who: Dictionary = Generator.new_person(r, "p%04d" % (slot + 1))
            var drawn: Dictionary = Generator.draw_case(gs.make_ticket_job(""), who, {}, _caps(gs), n, r)
            var job: Dictionary = drawn["job"]
            professions[str(drawn["person"]["profession"])] = true
            if bool(drawn["fallback"]): fallbacks += 1
            var temp: float = float(Diagnostics.evaluate(job, [])["temp"])
            var verdict: Dictionary = Generator.check(job, drawn["person"], _caps(gs), n)
            if not bool(verdict["ok"]) or int(drawn["level"]) > Generator.max_level(n) or not Diagnosis.solvable(job, temp, _caps(gs)):
                bad.append("night %d slot %d %s: %s" % [n, slot, str(drawn["events"]), str(verdict["reason"])])
            if not seen_levels.has(n): seen_levels[n] = {}
            seen_levels[n][int(drawn["level"])] = true
            for e: String in drawn["events"]: seen_events[e] = true
            for word: String in HIDDEN_WORDS:
                if str(job["complaint"]).to_lower().contains(word): leaks.append(str(job["complaint"]))
            if str(drawn["person"]["profession"]) == "clueless":
                check((drawn["person"]["needs"] as Dictionary).has("stated") and (drawn["person"]["needs"] as Dictionary).has("real"), "a clueless customer states a decoy need and has a real one")
    check(bad.is_empty(), "every generated case is solvable, fits its night and can end in a happy pickup: " + "; ".join(bad.slice(0, 3)))
    check(leaks.is_empty(), "complaints describe what the customer saw, never the hidden cause: " + "; ".join(leaks.slice(0, 2)))
    check(seen_levels[1].keys() == [Diagnosis.EVIDENT] and not seen_levels[2].has(Diagnosis.COMPARED) and not seen_levels[3].has(Diagnosis.COMPARED), "early nights only bring evident and one-test cases")
    check(seen_levels[2].has(Diagnosis.TESTED) and (seen_levels[6].has(Diagnosis.COMPARED) or seen_levels[8].has(Diagnosis.COMPARED)), "difficulty rises with the night: one-test cases from night 2, swap cases later")
    check(seen_events.has("overclock") and seen_events.has("adware") and seen_events.has("gpu_fault") and seen_events.size() >= 7, "the pool is varied, including PCs the customer overclocked: " + ", ".join(seen_events.keys()))
    check(professions.size() == 3, "regulars, gamers and clueless customers all come in")
    check(fallbacks < 10, "the fallback plain case stays rare (%d of 144)" % fallbacks)

    # ---- option B: a part the shop can buy counts as a test part ----
    var faulty: Dictionary = gs.make_ticket_job("")
    faulty["parts"] = PcBuild.sanitize({"cpu": "cpu_i5_6060", "gpus": ["gpu_gtx1660"], "ram": ["ram_8gb"], "storage": ["sto_ssd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"})
    check(Generator.apply_events(faulty, ["gpu_fault"], Generator.rng_for(1, 1, 1)), "a GPU fault applies")
    var no_gpu: Dictionary = _caps(gs, 100)
    no_gpu["stock"].erase(Ids.GPU)
    no_gpu["models"].erase(Ids.GPU)
    var temp_f: float = float(Diagnostics.evaluate(faulty, [])["temp"])
    check(Diagnosis.solvable(faulty, temp_f, no_gpu), "with no spare GPU, an affordable one to buy still makes the case solvable")
    var broke: Dictionary = no_gpu.duplicate(true)
    broke["money"] = 10
    check(not Diagnosis.solvable(faulty, temp_f, broke), "without a spare and without the money for one, it is not")
    var small: Dictionary = gs.make_ticket_job("")
    small["parts"] = PcBuild.sanitize(Customers_pc())
    check(Generator.apply_events(small, ["psu_small"], Generator.rng_for(1, 1, 2)) and not bool(PcBuild.effective(small)["powered"]), "the bigger-card case really overloads its power supply")
    check(not Generator.repaired(small, 100).is_empty() and Generator.repaired(small, 0).is_empty(), "its repair needs a power supply the shop can afford")

    # ---- generated customers are saved, loaded and sanitized ----
    gs.remember_person(person_a)
    gs.people["p9999"] = {"name": "", "profession": "wizard"}
    gs.people["t001_mara"] = {"name": "Fake", "profession": "regular"}
    gs.customer_state["p0001"] = {"trust": 72, "history": []}
    gs.reviews = [80, 90]
    var seed: int = gs.world_seed
    gs.save_game()
    check(gs.load_game(), "the save loads")
    check(gs.person("p0001")["name"] == person_a["name"] and gs.person("p0001")["needs"] == person_a["needs"], "a generated customer survives save and load")
    check(not gs.people.has("p9999") and gs.person("t001_mara")["name"] == "Mara V.", "broken records and fake story customers are dropped")
    check(int(gs.customer_view("p0001")["trust"]) == 72 and gs.reviews == [80, 90] and gs.world_seed == seed and seed != 0, "their trust, the reviews and the world seed are kept")

    # ---- a morning brings generated tickets ----
    gs.people = {}
    gs.customer_state = {}
    gs.reviews = []
    gs.tickets_taken = 0
    gs.new_game(false)
    gs.world_seed = 4242   # a fixed world: this morning takes the same path on every run
    check(night.start(gs), "night 1 starts with the two story customers")
    for entry: Dictionary in night.jobs(gs): night.ticket_action(gs, str(entry["id"]), Ticket.TOGGLE_CALL)
    var report: Dictionary = night.end_night(gs)
    var new_cards: Array = (report.get("cards", []) as Array).filter(func(c: Dictionary) -> bool: return c["kind"] == "new")
    check(report["ok"] and new_cards.size() == ShopRating.arrivals(float(report["rating"]), int(report["reputation"]), 0) and new_cards.size() >= 1, "as many customers come as the rating and reputation bring (%d)" % new_cards.size())
    check(str(report.get("arrivals", "")).contains("Online rating") and gs.reviews.size() == 2, "both pickups became reviews and the morning explains the arrivals")
    var all_known: bool = true
    for card: Dictionary in new_cards:
        var who: Dictionary = gs.person(str(card["customer_id"]))
        if who.is_empty() or str(card["job"]["complaint"]) == "": all_known = false
    check(all_known and night.ensure(gs), "every new ticket's customer is known and the manifest is valid")
    var generated: Array = new_cards.filter(func(c: Dictionary) -> bool: return str(c["customer_id"]).begins_with("p"))
    if not generated.is_empty():
        var id: String = str(generated[0]["ticket"])
        check(night.switch_pc(gs, id) and str(gs.job["customer"]) == str(gs.person(str(gs.job["customer_id"]))["name"]), "a generated ticket can be worked on like any other")
        var text: String = Ticket.text(gs.job, gs.person(str(gs.job["customer_id"])), {})
        check(text.contains(str(gs.job["customer"])) and text.contains(str(gs.job["complaint"]).left(20)), "its ticket shows the generated customer and their complaint")
        gs.save_game()
        check(gs.load_game() and night.ensure(gs) and str(gs.job["id"]) == id, "the generated ticket survives save and load")
    else:
        check(new_cards.all(func(c: Dictionary) -> bool: return bool(c.get("returning", false))), "if nobody new came, everyone was a returning customer")
    var waiting: int = night.jobs(gs).filter(func(j: Dictionary) -> bool: return j.get("state", "open") != "done").size()
    var second: Dictionary = night.end_night(gs)
    var second_new: int = (second["cards"] as Array).filter(func(c: Dictionary) -> bool: return c["kind"] == "new").size()
    check(second["ok"] and second_new == ShopRating.arrivals(float(second["rating"]), int(second["reputation"]), waiting) and night.jobs(gs).filter(func(j: Dictionary) -> bool: return j.get("state", "open") != "done").size() <= ShopRating.MAX_OPEN,
        "waiting PCs count against the shop's space; it never holds more than %d" % ShopRating.MAX_OPEN)

    # ---- B48: a bought part fitted in the first GPU slot keeps the manifest valid after a reload ----
    gs.money = 500
    var other_id: String = ""
    for entry: Dictionary in night.jobs(gs):
        if str(entry["id"]) != str(gs.job["id"]) and entry.get("state", "open") != "done": other_id = str(entry["id"])
    check(gs.buy_catalog_part("gpu_gtx1660"), "a catalogue GPU is bought")
    var bought: String = ""
    for record: Dictionary in gs.player_inventory:
        if str(record.get("model", "")) == "gpu_gtx1660" and str(record.get("tier", "")) == "model": bought = str(record["uid"])
    check((Ids.GPU in gs.job["removed_parts"] or gs.set_service_part_fitted(Ids.GPU, false)) and gs.fit_inventory_part(Ids.GPU, bought) and str(gs.job["service_replacements"][Ids.GPU]).begins_with("model:"), "it is fitted as a test part in the first slot")
    if other_id != "":
        check(night.switch_pc(gs, other_id), "switch away, so that PC is stored in the night manifest")
        gs.save_game()
        night.bound_path = ""
        check(gs.load_game() and night.ensure(gs) and not night.read_only, "after a reload the manifest is still valid and switching stays open (B48)")

    _remove_save_files(manifest)
    restore_save(gs)
    finish("Generated tickets")


func Customers_pc() -> Dictionary:
    return {"cpu": "cpu_i5_6060", "gpus": ["gpu_gtx1660"], "ram": ["ram_8gb"], "storage": ["sto_ssd_500"], "psu": "psu_cv450", "cooler": "cool_stock_box"}
