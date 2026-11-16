# Activities > Shop: every TOOL upgrade is sold here and nowhere else (D131). Parts stock is bought at
# the repair bench's Replacement stock panel.
extends "res://scripts/night/activities_view.gd"
const Upgrades = preload("res://scripts/data/upgrades.gd")
var cash_label: Label
var upgrade_buttons: Dictionary = {}
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("SHOP / TOOL UPGRADES",Vector2(172,24),Vector2(800,38),28)
    _label("All tool upgrades are sold here. Spare parts are bought at the repair bench (Replacement stock).",Vector2(32,84),Vector2(1100,40),18)
    Navigation.attach(self,_go.bind(Navigation.ACTIVITIES))
    Navigation.back(self,"Activities",Navigation.ACTIVITIES)
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
