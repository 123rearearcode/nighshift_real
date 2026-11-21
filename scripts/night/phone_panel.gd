# The player's phone (session 3.8 / 0.52.0, D160; user: "it's gonna be a button on your phone, which is
# gonna be the place where you see all reviews and have a button to buy more ... it's gonna look more like
# an app"). The FixFindr app: the shop's star rating, every review with its comment (newest first),
# trustworthiness and the shop level, and ReviewBoost, which sells fake five-star reviews. Reads GameState
# and calls its one action (buy_fake_reviews); it never decides anything itself.
# Scam hook: bought reviews look like any other review here, as they do to customers.
extends Panel

const Reviews = preload("res://scripts/rules/reviews.gd")
const SIZE := Vector2(400, 600)

var header: Label
var standing: Label
var list: VBoxContainer
var buy_button: Button
var close_button: Button
var status: Label


func _ready() -> void:
    name = "PhonePanel"
    size = SIZE
    mouse_filter = Control.MOUSE_FILTER_STOP
    var style := StyleBoxFlat.new()
    style.bg_color = Color("111418")
    style.border_color = Color("5c6670")
    style.set_border_width_all(6)
    style.set_corner_radius_all(28)
    add_theme_stylebox_override("panel", style)
    var app := _label("%s · your shop's page" % Reviews.SITE, Vector2(24, 22), Vector2(300, 28), 18)
    app.add_theme_color_override("font_color", Color("ffcf6b"))
    close_button = Button.new()
    close_button.name = "PhoneClose"
    close_button.text = "Close"
    close_button.position = Vector2(SIZE.x - 92, 18)
    close_button.size = Vector2(70, 30)
    close_button.pressed.connect(hide)
    add_child(close_button)
    header = _label("", Vector2(24, 56), Vector2(SIZE.x - 48, 28), 22)
    standing = _label("", Vector2(24, 86), Vector2(SIZE.x - 48, 44), 14)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(20, 134)
    scroll.size = Vector2(SIZE.x - 40, 330)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    list = VBoxContainer.new()
    list.custom_minimum_size = Vector2(SIZE.x - 60, 0)
    scroll.add_child(list)
    buy_button = Button.new()
    buy_button.name = "BuyReviewsButton"
    buy_button.position = Vector2(20, 474)
    buy_button.size = Vector2(SIZE.x - 40, 44)
    buy_button.add_theme_font_size_override("font_size", 15)
    buy_button.pressed.connect(_buy)
    add_child(buy_button)
    _label("ReviewBoost: cheap, fast, anonymous. %s checks new reviews every morning." % Reviews.SITE, Vector2(24, 520), Vector2(SIZE.x - 48, 36), 12)
    status = _label("", Vector2(24, 556), Vector2(SIZE.x - 48, 36), 13)
    refresh()


func _label(text: String, at: Vector2, area: Vector2, font: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font)
    add_child(label)
    return label


func open() -> void:
    refresh()
    status.text = ""
    show()


# The rows are rebuilt here only, never inside a row's own signal.
func refresh() -> void:
    var reviews: Array = GameState.reviews
    header.text = "%.1f ★  ·  %d review%s" % [GameState.shop_rating(), Reviews.counted(reviews), "" if Reviews.counted(reviews) == 1 else "s"]
    standing.text = GameState.standing_text() + "\nShop level upgrades: coming later."
    for child: Node in list.get_children(): child.queue_free()
    if reviews.is_empty():
        var none := Label.new()
        none.text = "No reviews yet. Customers write one when they collect."
        none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        none.custom_minimum_size = Vector2(SIZE.x - 70, 0)
        list.add_child(none)
    for i in range(reviews.size() - 1, -1, -1):
        var r: Variant = reviews[i]
        if not r is Dictionary: continue
        var row := Label.new()
        row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.custom_minimum_size = Vector2(SIZE.x - 70, 0)
        row.add_theme_font_size_override("font_size", 14)
        if str(r.get("kind", "")) == Reviews.NOTICE:
            row.text = "⚠ %s · night %d\n%s\n" % [str(r.get("author", Reviews.SITE)), int(r.get("night", 1)), str(r.get("text", ""))]
            row.add_theme_color_override("font_color", Color("ff9d9d"))
        else:
            row.text = "%s  %s · night %d\n%s\n" % [Reviews.stars_text(int(r.get("stars", 3))), str(r.get("author", "")), int(r.get("night", 1)), str(r.get("text", ""))]
        list.add_child(row)
    buy_button.text = "ReviewBoost: buy %d five-star reviews · $%d" % [Reviews.FAKE_PACK, Reviews.FAKE_PRICE]
    buy_button.disabled = GameState.money < Reviews.FAKE_PRICE


func _buy() -> void:
    if GameState.buy_fake_reviews():
        NightSession.checkpoint(GameState)
        status.text = "%d glowing reviews posted. Shop cash now $%d." % [Reviews.FAKE_PACK, GameState.money]
    else:
        status.text = "Not enough cash ($%d needed)." % Reviews.FAKE_PRICE
    call_deferred("refresh")
