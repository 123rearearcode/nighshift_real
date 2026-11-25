# The night hardware bench shows the SELECTED TICKET'S OWN PC (D131): its CPU, RAM, GPU and cooler sit
# on the board exactly as the repair bench left them, and every move here is written back to the job.
# Parts removed at the repair bench lie in the drawer (only visibly damaged ones say DAMAGED, D150), and replacing a
# GPU/cooler uses stock from the drawer. The shop's spare stock lives in the same drawer.
extends "res://scripts/view/workshop_view.gd"
const Navigation = preload("res://scripts/night/night_navigation.gd")
const CustomerPC = preload("res://scripts/rules/customer_pc.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const PcBuild = preload("res://scripts/rules/pc_build.gd")
const ToolRenderer = preload("res://scripts/view/tool_renderer.gd")
const Ids = preload("res://scripts/data/ids.gd")
const Catalog = preload("res://scripts/data/hardware_catalog.gd")
const Findings = preload("res://scripts/rules/findings.gd")
const SCREWDRIVER_TRAY := Rect2(430, 596, 270, 48)
const ORDER_RECT := Rect2(60, 150, 650, 440)
var screwdriver_held: bool = false
var order_panel: Panel
var order_buttons: Dictionary = {}   # catalogue id -> Buy button (D149)
var board_button: Button              # 0.48.1: take the motherboard out / fit it back
const BOARD_BUTTON := Rect2(60, 112, 320, 34)
const BuildRequest = preload("res://scripts/rules/build_request.gd")
const NightClock = preload("res://scripts/rules/night_clock.gd")
const CASE_BUTTON := Rect2(390, 112, 250, 34)
var case_button: Button               # 0.51.0: a build's case and motherboard (D159)
var case_panel: Panel
var case_rows: VBoxContainer

func _ready() -> void:
    super._ready()
    for node: Node in get_children():
        if node is Label and node.position.y < 32: node.hide()
    Navigation.workbench(self,"hardware",_activities)
    _build_order_panel()
    _build_board_button()
    _build_case_panel()
    # D150 (0.47.0): looking over the PC at the hardware bench is an inspection; Findings keeps it.
    GameState.record_finding(Findings.OBSERVATION, Findings.hardware_bench_observation(GameState.job), "hardware_bench")

func _activities() -> void:
    _navigate(Navigation.ACTIVITIES)
func _navigate(path: String) -> bool:
    if screwdriver_held: _put_down_screwdriver()
    inventory.cancel()
    _settle_all_throws()
    _save_inventory()
    if not NightSession.checkpoint(GameState):
        status_label.text = NightSession.status
        return false
    return Navigation.commit(self,path)

func _button(text: String,pos: Vector2,size: Vector2,callback: Callable) -> void:
    if text == "Back to shop":
        super._button("Order parts",pos,size,_toggle_order)   # D149: the header owns navigation; this slot buys parts
        return
    elif text == "Tower + L board" or text == "Compact + stepped board": return   # the ticket decides the case
    elif text == "Reset sandbox": super._button("Rearrange drawer",pos,size,callback)
    else: super._button(text,pos,size,callback)

# ---- the ticket's PC, projected from the job ----

func _components() -> Array:
    var mine: Array = CustomerPC.components(GameState.job)
    var first: int = CustomerPC.first_parts(GameState.job).size()   # 0.51.0: a build may have neither yet
    var tail: Array = mine.slice(mine.size() - first)   # GPU and cooler last, so loose ones never push the shop stock around
    # 0.46.2 (D150): shop parts fitted in this PC for a test come right after the customer's fitted parts.
    return mine.slice(0, mine.size() - first) + GameState.fitted_components() + GameState.inventory_components() + tail

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
    for slot: String in GameState.job.get("shop_fitted", {}):   # shop test parts sit on their slots
        layout[str(GameState.job["shop_fitted"][slot]["uid"])] = {"location": slot, "cell": [0, 0], "rotation": 0}
    return layout

func _title_text() -> String:
    if PcBuild.is_build(GameState.job):
        return "NIGHTSHIFT / HARDWARE BENCH - ticket %s: a new build for %s\nFit parts from your stock into the empty case (Order parts to buy). Every part you fit costs night time; taking one out is quick. Case and board: swap them while the case is empty. The GPU's bracket screws need the screwdriver." % [str(GameState.job.get("id", "")), str(GameState.job.get("customer", ""))]
    return "NIGHTSHIFT / HARDWARE BENCH - ticket %s: %s's own PC, as it stands on the repair bench\nEvery part can come out: drag it to the drawer and back. Fit parts from your stock into empty slots (Order parts to buy). The GPU's bracket screws need the screwdriver (tray under the case). The motherboard comes out only once every other part is out." % [str(GameState.job.get("id", "")), str(GameState.job.get("customer", ""))]

func _intro_text() -> String:
    if PcBuild.is_build(GameState.job):
        return "Build %s · %s · night clock %s. %s" % [str(GameState.job.get("id", "")), BuildRequest.needs_text(BuildRequest.record(GameState.job)), NightClock.label(GameState.night_minutes), PcBuild.summary_line(GameState.job)]
    return "Ticket %s. %s" % [str(GameState.job.get("id", "")), PcBuild.summary_line(GameState.job)]

# Every bench move is written back: the first GPU and cooler through their service state, every other
# customer part (fitted or loose) through GameState.apply_bench, the drawer cells per ticket, and stock
# resting on a slot is fitted (a replacement on the first GPU slot / cooler mount, or a new part elsewhere).
func _save_inventory() -> void:
    var snapshot: Dictionary = inventory.snapshot()
    var job: Dictionary = GameState.job
    var stock_layout: Dictionary = {}
    var placed: Array = []   # [uid, slot] of stock now sitting on the customer's board
    for part_uid: String in snapshot:
        if CustomerPC.is_customer(part_uid): continue
        var location: String = str((snapshot[part_uid] as Dictionary)["location"])
        if location == "drawer": stock_layout[part_uid] = snapshot[part_uid]
        else: placed.append([part_uid, location])
    var reproject: bool = false
    var custody_before: Array = (job.get("shop_custody", []) as Array).duplicate()
    for part: String in [Ids.GPU, Ids.COOLER]:
        GameState.set_service_part_fitted(part, CustomerPC.fitted_in(job, snapshot, part))
    reproject = custody_before != (job.get("shop_custody", []) as Array)   # a shop replacement went back to stock
    # 0.46.2 (D150): a shop test part taken off its slot goes back to the drawer as stock.
    var shop_now: Dictionary = {}
    for entry: Array in placed: shop_now[str(entry[0])] = str(entry[1])
    for slot: String in (job.get("shop_fitted", {}) as Dictionary).keys():
        var test_uid: String = str(job["shop_fitted"][slot]["uid"])
        if str(shop_now.get(test_uid, "")) != slot:
            GameState.unfit_catalog_stock(test_uid)
            if snapshot.has(test_uid) and str(snapshot[test_uid]["location"]) == "drawer": stock_layout[test_uid] = snapshot[test_uid]
            reproject = true
        else:
            placed = placed.filter(func(e: Array) -> bool: return str(e[0]) != test_uid)   # still where it was
    if not job["hardware_trial"] is Dictionary: job["hardware_trial"] = {}
    reproject = GameState.apply_bench(snapshot) or reproject
    # Drawer cells: the removed first GPU / cooler keep theirs; loose parts keep theirs by model, in order.
    var memory: Dictionary = {}
    for part: String in [Ids.GPU, Ids.COOLER]:
        var key: String = CustomerPC.uid(job, part)
        if snapshot.has(key) and str(snapshot[key]["location"]) == "drawer": memory[key] = snapshot[key]
    var cells: Dictionary = {}
    for key: String in snapshot:
        if CustomerPC.is_customer(key) and CustomerPC.part_of(key) != Ids.GPU and CustomerPC.part_of(key) != Ids.COOLER and str(snapshot[key]["location"]) == "drawer":
            var id: String = _seen_ids.get(key, "")
            if id != "": (cells.get_or_add(id, []) as Array).append(snapshot[key])
    var loose_list: Array = CustomerPC.loose(job)
    for i in range(loose_list.size()):
        var spots: Array = cells.get(str(loose_list[i]["id"]), [])
        if not spots.is_empty(): memory[CustomerPC.uid(job, "loose_" + str(i))] = spots.pop_front()
    job["hardware_trial"]["bench"] = memory
    GameState.set_inventory_layout(stock_layout)
    for entry: Array in placed: reproject = _fit_stock(str(entry[0]), str(entry[1])) or reproject
    if reproject: _configure_layout()
    _remember_ids()
    _refresh_board_button()

# Which catalogue part each customer uid stood for when the layout was built (uids are re-numbered
# when loose parts change, so drawer cells are carried over by model).
var _seen_ids: Dictionary = {}
func _remember_ids() -> void:
    _seen_ids.clear()
    for item: Dictionary in inventory.items:
        var key: String = str(item["part"]["id"])
        if CustomerPC.is_customer(key): _seen_ids[key] = CustomerPC.catalog_id(GameState.job, key)

func _configure_layout() -> void:
    super._configure_layout()
    # 0.48.1: the board drawn is the customer's own motherboard model.
    board["display_name"] = "%s · %s" % [str(Catalog.board(PcBuild.board_model(GameState.job))["name"]), "the build's motherboard" if PcBuild.is_build(GameState.job) else "customer's motherboard"]
    _remember_ids()
    _refresh_board_button()
    _refresh_case_panel()

# ---- the motherboard (0.48.1; user: every part must be out before it can come out) ----

func _build_board_button() -> void:
    board_button = Button.new()
    board_button.name = "BoardButton"
    board_button.position = BOARD_BUTTON.position
    board_button.size = BOARD_BUTTON.size
    board_button.pressed.connect(_board_pressed)
    add_child(board_button)
    _refresh_board_button()

func _refresh_board_button() -> void:
    if not is_instance_valid(board_button): return
    if PcBuild.board_out(GameState.job):
        board_button.text = "Fit the motherboard back"
        board_button.tooltip_text = ("Fit the build's motherboard in the case (%d night minutes). Parts can only go in once it is in." % BuildRequest.minutes("board")) if PcBuild.is_build(GameState.job) else "Put the customer's motherboard back in the case. Parts can only go in once it is back."
    else:
        var blocker: String = GameState.board_blocker()
        board_button.text = "Take out the motherboard"
        board_button.tooltip_text = blocker if blocker != "" else "Every part is out: the motherboard can come out of the case."

func _board_pressed() -> void:
    if inventory.held >= 0 or screwdriver_held: return
    _save_inventory()
    var name_text: String = str(Catalog.board(PcBuild.board_model(GameState.job))["name"])
    if PcBuild.board_out(GameState.job):
        if GameState.fit_board_back():
            NightSession.checkpoint(GameState)
            _configure_layout()
            _set_status("%s is back in the case. Parts can go in again." % name_text)
        elif GameState.assembly_blocker("board") != "": _set_status(GameState.assembly_blocker("board"), true)
        return
    var blocker: String = GameState.board_blocker()
    if blocker != "":
        _set_status(blocker, true)
        return
    if GameState.take_out_board():
        NightSession.checkpoint(GameState)
        _configure_layout()
        _set_status("Motherboard out: the customer's %s lies beside the case. Fit it back before any part can go in." % name_text)

func _draw_board() -> void:
    if not PcBuild.board_out(GameState.job):
        super._draw_board()
        return
    var area: Rect2 = PCLayout.board_rect(pc, geometry)
    draw_rect(area, Color(0.1, 0.12, 0.13, 0.6))
    var corners: Array = [area.position, Vector2(area.end.x, area.position.y), area.end, Vector2(area.position.x, area.end.y), area.position]
    for i in range(4):
        var a: Vector2 = corners[i]
        var b: Vector2 = corners[i + 1]
        var steps: int = int(a.distance_to(b) / 12.0)
        for k in range(0, steps, 2):
            draw_line(a.lerp(b, float(k) / steps), a.lerp(b, float(k + 1) / steps), Color("8a949a"), 2.0)
    _text(area.position + Vector2(10, 26), "MOTHERBOARD OUT OF THE CASE", 16, Color("ffcf7a"))
    _text(area.position + Vector2(10, 48), "%s lies beside the case." % str(Catalog.board(PcBuild.board_model(GameState.job))["name"]), 14)
    _text(area.position + Vector2(10, 68), "Fit it back (button above) before any part can go in.", 14)

func _stock_record(part_uid: String) -> Dictionary:
    return GameState._record(part_uid)

# Stock on a slot: a replacement on the first GPU slot / cooler mount, or a new part in any other slot.
func _fit_stock(part_uid: String, slot: String) -> bool:
    var record: Dictionary = _stock_record(part_uid)
    if record.is_empty(): return false
    if slot in [CustomerPC.SLOT_OF[Ids.GPU], CustomerPC.SLOT_OF[Ids.COOLER]]:
        _fit_replacement(part_uid)
        return true
    var kind: String = str(Catalog.part(PcBuild.stock_model(record)).get("type", ""))
    if GameState.assembly_blocker(kind) != "":   # 0.51.0: assembly costs night time
        _set_status(GameState.assembly_blocker(kind), true)
        return true
    if GameState.fit_catalog_stock(part_uid, slot):
        if PcBuild.is_build(GameState.job):
            _set_status("%s fitted (%d night minutes). It is yours until %s collects the build." % [Catalog.part(PcBuild.stock_model(record)).get("name", "Part"), BuildRequest.minutes(kind), str(GameState.job.get("customer", "the customer"))])
            return true
        _set_status("%s fitted for a test. It stays yours: take it out again and it goes back to the drawer. If it is still in when %s collects, it goes home with the PC." % [Catalog.part(str(record.get("model", ""))).get("name", "Part"), str(GameState.job.get("customer", "the customer"))])
        return true
    _set_status("That part does not fit this slot.", true)
    return true

func _fit_replacement(part_uid: String) -> void:
    var record: Dictionary = _stock_record(part_uid)
    if record.is_empty(): return
    var kind: String = str(record["kind"])
    var build: bool = PcBuild.is_build(GameState.job)
    if build and GameState.fit_inventory_part(kind, part_uid):   # 0.51.0
        _configure_layout()
        _set_status(("Graphics card fitted (%d night minutes). Tighten both bracket screws with the screwdriver." if kind == Ids.GPU
            else "Cooler fitted with its pre-applied paste (%d night minutes).") % BuildRequest.minutes(kind))
        return
    if build:
        _configure_layout()
        if GameState.assembly_blocker(kind) != "": _set_status(GameState.assembly_blocker(kind), true)
        elif kind == Ids.COOLER: _set_status("The cooler sits on the CPU: fit the processor first.", true)
        else: _set_status("That stock part does not fit this build.", true)
        return
    if GameState.fit_inventory_part(kind, part_uid):
        _configure_layout()
        _set_status(("Graphics card fitted. Its bracket screws are loose: pick up the screwdriver and tighten both." if kind == Ids.GPU
            else "Cooler fitted. It still needs fresh paste, mounting and screws at the repair bench.") + " It stays yours until the customer collects; theirs is in the drawer.")
    else:
        _configure_layout()
        _set_status("That stock part does not fit this ticket.", true)

# What may go where. 0.46.2 (D150): only physical fit decides; a part's health never does (no oracle).
# Anything owned and suitable may go into an empty matching slot. The PC's first card belongs in slot 1.
func _candidate(mouse: Vector2) -> Dictionary:
    var result: Dictionary = super._candidate(mouse)
    if result.get("kind", "") == "board" and PcBuild.board_out(GameState.job):
        result["ok"] = false
        result["message"] = "The motherboard is out of the case: fit it back first."
        return result
    if inventory.held < 0 or result.get("kind", "") != "board" or not bool(result.get("ok", false)): return result
    var part_uid: String = str(inventory.items[inventory.held]["part"]["id"])
    var slot: String = str(result.get("connector_id", ""))
    var job: Dictionary = GameState.job
    var why: String = ""
    if CustomerPC.is_customer(part_uid):
        if CustomerPC.part_of(part_uid) == Ids.GPU and slot == CustomerPC.GPU2_SLOT:
            why = "This is the PC's first card: it goes in PCIe slot 1. Slot 2 is for a second card."
    else:
        var record: Dictionary = _stock_record(part_uid)
        var kind: String = str(record.get("kind", ""))
        if slot in [CustomerPC.SLOT_OF[Ids.GPU], CustomerPC.SLOT_OF[Ids.COOLER]]:
            if not kind in Ids.SERVICE_PARTS: why = "That part does not go here."
            elif not kind in job["removed_parts"]: why = "Take the customer's %s out first." % kind.to_upper()
        elif PcBuild.stock_model(record) == "":
            why = "That stock record has no matching hardware model."
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
            var key: String = str(inventory.items[i]["part"]["id"])
            # Like a real PC: the cooler sits on the CPU, so it comes off first.
            var is_cpu: bool = CustomerPC.part_of(key) == "cpu" if CustomerPC.is_customer(key) else str(_stock_record(key).get("kind", "")) == "cpu"
            if is_cpu and str(inventory.items[i]["location"]) == CustomerPC.CPU_SLOT and not Ids.COOLER in GameState.job["removed_parts"]:
                _set_status("The cooler sits on the CPU: take the cooler off first.", true)
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
        if not ToolRenderer.draw_tool_sprite(self, "screwdriver", SCREWDRIVER_TRAY.position + Vector2(190, 36), -1.15): ToolRenderer.draw_screwdriver(self)
        draw_set_transform(Vector2.ZERO)
    var job: Dictionary = GameState.job
    for i in range(inventory.items.size()):
        var part_uid: String = str(inventory.items[i]["part"]["id"])
        # D150 (0.46.2): only damage the player caused and can see is labelled; hidden health never is.
        if CustomerPC.is_customer(part_uid) and CustomerPC.is_damaged(job, part_uid) and i != inventory.held:
            var r: Rect2 = _item_rect(i)
            _text(r.position + Vector2(4, 14), "DAMAGED", 13, Color("ff8a80"))
    if gpu_is_fitted():
        var radius: float = InstallFaults.gpu_screw_radius(CELL)
        var centers: Array = InstallFaults.gpu_screw_centers(gpu_slot_rect(), CELL)
        var bracket: Rect2 = InstallFaults.gpu_bracket_rect(gpu_slot_rect(), CELL)   # 0.48.1: on the card's rear bracket
        draw_rect(bracket, Color("7d868c"))
        draw_rect(bracket, Color("c9d1d6"), false, 1.0)
        for s in range(centers.size()):
            var tight: bool = s < int(job["gpu_screws"])
            draw_circle(centers[s], radius, Color("3b424d"))
            draw_arc(centers[s], radius, 0.0, TAU, 20, Color("dfe6ea") if tight else COLOR_BAD, 2.0)
            if tight: draw_line(centers[s] + Vector2(-radius * 0.5, 0), centers[s] + Vector2(radius * 0.5, 0), Color("dfe6ea"), 2.0)
        if int(job["gpu_screws"]) < InstallFaults.GPU_SCREW_COUNT:
            _text(Vector2(bracket.position.x - 40.0, (centers[0] as Vector2).y + 4.0), "loose", 12, COLOR_BAD)
    if screwdriver_held:
        draw_set_transform(pointer - Vector2(-18, 24) * 1.0)
        if not ToolRenderer.draw_tool_sprite(self, "screwdriver", pointer - Vector2(-18, 24), 0.0): ToolRenderer.draw_screwdriver(self)
        draw_set_transform(Vector2.ZERO)

# "Rearrange drawer" repacks the drawer only: what is fitted in the PC stays fitted.
func _reset_state() -> void:
    var fitted: Dictionary = {}
    var placed: Dictionary = CustomerPC.placements(GameState.job, {})
    for key: String in placed:
        if str(placed[key].get("location", "drawer")) != "drawer": fitted[key] = placed[key]
    for slot: String in GameState.job.get("shop_fitted", {}):   # shop test parts stay fitted too (B41)
        fitted[str(GameState.job["shop_fitted"][slot]["uid"])] = {"location": slot, "cell": [0, 0], "rotation": 0}
    inventory.setup(board, int(pc["depth"]), fitted, _components())
    _reset_motion()
    _save_inventory()
    _set_status("Drawer rearranged. Everything fitted in the PC stayed where it is.")

# ---- ordering parts (D149) ----

func _build_order_panel() -> void:
    order_panel = Panel.new()
    order_panel.name = "OrderPanel"
    order_panel.position = ORDER_RECT.position
    order_panel.size = ORDER_RECT.size
    order_panel.hide()
    add_child(order_panel)
    var title := Label.new()
    title.position = Vector2(14, 8)
    title.add_theme_font_size_override("font_size", 18)
    title.text = "ORDER PARTS · delivered to the drawer tonight"
    order_panel.add_child(title)
    var close := Button.new()
    close.text = "Close"
    close.position = Vector2(ORDER_RECT.size.x - 96, 6)
    close.size = Vector2(84, 30)
    close.pressed.connect(_toggle_order)
    order_panel.add_child(close)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(10, 44)
    scroll.size = ORDER_RECT.size - Vector2(20, 54)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    order_panel.add_child(scroll)
    var rows := VBoxContainer.new()
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(rows)
    for type: String in Catalog.TYPES:
        var head := Label.new()
        head.text = str(Catalog.TYPE_LABELS[type]).to_upper()
        head.add_theme_font_size_override("font_size", 15)
        rows.add_child(head)
        for id: String in Catalog.of_type(type):
            var row := HBoxContainer.new()
            var buy := Button.new()
            buy.custom_minimum_size = Vector2(110, 28)
            buy.pressed.connect(_buy.bind(id))
            order_buttons[id] = buy
            row.add_child(buy)
            var label := Label.new()
            label.text = "%s · %s" % [Catalog.part(id)["name"], Catalog.stat_text(id)]
            label.add_theme_font_size_override("font_size", 14)
            row.add_child(label)
            rows.add_child(row)
    _refresh_order()

func _refresh_order() -> void:
    for id: String in order_buttons:
        var price: int = int(Catalog.part(id)["price"])
        order_buttons[id].text = "Buy · $%d" % price
        order_buttons[id].disabled = GameState.money < price

func _toggle_order() -> void:
    order_panel.visible = not order_panel.visible
    _refresh_order()
    if order_panel.visible: _set_status("Shop cash: $%d. A bought part lands in the drawer; drag it into an empty slot to fit it." % GameState.money)

func _buy(id: String) -> void:
    _save_inventory()
    if GameState.buy_catalog_part(id):
        NightSession.checkpoint(GameState)
        _configure_layout()
        _set_status("%s bought for $%d: it is in the drawer. Shop cash now $%d." % [Catalog.part(id)["name"], int(Catalog.part(id)["price"]), GameState.money])
    else:
        _set_status("Not bought: not enough cash, or no room left in the drawer.", true)
    _refresh_order()

# ---- 0.51.0 (session 3.7, D159): a build's case and motherboard ----

func _build_case_panel() -> void:
    case_button = Button.new()
    case_button.name = "CaseButton"
    case_button.position = CASE_BUTTON.position
    case_button.size = CASE_BUTTON.size
    case_button.text = "Case and motherboard"
    case_button.pressed.connect(_toggle_case_panel)
    add_child(case_button)
    case_panel = Panel.new()
    case_panel.name = "CasePanel"
    case_panel.position = ORDER_RECT.position
    case_panel.size = ORDER_RECT.size
    case_panel.hide()
    add_child(case_panel)
    var title := Label.new()
    title.position = Vector2(14, 8)
    title.add_theme_font_size_override("font_size", 18)
    title.text = "CASE AND MOTHERBOARD · swapped while the case is empty"
    case_panel.add_child(title)
    var close := Button.new()
    close.text = "Close"
    close.position = Vector2(ORDER_RECT.size.x - 96, 6)
    close.size = Vector2(84, 30)
    close.pressed.connect(_toggle_case_panel)
    case_panel.add_child(close)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(10, 44)
    scroll.size = ORDER_RECT.size - Vector2(20, 54)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    case_panel.add_child(scroll)
    case_rows = VBoxContainer.new()
    case_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(case_rows)
    _refresh_case_panel()

# The rows are rebuilt only from the panel's own toggle/refresh, never inside a row button's signal.
func _refresh_case_panel() -> void:
    if not is_instance_valid(case_button): return
    var build: bool = PcBuild.is_build(GameState.job)
    case_button.visible = build
    if not build:
        case_panel.hide()
        return
    case_button.tooltip_text = "Swap the build's case or motherboard. Only while the case is empty: take every part out, then the motherboard."
    for child: Node in case_rows.get_children(): child.queue_free()
    var empty: bool = PcBuild.board_out(GameState.job)
    var note := Label.new()
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.custom_minimum_size = Vector2(ORDER_RECT.size.x - 40, 0)
    note.add_theme_font_size_override("font_size", 14)
    note.text = ("The case is empty: choose freely. The old one goes back to the supplier (refunded). A case of the other size takes a motherboard of its size. Swapping the case takes %d night minutes; fitting the motherboard back takes %d." % [BuildRequest.minutes("case"), BuildRequest.minutes("board")]) if empty else "Take every part out, then the motherboard (button above), before swapping the case or the board."
    case_rows.add_child(note)
    var now_case: String = PcBuild.case_model(GameState.job)
    var head := Label.new()
    head.text = "CASES"
    head.add_theme_font_size_override("font_size", 15)
    case_rows.add_child(head)
    for id: String in Catalog.CASES:
        case_rows.add_child(_choice_row(id, "%s · %s · $%d" % [Catalog.case_model(id)["name"], Catalog.case_text(id), int(Catalog.CASES[id]["price"])], id == now_case, not empty, true))
    var head_b := Label.new()
    head_b.text = "MOTHERBOARDS for this case"
    head_b.add_theme_font_size_override("font_size", 15)
    case_rows.add_child(head_b)
    var now_board: String = PcBuild.board_model(GameState.job)
    for id: String in Catalog.boards_for("compact" if str(GameState.job["layout"]) == "compact" else "tower"):
        case_rows.add_child(_choice_row(id, "%s · %s · $%d" % [Catalog.board(id)["name"], str(Catalog.BOARDS[id]["form"]), int(Catalog.BOARDS[id]["price"])], id == now_board, not empty, false))

func _choice_row(id: String, text: String, current: bool, locked: bool, is_case: bool) -> HBoxContainer:
    var row := HBoxContainer.new()
    var pick := Button.new()
    pick.custom_minimum_size = Vector2(110, 28)
    pick.text = "In the build" if current else "Choose"
    pick.disabled = current or locked
    pick.pressed.connect(_choose.bind(id, is_case))
    row.add_child(pick)
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 14)
    row.add_child(label)
    return row

func _toggle_case_panel() -> void:
    case_panel.visible = not case_panel.visible
    if case_panel.visible:
        order_panel.hide()
        _refresh_case_panel()

func _choose(id: String, is_case: bool) -> void:
    if inventory.held >= 0 or screwdriver_held: return
    _save_inventory()
    var result: Dictionary = GameState.choose_build_case(id) if is_case else GameState.choose_build_board(id)
    if bool(result["ok"]):
        NightSession.checkpoint(GameState)
        profile_id = str(GameState.job.get("layout", "tower"))
        _configure_layout()
    _set_status(str(result["message"]), not bool(result["ok"]))
    call_deferred("_refresh_case_panel")
