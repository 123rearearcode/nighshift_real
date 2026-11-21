# Room storage — local 0.33.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User-approved D118. No code pushed or merged.

## Try it

Use the 0.33.0 project/ZIP, F5 → Storage rack. The storage screen itself shows its version.
The integrated 0.32.0 build still contains the old crash; it will not change until updated.

- Every rack, cabinet and tool board exists together in one room. There are no rack-list buttons.
- Add furniture, then choose a model. Its real button is distinct from the other choices.
- Click a furniture title to select it; drag the title to move the whole unit to an empty floor bay.
- The room has four columns and two rows: eight units maximum. The floor grid enforces this.
- Wheel zooms around the pointer; middle-drag pans. Fit furniture shows occupied bays; Entire room
  shows all eight bays. Parts/furniture held at an edge gently scroll the view.
- Drag parts between shelves, rotate with R/E or Q. Invalid releases return to the last allocation.
  Escape/focus loss cancels. Moving furniture preserves all its item/shelf/rotation identities.
- Select an empty unit's title, then Remove empty. Occupied/last furniture stays safe.
- Arrange shelves, Refresh contents and Save layout still work. Excess items remain in Waiting
  for space; the arrows page only waiting items, never furniture.

Existing real PC/tool/part sources, ownership reservations, free furniture and the separate shop-stock
hardware bench remain as before. No new purchase prices, room upgrades or capacity-enforcement hooks.
Equal one-bay furniture footprints and the room size are provisional, ready for later design changes.

## Why this fixes the crash

The old furniture Button's pressed handler rebuilt the sidebar and called free() on itself while
Godot was still emitting its signal. The local fix had not been pushed, so Claude's integration of
the remote PRs still contained that code. The new UI has no such buttons or rebuild loop: room
furniture is data drawn on a canvas. Toolbar/popup controls are built once and persist through updates.

The old popup also positioned several Buttons directly inside PopupPanel (a Container), which
forces them into overlapping rectangles. It now has one MarginContainer/VBox tree. Native viewport
mouse tests check both separate rectangles and which furniture a real click actually creates.
Details hover text is bounded in a scrolling inspector; it cannot grow over the toolbar.

## Save contract

`user://nightshift_storage.json`, version **2**. Each unit has id, model and room_cell [x,y]. Item
placements retain the existing source id → furniture id/shelf/cell/rotation contract. No ownership,
customer state, money or canonical item records are copied into this layout file.

Version-1 units are assigned distinct row-first bays. Valid version-2 cells are reserved first;
missing, duplicated, extreme or invalid coordinates are rehomed without dropping units or their
contents. Up to eight units migrate, matching the old limit. Integer validation rejects extreme
JSON numbers before conversion. Saved room positions roundtrip through the real safe writer/reader.
A version above 2 remains read-only and is not overwritten. Layout edits autosave; failed writes
are reported and keep the previous safe file. Camera position is presentation-only and not saved.
Downgrading to the old storage reader makes version 2 read-only, rather than overwriting it.

## Scope and review

Based on main 0.32.0. This retains Claude's CPU projection/shared part-state integration and native
salvage fixes. No edits to bench_view.gd, tool_rig.gd, game_state.gd, shop_view.gd or WORK_PLAN.md.
Review of already-merged PR #39 is in REVIEW_0_32.md and its conversation. B16/B20 fixed here;
B19 (night-workshop ticket text overlapping the report) is a separate open finding for Claude.

Tests use actual Button/viewport mouse dispatch, repeated sort/save/refresh/add/select/remove,
room movement/overlap/limits, camera transforms, v1 migration, malformed positions, read-only guards,
source identity and layout saves. Existing bench/night/salvage suites stay enabled. User should
check the graphical scale and feel in Godot; no absolute guarantee about every possible crash.

Code remains local under the user's prior no-push instruction. Do not publish or merge automatically.
