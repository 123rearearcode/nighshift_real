# Nightshift — Current State and Technical Handoff

## Current — 0.49.0 Task Manajer detour, 19 November 2026

Main is verified at 0.48.0 (`6c18522`, #59 including #60 merged). This 0.49.0 feature is stacked on
open #61 (`50d1602`, 0.48.1 boards/persistence) and preserves that work; neither new PR is auto-merged.
Task Manajer now replaces one-click removal in the actual monitor. Stable native rows, occasional
advert, slow miner alias, uppercase SEND/Enter, typing pause and verified source/watchdog cleanup.
The actual adware/miner record remains authoritative. Failed/stopped rounds retain infection and
paid time; successful cure saves through existing GameState/NightSession. No new save schema.

Claude resumes session 3.6 Testing bay, discussion first, after user-controlled integration.
Version slots: bay 0.50.0 with structural review, builds 0.51.0, elegance/reviews 0.52.0. Manual remains
deferred. Native execution results: CHANGELOG 0.49.0. Older current/merged paragraphs below are historical.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Integration note — 0.48.0 branch, 18 November 2026 (Claude)

PR #59's branch now includes this 0.47.1 work (PR #60) through a merge commit and carries version
0.48.0: generated tickets (session 3.5) on top of the 0.47.1 ledger and lifecycle safeguards. Neither PR
is merged into main yet. Runtime ownership rules and the save schema are unchanged by 0.47.1; 0.48.0
adds `people`, `person_sequence`, `reviews` and `world_seed` (see DEVELOPMENT.md). The paragraph below
is Codex's 0.47.1 status and stays accurate for that part. Signed: Claude (Opus 5.5, claude-opus-5-5).

## Current baseline and pending safeguards — 18 November 2026

Merged main is 0.47.0 (`ed64f21`, PR #58 after #57): Findings and Stress lab are built, the manual is
deferred. Claude's PR #59 contains pending 0.48.0 generator work. This branch's 0.47.1 follow-up changes
bug documentation/tooling and adds lifecycle tests; it changes no runtime ownership rules or save schema.
Canonical current instructions: HANDOFF.md, BUGS.md, PART_LIFECYCLE.md and the newest changelog.

The bug ledger now distinguishes recorded fixes from verification, tracks L1/L2 customer-part identity
and orphan custody explicitly, and sets the next structural review to 0.50.0. New ledger and complete
cross-PC lifecycle checks are required; their passing does not prove those limitations resolved.
The older status paragraphs below describe their historical versions, not current implementation.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

**Current 0.42.0 navigation update (approved 16 November 2026):** based on main 0.41.0, preserving
Claude's connected customer hardware, install technique, Shop, malware/overclock and timed monitor
measurements. Earlier progress/branch-status notes below are historical. Only older MENU/PATH rules
are superseded; other confirmed design remains. Canonical menu rules: MENU_NAVIGATION.md.

Activities chooses Workshop room / Salvage / Shop. Drop a customer PC into the room slot to open
work directly. Persistent Repair / Hardware / Monitor tabs view that same PC; Repair has Cleaning
and Thermal secondary tabs. Named parent at top-left, selected PC identity centrally, Activities
and Pause at top-right. No intermediate service chooser, duplicate navigation actions or direct
Title button in an activity. Title's Continue resumes the last valid activity, PC and subview.
Pause actually pauses; it contains Resume, existing Settings and Title screen. Room furniture
edits belong to Arrange room mode; ordinary inventory/PC handling stays uncluttered, with autosave
status and an error-only retry. Safe exits preserve owned work and reject failed saves/running tests.
Navigation preferences are separate/run-bound and never own PC state. Salvage remains session-only.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 16 November 2026.

Current build: **0.41.1** (code identical to 0.41.0: night workshop with repair bench, ticket-PC hardware bench,
monitor with hardware check, timed game tests, anti-virus, overclocker and the Work + match tab). The next
work is designed but not built: docs/REPAIR_LOOP_DESIGN.md (D134 to D139).
Claude (Fable 5.2, model id claude-fable-5-2), 16 November 2026. Older notes below are historical.

Current review build: **0.34.0 spool, brush-first controls and movable heavy waste**. Room 0.33.0
was approved/published/merged in PR #40; its older local-only notes below are historical.
See BENCH_FEEL_0_34.md. Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.


Current local delivery: **0.33.0 room storage**, based on integrated main 0.32.0. Prior branch-status
notes are historical. Room has direct furniture, eight floor bays and zoom/pan; no rack-selector list.
See STORAGE_ROOM.md and REVIEW_0_32.md. Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.


Latest merged: **0.31.0 salvage variety** — fresh random pile per arrival, fourteen collectible kinds,
heavy obstacles (docs/SALVAGE_VARIETY.md, D113). Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.

Current delivery: **0.30.0 night workshop / activities**, pending review, stacked on unmerged 0.29.0.
New Game → Activities → Workshop or Salvage; two real customer PCs, three-shelf racks,
non-completing diagnostics and free switching. Full scope/boundaries: NIGHT_WORKSHOP.md.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.


Previous delivery: **0.29.0 general storage rack**, pending review/unmerged. Signed: Codex
(GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 14 November 2026.
F5 → Storage rack; PCs/tools/parts share expandable furniture grids. See the final section and
STORAGE.md for controls, save boundaries and capacity integration still to coordinate with Claude.

Earlier milestone notes follow.


Current 0.27.0 physics trial — Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
User requested trying a 2D side-view dumpster with real physics (D103). F5 → Salvage demo now uses
native gravity, inter-object collisions, supporting stacks/collapse, bounded spring pulling and open
containers with physical contents. Pull objects over the rim before trunk packing. This supersedes the
0.26.0 top-down overlap/nudge movement; whether the format is fun still needs the user's playtest.
Session-only cargo/time/site rules and campaign isolation remain. Bench/customer/shared saves are
unchanged. Exact physics/performance evidence and limitations are in the newest CHANGELOG entry.

Current 0.26.0 update — Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
F5 → Salvage demo opens the separate playable dumpster slice: car/site selection, physical searching,
opening/stripping, effort/travel time, sorting, trunk packing and periodically refreshed piles.
Two test cars/sites; all values are tuning. Progress lasts only within the running app; return/menu and
revisits preserve it, app exit/Reset does not. No shared campaign clock/save/inventory/customer changes.
Claude's merged 0.25.0 customer work is preserved. Shared adapters/whole-PC identity precede campaign
integration. Design and proposed contracts: SALVAGE_DESIGN_PROPOSAL.md (D98–D102). Unmerged design PR #31
is superseded by this reconciled delivery. Older baseline paragraphs below are historical snapshots.

Engineering update 0.22.1 (13 November 2026), Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work:
performance branch only, awaiting Claude cross-review/user playtest. Clamped hose idle sleep with wake
checks, paste/UI caches and separate static drawing are implemented. Eight automated suites pass on
Godot 4.7.2; this is not interactive visual acceptance. No gameplay scope/save-format change. Exact
measurements and limitations: PERFORMANCE.md; delivery validation: latest CHANGELOG entry.

Version 1.15 · 14 November 2026

## Current baseline — trial 0.19.0

Recording diagnosis: the bin reaches 100% around 35 seconds; suction stops by the intended capacity rule, but switching tools overwrote its transient explanation. A persistent status and nearby Empty bin action now expose that state. No capacity bypass or vacuum-power change. Tool, maintenance and thermal controls are regrouped. Hose self-crossings lacked a constraint; recovery now untangles them, including pin transitions. Occupied clamp reach uses the actual pinned segment count.

Silent audio foundation: 28 cue definitions, six mixer buses, lifecycle-managed loops and actual action hooks on repair/hardware/shop/menu screens. No sound samples, players or playback. Audio never changes simulation or reveals hidden scams. AUDIO_DESIGN.md distinguishes implemented contracts from future sonic choices. Leaving an unlocked mount cancels it rather than automatically finishing it.

Cooler pressure/release and deliberate lever feedback are accepted design goals; artwork is deferred and a replacement pressure puzzle is not selected. Automated target-engine results are recorded in CHANGELOG; human feel/layout acceptance remains necessary. No save-format change.

## Current baseline — trial 0.18.0

User confirmed 0.17.1 works. New: visible representative tails/count for hidden dirt with slow precision extraction, clamp left/right drag without replacement-button overlap, shorter standard hose (560; upgrade 760), and tool put-down allowed during active/expired cooler mounting. No save-format change; tails are derived from existing real dirt. User recording identified mount.active input gating; put-down does not complete mounting. Cooler art/animation changes are proposed, not implemented. Target-engine automated results are in CHANGELOG.

## Current baseline — trial 0.17.1

A user recording enabled reproduction of the previously uncertain tool stall: left pickup consumed the press without starting work. That same-press use now works for cleaning tools and paste tools. Parts-mode input also takes priority over parked tools, restoring GPU/cooler removal, cleaning beneath and refit. No dust tuning/save schema changes. See newest changelog for before/after and target-engine checks. Earlier first-entry uncertainty is superseded for this specific gesture, not an assertion that every possible input issue is solved.

## Current baseline — trial 0.17.0

Based on merged 0.16.0. Implemented: shared fresh/restore/reset dust setup, light-contact loosening with clearer visual feedback, real dust-state persistence, case-wide brush scattering with GPU/cooler traps and filter catch, dynamic area mass/progress, movable desk clamp outside the PC. No fan airflow or new campaign/scam systems. Initial dust count remains 85; case_interior starts empty/clean.

Original first-entry stall did not reproduce on controlled fresh 0.16.0. Current checks cover actual first-use vacuum/brush after fresh, saved and legacy loads plus new/reset tickets, rather than only DustSim in isolation. Physical-state reconstruction and access/feedback changes are implemented; a specific user's save-specific cause is unconfirmed. Target-engine results are in CHANGELOG. No graphical acceptance is claimed. Historical snapshots below apply to their versions.

## Current baseline — trial 0.16.0

Start menu, load/new-game navigation and labelled Achievements placeholder are implemented. Existing-save replacement is confirmed; merely opening an unsaved session does not write progress. Shop Main menu saves before returning. Hose uses full component housings and link collision checks; tools/held parts pass above it, held-tool input wins, and the hose has continuous pickup plus an optional session-local desk clamp.

Based on merged main 0.15.2 (PR #10, merge `8972272cce821243b4cfdfd102796e4c85b90e19`); other AI PRs were already merged when inventoried. User reports those changes tested. Current automated headless verification uses Godot 4.7.2; exact results are in CHANGELOG. Graphical launch was unavailable because this runtime had no display server; mouse feel/visual layout still need the user's acceptance.

Work orders, claims, archived delivery and scam consequences remain approved but unimplemented. Seven accepted concepts / rejection of C remain. The following 0.15.2 snapshot and older lists are historical; their no-gameplay-change statement describes that patch only.

## Active baseline — documentation patch 0.15.2

Gameplay remains **0.15.1**, from `123rearearcode/nighshift_real` main commit `c3dd9224f4a32d8fe04dcb5d07eb3e80c1877b93`. Patch 0.15.2 updates design documents/version metadata only on `design/scam-direction`; no game scripts/scenes change and no merge is authorised for this task.

Implemented bench baseline: vacuum-only dust removal, brush tossing/chipping, protected dirt, removable GPU/cooler and pick risk, shared stock, bounded tabletop/rotated-box collisions, hose/bin, material-specific paste, good-result completion and physical retention lever. See DESIGN section 18. The 0.15.1 changelog reports Godot 4.7.2 Actions results: 179 schema and 442 regression checks, zero failures. This update does not independently certify those runs or replace the user's pending human acceptance test.

Approved design, **not implemented by this patch**: scams A/B/D/E/F/G/H, rejection of C, persistent customer-promise information and separation of actual work/function/claims (D58–D60). Current final check still requires cleanliness in every zone. `job.scams` records toothpaste but has no customer consequence reader; a new practice ticket can discard the active job. Delivered-job archive, promises/claims, delayed complaints and social consequences still need implementation. Old-paste reuse and used-as-new need additional state.

Next completion gate: MINIGAME_RULES.md section 6. First human-test the current physical bench, then connect agreement/work/claim/delivery and one delayed consequence with reliable saves/economy. Full campaign, general PC assembly/catalogue and cooling simulation are not complete. GitHub is now connected; earlier statements about no repository access are history.

## Historical implementation notes

The following lists record earlier trial progress; current summaries above and DESIGN section 18 supersede stale input/physics/missing-feature statements.

## Implemented in Godot
- Three code-built Node2D screens: placeholder Shop/job menu, repair bench, hardware bench.
- One overheating customer job; cash, one-time payout, square-cloth upgrade.
- Six-zone dust bundle simulation: brush weakens grip, vacuum removes bundles; cleaning progress saved per zone.
- Paste deposit, spread and wipe on a 51 x 51 simulation grid; timed cooler pressure activity; coverage/overflow grading.
- Final check uses dust/paste penalties and a cleanliness gate. All numbers are demo values.
- Two instances of one RAM model and a generic GPU footprint; tower/L-shaped and compact/stepped board preview profiles; four-way rotation, slot type/size/facing checks, hover details and placement feedback.
- Autosave/load of cash, upgrades, job, per-zone dust fractions and paste grade/coverage/overflow to user://nightshift_save.json.
- Contributor handoff, file map, contracts, versioned changelog and Python hygiene checker.

## Persistence limits / stabilisation issues
- Hardware grid and repair replacements now share owned stock/positions (0.11.0); full customer-PC inventory storage is still absent.
- Exact paste picture is not saved, only its result. Re-entering the bench starts with an empty paste simulation while keeping a saved grade. Starting a new deposit or effective wipe now invalidates the saved grade; regression checked.
- Dust restore now tracks partial bundle weight exactly; twenty successive restores at each tested fraction show no progress drift. Exact particle identities are not saved; per-zone fractions persist.
- Save loading checks some containers but not every field type; malformed-save recovery needs verification.
- No atomic-save or backup strategy is established.
- bench_view.gd still coordinates activities and input; PC drawing has moved into pc_renderer.gd. Further UI/mount-session splits remain open.

## Verification
Review of the original 0.7.1: Python checker passed (11 scripts, 20 res:// references, 23 mapped files); import and ten-frame scene starts passed without reported errors in Godot 4.6.3. Reconciliation 0.7.2 repeats checker/import/scene startup on the final package; final results are logged in CHANGELOG.md. These are startup/hygiene checks, not interactive validation.
Claude explicitly recorded no Godot execution. Its changelog reports the user tried 0.4.0; that is second-hand evidence for an older version, not verification of 0.7.1/0.7.2. Target-editor input, visuals, complete repair and persistence roundtrip remain pending.

## Not implemented
Daytime customer flow, Open/Close shop, estimates/pricing/hidden budgets, multiple persistent PCs, continuous night clock/manual pause/overtime, salvage locations, generated suppliers/deliveries, online listings, full relationships/reputation/customer discovery, general grid stash and full case assembly, full catalogue, complete assembly/sales, personal-PC benchmark/failure, B2B/server progression or Steam packaging.

## Source / collaboration
DEVELOPMENT.md sections 5–6 contain the active Godot file map/contracts. Read HANDOFF.md, this document and the relevant DESIGN.md section before edits. User exchanges versioned ZIPs with Claude; this chat coordinates/reviews. No AI repository access is established.
Repository: https://github.com/123rearearcode/Nightshift . User confirmed original docs uploaded; latest remote contents were not independently inspected. Copy accepted project changes manually only after review/testing. Keep one authoritative set of the five documents, not divergent root/project duplicates.

## Historical browser reference
Separate browser prototype v0.9 at https://nightshift-pc-repair-lab.andreicachristoph1.chatgpt.site/ . Last recorded published commit da3f60e09c52e6dec70ea6dc157f296139ba20f6. It had ten tickets, three board profiles, broader stock and technician views, but is a different codebase; do not assume these features migrated to Godot. Browser source is not in this ZIP and local historical checkout availability is not guaranteed.

## Immediate next step
Use STABILISATION.md to complete target-editor manual checks and choose a bounded persistence-fix task. Do not add catalogue content, a full hub or new mechanics as a side effect of this patch. Record checks actually run, update the changelog and include all five documents in the next handoff.


## Verified 0.8.0 additions
Shared pc_layout.gd defines model cells, board origin, case depth and case-mounted items. Both benches derive rectangles from this data; no arbitrary stretching of usable board cells. Hardware preview switches between two case/board sizes, with slots inside usable cells. General case assembly is not built. Fresh dirty bench contains 36 dust bundles; saved clean state is intentionally retained with an explicit message. Syringe selection exits cloth mode. Cleaning suction is faster; a scripted ideal sweep takes about 8.2 seconds (not a human timing claim).

Godot 4.6.3 regression suite: 71 checks passed, including dust initialisation/restore, shared geometry, slot/rotation/cutout/occupancy/depth checks, actual bench tool switching, paste invalidation, one-time payout, reload and upgrade spending/persistence. Test save is isolated from normal saves. GUI checks observed fresh dust, shared visual mounting, cloth-to-syringe switching, RAM drag/snap and both layout previews. Godot 4.7.2, full manual repair/payment playthrough and comprehensive corrupted-save recovery remain unverified. See CHANGELOG.md and tools/test_regressions.gd.


## Verified 0.9.0 additions / supersedes 0.8.0 tuning
One paste-stage/syringe button remains; redundant dedicated syringe button removed. Vacuum 4.0/radius 50/ramp 0.2. Dust 51 bundles + 34 independent single specks across six surface and two hidden zones. Scripted unobstructed vacuum sweep 20.45s, excluding disassembly/user movement; not a human completion-time claim.
ServiceAccess controller manages drag offsets, original slots, tray positions, removal/refit and blocker rectangles. Surface dust moves with a removed component. Hidden dust is not drawn or affected by brush/vacuum while its part is installed; tool paths are also checked against other blockers. Only GPU/cooler are removable in this trial. Job gains additive dust_schema=2 and removed_parts fields. Old fully cleaned saves preserve hidden regions as clean; saved removal state survives load. Payments require all parts refitted. No general PC inventory/assembly is claimed.
Input pickup/drop now uses each mouse event's position rather than polling the latest cursor, avoiding missed queued/quick drags. Simulation remains fixed-step; display redraw is frame-driven, tool velocity is smoothed with delta time, and blocker edges are cached/rebuilt only on access-state changes. These changes were reviewed and checked; no measured FPS gain is claimed.
96 Godot 4.6.3 regression checks passed: earlier payment/persistence tests plus hidden access for both tools, specks, tray geometry/removal/refit, invalid drops, moving surface dust, saved removed parts and event-position drag handling. GUI observed GPU removal, exposed dust and refit. Target 4.7.2 and full human repair/payment playthrough remain unverified. Broader dust/paste physics redesign is deferred for discussion.


## Verified 0.10.0 additions / current scope
Pick controller separates timing/random risk from view input. Key4, hover inspection, progress arc,0.8s extraction attempt and provisional12% per-attempt damage; no hover damage. GPU/cooler only. Damage is saved, outlined red, halts pick use on that part and blocks payment. Installed parts retain the normal vacuum/brush access blocker. Safe remove/clean/refit path remains available.
Replacement window requires removing damaged part to tray. Equivalent/budget purchase deducts cash once, fits the replacement and saves its tier; repeat/unknown/unaffordable purchases fail without charge. Cooler replacement clears paste. Budget cooler adds8C to final check; budget GPU is saved/reported as65% specification, without a real GPU benchmark. Functional inferior parts may complete the job, one-time payout preserved; lower specification appears in final-check notes. Full stock/catalogue, customer detection/disclosure and relationship/reputation effects are not implemented.
246 GDScript checks passed in Godot4.6.3 before final packaging; latest final count/results are in CHANGELOG.md. GUI inspection, successful extraction and corrected readable replacement window observed. Target4.7.2 and a complete human repair-to-payment playthrough remain unverified. Damage/purchase/payment paths are covered by deterministic automated checks. Core docs1.5 are bundled; no GitHub push.


## Free arrangement update — same 0.10.0 delivery
Hardware sandbox now supports two existing RAM instances plus a generic GPU footprint. Drawer12x8 accepts arbitrary free cells/quarter turns, prevents overlap/overflow, highlights socket matches and preserves items after unsupported drops. No INVALID motherboard warning for ordinary drawer drops. New GridInventory controller owns placement/state; PartMotion owns damped visual following, lift, sway and turning. Per-profile sandbox snapshots save via job.hardware_trial and restore across preview changes/re-entry. It is still separate from the repair PC/stock system. Prior statements about single view-local RAM are superseded here. Final regression count246 in Godot4.6.3, zero failures; includes500 randomized rearrangements with no overlaps/lost parts and motion convergence at30/60/144Hz. These are automated checks, not measured render FPS.


## Verified0.11.0 additions / current authority
Shared tabletop dynamics adds reflected edge impacts, spin, height/gravity/floor rebound, damping and rest. Hardware drawer flick-release throws, Shift-release places precisely, settling searches free cells and scene/profile exit settles safely. Repair ToolRig applies damped handling/toss/recovery to vacuum/brush/pick/cloth/syringe. Dynamic brush bristle tips affect loosening directly; contact is no longer a circle. Move-parts GPU/cooler flicks bounce over the repair worktable; picking at the actual body position recovers them. Dust surface nodes follow rigid pose changes. Service resting positions persist.
A single top-level player_inventory now feeds hardware grid and repair replacement rows. Unique owned records and shared inventory_layout prevent duplication; stock is bought into the grid, then consumed on fit without charging again. Installed hardware-board pieces are unavailable as drawer stock. Broken customer originals and consumed replacement ids remain on the repair ticket, outside saleable player stock. Six starting demonstration items are not a release catalogue; general storage/ownership for full customer PCs is still absent. Legacy hardware snapshots migrate once for the active profile; empty stock stays empty. Payout/cloth prices unchanged.
Fresh tickets show71 visible groups plus14 protected groups without Reset; partial dust survives reopening. Saved clean PCs remain clean. Added brighter dust, ticket/visible-group status and New dirty PC keeping cash/stock/upgrades. The stale bench cannot save over a newly created ticket. No fresh-ticket missing-dust bug was reproduced; no unsupported root-cause claim. New dirty PC is a practice-ticket reset, not daytime intake.
325 Godot4.6.3 regression checks passed before packaging; final checker/import/smoke/fresh-extract results are in CHANGELOG.md. GUI observed dust on first bench entry and a new ticket without Reset, physical brush/rack handling, purchase into shared drawer and corrected cooler shapes. Target4.7.2 and full human repair-payment path remain unverified. Physics is a custom bounded tabletop/bristle model, with no inter-object collision, sound, throw-induced damage or persistent flight state. Free tools reset on scene entry. This section supersedes earlier single/sandbox-only inventory and no-throw statements.


Latest merged: **0.31.0 salvage variety** — fresh random pile per arrival, fourteen collectible kinds,
heavy obstacles (docs/SALVAGE_VARIETY.md, D113). Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.

## General storage rack — trial 0.29.0, 14 November 2026
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

The user approved a general inventory occupied by PCs, owned tools and parts, shown as a rack
and expandable with more furniture. The first implementation is `scenes/storage.tscn`, available
from the start menu's **Storage rack** button. Steel racks, shallow parts cabinets and tool boards
provide distinct grid capacity. Drag, rotate, move between shelves/furniture and add units; invalid
drops return safely. A visible waiting area retains everything that cannot fit.

The rack reads current player stock, the included five-tool kit and the one active customer PC.
It stores only furniture and allocations in `user://nightshift_storage.json`; ownership stays in
GameState. Installed shop parts retain marked shelf reservations; a whole customer PC includes
its fitted customer parts. No duplication or ownership transfer occurs by moving a tile.

Prototype choices, not final balance: furniture is free, at most eight units, example shelf sizes
and storage footprints. Furniture/layout survives New game independently of demo progress.
This is not the final shared-PC/owned-part model: multiple waiting PCs, owned built PCs and a
purchasable tool catalogue need canonical source records first. The current old hardware drawer
and buying/intake capacity checks are unchanged. The rack enforces its own allocation space and
shows overflow, but does not yet reject purchases, intake or salvage on capacity grounds.

Claude owns current concurrent engineering work. No changes to bench_view.gd, tool_rig.gd,
game_state.gd, shop_view.gd or WORK_PLAN.md in this delivery. Coordinate capacity hooks after
review; do not merge automatically. Contract, file map and playtest steps: docs/STORAGE.md.


## Night workshop and three-shelf rack — trial 0.30.0
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
14 November 2026, Europe/Bucharest. User-approved follow-up to the unmerged 0.29.0 rack.

New Game → Activities: Workshop, Salvage dump, Storage rack and a disabled future-activity space.
Salvage moves out of the initial menu. Workshop groups customer-PC selection, repair bench,
hardware stock sandbox and Final Check. New games have two actual repair tickets using the existing
customers, with separate dirty PCs and per-PC repair progress. Existing saves migrate only their
actual current ticket; they do not gain fictional client PCs. Every rack now has a third shelf.

A ticket does not imply a customer PC: the manifest explicitly stores an optional physical PC ID;
build orders without supplied hardware occupy no PC space. Night checks only diagnose boot/heat/
parts and owned game tests. They do not pay, complete jobs, advance customer rotation or record a
pickup. Switch PCs whenever desired. A good paste mount commits through the cooler lever, without
another completion button; existing thermal-paste costs/scam recording remain. Physical paste fields
also survive leaving the bench, alongside each PC's dust, removed parts, damage and replacements.

The daytime pickup/shop screen is future work. Hardware bench still manipulates SHOP STOCK, not a
full customer assembly model. Salvage time/cargo still belongs to its isolated prototype. No shared
campaign clock, shop economy or full owned-PC/part schema is claimed here. A temporary NightSession
bridge stores inactive jobs and references the active GameState.job; it does not clone stock or money.
Main-save active markers and a versioned sidecar allow interrupted-switch recovery; see NIGHT_WORKSHOP.md.
No edits to Claude's hot files or WORK_PLAN.md. This delivery is stacked on the rack branch; both PRs
must stay unmerged until reviewed. Claude goes next on shared-state integration review.


## Storage room — local trial 0.33.0
Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026, Europe/Bucharest.
The user replaces rack-selector buttons with direct room furniture. A 4×2 floor grid holds up to
eight units. All units coexist on one clipped room canvas; zoom/pan and Fit furniture/Entire room
replace paging. Drag furniture by its title bar to another free bay; its contents stay with it.
Parts still pack into each unit's shelves, with rotation, reservations, overflow and safe cancellation.

This removes the signal-emitter deletion path behind B16. The add-furniture popup uses proper
margin/VBox layout, fixing overlapping choices (B20). Native viewport mouse events now exercise
sort/save/add/model selection and repeated room selections in tests. No claim of universal crash
freedom or graphical playtest: the tested flows pass without script/locked-object errors.

Storage layout version 2 stores unit room_cell in addition to unchanged shelf allocations. Version 1
assigns distinct room bays on load; duplicate/malformed/out-of-range cells are rehomed safely. Item
ownership remains in the canonical GameState projection. Furniture remains free prototype tuning;
no room purchase/expansion economy or shared capacity hook introduced. Full controls: STORAGE_ROOM.md.

Main 0.32.0 already integrates the prior PRs. Earlier pending/independent-branch notes below are
historical. Review of Claude PR #39: canonical CPU/part-state fixes retained; night ticket overflow
B19 remains open with measured evidence, reported to Claude. Code is local; no pushes or merges.


## Bench feel — trial 0.34.0
Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026, Europe/Bucharest.
Room 0.33.0 is published and merged (PR #40, user authorized). This new review branch keeps that
room and adds requested feel fixes. Spool winds in deployed hose instead of restoring a full coil;
idle hose stays short, and pulling the nozzle/hose/clipped moving clamp feeds out only needed length,
up to base/upgrade capacity. Spooling releases a held rope point and removes the clamp constraint.

Repair benches (legacy and night) start with Brush, key 1. Vacuum is key 2; Parts 3 and Pick 4 stay.
Internal physics slots remain vacuum=0/brush=1. Tool highlights explicitly follow actual selection,
including hotkeys and refused hand-state transitions. Heavy concrete/appliances retain dynamic mass
and cannot be packed; lower mass/friction and strong damping allow controlled nudging without flight.
All weight/force/length tuning is provisional. Deployed hose length remains local to a bench instance,
like existing tool poses; cross-scene tool arrangement persistence is later engineering work.

No shared save/ownership changes. User-requested narrow edits touch ToolRig spool and BenchView
initial-tool/keys/labels/highlights; no competing bench PR was open. Hand-state rules are unchanged.
Claude cross-reviews next; the new feel changes are not automatically merged with the approved room.


## 0.35.0 — Wave 2 first playable monitor slice

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
User approved starting Wave 2 after cloth and power fixes. New repair tickets and saves lacking
an explicit switch begin powered OFF; an explicit saved on/off value remains respected. Repair
bench initializes fans still when off. Power is per customer PC; live boot/game/thermal tests
require switching on. Cleaning/repasting do not require power. Legacy final check now also
respects the power flag, while its historical one-time payment behavior remains unchanged.

Workshop → Diagnostic monitor offers boot, non-paying final/thermal report, Vapor purchase and
Counter Stroke 2 simulated FPS using existing Wave 1 rules and shop-owned licences. Customer
complaint, uses and collection request remain visible in a bounded sidebar. Reports clear on
power-down; no money/trust/pickup/completion side effect except explicit game purchases.
Anti-virus and overclocker are labeled upcoming; neither runs a pretend scan nor alters hardware.
Their exact mechanics, later campaign time and master-PC requirements remain future design work.
Cloth pickup follows rendered skew/rotation with a one-pixel inset; wiping reach is 35 world
pixels rather than 36 (not one whole 8px paste cell). See SOFTWARE_WAVE_2.md for limits.


## 0.36.0 — Physical room selection and common night exit

User requested room-based workshop selection: Activity Workshop now enters the room. Drag a real
customer PC into its workshop slot to select/open that PC. The old PC dropdown is removed. The
active PC's rack footprint is retained as a marked reservation; the slot references the same
GameState/NightSession record, with no clone or new ownership/save schema. Parts, tools, build
orders with no PC, stale IDs and protected manifests cannot act as customer PCs. Selection and
exits preserve repair progress. Existing hardware bench still operates shop stock (not a second
copy of the selected customer's installed hardware). Shared PC-model integration remains future work.

Activities uses one top-right control on room, service hub, repair, hardware, diagnostic monitor
and salvage. Duplicate title/activity Storage shortcuts are removed. Ticket details in the service
hub are now scrolled/bounded. The uploaded recording displays v0.32.0 and the removed rack-list
implementation; fresh v0.36.0 installation instructions avoid confusing project copies. No universal
crash-freedom claim: real native input regression tests cover the reported sequence and navigation.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.


## 0.37.0 — Thermal controls and bin retraction

User approved: distinct teal Cleaning / purple Thermal tabs; remove redundant cloth/syringe
button in favor of physical tools. Mount cooler moves below the socket, visible only after
paste is present and before mounting/graded completion. This does not force a good-size blob:
poor paste work remains possible. The lever still locks/grades; mounting never auto-completes.
One material menu offers normal thermal paste, super-paste and toothpaste. Wipe/reset a layer
before changing material. Super-paste is honest, uses normal flow/contact rules with a subtle
blue-purple tint, and improves cooling at equal grade. Trial numbers: $6 and −4°C versus normal
$3/0°C and toothpaste free/+14°C. Both thermal reports and saved/per-PC physical fields honor it.
The reel is inside the vacuum bin: RETRACT on the bin replaces the separate spool. It does not
empty the bin; hose stays shortened until pulled. No new campaign system or save-shape change.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
