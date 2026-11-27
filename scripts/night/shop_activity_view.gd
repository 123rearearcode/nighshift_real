# Outside > the store down the street (0.55.0, D162; the counter's "tool catalogue" in 0.53.0; Activities >
# Shop before that): every TOOL upgrade is sold here and nowhere else (D131). It is not the parts supplier
# (a separate "later" spot outside). Parts stock is still bought on the hardware bench (Order parts).
extends "res://scripts/night/night_screen.gd"
const Upgrades = preload("res://scripts/data/upgrades.gd")
const CableBox = preload("res://scripts/rules/cable_box.gd")      # 0.58.3 (D173): cable-box supplies
const CableStore = preload("res://scripts/state/cable_store.gd")
const WallFinishes = preload("res://scripts/data/wall_finishes.gd")   # 0.58.9 (D180): wall finishes for the counter
var cash_label: Label
var upgrade_buttons: Dictionary = {}
var supply_buttons: Dictionary = {}
var wall_buttons: Dictionary = {}
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("THE STORE / TOOLS AND UPGRADES",Vector2(210,24),Vector2(760,38),28)
    _label("Tool upgrades are sold here. Spare parts are ordered on the hardware bench (Order parts).",Vector2(32,84),Vector2(1100,40),18)
    Navigation.exit(self,"Outside",Navigation.OUTSIDE)   # 0.55.0: the store is down the street
    cash_label = _label("",Vector2(32,136),Vector2(600,40),24)
    var y: float = 186
    for upgrade: Dictionary in Upgrades.LIST:
        var id: String = upgrade["id"]
        var button := _button("",Rect2(32,y,430,46),"")
        button.pressed.connect(_buy.bind(id))
        upgrade_buttons[id] = button
        _label(str(upgrade["blurb"]),Vector2(484,y + 10),Vector2(740,40),18)
        y += 54
    # 0.58.3 (D173): things for the cable box (user: "you can get things from the shop to help you fix this").
    _label("FOR THE CABLE BOX",Vector2(32,y + 4),Vector2(600,30),18)
    y += 36
    for supply: String in CableBox.SUPPLIES:
        var info: Dictionary = CableBox.SUPPLIES[supply]
        var b := _button("",Rect2(32,y,430,46),"")
        b.name = "Supply_" + supply
        b.pressed.connect(_buy_supply.bind(supply))
        supply_buttons[supply] = b
        _label(str(info["blurb"]),Vector2(484,y + 10),Vector2(740,40),18)
        y += 54
    # 0.58.9 (D180, user: "Later on in the game, you can change wallpaper"): the counter's walls. Buy a finish
    # once, then put any finish you own up again for free.
    _label("WALLS IN THE SHOP (the counter room)",Vector2(32,y + 2),Vector2(800,30),18)
    y += 32
    var wx: float = 32.0
    for entry: Dictionary in WallFinishes.LIST:
        var wid: String = entry["id"]
        var wb := _button("",Rect2(wx,y,232,44),"")
        wb.name = "Wall_" + wid
        wb.add_theme_font_size_override("font_size",16)
        wb.tooltip_text = str(entry["blurb"])
        wb.pressed.connect(_wall.bind(wid))
        wall_buttons[wid] = wb
        wx += 244.0
    message = _label(NightSession.status,Vector2(32,640),Vector2(1210,50),16)
    _refresh()
func _refresh() -> void:
    cash_label.text = "Shop cash: $%d" % GameState.money
    for upgrade: Dictionary in Upgrades.LIST:
        var id: String = upgrade["id"]
        var owned: bool = GameState.has_upgrade(id)
        upgrade_buttons[id].text = str(upgrade["label"]) + (" · owned" if owned else " · $%d" % int(GameState.UPGRADE_PRICES[id]))
        upgrade_buttons[id].disabled = owned
    var box: Dictionary = CableStore.load_box(GameState)
    for supply: String in supply_buttons:
        var info: Dictionary = CableBox.SUPPLIES[supply]
        supply_buttons[supply].text = "%s · $%d (in the box: %d)" % [info["label"], int(info["price"]), int(box.get(supply, 0))]
        supply_buttons[supply].disabled = GameState.money < int(info["price"])
    for wid: String in wall_buttons:
        var entry: Dictionary = WallFinishes.finish(wid)
        var up: bool = GameState.wall_finish == wid
        var owned: bool = GameState.has_wall(wid)
        wall_buttons[wid].text = "%s · %s" % [entry["short"], "on the wall" if up else ("put up" if owned else "$%d" % int(entry["price"]))]
        wall_buttons[wid].disabled = up or (not owned and GameState.money < int(entry["price"]))
func _wall(id: String) -> void:
    var entry: Dictionary = WallFinishes.finish(id)
    var had: bool = GameState.has_wall(id)
    if not GameState.buy_wall(id):
        message.text = "Not enough cash for %s." % str(entry["label"]).to_lower()
        return
    NightSession.checkpoint(GameState)
    message.text = ("%s is up in the counter room." if had else "%s bought and put up in the counter room · cash $%d") % ([entry["label"]] if had else [entry["label"], GameState.money])
    if NightSession.status != "": message.text = NightSession.status
    _refresh()
func _buy_supply(supply: String) -> void:
    var info: Dictionary = CableBox.SUPPLIES[supply]
    var box: Dictionary = CableStore.load_box(GameState)
    if not GameState.spend_cash(int(info["price"])):
        message.text = "Not enough cash."
        return
    CableBox.add_supply(box, supply)
    CableStore.save_box(GameState, box)
    NightSession.checkpoint(GameState)
    message.text = "%s bought: they go in the cable box · cash $%d" % [info["label"], GameState.money]
    if NightSession.status != "": message.text = NightSession.status
    _refresh()
func _buy(id: String) -> void:
    var bought: bool = GameState.buy_upgrade(id)
    if bought: NightSession.checkpoint(GameState)
    message.text = ("Upgrade bought · cash $%d" % GameState.money) if bought else "Not enough cash for this upgrade."
    if NightSession.status != "": message.text = NightSession.status
    _refresh()
