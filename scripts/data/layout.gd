# DATA ONLY: where things are on screen, in one place (docs/WORK_PLAN.md Phase 1 step 3).
# The window is 1280 x 720. Values were moved here unchanged from the scripts that used them; those
# scripts keep their old constant names as aliases (e.g. ToolRig.TABLE), so nothing else had to change.
# Physical work areas (table, PC, socket, lever, bin, clamp) are fixed coordinates on purpose: the
# simulations, drawings and click areas must all agree on them.
extends RefCounted

const SCREEN := Rect2(0, 0, 1280, 720)
const SCREEN_SIZE := Vector2(1280, 720)

# Repair bench
const BENCH_TABLE := Rect2(40, 105, 620, 545)       # everything that moves on the bench stays inside this
const BENCH_PC_ORIGIN := Vector2(40, 110)          # top-left of the PC interior drawing
const BENCH_PC_SIZE := Vector2(620, 400)           # size of the PC interior drawing
const BENCH_TRAY := Rect2(40, 540, 620, 110)       # where removed parts lie
const BENCH_BIN := Rect2(582, 540, 72, 52)         # the vacuum's dust bin (also anchors the hose)
const BENCH_CLAMP := Rect2(550, 612, 88, 30)       # the hose clamp
const BENCH_SPOOL := Rect2(508, 544, 64, 44)       # the hose spool beside the bin: click it and it reels the vacuum in
const BENCH_POWER := Rect2(602, 114, 50, 26)       # the PC's power button (top-right of the case): fans stop while it is off
const BENCH_TRASH := Rect2(180, 560, 56, 60)       # the trash can on the tray: drop a carried loose item on it to bin it
const BENCH_CLAMP_POINT := Vector2(594, 627)
const BENCH_SOCKET_ORIGIN := Vector2(120, 150)     # top-left of the CPU paste grid
const BENCH_SOCKET_CELL: int = 8                   # px per paste cell
const BENCH_LEVER := Rect2(552, 250, 44, 210)      # the cooler's retention lever beside the socket
const PANEL_X: float = 700.0                       # left edge of the bench's side panel

# Shop
const SHOP_JOB_CARD := Rect2(40, 105, 600, 340)
const SHOP_LOWER_CARD := Rect2(40, 455, 600, 215)

# Hardware bench (workshop)
const WORKSHOP_PC := Rect2(60, 165, 640, 420)
const WORKSHOP_DRAWER := Rect2(800, 100, 440, 330)
const WORKSHOP_DRAWER_GRID_ORIGIN := Vector2(826, 148)
const WORKSHOP_STATUS := Rect2(800, 450, 440, 110)

# Start screen
const START_CARD := Rect2(410, 108, 460, 500)
