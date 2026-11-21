# Outside > the store down the street (0.55.0, D162; the counter's "tool catalogue" in 0.53.0; Activities >
# Shop before that): every TOOL upgrade is sold here and nowhere else (D131). It is not the parts supplier
# (a separate "later" spot outside). Parts stock is still bought on the hardware bench (Order parts).
extends "res://scripts/night/night_screen.gd"
const Upgrades = preload("res://scripts/data/upgrades.gd")
var cash_label: Label
var upgrade_buttons: Dictionary = {}
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("THE STORE / TOOLS AND UPGRADES",Vector2(210,24),Vector2(760,38),28)
    _label("Tool upgrades are sold here. Spare parts are ordered on the hardware bench (Order parts).",Vector2(32,84),Vector2(1100,40),18)
    Navigation.exit(self,"Outside",Navigation.OUTSIDE)   # 0.55.0: the store is down the street
    cash_label = _label("",Vector2(32,136),Vector2(600,40),24)
    var y: float = 200
    for upgrade: Dictionary in Upgrades.LIST:
        var id: String = upgrade["id"]
        var button := _button("",Rect2(32,y,430,64),"")
        button.pressed.connect(_buy.bind(id))
        upgrade_buttons[id] = button
        _label(str(upgrade["blurb"]),Vector2(484,y + 18),Vector2(740,40),18)
        y += 84
    message = _label(NightSession.status,Vector2(32,640),Vector2(1210,50),16)
    _refresh()
func _refresh() -> void:
    cash_label.text = "Shop cash: $%d" % GameState.money
    for upgrade: Dictionary in Upgrades.LIST:
        var id: String = upgrade["id"]
        var owned: bool = GameState.has_upgrade(id)
        upgrade_buttons[id].text = str(upgrade["label"]) + (" · owned" if owned else " · $%d" % int(GameState.UPGRADE_PRICES[id]))
        upgrade_buttons[id].disabled = owned
func _buy(id: String) -> void:
    var bought: bool = GameState.buy_upgrade(id)
    if bought: NightSession.checkpoint(GameState)
    message.text = ("Upgrade bought · cash $%d" % GameState.money) if bought else "Not enough cash for this upgrade."
    if NightSession.status != "": message.text = NightSession.status
    _refresh()
