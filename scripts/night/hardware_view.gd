# The night hardware bench shows the SELECTED TICKET'S OWN PC (D131): its CPU, RAM, GPU and cooler sit
# on the board exactly as the repair bench left them, and every move here is written back to the job.
# Parts removed at the repair bench lie in the drawer, broken parts say BROKEN, and replacing a broken
# GPU/cooler uses stock from the drawer. The shop's spare stock lives in the same drawer.
extends "res://scripts/view/workshop_view.gd"
const Navigation = preload("res://scripts/night/night_navigation.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const ToolRenderer = preload("res://scripts/view/tool_renderer.gd")
const Ids = preload("res://scripts/data/ids.gd")
const SCREWDRIVER_TRAY := Rect2(430, 596, 270, 48)
var screwdriver_held: bool = false

func _ready() -> void:
    super._ready()
    for node: Node in get_children():
        if node is Label and node.position.y < 32:
            node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            node.add_theme_font_size_override("font_size",18)
            node.size.x = 1040
    Navigation.attach(self,_activities)

func _activities() -> void:
    inventory.cancel()
    _settle_all_throws()
    _save_inventory()
    if NightSession.checkpoint(GameState): get_tree().change_scene_to_file(Navigation.ACTIVITIES)
    else: status_label.text = NightSession.status

func _button(text: String,pos: Vector2,size: Vector2,callback: Callable) -> void:
    if text == "Back to shop":
        super._button("Workshop / room",pos,size,func() -> void: get_tree().change_scene_to_file("res://scenes/night_workshop.tscn"))
    elif text == "Tower + L board" or text == "Compact + stepped board": return   # the ticket decides the case
    elif text == "Reset sandbox": super._button("Rearrange drawer",pos,size,callback)
    else: super._button(text,pos,size,callback)

# ---- the ticket's PC, projected from the job ----

func _components() -> Array:
    var mine: Array = CustomerPC.components(GameState.job)
    var tail: Array = mine.slice(mine.size() - 2)   # GPU and cooler last, so loose ones never push the shop stock around
    return mine.slice(0, mine.size() - 2) + GameState.inventory_components() + tail

func _bench_memory() -> Dictionary:
    var trial: Variant = GameState.job.get("hardware_trial", {})
    var memory: Variant = (trial as Dictionary).get("bench", {}) if trial is Dictionary else {}
    return memory if memory is Dictionary else {}

func _saved_layout() -> Dictionary:
    var layout: Dictionary = {}
    for part_uid: String in GameState.inventory_layout:
        var entry: Variant = GameState.inventory_layout[part_uid]
        if entry is Dictionary and str(entry.get("location", "drawer")) == "drawer": layout[part_uid] = entry   # shop stock never rests on the customer's board
    layout.merge(CustomerPC.placements(GameState.job, _bench_memory()), true)
    return layout

func _title_text() -> String:
    return "NIGHTSHIFT / HARDWARE BENCH - ticket %s: %s's own PC, as it stands on the repair bench\nMove the GPU or cooler out and back in. A broken one can be replaced with stock from the drawer. The GPU's bracket screws need the screwdriver (tray under the case)." % [str(GameState.job.get("id", "")), str(GameState.job.get("customer", ""))]

func _intro_text() -> String:
    return "Ticket %s. Parts: %s" % [str(GameState.job.get("id", "")), PartStates.summary(GameState.job)]

# Every bench move is written back: the job's removed_parts says what is on the board, the drawer cells are
# remembered per ticket, and stock resting on a service slot is a replacement.
func _save_inventory() -> void:
    var snapshot: Dictionary = inventory.snapshot()
    var job: Dictionary = GameState.job
    var stock_layout: Dictionary = {}
    var replacement: String = ""
    for part_uid: String in snapshot:
        if CustomerPC.is_customer(part_uid): continue
        if str((snapshot[part_uid] as Dictionary)["location"]) == "drawer": stock_layout[part_uid] = snapshot[part_uid]
        else: replacement = part_uid
    for part: String in [Ids.GPU, Ids.COOLER]:
        GameState.set_service_part_fitted(part, CustomerPC.fitted_in(job, snapshot, part))
    if not job["hardware_trial"] is Dictionary: job["hardware_trial"] = {}
    job["hardware_trial"]["bench"] = CustomerPC.memory(job, snapshot)
    GameState.set_inventory_layout(stock_layout)
    if replacement != "": _fit_replacement(replacement)

func _stock_record(part_uid: String) -> Dictionary:
    for record: Dictionary in GameState.player_inventory:
        if record["uid"] == part_uid: return record
    return {}

func _fit_replacement(part_uid: String) -> void:
    var record: Dictionary = _stock_record(part_uid)
    if record.is_empty(): return
    var kind: String = str(record["kind"])
    if GameState.fit_inventory_part(kind, part_uid):
        _configure_layout()
        _set_status(("Replacement GPU fitted. Its bracket screws are loose: pick up the screwdriver and tighten both." if kind == Ids.GPU
            else "Replacement cooler fitted. It still needs fresh paste, mounting and screws at the repair bench."))
    else:
        _configure_layout()
        _set_status("That stock part does not fit this ticket.", true)

# Shop stock may only replace the customer's BROKEN GPU/cooler once it is out of the PC.
func _candidate(mouse: Vector2) -> Dictionary:
    var result: Dictionary = super._candidate(mouse)
    if inventory.held < 0 or result.get("kind", "") != "board" or not bool(result.get("ok", false)): return result
    var part_uid: String = str(inventory.items[inventory.held]["part"]["id"])
    if CustomerPC.is_customer(part_uid): return result
    var record: Dictionary = _stock_record(part_uid)
    var kind: String = str(record.get("kind", ""))
    var job: Dictionary = GameState.job
    var why: String = ""
    if not kind in Ids.SERVICE_PARTS:
        why = "This ticket's CPU and RAM stay as they are; stock RAM and CPUs are for later upgrades."
    elif not kind in job["removed_parts"]:
        why = "Take the customer's %s out first." % kind.to_upper()
    elif not kind in job["broken_parts"]:
        why = "The customer's %s works. Refit it instead of swapping it." % kind.to_upper()
    if why != "":
        result["ok"] = false
        result["message"] = why
    return result

func _try_pick_up(mouse: Vector2) -> void:
    if inventory.held >= 0: return
    if screwdriver_held: return
    if SCREWDRIVER_TRAY.has_point(mouse):
        screwdriver_held = true
        AudioFeedback.request(self,"handling.pickup",{"kind":Ids.SCREWDRIVER})
        _set_status("Screwdriver in hand. Click a bracket screw on a fitted GPU. Click the tray or press Esc to put it down.")
        queue_redraw()
        return
    for i in range(inventory.items.size()-1,-1,-1):
        if _item_rect(i).has_point(mouse):
            if CustomerPC.is_fixed(str(inventory.items[i]["part"]["id"])):
                _set_status("The customer's CPU and RAM stay fitted for this ticket.", true)
                return
            break
    super._try_pick_up(mouse)

# ---- the screwdriver (hands are busy while it is held) ----

func _input(event: InputEvent) -> void:
    if screwdriver_held:
        if event is InputEventMouseMotion:
            pointer = event.position
            queue_redraw()
            return
        if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
            _put_down_screwdriver()
            return
        if event is InputEventMouseButton:
            pointer = event.position
            if event.pressed and event.button_index == MOUSE_BUTTON_LEFT: _screwdriver_click(event.position)
            elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT: _put_down_screwdriver()
            return
    super._input(event)

func _put_down_screwdriver() -> void:
    screwdriver_held = false
    _set_status("Screwdriver back in its tray.")
    queue_redraw()

func gpu_slot_rect() -> Rect2:
    for connector: Dictionary in board["connectors"]:
        if connector["id"] == "pcie": return _connector_rect(connector)
    return Rect2()

func gpu_is_fitted() -> bool:
    return not Ids.GPU in GameState.job["removed_parts"]

func _screwdriver_click(at: Vector2) -> void:
    if SCREWDRIVER_TRAY.has_point(at):
        _put_down_screwdriver()
        return
    if not gpu_is_fitted() or InstallFaults.gpu_screw_at(gpu_slot_rect(), CELL, at) < 0: return
    if GameState.turn_gpu_screw():
        AudioFeedback.request(self,"ui.click")
        var turns: int = int(GameState.job["gpu_screws"])
        _set_status("GPU bracket screw tightened (%d of %d)." % [turns, InstallFaults.GPU_SCREW_COUNT] + (" The card is secure." if turns >= InstallFaults.GPU_SCREW_COUNT else ""))
    else:
        _set_status("Both bracket screws are already tight.")
    queue_redraw()

# ---- drawing on top of the generic bench ----

func _draw() -> void:
    super._draw()
    draw_rect(SCREWDRIVER_TRAY, Color("2b3139"))
    draw_rect(SCREWDRIVER_TRAY, Color("66857b"), false, 1)
    _text(SCREWDRIVER_TRAY.position + Vector2(10, 18), "SCREWDRIVER TRAY" if not screwdriver_held else "Click here to put it down", 12)
    if not screwdriver_held:
        draw_set_transform(SCREWDRIVER_TRAY.position + Vector2(190, 36), -1.15)
        ToolRenderer.draw_screwdriver(self)
        draw_set_transform(Vector2.ZERO)
    var job: Dictionary = GameState.job
    for i in range(inventory.items.size()):
        var part_uid: String = str(inventory.items[i]["part"]["id"])
        if CustomerPC.is_customer(part_uid) and CustomerPC.is_broken(job, part_uid) and i != inventory.held:
            var r: Rect2 = _item_rect(i)
            _text(r.position + Vector2(4, 14), "BROKEN", 13, Color("ff8a80"))
    if gpu_is_fitted():
        var radius: float = InstallFaults.gpu_screw_radius(CELL)
        var centers: Array = InstallFaults.gpu_screw_centers(gpu_slot_rect(), CELL)
        for s in range(centers.size()):
            var tight: bool = s < int(job["gpu_screws"])
            draw_circle(centers[s], radius, Color("3b424d"))
            draw_arc(centers[s], radius, 0.0, TAU, 20, Color("dfe6ea") if tight else COLOR_BAD, 2.0)
            if tight: draw_line(centers[s] + Vector2(-radius * 0.5, 0), centers[s] + Vector2(radius * 0.5, 0), Color("dfe6ea"), 2.0)
        if int(job["gpu_screws"]) < InstallFaults.GPU_SCREW_COUNT:
            _text((centers[1] as Vector2) + Vector2(radius + 8, 5), "GPU screws loose", 12, COLOR_BAD)
    if screwdriver_held:
        draw_set_transform(pointer - Vector2(-18, 24) * 1.0)
        ToolRenderer.draw_screwdriver(self)
        draw_set_transform(Vector2.ZERO)
