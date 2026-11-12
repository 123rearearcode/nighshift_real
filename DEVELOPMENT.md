# Nightshift Godot Project - Development Guide

For any AI or human contributor. Read this, then the newest entry in `CHANGELOG.md`, then
`README.md`, then the scripts you will touch. Design rules live in the five core documents under docs/
(PROJECT_BRIEF.md, DESIGN.md, DECISIONS.md, CURRENT_STATE.md, ROADMAP.md); this project is the small
Godot foundation trial authorised under them. It is not an approved engine migration and it preserves D01–D32 and records later workflow/design updates in docs/DECISIONS.md. Numbers in this project are demo values, not approved balance.

## 1. Version numbering

Format: `MAJOR.MINOR.PATCH`, for example `0.5.1`.

- **Source of truth:** `config/version` in `project.godot`. The shop screen shows it. The newest
  `CHANGELOG.md` entry, the first line of `README.md` and the ZIP file name must agree with it.
  `tools/check_project.py` verifies the first three.
- **MAJOR** stays `0` while this is a trial. `1.0.0` is reserved for when the user declares a real
  production build.
- **MINOR** goes up for a new player-visible feature, a new screen or system, or a change to a data,
  rules or save contract that other code depends on. Resets PATCH to 0.
- **PATCH** goes up for bug fixes, number tuning, visual clarity tweaks, refactors with no behaviour
  change, documentation and tooling.
- **Every delivered change gets a new number**, even documentation only. Never ship a different build
  under a number that was already delivered.
- **Save format** is a separate integer, `GameState.SAVE_FORMAT`. Bump it only when saved data
  changes shape incompatibly, and describe the migration in the changelog.
- **ZIP names** include the version: `nightshift_godot_trial_v0.5.1.zip`. The folder inside is always
  `nightshift_godot_trial`. Keep the previous ZIP as the known working baseline.
- **Not related to the browser prototype.** CURRENT_STATE.md calls the old browser game "prototype
  0.9". That is a different codebase with its own numbering.
- **Several contributors:** each works on a branch (`feature/<short-name>`) and records notes under
  `Unreleased` in the changelog. The integrating contributor assigns the number at merge, commits as
  `v0.6.0: short summary`, and tags the commit `v0.6.0`.

## 2. Logging every change

Every change, however small, goes in `CHANGELOG.md` using the template at the top of that file.

- Record author, base version, type, execution status, what changed, **every file touched** (added,
  modified, deleted, renamed), checks actually run, proposals, known issues, next action.
- Say plainly whether Godot was run, by whom and on which version. Never describe code that has not
  been run in Godot as tested. List a check only if it was performed, with its result.
- Do not rewrite old entries. To fix a mistake, add a dated "Correction" note inside that entry.
- Mark anything the user has not approved as a proposal. New numbers are proposals.
- Keep this file's file map and data contracts (sections 5 and 6) current when files, formats or
  function signatures change, in the same version.

## 3. Release checklist

1. Decide the bump (section 1).
2. Update `config/version` in `project.godot`.
3. Update the first line of `README.md` and any instructions that changed.
4. Write the changelog entry (move notes out of `Unreleased`).
5. Update sections 5 and 6 of this file if files or contracts changed.
6. Run `python3 -I tools/check_project.py` from the project folder. Fix every FAIL.
7. Build `nightshift_godot_trial_vX.Y.Z.zip`.
8. Tell the user what was run and what was not.

## 4. Architecture rules

Layers, from the bottom up. A layer may only use layers listed before it.

| Layer | Folder | Job | Must not |
| --- | --- | --- | --- |
| data | `scripts/data/` | What things are (parts, boards) as plain dictionaries | draw, read input, hold rules |
| rules | `scripts/rules/` | Pure functions: is this allowed, and why not; text for hover cards | draw, read input, hold state |
| sim | `scripts/bench/` | Physics and scoring for cleaning and paste | draw, read input |
| state | `scripts/state/` | The `GameState` autoload: cash, ticket, save/load | draw, know about views |
| view | `scripts/view/` | Drawing, mouse and keyboard input, labels and buttons | decide compatibility or physics |

Screens are built in code on a bare `Node2D`; the `.tscn` files only attach a script. Simulation
runs in `_physics_process` (fixed 60 Hz), drawing happens in `_draw` after `queue_redraw()`.

## 5. File map

Update this table whenever files change. The checker fails if a file is missing from it.

| File | Layer | Purpose |
| --- | --- | --- |
| `project.godot` | config | Settings, `config/version`, main scene `shop.tscn`, autoload `GameState` |
| `.gitignore` | config | Ignores `.godot/` cache and export files |
| `README.md` | docs | How to import and run; what each screen does |
| `HANDOFF.md` | docs | Signed handoff: state, rules for every bot, how to update the changelog, open tasks |
| `AGENTS.md` | docs | Short pointer for any AI agent to the files above |
| `docs/DESIGN_PROPOSALS.md` | docs | Agreed and proposed designs (hub, night time, grid inventory, catalogue fields); not built |
| `CHANGELOG.md` | docs | Full change history and the entry template |
| `STABILISATION.md` | docs | Current checks, persistence risks and proposed bench refactor |
| `docs/PROJECT_BRIEF.md` | docs | Reconciled core project document version 1.4 |
| `docs/DESIGN.md` | docs | Reconciled core project document version 1.4 |
| `docs/ROADMAP.md` | docs | Reconciled core project document version 1.4 |
| `docs/DECISIONS.md` | docs | Reconciled core project document version 1.4 |
| `docs/CURRENT_STATE.md` | docs | Reconciled core project document version 1.4 |
| `DEVELOPMENT.md` | docs | This guide |
| `tools/check_project.py` | tooling | Consistency checker (does not run Godot) |
| `tools/.gdignore` | tooling | Keeps Godot from scanning `tools/` |
| `scenes/shop.tscn` | scene | Main scene, uses `shop_view.gd` |
| `scenes/bench.tscn` | scene | Repair bench (clean + paste), uses `bench_view.gd` |
| `scenes/main.tscn` | scene | Hardware sandbox (free drawer packing, multi-piece slot installation). Legacy name from 0.1.0; renaming is deferred |
| `scripts/state/game_state.gd` | state | Autoload `GameState`: cash, upgrades, one ticket, dust progress, final check, save/load |
| `scripts/rules/layout_rules.gd` | rules | Case/board containment and non-overlap validation |
| `scripts/data/pc_layout.gd` | data | Shared cell-based case/board model profiles and uniform display fitting |
| `scripts/view/pc_renderer.gd` | view | Shared PC/component drawing extracted from bench view |
| `tools/test_regressions.gd` | tooling | Real GDScript regression suite with isolated save path |
| `tools/test_data_schemas.gd` | tooling | Checks every data dictionary has the right keys and types, and that parts, boards and cases agree with each other |
| `scripts/data/component_data.gd` | data | RAM/GPU sandbox samples and demo L-shaped board |
| `scripts/rules/placement_rules.gd` | rules | Placement checks, facings, board validation |
| `scripts/rules/hover_info.gd` | rules | Text for hover cards |
| `scripts/data/dust_zones.gd` | data | The six dusty parts of the PC: rectangles, bundle counts, temperature penalties |
| `scripts/bench/table_body.gd` | sim | Shared edge/floor bounce, spin, drag friction and rest |
| `scripts/bench/brush_shape.gd` | sim | Spring bristle tips/compression; no drawing |
| `scripts/bench/tool_rig.gd` | controller | Five-tool equip/follow/toss/contact rig |
| `scripts/view/tool_renderer.gd` | view | Tool bodies, flexible bristles and shadows |
| `scripts/bench/grid_inventory.gd` | controller | Free drawer footprint packing, multi-piece install/cancel/snapshot |
| `scripts/view/part_motion.gd` | view | Critically damped follow/lift/sway/smooth turns, presentation only |
| `scripts/bench/dust_pick.gd` | sim/controller | Pick stroke timing and per-attempt random risk; injectable rolls for checks |
| `scripts/data/service_parts.gd` | data | Two generic replacement tiers for cooler/GPU; trial only |
| `scripts/bench/service_access.gd` | sim/controller | Service mount/tray geometry and drag state; no drawing/input |
| `scripts/bench/dust_sim.gd` | sim | Dust bundle physics: vacuum suction, brush loosening, per-part progress |
| `scripts/bench/paste_sim.gd` | sim | Paste spreading physics and grading |
| `scripts/view/shop_view.gd` | view | Shop screen: ticket checklist, cash, buttons, version label |
| `scripts/view/bench_view.gd` | view | Repair bench coordinator: input, tools, stage switching, service parts, replacements; delegates drawing to the renderers and mounting to `mount_session.gd` |
| `scripts/view/ui_style.gd` | view | Shared colours, text and progress-bar drawing helpers |
| `scripts/view/paste_renderer.gd` | view | Draws the paste stage, paste picture and paste side panel (presentation only) |
| `scripts/view/cleaning_renderer.gd` | view | Draws dust bundles and the cleaning side panel (presentation only) |
| `scripts/bench/mount_session.gd` | sim/controller | Timed cooler-mounting pressure session; takes a pressing flag, reads no input, draws nothing |
| `scripts/state/save_store.gd` | state | Safe JSON save writing (temp file, read-back, `.bak`) and reading with fallback; GameState decides contents and validation |
| `scripts/view/workshop_view.gd` | view | Hardware sandbox: free arrangement, pickup animation, rotation, fit previews, persisted profiles |
| `scripts/view/hover_card.gd` | view | Draws the fading hover card |

Screen flow: shop (`shop.tscn`) opens the cooler bench (`bench.tscn`) and the hardware bench
(`main.tscn`); both have a button back to the shop. Scene changes use
`get_tree().change_scene_to_file(...)`.

## 6. Data contracts

**Component** (`ComponentData.ram_stick()`): `id` String, `category` String, `display_name` String,
`short_label` String, `connector_type` String (e.g. `DDR4_DIMM`), `footprint` Vector2i in cells,
`details` Array of `[label, value]` pairs for hover cards.

**Board** (`ComponentData.demo_board()`): `id`, `display_name`, `size` Vector2i, `rows` Array of
Strings (`#` = board cell, `.` = cutout; one string per row, `size.x` characters each), `connectors`
Array of connector dictionaries. `PlacementRules.validate_board()` returns a list of problems.

**Connector:** `id`, `label`, `short_label`, `type` (must equal the component's `connector_type`),
`origin` Vector2i, `footprint` Vector2i, optional `allowed_rotations` Array of ints. Connectors must lie
entirely on board cells and must not overlap.

**Facing:** int 0 = Up, 1 = Right, 2 = Down, 3 = Left. Odd facings swap a footprint's width and height
(`PlacementRules.rotated_footprint`). A connector without `allowed_rotations` accepts all four.

**Placement result** (`PlacementRules.check_placement(board, component, rot, cell, occupied)`):
`{ok: bool, connector_id: String, label: String, message: String}`. Checks run in this order: off grid,
cutout, no connector, wrong type, wrong size or orientation, wrong facing, occupied.

**Job** (`GameState.job`): `id`, `customer`, `complaint`, `state` ("open" or "done"), `cleaned` bool,
`dust` Dictionary (zone id -> share removed, 0..1; `cleaned` is true only when every zone is at least `DustZones.CLEAN_AT`, and is recomputed, never set by hand),
`paste_grade` String ("" = none, else PERFECT, GOOD ENOUGH, MESSY, BALD SPOTS or TOO LITTLE),
`paste_coverage` float, `paste_overflow` float, `temp` float (0 = not checked), `payout` int.

**Save file** (`user://nightshift_save.json`): `save_format` int, `game_version` String, `money` int,
`upgrades` Dictionary (id -> true; currently only `square_cloth`), `job` Dictionary. Before 0.5.1 the format was stored as `"version": 1`; the loader still accepts that.
Unknown job keys are ignored and missing keys take defaults. Saves from before 0.7.0 with `cleaned: true`
and no `dust` key load as only the `cooler` zone clean. `upgrades` is additive, so SAVE_FORMAT stays 1.

**Dust zone** (`DustZones.zones()` returns an Array of these): `id` String, `label` String, `rect` Rect2 (local to
a `DustZones.AREA_SIZE` drawing area; the bench screen places that area), `bundles` int, `temp_penalty` float (C
added to the final-check temperature if the part is left fully dusty). `DustZones.CLEAN_AT` = 0.95. Zone ids:
case_fan, cooler, motherboard, gpu, psu, front_filter.

**DustSim API:** `setup(zones, origin, seed)`, `reset()`, `step(delta, tool_id, tool_pos, tool_vel, active)`,
`removed_fraction(zone_index)`, `remaining_fraction()`, `shake_off_zone(zone_index)`,
`apply_progress(zone_index, fraction)`, `clear_all()`, `zone_count()`. A bundle is a chain of 3 to 14 nodes
with a grip; states `STUCK`, `LOOSE`, `GONE`; tools `TOOL_VACUUM`, `TOOL_BRUSH`. Per-bundle arrays are named
`b_*`; `shown` holds node positions to draw. The vacuum only pulls; the brush only lowers grip (to 20%).

**PasteSim API:** `clear()`, `deposit(cx, cy, volume)`, `wipe(cx, cy, radius, strength, square = false) -> float`
(amount removed; `square` uses the larger of the x and y distances), `step(yield_h = YIELD_H) -> float`,
`yield_for_pressure(p)` (static; 0.25 at p 0 down to 0.01 at p 1), `measure() -> {coverage, overflow}`,
`evaluate() -> {coverage, overflow, volume, grade, message, tone}`, `gauge_text()`, `gauge_tone()`.
Grid is 51 x 51; the CPU covers cells 8 to 42 on both axes.

**GameState additions (0.7.0):** `dust_fraction(zone_id)`, `set_dust(fractions)`, `parts_clean_count()`,
`has_upgrade(id)`, `buy_upgrade(id) -> bool`, `UPGRADE_PRICES`. `mark_cleaned()` was removed.

**Mount minigame** (state in `mount_session.gd`, input in `bench_view.gd`, drawing in `paste_renderer.gd`): hold left mouse over the socket or Space to raise pressure
(+0.45 per second), release to lower it (-0.9 per second); each 60 Hz tick runs 3 paste steps at
`yield_for_pressure(pressure)`; 10 s limit (`MountSession.MOUNT_TIME`); Enter or "Secure cooler" finishes early; the grade comes from `evaluate()`.

**Where the numbers live:** physics constants at the top of `dust_sim.gd` and `paste_sim.gd`; per-part dust counts and penalties in `dust_zones.gd`; fan RPM and wipe-cloth constants at the top of `bench_view.gd`; mount-minigame constants at the top of `mount_session.gd`; economy
and final-check constants at the top of `game_state.gd`. All are demo values.

## 7. GDScript conventions (Godot 4.7.2)

- Indent with 4 spaces, never tabs. Godot's own editor inserts tabs by default, so if you edit these
  files inside Godot, use its Edit menu to convert indentation to spaces before saving.
- Type every variable and function signature. Preload other scripts into `const Name = preload(...)`.
- Pure logic is `static func` where possible so it can be checked without a scene.
- Connect signals with `.pressed.connect(callable)`. Build UI in code; keep layout numbers as constants.
- Avoid variable names that shadow engine classes or built-ins.
- Keep one responsibility per file (section 4). Do not put rules or physics in a view.

## 8. Verification rules

- Claude's original sandbox had no Godot; Codex review used Godot 4.6.3, not the user's real version 4.7.2. `tools/check_project.py` is a hygiene check, not a test.
- On any machine with Godot 4.7.2: open the project, press F5, read the Output and Debugger panels,
  and click through every screen you changed. Report the exact red error text with file and line.
- A contributor who cannot run Godot must say so in the changelog entry.
- Never mark a task complete on the strength of reading code alone.

## 9. Handoff template

Copy into the changelog's Unreleased section, or send with a finished branch.

```
Outcome:
Files changed (A/M/D/R):
Decisions proposed (not approved):
Checks actually performed and results:
Godot run? (who, which version, result):
Known failures and assumptions:
Exact next action:
```


## 0.8.0 contracts and checks
GameState job gains additive layout (tower default). save_path defaults to SAVE_PATH; test suite temporarily uses a separate path. Save format remains 1; old dust fractions migrate without resetting money or completed state. DustSim adds b_remaining (per-bundle residual weight); apply_progress restores fractional weight, eliminating upward rounding on repeated reload. Weight is not a new saved array; per-zone fractions remain the contract.
PCLayout.profile(id) returns case size/depth, board data/origin and fan/PSU/filter logical rectangles. display(model, area) returns uniform cell size/origin/case_rect; cell_rect/board_rect/connector_rect project cells to view coordinates. LayoutRules.validate checks board geometry/case containment and case-part versus board overlap. Data does not depend on the rules layer. This prototype locates display helpers in the data module as pure transforms, without input/drawing; a future geometry layer can separate them if needed.
PlacementRules.check_placement now optionally takes case_depth (-1 skips height gate); component height defaults to 0. Malformed row arrays fail validation before cell indexing. Hardware retains one RAM and view-local installed state. Drawer uses independent DRAWER_CELL; installed parts use shared board/case cell scale.
PCRenderer draws cell layout/components from shared geometry and existing dust-zone rectangles. Bench still coordinates cleaning/paste/mounting; further extraction is not done. Case-profile buttons are preview-only and reset RAM trial state, not saved part purchases.
Run python3 -I tools/check_project.py, then godot --headless --path . --script res://tools/test_regressions.gd . Actual review engine: 4.6.3; test target remains 4.7.2. Test suite bypasses human tool work to verify payment state paths and writes only its dedicated regression_test_only.json; no claim of a full human repair session.


## 0.9.0 contracts
DustZones.zones adds specks counts and two covered_by zones (under_cooler/under_gpu); AREA_SIZE is now620x400 to make room for the service tray. DustSim represents a speck as b_n=1 and a bundle as b_n>=3, with the same exact fractional progress accounting. Drawing must not call draw_polyline on one node. set_blockers(Array of id/rect) caches corners and protected zones; is_hidden and has_access enforce access for rendering/tools. translate_zone moves surface positions when parts move. This is not rigid-body collision or free-air dust simulation.
ServiceAccess.setup(zones,origin,saved_ids), begin(point), move(point), finish(point), current_rect(id), set_removed(id,bool), removed_ids(), blockers(). Only GPU/cooler are supported; tray and original mounts are fixed snap destinations. Controller does not read input/draw/save. Bench supplies mouse-event positions, projects part offsets into dust, and persists removal on committed drops. Preview dragging is not persisted. Surface dust translates only when offset changes; blocker cache refreshes only when installed-state changes.
PCRenderer.draw_pc gains optional part_rects dictionary, skipping covered_by zones as physical pieces; renderer receives actual tray/drag positions. GameState job adds dust_schema=2 and removed_parts array; SAVE_FORMAT remains1 for additive fields. Loader validates part ids and migrates old fully clean saves' hidden zones to clean. Refit gate added to final check without changing PAYOUT/START_MONEY/UPGRADE_PRICES. Refitting cooler through mounting saves its new state/result together. General full-PC installation still absent.
Regression suite96 checks in Godot4.6.3, target4.7.2 still unverified. Scripted20.45s clear excludes access restrictions/disassembly and human pointer travel. Changelog records actual final checks. No broad physics redesign was made.


## 0.10.0 contracts
DustPick.step(delta,part_id,active,forced_roll=-1) returns{} until a stroke completes, then{part,damaged}. reset() cancels elapsed hold. Target changes/releases reset progress; one roll per completed stroke, max one action per tick. Seedable RNG and forced rolls are for tests, never player UI. View only supplies an eligible installed/unbroken part with trapped dust on an open ticket. DustSim.trapped_count(id) includes remaining one-node specks; pick_extract(id) removes one protected clump via existing exact-weight accounting. It is an explicit risky-tool exception; vacuum/brush access rules are unchanged.
ServiceParts.option(id,tier) returns label,cost,performance,heat_penalty or{} for unsupported input. Only cooler/gpu and similar/budget are accepted. Job adds broken_parts:Array[String] and service_replacements:Dictionary[id->tier]. Loader defaults missing fields and filters malformed containers/unsupported values; save format remains1, additive compatible fields. GameState.damage_service_part(id) and replace_service_part(id,tier) return bool; damage requires open job, replacement requires damaged/removed supported part and sufficient cash. Purchase deducts once, clears broken/removal flags, records tier and clears cooler paste. Final check rejects broken parts and adds the known cooler penalty; functional lower-spec parts can pass and are reported. Paid tickets cannot gain service damage or purchases. Full PC identity, inventory ownership/history and customer consequences are future work.
Bench coordinates tool eligibility, saved transactions, panel input gating and visual access geometry. Panel overlays use an opaque style to avoid text merging with drawn progress bars. Shop shows downgrade notes on successful checks too. Prices/quality/risk are demo tuning. Do not treat GPU specification as a measured benchmark.


## 0.10.0 free storage contracts (same unreleased delivery)
ComponentData.drawer_stock() returns two uniquely identified instances of existing demo RAM plus a generic8x1GPU, not a release catalogue. GridInventory.setup(board,depth,saved={}) restores known items with validated location/cell/rotation and safe default packing for malformed data. items hold part,location(drawer or connector ID),cell(Vector2i),rotation. begin(index),rotate(step),store(cell)->bool,install(cell)->placement result,cancel(),occupied(exclude=-1),footprint(index),can_store(index,cell),snapshot()->JSON-safe dictionary. Occupancy excludes held item; failed stores retain it until view cancels. Snapshot during dragging uses the pre-pick committed record. Installed cells serialise canonically to[0,0] because connector ID sets actual position. Logical rule state must not depend on animation position.
PartMotion.snap(point,rotation),step(delta,target,rotation,held) stores center,velocity,angle,lift. Critically damped closed-form follow with capped visual delta; no physical collision or throw. View draws pieces last when held; previews storage bounds/occupied footprints and valid socket hints. Storage uses its own30px cells; case and board still share fitted cell size. job.hardware_trial maps profile ID->snapshot; GameState validates the outer dictionary, controller validates inner records. Scene/profile exit commits only last valid arrangements. No repair job parts or cash are changed. Current file map descriptions of single-RAM view-local storage are historical and superseded by this contract.


##0.11.0 contracts (supersede prior sandbox-only storage)
TableBody.launch(point,speed,half_size,angle=0),step(delta,bounds),extent() model 2D plane plus vertical height/velocity. Substeps<=1/120, elapsed budget capped0.25; bounds reflect outward velocity, rebound angular motion if rotated extent cannot fit. Impacts are counted. Tiny velocity/height settles inactive. Edge side is captured before float-vector clamping; never compare rounded clamped position against double boundary to detect an impact. No body-pair collisions/damage.
BrushShape.step(delta,velocity,contact),roots(),tips() generate13 bending spring bristles; ToolRig.IDS vacuum/brush/pick/cloth/syringe use PartMotion plus TableBody. select(),park(),begin_throw(),release_throw(),step(),hit(),contact(). Physics never reads input/draws. View uses actual tool tip/velocity and transformed bristle tips. DustSim.brush_contacts restricts loosening to within8px of tips after broad-phase/access checks; empty contact arrays retain previous API behaviour for direct sim checks. visible_count() reports remaining unhidden groups. transform_zone(index,old_center,new_center,angle_delta) carries surface nodes with service part pose. ToolRenderer draws shared geometry; PCRenderer.draw_pc adds optional poses(center,angle,shadow) for movable part geometry. Bench tracks pose/motion separately from logical mount/tray state and can pick a thrown part at its actual position. Modal panels suppress use.
GameState adds top-level player_inventory:Array[uid,kind,tier,owner,condition],inventory_layout:Dictionary[uid->placement],inventory_sequence,ticket_sequence. inventory_components() returns current known parts; stock_available(uid)/stock_count(kind,tier) exclude installed hardware stock. buy_service_stock(kind,tier) checks money AND physical capacity, creates unique UID, normalises grid and charges once. fit_inventory_part(kind,uid) consumes exactly one available matching working player item, assigns uid to customer job, clears broken/removal and preserves broken original as customer-owned record. replace_service_part(kind,tier) finds first eligible UID and delegates; it no longer buys/charges. Stock seed is once in new_game or missing-field legacy migration, never on an empty saved array. Valid records are filtered/deduplicated on load. SAVE_FORMAT1 remains additive. Existing payout/cloth prices unchanged.
GridInventory.setup(board,depth,saved={},stock=null) uses demo samples only when stock==null; explicit[] means genuinely empty. Hardware view passes current player stock and shared inventory_layout, not per-profile duplicated stock; old snapshots migrate once from active repair layout when shared field absent. Flight reserves old committed record; re-grab/settle/cancel preserves identity. Settlement tries nearest valid cell with selected rotation, or restores prior valid orientation if needed; exit settles before save. Resets arrange owned stock without restocking. Customer PC general storage/assembly remains future work.
Job adds service_table_positions(id->{center:[x,y],angle}),removed_component_records and service_replacement_ids. start_repair_ticket increments ticket id, creates explicit fresh dust0 per zone and preserves global stock/money/upgrades. It replaces trial work, not a full intake queue. Bench caches loaded_job_id and skips stale _save_dust when job id changes; saved service positions are reconstructed only for removed parts. Never overwrite legitimate clean progress on every scene entry. Free tools/flight velocities are intentionally not persisted. Future atomic-save/full-type-validation work remains.

## 0.11.1 structure (behaviour-preserving split)
`MountSession`: `start()`, `finish()`, `step(delta, pressing, paste) -> bool` (true when time ran out), fields `active`, `pressure`, `time_left`.
`PasteRenderer`: static `refresh_image`, `draw_stage`, `draw_panel`. `CleaningRenderer`: static `draw_dust`, `draw_panel`.
`UiStyle`: `label`, `bar`, `COLOR_TEXT`, `TONE_COLORS`. `SaveStore`: `write(path, data) -> bool`, `read(path) -> Variant` (null if missing).
`bench_view.gd` keeps the member names the regression suite uses (`dust`, `access`, `tools`, `holding`, `wiping`, `PASTE_ORIGIN`, `PASTE_CELL`, ...). Do not rename them without updating `tools/test_regressions.gd`.
Renderers are static and take the canvas as an argument, like `pc_renderer.gd`; they must not read input or change state.
Still inside `bench_view.gd` on purpose: the replacement panel (the suite touches its members directly), service-part drag and the input handling. Extract them one at a time, with the regression suite run after each.

## 0.11.2 save safety
`SaveStore.write(path, data)` writes `<path>.tmp`, reads it back, keeps the previous save as `<path>.bak`, then moves the new file into place. `SaveStore.read(path)` returns the first of `path`, `path.bak`, `path.tmp` that parses to a Dictionary, else null. Save format is unchanged. Field-by-field validation of what is inside a save is still `GameState.load_game()`'s job and is not complete.


## Automated tests (0.12.1)
`.github/workflows/tests.yml` runs on every push to GitHub: the hygiene checker, then `tools/test_data_schemas.gd`, then `tools/test_regressions.gd`, on Godot 4.7.2 downloaded from the official `godot-builds` releases. The Actions tab shows green (all passed) or red (open the failed step, read the log). It was written without being run; the first run may need a fix to the workflow itself.

When you add a new kind of data, or a new key to existing data, add it to the schema tables at the top of `tools/test_data_schemas.gd` in the same change. An unexpected key is reported as a problem on purpose: it catches typos.

Queued (not done): the `bench_view.gd` split continues with the replacement panel, then part dragging, then input handling, then one script per tool and a separate UI builder. Do one extraction per patch and let the automated tests run after each.
