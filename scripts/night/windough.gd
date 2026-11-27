# 0.59.0 (D182): the customer PC's screen on the diagnostic monitor. The user, 28 November 2026: "the PC desktop
# boot screen. It has to look somewhat like a goofy windows. We will have it booted in our own boot tool." Picked:
# "Windough 98" (Begin button, a dough-ball logo) on the shop's "NightBoot USB" stick; the drafts (revision 2,
# tools/art_batch_e/windough.py) were approved ("approved, create PR"). On revision 1: "make sure the info of the
# bios doesnt give anything away".
#
# Power on: the BIOS (nothing about the parts) -> the NightBoot menu, counting down (a click or Enter starts now)
# -> the Windough 98 splash, dough rising along a tray -> the desktop. A PC that does not start only shows the
# monitor's NO SIGNAL. On the desktop the shop's apps are icons (click selects, double click or Enter opens), each
# opens in a window whose buttons are the monitor's own app buttons, so every rule, night minute and Findings entry
# stays in software_view.gd. Begin opens a menu (Programs, readme, Shut Down turns the PC off); the tray clock is
# the night clock. Everything is pixel art at 423 x 258 drawn at exactly 2x, with a faint CRT scanline on top.
extends Control

const Clock = preload("res://scripts/rules/night_clock.gd")
const RoomArt = preload("res://scripts/rooms/room_art.gd")
const README := "res://art/ui/windough/README.md"   # the approved pictures sit beside it (manifest.json)
const W := 423
const H := 258
const TASKBAR := 15
const BIOS_SECONDS := 1.6
const COUNTDOWN := 3
const SPLASH_SECONDS := 2.4
const DOUBLE_CLICK := 0.45

const TEAL := Color8(24, 120, 120)
const GREY := Color8(192, 192, 192)
const LIGHT := Color8(255, 255, 255)
const SHADE := Color8(128, 128, 128)
const DARK := Color8(34, 34, 34)
const NAVY := Color8(0, 0, 128)
const TITLE_END := Color8(24, 136, 208)
const INK := Color8(24, 20, 18)
const DOUGH := Color8(236, 206, 150)
const DOUGH_SHADE := Color8(208, 166, 106)
const DOUGH_HI := Color8(252, 236, 200)

# Desktop icons, in the approved order (art/ui/windough/icon_<kind>.png).
const ICONS: Array = [["boot", "Boot check"], ["hardware", "Hardware check"], ["taskmanajer", "Task Manajer"], ["vapor", "Vapor"],
    ["game", "Counter Stroke 2"], ["stress", "Stress lab"], ["overclock", "Overclocker"], ["readme", "readme.txt"], ["bin", "Bin of Regret"]]
const PROGRAMS: Array = ["boot", "hardware", "taskmanajer", "vapor", "game", "stress", "overclock"]
const MENU: Array = [["hardware", "Programs", true], ["readme", "Documents", true], ["taskmanajer", "Settings", false],
    ["readme", "Help (none)", false], ["", "", false], ["boot", "Shut Down...", false]]
const TITLES: Dictionary = {"boot": "Boot check", "hardware": "Hardware check", "taskmanajer": "Task Manajer", "vapor": "Vapor",
    "game": "Counter Stroke 2", "stress": "Stress lab", "overclock": "Overclocker", "readme": "readme.txt - Notepad",
    "bin": "Bin of Regret", "settings": "Settings", "help": "Help"}
const BOXES: Dictionary = {"overclock": Rect2i(60, 16, 354, 220), "readme": Rect2i(96, 30, 290, 170), "bin": Rect2i(120, 60, 230, 110),
    "settings": Rect2i(120, 60, 230, 110), "help": Rect2i(120, 60, 230, 110)}
const DEFAULT_BOX := Rect2i(122, 16, 292, 220)
# A note from the last technician (placeholder story hook; the user writes the story).
const README_NOTE := "To whoever gets this job after me:\n\nThe stick boots anything with a plug. Leave their disk alone.\n\nWrite down what you actually measured. Customers talk, and so do reviews.\n\nAnd don't sell their old parts as new. Somebody always finds out.\n\n- V."

var monitor: Node                      # software_view.gd: apps, buttons, output, clock, busy state
var state: String = "off"              # off, no_signal, bios, nightboot, splash, desktop
var stage_time: float = 0.0
var instant: bool = false              # tests: power on straight to the desktop
var open_app: String = ""
var result_app: String = ""            # the app whose button produced the monitor's current output
var selected: int = -1
var menu_open: bool = false
var hover_menu: String = ""
var hover_program: String = ""
var scroll: int = 0
var _last_click: float = -10.0
var _last_icon: int = -1
var tex: Dictionary = {}
var selected_icons: Dictionary = {}
var font_chars: String = ""
var cursor_tex: Texture2D


func _ready() -> void:
    name = "Windough"
    position = Vector2(48, 104)
    size = Vector2(W * 2, H * 2)
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    mouse_filter = Control.MOUSE_FILTER_STOP
    for file: String in ["logo_dough", "wallpaper", "taskbar", "begin_button", "begin_button_pressed", "bios", "no_signal",
            "nightboot_base", "splash_windough_base", "font5x7", "cursor", "icon_usb", "icon_speaker"]:
        tex[file] = RoomArt.texture(art(file + ".png"))
    for pair: Array in ICONS:
        var kind: String = pair[0]
        tex["icon_" + kind] = RoomArt.texture(art("icon_" + kind + ".png"))
        selected_icons[kind] = _checkered(tex["icon_" + kind])
    var info: Variant = JSON.parse_string(FileAccess.get_file_as_string(art("font5x7.json"))) if FileAccess.file_exists(art("font5x7.json")) else null
    font_chars = str((info as Dictionary).get("chars", "")) if info is Dictionary else ""
    var arrow: Texture2D = tex.get("cursor")
    if arrow != null:
        var big: Image = arrow.get_image()
        big.resize(big.get_width() * 2, big.get_height() * 2, Image.INTERPOLATE_NEAREST)
        cursor_tex = ImageTexture.create_from_image(big)
    mouse_entered.connect(_pointer_in)
    mouse_exited.connect(_pointer_out)


func _pointer_in() -> void:
    if cursor_tex != null: Input.set_custom_mouse_cursor(cursor_tex)


func _pointer_out() -> void:
    Input.set_custom_mouse_cursor(null)


static func art(file: String) -> String:
    return README.get_base_dir() + "/" + file


func _exit_tree() -> void:
    Input.set_custom_mouse_cursor(null)


# All the approved pictures are installed.
func available() -> bool:
    for key: String in tex:
        if tex[key] == null: return false
    return font_chars != ""


# A selected icon: the approved picture with a navy checkerboard over its pixels (as the drafts draw it).
static func _checkered(source: Texture2D) -> Texture2D:
    if source == null: return null
    var img: Image = source.get_image()
    img.convert(Image.FORMAT_RGBA8)
    for y in range(img.get_height()):
        for x in range(img.get_width()):
            if img.get_pixel(x, y).a > 0.0 and (x + y) % 2 == 0: img.set_pixel(x, y, NAVY)
    return ImageTexture.create_from_image(img)


# ---------------------------------------------------------------- power and the boot

func power_on(boots: bool, skip: bool = false) -> void:
    open_app = ""
    menu_open = false
    selected = -1
    stage_time = 0.0
    state = "no_signal" if not boots else ("desktop" if skip or instant else "bios")
    queue_redraw()


func power_off() -> void:
    state = "off"
    open_app = ""
    menu_open = false
    queue_redraw()


func skip_boot() -> void:
    if state in ["bios", "nightboot", "splash"]: _enter("desktop")


func booting() -> bool:
    return state in ["bios", "nightboot", "splash"]


func _enter(next: String) -> void:
    state = next
    stage_time = 0.0
    queue_redraw()


func countdown() -> int:
    return maxi(1, COUNTDOWN - int(stage_time))


func _process(delta: float) -> void:
    if booting():
        stage_time += delta
        if state == "bios" and stage_time >= BIOS_SECONDS: _enter("nightboot")
        elif state == "nightboot" and stage_time >= float(COUNTDOWN): _enter("splash")
        elif state == "splash" and stage_time >= SPLASH_SECONDS: _enter("desktop")
        queue_redraw()
    elif state == "desktop" and monitor != null and float(monitor.get("busy_left")) > 0.0:
        queue_redraw()


# ---------------------------------------------------------------- the apps (buttons are the monitor's own)

func app_buttons(app: String) -> Array:
    if monitor == null: return []
    match app:
        "boot": return [["Run", monitor.boot_button]]
        "hardware": return [["Run", monitor.hardware_button]]
        "taskmanajer": return [["Scan", monitor.scan_button], ["Remove threat", monitor.remove_button]]
        "vapor": return [[_vapor_label(), monitor.buy_button]]
        "game": return [["Run test", monitor.run_button]]
        "stress": return [["Long test", monitor.long_button]]
        "overclock": return [["M-", monitor.mult_down], ["M+", monitor.mult_up], ["V-", monitor.volt_down], ["V+", monitor.volt_up], ["Quick stress", monitor.quick_button]]
    return []


func _vapor_label() -> String:
    var t: String = str(monitor.buy_button.text)
    if t.contains("owned"): return "Owned"
    var at: int = t.rfind("$")
    return "Buy " + t.substr(at) if at >= 0 else "Buy"


func app_text(app: String) -> String:
    var out: String = str(monitor.output.text) if monitor != null else ""
    var mine: bool = result_app == app and out != ""
    match app:
        "boot": return out if mine else "Boot check: does the PC start, and how? Press Run."
        "hardware": return out if mine else "Hardware check: is every part in place and the cooler locked? Press Run."
        "taskmanajer": return out if mine else "Task Manajer: scan for anything that should not be running. Remove threat starts the cleanup."
        "vapor": return "Vapor: games on the shop's licence.\n\n%s" % str(monitor.buy_button.text) + ("\n\n" + out if mine else "")
        "game": return out if mine else "Counter Stroke 2: play a match and measure the frame rate. Takes %d night minutes." % Clock.GAME_TEST_MINUTES
        "stress": return out if mine else "Stress lab: %s. The only way to see instability before the customer does." % str(monitor.long_button.text)
        "overclock": return str(monitor.oc_label.text) + "\n\n" + (out if mine else "Push the CPU harder. Heat shows in every check; instability only in a stress test.")
        "readme": return README_NOTE
        "bin": return "The Bin of Regret is empty. For now."
        "settings": return "There is nothing to set. It is 1998."
        "help": return "There is no help. There was never any help."
    return ""


func open(app: String) -> void:
    if state != "desktop": return
    open_app = app
    scroll = 0
    menu_open = false
    queue_redraw()


func close_window() -> void:
    open_app = ""
    queue_redraw()


func window_box(app: String) -> Rect2i:
    return BOXES.get(app, DEFAULT_BOX)


# The window's parts, in native pixels: title bar, close button, body, buttons [[label, Button, Rect2i]], status.
func layout(app: String) -> Dictionary:
    var b: Rect2i = window_box(app)
    var x0: int = b.position.x
    var y0: int = b.position.y
    var x1: int = b.end.x - 1
    var y1: int = b.end.y - 1
    var buttons: Array = app_buttons(app)
    buttons.append(["Close", null])
    var status: bool = app in PROGRAMS
    var bottom: int = y1 - (17 if status else 4) - 18
    var placed: Array = []
    var bx: int = x1 - 6
    for i in range(buttons.size() - 1, -1, -1):
        var label: String = buttons[i][0]
        var w: int = maxi(48, text_width(label) + 14)
        placed.push_front([label, buttons[i][1], Rect2i(bx - w, bottom + 4, w + 1, 14)])
        bx -= w + 6
    var tb: Rect2i = Rect2i(x0 + 3, y0 + 3, x1 - x0 - 5, 14)
    var close_x: int = (x1 - 3) - 13
    return {"box": b, "title": tb, "close": Rect2i(close_x, y0 + 5, 11, 10), "minimise": Rect2i(close_x - 26, y0 + 5, 11, 10),
        "body": Rect2i(x0 + 4, y0 + 31, x1 - 4 - (x0 + 4) + 1, bottom - (y0 + 31) + 1), "buttons": placed,
        "status": Rect2i(x0 + 4, y1 - 14, x1 - 4 - (x0 + 4) + 1, 11) if status else Rect2i()}


func status_text(app: String) -> String:
    if monitor == null: return ""
    var left: float = float(monitor.get("busy_left"))
    var total: float = float(monitor.get("busy_total"))
    if left > 0.0 and total > 0.0: return "Working ... %d%%" % int(100.0 * (1.0 - left / total))
    return "Done. Written in Findings." if result_app == app and str(monitor.output.text) != "" else "Ready."


# The button a test can click: its centre in screen pixels (Rect2() if not shown).
func button_rect(label: String) -> Rect2:
    if open_app == "": return Rect2()
    for entry: Array in layout(open_app)["buttons"]:
        if entry[0] == label:
            var r: Rect2i = entry[2]
            return Rect2(global_position + Vector2(r.position) * 2.0, Vector2(r.size) * 2.0)
    return Rect2()


func icon_rect(index: int) -> Rect2i:
    var spot: Vector2i = icon_spot(index)
    return Rect2i(spot.x + 8, spot.y, 44, 44)


static func icon_spot(index: int) -> Vector2i:
    return Vector2i(4 + (index / 5) * 64, 5 + (index % 5) * 46)


# ---------------------------------------------------------------- the Begin menu

func menu_box() -> Rect2i:
    var top: int = H - TASKBAR - 4 - 6 - MENU.size() * 16 + 10
    return Rect2i(2, top, 131, H - TASKBAR - 1 - top + 1)


func menu_items() -> Array:
    var box: Rect2i = menu_box()
    var out: Array = []
    var y: int = box.position.y + 5
    for item: Array in MENU:
        if str(item[1]) == "":
            y += 8
            continue
        out.append([item[1], Rect2i(box.position.x + 20, y - 1, box.end.x - 1 - 3 - (box.position.x + 20) + 1, 15), item[0], item[2], y])
        y += 16
    return out


func submenu_box() -> Rect2i:
    var box: Rect2i = menu_box()
    var h: int = PROGRAMS.size() * 15 + 5
    var top: int = mini(box.position.y + 3, H - TASKBAR - 1 - h)
    return Rect2i(box.end.x - 1 - 2, top, 121, h + 1)


func program_rect(i: int) -> Rect2i:
    var sub: Rect2i = submenu_box()
    return Rect2i(sub.position.x + 2, sub.position.y + 3 + i * 15 - 1, sub.size.x - 5, 15)


func _menu_action(label: String) -> void:
    match label:
        "Documents": open("readme")
        "Settings": open("settings")
        "Help (none)": open("help")
        "Shut Down...":
            menu_open = false
            if monitor != null and monitor.has_method("_power"): monitor._power()


# ---------------------------------------------------------------- input

func _gui_input(event: InputEvent) -> void:
    var motion := event as InputEventMouseMotion
    if motion != null:
        if menu_open: _hover(Vector2i(motion.position / 2.0))
        return
    var mb := event as InputEventMouseButton
    if mb == null or not mb.pressed: return
    var p := Vector2i(mb.position / 2.0)
    if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        var body: Rect2i = layout(open_app)["body"] if open_app != "" else Rect2i()
        if state == "desktop" and body.has_point(p):
            scroll = maxi(0, scroll + (1 if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1))
            queue_redraw()
            accept_event()
        return
    if mb.button_index != MOUSE_BUTTON_LEFT: return
    accept_event()
    match state:
        "bios": _enter("nightboot")
        "nightboot": _enter("splash")
        "splash": _enter("desktop")
        "desktop": _click(p, mb.double_click)


func _click(p: Vector2i, double: bool) -> void:
    if menu_open:
        _hover(p)
        if hover_program != "":
            open(hover_program)
            return
        for item: Array in menu_items():
            if Rect2i(item[1]).has_point(p):
                if not bool(item[3]) or item[0] == "Documents": _menu_action(item[0])
                return
        menu_open = false
        queue_redraw()
        if Rect2i(2, H - TASKBAR + 2, 48, 12).has_point(p): return
    if Rect2i(2, H - TASKBAR + 2, 48, 12).has_point(p):
        menu_open = true
        hover_menu = ""
        hover_program = ""
        queue_redraw()
        return
    if open_app != "":
        var parts: Dictionary = layout(open_app)
        if Rect2i(parts["box"]).has_point(p):
            if Rect2i(parts["close"]).has_point(p) or Rect2i(parts["minimise"]).has_point(p):
                close_window()
                return
            for entry: Array in parts["buttons"]:
                if not Rect2i(entry[2]).has_point(p): continue
                if entry[1] == null:
                    close_window()
                else:
                    var target: Button = entry[1]
                    if not target.disabled:
                        result_app = open_app
                        scroll = 0
                        target.pressed.emit()
                queue_redraw()
                return
            return
    for i in range(ICONS.size()):
        if icon_rect(i).has_point(p):
            var now: float = Time.get_ticks_msec() / 1000.0
            if double or (i == _last_icon and now - _last_click <= DOUBLE_CLICK):
                open(ICONS[i][0])
                _last_icon = -1
            else:
                selected = i
                _last_icon = i
                _last_click = now
            queue_redraw()
            return
    selected = -1
    queue_redraw()


func _hover(p: Vector2i) -> void:
    var before: String = hover_menu + "|" + hover_program
    if hover_menu == "Programs" and submenu_box().has_point(p):
        hover_program = ""
        for i in range(PROGRAMS.size()):
            if program_rect(i).has_point(p): hover_program = PROGRAMS[i]
    else:
        hover_program = ""
        var found: String = ""
        for item: Array in menu_items():
            if Rect2i(item[1]).has_point(p): found = item[0]
        if found != "" or not submenu_box().has_point(p): hover_menu = found
    if before != hover_menu + "|" + hover_program: queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
    var k := event as InputEventKey
    if not visible or k == null or not k.pressed or k.echo: return
    var enter: bool = k.keycode == KEY_ENTER or k.keycode == KEY_KP_ENTER
    if state == "nightboot" and enter:
        _enter("splash")
        get_viewport().set_input_as_handled()
    elif state == "desktop" and enter and selected >= 0 and open_app == "":
        open(ICONS[selected][0])
        get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- drawing (native pixels, 2x)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
    if state == "off" or not available(): return
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(2, 2))
    match state:
        "no_signal": _pic("no_signal", Vector2.ZERO)
        "bios": _pic("bios", Vector2.ZERO)
        "nightboot": _draw_nightboot()
        "splash": _draw_splash()
        "desktop": _draw_desktop()
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    for y in range(1, int(size.y), 2):          # a faint CRT scanline (every second screen row 10 % darker)
        draw_rect(Rect2(0, y, size.x, 1), Color(0, 0, 0, 0.1))


func _pic(key: String, at: Vector2) -> void:
    var t: Texture2D = tex.get(key)
    if t != null: draw_texture(t, at)


func _draw_nightboot() -> void:
    _pic("nightboot_base", Vector2.ZERO)
    var t: String = "Starting Windough 98 diagnostics in %d ..." % countdown()
    _text(t, (W - text_width(t)) / 2, 190, LIGHT)
    var hint: String = "Click or press Enter to start now"
    _text(hint, (W - text_width(hint)) / 2, 204, Color8(130, 140, 220))


func _draw_splash() -> void:
    _pic("splash_windough_base", Vector2.ZERO)
    var fraction: float = clampf(stage_time / SPLASH_SECONDS, 0.0, 1.0)
    var x0: int = W / 2 - 90
    var x1: int = W / 2 + 90
    var y0: int = 176
    var y1: int = 188
    var end: int = x0 + 2 + int(float(x1 - x0 - 4) * fraction)
    for x in range(x0 + 2, end):                 # the dough rising along the tray (the drafts' rule)
        var bump: int = 1 if (x / 5) % 2 != 0 else 0
        _rect(x, y0 + 3 - bump, x, y1 - 2, DOUGH if (x / 5) % 3 != 0 else DOUGH_SHADE)
    if end > x0 + 2: _rect(x0 + 2, y0 + 3, end, y0 + 3, DOUGH_HI)


func _draw_desktop() -> void:
    _pic("wallpaper", Vector2.ZERO)
    for i in range(ICONS.size()):
        var kind: String = ICONS[i][0]
        var spot: Vector2i = icon_spot(i)
        var icon: Texture2D = selected_icons.get(kind) if i == selected else tex.get("icon_" + kind)
        if icon != null: draw_texture(icon, Vector2(spot.x + 18, spot.y))
        var parts: Array = word_wrap(str(ICONS[i][1]), 9)
        for k in range(parts.size()):
            var part: String = parts[k]
            var tx: int = spot.x + 30 - text_width(part) / 2
            if i == selected:
                draw_rect(Rect2(tx - 1, spot.y + 25 + k * 9, text_width(part) + 2, 9), NAVY)
                _text(part, tx, spot.y + 26 + k * 9, LIGHT)
            else:
                _text(part, tx, spot.y + 26 + k * 9, LIGHT, 1, false, Color8(8, 44, 44))
    _pic("taskbar", Vector2(0, H - TASKBAR))
    _pic("begin_button_pressed" if menu_open else "begin_button", Vector2(2, H - TASKBAR + 2))
    var clock: String = Clock.label(int(GameState.night_minutes)) if Engine.get_main_loop() != null else "00:00"
    _text(clock, W - 34, H - TASKBAR + 5, INK)
    if open_app != "":
        _taskbar_button(54, str(TITLES.get(open_app, open_app)))
        _draw_window(open_app)
    if menu_open: _draw_menu()


func _taskbar_button(x: int, label: String) -> void:
    _rect(x, H - TASKBAR + 2, x + 104, H - 2, Color8(212, 212, 212))
    _bevel(x, H - TASKBAR + 2, x + 104, H - 2, false)
    _text(label.left(15), x + 5, H - TASKBAR + 5, INK, 1, true)


func _draw_window(app: String) -> void:
    var parts: Dictionary = layout(app)
    var b: Rect2i = parts["box"]
    var x0: int = b.position.x
    var y0: int = b.position.y
    var x1: int = b.end.x - 1
    var y1: int = b.end.y - 1
    _rect(x0, y0, x1, y1, GREY)
    _bevel(x0, y0, x1, y1, true)
    _title_bar(x0 + 3, y0 + 3, x1 - 3, y0 + 16, str(TITLES.get(app, app)), _icon_for(app))
    var mx: int = x0 + 6
    for m: String in (["File", "Edit", "Panic"] if app != "readme" else ["File", "Edit", "Search", "Help"]):
        _text(m, mx, y0 + 20, INK)
        _rect(mx, y0 + 28, mx + 4, y0 + 28, INK)
        mx += text_width(m) + 10
    var body: Rect2i = parts["body"]
    _rect(body.position.x, body.position.y, body.end.x - 1, body.end.y - 1, LIGHT)
    _bevel(body.position.x, body.position.y, body.end.x - 1, body.end.y - 1, false)
    var y: int = body.position.y + 5
    var chars: int = (body.size.x - 10) / 6
    var skipped: int = 0
    for line: String in app_text(app).split("\n"):
        if line == "":
            if skipped >= scroll: y += 5
            continue
        for part: String in word_wrap(line, chars):
            if skipped < scroll:
                skipped += 1
                continue
            if y + 8 > body.end.y - 3: break
            _text(part, body.position.x + 5, y, INK)
            y += 9
    for entry: Array in parts["buttons"]:
        var r: Rect2i = entry[2]
        var enabled: bool = entry[1] == null or not entry[1].disabled
        _button(r.position.x, r.position.y, r.end.x - 1, r.end.y - 1, entry[0], enabled)
    if app in PROGRAMS:
        var s: Rect2i = parts["status"]
        _bevel(s.position.x, s.position.y, s.end.x - 1, s.end.y - 1, false)
        _text(status_text(app), x0 + 7, y1 - 12, INK)


func _icon_for(app: String) -> Texture2D:
    if app in ["settings", "help"]: return tex.get("icon_readme")
    return tex.get("icon_" + app)


func _title_bar(x0: int, y0: int, x1: int, y1: int, title: String, icon: Texture2D) -> void:
    for x in range(x0, x1 + 1):                  # the 98-style gradient, in 4-pixel steps
        var t: float = float(((x - x0) / 4) * 4) / float(maxi(1, x1 - x0))
        draw_rect(Rect2(x, y0, 1, y1 - y0 + 1), Color8(int(NAVY.r8 + (TITLE_END.r8 - NAVY.r8) * t), int(NAVY.g8 + (TITLE_END.g8 - NAVY.g8) * t), int(NAVY.b8 + (TITLE_END.b8 - NAVY.b8) * t)))
    var tx: int = x0 + 3
    if icon != null:
        draw_texture_rect(icon, Rect2(x0 + 2, y0 + 1, 11, 11), false)
        tx = x0 + 16
    _text(title, tx, y0 + 3, LIGHT, 1, true)
    for k in range(3):                           # close, maximise, minimise
        var bx: int = x1 - 13 - k * 12 - (2 if k > 0 else 0)
        _rect(bx, y0 + 2, bx + 10, y1 - 2, GREY)
        _bevel(bx, y0 + 2, bx + 10, y1 - 2, true)
        if k == 1:
            _frame(bx + 2, y0 + 4, bx + 8, y1 - 4, INK)
            _rect(bx + 2, y0 + 5, bx + 8, y0 + 5, INK)
        elif k == 2:
            _rect(bx + 2, y1 - 5, bx + 6, y1 - 4, INK)
        else:
            for o in range(2):
                for s in range(5):
                    _rect(bx + 2 + o + s, y0 + 4 + s, bx + 2 + o + s, y0 + 4 + s, INK)
                    _rect(bx + 6 + o - s, y0 + 4 + s, bx + 6 + o - s, y0 + 4 + s, INK)


func _button(x0: int, y0: int, x1: int, y1: int, label: String, enabled: bool) -> void:
    _rect(x0, y0, x1, y1, GREY)
    _bevel(x0, y0, x1, y1, true)
    var w: int = text_width(label)
    var tx: int = (x0 + x1) / 2 - w / 2
    var ty: int = (y0 + y1) / 2 - 3
    if not enabled: _text(label, tx + 1, ty + 1, LIGHT)
    _text(label, tx, ty, INK if enabled else SHADE)


func _draw_menu() -> void:
    var box: Rect2i = menu_box()
    var x0: int = box.position.x
    var y0: int = box.position.y
    var x1: int = box.end.x - 1
    var y1: int = box.end.y - 1
    _rect(x0, y0, x1, y1, GREY)
    _bevel(x0, y0, x1, y1, true)
    for y in range(y0 + 3, y1 - 2):
        var t: float = float(y - y0) / float(y1 - y0)
        _rect(x0 + 3, y, x0 + 18, y, Color8(int(30 * t), int(60 * t), int(128 + 40 * t)))
    # the banner, bottom to top: "Windough" white, "98" orange
    draw_set_transform(Vector2(x0 + 6, y1 - 84 + 80) * 2.0, -PI / 2.0, Vector2(2, 2))
    _text("Windough", 0, 1, LIGHT, 1, true)
    _text("98", 58, 1, Color8(250, 170, 50), 1, true)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(2, 2))
    var y: int = y0 + 5
    for item: Array in MENU:
        if str(item[1]) == "":
            _rect(x0 + 22, y + 3, x1 - 4, y + 3, SHADE)
            _rect(x0 + 22, y + 4, x1 - 4, y + 4, LIGHT)
            y += 8
            continue
        var lit: bool = hover_menu == item[1]
        if lit: _rect(x0 + 20, y - 1, x1 - 3, y + 13, NAVY)
        var icon: Texture2D = tex.get("icon_" + str(item[0]))
        if icon != null: draw_texture_rect(icon, Rect2(x0 + 23, y, 12, 12), false)
        _text(item[1], x0 + 39, y + 3, LIGHT if lit else INK)
        if bool(item[2]): _text("▸", x1 - 10, y + 3, LIGHT if lit else INK)
        y += 16
    if hover_menu == "Programs":
        var sub: Rect2i = submenu_box()
        _rect(sub.position.x, sub.position.y, sub.end.x - 1, sub.end.y - 1, GREY)
        _bevel(sub.position.x, sub.position.y, sub.end.x - 1, sub.end.y - 1, true)
        for k in range(PROGRAMS.size()):
            var kind: String = PROGRAMS[k]
            var yy: int = sub.position.y + 3 + k * 15
            var on: bool = hover_program == kind
            if on:
                var r: Rect2i = program_rect(k)
                _rect(r.position.x, r.position.y, r.end.x - 1, r.end.y - 1, NAVY)
            var icon: Texture2D = tex.get("icon_" + kind)
            if icon != null: draw_texture_rect(icon, Rect2(sub.position.x + 4, yy, 12, 12), false)
            _text(str(TITLES[kind]), sub.position.x + 20, yy + 3, LIGHT if on else INK)


# ---------------------------------------------------------------- pixel helpers (inclusive boxes, like the drafts)

func _rect(x0: int, y0: int, x1: int, y1: int, colour: Color) -> void:
    draw_rect(Rect2(x0, y0, x1 - x0 + 1, y1 - y0 + 1), colour)


func _frame(x0: int, y0: int, x1: int, y1: int, colour: Color) -> void:
    _rect(x0, y0, x1, y0, colour)
    _rect(x0, y1, x1, y1, colour)
    _rect(x0, y0, x0, y1, colour)
    _rect(x1, y0, x1, y1, colour)


func _bevel(x0: int, y0: int, x1: int, y1: int, raised: bool) -> void:
    var a: Color = LIGHT if raised else SHADE
    var b: Color = DARK if raised else LIGHT
    _rect(x0, y0, x1, y0, a)
    _rect(x0, y0, x0, y1, a)
    _rect(x0, y1, x1, y1, b)
    _rect(x1, y0, x1, y1, b)
    if raised:
        _rect(x0 + 1, y1 - 1, x1 - 1, y1 - 1, SHADE)
        _rect(x1 - 1, y0 + 1, x1 - 1, y1 - 1, SHADE)
    else:
        _rect(x0 + 1, y0 + 1, x1 - 1, y0 + 1, DARK)
        _rect(x0 + 1, y0 + 1, x0 + 1, y1 - 1, DARK)


# The 5 x 7 font (art/ui/windough/font5x7.png): 6 x 8 cells, 16 a row, drawn in any colour.
func _text(s: String, x: int, y: int, colour: Color, scale: int = 1, bold: bool = false, shadow: Variant = null) -> void:
    var atlas: Texture2D = tex.get("font5x7")
    if atlas == null: return
    var adv: int = 7 if bold else 6
    var layers: Array = [[shadow, scale]] if shadow != null else []
    layers.append([colour, 0])
    for layer: Array in layers:
        for i in range(s.length()):
            var at: int = font_chars.find(s[i])
            if at < 0: at = font_chars.find("?")
            if at < 0 or s[i] == " ": continue
            var src := Rect2((at % 16) * 6, (at / 16) * 8, 5, 7)
            for b in range(2 if bold else 1):
                draw_texture_rect_region(atlas, Rect2(x + (i * adv + b) * scale + layer[1], y + layer[1], 5 * scale, 7 * scale), src, layer[0])


static func text_width(s: String, scale: int = 1, bold: bool = false) -> int:
    return s.length() * (7 if bold else 6) * scale - scale


static func word_wrap(s: String, chars: int) -> Array:
    var out: Array = []
    var line: String = ""
    for word: String in s.split(" "):
        if line != "" and line.length() + 1 + word.length() > chars:
            out.append(line)
            line = word
        else:
            line = (line + " " + word).strip_edges()
    if line != "": out.append(line)
    return out
