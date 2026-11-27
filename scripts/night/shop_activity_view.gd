# Outside > the store down the street (0.55.0, D162; the counter's "tool catalogue" in 0.53.0; Activities >
# Shop before that): every TOOL upgrade is sold here and nowhere else (D131). It is not the parts supplier
# (a separate "later" spot outside). Parts stock is still bought on the hardware bench (Order parts).
extends "res://scripts/night/night_screen.gd"
const Upgrades = preload("res://scripts/data/upgrades.gd")
const CableBox = preload("res://scripts/rules/cable_box.gd")      # 0.58.3 (D173): cable-box supplies
const CableStore = preload("res://scripts/state/cable_store.gd")
var cash_label: Label
var upgrade_buttons: Dictionary = {}
var supply_buttons: Dictionary = {}
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("THE STORE / TOOLS AND UPGRADES",Vector2(210,24),Vector2(760,38),28)
    _label("Tool upgrades are sold here. Spare parts are ordered on the hardware bench (Order parts).",Vector2(32,84),Vector2(1100,40),18)
    Navigation.exit(self,"Outside",Navigation.OUTSIDE)   # 0.55.0: the store is down the street
    cash_label = _label("",Vector2(32,136),Vector2(600,40),24)
    var y: float = 186
    for upgrade: Dictionary in Upgrades.LIST:
        var id: String = upgrade["id"]
        var button := _button("",Rect2(32,y,430,52),"")
        button.pressed.connect(_buy.bind(id))
        upgrade_buttons[id] = button
        _label(str(upgrade["blurb"]),Vector2(484,y + 12),Vector2(740,40),18)
        y += 62
    # 0.58.3 (D173): things for the cable box (user: "you can get things from the shop to help you fix this").
    _label("FOR THE CABLE BOX",Vector2(32,y + 4),Vector2(600,30),18)
    y += 36
    for supply: String in CableBox.SUPPLIES:
        var info: Dictionary = CableBox.SUPPLIES[supply]
        var b := _button("",Rect2(32,y,430,56),"")
        b.name = "Supply_" + supply
        b.pressed.connect(_buy_supply.bind(supply))
        supply_buttons[supply] = b
        _label(str(info["blurb"]),Vector2(484,y + 14),Vector2(740,40),18)
        y += 66
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
