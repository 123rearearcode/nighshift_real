# VIEW (0.58.3, D173): the open cable box, seen from above. Presentation and feel only; the rules
# (knots, ties, breaking, moving) are scripts/rules/cable_box.gd and the file is scripts/state/cable_store.gd.
# User, 27 November 2026: the box is "openable" and reveals "the cables in their state"; the untangling is
# "more physics-based".
#
# Each loose cable is a verlet rope (a chain of points held at a fixed spacing, with floor friction and the
# box walls). Grab a cable by one of its plugs and pull. A knot is where two cables are caught together:
# pulled by the end it can slip out of, the cable slides through the knot and comes free; pulled by its
# other end, the knot only tightens (it turns red) and, pulled too hard, the cable snaps. Tied cables lie
# coiled on the left and never tangle. Placeholder drawings until the cable art is approved (D167).
extends Control

signal closed
signal carry_requested

const CableBox = preload("res://scripts/rules/cable_box.gd")
const CableStore = preload("res://scripts/state/cable_store.gd")

const BOX := Rect2(150, 96, 790, 500)            # the box, outer rim
const FLOOR := Rect2(336, 118, 584, 456)          # where the loose cables lie
const SHELF := Rect2(172, 118, 148, 456)          # tied cables, coiled
const SIDE := Rect2(962, 96, 300, 500)            # the controls
const SEG: float = 15.0
const GRAB_RADIUS: float = 28.0
const PICK_RADIUS: float = 12.0
const FRICTION: float = 0.82
const ITERATIONS: int = 12
const PULL_START: float = 1.08                    # how far past its rope length the plug must be pulled
const FULL_PULL: float = 0.2                      # ... and how much further counts as a full pull
const MAX_STRETCH: float = 1.35                   # a cable goes taut; it does not stretch like elastic
const SLIDE_RATE: float = 0.55                    # fraction of the cable per second at a full pull
const STRAIN_RATE: float = 0.45                   # of BREAK_STRAIN per second at a full pull (about 3 s to snap)
const RELAX_RATE: float = 0.12
const FREE_AT: float = 0.03

var gs: Node
var state: Dictionary = {}
var ropes: Dictionary = {}       # cable id -> {"p": PackedVector2Array, "o": PackedVector2Array, "cut": int}
var anchors: Array = []          # one point per knot, in step with state["knots"]
var held_id: String = ""
var held_end: int = -1           # 0 = first plug, 1 = last plug
var held_at := Vector2.ZERO      # where the held plug is (kept within the cable's reach of its knots)
var held_target := Vector2.ZERO  # where the mouse is
var pulling: Dictionary = {}     # knot index -> pull strength this step (for drawing)
var selected: String = ""
var title: Label
var info: Label
var note: Label
var buttons: Dictionary = {}


func open(game_state: Node, box_state: Dictionary) -> void:
    gs = game_state
    state = box_state
    name = "CableBoxView"
    position = Vector2.ZERO
    size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 60
    title = _label("THE CABLE BOX", SIDE.position + Vector2(14, 10), Vector2(SIDE.size.x - 28, 30), 20)
    info = _label("", SIDE.position + Vector2(14, 46), Vector2(SIDE.size.x - 28, 110), 14)
    note = _label("Grab a cable by a plug and pull. A knot gives way only from one side: pull the other end and it tightens.", SIDE.position + Vector2(14, 160), Vector2(SIDE.size.x - 28, 80), 13)
    var y: float = SIDE.position.y + 250
    for spec: Array in [["zip", "Tie with a zip tie"], ["velcro", "Tie with a velcro strap"], ["untie", "Untie"], ["throw", "Throw the broken cable away"], ["carry", "Carry the box"], ["close", "Close the box"]]:
        var b := Button.new()
        b.name = "CableBox_" + str(spec[0])
        b.text = str(spec[1])
        b.position = Vector2(SIDE.position.x + 14, y)
        b.size = Vector2(SIDE.size.x - 28, 34)
        b.add_theme_font_size_override("font_size", 15)
        b.pressed.connect(_on_button.bind(str(spec[0])))
        add_child(b)
        buttons[str(spec[0])] = b
        y += 40
    _build_ropes()
    for i in range(90): step(1.0 / 60.0)     # let the cables settle into their knots
    _refresh()
    queue_redraw()


func _label(text: String, at: Vector2, area: Vector2, font_size: int) -> Label:
    var l := Label.new()
    l.text = text
    l.position = at
    l.size = area
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", Color("e8e2d0"))
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(l)
    return l


# ---- the ropes ----

func _build_ropes() -> void:
    ropes.clear()
    for c: Dictionary in state["cables"]:
        if c["tie"] == "": ropes[str(c["id"])] = _lay(c)
    _place_anchors()


# A cable laid out as a wandering line across the box floor (the same each time for the same box).
func _lay(c: Dictionary) -> Dictionary:
    var n: int = int(CableBox.KINDS[c["kind"]]["points"])
    var rng := RandomNumberGenerator.new()
    rng.seed = hash("%s:%d" % [c["id"], int(state.get("moves", 0))])
    var at := Vector2(rng.randf_range(FLOOR.position.x + 40, FLOOR.end.x - 40), rng.randf_range(FLOOR.position.y + 40, FLOOR.end.y - 40))
    var heading: float = rng.randf() * TAU
    var p := PackedVector2Array()
    for i in range(n):
        p.append(at)
        heading += rng.randf_range(-0.5, 0.5)
        var next: Vector2 = at + Vector2.from_angle(heading) * SEG
        if not FLOOR.grow(-10).has_point(next):
            heading += PI * 0.6
            next = at + Vector2.from_angle(heading) * SEG
        at = next.clamp(FLOOR.position + Vector2.ONE * 6, FLOOR.end - Vector2.ONE * 6)
    return {"p": p, "o": p.duplicate(), "cut": n / 2 if c["broken"] else -1}


func _place_anchors() -> void:
    anchors.clear()
    for k: Dictionary in state["knots"]:
        var a: Vector2 = _knot_point(k, "a")
        var b: Vector2 = _knot_point(k, "b")
        anchors.append((a + b) * 0.5)


func _knot_index(k: Dictionary, which: String) -> int:
    var rope: Dictionary = ropes.get(str(k[which]), {})
    if rope.is_empty(): return -1
    return clampi(int(round(float(k["at_" + which]) * ((rope["p"] as PackedVector2Array).size() - 1))), 0, (rope["p"] as PackedVector2Array).size() - 1)


func _knot_point(k: Dictionary, which: String) -> Vector2:
    var i: int = _knot_index(k, which)
    return (ropes[str(k[which])]["p"] as PackedVector2Array)[i] if i >= 0 else FLOOR.get_center()


# One physics step. Called every frame; tests call it directly.
func step(dt: float) -> void:
    pulling.clear()
    if held_id != "": held_at = _reach(held_target)
    for id: String in ropes:
        var r: Dictionary = ropes[id]
        var p: PackedVector2Array = r["p"]
        var o: PackedVector2Array = r["o"]
        for i in range(p.size()):
            var v: Vector2 = (p[i] - o[i]) * FRICTION
            o[i] = p[i]
            p[i] += v
        r["p"] = p
        r["o"] = o
    for it in range(ITERATIONS):
        for id: String in ropes:
            var r: Dictionary = ropes[id]
            var p: PackedVector2Array = r["p"]
            var cut: int = int(r["cut"])
            for i in range(p.size() - 1):
                if i == cut: continue                       # a snapped cable falls apart at its break
                var d: Vector2 = p[i + 1] - p[i]
                var length: float = maxf(d.length(), 0.001)
                var fix: Vector2 = d * ((length - SEG) / length) * 0.5
                p[i] += fix
                p[i + 1] -= fix
            if id == held_id: p[0 if held_end == 0 else p.size() - 1] = held_at
            for i in range(p.size()): p[i] = p[i].clamp(FLOOR.position, FLOOR.end)
            r["p"] = p
        for k_i in range(anchors.size()):                   # a knot holds both cables at one spot
            var k: Dictionary = state["knots"][k_i]
            for which: String in ["a", "b"]:
                var i: int = _knot_index(k, which)
                if i < 0: continue
                var p: PackedVector2Array = ropes[str(k[which])]["p"]
                if str(k[which]) == held_id and i == (0 if held_end == 0 else p.size() - 1): continue
                p[i] = p[i].lerp(anchors[k_i], 0.6)
                ropes[str(k[which])]["p"] = p
    if held_id == "":                                       # knots settle with the cables, but hold still while pulled
        for k_i in range(anchors.size()):
            var k: Dictionary = state["knots"][k_i]
            anchors[k_i] = (anchors[k_i] as Vector2).lerp((_knot_point(k, "a") + _knot_point(k, "b")) * 0.5, 0.02)
    if held_id != "": _pull(dt)
    CableBox.relax(state, RELAX_RATE * dt)
    queue_redraw()


# The plug can go no further from each knot than the cable between them allows (a little give, then taut).
func _reach(target: Vector2) -> Vector2:
    var at: Vector2 = target.clamp(FLOOR.position, FLOOR.end)
    var n: int = (ropes[held_id]["p"] as PackedVector2Array).size()
    for k_i in CableBox.knots_of(state, held_id):
        var k: Dictionary = state["knots"][k_i]
        var which: String = "a" if k["a"] == held_id else "b"
        var reach: float = maxf(absf(_knot_index(k, which) - (0 if held_end == 0 else n - 1)) * SEG, SEG) * MAX_STRETCH
        var from: Vector2 = anchors[k_i]
        if at.distance_to(from) > reach: at = from + (at - from).normalized() * reach
    return at


# The held cable is pulled. Pulled by its open end, it is drawn through each knot (the knot moves along the
# cable toward its far end until that end slips out); pulled by the other end, the knot only tightens.
func _pull(dt: float) -> void:
    var freed: Array = []
    var snapped: bool = false
    for k_i in CableBox.knots_of(state, held_id):
        var k: Dictionary = state["knots"][k_i]
        var which: String = "a" if k["a"] == held_id else "b"
        var n: int = (ropes[held_id]["p"] as PackedVector2Array).size()
        var plug: int = 0 if held_end == 0 else n - 1
        var rest: float = maxf(absf(_knot_index(k, which) - plug) * SEG, SEG)
        var stretch: float = held_at.distance_to(anchors[k_i]) / rest
        if stretch <= PULL_START: continue
        var pull: float = clampf((stretch - PULL_START) / FULL_PULL, 0.0, 1.0)
        pulling[k_i] = pull
        if int(k["open_" + which]) == held_end:
            var at: float = float(k["at_" + which]) + (1.0 if held_end == 0 else -1.0) * SLIDE_RATE * pull * dt
            k["at_" + which] = clampf(at, 0.0, 1.0)
            if at <= FREE_AT or at >= 1.0 - FREE_AT: freed.append(k_i)
        elif CableBox.strain(state, k_i, held_id, STRAIN_RATE * pull * dt):
            snapped = true
            break
    if snapped:
        var id: String = held_id
        _release()
        ropes[id]["cut"] = (ropes[id]["p"] as PackedVector2Array).size() / 2
        _place_anchors()
        _say("Snap! The cable broke. Throw it away and get another.")
        _save()
        return
    if not freed.is_empty():
        freed.sort()
        freed.reverse()
        for k_i: int in freed:
            CableBox.free_knot(state, k_i)
            anchors.remove_at(k_i)
        _say("A knot came undone." if CableBox.is_free(state, held_id) == false else "That cable is free.")
        _save()


# ---- input ----

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
        var at: Vector2 = (event as InputEventMouseButton).position
        if (event as InputEventMouseButton).pressed: press_at(at)
        else: _release()
        accept_event()
    elif event is InputEventMouseMotion and held_id != "":
        drag_to((event as InputEventMouseMotion).position)
        accept_event()


# Grab the nearest plug, or select a cable (loose or coiled) for tying.
func press_at(at: Vector2) -> void:
    var best: float = GRAB_RADIUS
    for id: String in ropes:
        var c: Dictionary = CableBox.cable(state, id)
        if c.is_empty() or c["broken"]: continue
        var p: PackedVector2Array = ropes[id]["p"]
        for end in [0, 1]:
            var d: float = at.distance_to(p[0 if end == 0 else p.size() - 1])
            if d < best:
                best = d
                held_id = id
                held_end = end
    if held_id != "":
        held_target = at
        held_at = _reach(at)
        selected = held_id
    else:
        selected = _cable_at(at)
    _refresh()


func drag_to(at: Vector2) -> void:
    held_target = at


func grab(id: String, end: int) -> void:
    if not ropes.has(id): return
    held_id = id
    held_end = end
    var p: PackedVector2Array = ropes[id]["p"]
    held_at = p[0 if end == 0 else p.size() - 1]
    held_target = held_at
    selected = id


func _release() -> void:
    if held_id != "": _save()
    held_id = ""
    held_end = -1


func _cable_at(at: Vector2) -> String:
    for id: String in ropes:
        var p: PackedVector2Array = ropes[id]["p"]
        for i in range(p.size() - 1):
            if Geometry2D.get_closest_point_to_segment(at, p[i], p[i + 1]).distance_to(at) < PICK_RADIUS: return id
    var coils: Array = _coils()
    for i in range(coils.size()):
        if _coil_rect(i).has_point(at): return str(coils[i]["id"])
    return ""


func _coils() -> Array:
    return (state["cables"] as Array).filter(func(c: Dictionary) -> bool: return c["tie"] != "")


func _coil_rect(i: int) -> Rect2:
    return Rect2(SHELF.position + Vector2(10, 12 + i * 86), Vector2(SHELF.size.x - 20, 78))


# ---- buttons ----

func _on_button(id: String) -> void:
    match id:
        "zip", "velcro":
            if CableBox.tie(state, selected, id):
                ropes.erase(selected)
                _place_anchors()
                _say("Tied. It won't tangle any more.")
                _save()
        "untie":
            var c: Dictionary = CableBox.cable(state, selected)
            var was: String = str(c.get("tie", ""))
            if CableBox.untie(state, selected):
                ropes[selected] = _lay(CableBox.cable(state, selected))
                _place_anchors()
                _say("The zip tie is cut off." if was == "zip" else "The strap goes back in the box.")
                _save()
        "throw":
            if CableBox.throw_away(state, selected):
                ropes.erase(selected)
                selected = ""
                _place_anchors()
                _say("Thrown away.")
                _save()
        "carry":
            carry_requested.emit()
        "close":
            closed.emit()
    _refresh()


func _refresh() -> void:
    if info == null: return
    var c: Dictionary = CableBox.cable(state, selected)
    var lines: Array = [CableBox.summary(state), "Zip ties: %d · velcro straps: %d (the store sells more)" % [int(state["zip_ties"]), int(state["velcro"])]]
    if not c.is_empty():
        var what: String = str(CableBox.KINDS[c["kind"]]["label"])
        var how: String = "broken" if c["broken"] else ("tied (%s)" % ("zip tie" if c["tie"] == "zip" else "velcro")) if c["tie"] != "" else ("free" if CableBox.is_free(state, selected) else "caught in a knot")
        lines.append("Selected: %s, %s" % [what, how])
    info.text = "\n".join(lines)
    buttons["zip"].disabled = not CableBox.can_tie(state, selected, "zip")
    buttons["velcro"].disabled = not CableBox.can_tie(state, selected, "velcro")
    buttons["untie"].disabled = c.is_empty() or str(c.get("tie", "")) == ""
    buttons["throw"].disabled = c.is_empty() or not bool(c.get("broken", false))


func _say(text: String) -> void:
    if note != null: note.text = text


func _save() -> void:
    if gs != null: CableStore.save_box(gs, state)
    _refresh()


func _process(delta: float) -> void:
    if visible: step(minf(delta, 1.0 / 30.0))


# ---- drawing (placeholders until the cable art is approved) ----

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.62))
    draw_rect(BOX, Color("2b2f36"))
    draw_rect(BOX.grow(-8), Color("4a4f57"))
    draw_rect(SHELF, Color("3c4047"))
    draw_rect(FLOOR, Color("565b63"))
    draw_rect(BOX, Color("111317"), false, 4.0)
    draw_rect(SIDE, Color("1d2128"))
    draw_rect(SIDE, Color("111317"), false, 3.0)
    var coils: Array = _coils()
    for i in range(coils.size()):
        var c: Dictionary = coils[i]
        var r: Rect2 = _coil_rect(i)
        var center: Vector2 = r.get_center()
        var w: float = float(CableBox.KINDS[c["kind"]]["width"])
        for ring in range(3):
            draw_arc(center, 26.0 - ring * 7.0, 0, TAU, 28, Color("15171b"), w * 0.7 + 2.0)
            draw_arc(center, 26.0 - ring * 7.0, 0, TAU, 28, Color("2e3239"), w * 0.7)
        draw_rect(Rect2(center + Vector2(-5, -32), Vector2(10, 64)), Color("101012") if c["tie"] == "zip" else Color("2d5f9c"))
        if selected == c["id"]: draw_rect(r, Color("f2d36b"), false, 2.0)
    for id: String in ropes:
        var c: Dictionary = CableBox.cable(state, id)
        if c.is_empty(): continue
        var p: PackedVector2Array = ropes[id]["p"]
        var w: float = float(CableBox.KINDS[c["kind"]]["width"])
        var cut: int = int(ropes[id]["cut"])
        var pieces: Array = [p] if cut < 0 else [p.slice(0, cut + 1), p.slice(cut + 1)]
        for piece: PackedVector2Array in pieces:
            if piece.size() < 2: continue
            if selected == id: draw_polyline(piece, Color("f2d36b"), w + 6.0)
            draw_polyline(piece, Color("0d0e10"), w + 3.0)
            draw_polyline(piece, Color("6b6f78") if c["broken"] else Color("2a2d33"), w)
            draw_polyline(piece, Color(1, 1, 1, 0.12), maxf(1.0, w * 0.25))
        if cut >= 0:
            for end_at: Vector2 in [p[cut], p[mini(cut + 1, p.size() - 1)]]:
                draw_circle(end_at, w * 0.55, Color("c87f3c"))      # frayed copper
        for end in [0, 1]:
            var at: Vector2 = p[0 if end == 0 else p.size() - 1]
            var toward: Vector2 = p[1 if end == 0 else p.size() - 2]
            var dir: Vector2 = (at - toward).normalized()
            var plug: Vector2 = Vector2(w * 2.2, w * 1.4) if c["kind"] == "atx24" else Vector2(w * 1.8, w * 1.3)
            draw_set_transform(at + dir * plug.x * 0.4, dir.angle())
            draw_rect(Rect2(-plug * 0.5, plug), Color("18191c"))
            draw_rect(Rect2(-plug * 0.5, plug), Color("8a8f98"), false, 1.5)
            draw_set_transform(Vector2.ZERO)
    for k_i in range(anchors.size()):
        var strain: float = float(state["knots"][k_i]["strain"])
        var col: Color = Color("e8e2d0").lerp(Color("e0453a"), strain)
        draw_arc(anchors[k_i], 13.0, 0, TAU, 20, Color("0d0e10"), 6.0)
        draw_arc(anchors[k_i], 13.0, 0, TAU, 20, col, 3.0)
