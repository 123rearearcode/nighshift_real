# The night hardware bench shows the SELECTED TICKET'S OWN PC (D131): its CPU, RAM, GPU and cooler sit
# on the board exactly as the repair bench left them, and every move here is written back to the job.
# Parts removed at the repair bench lie in the drawer, broken parts say BROKEN, and replacing a broken
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
const SCREWDRIVER_TRAY := Rect2(430, 596, 270, 48)
const ORDER_RECT := Rect2(60, 150, 650, 440)
var screwdriver_held: bool = false
var order_panel: Panel
var order_buttons: Dictionary = {}   # catalogue id -> Buy button (D149)

func _ready() -> void:
    super._ready()
    for node: Node in get_children():
        if node is Label and node.position.y < 32: node.hide()
    Navigation.workbench(self,"hardware",_activities)
    _build_order_panel()

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
    return "NIGHTSHIFT / HARDWARE BENCH - ticket %s: %s's own PC, as it stands on the repair bench\nEvery part can come out: drag it to the drawer and back. Fit parts from your stock into empty slots (Order parts to buy). The GPU's bracket screws need the screwdriver (tray under the case)." % [str(GameState.job.get("id", "")), str(GameState.job.get("customer", ""))]

func _intro_text() -> String:
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
    for part: String in [Ids.GPU, Ids.COOLER]:
        GameState.set_service_part_fitted(part, CustomerPC.fitted_in(job, snapshot, part))
    if not job["hardware_trial"] is Dictionary: job["hardware_trial"] = {}
    var reproject: bool = GameState.apply_bench(snapshot)
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
    _remember_ids()

func _stock_record(part_uid: String) -> Dictionary:
    for record: Dictionary in GameState.player_inventory:
        if record["uid"] == part_uid: return record
    return {}

# Stock on a slot: a replacement on the first GPU slot / cooler mount, or a new part in any other slot.
func _fit_stock(part_uid: String, slot: String) -> bool:
    var record: Dictionary = _stock_record(part_uid)
    if record.is_empty(): return false
    if slot in [CustomerPC.SLOT_OF[Ids.GPU], CustomerPC.SLOT_OF[Ids.COOLER]]:
        _fit_replacement(part_uid)
        return true
    if GameState.fit_catalog_stock(part_uid, slot):
        _set_status("%s fitted. It is part of %s's PC now." % [Catalog.part(str(record.get("model", ""))).get("name", "Part"), str(GameState.job.get("customer", "the customer"))])
        return true
    _set_status("That part does not fit this slot.", true)
    return true

func _fit_replacement(part_uid: String) -> void:
    var record: Dictionary = _stock_record(part_uid)
    if record.is_empty(): return
    var kind: String = str(record["kind"])
    if GameState.fit_inventory_part(kind, part_uid):
        _configure_layout()
        _set_status(("Graphics card fitted. Its bracket screws are loose: pick up the screwdriver and tighten both." if kind == Ids.GPU
            else "Cooler fitted. It still needs fresh paste, mounting and screws at the repair bench.") + (" The customer's own one is in the drawer." if str(record["tier"]) == "model" and not CustomerPC.loose(GameState.job).is_empty() else ""))
    else:
        _configure_layout()
        _set_status("That stock part does not fit this ticket.", true)

# What may go where (D149). Stock tiers ("Equivalent"/"Budget") only replace a BROKEN first GPU / cooler;
# catalogue parts fit any empty matching slot, including over a working first GPU / cooler taken out.
# Broken parts never go back in. The PC's first card belongs in the first PCIe slot.
func _candidate(mouse: Vector2) -> Dictionary:
    var result: Dictionary = super._candidate(mouse)
    if inventory.held < 0 or result.get("kind", "") != "board" or not bool(result.get("ok", false)): return result
    var part_uid: String = str(inventory.items[inventory.held]["part"]["id"])
    var slot: String = str(result.get("connector_id", ""))
    var job: Dictionary = GameState.job
    var why: String = ""
    if CustomerPC.is_customer(part_uid):
        var kind: String = CustomerPC.part_of(part_uid)
        if CustomerPC.is_broken(job, part_uid) and kind == "loose":
            why = "This part is broken: it cannot go back in. Fit a working one."
        elif kind == Ids.GPU and slot == CustomerPC.GPU2_SLOT:
            why = "This is the PC's first card: it goes in PCIe slot 1. Slot 2 is for a second card."
        elif kind == "loose" and slot in [CustomerPC.SLOT_OF[Ids.GPU], CustomerPC.SLOT_OF[Ids.COOLER]] and CustomerPC.is_broken(job, part_uid):
            why = "This part is broken: it cannot go back in."
    else:
        var record: Dictionary = _stock_record(part_uid)
        var kind: String = str(record.get("kind", ""))
        var catalogue: bool = str(record.get("tier", "")) == "model"
        if slot in [CustomerPC.SLOT_OF[Ids.GPU], CustomerPC.SLOT_OF[Ids.COOLER]]:
            if not kind in Ids.SERVICE_PARTS: why = "That part does not go here."
            elif not kind in job["removed_parts"]: why = "Take the customer's %s out first." % kind.to_upper()
            elif not catalogue and not kind in job["broken_parts"]: why = "The customer's %s works. Refit it, or fit a part from the catalogue to upgrade it." % kind.to_upper()
        elif not catalogue:
            why = "Old trial stock only replaces a broken GPU or cooler. Order parts from the catalogue to fit new ones."
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
            if CustomerPC.is_customer(key) and CustomerPC.part_of(key) == "cpu" and not Ids.COOLER in GameState.job["removed_parts"]:
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

# "Rearrange drawer" repacks the drawer only: what is fitted in the PC stays fitted.
func _reset_state() -> void:
    var fitted: Dictionary = {}
    var placed: Dictionary = CustomerPC.placements(GameState.job, {})
    for key: String in placed:
        if str(placed[key].get("location", "drawer")) != "drawer": fitted[key] = placed[key]
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

