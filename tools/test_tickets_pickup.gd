# Wave 3 session 3.1 (D134/D135): tickets as records; ready sticker and calling the customer, from the
# room (right-click a PC) and from the workbench ticket (the header identity).
extends "res://tools/test_support.gd"
const Ticket = preload("res://scripts/rules/ticket.gd")
const TicketMenu = preload("res://scripts/night/ticket_menu.gd")
const Customers = preload("res://scripts/data/customers.gd")

func _initialize() -> void: call_deferred("run_checks")

func right_click(at: Vector2) -> void:
    for down: bool in [true, false]:
        var e := InputEventMouseButton.new()
        e.position = at
        e.global_position = at
        e.button_index = MOUSE_BUTTON_RIGHT
        e.pressed = down
        root.push_input(e, true)
        await process_frame

func find_menu(owner: Node) -> PopupMenu:
    for child: Node in owner.get_children():
        if child is PopupMenu and child.name.begins_with("TicketMenu"): return child
    return null

func run_checks() -> void:
    var gs: Node = root.get_node("GameState")
    var night: Node = root.get_node("NightSession")
    use_test_save(gs, "tickets_pickup_test.json")
    var manifest: String = gs.save_path + ".night.json"
    var layout: String = "user://tickets_pickup_layout_test.json"
    _remove_save_files(manifest)
    _remove_save_files(layout)

    # Pure rule.
    check(Ticket.sanitize(null) == {"request": "repair", "ready": false, "called": false} and Ticket.sanitize({"request": "x", "ready": "yes", "called": true})["called"] and Ticket.sanitize({"request": "x"})["request"] == "repair", "ticket flags are sanitized")
    var j: Dictionary = {"id": "T9", "customer": "Ana", "state": "open", "complaint": "Loud fans.", "payout": 40, "layout": "tower"}
    check(Ticket.status(j) == Ticket.OPEN and Ticket.badge(j) == "", "a new ticket is open with no sticker")
    var r: Dictionary = Ticket.apply(j, Ticket.TOGGLE_READY)
    check(r["ok"] and r["flags"]["ready"] and not j.has("ticket"), "apply works on a copy")
    j["ticket"] = r["flags"]
    check(Ticket.status(j) == Ticket.READY and Ticket.badge(j) == "READY", "sticker marks it ready")
    j["ticket"] = Ticket.apply(j, Ticket.TOGGLE_CALL)["flags"]
    check(Ticket.status(j) == Ticket.CALLED and Ticket.badge(j) == "CALLED" and Ticket.status_text(j).contains("next morning"), "calling wins over the sticker and says next morning")
    check(Ticket.menu(j)[1][1].contains("Cancel") and Ticket.menu(j)[0][1].contains("Remove"), "menu offers to undo both")
    j["state"] = "done"
    check(Ticket.menu(j).is_empty() and not Ticket.apply(j, Ticket.TOGGLE_CALL)["ok"], "a collected ticket has no pickup actions")
    var who: Dictionary = Customers.customer(Customers.IDS[0])
    var record: Dictionary = Ticket.record({"id": "T1", "complaint": "Hot.", "layout": "compact", "payout": 30}, who)
    check(record["request"] == "repair" and record["symptoms"] == "Hot." and record["machine"]["layout"] == "compact" and record["terms"]["payout"] == 30 and record["customer"]["name"] != "", "the ticket record holds request, customer, machine, symptoms and terms")
    var text: String = Ticket.text({"id": "T1", "complaint": "Hot.", "layout": "compact", "payout": 30, "customer": "Mara"}, who, TicketMenu.game_titles())
    check(text.contains("TICKET T1") and text.contains("What they say: Hot.") and text.contains("$30") and not text.contains("\n\n\n"), "ticket text reads cleanly")

    # State: active and stored tickets, saved in both files.
    gs.new_game(false)
    check(night.start(gs), "night starts")
    var first: String = night.active_id
    var other: String = night.tickets[1]["id"]
    check(Ticket.status(gs.job) == Ticket.OPEN, "new game ticket is open")
    var res: Dictionary = night.ticket_action(gs, other, Ticket.TOGGLE_CALL)
    check(res["ok"] and Ticket.status(night.ticket_job(gs, other)) == Ticket.CALLED and Ticket.status(gs.job) == Ticket.OPEN, "calling a stored PC leaves the active one alone")
    res = night.ticket_action(gs, first, Ticket.TOGGLE_READY)
    check(res["ok"] and gs.job["ticket"]["ready"], "the active PC gets its sticker")
    night.bound_path = ""   # force a reload of the manifest
    check(night.ensure(gs) and Ticket.status(night.ticket_job(gs, other)) == Ticket.CALLED, "the call survives a manifest reload")
    gs.save_game()
    check(gs.load_game() and gs.job["ticket"]["ready"], "the sticker survives save and load")
    check(night.switch_pc(gs, other) and Ticket.status(gs.job) == Ticket.CALLED and night.switch_pc(gs, first), "the flags travel with their PC when switching")
    check(not night.ticket_action(gs, "T999", Ticket.TOGGLE_CALL)["ok"], "unknown tickets are refused")
    night.read_only = true
    check(not night.ticket_action(gs, other, Ticket.TOGGLE_CALL)["ok"] and Ticket.status(night.ticket_job(gs, other)) == Ticket.CALLED, "a protected manifest cannot be changed")
    night.read_only = false
    var data: Dictionary = load("res://scripts/state/save_store.gd").read(gs.save_path)
    data["job"].erase("ticket")
    load("res://scripts/state/save_store.gd").write(gs.save_path, data)
    check(gs.load_game() and gs.job["ticket"] == {"request": "repair", "ready": false, "called": false}, "old saves without a ticket load as open")
    night.bound_path = ""
    night.ensure(gs)
    night.checkpoint(gs)

    # Room: native right-click on a PC opens the pickup menu; the sticker shows.
    var room: Node = load("res://scripts/storage/storage_view.gd").new()
    room.store.path = layout
    root.add_child(room)
    current_scene = room
    await process_frame
    room._fit_used()
    var uid: String = ""
    for id: String in room.model.items:
        if room.model.items[id]["category"] == "pc" and room.model.items[id]["source_uid"] == other: uid = id
    check(uid != "" and room.ticket_badges.get(other, "") == "CALLED", "room knows the stored PC was called")
    await right_click(room.item_rect(uid).get_center())
    var menu: PopupMenu = find_menu(room)
    check(menu != null and menu.item_count == 2 and menu.get_item_text(1).contains("Cancel"), "native right-click on a room PC opens its pickup menu")
    if menu != null: menu.id_pressed.emit(1)
    await process_frame
    check(Ticket.status(night.ticket_job(gs, other)) == Ticket.OPEN and not room.ticket_badges.has(other) and room.status.text.contains("cancelled"), "cancelling the call from the room updates the ticket and the sticker")
    room._ticket_action(uid, Ticket.TOGGLE_READY)
    check(room.ticket_badges.get(other, "") == "READY" and room.info.text.contains("ready"), "the room shows the ready sticker and the ticket status")
    room.queue_redraw()
    await process_frame
    check(room.model.held == "", "right-click never picks a PC up")
    room.queue_free()
    await process_frame

    # Workbench header: the identity is the ticket.
    change_scene_to_file("res://scenes/software.tscn")
    await process_frame
    await process_frame
    var ticket: Button = current_scene.get_node_or_null("TicketButton")
    var identity: Label = current_scene.get_node_or_null("PCIdentity")
    check(ticket != null and identity != null and identity.text.contains(first) and identity.text.contains("[READY]"), "the workbench identity shows the ticket and its sticker")
    await right_click(ticket.get_global_rect().get_center())
    menu = find_menu(current_scene)
    check(menu != null and menu.get_item_text(1).contains("Call"), "right-clicking the ticket opens the pickup menu")
    if menu != null: menu.id_pressed.emit(1)
    await process_frame
    check(gs.job["ticket"]["called"] and identity.text.contains("[CALLED]"), "calling from the ticket updates the header")
    ticket.pressed.emit()
    await process_frame
    var window: AcceptDialog = current_scene.get_node_or_null("TicketWindow")
    check(window != null and window.dialog_text.contains("TICKET " + first) and window.dialog_text.contains("collects next morning"), "clicking the ticket opens the full ticket")
    if window != null:
        window.custom_action.emit(&"toggle_call")
        await process_frame
        check(not gs.job["ticket"]["called"] and window.dialog_text.contains("Marked ready"), "the ticket window's buttons act and refresh in place")
        window.hide()
    _remove_save_files(manifest)
    _remove_save_files(layout)
    restore_save(gs)
    finish("Tickets and pickup")
