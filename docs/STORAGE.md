# General storage rack — trials 0.29.0–0.30.0

**Current menu rules: MENU_NAVIGATION.md (0.42.0, user approved).** Slot → workbench directly,
common Repair/Hardware/Monitor tabs, named Room back, Activities/Pause, Arrange room mode and
Continue. Older menu, sandbox and service-hub instructions below are historical; current hardware
is connected (D131). This supersedes paths only, preserving current game/app mechanics.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 16 November 2026.

**Current 0.36.0 override:** PC selection is now a drag-in workshop slot in the room; the old
service-hub dropdown is removed. Activity Workshop opens the room. All night work screens use
one top-right Activities exit. See ROOM_WORKSHOP.md; older instructions below are historical.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.

**Current local 0.33.0 override:** see STORAGE_ROOM.md. Furniture is a direct 4×2 room layout with
zoom/pan, no selector list/pages. Schema 2 migrates old allocations and records room cells. The
controls/format below describe historical 0.29/0.30 behavior. No code pushed for this local update.


Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
14 November 2026, Europe/Bucharest. User-requested gameplay feature (D109).

## Try it

Open project.godot with Godot 4.7.2. Press F5, then **Storage rack** on the right of the menu.
The scene uses the current in-memory demo save: load/return from the shop first if desired.

- Drag a PC, part or tool to a shelf. Its preview turns green when it fits, red otherwise.
- R/E rotate clockwise; Q counterclockwise. The grab point follows the rotation.
- Release outside a valid space, press Escape or lose window focus: the move cancels safely.
- Hover for generic part name, model, size, condition and owner. A dot marks installed stock.
- **Add furniture** opens three choices. Pick a steel rack (PCs/tools/parts), parts cabinet
  (shallow component drawers) or tool board. Expansion is free for this prototype, up to eight.
- Two units are visible at a time. Sidebar selects a unit; Tab cycles pages, even while holding.
- Select an empty unit in the sidebar, then **Remove empty unit**. Occupied/last units stay safe.
- **Arrange shelves** repacks current items; **Refresh contents** rereads the real source records.
- Items without room remain in **Waiting for space**, paged with ‹/›. Add room then arrange,
  or drag a waiting item directly. Nothing disappears because the rack fills up.

## Source of truth

0.30.0: New Game → Activities → Workshop selects PCs. Storage returns to Activities.

`storage_sources.gd` reads player_inventory/inventory_layout/current job. It never writes them.
Player-owned RAM/GPU/cooler records retain their existing UID under the `part:` namespace.
Installed shop stock keeps a marked shelf reservation; arranging that reservation does not
uninstall it. Broken loose stock stays visible and is not mislabelled as installed.

The five default tools use stable `tool:kit:` IDs. These refer to the existing included tool kit,
not a new ownership/purchase system. Tools keep their storage allocation while used at the bench.
Customer PCs use run-scoped physical PC IDs from NightSession and disappear after pickup.
Build orders without supplied PCs create no storage tile. Its whole
footprint includes fitted customer parts, so they are not counted twice. It cannot be sold,
claimed or dismantled from this screen. Completed PCs are not retained as phantom stock.

Storage dimensions describe packing space, separately from motherboard socket geometry.
Tower/compact PCs are 8×6/7×5 cells. A rack has three 12×6 shelves, a cabinet three 12×2 drawers,
a tool board one 12×6 surface. These numbers and free furniture are provisional tuning.

## Save contract

`user://nightshift_storage.json`, version 1, contains:
- `units`: furniture id/model records;
- `placements`: source item id → unit, shelf, cell [x,y], rotation (quarter turns).

There are no copied ownership records, money, job state or tool states. SafeStore provides
readback/backup/temporary recovery. Unknown/duplicate furniture and invalid placements are
filtered; missing items are removed by reconciliation, unplaced real items are repacked or
left waiting. A future version opens read-only and is not overwritten. Failed writes are
shown with a retry button. Held moves never alter committed placement until a valid release,
so saving during a move cannot strand an item. Successful moves/furniture edits autosave.
Furniture/layout persists across New game; current source stock is reconciled on next entry.

## Laptop piles — 0.59.1 (D185)

A customer laptop is a 6 x 4 storage item marked `stackable`. It may rest on a desktop or another laptop when
its whole footprint lies on that item, that item is the top of its pile (nothing else on it) and the pile stays
at most three high (`Laptop.STACK_MAX`, the desktop counting). `storage_model._spot()` decides; a piled
placement carries `on` (what it rests on) and `level()` counts the height. Anything with something on it cannot
be picked up or sent back to the room (`blocked()`: "Lift the laptop on top off first"). Automatic placement
(`fill_unplaced`, `place_first`) tries free shelf space first and only then a pile. The save stays version 2:
floor placements are unchanged; a piled one adds `level`, used to restore piles bottom first. The stock room
and the under-counter view draw piles bottom first, each layer a little up and left with a shadow, and pick the
top first.

## Coordination and remaining work

No hot files or customer/shop code changed. The only existing view hook is a new start-menu
button. The storage files are separate, ready for Claude to cross-review before any merge.

The rack is usable now but deliberately does not implement the unapproved full PC model:
player-built PCs, purchasable tool records and globally unique lifetime
PC/visit IDs still need shared canonical records. New games have two repair PCs; legacy saves retain their one actual ticket. See NIGHT_WORKSHOP.md.
Purchase/intake/old drawer limits are unchanged; existing tools and benches work as before.
The next integration is one shared capacity/reservation check used by purchases, intake and
salvage transfer, coordinated with Claude's state work. Do not create a second item database
or silently delete overflow as a shortcut. Hardware installation/motherboard geometry remains
in its existing model, independent of this room-storage grid.

## Verification

`tools/test_storage.gd`: actual source projection and no ownership mutation; fit/overlap/rotation;
cross-furniture movement, drawer/tool restrictions, overflow and expansion; safe cancellation;
JSON roundtrip/invalid saves/backup/future-version/write failure; scene mouse/key handlers,
paging while held, autosave and start-menu entry. Existing suites stay enabled.
Headless checks cannot confirm visual polish, mouse feel or display scaling: user playtest needed.
