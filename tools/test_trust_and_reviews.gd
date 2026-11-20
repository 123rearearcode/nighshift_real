# 0.52.0 / session 3.8 (D160): reviews, trustworthiness, the shop level and customers finding out. Every
# pickup leaves a star review with a comment (some customers are petty); good work earns trustworthiness;
# it only falls when a customer finds something out (an honest mistake or a scam) or the review site
# catches bought reviews. The phone shows it all and sells fake reviews.
extends "res://tools/test_support.gd"
const Reviews = preload("res://scripts/rules/reviews.gd")
const ShopRating = preload("res://scripts/rules/shop_rating.gd")
const Morning = preload("res://scripts/rules/morning.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")

func _initialize() -> void:
    call_deferred("run_checks")


func press(button: Button) -> void:
    for down: bool in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = down
        event.position = button.get_global_rect().get_center()
        event.global_position = event.position
        root.push_input(event, true)
        await process_frame
    await process_frame


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "trust_reviews_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.customer_state = {}
    gs.reviews = []
    gs.trust_points = 0
    gs.fake_orders = []
    gs.new_game(false)
    check(night.start(gs), "a night starts")

    # ---- stars, comments and pettiness (pure) ----
    check(Reviews.stars_for(95) == 5 and Reviews.stars_for(75) == 4 and Reviews.stars_for(55) == 3 and Reviews.stars_for(35) == 2 and Reviews.stars_for(5) == 1, "a pickup score becomes 1 to 5 stars")
    var a: Dictionary = Reviews.pickup_review(7, "T010", "Ana B.", 3, 92, [], true, false)
    check(a == Reviews.pickup_review(7, "T010", "Ana B.", 3, 92, [], true, false) and str(a["text"]) != "" and str(a["kind"]) == Reviews.PICKUP, "the same save writes the same review, always with a comment")
    check(int(Reviews.pickup_review(7, "T011", "Ana B.", 3, 95, [], false, false)["stars"]) == 1, "a PC that does not start gets one star")
    var petty: int = 0
    var never_higher: bool = true
    for i in range(60):
        var r: Dictionary = Reviews.pickup_review(11, "T%03d" % i, "X", 1, 95, [], true, false)
        if int(r["stars"]) < 5: petty += 1
        if int(r["stars"]) > 5: never_higher = false
    check(petty > 5 and petty < 40 and never_higher, "some customers knock a star off a perfect job for petty reasons (%d of 60)" % petty)
    var missed: Dictionary = Reviews.pickup_review(7, "T012", "Ana B.", 3, 60, ["still loud under load"], true, false)
    check(str(missed["text"]).contains("Still loud under load"), "a disappointed review says what they noticed")

    # ---- the rating ----
    check(is_equal_approx(Reviews.rating([]), 3.0) and is_equal_approx(ShopRating.rating([100, 100]), 5.0) and is_equal_approx(ShopRating.rating([0]), 1.0), "old plain scores still rate as before")
    var mixed: Array = [Reviews.record(5, "a", Reviews.PICKUP, 1, "", "x"), Reviews.record(1, "b", Reviews.NOTICE, 1, "", Reviews.SITE), Reviews.record(3, "c", Reviews.FAKE, 1, "", "y")]
    check(is_equal_approx(Reviews.rating(mixed), 4.0) and Reviews.counted(mixed) == 2, "the rating averages review stars; the site's notice is not a review")
    var migrated: Array = Reviews.sanitize([80, "junk", {"stars": "x"}, {"stars": 2, "text": "meh", "kind": "pickup", "night": 4}])
    check(migrated.size() == 2 and int(migrated[0]["stars"]) == 4 and int(migrated[1]["stars"]) == 2 and int(migrated[1]["night"]) == 4, "old scores become reviews; broken entries are dropped")

    # ---- trustworthiness and the shop level ----
    check(Reviews.level(0) == 1 and Reviews.level(15) == 2 and Reviews.level(39) == 2 and Reviews.level(220) == 6 and Reviews.to_next(10) == 5 and Reviews.to_next(500) == -1, "trust points set the shop level")
    check(Reviews.pickup_points(95, true) > Reviews.pickup_points(75, true) and Reviews.pickup_points(40, true) == 0 and Reviews.pickup_points(95, false) == 0, "good work earns trust; a poor or dead pickup earns none (and costs none)")

    # ---- finding out ----
    var nosy: Dictionary = {"habits": "Opens the case and watches temperatures."}
    var trusting: Dictionary = {"habits": "Never opens the case."}
    check(Reviews.find_chance("toothpaste", nosy) > Reviews.find_chance("toothpaste", {}) and Reviews.find_chance("toothpaste", trusting) < Reviews.find_chance("toothpaste", {}), "a customer who opens the case finds out more often than one who never does")
    check(Reviews.discoveries(5, "T020", nosy, ["toothpaste", "used_parts"]) == Reviews.discoveries(5, "T020", nosy, ["toothpaste", "used_parts"]) and Reviews.discoveries(5, "T020", nosy, ["nonsense"]).is_empty(), "who finds out is fixed per save and ticket")
    check(Reviews.found_points(["found:toothpaste"]) > Reviews.found_points([InstallFaults.GPU_LOOSE]) and Reviews.found_points([InstallFaults.GPU_LOOSE]) > 0, "scams and honest mistakes found out both cost trust; scams more")
    check(int(Reviews.found_review(["found:toothpaste"], [], 3, "T", "A")["stars"]) == 1 and int(Reviews.found_review([InstallFaults.GPU_LOOSE], ["the card rattles"], 3, "T", "A")["stars"]) == 2, "a found-out scam is one star, a found-out mistake two")
    check(Morning.sanitize_pending([{"faults": ["found:toothpaste"], "nights_left": 3}, {"faults": ["found:teleport"], "nights_left": 3}]).size() == 1, "saved discoveries survive; unknown ones are dropped")
    check(Morning.complaints(["found:toothpaste"])[0] == Reviews.complaint("found:toothpaste"), "the morning names what they found")

    # ---- a collection with toothpaste under the cooler, found out later ----
    var ticket: String = str(gs.job["id"])
    var who: Dictionary = gs.customer_view(str(gs.job["customer_id"]))
    var seed: int = 0
    for s in range(1, 400):
        if not Reviews.discoveries(s, ticket, who, ["toothpaste"]).is_empty():
            seed = s
            break
    check(seed != 0, "some save finds the toothpaste")
    gs.world_seed = seed
    gs.job["scams"] = ["toothpaste"]
    var points_before: int = gs.trust_points
    var card: Dictionary = gs.collect_active()
    check(not (card["review"] as Dictionary).is_empty() and str(gs.reviews[gs.reviews.size() - 1]["author"]) == str(card["customer"]), "the customer reviews the shop when they collect")
    check(gs.trust_points == points_before + int(card["points"]), "the pickup's trust points are added")
    var found: Array = gs.comebacks.filter(func(e: Dictionary) -> bool: return (e["faults"] as Array).has("found:toothpaste"))
    check(found.size() == 1 and int(found[0]["nights_left"]) >= 2 and int(found[0]["nights_left"]) <= 4, "the toothpaste is found out a few mornings later")
    gs.trust_points = 30
    for e: Dictionary in gs.comebacks: e["nights_left"] = 1
    var due: Array = gs.advance_comebacks()
    var scam_card: Array = due.filter(func(c: Dictionary) -> bool: return (c["misses"] as Array).has(Reviews.complaint("found:toothpaste")))
    check(scam_card.size() == 1 and int(scam_card[0]["review"]["stars"]) == 1 and str(scam_card[0]["review"]["text"]).contains("TOOTHPASTE") and str(scam_card[0]["reaction"]).begins_with("Found out"), "they come back, found out, and post a one-star review")
    check(gs.trust_points <= 30 - Reviews.found_points(["found:toothpaste"]) and str(gs.reviews[gs.reviews.size() - 1]["kind"]) == Reviews.FOUND, "being found out costs trustworthiness")

    # ---- an honest mistake found out ----
    gs.trust_points = 30
    gs.comebacks = [{"customer_id": str(who["id"]), "customer": str(who["name"]), "ticket": ticket, "faults": [InstallFaults.GPU_LOOSE], "nights_left": 1}]
    var honest: Array = gs.advance_comebacks()
    check(honest.size() == 1 and int(honest[0]["review"]["stars"]) == 2 and gs.trust_points == 30 - Reviews.HONEST_MISTAKE_POINTS, "an honest mistake found out also costs trust, less than a scam")

    # ---- fake reviews ----
    gs.money = 10
    check(not gs.buy_fake_reviews(), "no cash, no fake reviews")
    gs.money = 200
    var count: int = gs.reviews.size()
    var rating_before: float = gs.shop_rating()
    check(gs.buy_fake_reviews() and gs.money == 200 - Reviews.FAKE_PRICE and gs.reviews.size() == count + Reviews.FAKE_PACK and gs.fake_orders == [gs.night_number], "ReviewBoost posts three five-star reviews for cash")
    check(gs.shop_rating() >= rating_before and (gs.reviews.slice(gs.reviews.size() - 3) as Array).all(func(r: Dictionary) -> bool: return int(r["stars"]) == 5), "bought reviews lift the rating")
    check(Reviews.catch_chance([], gs.night_number, gs.reviews) == 0.0 and Reviews.catch_chance([gs.night_number, gs.night_number], gs.night_number, gs.reviews) > Reviews.catch_chance([gs.night_number], gs.night_number, gs.reviews), "nothing bought, nothing to catch; more orders, more risk")
    gs.save_game()
    check(gs.load_game() and gs.fake_orders == [gs.night_number] and gs.trust_points == 30 - Reviews.HONEST_MISTAKE_POINTS and gs.reviews.size() == count + Reviews.FAKE_PACK and gs.reviews[0] is Dictionary, "reviews, trust points and orders survive save and load")
    var chance: float = Reviews.catch_chance(gs.fake_orders, gs.night_number, gs.reviews)
    var caught_seed: int = 0
    var safe_seed: int = 0
    for s in range(1, 400):
        if caught_seed == 0 and Reviews.caught(s, gs.night_number, chance): caught_seed = s
        if safe_seed == 0 and not Reviews.caught(s, gs.night_number, chance): safe_seed = s
    gs.world_seed = safe_seed
    check(gs.check_fake_reviews(gs.night_number).is_empty() and gs.reviews.size() == count + Reviews.FAKE_PACK, "most mornings nobody notices")
    gs.world_seed = caught_seed
    var points: int = gs.trust_points
    var notice: Dictionary = gs.check_fake_reviews(gs.night_number)
    check(str(notice.get("kind", "")) == "notice" and not gs.reviews.any(func(r: Dictionary) -> bool: return str(r["kind"]) == Reviews.FAKE), "caught: the site removes every bought review")
    check(str(gs.reviews[gs.reviews.size() - 1]["kind"]) == Reviews.NOTICE and gs.trust_points == maxi(0, points - Reviews.CAUGHT_FAKES_POINTS) and gs.fake_orders.is_empty(), "the site flags the shop and trust drops")

    # ---- the phone ----
    gs.money = 200
    var acts: Node = load("res://scenes/activities.tscn").instantiate()
    root.add_child(acts)
    await process_frame
    check(not acts.phone.visible, "the phone starts in your pocket")
    await press(acts.phone_button)
    check(acts.phone.visible and str(acts.phone.header.text).contains("★") and str(acts.phone.standing.text).contains("shop level"), "the phone shows the rating, trustworthiness and the shop level")
    await process_frame
    check(acts.phone.list.get_child_count() == gs.reviews.size(), "every review is listed")
    var before: int = gs.reviews.size()
    await press(acts.phone.buy_button)
    await process_frame
    await process_frame
    check(gs.reviews.size() == before + Reviews.FAKE_PACK and gs.money == 200 - Reviews.FAKE_PRICE and acts.phone.list.get_child_count() == gs.reviews.size(), "buying from the phone posts the reviews and the list follows")
    await press(acts.phone.close_button)
    check(not acts.phone.visible, "the phone goes back in your pocket")
    acts.queue_free()
    await process_frame

    # ---- the morning report carries the standing ----
    gs.night_minutes = 0
    night.bound_path = ""
    var report: Dictionary = night.end_night(gs)
    check(bool(report.get("ok", false)) and str(report.get("standing", "")).contains("shop level") and report.has("level_before"), "the morning says the shop's trustworthiness and level")

    _remove_save_files(manifest)
    restore_save(gs)
    finish("Trust and reviews")
