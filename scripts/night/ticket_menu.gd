# The ticket's pickup menu and ticket window (D134/D135, Wave 3 session 3.1). One implementation shared
# by the workshop room (right-click a PC) and the workbench header (the ticket identity). It only calls
# NightSession.ticket_action; all rules live in scripts/rules/ticket.gd.
extends RefCounted

const Ticket = preload("res://scripts/rules/ticket.gd")
const Customers = preload("res://scripts/data/customers.gd")
const Games = preload("res://scripts/data/games.gd")


static func _gs(owner: Node) -> Node: return owner.get_node("/root/GameState")
static func _session(owner: Node) -> Node: return owner.get_node("/root/NightSession")


static func job(owner: Node, id: String) -> Dictionary:
    return _session(owner).ticket_job(_gs(owner), id)


static func game_titles() -> Dictionary:
    var out: Dictionary = {}
    for id: String in Games.IDS: out[id] = str(Games.game(id).get("title", id))
    return out


# Applies one action and returns {ok, message}. `after` is called with the result (to refresh views).
static func act(owner: Node, id: String, action: String, after: Callable = Callable()) -> Dictionary:
    var result: Dictionary = _session(owner).ticket_action(_gs(owner), id, action)
    owner.get_node("/root/AudioFeedback").request(owner, "ui.click")
    if after.is_valid(): after.call(result)
    return result


# Right-click menu at a screen position. Freed when it closes.
static func popup(owner: Node, id: String, at: Vector2, after: Callable = Callable()) -> PopupMenu:
    var entries: Array = Ticket.menu(job(owner, id))
    if entries.is_empty(): return null
    var menu := PopupMenu.new()
    menu.name = "TicketMenu"
    for i in range(entries.size()): menu.add_item(str(entries[i][1]), i)
    menu.id_pressed.connect(func(index: int) -> void: act(owner, id, str(entries[index][0]), after))
    menu.popup_hide.connect(menu.queue_free)
    owner.add_child(menu)
    menu.popup(Rect2i(Vector2i(at), Vector2i(1, 1)))
    return menu


# The ticket window: the whole record plus the two pickup actions. Freed when it closes.
static func window(owner: Node, id: String, after: Callable = Callable()) -> AcceptDialog:
    var dialog := AcceptDialog.new()
    dialog.name = "TicketWindow"
    dialog.title = "Ticket"
    dialog.ok_button_text = "Close"
    dialog.min_size = Vector2i(560, 0)
    var buttons: Dictionary = {}
    var refresh := func() -> void:
        var current: Dictionary = job(owner, id)
        dialog.dialog_text = Ticket.text(current, Customers.customer(str(current.get("customer_id", ""))), game_titles())
        for entry: Array in Ticket.menu(current):
            if buttons.has(entry[0]): buttons[entry[0]].text = str(entry[1])
    for entry: Array in Ticket.menu(job(owner, id)):
        buttons[entry[0]] = dialog.add_button(str(entry[1]), false, str(entry[0]))
    dialog.custom_action.connect(func(action: StringName) -> void:
        act(owner, id, str(action), after)
        refresh.call())
    dialog.confirmed.connect(dialog.queue_free)
    dialog.canceled.connect(dialog.queue_free)
    refresh.call()
    owner.add_child(dialog)
    dialog.popup_centered()
    return dialog


# Header text for the workbench identity: customer · ticket · case · status badge.
static func identity_text(current: Dictionary) -> String:
    var badge: String = Ticket.badge(current)
    return "%s · %s · %s PC%s" % [current.get("customer", ""), current.get("id", ""), str(current.get("layout", "tower")).capitalize(), ("  [" + badge + "]") if badge != "" else ""]
