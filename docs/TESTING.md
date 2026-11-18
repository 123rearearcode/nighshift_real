# Test policy — 0.27.0

## Current addition — 0.49.0 standard anti-virus

Required `tools/test_antivirus.gd` prints Antivirus checks. Exercise real viewport mouse SEND and
keyboard Enter, immediate uppercase with caret preservation, wrong-word retry, stable row coordinates,
indefinite typing pause, source/watchdog/auto-start/reboot, canonical clock cost, 06:00 and boot refusal,
power cancellation, reload, duplicate completion and stale-ticket isolation. Keep every prior suite.
Only the in-chat standard demo has user acceptance; target-engine automated input is separate from a
graphical Godot feel test. No boss-speed/hidden-row acceptance is implied. See D157 and HANDOFF.

## Current addition — 0.47.1 ledger and complete component journeys

The original ten-suite counts below are historical; the current required list is in the workflow.
Always run the project checker, CI scope tests, `python3 -I tools/check_bug_register.py` and
`python3 -B tools/test_bug_register.py`, including on documentation-only changes. Malformed-register
fixtures verify that detached rows, missing details/evidence, duplicate ids and overdue review markers
fail validation. The checker enforces record consistency; it does not prove a fix works or user acceptance.

Runtime verification also includes `tools/test_part_lifecycle.gd` (summary: Part lifecycle). It follows
two PCs and same-model shop parts through fit, undo, damage, switch, save/load, collection and repeat
settlement. Do not weaken its custody checks to accommodate a refactor. Add an appropriate full journey
when ownership/identity/save logic changes, not just a successful initial fit assertion.

See PART_LIFECYCLE.md for invariants and acceptance criteria not yet implemented for all customer parts.
A passing shop-stock lifecycle suite is not proof of L1 customer-part identity or L2 orphan recovery.
Read optional save values once, validate that local value, then use it; keep missing-key and malformed
nested-data fixtures. Do not label historical bugs Verified without named evidence.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest.

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work · 13 November 2026.
User authorised the test audit recommendations. Gameplay is unchanged; Claude still owns the Phase 2 hot files.

## What runs when

| Change | Required checks | Diagnostic work |
| --- | --- | --- |
| Markdown only, optionally a project version-only bump | Project checker and CI scope tests | No Godot download, style pass or playtest |
| Runtime code, tests, workflow or other non-doc files | Project checker, CI scope tests and all ten Godot suites | Short representative smoke playtest |
| Bench physics/controllers, game data, bench_view, part_motion or playtest driver | Same required checks | Complete original matrix and frame-time measurements |
| Manual workflow run | Same required checks | Smoke by default; select full_diagnostics for full matrix |
| Unknown/missing comparison history | Same required checks | Full diagnostics, conservatively |

A newer push/PR run for the same branch cancels an older in-progress run; different branches remain independent.
The classifier examines actual Git diffs. Only config/version changes are exempt in project.godot;
other settings, code deletions and code renamed to Markdown still require runtime checks. Workflow
changes run the suites too. The scope tests create real temporary Git histories to check these boundaries.

Keep all ten suites while Claude refactors the bench. Do not judge coverage by the headline count:
schema loops and frame loops can count the same scenario repeatedly. A fixed bug's regression test
remains useful; older-save migration tests remain until compatibility is explicitly dropped.

## What was cleaned up

- Removed the historical 8.2–65 second vacuum balance gate. Optional --tuning prints the same simulated
  clear-time observation, without treating teleporting between dirt groups as a human completion time.
- Dust-spawn and pick-inspection counts follow configured zone data; slow-brush conservation compares
  against its initial count. Fresh visibility no longer requires a hard-coded minimum of 70 groups.
- Replaced the obsolete 'Apply paste / syringe' label search with one actual cloth/syringe toggle
  and no redundant direct-dispense button. It inspects action wiring, so text changes cannot fool it.
- Removed duplicate fresh-bench/rack-pickup checks from the broad suite. test_dust_flow and
  test_bench_interactions retain the real input scenarios; partial-work reload and stale-scene ticket
  protection stay in the broad suite.
- The pick's 47 pre-completion frames are all still simulated and observed, but report one combined
  assertion instead of 47 almost identical success counts. Stroke completion has its own assertion.
- Removed the test endorsing tab navigation as a substitute for the securing lever. That behaviour
  conflicts with D57; the correct expectation moved to the pending-contract report, then into required tests in 0.21.0.

## Historical pending-contract lane

Update: 0.21.0 fixed and promoted these cases into required regressions. The pending script is now an
empty stub; the older CI lane/summary wording remains for Claude to retire. The paragraph below records
what the 0.20.1 cleanup did, rather than asserting these defects are still open.


tools/test_pending_contracts.gd checks the intended lever rule on same-tab and cross-tab navigation,
and the selected-tool highlight after a refused switch while gripping the hose. At baseline 0.20.0
these are expected to fail: the known gameplay defects have not been fixed by this test-only patch.
The CI step is explicitly named and non-blocking, writes a warning to the job summary, keeps its log
and does not suppress its nonzero exit. These failures must be disclosed alongside required-suite results.

Claude must fix the bench within its reserved scope. Then move the cases into the required interaction
suite and remove the temporary non-blocking lane. Do not change expected outcomes just to obtain green
results. Fixture setup checks in that file distinguish inability to reproduce from the intended failures.

## Local commands

Use the user's target engine, Godot 4.7.2. Run python3 -I tools/check_project.py for project hygiene and
python3 tools/test_ci_scope.py for the nine CI-selection integration tests. The ten GDScript suites
remain listed explicitly in .github/workflows/tests.yml; each ends with its own summary and exit status.
CI now retains nonzero process exits, continues to later suites and handles missing summaries safely.

- Short diagnostics: godot --headless --path . --script res://tools/playtest_bench.gd -- --smoke
- Complete legacy matrix plus frame times: godot --headless --path . --script res://tools/playtest_bench.gd
- Optional pace observation: append -- --smoke --tuning, or -- --tuning for the full matrix too.
- Known-defect report: godot --headless --path . --script res://tools/test_pending_contracts.gd

Smoke uses two brush angles per part, one vacuum angle, four overlap-click cases and one representative
paste combination, retaining reach and hand-state tables. Full mode preserves the previous matrix; timing
rows naturally vary. Diagnostic tables are observations, not proof of human feel or GPU performance.

## Review and release

Run the full required set once for test/workflow changes such as this patch. After it passes, rerun only
when a relevant edit, failure or unresolved concern warrants it. Documentation-only edits need no fresh
full game run. For behaviour-preserving engineering changes, retain the approved work plan's comparison
of full deterministic tables; intentional gameplay/tuning changes need an approved new baseline instead.
No runtime save, inventory, physics, sound or ownership rules change in this cleanup.


## Performance checks (0.22.1)

Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 13 November 2026.
The eighth required suite, tools/test_performance.gd, checks sleeping/waking constraints, paste cache
invalidation and isolated return values, unchanged texture uploads, bin status and static redraw independence.
It deliberately has no millisecond thresholds: shared runners are noisy.
Run `godot --headless --path . --script res://tools/profile_bench.gd` for the short optional CPU profile,
or enable quick_profile on a manual workflow. It prints mean, p50/p95/p99/max for physics, CPU drawing
and full dirty-PC saves. It does not measure GPU rendering, display latency or player FPS. Saves use a
disposable path and retain safe readback/backup rotation. Run comparison builds sequentially on the same
host, without other Godot tests competing. Full deterministic playtest comparison is still required for
behaviour-preserving changes; the quick profiler does not replace that matrix.


## Salvage isolation and correctness — 0.26.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
The ninth required suite is tools/test_salvage.gd. It exercises real menu/scene press-hold-release input,
obstructed targets, partial effort/cancel/pause charges, return protection, committed grid rotation and
rejected drops, pre-existing container contents, PC child custody/stripping across sites, refresh,
separate-car cargo, idempotent unload and no campaign side effects. Idle solver/UI checks protect skipped
work without timing thresholds. A small headless CPU observation is printed, not treated as an FPS claim.
The harness never writes the player's save. Disk save/load recovery and actual campaign awards are not
implemented and are not claimed as tested. Existing bench suites still run; isolated salvage changes use
the smoke bench diagnostic under the existing CI classifier. No additional full brush matrix is needed
unless shared bench/data code changes. A human must still evaluate physical feel, layout and readability.


## Native salvage physics — 0.27.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
The tenth required suite, tools/test_salvage_physics.gd, awaits real PhysicsServer2D frames. It checks
support/fall/collision/sleep, support removal causing collapse, bounded force pulling, in-place release,
pause, physical rim extraction, bag contents and collapsed volume, hollow boxes, physical-to-grid custody,
rollback, real scene/menu input and campaign isolation. Pure tools/test_salvage.gd retains time/grid/UID/
refresh tests. Removed obsolete 0.26.0 percentage-occlusion/custom-solver assertions and moved scene
coverage into native-frame tests; no fake gravity assertions or machine-dependent timing gates.

Optional: godot --headless --path . --script res://tools/profile_salvage_physics.gd. Three loads (20, 50,
100 simple boxes) each sample 240 fall/settle ticks, 60 late-settle ticks, 120 pulling ticks. Timings run
from physics_frame to process_frame and include native physics, sync and scene dispatch; they are wall
phase samples, not the coarsely sampled Performance.TIME_PHYSICS_PROCESS counter. Sleep/active/pair
counts aid interpretation. No GPU/display/FPS claim. Run without other Godot tests competing. Human
corner-grip feel, sorting readability and container handling must still be playtested.


## Storage rack, 0.29.0
Run `godot --headless --path . --script res://tools/test_storage.gd` (required in CI).
For the graphical playtest: F5 → Storage rack; drag/rotate each kind, transfer to a new rack,
try wrong cabinet/tool-board types, fill shelves until overflow appears, reload and check saved
allocations. Cancel mid-drag/focus loss, navigate pages while holding, remove an empty unit.
Confirm ownership/repair state and money are unchanged. Read docs/STORAGE.md for boundaries.


## Night workshop, 0.30.0
Required: `godot --headless --path . --script res://tools/test_night_workshop.gd`.
Manual: New Game → Activities; enter Workshop, partly clean one PC, return, switch to the other,
then back and confirm the work stays separate. Try a good lever mount without a completion button;
leave/reopen and inspect paste. Run Final Check repeatedly: no money, pickup or completion. Check
Salvage returns to Activities, and all three shelves fit on screen. Existing save should retain its
single actual ticket, while New Game deliberately gives two. Hardware bench is still shop stock.
## Salvage variety — 0.31.0
Existing Salvage/Salvage physics suites include 128 seeded layouts (bounded, non-overlapping rotated
root hulls, record caps/IDs), all collectible packing/rotation, fresh-arrival/cargo invariants, new
container reveals and native heavy/generated-pile cases. Test normal random mode manually: enter,
inspect, drive home and re-enter; cargo stays while the pile changes. Try lifting a HEAVY item,
ordinary parts, and opening a crowded box. No target-hardware performance claim; measure feel in Godot.


## Room storage — local 0.33.0
Storage suite now routes mouse events through actual viewport/Button dispatch, including embedded
popup coordinates. Test sort → save → add → each model, distinct popup rectangles, every furniture
title, drag to empty/occupied bay, all eight visible at Entire room, remove/re-add, repeated toolbar
loops, clipping/camera transforms, read-only edits, schema 1→2 migration and extreme coordinate input.
No rack selection Buttons or UI rebuild/free remain. Existing ownership/packing/save tests stay.
Manual: launch the 0.33.0 ZIP, verify the version on Storage, zoom and move a populated rack. Review
B19 separately: workshop ticket still needs a bounded scroll (see REVIEW_0_32.md).

### Wave 2 / 0.35.0

`test_software.gd` is required in CI: powered-off defaults/migration, actual viewport power-button
input, live-test gates, purchase-once/ownership/FPS, non-paying thermal reports, protected manifest,
per-PC switches and one-world-pixel cloth edge. Older payment fixtures explicitly switch their
repaired PC on; no global test override hides the new default. Rendering/feel need manual playtest.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.


### Room/workshop / 0.36.0
`test_room_workshop.gd` is required. Real viewport inputs replay sort/save/add/title selection,
drop a whole PC into the workshop slot, reject tool/unknown/protected choices, check a bounded
hub ticket, and click one identically positioned Activities control on each of six night screens.
Checks preserve per-PC progress, canonical item counts and money; failed checkpoint blocks exit.
Recording evidence shows v0.32.0. Test the fresh version rather than only replaying its old UI.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.


### Thermal service / 0.37.0
Required `test_thermal_service.gd`: actual tab click, native material-menu opening/keyboard choice,
mount and bin-retract clicks; visibility below socket; obsolete tool toggle absence; no mixed layer;
premium cooling parity, charge once, honest scam state, save/snapshot roundtrip; retraction cannot
empty dust and the old spool area does not retract. Existing tests replace obsolete button-based
fixtures with tool selection; physical pickup coverage remains. CI includes the new suite.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

### Install technique / 0.38.0
Required `test_install_technique.gd`: the pure fault rule, pickup-score effects, proof that the shop's
final check temperature and notes ignore the faults, save round trip, and real clicks on the film
button, corner screws and lever. Not tested: how it feels to play.


### Approved menu paths / 0.42.0
`test_menu_navigation.gd` is required in CI. Native clicks cover normal/Arrange mode, Retry,
Resume work, workbench tabs, Pause and Continue. Check canonical PC identity/physical paste across
views, real timed-test pause, busy/save refusal, sound settings, new-run reset and unknown/future
UI preferences. Existing scene tests replace obsolete hub/Save/Refresh assertions, retaining their
storage/ownership/repair coverage. See MENU_NAVIGATION.md before adding any future menu.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
