# 0.47.0 / session 3.4 (D150): the Findings notebook, the Stress lab, timed-test clock limits,
# hidden-health secrecy in everything the notebook keeps, and diagnosis solvability/difficulty.
extends "res://tools/test_support.gd"
const Findings = preload("res://scripts/rules/findings.gd")
const StressLab = preload("res://scripts/rules/stress_lab.gd")
const Diagnosis = preload("res://scripts/rules/diagnosis.gd")
const Diagnostics = preload("res://scripts/night/night_diagnostics.gd")
const WorkReport = preload("res://scripts/rules/work_report.gd")
const Clock = preload("res://scripts/rules/night_clock.gd")
const Overclock = preload("res://scripts/rules/overclock.gd")
const Malware = preload("res://scripts/rules/malware.gd")
const Ids = preload("res://scripts/data/ids.gd")
const HIDDEN_WORDS: Array = ["broken", "BROKEN", "faulty", "FAULTY", "dead", "DEAD", "fault", "film", "screw"]

func _initialize() -> void:
    call_deferred("run_checks")


func _leaks(text: String) -> Array:
    return HIDDEN_WORDS.filter(func(word: String) -> bool: return text.contains(word))


func _notes_text(gs: Node) -> String:
    return "\n".join((gs.job.get("findings", []) as Array).map(func(n: Dictionary) -> String: return str(n["text"])))


func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "diagnosis_test.json")
    var manifest: String = gs.save_path + ".night.json"
    _remove_save_files(manifest)
    gs.tickets_taken = 0
    gs.owned_games = []
    gs.customer_state = {}
    gs.new_game(false)
    check(night.start(gs), "night starts")
    var mara: String = night.active_id
    var relu: String = night.tickets[1]["id"]

    # ---- pure notebook rules ----
    var notes: Array = []
    var seen: Dictionary = Findings.entry(Findings.OBSERVATION, "Dust visible on: CPU cooler", 2, 75, "sigA", "repair_bench")
    check(Findings.add(notes, seen) and not Findings.add(notes, seen.duplicate()), "the same look at the same unchanged PC is noted once")
    check(Findings.add(notes, Findings.entry(Findings.OBSERVATION, "Dust visible on: CPU cooler", 2, 90, "sigB", "repair_bench")), "the same look after the PC changed is a new observation")
    check(Findings.stamp(Findings.entry(Findings.MEASUREMENT, "x", 3, 130, "s", "", 150)) == "Night 3 · 00:10–00:30", "entries carry the night number and the night clock, with an end time for timed tests")
    var measured: Dictionary = Findings.entry(Findings.MEASUREMENT, "Game test: 40 FPS", 1, 30, "old")
    var done: Dictionary = Findings.entry(Findings.WORK, "Taken out: GPU", 1, 40, "old")
    check(not Findings.current(measured, "new") and Findings.line(measured, "new").contains("outdated") and Findings.current(done, "new") and not Findings.line(done, "new").contains("outdated"),
        "a measurement from before a change stays readable but is marked outdated; work history never goes stale")
    var stopped: String = Findings.line(Findings.entry(Findings.MEASUREMENT, "Stress lab stopped", 1, 30, "s", "", -1, true), "s")
    check(stopped.contains("INCOMPLETE"), "a stopped test is labelled incomplete")
    var dirty: Array = [{"kind": "guess", "text": "it is the GPU"}, {"kind": "work", "text": "  "}, "junk", {"kind": "work", "text": "Cleaned: RAM", "night": "x", "minute": -5}]
    var clean: Array = Findings.sanitize(dirty)
    check(clean.size() == 1 and clean[0]["night"] == 1 and clean[0]["minute"] == 0, "saved notes are rebuilt from known kinds only; conclusions and malformed stamps do not survive")
    var many: Array = []
    for i in range(Findings.LIMIT + 7): Findings.add(many, Findings.entry(Findings.WORK, "w%d" % i, 1, i, "s"))
    check(many.size() == Findings.LIMIT and str(many[0]["text"]) == "w7", "the notebook keeps the newest entries")
    check(Findings.change_text(["RAM: A (customer's)", "RAM: A (customer's)"], ["RAM: A (customer's)", "RAM: B (your test part, s1)"]) == "Taken out: RAM: A (customer's)\nFitted: RAM: B (your test part, s1)",
        "identical parts are counted one by one, and a test part keeps its own stock id")

    # ---- the hidden truth never reaches the notebook (Relu: a GPU that does not work, plus adware) ----
    check(night.switch_pc(gs, relu) and "gpu" in gs.job["broken_parts"], "Relu's PC has a hidden GPU fault")
    var looks: String = Findings.repair_bench_observation(gs.job) + "\n" + Findings.hardware_bench_observation(gs.job)
    check(_leaks(looks).is_empty() and looks.contains("GPU: ") and looks.contains("(customer's)"), "bench inspections list models and owners, never health")
    gs.set_pc_powered(true)
    var view: Node = load("res://scenes/software.tscn").instantiate()
    view.run_seconds = 0.0
    root.add_child(view)
    await process_frame
    view._boot()
    check(view.output.text.contains("no image") and str(gs.job["findings"].back()["text"]).begins_with("Boot check: Boot FAILED"), "the boot symptom is noted as measured")
    view._hardware()
    view._scan()
    var relu_notes: String = _notes_text(gs)
    check(_leaks(relu_notes).is_empty(), "nothing in Relu's notebook names the faulty GPU or hidden installation flags: " + ", ".join(_leaks(relu_notes)))
    check(not relu_notes.contains("Anti-virus scan"), "a scan that cannot run (the PC does not start) writes no fake result")
    view._show_tab("findings")
    check(view.side_text.text.contains("FINDINGS") and view.side_text.text.contains(str(gs.job["complaint"])) and view.output.text.contains("FINDINGS"), "the Findings tab shows the complaint and the notebook, also on the big screen")
    var minutes_before: int = gs.night_minutes
    view._show_tab("work")
    view._show_tab("findings")
    check(gs.night_minutes == minutes_before, "reading the notebook costs no night time")
    view.queue_free()
    await process_frame

    # ---- work history from real state changes, with part identity and custody ----
    gs.set_pc_powered(false)
    var count: int = (gs.job["findings"] as Array).size()
    check(gs.set_service_part_fitted(Ids.GPU, false), "the customer's GPU comes out")
    check(str(gs.job["findings"].back()["text"]).contains("Taken out: GPU") and str(gs.job["findings"].back()["text"]).contains("(customer's)"), "taking a part out is work history naming its owner")
    check(gs.fit_inventory_part(Ids.GPU, "trial_gpu"), "an owned test GPU goes in")
    var fitted: String = str(gs.job["findings"].back()["text"])
    check(fitted.contains("Fitted: GPU") and fitted.contains("your test part, trial_gpu"), "fitting a test part notes it as the shop's, with its own stock id")
    check(gs.set_service_part_fitted(Ids.GPU, false) and str(gs.job["findings"].back()["text"]).contains("Taken out: GPU") and str(gs.job["findings"].back()["text"]).contains("trial_gpu"), "removing the test part is noted too")
    check(gs.set_service_part_fitted(Ids.GPU, true) and (gs.job["findings"] as Array).size() == count + 4, "refitting the customer's own card is noted: four moves, four entries")
    check(gs.set_overclock(1, 1) and str(gs.job["findings"].back()["text"]).contains("multiplier +1, voltage 1"), "an overclock change is work history")
    gs.set_overclock(1, 1)
    check((gs.job["findings"] as Array).size() == count + 5, "setting the same overclock again writes nothing")
    gs.set_overclock(0, 0)
    var zones: Dictionary = gs.job["dust"].duplicate()
    for id: String in zones: zones[id] = 1.0
    gs.night_minutes = 95
    gs.set_dust(zones)
    var cleaned: Dictionary = gs.job["findings"].back()
    check(str(cleaned["text"]).begins_with("Cleaned:") and int(cleaned["minute"]) == 95 and int(cleaned["night"]) == gs.night_number, "cleaning is noted with the shared night clock and night number")
    gs.set_dust(zones)
    check(gs.job["findings"].back() == cleaned, "already-clean parts are not noted again")
    check(_leaks(_notes_text(gs)).is_empty(), "work history keeps hidden health out too")

    # ---- notebooks belong to their PC and survive save/load ----
    var relu_count: int = (gs.job["findings"] as Array).size()
    check(night.switch_pc(gs, mara) and (gs.job["findings"] as Array).size() < relu_count and not _notes_text(gs).contains("trial_gpu"), "each PC keeps its own notebook")
    check(night.switch_pc(gs, relu) and (gs.job["findings"] as Array).size() == relu_count, "switching back finds the notebook as it was")
    gs.save_game()
    check(gs.load_game() and (gs.job["findings"] as Array).size() == relu_count, "the notebook survives save and load")

    # ---- the Stress lab: pure, deterministic, observations only ----
    var lab_job: Dictionary = gs.job.duplicate(true)
    lab_job["overclock"] = {"mult": 0, "volt": 0}
    lab_job["infection"] = ""
    var run: Dictionary = StressLab.run(lab_job, 70.0, 60)
    check(run["complete"] and int(run["minutes"]) == Clock.LONG_STRESS_MINUTES and (run["readings"] as Array).size() == 5 and run == StressLab.run(lab_job, 70.0, 60), "a full run: readings every five minutes, same input same result")
    check(int(run["loud_from"]) == 10 and StressLab.message(run, 60).contains("23:00–23:20") and StressLab.message(run, 60).contains("23:10"), "readings and the fans getting loud are stamped on the night clock")
    check(not StressLab.run(lab_job, 60.0, 0)["lines"][1].contains("loud"), "a cool PC keeps its fans quiet")
    lab_job["overclock"] = {"mult": 3, "volt": 1}
    var crash: Dictionary = StressLab.run(lab_job, 60.0, 0)
    check(crash["crashed"] and int(crash["minutes"]) == 3 and "\n".join(crash["lines"]).contains("CRASHED"), "a far too high overclock crashes within minutes and the run ends there")
    lab_job["overclock"] = {"mult": 1, "volt": 0}
    check(int(StressLab.run(lab_job, 60.0, 0)["minutes"]) == 14, "a marginal overclock crashes later in the run (a quick test would pass it)")
    lab_job["overclock"] = {"mult": 1, "volt": 1}
    check(StressLab.run(lab_job, 60.0, 0)["complete"], "a stable overclock completes")
    var miner: Dictionary = lab_job.duplicate(true)
    miner["overclock"] = {"mult": 0, "volt": 0}
    Malware.infect(miner, Malware.MINER)
    check(StressLab.idle_temp(miner, 90.0) > StressLab.idle_temp(lab_job, 90.0), "a CPU kept busy by something already running reads warmer before the load starts")
    check(_leaks("\n".join(run["lines"]) + "\n".join(crash["lines"])).is_empty() and not "\n".join(crash["lines"]).contains("voltage too low"), "the lab reports behaviour, never a cause")

    # ---- the Stress lab app on the monitor: time, money, night end, stopping ----
    check(night.switch_pc(gs, mara), "back to Mara's PC")
    gs.set_pc_powered(true)
    gs.money = 50
    gs.night_minutes = 60
    var monitor: Node = load("res://scenes/software.tscn").instantiate()
    monitor.run_seconds = 0.0
    root.add_child(monitor)
    await process_frame
    check(monitor.long_button.text.contains("Stress lab") and monitor.long_button.position.y < monitor.mult_up.position.y, "the long test is its own app, not an overclocker button")
    monitor._stress(true)
    var lab_note: Dictionary = gs.job["findings"].back()
    check(gs.night_minutes == 60 + Clock.LONG_STRESS_MINUTES and gs.money == 50 - Overclock.LONG_TEST_COST and monitor.output.text.contains("STRESS LAB"), "a full run spends its night minutes and its electricity")
    check(lab_note["kind"] == "measurement" and int(lab_note["minute"]) == 60 and int(lab_note["until"]) == 80 and str(lab_note["text"]).contains("Readings"), "the run is noted with its start and end on the night clock")
    check(gs.job["tests"].has("temp"), "a settled run records the load temperature for the request match")
    gs.set_overclock(3, 1)
    var crash_from: int = gs.night_minutes
    monitor._stress(true)
    check(gs.night_minutes == crash_from + 3 and str(gs.job["findings"].back()["text"]).contains("CRASHED"), "a crash ends the run early: only the minutes actually run are spent")
    gs.set_overclock(0, 0)
    gs.night_minutes = Clock.SHIFT_MINUTES - 10
    var cash: int = gs.money
    count = (gs.job["findings"] as Array).size()
    monitor._stress(true)
    check(gs.money == cash and gs.night_minutes == Clock.SHIFT_MINUTES - 10 and monitor.output.text.contains("past 06:00") and (gs.job["findings"] as Array).size() == count, "a run that would pass 06:00 is refused: nothing charged, nothing noted")
    gs.owned_games = ["counter_stroke_2"]
    monitor._game()
    check(gs.night_minutes == Clock.SHIFT_MINUTES - 10 and monitor.output.text.contains("past 06:00"), "a game test that would pass 06:00 is refused as well")
    gs.night_minutes = 100
    monitor.run_seconds = 3.0
    monitor._stress(true)
    check(monitor.busy_left > 0.0, "the run is going")
    monitor._power()
    var cut: Dictionary = gs.job["findings"].back()
    check(bool(cut["incomplete"]) and str(cut["text"]).contains("No result") and gs.night_minutes == 100, "switching the PC off stops the run: noted as incomplete, no result, no time")
    monitor.queue_free()
    await process_frame

    # ---- solvability and difficulty (hidden truth, tests and the future generator only) ----
    gs.new_game(false)
    check(night.start(gs), "a fresh night for the story cases")
    var caps: Dictionary = gs.diagnosis_capabilities()
    var story: Dictionary = {}
    for ticket: Dictionary in night.tickets: story[str(ticket["customer_id"])] = ticket.duplicate(true)
    var mara_job: Dictionary = story["t001_mara"]
    var relu_job: Dictionary = story["t002_relu"]
    var mara_temp: float = Diagnostics.evaluate(mara_job, [])["temp"]
    var relu_temp: float = Diagnostics.evaluate(relu_job, [])["temp"]
    check(Diagnosis.solvable(mara_job, mara_temp, caps) and Diagnosis.difficulty(mara_job, mara_temp, caps) == Diagnosis.EVIDENT, "Mara's overheating PC is solvable and evident (dust and cooler contact are seen)")
    check(Diagnosis.solvable(relu_job, relu_temp, caps) and Diagnosis.difficulty(relu_job, relu_temp, caps) == Diagnosis.COMPARED, "Relu's PC is solvable with the starter stock but needs a known-good swap")
    var adware: Array = Diagnosis.assess(relu_job, relu_temp, caps).filter(func(c: Dictionary) -> bool: return str(c["id"]).begins_with("malware"))
    check(adware.size() == 1 and int(adware[0]["level"]) == Diagnosis.TESTED, "the adware is one scan away once the start-blocking GPU fault is dealt with")
    var no_gpu: Dictionary = caps.duplicate(true)
    no_gpu["stock"].erase(Ids.GPU)
    var blocked: Array = Diagnosis.assess(relu_job, relu_temp, no_gpu)
    check(not Diagnosis.solvable(relu_job, relu_temp, no_gpu) and blocked.filter(func(c: Dictionary) -> bool: return int(c["level"]) == Diagnosis.UNSOLVABLE).size() == 2,
        "without an owned GPU the swap is impossible, and the masked adware cannot be reached either")
    var marginal: Dictionary = mara_job.duplicate(true)
    marginal["overclock"] = {"mult": 1, "volt": 0}
    var broke: Dictionary = caps.duplicate(true)
    broke["money"] = 0
    check(Diagnosis.solvable(marginal, 60.0, caps) and not Diagnosis.solvable(marginal, 60.0, broke), "a marginal overclock needs the Stress lab, so the shop must afford its electricity")
    check(Diagnosis.conditions(gs.job, mara_temp).all(func(c: Dictionary) -> bool: return not str(c["id"]).begins_with("film")), "hidden installation flags stay out of diagnosis: they are pickup discoveries")

    _remove_save_files(manifest)
    restore_save(gs)
    finish("Diagnosis")
