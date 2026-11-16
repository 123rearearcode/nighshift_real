extends Node2D
const Navigation = preload("res://scripts/night/night_navigation.gd")
var message: Label
func _ready() -> void:
    NightSession.ensure(GameState)
    _label("NIGHTSHIFT / AFTER HOURS",Vector2(60,72),Vector2(1160,60),32)
    _label("Choose your next activity. Your PCs stay where you left them.",Vector2(60,140),Vector2(1160,40),20)
    _button("WORKSHOP ROOM\nDrag a PC into the workshop slot",Rect2(60,235,550,150),"res://scenes/storage.tscn")
    _button("SALVAGE DUMP\nDrive out and search the pile",Rect2(670,235,550,150),"res://scenes/night_salvage.tscn")
    _button("SHOP\nBuy tool upgrades",Rect2(60,430,550,140),"res://scenes/night_shop.tscn")
    Navigation.pause(self)
    message = _label(NightSession.status,Vector2(60,620),Vector2(1160,65),17)

func _label(text: String,at: Vector2,area: Vector2,size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",size)
    add_child(label)
    return label
func _button(text: String,rect: Rect2,path: String) -> Button:
    var button := Button.new()
    button.text = text
    button.position = rect.position
    button.size = rect.size
    button.add_theme_font_size_override("font_size",20)
    if path != "": button.pressed.connect(_go.bind(path))
    button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(button)
    return button
func _go(path: String) -> void:
    _navigate(path)
func _navigate(path: String) -> bool:
    if not NightSession.checkpoint(GameState):
        if is_instance_valid(message): message.text = NightSession.status
        return false
    return Navigation.commit(self,path)
func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("151e27"))
