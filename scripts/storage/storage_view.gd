# Rack presentation. Ownership stays in GameState; furniture/layout live in StorageStore.
extends Node2D
const Data = preload("res://scripts/storage/storage_data.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const Motion = preload("res://scripts/view/part_motion.gd")
var model := Model.new()
var store := Store.new()
var motion := Motion.new()
var page: int = 0
var waiting_page: int = 0
var pointer := Vector2.ZERO
var selected: String = ""
var selected_unit: String = ""
var grab := Vector2(0.5,0.5)
var summary: Label
var info: Label
var status: Label
var furniture_list: VBoxContainer
var add_dialog: PopupPanel
var edit_buttons: Array[Button] = []
var furniture_buttons: Array[Button] = []

func _ready() -> void:
    model.setup(Sources.collect(GameState),store.read())
    selected_unit = model.units[0]["id"]
    _label("STORAGE / YOUR WORKSHOP",Vector2(24,18),Vector2(900,40),28)
    summary = _label("",Vector2(24,62),Vector2(940,30),16)
    _button("Main menu",Rect2(1100,22,152,42),_leave)
    _label("FURNITURE",Vector2(24,128),Vector2(210,30),17)
    furniture_list = VBoxContainer.new()
    furniture_list.position = Vector2(24,168)
    furniture_list.size = Vector2(202,315)
    furniture_list.add_theme_constant_override("separation",8)
    add_child(furniture_list)
    edit_buttons.append(_button("+ Add furniture",Rect2(24,490,202,40),func() -> void: add_dialog.popup_centered()))
    edit_buttons.append(_button("Remove empty unit",Rect2(24,538,202,36),_remove_unit))
    edit_buttons.append(_button("Arrange shelves",Rect2(1010,450,242,38),_arrange))
    _button("Refresh contents",Rect2(1010,496,242,38),_refresh)
    edit_buttons.append(_button("Save layout",Rect2(1010,542,242,38),_save))
    _label("DETAILS",Vector2(1010,128),Vector2(242,28),17)
    info = _label("Hover over a part, tool or PC.\n\nDrag to arrange. R / Q / E rotate.\nTab switches furniture pages while holding.\nEscape cancels a move.",Vector2(1010,168),Vector2(242,272),16)
    _label("WAITING FOR SPACE",Vector2(24,592),Vector2(280,26),15)
    _button("‹",Rect2(1150,588,45,30),func() -> void: _waiting_turn(-1))
    _button("›",Rect2(1203,588,45,30),func() -> void: _waiting_turn(1))
    status = _label("",Vector2(24,677),Vector2(1230,32),14)
    _make_add_dialog()
    get_window().focus_exited.connect(_cancel)
    _sync_ui()

func _label(text: String, at: Vector2, area: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = at
    label.size = area
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size",font_size)
    add_child(label)
    return label

func _button(text: String, rect: Rect2, action: Callable, parent: Node = self) -> Button:
    var b := Button.new()
    b.text = text
    b.position = rect.position
    b.size = rect.size
    b.pressed.connect(action)
    b.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    parent.add_child(b)
    return b

func _make_add_dialog() -> void:
    add_dialog = PopupPanel.new()
    add_dialog.size = Vector2i(500,270)
    add_child(add_dialog)
    var title := Label.new()
    title.text = "Expand your workshop · free in this prototype"
    title.position = Vector2(20,16)
    add_dialog.add_child(title)
    var y: float = 54
    for kind: String in Data.MODELS:
        var spec: Dictionary = Data.MODELS[kind]
        _button(spec["name"]+"\n"+spec["hint"],Rect2(16,y,468,56),func() -> void: _add_unit(kind),add_dialog)
        y += 64

func _sync_ui() -> void:
    page = clampi(page,0,maxi(0,(model.units.size()-1)/2))
    waiting_page = clampi(waiting_page,0,maxi(0,(model.overflow().size()-1)/8))
    for b: Button in furniture_buttons:
        b.free()
    furniture_buttons.clear()
    for i in range(model.units.size()):
        var u: Dictionary = model.units[i]
        var b := Button.new()
        b.text = "%d · %s"%[i+1,Data.MODELS[u["model"]]["name"]]
        b.custom_minimum_size = Vector2(202,30)
        b.toggle_mode = true
        b.button_pressed = u["id"] == selected_unit
        b.pressed.connect(func() -> void: page = i/2; selected_unit = u["id"]; _sync_ui())
        furniture_list.add_child(b)
        furniture_buttons.append(b)
    var counts := {"pc":0,"tool":0,"part":0}
    for item: Dictionary in model.items.values(): counts[item["category"]] += 1
    summary.text = "%d PC · %d tools · %d parts     |     %d furniture units     |     %d waiting for space"%[counts.pc,counts.tool,counts.part,model.units.size(),model.overflow().size()]
    status.text = store.status if store.status != "" else "Drag to store · invalid drops return safely · fitted parts keep reserved shelf space · furniture is free in this prototype"
    for b: Button in edit_buttons: b.disabled = store.read_only
    queue_redraw()

func _save() -> void:
    store.write(model)
    _sync_ui()

func _refresh() -> void:
    model.setup(Sources.collect(GameState),model.snapshot())
    selected = ""
    _sync_ui()

func _add_unit(kind: String) -> void:
    if store.read_only: return
    model.cancel()
    var id: String = model.add_unit(kind)
    if id != "":
        model.fill_unplaced()
        selected_unit = id
        page = (model.units.size()-1)/2
        _save()
    else:
        status.text = "Prototype limit: eight furniture units. No items have been lost."
    add_dialog.hide()

func _remove_unit() -> void:
    if store.read_only: return
    if model.remove_unit(selected_unit):
        selected_unit = model.units[0]["id"]
        _save()
    else: status.text = "Empty this unit before removing it. Keep at least one unit."

func _arrange() -> void:
    if store.read_only: return
    model.arrange()
    _save()

func _leave() -> void:
    _cancel()
    get_tree().change_scene_to_file("res://scenes/start.tscn")

func _cancel() -> void:
    model.cancel()
    queue_redraw()

func _waiting_turn(step: int) -> void:
    waiting_page = clampi(waiting_page+step,0,maxi(0,(model.overflow().size()-1)/8))
    queue_redraw()

func shelf_rect(index: int, shelf: int) -> Rect2:
    var spec: Dictionary = Data.MODELS[model.units[index]["model"]]
    return Rect2(Vector2(274+(index%2)*374,214+shelf*(spec["size"].y*Data.CELL+30)),Vector2(spec["size"])*Data.CELL)

func item_rect(uid: String) -> Rect2:
    var p: Dictionary = model.placements.get(uid,{})
    if p.is_empty():
        var ids: Array = model.overflow()
        var n: int = ids.find(uid)-waiting_page*8
        return Rect2(24+n*139,626,130,42) if n>=0 and n<8 else Rect2()
    for i in range(page*2,mini(page*2+2,model.units.size())):
        if model.units[i]["id"] == p["unit"]:
            return Rect2(shelf_rect(i,p["shelf"]).position+Vector2(p["cell"])*Data.CELL,Vector2(Data.footprint(model.items[uid],p["rotation"]))*Data.CELL)
    return Rect2()

func _hit(at: Vector2) -> String:
    for uid: String in model.items:
        var rect: Rect2 = item_rect(uid)
        if rect.has_area() and rect.has_point(at): return uid
    return ""

func _target(at: Vector2) -> Dictionary:
    for i in range(page*2,mini(page*2+2,model.units.size())):
        var spec: Dictionary = Data.MODELS[model.units[i]["model"]]
        for shelf in range(spec["shelves"]):
            var rect := shelf_rect(i,shelf)
            if rect.has_point(at):
                var offset := Vector2.ZERO
                if model.held != "": offset = grab*Vector2(Data.footprint(model.items[model.held],model.held_rotation))*Data.CELL
                return {"unit":model.units[i]["id"],"shelf":shelf,"cell":Vector2i(((at-rect.position-offset)/Data.CELL+Vector2(0.5,0.5)).floor())}
    return {}

func _input(event: InputEvent) -> void:
    if add_dialog.visible: return
    if event is InputEventMouseMotion:
        pointer = event.position
        _show_info(model.held if model.held != "" else _hit(pointer))
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE: _cancel()
        elif model.held != "" and event.keycode in [KEY_R,KEY_Q,KEY_E]:
            var step: int = -1 if event.keycode == KEY_Q else 1
            model.rotate(step)
            grab = Vector2(grab.y,1.0-grab.x) if step<0 else Vector2(1.0-grab.y,grab.x)
            AudioFeedback.request(self,"handling.rotate")
        elif event.keycode == KEY_TAB:
            page = (page+1)%maxi(1,(model.units.size()+1)/2)
            get_viewport().set_input_as_handled()
            queue_redraw()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        pointer = event.position
        if event.pressed and not store.read_only:
            selected = _hit(pointer)
            if model.begin(selected):
                var rect: Rect2 = item_rect(selected)
                grab = (pointer-rect.position)/rect.size
                motion.snap(pointer,model.held_rotation)
                AudioFeedback.request(self,"handling.pickup")
                _show_info(selected)
        elif not event.pressed and model.held != "":
            var target := _target(pointer)
            var committed: bool = not target.is_empty() and model.drop(target["unit"],target["shelf"],target["cell"])
            model.cancel()
            if committed:
                AudioFeedback.request(self,"handling.putdown")
                _save()
            queue_redraw()

func _show_info(uid: String) -> void:
    if uid == "" or not model.items.has(uid): return
    var item: Dictionary = model.items[uid]
    var shape: Vector2i = item["size"]
    info.text = "%s\n%s\n\n%s\n%s · %d × %d cells\n\n%s"%[item["label"],item["model"],item["owner"],item["condition"],shape.x,shape.y,item["note"]]

func _process(delta: float) -> void:
    if model.held != "":
        motion.step(delta,pointer,model.held_rotation,true)
        queue_redraw()

func _text(text: String,at: Vector2,size: int = 14,color: Color = Color("dce6ec")) -> void:
    draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func _draw_item(uid: String,rect: Rect2,alpha: float = 1.0) -> void:
    var item: Dictionary = model.items[uid]
    var color: Color = Data.COLOURS.get(item["kind"],Color("a0adba"))
    color.a = alpha
    draw_rect(rect.grow(-2),color.darkened(0.65))
    draw_rect(rect.grow(-2),color,false,2)
    if item["category"] == "pc" and rect.size.y>70:
        draw_rect(Rect2(rect.position+Vector2(15,18),Vector2(rect.size.x-30,12)),color.darkened(0.2))
        for y in range(48,int(rect.size.y)-20,10):
            draw_line(rect.position+Vector2(18,y),rect.position+Vector2(rect.size.x-18,y),color.darkened(0.4),3)
    elif rect.size.x>65 and rect.size.y>35:
        for x in range(12,int(rect.size.x)-12,16):
            draw_rect(Rect2(rect.position+Vector2(x,12),Vector2(8,8)),color.darkened(0.25))
    var label: String = "Syringe" if item["kind"] == "syringe" else item["label"]
    if rect.size.x<55:
        # Rotate narrow labels so RAM and slender tools remain readable.
        draw_set_transform(rect.position+Vector2(16,rect.size.y-8),-PI/2)
        var font_size: int = 12
        if ThemeDB.fallback_font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.y-16: font_size = 10
        _text(label,Vector2.ZERO,font_size,color)
        draw_set_transform(Vector2.ZERO)
    else:
        _text(label,rect.position+Vector2(8,rect.size.y-10),13,color)
    if item.get("reserved",false): _text("•",rect.position+Vector2(5,14),15,color)

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("151e27"))
    draw_rect(Rect2(244,112,752,466),Color("1b2933"))
    draw_rect(Rect2(1000,112,264,474),Color("202f3a"))
    for i in range(page*2,mini(page*2+2,model.units.size())):
        var u: Dictionary = model.units[i]
        var spec: Dictionary = Data.MODELS[u["model"]]
        var x: float = 254+(i%2)*374
        draw_rect(Rect2(x,182,10,378),Color("647988"))
        draw_rect(Rect2(x+318,182,10,378),Color("647988"))
        _text("%d / %s"%[i+1,spec["name"]],Vector2(x+8,158),18)
        for shelf in range(spec["shelves"]):
            var rect := shelf_rect(i,shelf)
            draw_rect(rect,Color("111a22"))
            for col in range(spec["size"].x+1):
                draw_line(rect.position+Vector2(col*Data.CELL,0),rect.position+Vector2(col*Data.CELL,rect.size.y),Color("2c3c47"))
            for row in range(spec["size"].y+1):
                draw_line(rect.position+Vector2(0,row*Data.CELL),rect.position+Vector2(rect.size.x,row*Data.CELL),Color("2c3c47"))
            draw_rect(Rect2(rect.position+Vector2(-14,rect.size.y),Vector2(rect.size.x+28,10)),Color("687d8b"))
    for uid: String in model.items:
        var rect := item_rect(uid)
        if rect.has_area(): _draw_item(uid,rect,0.3 if uid == model.held else 1.0)
    if model.overflow().is_empty(): _text("Everything has a home. Extra finds will wait here if the shelves fill up.",Vector2(24,650),15)
    if model.held != "":
        var size: Vector2 = Vector2(Data.footprint(model.items[model.held],model.held_rotation))*Data.CELL
        var target := _target(pointer)
        if not target.is_empty():
            var rect: Rect2
            for i in range(model.units.size()):
                if model.units[i]["id"] == target["unit"]: rect = shelf_rect(i,target["shelf"])
            rect = Rect2(rect.position+Vector2(target["cell"])*Data.CELL,size)
            var valid: bool = model.can_place(model.held,target["unit"],target["shelf"],target["cell"],model.held_rotation)
            draw_rect(rect,Color(0.4,0.9,0.6,0.3) if valid else Color(1,0.4,0.3,0.3))
        # Follow the hand with existing damped pickup motion; logical placement is grid-based.
        _draw_item(model.held,Rect2(motion.center-grab*size+Vector2(0,-4),size),0.88)
