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
const PCRenderer = preload("res://scripts/view/pc_renderer.gd")
const DustZones = preload("res://scripts/data/dust_zones.gd")
const MountSession = preload("res://scripts/bench/mount_session.gd")
const PasteRenderer = preload("res://scripts/view/paste_renderer.gd")
const CleaningRenderer = preload("res://scripts/view/cleaning_renderer.gd")
const DustBin = preload("res://scripts/bench/dust_bin.gd")
const PieceCollision = preload("res://scripts/bench/piece_collision.gd")
const DustMotes = preload("res://scripts/bench/dust_motes.gd")
const UiStyle = preload("res://scripts/view/ui_style.gd")

const STAGE_CLEAN: int = Ids.STAGE_CLEAN
const STAGE_PASTE: int = Ids.STAGE_PASTE

const PC_ORIGIN: Vector2 = Layout.BENCH_PC_ORIGIN    # top-left of the PC interior drawing
const DUST_SEED: int = 12345
const PASTE_ORIGIN: Vector2 = Layout.BENCH_SOCKET_ORIGIN
const PASTE_CELL: int = Layout.BENCH_SOCKET_CELL
const PANEL_X: float = Layout.PANEL_X
const DEPOSIT_RATE: float = 60.0       # paste units per second while squeezing
const WIPE_RADIUS_CELLS: float = 4.5   # reach of the cloth on the paste grid (a square cloth reaches 4.5 cells each way)
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
var active_tool: int = DustSim.TOOL_VACUUM
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
var wipe_button: Button
var mount_button: Button
var clear_button: Button
const SECURE_LEVER: Rect2 = Layout.BENCH_LEVER   # the cooler's retention lever beside the socket: click it to secure the cooler
var time_up_told: bool = false
var clamp_button: int = 0
var clamp_press := Vector2.ZERO
var material_button: Button           # thermal paste or toothpaste (a scam)
var complete_button: Button           # Complete repaste: appears after a mount, works on a good result
var clean_controls: Array = []
var paste_controls: Array = []
var tool_buttons: Array = []
var empty_bin_button: Button
var vacuum_status: Label
var _audio_activity: Dictionary = {}
var _impact_counts: Dictionary = {}
var stock_button: Button


func _ready() -> void:
    loaded_job_id = str(GameState.job["id"])
    font = ThemeDB.fallback_font
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    zones = DustZones.zones(str(GameState.job.get("layout", "tower")))
    cooler_zone = DustZones.index_of(Ids.COOLER)
    case_fan_zone = DustZones.index_of("case_fan")
    tools.set_long_hose(GameState.has_upgrade("long_hose"))
    _initialize_dust()
    cooler_rpm = lerpf(FAN_RPM_DUSTY, FAN_RPM_CLEAN, dust.removed_fraction(cooler_zone))
    case_rpm = lerpf(FAN_RPM_DUSTY, FAN_RPM_CLEAN, dust.removed_fraction(case_fan_zone))
    paste_image = Image.create_empty(PasteSim.GRID, PasteSim.GRID, false, Image.FORMAT_RGBA8)
    paste_image.fill(Color(0, 0, 0, 0))
    paste_texture = ImageTexture.create_from_image(paste_image)
    _build_ui()
    _select_stage(STAGE_CLEAN)


# Fresh, reopened and New dirty PC use the same geometry + restoration sequence.
func _initialize_dust() -> void:
    dust.setup(zones, PC_ORIGIN, DUST_SEED)
    access.setup(zones, PC_ORIGIN, GameState.job.get("removed_parts", []))
    part_motions.clear()
    part_bodies.clear()
    _init_part_motion()
    previous_poses.clear()
    blocker_key = ""
    _sync_part_geometry()
    var restored: bool = DustSnapshot.restore(dust, GameState.job.get("dust_state", {}))
    if not restored:
        for i in range(zones.size()): dust.apply_progress(i,GameState.dust_fraction(str(zones[i]["id"])))
    zone_done.clear()
    for i in range(zones.size()): zone_done.append(dust.removed_fraction(i) >= DustZones.CLEAN_AT)
    tools.clamp_pc = dust.case_bounds


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

func _dust_fractions() -> Dictionary:
    var out: Dictionary = {}
    for i in range(zones.size()):
        var z: Dictionary = zones[i]
        out[str(z["id"])] = dust.removed_fraction(i)
    return out


func _save_dust() -> void:
    if zones.is_empty() or loaded_job_id != str(GameState.job["id"]):
        return
    _save_service_positions()
    GameState.set_dust(_dust_fractions(),DustSnapshot.capture(dust))
    dust_dirty = false
    save_timer = 0.0


func _done_count() -> int:
    var n: int = 0
    for d in zone_done:
        if bool(d):
            n += 1
    return n


# ---------- UI ----------

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
    b.pressed.connect(func() -> void: _sound("ui.click"))
    add_child(b)
    return b


func _build_ui() -> void:
    title_label = Label.new()
    title_label.position = Vector2(40, 16)
    title_label.size = Vector2(1200, 70)
    title_label.add_theme_font_size_override("font_size", 18)
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(title_label)

    status_label = Label.new()
    status_label.position = Vector2(PANEL_X, 556)
    status_label.size = Vector2(520, 85)
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 16)
    add_child(status_label)

    var stage_group := ButtonGroup.new()
    var b1: Button = _make_button("Cleaning", Vector2(PANEL_X, 100), Vector2(250, 40), _select_stage.bind(STAGE_CLEAN), stage_group)
    _make_button("Thermal service", Vector2(PANEL_X + 270, 100), Vector2(250, 40), _select_stage.bind(STAGE_PASTE), stage_group)
    b1.button_pressed = true

    var tool_group := ButtonGroup.new()
    var vac: Button = _make_button("Vacuum (1)", Vector2(PANEL_X, 164), Vector2(120, 36), _select_tool.bind(DustSim.TOOL_VACUUM), tool_group)
    var brush: Button = _make_button("Brush (2)", Vector2(PANEL_X + 133, 164), Vector2(120, 36), _select_tool.bind(DustSim.TOOL_BRUSH), tool_group)
    vac.button_pressed = true
    tool_buttons = [vac, brush]
    var reset_dust: Button = _make_button("Practice: new dirty PC", Vector2(PANEL_X + 270, 645), Vector2(250, 40), _new_ticket)
    move_button = _make_button("Move parts (3)", Vector2(PANEL_X + 266, 164), Vector2(120, 36), _select_tool.bind(2), tool_group)
    tool_buttons.append(move_button)
    var pick_button: Button = _make_button("Pick (4) / risky", Vector2(PANEL_X + 399, 164), Vector2(120, 36), _select_tool.bind(3), tool_group)
    tool_buttons.append(pick_button)
    for b: Button in [vac,brush,move_button,pick_button]: b.add_theme_font_size_override("font_size",14)
    empty_bin_button = _make_button("Empty bin",Vector2(PANEL_X,220),Vector2(250,32),_empty_bin)
    stock_button = _make_button("Replacement stock",Vector2(PANEL_X+270,220),Vector2(250,32),_open_replacements)
    vacuum_status = Label.new()
    vacuum_status.position = Vector2(PANEL_X,260)
    vacuum_status.size = Vector2(520,24)
    vacuum_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vacuum_status.add_theme_font_size_override("font_size",16)
    add_child(vacuum_status)
    clean_controls = [vac,brush,reset_dust,move_button,pick_button,empty_bin_button,stock_button,vacuum_status]
    _refresh_vacuum_status()

    mount_button = _make_button("Mount cooler", Vector2(PANEL_X, 210), Vector2(250, 40), _on_mount_pressed)
    wipe_button = _make_button("Wipe with cloth", Vector2(PANEL_X + 270, 160), Vector2(250, 40), _on_wipe_toggled)
    wipe_button.toggle_mode = true
    clear_button = _make_button("Reset paste (practice)", Vector2(PANEL_X, 260), Vector2(250, 28), _on_clear_pressed)
    material_button = _make_button("Paste: thermal ($%d)" % int(PasteMaterials.material("thermal")["cost"]), Vector2(PANEL_X, 160), Vector2(250, 40), _on_material_toggled)
    material_button.toggle_mode = true
    complete_button = _make_button("Complete repaste", Vector2(PANEL_X + 270, 210), Vector2(250, 40), _on_complete_pressed)
    paste_controls = [mount_button, wipe_button, clear_button, material_button, complete_button]

    var back: Button = _make_button("Back to shop", Vector2(PANEL_X, 645), Vector2(250, 44), _on_back_pressed)
    back.tooltip_text = "Saves work. An unfinished cooler mount is cancelled; only its lever locks it."
    paste.material = str(GameState.job["paste_material"]) if str(GameState.job["paste_material"]) in PasteMaterials.IDS else "thermal"
    _refresh_material_button()
    _build_replacements()


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
        _finish_mount()   # a stage switch releases everything (docs/HAND_STATES.md): the cooler is secured as it lies
    stage = new_stage
    clamp_button = 0
    holding = false
    _equip_tool(Ids.SYRINGE if stage == STAGE_PASTE else Ids.SLOT_TOOL[active_tool], _pointer())
    if stage == STAGE_CLEAN and active_tool == 2: _park_tool()
    if stage == STAGE_PASTE:
        wiping = false
        wipe_button.set_pressed_no_signal(false)
    for c: Control in clean_controls:
        c.visible = (stage == STAGE_CLEAN)
    for c: Control in paste_controls:
        c.visible = (stage == STAGE_PASTE)
    if stage == STAGE_CLEAN:
        status_label.position = Vector2(PANEL_X, 556)
        status_label.size = Vector2(520, 85)
        title_label.text = "NIGHTSHIFT - clean the PC\nLeft hold: use. Right-drag: throw. Shift + right-drag: hose. Drag clamp: move (outside PC). Click clamp: unclip. 1 vacuum / 2 brush / 3 parts / 4 pick. Wheel or Q/E: rotate."
        if _done_count() == zones.size():
            _set_status("Cleanliness target met. %d real dust groups remain; finish vacuuming or continue to paste. New dirty PC starts another practice job." % dust.visible_count(), 1)
        else:
            _set_status(_clean_hint(), 0)
    else:
        status_label.position = Vector2(PANEL_X, 540)
        status_label.size = Vector2(520, 95)
        title_label.text = "NIGHTSHIFT - repair bench (step 2: thermal paste)\nChoose syringe or cloth. Hold on the CPU to use it; mount the cooler when ready."
        var saved_grade: String = str(GameState.job["paste_grade"])
        if mount.active:
            _set_status("Mounting: hold the mouse over the socket (or Space) to press. Release once CPU covered passes the line.", 0)
        elif bool(GameState.job["paste_done"]) and mount_result.is_empty():
            _set_status("Repaste complete (%s, %s). (The paste picture is not saved.) Press Clear all paste to redo it." % [saved_grade, PasteMaterials.material(str(GameState.job["paste_material"]))["label"].to_lower()], 1)
        elif saved_grade != "" and mount_result.is_empty():
            _set_status("Saved result: %s, not completed yet. (The paste picture is not saved.) Press Clear all paste to redo it." % saved_grade, 0)
        elif mount_result.is_empty():
            _set_status("Squeeze a pea-sized blob in the centre of the CPU (the green zone on the gauge), then press Mount cooler and time the press.", 0)
    queue_redraw()


func _clean_hint() -> String:
    if active_tool == 3:
        return "Pick: hover cooler/GPU to inspect trapped dust; hold to extract (0.8s, 12% damage risk per attempt). Safe alternative: remove the part. Broken? Move it to tray, then choose Replacements."
    if active_tool == 2:
        return "Move parts: drag cooler or GPU onto the tray. Clean their surfaces there, then clean the exposed board. Drag each back to its mount before final check."
    if active_tool == DustSim.TOOL_VACUUM:
        return "Vacuum: hold over dirt. Tails hanging from under parts can be pulled very slowly with precise suction; remove the part for easier access. Short hose: rotate/re-route to reach the far-left corner."
    return "Brush: sweep the bristles over dust to loosen it (it turns lighter). Fast strokes scatter it through the case; watch for trapped dust and clogged filter. The brush removes nothing by itself; vacuum the loosened bundle afterwards, which is faster."


func _select_tool(new_tool: int) -> void:
    if is_instance_valid(replacement_panel) and replacement_panel.visible: return
    if new_tool != Ids.SLOT_PARTS and not _may_enter(HandState.USING_TOOL): return
    if access.dragging != "": access.dragging = ""
    holding = false
    clamp_button = 0
    tools.end_clamp_drag()
    active_tool = new_tool
    if new_tool != Ids.SLOT_PARTS: _equip_tool(Ids.SLOT_TOOL[new_tool], _pointer())
    else: _park_tool()
    pick.reset()
    if tool_buttons.size() == 4:
        (tool_buttons[new_tool] as Button).set_pressed_no_signal(true)
    if stage == STAGE_CLEAN and _done_count() < zones.size():
        _set_status(_clean_hint(), 0)


func _on_reset_dust() -> void:
    holding = false
    var fresh: Dictionary = {}
    for z: Dictionary in zones: fresh[str(z["id"])] = 1.0 if z["id"] == "case_interior" else 0.0
    _save_service_positions()
    GameState.set_dust(fresh)
    _initialize_dust()
    tools.flow.clear()
    cooler_rpm = FAN_RPM_DUSTY
    case_rpm = FAN_RPM_DUSTY
    _save_dust()
    _set_status(_clean_hint(), 0)


func _on_mount_pressed() -> void:
    if mount.active or not mount_result.is_empty():
        return
    if paste.total_deposited < 1.0:
        _set_status("Squeeze some paste onto the CPU first: hold the left mouse button over it.", 2)
        return
    if not _may_enter(HandState.MOUNTING):
        return
    _park_tool()   # pressing the cooler uses free hands; a syringe must not stay stuck to the cursor
    mount.start()
    holding = false
    wiping = false
    wipe_button.button_pressed = false
    _set_status("Press now! Hold the left mouse button over the socket (or Space). Pressure builds slowly and eases off when you let go. Release once CPU covered passes the line; stop too late and paste squeezes out. Then click the lever beside the socket to lock the cooler down.", 0)
    time_up_told = false


# Thermal paste or toothpaste. Only while the CPU is bare: the two are never mixed.
func _on_material_toggled() -> void:
    var want: String = "toothpaste" if material_button.button_pressed else "thermal"
    if paste.total_deposited > 0.0 or mount.active or not mount_result.is_empty():
        material_button.set_pressed_no_signal(paste.material == "toothpaste")
        _set_status("Wipe the CPU clean (or press Clear all paste) before switching what you squeeze.", 2)
        return
    paste.material = want
    _refresh_material_button()
    if want == "toothpaste":
        _set_status("Toothpaste in the syringe. It is free and looks the part, but it is stiffer, so press harder, and it cools badly. The customer pays for a real repaste: this is a scam.", 2)
    else:
        _set_status("Thermal paste in the syringe ($%d, paid when you complete the repaste)." % int(PasteMaterials.material("thermal")["cost"]), 0)


func _refresh_material_button() -> void:
    var kind: Dictionary = PasteMaterials.material(paste.material)
    material_button.text = "Paste: thermal ($%d)" % int(kind["cost"]) if paste.material == "thermal" else "Paste: TOOTHPASTE (scam)"
    material_button.set_pressed_no_signal(paste.material == "toothpaste")


# Complete repaste: only a PERFECT or GOOD ENOUGH mount can be completed.
func _on_complete_pressed() -> void:
    if mount.active or mount_result.is_empty():
        return
    var result: Dictionary = GameState.complete_repaste(paste.material)
    if not result["ok"]:
        _set_status(str(result["message"]) + " Wipe the paste off (cloth or Clear all paste) and try again.", 3)
        return
    _sound("cooler.complete",{"material":paste.material,"grade":str(GameState.job["paste_grade"])})
    if paste.material == "toothpaste":
        _set_status("Repaste \"complete\": toothpaste under the cooler. The customer will pay for thermal paste. It will pass today's check but run hotter and dry out.", 2)
    else:
        _set_status("Repaste complete: %s with thermal paste ($%d). Run the final check in the shop." % [str(GameState.job["paste_grade"]), int(result["cost"])], 1)


func _on_clear_pressed() -> void:
    if mount.active:
        return
    paste.clear()
    mount_result = {}
    live_stats = {"coverage": 0.0, "overflow": 0.0}
    paste_dirty = true
    GameState.clear_paste()
    _set_status("All paste cleared. Squeeze a new blob onto the CPU.", 0)


func _cloth_is_square() -> bool:
    return GameState.has_upgrade("square_cloth")


func _select_dispense() -> void:
    if not _equip_tool(Ids.SYRINGE,_pointer()):
        return
    wiping = false
    holding = false
    wipe_button.set_pressed_no_signal(false)
    _set_status("Syringe selected. Hold on the CPU to apply paste; select cloth to wipe.", 0)
    queue_redraw()


func _on_wipe_toggled() -> void:
    if not _may_enter(HandState.USING_TOOL):
        wipe_button.set_pressed_no_signal(wiping)   # the toggle stays as it was; the hands are busy
        return
    wiping = wipe_button.button_pressed
    _equip_tool(Ids.CLOTH if wiping else Ids.SYRINGE,_pointer())
    holding = false
    var shape: String = "square cloth" if _cloth_is_square() else "cloth"
    if wiping:
        _set_status("Ready: hold the left mouse button and rub over the paste to wipe it off with the %s. A thick blob takes about a second of rubbing. Click the button again to put it away." % shape, 0)
    elif mount_result.is_empty():
        _set_status("Cloth put away. Squeeze paste with the left mouse button, then mount the cooler.", 0)
    else:
        _set_status("Cloth put away. The cooler is still mounted: wipe the paste off first to squeeze more.", 0)


func _cancel_unlocked_mount() -> void:
    if not mount.active: return
    mount.finish()
    mount_result = {}
    GameState.clear_paste()
    _sound("cooler.cancel")


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


func _input(event: InputEvent) -> void:
    if is_instance_valid(replacement_panel) and replacement_panel.visible: return
    if event is InputEventMouseMotion and turning_with_mouse:
        turn_travel += (event as InputEventMouseMotion).relative.x
        var steps: int = int(turn_travel / TURN_DRAG_PIXELS)
        if steps != 0:
            turn_travel -= float(steps) * TURN_DRAG_PIXELS
            tools.rotate_steps(steps)
    if event is InputEventMouseMotion:
        var now: int = Time.get_ticks_msec()
        if pointer_tick > 0:
            event_velocity = event_velocity.lerp(((event.position-pointer_event)/maxf(0.008,float(now-pointer_tick)/1000.0)).limit_length(2200),0.6)
        pointer_tick = now
        pointer_event = event.position
    if event is InputEventMouseButton:
        var mb: InputEventMouseButton = event
        if stage == STAGE_CLEAN and mb.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
            if not mb.pressed and clamp_button == mb.button_index:
                tools.move_clamp(mb.position)
                var clicked: bool = clamp_press.distance_to(mb.position) < 5.0
                tools.end_clamp_drag()
                if clicked and clamp_button == MOUSE_BUTTON_LEFT:
                    tools.unclamp_hose()
                    _sound("clamp.release")
                clamp_button = 0
                holding = false
                return
            if mb.pressed and tools.hose_grab < 0 and _may_enter(HandState.DRAGGING_CLAMP) and tools.begin_clamp_drag(mb.position):
                clamp_button = mb.button_index
                clamp_press = mb.position
                holding = false
                return
        # Middle mouse turns the held tool: spin the wheel, or hold the middle button and drag sideways.
        if mb.button_index == MOUSE_BUTTON_MIDDLE:
            turning_with_mouse = mb.pressed
            turn_travel = 0.0
            return
        if mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
            tools.rotate_held(-1 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
            return
        # The clamp never steals a held-tool click. Empty hands can unclip it.
        if mb.button_index == MOUSE_BUTTON_RIGHT and not mb.pressed and tools.hose_grab >= 0:
            tools.release_hose(mb.position)
            if tools.hose_clamp > 0:
                _sound("clamp.lock")
                _set_status("Hose parked in the clamp. Pick up a tool to keep working; click the clamp with empty hands to release.", 1)
            elif tools.clamp_rect().has_point(mb.position):
                _set_status("That section cannot reach the clamp. Grab farther along the hose and try again.", 2)
            holding = false
            return
        if mb.button_index == MOUSE_BUTTON_RIGHT and (stage == STAGE_PASTE or active_tool != 2 or mb.shift_pressed):
            if mb.pressed:
                var candidate: String = "" if tools.equipped else tools.hit(mb.position,Ids.CLEAN_TOOLS if stage == STAGE_CLEAN else Ids.PASTE_TOOLS)
                var was_equipped: bool = tools.equipped
                if (candidate == "" or mb.shift_pressed) and stage == STAGE_CLEAN and (not tools.equipped or mb.shift_pressed) and _may_enter(HandState.CARRYING_HOSE) and tools.grab_hose(mb.position):
                    if was_equipped: _sound("handling.putdown",{"kind":tools.selected})
                    _sound("hose.grab")
                    holding = false
                    return
                if stage == STAGE_CLEAN and candidate in Ids.CLEAN_TOOLS:
                    _select_tool(Ids.TOOL_SLOT[candidate])
                elif stage == STAGE_PASTE and candidate in Ids.PASTE_TOOLS:
                    if _equip_tool(candidate,mb.position):
                        wiping = candidate == Ids.CLOTH
                        wipe_button.set_pressed_no_signal(wiping)
                if tools.equipped and _may_enter(HandState.THROWING):
                    tools.begin_throw(mb.position)
                elif tools.equipped:
                    # Letting go is always allowed: where a throw is forbidden (mid-mount), the same
                    # right-click sets the tool down gently instead of winding up (_park_tool plays the sound).
                    _park_tool()
            else:
                var was_carrying: bool = tools.carrying
                tools.release_throw(event_velocity if Time.get_ticks_msec()-pointer_tick < 140 else Vector2.ZERO)
                if was_carrying: _sound("handling.putdown",{"kind":tools.selected,"speed":event_velocity.length()})
                holding = false
            return
        if mb.button_index == MOUSE_BUTTON_LEFT:
            # The cooler is secured by physically clicking its retention lever (there is no button for it).
            if mb.pressed and stage == STAGE_PASTE and mount.active and SECURE_LEVER.has_point(mb.position):
                holding = false
                _sound("cooler.lever")
                _finish_mount()
                return
            # Loose items: empty hands pick one up; releasing drops it (on the trash can it is binned).
            if stage == STAGE_CLEAN and not mb.pressed and items.carried >= 0:
                var dropped: Dictionary = items.drop(mb.position, ToolRig.TABLE)
                if bool(dropped.get("trashed", false)):
                    _sound("item.trash",{"kind":dropped.get("kind","")})
                    _set_status("Threw the %s away." % str(dropped.get("kind","item")), 0)
                else:
                    _sound("handling.putdown",{"kind":dropped.get("kind",""),"item":"loose"})
                holding = false
                return
            if mb.pressed and stage == STAGE_CLEAN and _may_enter(HandState.CARRYING_ITEM) and items.pick(mb.position):
                _sound("handling.pickup",{"kind":items.kinds[items.carried],"item":"loose"})
                holding = false
                return
            # The spool beside the bin: a click rewinds the hose (empty hands or a held tool both work).
            if mb.pressed and stage == STAGE_CLEAN and Layout.BENCH_SPOOL.has_point(mb.position) \
                    and hand_state() in [HandState.FREE, HandState.USING_TOOL]:
                tools.rewind_hose()
                _sound("hose.rewind")
                _set_status("Rewound the hose onto its spool: it lies neatly from the bin again.", 0)
                holding = false
                return
            # In explicit parts mode, tools lying on a component must not steal its click.
            if stage == STAGE_CLEAN and active_tool == 2:
                if mb.pressed: _begin_part_drag(mb.position)
                else: _finish_part_drag(mb.position)
                holding = false
                return
            if mb.pressed:
                # With a tool in hand a left click always uses it (it never swaps to a tool lying next to it).
                var resting: String = "" if tools.equipped else tools.hit(mb.position,Ids.CLEAN_TOOLS if stage == STAGE_CLEAN else Ids.PASTE_TOOLS)
                if resting != "" and ToolRig.TABLE.has_point(mb.position) and resting in (Ids.CLEAN_TOOLS if stage == STAGE_CLEAN else Ids.PASTE_TOOLS):
                    if stage == STAGE_CLEAN and resting in Ids.CLEAN_TOOLS:
                        _select_tool(Ids.TOOL_SLOT[resting])
                    elif stage == STAGE_PASTE and resting in Ids.PASTE_TOOLS:
                        if _equip_tool(resting,mb.position):
                            wiping = resting == Ids.CLOTH
                            wipe_button.set_pressed_no_signal(wiping)
                    # The pickup press is also the beginning of this tool stroke. Waiting for
                    # a second click made every freshly picked-up tool look broken.
                    holding = not mount.active
                    return
            if mb.pressed and stage == STAGE_CLEAN and DustBin.RECT.has_point(mb.position):
                _empty_bin()
                holding = false
                return
            if mb.pressed:
                holding = _work_rect().has_point(mb.position) and not mount.active
                if holding and stage == STAGE_PASTE and not wiping and not mount_result.is_empty():
                    _set_status("The cooler is already mounted. Wipe the paste off with the cloth, or press Clear all paste, before squeezing more.", 2)
            else:
                holding = false
    elif event is InputEventKey:
        var key: InputEventKey = event
        if key.pressed and key.keycode == KEY_Q:
            tools.rotate_held(-1)   # holding the key repeats, so the tool keeps turning
        elif key.pressed and key.keycode == KEY_E:
            tools.rotate_held(1)
        if key.pressed and not key.echo:
            if stage == STAGE_CLEAN:
                if key.keycode == KEY_1:
                    _select_tool(DustSim.TOOL_VACUUM)
                    (tool_buttons[0] as Button).button_pressed = true
                elif key.keycode == KEY_2:
                    _select_tool(DustSim.TOOL_BRUSH)
                    (tool_buttons[1] as Button).button_pressed = true
                elif key.keycode == KEY_3:
                    _select_tool(2)
                elif key.keycode == KEY_4:
                    _select_tool(3)
            elif key.keycode == KEY_3:
                _select_dispense()


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
    _audio_loop("pc.fan",stage == STAGE_CLEAN,{"cooler_rpm":cooler_rpm,"case_rpm":case_rpm})
    _sync_audio()


func _step_clean(delta: float, mouse: Vector2) -> void:
    access.move(mouse)
    _step_part_motion(delta)
    _sync_part_geometry()
    var modal_open: bool = is_instance_valid(replacement_panel) and replacement_panel.visible
    dust.brush_contacts = PackedVector2Array()
    if active_tool == 1:
        var angle: float = tools.motions[Ids.BRUSH].angle
        for point: Vector2 in tools.brush.tips(): dust.brush_contacts.append(mouse+point.rotated(angle))
    var working: bool = holding and not modal_open and tools.equipped and not tools.carrying and not tools.clamp_dragging
    var vacuum_ok: bool = not (active_tool == DustSim.TOOL_VACUUM and bin.is_full())   # a full bin stops the suction
    dust.step(delta, active_tool, mouse, tools.speed, working and vacuum_ok)
    _audio_loop("vacuum.motor",working and vacuum_ok and active_tool == 0,{"ramp":dust.vac_ramp,"bin_fill":bin.fraction()})
    _audio_loop("brush.contact",working and active_tool == 1 and dust.last_brush_contacts > 0,{"speed":tools.speed.length(),"contacts":dust.last_brush_contacts})
    _after_dust_step(delta, mouse)
    var target: String = _pick_target(mouse)
    var eligible: bool = active_tool == 3 and working and target != "" and not target in GameState.job["broken_parts"] and GameState.job["state"] != "done" and dust.trapped_count(target) > 0
    _audio_loop("pick.scrape",eligible,{"part":target})
    var stroke: Dictionary = pick.step(delta, target, eligible)
    if not stroke.is_empty():
        if stroke["damaged"]:
            GameState.damage_service_part(target)
            _sound("part.damage",{"kind":target})
            holding = false
            _set_status("SNAP! %s damaged. Move it to the tray, then open Replacements. Equivalent parts cost more; budget parts lower the specification." % target.to_upper(), 3)
        else:
            dust.pick_extract(target)
            _sound("pick.extract",{"kind":target})
            _set_status("Extracted a clump from under %s. %d remain. Another attempt risks damage again." % [target, dust.trapped_count(target)], 2)
        _save_dust()
    if holding or dust.motion_changed:
        dust_dirty = true
    for i in range(zones.size()):
        var now_clean: bool = dust.removed_fraction(i) >= DustZones.CLEAN_AT
        if bool(zone_done[i]) != now_clean:
            zone_done[i] = now_clean
            dust_dirty = true
            if now_clean and not dust.motion_changed: _announce_zone(i)
    if dust_dirty:
        save_timer += delta
        if save_timer >= AUTOSAVE_SECONDS:
            _save_dust()
    # Fan speeds follow how clean their own part is; angle advances by exactly RPM * 360 / 60 per second.
    var target_cooler: float = lerpf(FAN_RPM_DUSTY, FAN_RPM_CLEAN, dust.removed_fraction(cooler_zone))
    var target_case: float = lerpf(FAN_RPM_DUSTY, FAN_RPM_CLEAN, dust.removed_fraction(case_fan_zone))
    if Ids.COOLER in GameState.job["broken_parts"]: target_cooler = 0.0
    cooler_rpm = lerpf(cooler_rpm, target_cooler, 1.0 - exp(-3.0 * delta))
    case_rpm = lerpf(case_rpm, target_case, 1.0 - exp(-3.0 * delta))
    cooler_angle += cooler_rpm * TAU / 60.0 * delta   # RPM to radians per second
    case_angle += case_rpm * TAU / 60.0 * delta


# Tools and loose parts lying on the bench collide as rotated boxes. Held things push others away and are
# never pushed. The solid pieces also become obstacles the vacuum hose has to lie around.
func _step_pieces() -> void:
    var visible_tools: Array = Ids.CLEAN_TOOLS if stage == STAGE_CLEAN else Ids.PASTE_TOOLS
    var pieces: Array = tools.collision_pieces(visible_tools)
    if stage == STAGE_CLEAN and not (is_instance_valid(replacement_panel) and replacement_panel.visible):
        pieces.append_array(_part_pieces())
    PieceCollision.resolve(pieces)
    tools.apply_collisions(pieces)
    _apply_part_collisions(pieces)
    var fitted: Array = []
    if stage == STAGE_CLEAN:
        for id: String in ServiceAccess.MOVABLE:
            if id in access.removed_ids() or access.dragging == id: continue
            var home: Rect2 = access.homes[id]
            fitted.append({"id": id, "center": home.get_center(), "angle": 0.0, "half": home.size * 0.5})
    tools.set_hose_obstacles(pieces, fitted)



func _part_pieces() -> Array:
    var out: Array = []
    for id: String in ServiceAccess.MOVABLE:
        var dragging: bool = access.dragging == id
        if not dragging and not id in access.removed_ids(): continue
        var motion: RefCounted = part_motions[id]
        var body: RefCounted = part_bodies.get(id)
        out.append({"id": id, "kind": "part", "center": motion.center, "angle": motion.angle,
            "half": access.homes[id].size * 0.5,
            "velocity": motion.velocity if dragging else (Vector2.ZERO if body == null else body.velocity),
            "spin": 0.0 if (dragging or body == null) else body.angular_velocity,
            "inv_mass": 0.0 if dragging else 1.0 / float(PART_MASS[id]),
            "solid": dragging or body == null or not body.active or body.height < ToolRig.SOLID_HEIGHT,
            "touched": false})
    return out


func _apply_part_collisions(pieces: Array) -> void:
    for piece: Dictionary in pieces:
        if piece["kind"] != "part" or not bool(piece["touched"]): continue
        var id: String = piece["id"]
        if access.dragging == id: continue
        var body: RefCounted = part_bodies.get(id)
        if body == null:
            body = TableBody.new()
            part_bodies[id] = body
        var was_active: bool = body.active
        body.half_size = access.homes[id].size * 0.5
        body.center = piece["center"]
        body.angle = piece["angle"]
        body.velocity = piece["velocity"]
        body.angular_velocity = piece["spin"]
        if not was_active:
            body.height = 0.0
            body.vertical_velocity = 0.0
            body.active = true
        part_motions[id].center = body.center
        part_motions[id].angle = body.angle


# Things that follow from one dust step: the bin fills, kicked dust sends up motes, motes float.
func _after_dust_step(delta: float, nozzle: Vector2) -> void:
    var swallowed: float = dust.take_swallowed()
    tools.flow.add(swallowed)   # swallowed dust rides the hose; it fills the bin when it arrives
    var suction_now: float = dust.vac_ramp if active_tool == DustSim.TOOL_VACUUM else 0.0
    var arrived: float = tools.flow.step(delta, suction_now, DustBin.CAPACITY - bin.fill)
    if arrived > 0.0:
        bin.add(arrived)
        if bin.is_full() and not bin_notified:
            bin_notified = true
            _sound("bin.full")
            _set_status("The dust bin is full! Click the bin (bottom right of the bench) to empty it, then keep vacuuming.", 2)
    _audio_loop("vacuum.dust",active_tool == 0 and holding and tools.equipped and not bin.is_full() and (swallowed > 0.0 or tools.flow.count() > 0),{"units":swallowed,"carried":tools.flow.carried()})
    _refresh_vacuum_status()
    for point: Vector2 in dust.kicked:
        motes.spawn(point, tools.speed.limit_length(200.0) * 0.15, 3, 45.0)
    var suction: float = dust.vac_ramp if active_tool == DustSim.TOOL_VACUUM else 0.0
    motes.step(delta, dust, nozzle, suction)


# A blocked vacuum is a persistent state, independent of transient tool hints.
func _refresh_vacuum_status() -> void:
    if not is_instance_valid(vacuum_status): return
    var full: bool = bin.is_full()
    vacuum_status.text = "BIN FULL — suction paused. Empty bin to continue." if full else "Vacuum ready  /  bin %d%%" % roundi(bin.fraction()*100.0)
    vacuum_status.add_theme_color_override("font_color",TONE_COLORS[2] if full else TONE_COLORS[0])
    empty_bin_button.text = "Empty bin (%d%%)" % roundi(bin.fraction()*100.0)
    empty_bin_button.disabled = bin.fill <= 0.0
    empty_bin_button.add_theme_color_override("font_color",TONE_COLORS[2] if full else TONE_COLORS[0])


func _empty_bin() -> void:
    var had: float = bin.empty()
    if had > 0.0: _sound("bin.empty",{"units":had})
    bin_notified = false
    _refresh_vacuum_status()
    if had <= 0.0:
        _set_status("The dust bin is already empty.", 0)
    else:
        _set_status("Emptied the dust bin (%d units of dust). The vacuum is ready again." % roundi(had), 1)


func _announce_zone(i: int) -> void:
    var z: Dictionary = zones[i]
    if _done_count() == zones.size():
        _set_status("%s is clean. That was the last part: the whole PC is clean! Move on to step 2: apply thermal paste." % z["label"], 1)
    else:
        _set_status("%s is clean (%d of %d parts). Keep going: the other parts still count." % [z["label"], _done_count(), zones.size()], 1)


func _step_paste(delta: float, mouse: Vector2) -> void:
    if mount.active:
        _step_mount(delta, mouse)
    elif holding and tools.equipped and not tools.carrying and wiping:
        var wcell: Vector2 = (mouse - PASTE_ORIGIN) / float(PASTE_CELL)
        var removed: float = paste.wipe(wcell.x, wcell.y, WIPE_RADIUS_CELLS, WIPE_STRENGTH, _cloth_is_square())
        _audio_loop("cloth.wipe",_work_rect().has_point(mouse),{"speed":tools.speed.length(),"removed":removed})
        if removed > 0.0:
            paste_dirty = true
            # Tidying the paste that squeezed out BESIDE the CPU never costs the result; only wiping
            # the CPU itself does (0.20.0 fix: the user cleaned the overflow after pulling the lever
            # and lost the grade, so Complete repaste went dark).
            if paste.last_wipe_on_cpu > 0.0 and (not mount_result.is_empty() or str(GameState.job["paste_grade"]) != ""):
                mount_result = {}
                live_stats = {"coverage": 0.0, "overflow": 0.0}
                GameState.clear_paste()
                _set_status("Grade cleared because the paste on the CPU is being wiped off. Keep wiping, or squeeze fresh paste once the CPU is clean.", 0)
    elif holding and tools.equipped and not tools.carrying and mount_result.is_empty():
        var cell: Vector2 = (mouse - PASTE_ORIGIN) / float(PASTE_CELL)
        if cell.x >= 0.0 and cell.y >= 0.0 and cell.x < PasteSim.GRID and cell.y < PasteSim.GRID:
            if str(GameState.job["paste_grade"]) != "":
                GameState.clear_paste()
            paste.deposit(cell.x, cell.y, DEPOSIT_RATE * delta)
            _audio_loop("paste.squeeze",true,{"material":paste.material,"rate":DEPOSIT_RATE})
            paste_dirty = true
    mount_button.disabled = mount.active
    wipe_button.disabled = mount.active
    clear_button.disabled = mount.active
    material_button.disabled = mount.active
    var done: bool = bool(GameState.job["paste_done"])
    complete_button.visible = true
    complete_button.disabled = mount.active or done or not GameState.can_complete_repaste()
    wipe_button.text = "Tool: cloth (switch to syringe)" if wiping else "Tool: syringe (switch to cloth)"
    complete_button.tooltip_text = "Lock the cooler with its lever and obtain a good result before completing."
    complete_button.text = "Repaste complete" if done else ("Complete repaste" if GameState.can_complete_repaste() else "Complete repaste")
    if paste_dirty:
        _refresh_paste_image()
        paste_dirty = false


func _step_mount(delta: float, mouse: Vector2) -> void:
    var pressing: bool = Input.is_key_pressed(KEY_SPACE) or (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _work_rect().has_point(mouse))
    if scripted_pressing is bool: pressing = scripted_pressing   # automated playtest only
    var expired: bool = mount.step(delta, pressing, paste)
    _audio_loop("cooler.press",pressing and not expired,{"pressure":mount.pressure})
    live_stats = paste.measure()
    paste_dirty = true
    if expired and not time_up_told:
        time_up_told = true
        _set_status("Time is up: the paste has set. Click the lever beside the socket to lock the cooler down.", 2)

func _finish_mount() -> void:
    if not mount.active:
        return
    mount.finish()
    mount_result = paste.evaluate()
    live_stats = {"coverage": mount_result["coverage"], "overflow": mount_result["overflow"]}
    access.set_removed(Ids.COOLER, false)
    GameState.job["removed_parts"] = access.removed_ids()
    _sync_part_geometry()
    GameState.set_paste(mount_result)
    paste_dirty = true
    var cov: float = mount_result["coverage"]
    var over: float = mount_result["overflow"]
    var text: String = "%s\n%s\nCoverage %d%%, squeezed out %d%%. Cooler lifted so you can inspect: red = bare CPU, orange = squeezed out." % [mount_result["grade"], mount_result["message"], roundi(cov * 100.0), roundi(over * 100.0)]
    _set_status(text, mount_result["tone"])


func _refresh_paste_image() -> void:
    var show_result: bool = not mount_result.is_empty()
    PasteRenderer.refresh_image(paste, paste_image, paste_texture, show_result, show_result or mount.active)

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
    draw_rect(Layout.SCREEN, COLOR_BG)
    if stage == STAGE_CLEAN:
        _draw_pc()
        _text(Vector2(PANEL_X,155),"TOOLS",12)
        _text(Vector2(PANEL_X,216),"MAINTENANCE",12)
        _draw_dust()
        CleaningRenderer.draw_bin(self, bin, DustBin.RECT.has_point(get_global_mouse_position()))
        CleaningRenderer.draw_spool(self, Layout.BENCH_SPOOL.has_point(get_global_mouse_position()))
        CleaningRenderer.draw_trash(self, items.carried >= 0 and Layout.BENCH_TRASH.has_point(get_global_mouse_position()))
        CleaningRenderer.draw_items(self, items)
        CleaningRenderer.draw_motes(self, motes)
        _draw_clean_panel()
        _draw_clean_cursor()
        _text(Vector2(40,690),"v%s / %s / %d visible dust groups / %s" % [GameState.game_version(),loaded_job_id,dust.visible_count(),"CLEANED SAVE: continue paste or choose New dirty PC" if _done_count() == zones.size() else "saved progress resumed"],13)
    else:
        _draw_paste_stage()
        _draw_paste_panel()
        _draw_paste_cursor()


func _zone_rect(i: int) -> Rect2:
    var z: Dictionary = zones[i]
    var r: Rect2 = z["rect"]
    r.position += PC_ORIGIN
    return r


func _part_rects() -> Dictionary:
    var out: Dictionary = {}
    for id: String in ServiceAccess.MOVABLE:
        var center: Vector2 = part_motions[id].center
        if part_bodies.has(id): center.y -= part_bodies[id].height
        var size: Vector2 = (access.homes[id] as Rect2).size
        out[id] = Rect2(center-size*0.5,size)
    return out

func _part_poses() -> Dictionary:
    var out: Dictionary = {}
    var rects: Dictionary = _part_rects()
    for id: String in ServiceAccess.MOVABLE:
        out[id] = {"center":rects[id].get_center(),"angle":part_motions[id].angle,"shadow":part_motions[id].center+Vector2(3,5)}
    return out

func _sync_part_geometry() -> void:
    if part_motions.is_empty(): return
    var poses: Dictionary = _part_poses()
    for id: String in ServiceAccess.MOVABLE:
        var index: int = DustZones.index_of(id)
        var old: Dictionary = previous_poses.get(id,{"center":access.homes[id].get_center(),"angle":0.0})
        dust.transform_zone(index,old["center"],poses[id]["center"],poses[id]["angle"]-old["angle"])
    previous_poses = poses
    var key: String = str(access.removed_ids())
    if key != blocker_key:
        dust.set_blockers(access.blockers())
        blocker_key = key

func _finish_part_drag(point: Vector2) -> void:
    var id: String = access.dragging
    var flick: bool = id != "" and event_velocity.length() > 450 and Time.get_ticks_msec()-pointer_tick < 140 and ToolRig.TABLE.has_point(point) and not access.homes[id].grow(12).has_point(point)
    var result: Dictionary = access.finish(ServiceAccess.TRAY.get_center() if flick else point)
    if id != "":
        _sound("handling.install" if result.get("changed",false) and not id in access.removed_ids() else "handling.putdown",{"kind":id,"item":"component"})
        if flick:
            var body := TableBody.new()
            body.launch(part_motions[id].center,event_velocity*0.8,access.homes[id].size*0.5,part_motions[id].angle)
            part_bodies[id] = body
        else: part_bodies.erase(id)
    _sync_part_geometry()
    if result.get("changed", false):
        GameState.job["removed_parts"] = access.removed_ids()
        if result["id"] == Ids.COOLER and Ids.COOLER in access.removed_ids():
            GameState.clear_paste()
            paste.clear()
            mount_result = {}
            paste_dirty = true
        _save_dust()
    if result.get("message", "") != "": _set_status(result["message"], 0)

func _draw_pc() -> void:
    draw_rect(ServiceAccess.TRAY, Color("283644"))
    draw_rect(ServiceAccess.TRAY, Color("9ba7a9"), false, 2.0)
    _text(ServiceAccess.TRAY.position + Vector2(8, 16), "SERVICE TRAY / move parts here, then refit", 13)
    PCRenderer.draw_pc(self, str(GameState.job.get("layout", "tower")), Rect2(PC_ORIGIN, DustZones.AREA_SIZE), zones, case_angle, cooler_angle, _part_rects(), _part_poses())
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
    var locked: bool = not mount.active and (not mount_result.is_empty() or bool(GameState.job["paste_done"]))
    PasteRenderer.draw_lever(self, SECURE_LEVER, mount.active, locked, SECURE_LEVER.has_point(get_global_mouse_position()), vfx_time)

func _draw_paste_panel() -> void:
    PasteRenderer.draw_panel(self, paste, PANEL_X, mount, not mount_result.is_empty(), live_stats)

func _draw_paste_cursor() -> void:
    ToolRenderer.draw_tools(self,tools,Ids.PASTE_TOOLS)

func _pick_target(point: Vector2) -> String:
    for id: String in ServiceAccess.MOVABLE:
        if not id in access.removed_ids() and access.current_rect(id).has_point(point): return id
    return ""

func _build_replacements() -> void:
    replacement_panel = Panel.new()
    replacement_panel.position = Vector2(680, 250)
    replacement_panel.size = Vector2(570, 385)
    replacement_panel.z_index = 20
    var background := StyleBoxFlat.new()
    background.bg_color = Color("202b38")
    background.border_color = Color("8eafc3")
    background.set_border_width_all(2)
    replacement_panel.add_theme_stylebox_override("panel", background)
    add_child(replacement_panel)
    replacement_summary = Label.new()
    replacement_summary.position = Vector2(16, 12)
    replacement_summary.size = Vector2(538, 140)
    replacement_summary.add_theme_font_size_override("font_size", 14)
    replacement_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    replacement_panel.add_child(replacement_summary)
    for id: String in ServiceParts.IDS:
        for tier: String in ["similar", "budget"]:
            var choice: Dictionary = ServiceParts.option(id, tier)
            var i: int = replacement_buttons.size()
            var button := Button.new()
            button.position = Vector2(16, 156 + i * 41)
            button.size = Vector2(350, 36)
            button.add_theme_font_size_override("font_size", 14)
            var disabled_style := StyleBoxFlat.new()
            disabled_style.bg_color = Color("29333f")
            button.add_theme_stylebox_override("disabled", disabled_style)
            button.text = "%s / $%d / %d%% of original%s" % [choice["label"], choice["cost"], choice["performance"], " / +8 C" if id == Ids.COOLER and tier == "budget" else ""]
            button.pressed.connect(_replace_part.bind(id, tier))
            replacement_panel.add_child(button)
            var buy := Button.new()
            buy.position = Vector2(374,156+i*41)
            buy.size = Vector2(178,36)
            buy.text = "Buy +1 / $%d" % choice["cost"]
            buy.pressed.connect(_buy_stock.bind(id,tier))
            replacement_panel.add_child(buy)
            replacement_buttons.append({"button":button,"buy":buy,"id":id,"tier":tier})
    var close := Button.new()
    close.position = Vector2(16, 332)
    close.size = Vector2(250, 36)
    close.text = "Close / return to bench"
    close.pressed.connect(func() -> void: replacement_panel.hide())
    replacement_panel.add_child(close)
    var inventory_button := Button.new()
    inventory_button.position = Vector2(282,332)
    inventory_button.size = Vector2(270,36)
    inventory_button.text = "Open player inventory"
    inventory_button.pressed.connect(func() -> void:
        _save_dust()
        get_tree().change_scene_to_file("res://scenes/main.tscn"))
    replacement_panel.add_child(inventory_button)
    replacement_panel.hide()

func _open_replacements() -> void:
    if not _may_enter(HandState.PANEL_OPEN):
        return
    holding = false
    access.dragging = ""
    _sync_part_geometry()
    pick.reset()
    replacement_panel.show()
    _refresh_replacements()

func _refresh_replacements() -> void:
    replacement_summary.text = "PLAYER INVENTORY / cash $%d\nFit consumes one owned part. Buy adds to the same drawer shown in Hardware bench. Remove damaged part first.\nBudget = 65%% specification. Cooler downgrade: +8 C.\nDamaged: %s\nCustomer-owned broken parts are retained separately." % [GameState.money,str(GameState.job["broken_parts"])]
    for item: Dictionary in replacement_buttons:
        var id: String = item["id"]
        var choice: Dictionary = ServiceParts.option(id,item["tier"])
        var count: int = GameState.stock_count(id,item["tier"])
        item["button"].text = "Fit %s / owned %d" % [choice["label"],count]
        item["button"].disabled = count == 0 or not id in GameState.job["broken_parts"] or not id in GameState.job["removed_parts"] or GameState.job["state"] == "done"
        item["buy"].disabled = GameState.money < int(choice["cost"])


func _replace_part(id: String, tier: String) -> void:
    if not GameState.replace_service_part(id, tier): return
    access.set_removed(id, false)
    _sync_part_geometry()
    if id == Ids.COOLER:
        paste.clear()
        mount_result = {}
        paste_dirty = true
    _refresh_replacements()
    _set_status("Replacement fitted. %s" % ("Budget part: 65% of the original specification." if tier == "budget" else "Original specification restored."), 2 if tier == "budget" else 1)


func _buy_stock(id: String, tier: String) -> void:
    if not GameState.buy_service_stock(id,tier):
        _set_status("Purchase needs enough cash and empty inventory cells.",2)
    _refresh_replacements()

func _new_ticket() -> void:
    _save_dust()
    GameState.start_repair_ticket()
    get_tree().reload_current_scene()

func _init_part_motion() -> void:
    var saved: Dictionary = GameState.job.get("service_table_positions",{})
    for id: String in ServiceAccess.MOVABLE:
        var motion := PartMotion.new()
        motion.snap(access.current_rect(id).get_center(),0)
        if id in access.removed_ids() and saved.get(id) is Dictionary:
            var xy: Variant = saved[id].get("center",[])
            if xy is Array and xy.size() == 2 and typeof(xy[0]) in [TYPE_INT,TYPE_FLOAT] and typeof(xy[1]) in [TYPE_INT,TYPE_FLOAT]:
                var body := TableBody.new()
                body.center = Vector2(float(xy[0]),float(xy[1])).clamp(ToolRig.TABLE.position+access.homes[id].size*0.5,ToolRig.TABLE.end-access.homes[id].size*0.5)
                body.half_size = access.homes[id].size*0.5
                body.angle = float(saved[id].get("angle",0.0))
                part_bodies[id] = body
                motion.center = body.center
                motion.angle = body.angle
        part_motions[id] = motion

func _step_part_motion(delta: float) -> void:
    for id: String in ServiceAccess.MOVABLE:
        var motion: RefCounted = part_motions[id]
        if access.dragging == id:
            part_bodies.erase(id)
            motion.step(delta,access.current_rect(id).get_center(),0,true)
        elif part_bodies.has(id) and id in access.removed_ids():
            var body: RefCounted = part_bodies[id]
            body.step(delta,ToolRig.TABLE)
            motion.center = body.center
            motion.angle = body.angle
        else:
            part_bodies.erase(id)
            motion.step(delta,access.current_rect(id).get_center(),0,false)

func _save_service_positions() -> void:
    var saved: Dictionary = {}
    for id: String in part_bodies:
        if id in access.removed_ids():
            var center: Vector2 = part_bodies[id].center
            saved[id] = {"center":[center.x,center.y],"angle":part_bodies[id].angle}
    GameState.job["service_table_positions"] = saved


func _begin_part_drag(point: Vector2) -> bool:
    if not _may_enter(HandState.DRAGGING_PART):
        return false
    var rects: Dictionary = _part_rects()
    for id: String in ServiceAccess.MOVABLE:
        var hit_rect: Rect2 = rects[id]
        if part_bodies.has(id):
            var edge: Vector2 = part_bodies[id].extent()
            hit_rect = Rect2(rects[id].get_center()-edge,edge*2)
        if not hit_rect.has_point(point): continue
        access.begin(access.current_rect(id).get_center())
        access.drag_rect = rects[id]
        access.drag_offset = point-rects[id].position
        part_bodies.erase(id)
        _sound("handling.pickup",{"kind":id,"item":"component"})
        return true
    return false
