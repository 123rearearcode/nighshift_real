# One persistent room canvas; controls are built once. No per-rack buttons or page rebuilds.
extends Node2D
const Data = preload("res://scripts/storage/storage_data.gd")
const Model = preload("res://scripts/storage/storage_model.gd")
const Sources = preload("res://scripts/storage/storage_sources.gd")
const Store = preload("res://scripts/storage/storage_store.gd")
const Motion = preload("res://scripts/view/part_motion.gd")
const Canvas = preload("res://scripts/storage/room_canvas.gd")
const Navigation = preload("res://scripts/night/night_navigation.gd")
const TicketMenu = preload("res://scripts/night/ticket_menu.gd")
const Ticket = preload("res://scripts/rules/ticket.gd")
const WORKSHOP_SLOT := Rect2(1010,150,242,126)
const STACK_LIFT := Vector2(3, 5)   # 0.59.1 (D185): each laptop on a pile is drawn this much up and left
const ROOM_VIEW := Rect2(24,158,946,414)
var model := Model.new()
var store := Store.new()
var motion := Motion.new()
var waiting_page: int = 0
var pointer := Vector2.ZERO
var arranging: bool = false
var arrange_toggle: Button
var retry_save: Button
var saved_label: Label
var layout_saved: bool = false
var selected_unit: String = ""
var grab := Vector2(0.5,0.5)
var held_furniture: String = ""
var panning: bool = false
var zoom: float = 1.0
var pan := Vector2.ZERO
var summary: Label
var info: Label
var workshop_label: Label
var workshop_button: Button
var workshop_pending: bool = false
var status: Label
var room_clip: Control
var canvas: Node2D
var add_dialog: PopupPanel
var edit_buttons: Array[Button] = []
var choice_buttons: Array[Button] = []
var ticket_badges: Dictionary = {}   # ticket id -> "READY" / "CALLED" (D134), refreshed after every change

func _ready() -> void:
    if not GameState.job.get("hardware_trial",{}).get("night_session",{}).is_empty(): NightSession.ensure(GameState)
    model.setup(Sources.collect(GameState),store.read())
    selected_unit = model.units[0]["id"]
    _label("STOCK ROOM",Vector2(210,24),Vector2(760,36),26)
    Navigation.exit(self,"Workshop",Navigation.WORKSHOP)   # 0.53.0 (D161): the stock room opens off the workshop
    summary = _label("",Vector2(24,62),Vector2(946,32),16)
    _label("v%s · room storage"%GameState.game_version(),Vector2(1008,72),Vector2(244,24),13)
    arrange_toggle = _button("Arrange room",Rect2(24,108,174,36),func() -> void: _set_arranging(not arranging))
    arrange_toggle.toggle_mode = true
    _button("Fit furniture",Rect2(210,108,150,36),_fit_used)
    _button("Entire room",Rect2(372,108,144,36),_fit_room)
    _button("−",Rect2(528,108,44,36),func() -> void: _zoom_at(zoom/1.25,ROOM_VIEW.get_center()))
    _button("+",Rect2(584,108,44,36),func() -> void: _zoom_at(zoom*1.25,ROOM_VIEW.get_center()))
    _label("ROOM · 4 × 2 bays",Vector2(812,112),Vector2(158,28),14)
    room_clip = Control.new()
    room_clip.position = ROOM_VIEW.position
    room_clip.size = ROOM_VIEW.size
    room_clip.clip_contents = true
    room_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(room_clip)
    canvas = Canvas.new()
    canvas.view = self
    room_clip.add_child(canvas)
    _label("WORKSHOP SLOT",Vector2(1010,120),Vector2(242,26),17)
    workshop_label = _label("",Vector2(1020,160),Vector2(222,106),15)
    workshop_button = _button("Resume work",Rect2(1010,286,242,34),_open_workshop)
    _label("DETAILS",Vector2(1010,326),Vector2(242,24),15)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(1010,354)
    scroll.size = Vector2(242,88)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    info = Label.new()
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.custom_minimum_size = Vector2(220,0)
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_theme_font_size_override("font_size",15)
    info.text = "Drag parts to shelves. R / E rotates, Q turns back.\n\nWheel zooms; middle-drag pans. Choose Arrange room to move furniture titles into empty bays.\n\nFit furniture shows every owned unit; Entire room shows all eight bays."
    scroll.add_child(info)
    edit_buttons.append(_button("+ Add furniture",Rect2(1010,450,242,38),_open_add))
    edit_buttons.append(_button("Remove empty",Rect2(1010,496,242,38),_remove_unit))
    edit_buttons.append(_button("Auto-pack shelves",Rect2(1010,542,242,38),_arrange))
    saved_label = _label("Changes save automatically",Vector2(1010,450),Vector2(242,66),15)
    retry_save = _button("Retry saving layout",Rect2(1010,542,242,38),_save)
    _label("WAITING FOR SPACE",Vector2(24,592),Vector2(400,26),15)
    _button("‹",Rect2(1150,588,45,30),func() -> void: _waiting_turn(-1))
    _button("›",Rect2(1203,588,45,30),func() -> void: _waiting_turn(1))
    status = _label("",Vector2(24,677),Vector2(1230,36),14)
    _make_add_dialog()
    get_window().focus_exited.connect(_cancel)
    _refresh_badges()
    _fit_used()
    _sync_ui()

func _label(text: String,at: Vector2,area: Vector2,size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.position = at
    label.size = area
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size",size)
    add_child(label)
    return label

func _button(text: String,rect: Rect2,action: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.position = rect.position
    button.size = rect.size
    button.pressed.connect(action)
    button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
    add_child(button)
    return button

func _make_add_dialog() -> void:
    add_dialog = PopupPanel.new()
    add_child(add_dialog)
    var margin := MarginContainer.new()
    for side: String in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
    add_dialog.add_child(margin)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",12)
    margin.add_child(box)
    var title := Label.new()
    title.text = "Add furniture · free in this prototype"
    box.add_child(title)
    for kind: String in Data.MODELS:
        var spec: Dictionary = Data.MODELS[kind]
        var button := Button.new()
        button.text = spec["name"]+"\n"+spec["hint"]
        button.custom_minimum_size = Vector2(460,58)
        button.pressed.connect(_add_unit.bind(kind))
        button.pressed.connect(func() -> void: AudioFeedback.request(self,"ui.click"))
        box.add_child(button)
        choice_buttons.append(button)

func _open_add() -> void:
    if store.read_only or not arranging: return
    _cancel()
    var full: bool = model.free_room_cell() == Vector2i(-1,-1)
    for button: Button in choice_buttons: button.disabled = full
    if full:
        status.text = "Room full: all eight bays are occupied. Remove an empty furniture unit first."
        return
    add_dialog.popup_centered()

func _sync_ui() -> void:
    waiting_page = clampi(waiting_page,0,maxi(0,floori((model.overflow().size()-1)/8.0)))
    var counts := {"pc":0,"tool":0,"part":0}
    for item: Dictionary in model.items.values(): counts[item["category"]] += 1
    summary.text = "%d PC · %d tools · %d parts   |   Room %d / 8 bays   |   %d waiting for space   |   %d under the counter   |   %d in your backpack"%[counts.pc,counts.tool,counts.part,model.units.size(),model.overflow().size(),model.in_unit(Data.COUNTER_ID).size(),model.in_unit("backpack").size()]
    status.text = store.status if store.status != "" else ("Arrange room: drag titles into empty bays; furniture is free in this trial." if arranging else "Drag a PC into the workshop slot, or arrange your inventory. Wheel zooms; middle-drag pans.")
    var failed: bool = store.status.contains("not saved") and not store.read_only
    for button: Button in edit_buttons:
        button.disabled = store.read_only
        button.visible = arranging and not (failed and button.text == "Auto-pack shelves")
    arrange_toggle.disabled = store.read_only
    arrange_toggle.set_pressed_no_signal(arranging)
    arrange_toggle.text = "Done arranging" if arranging else "Arrange room"
    retry_save.visible = failed
    saved_label.visible = not arranging
    saved_label.text = "Layout saved" if layout_saved else "Changes save automatically"
    var active: String = _workshop_uid()
    workshop_label.text = "Drop a PC here to choose it.\n\n"+("On bench: "+model.items[active]["model"] if active != "" else "No customer PC available")
    workshop_button.disabled = arranging or store.read_only or NightSession.read_only or active == ""
    _redraw()

# A shelf allocation stays reserved while the same physical PC is on the workbench.
# The slot is a reference to GameState/NightSession, never a copied PC or a second inventory.
func _workshop_uid() -> String:
    for uid: String in model.items:
        if model.items[uid]["category"] == "pc" and model.items[uid]["source_uid"] == str(GameState.job.get("id","")): return uid
    return ""

func _choose_workshop_pc(uid: String) -> bool:
    if store.read_only or workshop_pending or arranging: return false
    if store.status.contains("not saved"):
        status.text = "Layout not saved. Retry saving layout before leaving the room."
        return false
    var canonical: Dictionary = Sources.collect(GameState).get(uid,{})
    if canonical.get("category","") != "pc":
        status.text = "The workshop slot accepts a whole customer PC, not a part or tool."
        return false
    var ticket_id: String = str(canonical["source_uid"])
    if not NightSession.ensure(GameState) or not NightSession.switch_pc(GameState,ticket_id):
        status.text = NightSession.status if NightSession.status != "" else "This PC cannot be selected. Refresh the room and try again."
        return false
    if not NightSession.checkpoint(GameState):
        status.text = NightSession.status
        return false
    _refresh()
    return true

func _open_workshop() -> void:
    if _choose_workshop_pc(_workshop_uid()): _queue_workshop()

func _queue_workshop() -> void:
    _cancel()
    workshop_pending = true
    set_process_input(false)
    call_deferred("_enter_workshop")

func _enter_workshop() -> void:
    if is_inside_tree(): Navigation.commit(self,Navigation.Memory.workbench_path(GameState))

func _set_arranging(enabled: bool) -> void:
    _cancel()
    add_dialog.hide()
    arranging = enabled and not store.read_only
    _sync_ui()

func _save() -> void:
    layout_saved = store.write(model)
    _sync_ui()
# D134: pickup stickers drawn on room PCs, read from every ticket of tonight.
func _refresh_badges() -> void:
    ticket_badges.clear()
    for job: Dictionary in NightSession.jobs(GameState):
        var badge: String = Ticket.badge(job)
        if badge != "": ticket_badges[str(job.get("id",""))] = badge

func _ticket_id(uid: String) -> String:
    if not model.items.has(uid) or model.items[uid]["category"] != "pc": return ""
    return str(model.items[uid]["source_uid"])

# D134: right-click on a room PC opens the same pickup menu as the workbench ticket.
func _open_ticket_menu(uid: String, at: Vector2) -> PopupMenu:
    var id: String = _ticket_id(uid)
    if id == "": return null
    return TicketMenu.popup(self,id,at,_ticket_done.bind(uid))

func _ticket_action(uid: String, action: String) -> Dictionary:
    var id: String = _ticket_id(uid)
    if id == "": return {"ok":false,"message":"Only a customer PC has a ticket."}
    return TicketMenu.act(self,id,action,_ticket_done.bind(uid))

func _ticket_done(result: Dictionary, uid: String) -> void:
    status.text = str(result.get("message",""))
    _refresh_badges()
    _show_info(uid)
    _redraw()

func _refresh() -> void:
    _cancel()
    _refresh_badges()
    model.setup(Sources.collect(GameState),model.snapshot())
    if model.unit(selected_unit).is_empty(): selected_unit = model.units[0]["id"]
    _sync_ui()
func _add_unit(kind: String) -> void:
    if store.read_only or not arranging: return
    _cancel()
    var id: String = model.add_unit(kind)
    add_dialog.hide()
    if id == "":
        status.text = "No free bay or invalid furniture. Your items are unchanged."
        return
    model.fill_unplaced()
    selected_unit = id
    _fit_used()
    _save()
func _remove_unit() -> void:
    if store.read_only or not arranging: return
    _cancel()
    if model.remove_unit(selected_unit):
        selected_unit = model.units[0]["id"]
        _fit_used()
        _save()
    else: status.text = "Click an empty furniture title bar first. Occupied units and the last unit cannot be removed."
func _arrange() -> void:
    if store.read_only or not arranging: return
    _cancel()
    model.arrange()
    _save()
func _leave() -> void:
    _navigate(Navigation.WORKSHOP)
func _navigate(path: String) -> bool:
    _cancel()
    if store.status.contains("not saved") and not store.read_only:
        status.text = "Layout not saved. Retry saving layout before leaving the room."
        return false
    if not NightSession.checkpoint(GameState):
        status.text = NightSession.status
        return false
    return Navigation.commit(self,path)
func _cancel() -> void:
    model.cancel()
    held_furniture = ""
    panning = false
    _redraw()
func _waiting_turn(step: int) -> void:
    waiting_page = clampi(waiting_page+step,0,maxi(0,floori((model.overflow().size()-1)/8.0)))
    _redraw()

func _bay_rect(cell: Vector2i) -> Rect2:
    return Rect2(Vector2(cell)*Data.BAY_STRIDE+Vector2(10,10),Data.BAY_SIZE)
func _unit_rect(index: int) -> Rect2:
    return _bay_rect(model.units[index]["room_cell"])
func _world_shelf(index: int,shelf: int) -> Rect2:
    var spec: Dictionary = Data.MODELS[model.units[index]["model"]]
    return Rect2(_unit_rect(index).position+Vector2(30,52+shelf*(spec["size"].y*Data.CELL+20)),Vector2(spec["size"])*Data.CELL)
func to_screen(at: Vector2) -> Vector2:
    return ROOM_VIEW.position+pan+at*zoom
func to_world(at: Vector2) -> Vector2:
    return (at-ROOM_VIEW.position-pan)/zoom
func shelf_rect(index: int,shelf: int) -> Rect2:
    var rect := _world_shelf(index,shelf)
    return Rect2(to_screen(rect.position),rect.size*zoom)
func header_rect(index: int) -> Rect2:
    return Rect2(to_screen(_unit_rect(index).position),Vector2(Data.BAY_SIZE.x,34)*zoom)
func _world_item(uid: String) -> Rect2:
    var p: Dictionary = model.placements.get(uid,{})
    if p.is_empty(): return Rect2()
    for i in range(model.units.size()):
        if model.units[i]["id"] == p["unit"]:
            return Rect2(_world_shelf(i,p["shelf"]).position+Vector2(p["cell"])*Data.CELL-STACK_LIFT*model.level(uid),Vector2(Data.footprint(model.items[uid],p["rotation"]))*Data.CELL)   # 0.59.1: a pile reads as a pile
    return Rect2()
# B56: only items on the room's own furniture are drawn in it. Items under the counter or in the backpack are
# placed in units that are not in the room (no world rectangle) and used to be drawn as a mark at the origin.
func room_drawn_items() -> Array:
    var out: Array = []
    for uid: String in model.placements:
        if _world_item(uid).has_area(): out.append(uid)
    out.sort_custom(func(a: String, b: String) -> bool: return model.level(a) < model.level(b))   # 0.59.1: piles bottom first
    return out
func item_rect(uid: String) -> Rect2:
    var rect := _world_item(uid)
    if rect.has_area(): return Rect2(to_screen(rect.position),rect.size*zoom)
    var n: int = model.overflow().find(uid)-waiting_page*8
    return Rect2(24+n*139,626,130,42) if n>=0 and n<8 else Rect2()
func _hit(at: Vector2) -> String:
    var order: Array = model.items.keys()   # 0.59.1: the top of a pile is under the pointer first
    order.sort_custom(func(a: String, b: String) -> bool: return model.level(a) > model.level(b))
    for uid: String in order:
        if model.placements.has(uid) and not ROOM_VIEW.has_point(at): continue
        var rect := item_rect(uid)
        if rect.has_area() and rect.has_point(at): return uid
    return ""
func _target(at: Vector2) -> Dictionary:
    if not ROOM_VIEW.has_point(at): return {}
    var point := to_world(at)
    for i in range(model.units.size()):
        var spec: Dictionary = Data.MODELS[model.units[i]["model"]]
        for shelf in range(spec["shelves"]):
            var rect := _world_shelf(i,shelf)
            if rect.has_point(point):
                var offset := grab*Vector2(Data.footprint(model.items[model.held],model.held_rotation))*Data.CELL if model.held != "" else Vector2.ZERO
                return {"unit":model.units[i]["id"],"shelf":shelf,"cell":Vector2i(((point-rect.position-offset)/Data.CELL+Vector2(0.5,0.5)).floor())}
    return {}
func _room_cell(at: Vector2) -> Vector2i:
    return Vector2i((to_world(at)/Data.BAY_STRIDE).floor())

func _fit(bounds: Rect2) -> void:
    zoom = clampf(minf((ROOM_VIEW.size.x-28)/bounds.size.x,(ROOM_VIEW.size.y-20)/bounds.size.y),0.35,1.8)
    pan = ROOM_VIEW.size*0.5-bounds.get_center()*zoom
    _clamp_pan()
    _redraw()
func _fit_used() -> void:
    if model.units.is_empty(): return
    var bounds := _unit_rect(0)
    for i in range(1,model.units.size()): bounds = bounds.merge(_unit_rect(i))
    _fit(bounds)
func _fit_room() -> void:
    _fit(Rect2(Vector2.ZERO,Vector2(Data.ROOM_SIZE)*Data.BAY_STRIDE))
func _zoom_at(value: float,at: Vector2) -> void:
    var anchor := to_world(at)
    zoom = clampf(value,0.35,1.8)
    pan = at-ROOM_VIEW.position-anchor*zoom
    _clamp_pan()
    _redraw()
func _clamp_pan() -> void:
    var room_size: Vector2 = Vector2(Data.ROOM_SIZE)*Data.BAY_STRIDE*zoom
    pan.x = clampf(pan.x,minf(20,ROOM_VIEW.size.x-room_size.x-20),maxf(20,(ROOM_VIEW.size.x-room_size.x)*0.5))
    pan.y = clampf(pan.y,minf(20,ROOM_VIEW.size.y-room_size.y-20),maxf(20,(ROOM_VIEW.size.y-room_size.y)*0.5))
func _redraw() -> void:
    if is_instance_valid(canvas):
        canvas.position = pan
        canvas.scale = Vector2.ONE*zoom
        canvas.queue_redraw()
    queue_redraw()

func _input(event: InputEvent) -> void:
    if is_instance_valid(add_dialog) and add_dialog.visible: return
    if event is InputEventMouseMotion:
        if panning: pan += event.position-pointer; _clamp_pan()
        pointer = event.position
        _show_info(model.held if model.held != "" else _hit(pointer))
        _redraw()
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE: _cancel()
        elif model.held != "" and event.keycode in [KEY_R,KEY_Q,KEY_E]:
            var turn: int = -1 if event.keycode == KEY_Q else 1
            model.rotate(turn)
            AudioFeedback.request(self,"handling.rotate")
            grab = Vector2(grab.y,1.0-grab.x) if turn<0 else Vector2(1.0-grab.y,grab.x)
            _redraw()
    elif event is InputEventMouseButton:
        pointer = event.position
        if event.button_index == MOUSE_BUTTON_MIDDLE:
            panning = event.pressed and ROOM_VIEW.has_point(pointer)
        elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and ROOM_VIEW.has_point(pointer):
            _zoom_at(zoom*(1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1/1.15),pointer)
        elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and model.held == "" and held_furniture == "" and not arranging and ROOM_VIEW.has_point(pointer):
            var clicked: String = _hit(pointer)
            if _ticket_id(clicked) != "": _open_ticket_menu(clicked,pointer)
        elif event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed and not store.read_only:
                if arranging and ROOM_VIEW.has_point(pointer) and model.held == "":
                    for i in range(model.units.size()):
                        if header_rect(i).has_point(pointer):
                            selected_unit = model.units[i]["id"]
                            held_furniture = selected_unit
                            info.text = Data.MODELS[model.units[i]["model"]]["name"]+"\nDrag this title bar to an empty room bay.\n\nOccupied furniture cannot be removed."
                            _redraw()
                            return
                var uid := _hit(pointer)
                if uid != "" and model.blocked(uid) != "":   # 0.59.1: a laptop lies on it
                    info.text = model.blocked(uid)
                    _redraw()
                    return
                if model.begin(uid):
                    var rect := item_rect(uid)
                    grab = (pointer-rect.position)/rect.size
                    motion.snap(pointer,model.held_rotation)
                    AudioFeedback.request(self,"handling.pickup")
                    _show_info(uid)
            elif not event.pressed:
                if held_furniture != "":
                    var destination: Vector2i = _room_cell(pointer)
                    var changed: bool = model.unit(held_furniture)["room_cell"] != destination
                    if ROOM_VIEW.has_point(pointer) and changed and model.move_unit(held_furniture,destination): _save()
                    held_furniture = ""
                elif model.held != "":
                    if WORKSHOP_SLOT.has_point(pointer):
                        var uid: String = model.held
                        model.cancel()
                        if _choose_workshop_pc(uid): _queue_workshop()
                        _redraw()
                        return
                    var target := _target(pointer)
                    var committed: bool = not target.is_empty() and model.drop(target["unit"],target["shelf"],target["cell"])
                    model.cancel()
                    if committed:
                        AudioFeedback.request(self,"handling.putdown")
                        _save()
                _redraw()

func _show_info(uid: String) -> void:
    if not model.items.has(uid): return
    var item: Dictionary = model.items[uid]
    var shape: Vector2i = item["size"]
    info.text = "%s\n%s\n\n%s\n%s · %d × %d cells\n\n%s"%[item["label"],item["model"],item["owner"],item["condition"],shape.x,shape.y,item["note"]]
    if item["category"] == "pc":
        var job: Dictionary = NightSession.ticket_job(GameState,str(item["source_uid"]))
        if not job.is_empty(): info.text += "\n\nTicket: %s. Right-click for pickup."%Ticket.status_text(job)
func _process(delta: float) -> void:
    if model.held != "" or held_furniture != "":
        if ROOM_VIEW.has_point(pointer):
            var move := Vector2.ZERO
            if pointer.x<ROOM_VIEW.position.x+20: move.x = 180
            elif pointer.x>ROOM_VIEW.end.x-20: move.x = -180
            if pointer.y<ROOM_VIEW.position.y+20: move.y = 180
            elif pointer.y>ROOM_VIEW.end.y-20: move.y = -180
            pan += move*minf(delta,0.05)
            _clamp_pan()
        if model.held != "": motion.step(delta,pointer,model.held_rotation,true)
        _redraw()
func _text(text: String,at: Vector2,size: int = 14,color: Color = Color("dce6ec"),painter: CanvasItem = self) -> void:
    painter.draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func _draw_item(uid: String,rect: Rect2,alpha: float = 1.0, painter: CanvasItem = self) -> void:
    var item: Dictionary = model.items[uid]
    if uid == _workshop_uid() and painter != self:
        painter.draw_rect(rect.grow(-2),Color("72959e"),false,1)
        _text("ON BENCH",rect.position+Vector2(4,16),11,Color("72959e"),painter)
        return
    var color: Color = Data.COLOURS.get(item["kind"],Color("a0adba"))
    color.a = alpha
    if model.placements.has(uid) and model.level(uid) > 0: painter.draw_rect(rect.grow(-2).grow_individual(-2,-2,4,6),Color(0,0,0,0.35*alpha))   # 0.59.1: its shadow on the pile
    painter.draw_rect(rect.grow(-2),color.darkened(0.65))
    painter.draw_rect(rect.grow(-2),color,false,2)
    if bool(item.get("stackable",false)):   # 0.59.1 (D185): a closed laptop: hinge along the back, badge on the lid
        painter.draw_rect(Rect2(rect.position+Vector2(8,6),Vector2(rect.size.x-16,6)),color.darkened(0.35))
        painter.draw_rect(Rect2(rect.get_center()-Vector2(7,5),Vector2(14,10)),color.darkened(0.25))
    elif item["category"] == "pc" and rect.size.y>70:
        painter.draw_rect(Rect2(rect.position+Vector2(15,18),Vector2(rect.size.x-30,12)),color.darkened(0.2))
        for y in range(48,int(rect.size.y)-20,10):
            painter.draw_line(rect.position+Vector2(18,y),rect.position+Vector2(rect.size.x-18,y),color.darkened(0.4),3)
    elif rect.size.x>65 and rect.size.y>35:
        for x in range(12,int(rect.size.x)-12,16):
            painter.draw_rect(Rect2(rect.position+Vector2(x,12),Vector2(8,8)),color.darkened(0.25))
    var label: String = "SYR" if item["kind"] == "syringe" else item["label"]
    var portrait: bool = rect.size.x<28 and rect.size.y>rect.size.x
    var available: float = (rect.size.y if portrait else rect.size.x)-8
    var font_size: int = 13
    while font_size>8 and ThemeDB.fallback_font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>available: font_size -= 1
    while label.length()>1 and ThemeDB.fallback_font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>available: label = label.left(label.length()-1)
    if portrait:
        painter.draw_set_transform(rect.position+Vector2(rect.size.x-4,rect.size.y-4),-PI/2)
        _text(label,Vector2.ZERO,font_size,color,painter)
        painter.draw_set_transform(Vector2.ZERO)
    else:
        _text(label,rect.position+Vector2(4,rect.size.y-4),font_size,color,painter)
    if item.get("reserved",false): _text("•",rect.position+Vector2(5,14),15,color,painter)
    var badge: String = str(ticket_badges.get(str(item.get("source_uid","")),"")) if item["category"] == "pc" else ""
    if badge != "":
        # D134: the ready sticker (yellow) or the called tag (green), top-right of the case.
        var tag_color: Color = Color("f2c94c") if badge == "READY" else Color("6fcf97")
        var tag := Rect2(rect.end.x-58,rect.position.y+4,54,18)
        painter.draw_rect(tag,tag_color)
        painter.draw_rect(tag,tag_color.darkened(0.5),false,1)
        _text(badge,tag.position+Vector2(4,14),11,Color("1d232b"),painter)

func draw_room(painter: Node2D) -> void:
    painter.draw_rect(Rect2(Vector2.ZERO,Vector2(Data.ROOM_SIZE)*Data.BAY_STRIDE),Color("182730"))
    for y in range(Data.ROOM_SIZE.y):
        for x in range(Data.ROOM_SIZE.x):
            var bay := _bay_rect(Vector2i(x,y))
            painter.draw_rect(bay,Color("20333e"))
            painter.draw_rect(bay,Color("38515e"),false,1)
            _text("%d · EMPTY BAY"%(y*Data.ROOM_SIZE.x+x+1),bay.position+Vector2(16,28),15,Color("67818d"),painter)
    for i in range(model.units.size()):
        var unit: Dictionary = model.units[i]
        var spec: Dictionary = Data.MODELS[unit["model"]]
        var bay := _unit_rect(i)
        painter.draw_rect(bay,Color("253b47"))
        painter.draw_rect(Rect2(bay.position,Vector2(bay.size.x,34)),Color("48616b") if selected_unit == unit["id"] else Color("334b58"))
        _text("%s · %s"%[str(unit["id"]).trim_prefix("storage_"),spec["name"]],bay.position+Vector2(12,24),17,Color("e1e8e9"),painter)
        painter.draw_rect(Rect2(bay.position+Vector2(14,44),Vector2(9,384)),Color("6a7e88"))
        painter.draw_rect(Rect2(bay.position+Vector2(257,44),Vector2(9,384)),Color("6a7e88"))
        for shelf in range(spec["shelves"]):
            var rect := _world_shelf(i,shelf)
            painter.draw_rect(rect,Color("111c24"))
            for col in range(spec["size"].x+1): painter.draw_line(rect.position+Vector2(col*Data.CELL,0),rect.position+Vector2(col*Data.CELL,rect.size.y),Color("2d414b"))
            for row in range(spec["size"].y+1): painter.draw_line(rect.position+Vector2(0,row*Data.CELL),rect.position+Vector2(rect.size.x,row*Data.CELL),Color("2d414b"))
            painter.draw_rect(Rect2(rect.position+Vector2(-12,rect.size.y),Vector2(rect.size.x+24,8)),Color("74868e"))
    for uid: String in room_drawn_items():
        _draw_item(uid,_world_item(uid),0.3 if uid == model.held else 1.0,painter)
    if model.held != "":
        var target := _target(pointer)
        if not target.is_empty():
            for i in range(model.units.size()):
                if model.units[i]["id"] != target["unit"]: continue
                var rect := Rect2(_world_shelf(i,target["shelf"]).position+Vector2(target["cell"])*Data.CELL,Vector2(Data.footprint(model.items[model.held],model.held_rotation))*Data.CELL)
                var valid: bool = model.can_place(model.held,target["unit"],target["shelf"],target["cell"],model.held_rotation)
                painter.draw_rect(rect,Color(0.4,0.9,0.6,0.3) if valid else Color(1,0.4,0.3,0.3))
    if held_furniture != "" and ROOM_VIEW.has_point(pointer):
        var cell := _room_cell(pointer)
        if Rect2i(Vector2i.ZERO,Data.ROOM_SIZE).has_point(cell):
            painter.draw_rect(_bay_rect(cell),Color(0.4,0.9,0.6,0.3) if model.can_place_furniture(held_furniture,cell) else Color(1,0.4,0.3,0.3))
func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("151e27"))
    draw_rect(ROOM_VIEW.grow(2),Color("48606b"))
    draw_rect(Rect2(1000,112,264,474),Color("202f3a"))
    var valid: bool = model.held != "" and model.items[model.held]["category"] == "pc" and not NightSession.read_only
    draw_rect(WORKSHOP_SLOT,Color("193c36") if valid else Color("14232d"))
    draw_rect(WORKSHOP_SLOT,Color("72d9ad") if valid else Color("6c8a98"),false,2)
    for uid: String in model.overflow():
        var rect := item_rect(uid)
        if rect.has_area(): _draw_item(uid,rect,0.3 if uid == model.held else 1.0)
    if model.overflow().is_empty(): _text("Everything has shelf space. New items wait here if the furniture fills up.",Vector2(24,650),15)
    if model.held != "":
        var size := Vector2(Data.footprint(model.items[model.held],model.held_rotation))*Data.CELL*zoom
        _draw_item(model.held,Rect2(motion.center-grab*size,size),0.9)
