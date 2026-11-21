# Builds the repair bench's buttons, labels and panels (no behaviour of its own: buttons call the bench).
# Split out of bench_view.gd in 0.41.2 (Wave 3 session 3.0). Holds no state of its own: every
# member it touches lives on the bench (`bv`), and the bench keeps one-line wrappers with the old
# names, so callers and tests are unchanged.
extends RefCounted

const Layout = preload("res://scripts/data/layout.gd")
const DustSim = preload("res://scripts/bench/dust_sim.gd")
const PasteSim = preload("res://scripts/bench/paste_sim.gd")
const PasteMaterials = preload("res://scripts/data/paste_materials.gd")

var bv   # the bench_view.gd node; untyped on purpose (its members are reached dynamically)


func _init(bench: Node2D) -> void:
    bv = bench


func _make_button(text: String, pos: Vector2, size: Vector2, callback: Callable, group: ButtonGroup = null) -> Button:
    var b := Button.new()
    b.text = text
    b.position = pos
    b.size = size
    b.focus_mode = Control.FOCUS_NONE
    if group != null:
        b.toggle_mode = true
        b.button_group = group
    b.pressed.connect(callback)
    b.pressed.connect(func() -> void: bv._sound("ui.click"))
    bv.add_child(b)
    return b


func _build_ui() -> void:
    bv.title_label = Label.new()
    bv.title_label.position = Vector2(40, 16)
    bv.title_label.size = Vector2(1200, 70)
    bv.title_label.add_theme_font_size_override("font_size", 18)
    bv.title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    bv.add_child(bv.title_label)

    bv.status_label = Label.new()
    bv.status_label.position = Vector2(bv.PANEL_X, 556)
    bv.status_label.size = Vector2(520, 85)
    bv.status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    bv.status_label.add_theme_font_size_override("font_size", 16)
    bv.add_child(bv.status_label)

    var stage_group := ButtonGroup.new()
    var b1: Button = _make_button("Cleaning", Vector2(bv.PANEL_X, 100), Vector2(250, 40), bv._select_stage.bind(bv.STAGE_CLEAN), stage_group)
    var b2: Button = _make_button("Thermal service", Vector2(bv.PANEL_X + 270, 100), Vector2(250, 40), bv._select_stage.bind(bv.STAGE_PASTE), stage_group)
    bv.stage_buttons.assign([b1,b2])   # typed Array[Button] on the bench: assign, not replace
    _style_stage_button(b1,Color("65c7b1"))
    _style_stage_button(b2,Color("b7a3ef"))
    b1.button_pressed = true

    var tool_group := ButtonGroup.new()
    var vac: Button = _make_button("Vacuum (2)", Vector2(bv.PANEL_X + 133, 164), Vector2(120, 36), bv._select_tool.bind(DustSim.TOOL_VACUUM), tool_group)
    var brush: Button = _make_button("Brush (1)", Vector2(bv.PANEL_X, 164), Vector2(120, 36), bv._select_tool.bind(DustSim.TOOL_BRUSH), tool_group)
    brush.button_pressed = true
    bv.tool_buttons = [vac, brush]
    var reset_dust: Button = _make_button("Practice: new dirty PC", Vector2(bv.PANEL_X + 270, 645), Vector2(250, 40), bv._new_ticket)
    bv.move_button = _make_button("Move parts (3)", Vector2(bv.PANEL_X + 266, 164), Vector2(120, 36), bv._select_tool.bind(2), tool_group)
    bv.tool_buttons.append(bv.move_button)
    var pick_button: Button = _make_button("Pick (4) / risky", Vector2(bv.PANEL_X + 399, 164), Vector2(120, 36), bv._select_tool.bind(3), tool_group)
    bv.tool_buttons.append(pick_button)
    for b: Button in [vac,brush,bv.move_button,pick_button]: b.add_theme_font_size_override("font_size",14)
    # Colour-coded tools (D90): the button's text carries its tool's colour in every state.
    for slot in range(bv.tool_buttons.size()):
        for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_hover_pressed_color"]:
            (bv.tool_buttons[slot] as Button).add_theme_color_override(state, bv.TOOL_COLORS[slot])
    bv.empty_bin_button = _make_button("Empty bin",Vector2(bv.PANEL_X,220),Vector2(250,32),bv._empty_bin)
    bv.stock_button = _make_button("Replacement stock",Vector2(bv.PANEL_X+270,220),Vector2(250,32),bv._open_replacements)
    bv.vacuum_status = Label.new()
    bv.vacuum_status.position = Vector2(bv.PANEL_X,260)
    bv.vacuum_status.size = Vector2(520,24)
    bv.vacuum_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bv.vacuum_status.add_theme_font_size_override("font_size",16)
    bv.add_child(bv.vacuum_status)
    bv.retract_button = _make_button("RETRACT",Layout.BENCH_RETRACT.position,Layout.BENCH_RETRACT.size,bv._retract_hose)
    bv.retract_button.add_theme_font_size_override("font_size",9)
    for state: String in ["normal","hover","pressed","hover_pressed"]:
        var face := StyleBoxFlat.new()
        face.bg_color = Color("365368") if state == "normal" else Color("557f97")
        face.set_content_margin_all(1)
        bv.retract_button.add_theme_stylebox_override(state,face)
    bv.retract_button.size = Layout.BENCH_RETRACT.size
    bv.retract_button.tooltip_text = "Retract hose into the vacuum bin. Pull the vacuum or hose to feed it out again."
    bv.clean_controls = [bv.retract_button,vac,brush,reset_dust,bv.move_button,pick_button,bv.empty_bin_button,bv.stock_button,bv.vacuum_status]
    bv._refresh_vacuum_status()

    bv.mount_button = _make_button("Mount cooler",Vector2(bv.PASTE_ORIGIN.x,628),Vector2(PasteSim.GRID*bv.PASTE_CELL,44),bv._on_mount_pressed)
    bv.clear_button = _make_button("Reset paste (practice)",Vector2(bv.PANEL_X,210),Vector2(250,40),bv._on_clear_pressed)
    bv.material_button = MenuButton.new()
    bv.material_button.position = Vector2(bv.PANEL_X,160)
    bv.material_button.size = Vector2(520,40)
    bv.material_button.focus_mode = Control.FOCUS_NONE
    var menu: PopupMenu = bv.material_button.get_popup()
    for i in range(PasteMaterials.IDS.size()):
        var kind: Dictionary = PasteMaterials.material(PasteMaterials.IDS[i])
        menu.add_radio_check_item("%s · %s"%[kind["label"],"free (scam)" if kind["scam"] else "$%d"%kind["cost"]],i)
    menu.id_pressed.connect(bv._on_material_selected)
    menu.about_to_popup.connect(bv._refresh_material_menu)
    bv.add_child(bv.material_button)
    bv.complete_button = _make_button("Complete repaste",Vector2(bv.PANEL_X+270,210),Vector2(250,40),bv._on_complete_pressed)
    bv.film_button = _make_button("Cooler base",Vector2(bv.PANEL_X,258),Vector2(250,40),bv._on_film_pressed)
    bv.film_button.tooltip_text = "Look at the cooler's contact plate."
    bv.paste_controls = [bv.mount_button,bv.clear_button,bv.material_button,bv.complete_button,bv.film_button]

    var back: Button = _make_button("Back to shop", Vector2(bv.PANEL_X, 645), Vector2(250, 44), bv._on_back_pressed)
    back.tooltip_text = "Saves work. An unfinished cooler mount is cancelled; only its lever locks it."
    bv.paste.material = str(GameState.job["paste_material"]) if str(GameState.job["paste_material"]) in PasteMaterials.IDS else "thermal"
    bv._refresh_material_button()
    bv._build_replacements()


func _style_stage_button(button: Button,tint: Color) -> void:
    for state: String in ["normal","hover","pressed","hover_pressed","focus"]:
        var box := StyleBoxFlat.new()
        box.bg_color = tint.darkened(0.65 if state == "normal" else 0.45)
        box.border_color = tint
        box.set_border_width_all(3 if state in ["pressed","hover_pressed"] else 1)
        button.add_theme_stylebox_override(state,box)
    for state: String in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color"]:
        button.add_theme_color_override(state,tint.lightened(0.2))
