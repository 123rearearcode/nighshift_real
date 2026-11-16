# VIEW + INPUT for the repair bench: stage 1 vacuum the dust out of the WHOLE PC, stage 2 apply
# thermal paste and mount the cooler. The physics live in scripts/bench/dust_sim.gd and
# paste_sim.gd; the list of dusty parts is in scripts/data/dust_zones.gd; progress is stored in the
# GameState autoload. This file draws, reads the mouse and keyboard and shows text.
# Placeholder shapes only: real graphics come later.
extends Node2D
const Ids = preload("res://scripts/data/ids.gd")
const Layout = preload("res://scripts/data/layout.gd")

const ToolRig = preload("res://scripts/bench/tool_rig.gd")
const ToolRenderer = preload("res://scripts/view/tool_renderer.gd")
const TableBody = preload("res://scripts/bench/table_body.gd")
const PartMotion = preload("res://scripts/view/part_motion.gd")
const DustPick = preload("res://scripts/bench/dust_pick.gd")
const ServiceParts = preload("res://scripts/data/service_parts.gd")
const DustSnapshot = preload("res://scripts/bench/dust_snapshot.gd")
const DustSim = preload("res://scripts/bench/dust_sim.gd")
const PasteSim = preload("res://scripts/bench/paste_sim.gd")
const PasteMaterials = preload("res://scripts/data/paste_materials.gd")
const HandState = preload("res://scripts/bench/hand_state.gd")
const BenchItems = preload("res://scripts/bench/bench_items.gd")
const ServiceAccess = preload("res://scripts/bench/service_access.gd")
const PCLayout = preload("res://scripts/data/pc_layout.gd")
const Backdrop = preload("res://scripts/view/bench_backdrop.gd")
const PCRenderer = preload("res://scripts/view/pc_renderer.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const MountSession = preload("res://scripts/bench/mount_session.gd")
const InstallFaults = preload("res://scripts/rules/install_faults.gd")
const PasteRenderer = preload("res://scripts/view/paste_renderer.gd")
const CleaningRenderer = preload("res://scripts/view/cleaning_renderer.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const PieceCollision = preload("res://scripts/bench/piece_collision.gd")
const DustMotes = preload("res://scripts/bench/dust_motes.gd")
const UiStyle = preload("res://scripts/view/ui_style.gd")
const BenchThermal = preload("res://scripts/view/bench_thermal.gd")
const BenchCleaning = preload("res://scripts/view/bench_cleaning.gd")
const BenchParts = preload("res://scripts/view/bench_parts.gd")
const BenchUi = preload("res://scripts/view/bench_ui.gd")
const BenchInput = preload("res://scripts/view/bench_input.gd")

const STAGE_CLEAN: int = Ids.STAGE_CLEAN
const STAGE_PASTE: int = Ids.STAGE_PASTE

const PC_ORIGIN: Vector2 = Layout.BENCH_PC_ORIGIN    # top-left of the PC interior drawing
const DUST_SEED: int = 12345
const PASTE_ORIGIN: Vector2 = Layout.BENCH_SOCKET_ORIGIN
const PASTE_CELL: int = Layout.BENCH_SOCKET_CELL
const PANEL_X: float = Layout.PANEL_X
const DEPOSIT_RATE: float = 60.0       # paste units per second while squeezing
const PART_LIFT_SECONDS: float = 1.2   # unscrewing a fitted part takes this long (D89: the night is about time)
const TOOL_COLORS: Array = [Color("5ab0f0"), Color("e0a95a"), Color("72d9ad"), Color("ed8d79")]   # vacuum, brush, move parts, pick
const KEEP_GRADE_ABOVE: float = 0.95   # a graded CPU keeps its result until wiping takes it below this share of the graded paste
const WIPE_RADIUS_CELLS: float = (36.0 - 1.0) / float(PASTE_CELL) # shrink working edge by one world pixel, not one 8px cell
const WIPE_STRENGTH: float = 0.12      # share of paste removed per tick at the cloth centre (a blob takes about 1 s)
const PART_MASS: Dictionary = {Ids.COOLER: 2.0, Ids.GPU: 2.5}   # loose parts on the bench: heavier than tools, so tools bounce off them
const AUTOSAVE_SECONDS: float = 3.0    # dust progress is saved this often while cleaning

# Fans: the blades turn at exactly the RPM shown. The range is low on purpose: with 7 blades and
# 60 updates per second, anything above about 250 RPM looks like it is stuttering or running
# backwards. 240 RPM turns the fan 24 degrees per update, under half the 51 degree blade spacing.
const FAN_RPM_DUSTY: float = 30.0
const FAN_RPM_CLEAN: float = 240.0

const COLOR_BG := Color(0.11, 0.12, 0.15)
const COLOR_TEXT := UiStyle.COLOR_TEXT
const TONE_COLORS := UiStyle.TONE_COLORS

var tools := ToolRig.new()
var part_motions: Dictionary = {}
var part_bodies: Dictionary = {}
var previous_poses: Dictionary = {}
var loaded_job_id: String = ""
var event_velocity := Vector2.ZERO
var pointer_event := Vector2.ZERO
var pointer_tick: int = 0
var font: Font
var stage: int = STAGE_CLEAN
var pick := DustPick.new()
var replacement_panel: Panel
var replacement_summary: Label
var replacement_buttons: Array = []
var active_tool: int = DustSim.TOOL_BRUSH
var zones: Array = []
var zone_done: Array = []              # bool per zone: counted as clean
var access: ServiceAccess = ServiceAccess.new()
var part_offsets: Dictionary = {}
var blocker_key: String = ""
var move_button: Button
var dust: DustSim = DustSim.new()
var bin := DustBin.new()               # the vacuum's dust bin: fills while vacuuming, click it to empty
var motes := DustMotes.new()           # floating dust, cosmetic only
var items := BenchItems.new()          # loose items on the bench (a dropped coin, a stray screw); not saved
const TURN_DRAG_PIXELS: float = 26.0   # sideways middle-button drag needed per 15 degree turn
var turning_with_mouse: bool = false
var turn_travel: float = 0.0
var bin_notified: bool = false
var lift_id: String = ""              # fitted part being unscrewed (hold); the drag starts when it frees
var lift_progress: float = 0.0
var scripted_pressing: Variant = null # tools/playtest_bench.gd: pressing the cooler during mounting
var scripted_pointer: Variant = null  # tools/playtest_bench.gd sets this to drive the bench without a real mouse
var last_draw_usec: int = 0           # how long the last redraw took (CPU side, microseconds); read by tools/playtest_bench.gd
var paste: PasteSim = PasteSim.new()
var paste_image: Image
var paste_texture: ImageTexture
var paste_dirty: bool = true

var holding: bool = false              # mouse held, and the press started in the work area
var last_mouse: Vector2 = Vector2.ZERO
var tool_vel: Vector2 = Vector2.ZERO
var dust_dirty: bool = false
var save_timer: float = 0.0
var wiping: bool = false               # the cloth is the active paste tool
var mount := MountSession.new()        # the timed pressure minigame (see scripts/bench/mount_session.gd)
var mount_result: Dictionary = {}
var live_stats: Dictionary = {"coverage": 0.0, "overflow": 0.0}
var cooler_zone: int = 1
var case_fan_zone: int = 0
var cooler_angle: float = 0.0
var cooler_rpm: float = FAN_RPM_DUSTY
var case_angle: float = 0.0
var case_rpm: float = FAN_RPM_DUSTY
var vfx_time: float = 0.0

var title_label: Label
var status_label: Label
var mount_button: Button
var film_button: Button                # D130: the cooler base with its clear plastic film
var screw_clicks: Array = []           # D130: corner screws turned during this mount, in order (install_faults.gd)
var clear_button: Button
const SECURE_LEVER: Rect2 = Layout.BENCH_LEVER   # the cooler's retention lever beside the socket: click it to secure the cooler
var time_up_told: bool = false
var clamp_button: int = 0
var clamp_press := Vector2.ZERO
var material_button: MenuButton       # one canonical three-material menu
var stage_buttons: Array[Button] = []
var retract_button: Button
var complete_button: Button           # Complete repaste: appears after a mount, works on a good result
var clean_controls: Array = []
var paste_controls: Array = []
var tool_buttons: Array = []
var empty_bin_button: Button
var vacuum_status: Label
var _audio_activity: Dictionary = {}
var _impact_counts: Dictionary = {}
var stock_button: Button
var backdrop: Node2D
var _vacuum_ui_key := Vector3i(-1,-1,-1)
var _paste_ui_key: int = -1
var vacuum_ui_updates: int = 0
# 0.42.0: the bench's behaviour lives in five helpers (one-line wrappers below keep the old names).
# They keep no state of their own; every bench variable stays here.
var thermal := BenchThermal.new(self)    # paste, mount, install ritual (bench_thermal.gd)
var cleaning := BenchCleaning.new(self)  # dust, pick, bin, collisions, fans (bench_cleaning.gd)
var parts := BenchParts.new(self)        # movable parts and Replacement stock (bench_parts.gd)
var ui_builder := BenchUi.new(self)      # buttons, labels and panels (bench_ui.gd)
var input_router := BenchInput.new(self) # mouse and keyboard, through the hand state (bench_input.gd)


func _ready() -> void:
    loaded_job_id = str(GameState.job["id"])
    font = ThemeDB.fallback_font
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    zones = DustZones.zones(str(GameState.job.get("layout", "tower")))
    cooler_zone = DustZones.index_of(Ids.COOLER)
    case_fan_zone = DustZones.index_of("case_fan")
    tools.set_long_hose(GameState.has_upgrade("long_hose"))
    _initialize_dust()
    cooler_rpm = lerpf(FAN_RPM_DUSTY, FAN_RPM_CLEAN, dust.removed_fraction(cooler_zone)) if GameState.job["pc_powered"] else 0.0
    case_rpm = lerpf(FAN_RPM_DUSTY, FAN_RPM_CLEAN, dust.removed_fraction(case_fan_zone)) if GameState.job["pc_powered"] else 0.0
    paste_image = Image.create_empty(PasteSim.GRID, PasteSim.GRID, false, Image.FORMAT_RGBA8)
    paste_image.fill(Color(0, 0, 0, 0))
    paste_texture = ImageTexture.create_from_image(paste_image)
    backdrop = Backdrop.new()
    backdrop.z_index = -1
    add_child(backdrop)
    _build_ui()
    _select_stage(STAGE_CLEAN)


func _initialize_dust() -> void: cleaning._initialize_dust()


func _sound(id: String, context: Dictionary = {}) -> void:
    var details: Dictionary = context.duplicate(true)
    if not details.has("position"): details["position"] = tools.point
    if is_instance_valid(AudioFeedback): AudioFeedback.request(self,id,details)

func _equip_tool(id: String, at: Vector2) -> bool:
    if not _may_enter(HandState.USING_TOOL):
        return false
    var previous: String = tools.selected if tools.equipped else ""
    tools.select(id,at)
    if previous != id:
        if previous != "": _sound("handling.putdown",{"kind":previous})
        _sound("handling.pickup",{"kind":id})
    return true

func _park_tool() -> void:
    if tools.equipped: _sound("handling.putdown",{"kind":tools.selected})
    tools.park()

func _audio_loop(id: String, enabled: bool, context: Dictionary = {}) -> void:
    _audio_activity[id] = {"enabled":enabled,"context":context}

func _sync_audio() -> void:
    for id: String in AudioFeedback.Cues.CUES:
        if not bool(AudioFeedback.Cues.CUES[id]["loop"]): continue
        var activity: Dictionary = _audio_activity.get(id,{})
        AudioFeedback.set_loop(self,id,bool(activity.get("enabled",false)),activity.get("context",{}))
    for id: String in part_bodies:
        var impacts: int = part_bodies[id].impacts
        var key: String = "part:"+id
        if impacts > int(_impact_counts.get(key,0)):
            _sound("handling.impact",{"kind":id,"speed":part_bodies[id].velocity.length()})
        _impact_counts[key] = impacts
    for id: String in ToolRig.IDS:
        var impacts: int = tools.bodies[id].impacts
        if impacts > int(_impact_counts.get(id,0)):
            _sound("handling.impact",{"kind":id,"speed":tools.bodies[id].velocity.length()})
        _impact_counts[id] = impacts


func _exit_tree() -> void:
    if is_instance_valid(AudioFeedback): AudioFeedback.stop_owner(self)
    _save_dust()


# ---------- saving dust progress ----------

func _dust_fractions() -> Dictionary: return cleaning._dust_fractions()


func _save_dust() -> void: cleaning._save_dust()


func _done_count() -> int: return cleaning._done_count()


# ---------- UI ----------

func _make_button(text: String, pos: Vector2, size: Vector2, callback: Callable, group: ButtonGroup = null) -> Button: return ui_builder._make_button(text, pos, size, callback, group)


func _build_ui() -> void: ui_builder._build_ui()


func _set_status(text: String, tone: int) -> void:
    status_label.text = text
    status_label.add_theme_color_override("font_color", TONE_COLORS[tone])


func _select_stage(new_stage: int) -> void:
    if is_instance_valid(replacement_panel) and replacement_panel.visible: return
    pick.reset()
    if stage == STAGE_CLEAN and dust_dirty:
        _save_dust()
    if access.dragging != "":
        access.dragging = ""
        _sync_part_geometry()
    AudioFeedback.stop_owner(self)
    if mount.active:
        _cancel_mount()   # a stage switch releases everything; only the lever may secure and grade (D57)
    lift_id = ""
    stage = new_stage
    for i in range(stage_buttons.size()): stage_buttons[i].set_pressed_no_signal(i == stage)
    _paste_ui_key = -1
    backdrop.configure(stage == STAGE_CLEAN,str(GameState.job["layout"]),Rect2(PC_ORIGIN,DustZones.AREA_SIZE),COLOR_BG)
    clamp_button = 0
    holding = false
    _equip_tool(Ids.SYRINGE if stage == STAGE_PASTE else Ids.SLOT_TOOL[active_tool], _pointer())
    if stage == STAGE_CLEAN and active_tool == 2: _park_tool()
    if stage == STAGE_PASTE:
        wiping = false
    for c: Control in clean_controls:
        c.visible = (stage == STAGE_CLEAN)
    for c: Control in paste_controls:
        c.visible = (stage == STAGE_PASTE)
    if stage == STAGE_CLEAN:
        status_label.position = Vector2(PANEL_X, 556)
        status_label.size = Vector2(520, 85)
        title_label.text = "NIGHTSHIFT - clean the PC\nLeft hold: use. Right-drag: throw. Shift + right-drag: hose. Drag clamp: move (outside PC). Click clamp: unclip. 1 brush / 2 vacuum / 3 parts / 4 pick. Wheel or Q/E: rotate."
        if _done_count() == zones.size():
            _set_status("Cleanliness target met. %d real dust groups remain; finish vacuuming or continue to paste. New dirty PC starts another practice job." % dust.visible_count(), 1)
        else:
            _set_status(_clean_hint(), 0)
    else:
        status_label.position = Vector2(PANEL_X, 540)
        status_label.size = Vector2(520, 95)
        title_label.text = "NIGHTSHIFT - repair bench (step 2: thermal paste)\nPick up the syringe or cloth from the bench. Hold on the CPU to use it; mount below the socket when ready. Installing: film, paste, mount + press, screws (screwdriver), lever."
        var saved_grade: String = str(GameState.job["paste_grade"])
        if mount.active:
            _set_status("Mounting: hold the mouse over the socket (or Space) to press. Release once CPU covered passes the line. Screws come after, with the screwdriver, then the lever.", 0)
        elif bool(GameState.job["paste_done"]) and mount_result.is_empty():
            _set_status("Repaste complete (%s, %s). (The paste picture is not saved.) Press Clear all paste to redo it." % [saved_grade, PasteMaterials.material(str(GameState.job["paste_material"]))["label"].to_lower()], 1)
        elif saved_grade != "" and mount_result.is_empty():
            _set_status("Saved result: %s, not completed yet. (The paste picture is not saved.) Press Clear all paste to redo it." % saved_grade, 0)
        elif mount_result.is_empty():
            _set_status("Squeeze a pea-sized blob in the centre of the CPU (the green zone on the gauge), then press Mount cooler and time the press.", 0)
    _sync_paste_controls()
    queue_redraw()


func _clean_hint() -> String: return cleaning._clean_hint()


func _select_tool(new_tool: int) -> void:
    if is_instance_valid(replacement_panel) and replacement_panel.visible: return
    if new_tool != Ids.SLOT_PARTS and not _may_enter(HandState.USING_TOOL): return
    lift_id = ""
    if access.dragging != "": access.dragging = ""
    holding = false
    clamp_button = 0
    tools.end_clamp_drag()
    active_tool = new_tool
    if new_tool != Ids.SLOT_PARTS: _equip_tool(Ids.SLOT_TOOL[new_tool], _pointer())
    else: _park_tool()
    pick.reset()
    if tool_buttons.size() == 4:
        for index in range(tool_buttons.size()):
            (tool_buttons[index] as Button).set_pressed_no_signal(index == new_tool)
    if stage == STAGE_CLEAN and _done_count() < zones.size():
        _set_status(_clean_hint(), 0)


func _on_reset_dust() -> void: cleaning._on_reset_dust()


func _on_mount_pressed() -> void: thermal._on_mount_pressed()


func _can_change_material() -> bool: return thermal._can_change_material()

func _refresh_material_menu(announce: bool = true) -> void: thermal._refresh_material_menu(announce)

func _on_material_selected(index: int) -> void: thermal._on_material_selected(index)

func _material_charge_note() -> String: return thermal._material_charge_note()

func _refresh_material_button() -> void: thermal._refresh_material_button()

func _on_complete_pressed() -> void: thermal._on_complete_pressed()


func _on_clear_pressed() -> void: thermal._on_clear_pressed()


func _cloth_is_square() -> bool: return thermal._cloth_is_square()


func _select_dispense() -> void: thermal._select_dispense()


func _select_cloth() -> void: thermal._select_cloth()

func _cancel_unlocked_mount() -> void: thermal._cancel_unlocked_mount()


func _on_back_pressed() -> void:
    _cancel_unlocked_mount()   # navigation must never impersonate the physical securing lever
    _save_dust()
    get_tree().change_scene_to_file("res://scenes/shop.tscn")


# ---------- input ----------

# Where the pointer is: the real mouse, or a scripted position during an automated playtest.
# Which hand state the bench is in (docs/HAND_STATES.md). Step 5 of the work plan: read-only, derived
# from today's flags in priority order; nothing acts on it yet. Step 6 will route input through it.
func hand_state() -> String:
    return HandState.derive({
        "panel_open": is_instance_valid(replacement_panel) and replacement_panel.visible,
        "mounting": mount.active,
        "clamp_dragging": tools.clamp_dragging,
        "hose_grabbed": tools.hose_grab >= 0,
        "part_dragging": access.dragging != "",
        "item_carried": items.carried >= 0,
        "throwing": tools.carrying,
        "equipped": tools.equipped,
    })


# May the hands enter `to` from where they are now? Asked before every act that takes something into
# the hands; a refused act simply does not happen (the click falls through to nothing).
func _may_enter(to: String) -> bool:
    return HandState.allowed(hand_state(), to)


func _pointer() -> Vector2:
    return scripted_pointer if scripted_pointer is Vector2 else get_global_mouse_position()


func _work_rect() -> Rect2:
    if stage == STAGE_CLEAN:
        return Rect2(PC_ORIGIN, DustZones.AREA_SIZE).merge(ServiceAccess.TRAY)
    var side: float = PasteSim.GRID * PASTE_CELL
    return Rect2(PASTE_ORIGIN, Vector2(side, side))


func _input(event: InputEvent) -> void: input_router._input(event)


# ---------- simulation tick (fixed 60 Hz) ----------

func _process(_delta: float) -> void:
    queue_redraw()


func _physics_process(delta: float) -> void:
    _audio_activity.clear()
    var mouse: Vector2 = _pointer()
    var raw_vel: Vector2 = (mouse - last_mouse) / maxf(delta, 0.0001)
    tool_vel = tool_vel.lerp(raw_vel.limit_length(2500), 1.0 - exp(-26.0 * delta))
    last_mouse = mouse
    vfx_time += delta

    if items.carried >= 0: items.move(mouse)
    var old_clamp: Vector2 = tools.clamp_position
    tools.step(delta,mouse,holding and _work_rect().has_point(mouse) and not replacement_panel.visible)
    _audio_loop("clamp.slide",tools.clamp_dragging and tools.clamp_position.distance_to(old_clamp)>0.1,{"speed":tools.clamp_position.distance_to(old_clamp)/maxf(delta,0.0001)})
    _audio_loop("hose.drag",tools.hose_grab>=0 and tool_vel.length()>10.0,{"speed":tool_vel.length()})
    _step_pieces()
    if stage == STAGE_CLEAN:
        _step_clean(delta,mouse if active_tool == 2 else tools.contact())
    else:
        _step_paste(delta,mouse if mount.active else tools.contact())
    _audio_loop("pc.fan",stage == STAGE_CLEAN and bool(GameState.job["pc_powered"]),{"cooler_rpm":cooler_rpm,"case_rpm":case_rpm})
    _sync_audio()


func _step_clean(delta: float, mouse: Vector2) -> void: cleaning._step_clean(delta, mouse)


func _step_pieces() -> void: cleaning._step_pieces()



func _part_pieces() -> Array: return cleaning._part_pieces()


func _apply_part_collisions(pieces: Array) -> void: cleaning._apply_part_collisions(pieces)


func _after_dust_step(delta: float, nozzle: Vector2) -> void: cleaning._after_dust_step(delta, nozzle)


func _refresh_vacuum_status() -> void: cleaning._refresh_vacuum_status()


func _empty_bin() -> void: cleaning._empty_bin()


func _announce_zone(i: int) -> void: cleaning._announce_zone(i)


func _step_paste(delta: float, mouse: Vector2) -> void: thermal._step_paste(delta, mouse)


func _sync_paste_controls() -> void: thermal._sync_paste_controls()

func _retract_hose() -> void: cleaning._retract_hose()

func _style_stage_button(button: Button,tint: Color) -> void: ui_builder._style_stage_button(button, tint)

func _step_mount(delta: float, mouse: Vector2) -> void: thermal._step_mount(delta, mouse)

func _cancel_mount() -> void: thermal._cancel_mount()


func _install_step() -> int: return thermal._install_step()


func _socket_region() -> Rect2: return thermal._socket_region()


func _on_film_pressed() -> void: thermal._on_film_pressed()


func _screw_click(screw: int) -> void: thermal._screw_click(screw)


func _turn_screw(screw: int) -> void: thermal._turn_screw(screw)


func _finish_mount() -> void: thermal._finish_mount()


func _refresh_paste_image() -> void: thermal._refresh_paste_image()

# ---------- drawing ----------

func _text(pos: Vector2, text: String, size: int = 16, color: Color = COLOR_TEXT) -> void:
    UiStyle.label(self, pos, text, size, color)

func _bar(rect: Rect2, fraction: float, color: Color, mark: float = -1.0) -> void:
    UiStyle.bar(self, rect, fraction, color, mark)

# Redraw, timed: the frame-time table in tools/playtest_bench.gd reads last_draw_usec. Costs two clock reads.
func _draw() -> void:
    var started: int = Time.get_ticks_usec()
    _draw_scene()
    last_draw_usec = Time.get_ticks_usec() - started


func _draw_scene() -> void:
    if stage == STAGE_CLEAN:
        _draw_pc()
        _text(Vector2(PANEL_X,155),"TOOLS",12)
        _text(Vector2(PANEL_X,216),"MAINTENANCE",12)
        _draw_dust()
        CleaningRenderer.draw_bin(self, bin, DustBin.RECT.has_point(get_global_mouse_position()))
        CleaningRenderer.draw_power(self, bool(GameState.job["pc_powered"]), Layout.BENCH_POWER.has_point(get_global_mouse_position()))
        CleaningRenderer.draw_trash(self, items.carried >= 0 and Layout.BENCH_TRASH.has_point(get_global_mouse_position()))
        CleaningRenderer.draw_items(self, items)
        if lift_id != "":
            var t: float = clampf(lift_progress / PART_LIFT_SECONDS, 0.0, 1.0)
            draw_arc(_pointer(), 17.0, -PI * 0.5, -PI * 0.5 + TAU * t, 24, Color(0.95, 0.85, 0.45), 4.0, true)
            draw_arc(_pointer(), 17.0, 0.0, TAU, 24, Color(0.95, 0.85, 0.45, 0.25), 1.5, true)
        CleaningRenderer.draw_motes(self, motes)
        _draw_clean_panel()
        _draw_clean_cursor()
        _text(Vector2(40,690),"v%s / %s / %d visible dust groups / %s" % [GameState.game_version(),loaded_job_id,dust.visible_count(),"CLEANED SAVE: continue paste or choose New dirty PC" if _done_count() == zones.size() else "saved progress resumed"],13)
    else:
        _draw_paste_stage()
        _draw_paste_panel()
        _draw_paste_cursor()


func _zone_rect(i: int) -> Rect2: return parts._zone_rect(i)


func _part_rects() -> Dictionary: return parts._part_rects()

func _part_poses() -> Dictionary: return parts._part_poses()

func _sync_part_geometry() -> void: parts._sync_part_geometry()

func _finish_part_drag(point: Vector2) -> void: parts._finish_part_drag(point)

func _draw_pc() -> void:
    PCRenderer.draw_pc(self, str(GameState.job.get("layout", "tower")), Rect2(PC_ORIGIN, DustZones.AREA_SIZE), zones, case_angle, cooler_angle, _part_rects(), _part_poses(), false)
    for id: String in GameState.job["broken_parts"]:
        var rect: Rect2 = access.current_rect(id)
        draw_rect(rect.grow(3), TONE_COLORS[3], false, 3)
        _text(rect.position + Vector2(5, 17), "DAMAGED", 14, TONE_COLORS[3])


func _draw_dust() -> void:
    CleaningRenderer.draw_dust(self, dust)

func _draw_clean_panel() -> void:
    CleaningRenderer.draw_panel(self, dust, zones, zone_done, _done_count(), PANEL_X, cooler_rpm, case_rpm)

func _draw_clean_cursor() -> void:
    if replacement_panel.visible: return
    if active_tool == 2 and _work_rect().has_point(get_global_mouse_position()):
        draw_arc(get_global_mouse_position(),10,0,TAU,20,Color.WHITE,1)
    ToolRenderer.draw_tools(self,tools,Ids.CLEAN_TOOLS)
    if active_tool == 3 and tools.equipped:
        var point: Vector2 = tools.contact()
        var id: String = _pick_target(point)
        draw_arc(point,12,-PI/2,-PI/2+TAU*maxf(0.01,pick.elapsed/DustPick.STROKE_SECONDS),24,Color("ffca7a"),2)
        if id != "":
            _text(Vector2(clampf(point.x-90,42,330),maxf(140,point.y-35)),"%s: %d trapped / 12%% risk" % [id,dust.trapped_count(id)],13,Color("ffca7a"))

func _draw_paste_stage() -> void:
    PasteRenderer.draw_stage(self, paste, paste_texture, PASTE_ORIGIN, PASTE_CELL, mount)
    PasteRenderer.draw_cooler_base(self, Rect2(PANEL_X + 270, 258, 250, 40), bool(GameState.job["cooler_film_peeled"]))
    PasteRenderer.draw_install_steps(self, Vector2(PANEL_X, 520), _install_step(), InstallFaults.STEPS)
    if mount.active:
        PasteRenderer.draw_screws(self, InstallFaults.screw_centers(_socket_region()), screw_clicks, InstallFaults.TURNS_NEEDED, InstallFaults.SCREW_RADIUS)
    var locked: bool = not mount.active and (not mount_result.is_empty() or bool(GameState.job["paste_done"]))
    PasteRenderer.draw_lever(self, SECURE_LEVER, mount.active, locked, SECURE_LEVER.has_point(get_global_mouse_position()), vfx_time)

func _draw_paste_panel() -> void:
    PasteRenderer.draw_panel(self, paste, PANEL_X, mount, not mount_result.is_empty(), live_stats)

func _draw_paste_cursor() -> void:
    ToolRenderer.draw_tools(self,tools,Ids.PASTE_TOOLS)

func _pick_target(point: Vector2) -> String: return parts._pick_target(point)

func _build_replacements() -> void: parts._build_replacements()

func _open_replacements() -> void: parts._open_replacements()

func _refresh_replacements() -> void: parts._refresh_replacements()


func _replace_part(id: String, tier: String) -> void: parts._replace_part(id, tier)


func _buy_stock(id: String, tier: String) -> void: parts._buy_stock(id, tier)

func _new_ticket() -> void: parts._new_ticket()

func _init_part_motion() -> void: parts._init_part_motion()

func _step_part_motion(delta: float) -> void: parts._step_part_motion(delta)

func _save_service_positions() -> void: parts._save_service_positions()


func _part_under(point: Vector2) -> String: return parts._part_under(point)


func _begin_part_drag(point: Vector2) -> bool: return parts._begin_part_drag(point)


func _start_part_drag(id: String, point: Vector2) -> bool: return parts._start_part_drag(id, point)
