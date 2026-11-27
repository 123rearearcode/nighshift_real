# Handoff — current state first

## Current — 0.57.10 B61 fixed, 27 November 2026

The testing bay's magnifying glass now draws the same stack as the panel (the close-up, then every revealed
clue) and stays on the picture (`picture_layers`, `lens_glass` in `testing_bay_view.gd`). #84 (0.57.9), #85
(B61 report) and #86 (performance review) were merged first with the user's go-ahead; #86's changelog clash
with #85 was resolved by keeping both Unreleased notes. In discussion with the user: a cable-management
minigame (a separate cable drawer whose cables tangle, shop items that help), termopan (white PVC, 90s/2000s)
doors and the rest of the counter art, and the B59 recovery policy.
Signed: Claude (Opus 5.5, model id claude-opus-5-5).


## Previous — 0.57.9 counter room with a flat front wall (the user's sketch), 26 November 2026

The user found the counter's corner perspective inconsistent (shutter straight down, glass angled, door
hover endpoints neither looking closed, street straight) and drew the room they want: you behind the
counter facing the shop's front wall flat; one glass block on the left (glass door + shop window, bigger
than in the sketch) under one flat shutter box; the workshop door with a keyhole on the right. They approved
Claude's mockups and asked to push the layout "with the existing current assets in the game" (D171).
`scripts/rooms/counter_art.gd` now draws only the approved Batch A pixels in that layout: the shell, its own
flat tiles over the painted corner, the door picture and stretches of its frame, the shutter box and the
down shutter (whole slats repeated), the sign, the street at the 0.57.8 eye-level mapping. FrontDoor and
Shutter hotspots moved; all other anchors unchanged. References (not loaded): `art/references/counter_flat_layout/`.
Still waiting for review: the 0.57.8 drafts (connectors, case walls, street-level Outside).
Signed: Claude (Opus 5.5, model id claude-opus-5-5).


## Previous — 0.57.8 Batch C in the game, one picture per item, storage pull-up, 25 November 2026

User decisions (D170): stay 2D; every item uses ONE model drawn from on top (and from the side only where a
scene needs it) via `scripts/view/item_art.gd`, used by storage, hardware board, repair bench and testing
bay; the repair bench shows the PC lying open on its side; tools are pixel art (rev 2 approved: "So that
works"); no storage button: the bottom edge of the counter pulls the storage up; items under the counter
must turn (click-to-hold + R/Q/E/right-click/wheel). Done in 0.57.8, plus the workshop door fit and the
window framed at street level. No hot file (`bench_view.gd`, `tool_rig.gd`, `game_state.gd`) was edited:
all drawing changes are in the renderers.

Waiting for the user's review (drafts, not loaded): the two power connectors (24-pin, 8-pin) with clean
routing, the case's inner walls, and the Outside room at street level (`art/drafts/`). After approval: route
the cables in code (Line2D with the cable textures, plugs at the 24-pin and the GPU power connector), put the
walls over the case, install the Outside picture and move its hotspots to `outside_layout.json`.
Built on main 0.57.7 (Codex's #82 review consolidation; B59 still Open, see the next section).
Signed: Claude (Opus 5.5, model id claude-opus-5-5).


## Previous — 0.57.7 critical consolidation of checker #77/#78, 25 November 2026

User asked to critically review both older open reports against the current game, combine them into
one new PR and leave merging to the user. Base main is 0.57.6 / 842d0c2, after merged #79/#80/#81.
Read docs/REVIEW_CONSOLIDATION.md for every disposition, source comparisons and reproduction matrix.
Original finding/measurements remain credited to Claude (Opus 5.5, model id claude-opus-5-5).

B59 remains Open and is re-triaged High for a blocked loop. Godot 4.7.2 reproduction confirms it;
valid backup/tmp recovery works, wrong-run primary can hide a good backup, active-only pending can
show a slip but cannot accept, and restoring a matching manifest plus cold reload recovers. Clearing
the queue alone does not fix protected room checkpoints. No runtime fix or recovery policy is built.
The optional tools/reproduce_b59.gd uses only uniquely named disposable saves and reports behavior;
it is not a required regression test asserting that the lock should remain.

Performance report's method/tables are historical 960b847 → 1897eda measurements, not current art
benchmarks. Corrected refresh copies (two pre-dawn, not four), dropped already-existing save p50 task,
qualified inconclusive save drift and unmeasured checkpoint latency, rejected front-only acceptance
validation. Retain B57 affordability/memoization and coverage improvements as proposals. No new
scheduled audit, optimization or bug-fix claim; checker structural marker remains 0.60.0.

Art state is the 0.57.6 section below: Batch A/B installed; Batch C ignored drafts, ART-16 pixel rev2
pending human approval, ART-13 not created. Art tracking/approvals are unchanged by this task.
Anti-virus 0.58.0 and part tests 0.59.0 remain reserved. Leave this combined PR unmerged for the user;
source #77/#78 are linked as superseded historical reports. Checks actually run: newest CHANGELOG.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Previous — 0.57.6 Batch C art (ART-14 to ART-18), approved except the pixel tools, 25 November 2026

The user gave Claude Batch C (ART-14 to ART-18) and asked for a PR with all the new graphics. They are
drafts in `art/drafts/ART-14/` to `ART-18/` (81 files, hashes in `art/drafts/batch_c_manifest.json`,
source `tools/art_batch_c/`), NOT loaded by the game (`.gdignore`). The user approved them at 21:31 ("the
art is reviewed and okay, the tools should be pixel art, i like the phone crack"): everything except the
ART-16 tools, which were redrawn as pixel art in `art/drafts/ART-16/rev2/` (24 pre-turned frames each;
approval pending). Per-file status and hashes: `art/drafts/batch_c_manifest.json`.

When approved, integration needs: the repair bench drawing the case/board/parts/dust/fan art and the tool
sprites (tip at Rig.TIP; `bench_view.gd` and `tool_rig.gd` are single-owner hot files, check WORK_PLAN),
the hardware board drawing the board/parts, the testing bay using per-kind lens spots from
`inspect_spots.json` and showing a damage overlay only when its clue is revealed, and the monitor/phone
frames. ART-13 (workshop room) is the last first-day task not created; Batch A is merged (#80, 0.57.5).
Signed: Claude (Opus 5.5, model id claude-opus-5-5).


## Previous — 0.57.5 approved Batch A integration, 25 November 2026

User reviewed Batch A revision 02 and said “Aight u can put it in”, then “art reviewed, look sgood.
claude already created some art in an open pr (i think) so merge that and then create a new PR.”
Claude's Batch B PR #79 was cross-reviewed and merged first (87dd2b6; head 6bddbb3). Its CI passed;
Codex also ran Godot 4.7.2 Rooms 77 and First customer 37, both with zero failures before merging.
PRs #77 (B59) and #78 (performance docs) remain untouched. This new PR is for Batch A integration.

Read ART_PRODUCTION_PROGRESS FIRST, then ART_DIRECTION, ART_ASSET_LOG and
art/rooms/counter_batch_a/manifest.json, layout.json and README.md. All 14 source PNGs retain the
exact human-approved revision-02 hashes; quotes, creator/model provenance and source pack are
recorded. No new pixels or changed Batch B art. The prior review packet used metadata 0.57.4;
this distinct runtime presentation change uses 0.57.5, not a reused build number.

Counter layers: street/architecture/door endpoints behind the customer, foreground countertop over
the customer's body, PC and clipboard above it, UI above the scene. Native hover chooses door
endpoints. The existing end-night dialog previews the down shutter; cancel restores it without
changing time. Morning exterior is used during intake/visits, dusk afterwards. Existing open/close,
pause, save and room paths are retained. No hover-open storage mechanic is introduced.

Shared layout: logical 1280×720, room sources from common 1672×941 origin; customer center x680,
waist y488, PC bottom-center (1030,550), clipboard center (830,543). Batch B sprites stay 2× nearest
and item pictures stay at 44 px/cell. Under-counter GRID remains Rect2(40,140,880,440), exactly 20×10.
Decorative interior/rim UV mapping is around those cells, never another storage model. A flat
Background override and missing-art placeholders remain supported.

Created status is 12/18 for the approved current slice (ART-01–12); approval, branch integration and
human in-game visual acceptance are tracked separately. Source pixel-density polish is still open;
do not call this uniform native 640×360 art or final visual acceptance. ART-13–18 remain uncreated.
First-day list remains active; retirement conditions have not been reached.

Codex owns this bounded room/presentation patch. No GameState, bench, tool-rig, save, ownership,
diagnostic or clock-rule changes. Keep reserved anti-virus 0.58.0, part tests 0.59.0 and scheduled
checker 0.60.0 scope. B55/B56/B57/B59 are not claimed fixed. Execution: Godot 4.7.2 headless;
checks and remaining limits in newest CHANGELOG. No graphical/human playtest claim.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Previous — 0.57.3 first approved art in the game (Batch B), 25 November 2026

The user assigned Batch B (ART-06 to ART-10) to Claude and Batch A (ART-01 to ART-05, 11, 12) to ChatGPT,
reviewed Claude's art in chat (rev 1: "refine the tools, and the vase/clipboard. Parts are supposed to be
in a completely different style; comic book but semi-realistic ... the headphones are the wrong way
around"), then approved rev 2: "they are heading the right way, and you can add this art to the game. I
think they are big enough." Approval, revision history and the SHA-256 of all 62 files are in
ART_ASSET_LOG; D168 records the decision and the parts style.

What is in the game now (branch `feat/batch-b-art-0573`, until the user merges it):
- Mara and Relu at the counter window (pixel sprites, 2x, waist on the counter line y 410); their PC on the
  counter while they are there; the clipboard prop on the counter (hotspot `prop`/`prop_hover`); the
  ticket clipboard close-up skin (600 x 700, rows on `CLIPBOARD_PAPER`); storage pictures in the
  under-counter grid, now 44 px cells (parts illustrated 1:1, PCs/tools pixel 2x, box fallback).
- Editable sources: `tools/art_batch_b/` regenerate the exact approved bytes. Changing any pixel needs
  new human approval (D167).

For Batch A (ChatGPT): leave the clipboard spot clear in the counter picture (it is a separate prop), keep
customers standing behind a counter top at about y 410 or tell the integrator the new line, and publish
ART-01 anchors so the interim placements (customer centre, PC base (456, 440), clipboard spot) can follow
them. For close-up hardware (ART-15): match the comic-book, semi-realistic parts in `art/storage/`.

Versions: 0.58.0 anti-virus and 0.59.0 part tests stay Codex's; 0.60.0 the checker's. Open checker PRs
#77 (B59) and #78 (performance) do not touch these files. Next free bug id after #77: B60. Signed:
Claude (Opus 5.5, model id claude-opus-5-5).


## Previous — 0.57.2 permanent art progress and human-approval rule, 23 November 2026

User authorized merging prior PRs and creating this NEW documentation PR. #74, #75 and #73 are now
merged, baseline main 0.57.1 / fd07993: art brief/credits, customer-first opening, checker performance
report/B57. This patch adds no art/runtime changes and does not approve any existing draft for the game.

### Art agents: required entry point and next work

Read `docs/ART_PRODUCTION_PROGRESS.md` FIRST, then ART_DIRECTION and ART_ASSET_LOG. It is the durable
router/continuing queue. Current phase FIRST_DAY_ACTIVE routes to FIRST_DAY_ART_CHECKLIST (0/18 created).
Next dependency is the shared ART-01 composition + ART-05 storage-capacity layout; assign one owner.
No new art is requested by this governance-only task. The clipboard-only top and 20 x 10 storage remain.

Once first-day creation is complete, the coordinating agent must move remaining reviews/approval/
integration work and the next user-authorized art scope into the permanent queue, switch live AGENTS/
HANDOFF/guide pointers, notify/remind the user and retire the old file. Keep a brief redirect while
branches migrate; delete it once the permanent tracker's explicit retirement conditions hold. Preserve
credits, approvals and completed history; do not delete the incomplete checklist now or keep two lists.

### Human approval is mandatory BEFORE art enters gameplay

No agent may push artwork into the playable game before a HUMAN approves its exact revision/use.
Record approver/date/evidence/file hashes in ART_ASSET_LOG; changes to approved art need renewed
approval. Created is not approved or integrated. Draft/reference paths may hold review material only
while disconnected from runtime loaders/scenes/code. Existing concept acceptance is not blanket
approval to install its art. The rule is documented policy; no automated approval CI gate is claimed.

A daily condition-watch is active to check first-day completion/obsolescence and remind the user of
migration/retirement and prepare docs-only transition PRs when conditions hold. It must never approve
or install art or merge PRs. Delivery-time agents still
manage the routing change; the reminder is a backstop, not a replacement for maintaining these docs.

### Copyable resume instruction

> Read ART_PRODUCTION_PROGRESS first and follow its ACTIVE list, not an old handoff's phase. Update
> creation status and per-file credits in ART_ASSET_LOG. Submit exact asset revisions for HUMAN review
> before any runtime installation. After first-day creation completes, migrate agent pointers to the
> continuing queue, carry over pending approvals/integration, tell the user the old checklist is obsolete,
> and retire/delete it only after all live references and branch dependencies have migrated.

Pending gameplay stays anti-virus 0.58.0 / per-part tests 0.59.0; opening 0.57.0 is merged. No hot file
is reserved by this docs task. Scheduled checker owns the next structural marker, 0.60.0. B55/B56/B57
stay Open; B58 stays Verified. Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.


## Previous — 0.57.1 prior-PR integration, 23 November 2026

User authorized merging the prior PRs. #74 (art/checklist/credits, 0.56.3) and #75 (customer-first
opening, 0.57.0) are merged on main 8342874. This docs-only integration resolves checker #73's bug
ledger conflict while preserving B57 Open and B58 Verified. It retains Claude's recorded profiling
measurements/proposals and author attribution; Codex did not rerun or take over the scheduled review.
No runtime/art/save change, only version metadata and documentation. The next user task is a separate
PR for permanent art-progress routing, checklist retirement and mandatory human approval before art
is installed in the playable game; that governance work is not built by this merge commit.
Pending gameplay slots stay anti-virus 0.58.0 and part tests 0.59.0, checker structural review 0.60.0.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.


## Previous — 0.57.0 first-day customer opening (separate gameplay PR), 23 November 2026

The user authorized: update checklist FIRST, then make a NEW PR so the first day starts with a
customer. Checklist/credits were pushed to #74 at a0551f8 (0.56.3) before this runtime work began.
This feature branch is stacked on that exact head; merge #74 first and retarget this PR to main.
Main remains 0.56.1 / 960b847; independent checker #73 is untouched. No new art was generated.

New game through the title now shows the existing first customer at the counter (Mara on a fresh
shop), then the other already-seeded repair customer. Each presents the recorded complaint, uses,
timing and existing repair fee; accepting the PC advances the queue. Intake is untimed and gates
night navigation, PC switching and end-night until complete. Then night ONE begins at zero minutes,
with exactly the same two jobs/PCs, stock, money and repair rules. No generator, payment, review,
repair, deadline or simulation runs merely to introduce/accept a customer. Existing assets/placeholder
portraits are reused. This is a bounded first-day introduction, not the full future trading/negotiation day.

`GameState.opening_customers` is an optional list of still-pending EXISTING ticket IDs, stored in the
main save; legacy/missing/wrong-container input defaults empty and IDs are filtered/deduplicated.
SAVE_FORMAT remains 1. Cold Continue resumes the unaccepted customer; accepted customers are not
replayed. Pending opening forces Continue to the counter. The normal later-morning path is unchanged.
Direct NightSession.start(gs) demo/test callers retain the old immediate-night default; the product
New game explicitly requests introduction. No second inventory/PC model is added.

### Ownership and next action

Codex owns the bounded GameState/NightSession/counter/title/resume patch for this user assignment.
Do not race another change to those files until cross-review/integration. Keep first-customer, existing
morning/room/navigation and lifecycle tests. B58 records the corrected night-workshop fixture
that previously bypassed intake; B57 remains allocated in checker #73. Recheck branches before
allocating further bug IDs. Art agents still read ART_DIRECTION, FIRST_DAY_ART_CHECKLIST
and ART_ASSET_LOG, update checkboxes/actual per-file creator credits and keep only the clipboard as
initial tabletop dressing. Runtime implementation does not mark any production artwork Created.

Version slots are revised because the user prioritised this new visible feature: 0.57.0 is this opening;
Codex anti-virus effects/reduce-flashing moves to 0.58.0, per-part goofy tests to 0.59.0. Those features
remain pending, not built here. Their D163/D164 reservations remain; this opening records D166.
No gameplay brief is dropped. Next structural review remains 0.60.0, scheduled Code checker only.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Execution evidence: newest CHANGELOG and required First customer suite. Headless execution is not
finished art, animation or human graphical acceptance. No automatic merge in this task.


## Previous — 0.56.3 checklist credits/status first, 23 November 2026

The user asked to update the art checklist FIRST, then create a separate gameplay PR so a fresh first
day starts with a customer. This commit implements the documentation half only. Read FIRST_DAY_ART_CHECKLIST
and ART_ASSET_LOG: 18 actual Markdown creation checkboxes, named per-file creator/model/tool/date,
retained original/edit credits and separate integration status. All production tasks are initially
Not created; the four existing references are credited separately. No new art or gameplay change.
The customer-start implementation follows on a separate branch/PR; it is not already built here.
Keep the art direction, 20 x 10 storage and earlier pending feature work; don't seize shared hot files
for unrelated work. Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.


## Previous — 0.56.2 art reference and first-day asset brief, 23 November 2026

User assignment: document the accepted-for-now visual direction, plan a playable first-day art slice,
keep REAL under-counter storage (Probably Stolen video reference), and make the reference mandatory
for art agents. **No new art now.** This patch changes docs/version metadata and copies four existing
reference images unchanged; it does not install them in live scenes, implement hover UI or change saves.
Based on main 960b847 / 0.56.1. Open #73 is the scheduled checker's independent performance/B57 docs
PR, untouched; no merge is requested by this task. Do not claim B55/B56/B57 fixed by artwork.

### Required read before ANY art creation or integration

1. `docs/ART_DIRECTION.md`: latest user design instructions, actual images/provenance, layering,
   native-pixel working proposal, written-instruction precedence and under-counter storage geometry.
2. `docs/FIRST_DAY_ART_CHECKLIST.md`: ART-01–18 priorities, suggested Claude/Gemini batches,
   copyable prompt, existing first-night versus proposed opening-day boundary and acceptance checks.
3. Inspect `art/references/` images. Latest empty drafts are not ready game assets. The filled look
   reference is not authority to recreate clutter. Only the clipboard is initial tabletop dressing;
   customer PCs, items, paper text and stored contents are dynamic. No plants/counter-wall shelves.

Storage remains ONE 20-column x 10-row unit for parts/tools/PCs. The four-cubby draft cannot shrink
or partition it. The user permits visible storage OR looking under the counter on hover; the brief
recommends a larger look-under view but does not pretend that choice/gesture is final or implemented.
Existing separate storage close-up remains functional. The referenced 16.6 s video was inspected at
2/8/14 s; it supports the below-top continuous grid relationship, not a claimed hover gesture.

### Resume / ownership

The user will assign asset creation to Claude/Gemini. Suggested environment and prop/character work
packets and a shared prompt are in the checklist; nobody was launched or contacted. Art work stays
in assigned draft files. Agree the layout/anchors/storage area before final sprites. Runtime integration
is a separate bounded version with one file owner. Keep existing phones/reviews/cash/end-night/routes
reachable even while decorative props are omitted. Original Codex 0.57.0 anti-virus and 0.58.0 part-test
briefs remain pending, not built or cancelled here; the art task does not seize their hot files. Do not
reclaim the scheduled checker's structural/performance role; next structural marker remains 0.60.0.

Copyable art-agent prompt: FIRST_DAY_ART_CHECKLIST section 5. Check current live main/branches before
starting, then deliver only assigned ART IDs and provenance/dimensions/alpha/anchor/state manifests.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Execution: documentation/reference-copy pass only; checks recorded in CHANGELOG 0.56.2.


## Previous — 0.56.1 merge completion and checker reports, 21 November 2026

The user authorized merging all current PRs. #69 (0.55.0 store/under-counter storage) and #70
(0.56.0 magnifying glass) are merged in order on main, baseline b4d6841. This docs/version patch
integrates #71 while preserving B54's verified harness fix and adding both checker reports:
B55 (hidden cursor in the pause menu with the lens) and B56 (under-counter items drawn at the
stock-room origin). Both remain Open, code-review findings only, not reproduced or fixed here.
All runtime files, tests, tools and CI remain identical to the passing 0.56.0 release.

Resume from current main. The 0.55.0 work split below still applies: Codex next owns 0.57.0
anti-virus effects/reduce-flashing and 0.58.0 per-part tests; #70's merge releases the bay for that
planned work. This merge request does not start those features. Claude handles engineering/code
health and follows up the checker findings with the relevant file owner; coordinate any bay fix
before overlapping Codex's changes. Keep every required suite, the hidden-condition boundary and
all lifecycle contracts. Next unused bug id is B57; next structural review stays 0.60.0 and belongs
to the scheduled Code checker. Remaining feature/design questions in the prior section stay open.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Execution: documentation/version integration only; no new Godot run. See CHANGELOG 0.56.1.


## Previous — 0.55.0 store and under-counter storage; work split for Codex (Claude), 21 November 2026

Read first: done (0.54.2 section and docs/CODE_CHECKER.md). The user played 0.53.0 and decided D162.
Versions and owners are handed out here so nobody collides:

| Version | Owner | What | Brief | Status |
| --- | --- | --- | --- | --- |
| 0.55.0 | Claude | The tool catalogue leaves the counter for **the store** outside (not the parts supplier); **storage under the counter window**, a 20 × 10 grid for parts, tools and PCs | D162 1–2 | this PR, branch `feat/counter-store-0550` |
| 0.56.0 | Claude | The testing bay's **magnifying glass** (the tool; fault types come later; `PartCondition.needs_lens`) | D162 3 | built, branch `feat/bay-lens-0560`, stacked on 0.55.0 |
| 0.57.0 | **Codex** | **Anti-virus dynamism**: garbled mixed-script/mojibake names, fast-changing text, rainbow and italic rows, haze, look-alike names; rows and controls never move; a **reduce-flashing setting** | D162 5, top of `docs/ANTIVIRUS_MINIGAME_DESIGN.md` | Codex may start from main now (it does not touch the bay or the counter) |
| 0.58.0 | **Codex** | **A goofy test per part type** replacing the quick and long tests; short; failing costs night time | D162 4, `docs/PART_TESTS_DESIGN.md` | start after 0.56.0 merges (both edit `testing_bay_view.gd`) |

Hot files: Claude holds `scripts/night/testing_bay_view.gd` until 0.56.0 merges, then it passes to Codex
for 0.58.0. Codex holds the anti-virus files (`antivirus_panel.gd`, `antivirus_round.gd`, `malware.gd`,
`tools/test_antivirus.gd`) for 0.57.0. Decision ids: D162 is used; Codex takes D163 (anti-virus) and D164
(part tests) if it records decisions. Next bug id B54. Next structural marker 0.60.0 (the Code checker
session owns that review).

Open for the user: confirm the reading of "keep store upgrades separate from buying parts and tools"
(the store sells tool upgrades; parts are still ordered on the hardware bench); the grid orientation (built
20 wide × 10 high). Scam hooks kept: what sits under the counter (police later), labels independent of
tests (relabeler tool later, similar parts only).
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

### Copyable Codex resume prompt

> Pull main and read HANDOFF's 0.55.0 section and docs/CODE_CHECKER.md. Your two tasks (D162): first
> 0.57.0, the livelier anti-virus (brief at the top of docs/ANTIVIRUS_MINIGAME_DESIGN.md: garbled text
> and mojibake, fast-changing names, rainbow and italic rows, haze, look-alike names, a reduce-flashing
> setting; rows and controls never move). Then 0.58.0, the per-part goofy tests replacing the quick and
> long tests (docs/PART_TESTS_DESIGN.md), after Claude's 0.56.0 magnifying glass is merged. Keep
> PART_LIFECYCLE invariant 7 (the bay never shows the real condition) and the native-input suites.

## Previous — 0.54.2 dedicated Code checker integration, 21 November 2026

PRs #19 and #64–#67 are merged (main 0.54.1 / 7861de7). PR #68 appeared during that integration;
this patch resolves its handoff conflict, retains all current game code and assigns version 0.54.2.
The two older PC-model proposals remain historical; the 0.54.0 delivered-part contracts remain current.

**Code checker (user decision recorded by Claude, 21 November 2026):** reviews belong to a separate
scheduled Claude session — change review every six hours, structural review when the BUGS marker is
reached (next 0.60.0), and performance review every two days. Read docs/CODE_CHECKER.md for the full
contract. It reports and opens small docs PRs; it never edits runtime/tests/tools/CI or merges. Other
AIs still test their changes and file bugs found in their own work, but do not take over those scheduled
reviews. This integration records the role only; it does not create, inspect or verify external schedules.

### Copyable Claude resume prompt

> Pull main and read HANDOFF's 0.54.2 section and docs/CODE_CHECKER.md first. All previously open
> release PRs and the historical #19 archive are integrated; #68 adds the separate checker role.
> Resume Rooms/art/playtesting from the current room navigation, not old Wave 3 steps. Preserve
> delivered UID/condition/defect/knowledge, bags, comeback receipts and every required suite. L1/L2
> remain open, L4 clock and L5 overflow are separate. No runtime hot file is reserved by this
> integration; coordinate the next owner. Manual/boss malware/interactive reviews/shop upgrades
> stay deferred. The dedicated checker owns scheduled structural/performance reviews; authors
> still verify their work and file bugs. Next structural marker remains 0.60.0.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Execution: documentation/version integration only; no new Godot run. See CHANGELOG 0.54.2.


## Previous — 0.54.1 integration and historical proposal archive, 21 November 2026

The user authorized merging everything. PRs #64 (builds), #65 (trust/reviews), #66 (Rooms) and
#67 (delivered physical records) are now merged in order. Their integrated main baseline is
0.54.0 / d8ecf6a. This final documentation patch resolves PR #19 against that baseline, retaining
its two 0.19.3-era proposals as prominently labelled historical reference. Current runtime, save
contracts, tests and all five core design documents are retained; only config/version changes.
Merging #19 does not authorize implementing its remaining proposed rules. Current DECISIONS,
PART_LIFECYCLE and DEVELOPMENT supersede its illustrative fields and old work assignments.
Older sections below preserve history; their open-PR/integration instructions are superseded.

### Claude's next action

1. Pull current main and read this section, the 0.54.0 lifecycle stage and newest changelog first.
   Start new work from integrated main, not the old stacked feature branches or PR #19 baseline.
2. Resume the latest Rooms/art/playtest follow-up from 0.53.0: replaceable room art, actual player
   feedback and the pending day-timing clarification. Wave 3 through 3.8 is already built; do not
   restart the testing bay, build requests or trust/reviews, and do not reintroduce the old menus.
3. Preserve the Delivered parts suite and all earlier tests. Cross-review the delivered-part path
   when extending it. L1 legacy originals/bench aliases and L2 orphan recovery remain open; L4
   salvage-clock integration and L5 drawer overflow are separate tasks. Do not unlock orphan stock.
4. The bounded Codex runtime patch is complete; no hot file is reserved by this merge-only task.
   Coordinate the next runtime owner before editing GameState/bench hot files. The standing split
   remains Codex design/gameplay and Claude engineering/code health. This patch requires no runtime
   compatibility patch; audit any newly assigned work against current contracts before implementing.
5. Manual, boss malware, interactive reviews and shop upgrades remain deferred. Next scheduled
   structural review is 0.60.0. Green headless tests are not graphical acceptance.

### Copyable Claude resume prompt

> Pull main and read HANDOFF's 0.54.1 section before continuing. The user authorized all merges:
> #64/#65/#66/#67 are integrated; #19 is preserved only as historical 0.19.3 design reference.
> Resume current Rooms/art/playtesting from the shipped 0.53.0 navigation, not old Wave 3 steps.
> Preserve 0.54.0's delivered UID/condition/defect/knowledge, bag and comeback receipt contracts
> and every required suite. L1/L2 remain open, L4 clock and L5 overflow are separate. Coordinate
> hot-file ownership for the next task; keep deferred features deferred and the 0.60.0 review.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Execution: documentation/version integration only; evidence in CHANGELOG 0.54.1.

## Previous — 0.54.0 delivered physical records and audit follow-up (Codex), 21 November 2026

User assignment: implement the recommendations from the bug-register review: preserve delivered
condition through collection/comeback/reload, continue stable identity incrementally, split the two
unrelated L4 issues. The scheduled 0.50.0 review WAS done by Claude on 20 November; this is its targeted
follow-up, not a claim that it was missed. New regression B53 reproduces loss on the unchanged parent.

### Integration and ownership

- Verified main: 0.50.0 / c04a278. Open chain: #64 builds (0.51.0) -> #65 trust/reviews (0.52.0) ->
  #66 Rooms (0.53.0). This branch `fix/delivered-part-records-0540` starts from #66 head f61583c,
  preserving all their changes. Review/integration order is that chain, then this follow-up. Retarget
  each dependent PR to updated main when its predecessor merges; do not merge/force-push predecessors.
- The user's current instruction assigns Codex the bounded GameState/CustomerPC/PcBuild/receipt
  correction and its tests. This supersedes the stale #59 ownership notes for this task only.
  Do not race a second lifecycle or GameState patch; cross-review this result first.
- Version 0.54.0 is used because physical saved-record contracts are added compatibly. SAVE_FORMAT
  stays 1. Existing original parts are not assigned invented historical identities or hidden health.

### What changed

`job.part_instances` retains the original physical stock uid, model, customer owner, actual condition,
defect and player knowledge when custody ends. Existing `parts` remains the model/placement projection;
temporary fits still derive condition from shop stock. Actual effects persist after collection,
including dead RAM/CPU/PSU and degraded GPU/cooler/storage. Matching same-model parts never exchanges
their health. Measurement fingerprints include physical uid/health, not ownership or knowledge edits.

Removal/refitting/reordering carries each migrated record inside the relevant loose entry. A later
replacement returns that original to stock with its SAME uid/defect, marked untested under D158. An
unreplaced removed part leaves in the customer's bag; its record remains in the PC/receipt, not free
stock. Repeat settlement neither consumes more parts nor heals them. Optional immutable `pc_snapshot`
receipts survive pending-comeback save/load and due report cards. These are historical receipts; the
existing comeback flow is report-only, not a newly implemented automatic return-repair ticket.

B53 is fixed with target-engine regression evidence. L3 now points to that fix for future handovers;
already-lost old condition cannot be recovered honestly. L1 remains Investigating for legacy customer
originals, stable bench aliases and the full migration/rollback path. L2 remains Investigating: no
orphan mark was cleared or unlocked. L4 now means salvage/night-clock integration ONLY; L5 separately
tracks drawer-overflow visibility. Both remain open. B1–B41 are still Fixed, not automatically Verified.

### Claude's next action

1. Check live branches and read this section, PART_LIFECYCLE's 0.54.0 stage and the new changelog.
2. Cross-review the #64 -> #65 -> #66 chain and this final patch under user-controlled integration.
   Pay attention to same-model RAM reordering, undoing service replacements, a delivered part returned
   to stock, bag contents, inactive-PC load and immutable comeback receipts. Keep all prior suites and
   the new Delivered parts suite; do not weaken the old Part lifecycle journey.
3. After the user integrates, resume the CURRENT Rooms/art/playtest follow-up in the 0.53.0 section
   below. Wave 3 through 3.8 is already built on this chain: do not restart the testing bay or builds.
   The manual, boss malware, interactive reviews and shop upgrades remain deferred as before.
4. Continue L1 by migrating legacy originals behind adapters, retaining one authoritative identity/
   condition record and proving rollback/duplicate/orphan scenarios. This patch is one migrated path,
   not the full registry. Keep L2 locked until a safe recovery policy exists. Design L4 clock charging
   separately from L5 UI overflow. Neither receives invented gameplay rules in this task.
5. Next scheduled structural review stays at 0.60.0. Historical review entries are provenance; green
   CI is not graphical acceptance or proof that the 41 historical fixes were individually reverified.

### Copyable Claude resume prompt

> Read HANDOFF's 0.54.0 section before continuing. The user asked Codex to implement the audit
> recommendations. This stacked follow-up fixes B53/L3: physical stock uid/condition/defect/knowledge
> survive delivery, removal/refit, return to stock, bag contents and comeback receipts. It preserves
> your #64/#65/#66 chain; integrate in that order under the user's merge instructions. Cross-review
> the new Delivered parts suite alongside all existing lifecycle/native tests. Then resume Rooms/art/
> playtesting, not old Wave 3 steps. L1 legacy originals/bench aliases and L2 orphan recovery remain
> open; L4 clock and L5 drawer overflow are separate. Keep the manual deferred and the 0.60.0 review.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Execution evidence: CHANGELOG 0.54.0. Native Godot checks are not a graphical/user acceptance claim.

## Previous — 0.53.0 Rooms instead of menus (Claude), 21 November 2026

Read first: done. #64 (0.51.0) and #65 (0.52.0) are open; this branch `feat/rooms-0530` is stacked on
#65 (merge #64, then #65, then this; retarget each to main as the one below merges). The user asked for a
major revamp: no menus, the shop counter as the main screen, doors and objects to move around (D161,
MENU_NAVIGATION.md rewritten). Built all at once as asked: `scripts/rooms/` (room_view, hotspot, room_art,
counter/workshop/outside rooms), three room scenes with placeholder drawing and replaceable art
(`docs/ROOM_ART_GUIDE.md`), close-ups with one named exit, the morning's customers at the counter.
Open for the user: confirm "the day is not timed" (read as no clock on the morning visits; night clock
kept); art; customer dialogue beyond the report text. Not started: shop level upgrades, interactive
reviews, scam consequences at the counter (the till, the bin), L1/L2, the manual.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## Previous — 0.52.0 session 3.8 Trust and reviews (Claude), 20 November 2026

Read first: done. 0.51.0 (#64, build requests) is open and unmerged; this branch
`feat/trust-reviews-0520` is stacked on it (review/merge #64 first, then retarget this PR to main).
3.8 talk-first was held; the user's answers are D160: no elegance mechanic; a trustworthiness level
feeding the shop level (up with good work, down only when customers find out; honest mistakes and scams
both hurt; upgrades later); every pickup leaves a review and some customers are petty ("a reason to feel
justified in scamming"); star reviews with comments on the player's phone, with a button to buy fake
reviews. Later (design doc 7c): more interactive reviews (replying, paying for a review to be removed).

For Codex's cross-review: review records replaced the plain score list (old saves migrate; one 0.48.0
assertion updated to the new shape); `Reviews.rating` is the single rating rule; the deceptions found out
at collection (`_hidden_deceptions`) and their `found:` comebacks; the review site's morning check; the
numbers in D160. Not started: shop level upgrades, interactive reviews, L1/L2, the manual.
Wave 3's plan ends here; what comes next is the user's call. Merge stays user-controlled.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## Previous — 0.51.0 session 3.7 Build requests (Claude), 20 November 2026

Read first: done. The user merged #63 (0.50.0, main `c04a278`, archived `archive/v0.50.0`) after
playing it ("all looks good for me so far"). 3.7 talk-first was held; the user's answers are D159
(rescaled uses table, wants quiet/headroom/brand/storage, swappable cases, budget = price with half up
front, assembly costs night time, builds from nights 4–5, scam hooks open). Branch
`feat/build-requests-0510` builds it (details: CHANGELOG 0.51.0, D159 proposals, DEVELOPMENT "Build
request contracts", PART_LIFECYCLE "Stage reached in 0.51.0").

For Codex's cross-review: a build reuses the PC shape with an empty first GPU/cooler held in
`removed_parts` (placeholder ids never shown: `CustomerPC.first_parts`); the repair bench is bypassed
for builds (pre-applied paste); `case` joined the parts record ("" = default case, zero effect);
the cheapest-build search used for solvability and budgets; the numbers in D159. Open for the user:
whether builds should include the paste minigame; case swaps for repair customers (upsell); returning
and clueless build customers. Not started: elegance (3.8), scam consequences, L1/L2, the manual.
Next in the plan: 3.8 Elegance and reviews (0.52.0), talk first. Merge stays user-controlled.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## Previous — 0.50.0 session 3.6 Testing bay + structural review (Claude), 20 November 2026

Read first, per Codex's 0.49.0 resume order (below): done. Claude cross-reviewed PR #62 (approve, three
non-blocking notes in the PR comment); the user then asked Claude to merge #61 and #62: main is 0.49.0
(`a62efc6`, tree identical to Codex's archive/v0.49.0); 0.48.1 archived as `archive/v0.48.1`.

3.6 talk-first was held; the user's answers are D158 (salvage + customers' broken parts into stock,
physical inspection, rig tests, degraded parts, untested test parts allowed but risky, scrap, room for
scams). Branch `feat/testing-bay-0500` builds it (details: CHANGELOG 0.50.0, D158 proposals, DEVELOPMENT
contracts, PART_LIFECYCLE "Stage reached in 0.50.0"). The structural review due at 0.50.0 is in
docs/BUGS.md (RC-6 new, RC-5 progress, L3/L4, B51; next review 0.60.0) — not postponed.

For Codex's cross-review: the condition/knowledge split on stock records and the derived
`shop_condition` copy (authority = stock record; rebuilt on load/switch; tamper test); that every
replaced customer original now stays as untested stock (customer-property question, D19); the salvage
clock gap (L4) and delivered-condition loss (L3); the numbers in D158. Not started: customer-part
identity migration (L1/L2), boss malware, scanners/economies, the manual (still deferred).
Next in the plan: 3.7 Build requests (0.51.0), talk first. Merge stays user-controlled.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## Previous — 0.49.0 Task Manajer detour complete; resume 3.6 Testing bay, 19 November 2026

The user approved the calmer in-chat demo and explicitly asked Codex to implement it in the game,
then tell Claude where the plan stopped. D157 and ANTIVIRUS_MINIGAME_DESIGN.md are now the live
contract; the original D156 review request below is historical, not a prohibition on this assignment.
The fast disappearing/reordering demo was rejected as too hard (possibly a future boss idea, NOT
approved for implementation). Do not restore it as normal difficulty.

### Where we were, and what this delivery changes

- Main verified at 0.48.0 / `6c18522`: PR #59 (generated tickets, session 3.5) merged with #60's bug
  ledger/lifecycle safeguards inside. Session 3.4 diagnosis is merged; 3.4m manual remains deferred.
- Claude's PR #61 / `feat/board-persistence-0481`, head `50d1602`, is still open: boards, bracket
  screws B49, vacuum persistence and close-on-bench paste save. This feature starts from that exact
  head and preserves it. PR #19 is an old design proposal; do not implement it wholesale or merge it.
- This branch `feat/task-manajer-standard` adds 0.49.0, the anti-virus side feature. It is NOT session
  3.6 and does not start testing-bay, build-request, elegance or identity-migration work.
- Scan -> Remove threat -> native Task Manajer inside the same monitor. Six stable rows; no hiding,
  spawning or moving rows; one advert at a time; miner alias changes every eight seconds. SEND and
  Enter share one handler, typed characters become uppercase immediately, typing pauses the action.
- Each actual `job.infection` (adware or miner) supplies its own source plus a Zombie watchdog;
  the watchdog is that infection's persistence, not a fabricated extra infection or a new save model.
  Cure only follows source/watchdog stopped, auto-start disabled and a clean verification reboot.
- Ten night minutes per attempt are trial tuning, spent/saved once before play. Stopping, crashes,
  power-off or closing the application retain infection and spent time. Unfinished UI progress resets
  on a fresh attempt. No payment, ready sticker, collection or reputation is applied by the minigame.
- No GameState, hardware/bench/tool hot-file or save-schema edits. Findings logs visible actions on
  the real night clock. New required suite: `test_antivirus.gd` (Antivirus); preserve all other suites.

### Claude: resume in this order

1. Read this section, D157, ANTIVIRUS_MINIGAME_DESIGN.md and WORK_PLAN's current Wave 3 table.
2. Check live main/open PRs. Cross-review this feature against the approved standard demo, including
   native SEND + Enter, clock/cancel/06:00, stale-ticket isolation and save failures. Review/merge is
   the user's decision: #61 first, then retarget this stacked PR from #61's branch to updated main.
   Do not merge this into #61 or rewrite/force-push another contributor's branch without instruction.
3. After user-controlled integration, base new work on that integrated main. The next planned work
   is still **session 3.6 Testing bay**: talk with the user about bay interaction/rules before coding.
   Scope: discover the actual condition of salvaged parts through testing, keeping actual versus
   known condition and part identity/custody separate. Salvage campaign stock integration is not
   magically completed by the anti-virus feature; inspect the existing boundary before designing it.
4. Version allocation: 0.49.0 is now this detour. Use 0.50.0 for the testing bay, with the already-due
   structural bug/root-cause review in that release; then 3.7 builds 0.51.0 and 3.8 elegance/reviews
   0.52.0, checking live reservations first. Do NOT postpone the 0.50.0 review to build requests.
5. Keep the manual deferred. Do not implement boss malware, scanners/store/subscriptions/power-up
   economies, more virus families or wholesale part-identity migration as incidental follow-ups.
   L1/L2 remain Investigating. The old engineering phases are not automatically resumed instead of 3.6.
6. Preserve the board/persistence work, ledger checks, Part lifecycle, Diagnosis, Generated tickets,
   Board and bench state and Antivirus suites. Run native navigation tests for new bay routing.

### Copyable resume prompt

> Read HANDOFF.md's 0.49.0 section before continuing. We finished 3.5 Generated tickets in merged
> #59 (including #60), then your 0.48.1 PR #61, then took the user-approved Task Manajer detour.
> Cross-review and integrate #61 then the stacked anti-virus PR only under the user's merge direction.
> After that resume 3.6 Testing bay, starting with its talk-first design questions, not build requests.
> 0.49.0 is used; bay is now 0.50.0 and must include the structural review, builds 0.51.0, elegance
> 0.52.0. Keep the manual deferred and the approved calm anti-virus controls; preserve all tests and
> canonical PC/condition/custody boundaries. Check live branch ownership before touching shared files.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
19 November 2026, Europe/Bucharest. Target-engine execution evidence is in CHANGELOG 0.49.0;
in-chat demo acceptance is not a claim of a graphical Godot playtest.

## Historical review request — anti-virus mini-game design, 18 November 2026

The user chose option D, a **Task Manager panic** (D156), for the anti-virus mini-game and asked that
Claude's first design ideas go to chat for review through this handoff. Read
`docs/ANTIVIRUS_MINIGAME_DESIGN.md` (proposal, nothing built). In short: the scan becomes the scouting
step (better products detect and tag more kinds; a weak scan never hides a virus, it only fails to tag
it); "Remove threat" opens a ~40-second "Task Manajer" round where malware processes with goofy faces
must be ended by clicking while real system processes must be spared (ending one blue-screens the PC);
an infection meter fills while malware runs. Enemy ideas: the existing adware and miner strains, plus a
worm, a disguised trojan, a rootkit, ransomware and a respawner. Scanners are owned products; power-ups
are consumable charges (Freeze Ray, Highlighter, Rubber Duck, Firewall, Sudo Hammer, Auto-Kill Bot).

Please review against D150 (observation-only evidence, solvable puzzles, difficulty by how evident a tell
is), D153 (difficulty by night) and D132/`malware.gd`; challenge or add ideas in a comment or a docs PR.
The eight open questions in its section 9 are the user's to answer. Do not start code: the user wants a
discussion first. Signed: Claude (Opus 5.5, model id claude-opus-5-5).

## Current — 0.48.1 user requests (Claude), 18 November 2026

The user merged PR #59 (with PR #60 inside); main is 0.48.0 (`6c18522`), archived as `archive/v0.48.0`;
GitHub shows #60 as merged too. Branch `feat/board-persistence-0481` carries 0.48.1 (D155): motherboards
as PC parts (out only once every other part is out; nothing fits while it is out), GPU bracket screws on
the rear bracket (B49), the vacuum's bin and hose saved with the shop, and a save when the game closes
on the repair bench (paste mid-press already survived leaving; now tested). Codex's Part lifecycle suite
ran unchanged and green; the new board journey lives in `tools/test_board_and_bench_state.gd`.

PR #19 (Codex's 13 November part-model proposal) was compared with the current code and reported to
the user: its direction continues in PART_LIFECYCLE.md; the user answered its open questions (D155 1–3).
Closing it is the user's call. The anti-virus mini-game (D155 item 5) is in discussion, nothing built.
Next in the plan after that: 3.6 testing bay (talk first). Merge stays user-controlled.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## Previous — 0.48.0 integration: PR #60 (0.47.1) reconciled into PR #59, 18 November 2026

The user asked Claude to reconcile the two open PRs per Codex's instructions and push the result.
Branch `feat/generated-tickets-0480` (PR #59) now contains PR #60's commit 656221d through a normal
merge commit (no force-push, no rebase). Neither PR is merged into main; merge stays user-controlled.
Merging #59 brings both; merging #60 first and then #59 also works (no further conflicts).

Done per Codex's 0.47.1 instructions: version stays 0.48.0 (0.47.1 is folded in, not overwritten);
all suites kept and registered (Part lifecycle, Diagnosis, Generated tickets) plus the Python ledger
checks; Codex's reconciled register adopted as is; Claude's former B48 row re-filed in the new format
with an index row, a detail section and Verified/Automated evidence linked to
`tools/test_generated_tickets.gd`; register checker and its malformed-ledger tests run before pushing.
No runtime identity migration was started (instruction 5): L1/L2 stay Investigating. The 0.50.0
structural review marker is unchanged. Both sections below remain current instructions.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session.

## Current work — 0.47.1 bug register and lifecycle safeguards, 18 November 2026

User assignment: implement the bug-audit recommendations in a NEW PR and include resume instructions
for other AIs. Base is merged main 0.47.0 (`ed64f21`): PRs #57 and #58 are already merged. Claude's
PR #59 (0.48.0 generated tickets) is open and touches shared runtime state. This branch does not edit
GameState, benches or the generator, and it does not merge any PR.

Delivered here: one reconciled 47-bug index with details; explicit Fixed/Verified evidence types;
current RC-1/RC-4 status, diagnosis-safe RC-2 wording, next checkpoint 0.50.0; Python ledger validation
and malformed-ledger fixtures run in CI even for docs changes; required cross-PC Part lifecycle suite.
Read docs/PART_LIFECYCLE.md for complete-journey invariants and the staged part-record direction.

**Important boundary:** lifecycle tests pass for existing shop-stock uids/custody; a full stable
customer-part registry and orphan recovery are NOT implemented here. L1/L2 are explicitly Investigating,
not invented fixes or automatically promoted confirmed bugs. Do not infer their completion from green CI.

### Instructions for Claude / any integrating AI

1. Read this section, docs/BUGS.md filing rules, docs/PART_LIFECYCLE.md and the new 0.47.1 changelog.
2. Check actual main and open PRs. This branch is independent of #59; reconcile whichever lands second.
   Preserve the new bug checker/tests AND Diagnosis/Part lifecycle/Generated tickets workflow entries.
   Do not overwrite 0.48.0 metadata or reuse a B-id allocated in another open PR. If a new ledger row is
   added, add its matching detail section and explicit evidence status; run the checker before pushing.
3. Keep Fixed separate from Verified; name Automated/Graphical/User evidence and link the regression
   or recording. No claim of user acceptance from headless tests. Historical notes are not current rules.
4. Before further ownership/save changes, run tools/test_part_lifecycle.gd and add the missing complete
   journey. Same-model neighbours, returns after damage, inactive-PC reload and repeat collection matter.
5. Coordinate ownership before the next runtime identity migration. Introduce stable physical customer
   records incrementally behind existing projections; do not create a second writable PC database.
   Satisfy the L1/L2 acceptance scenarios before marking them fixed. Never unlock or delete orphan
   custody merely because the referenced ticket cannot be found.
6. Read optional/external values once, validate the local value, then use it. Keep missing-key and
   malformed nested-record fixtures (B8/B30/B34). Do not check get() then index the absent key.
7. Reconcile current root causes at 0.50.0 and advance its review marker. Keep old review provenance.
   Review/merge remains user-controlled. The deferred manual remains deferred.

### Copyable resume prompt

> Read HANDOFF.md's 0.47.1 section and PART_LIFECYCLE.md before continuing. This PR reconciles the
> bug ledger and adds enforced ledger/evidence checks plus complete cross-PC lifecycle tests; it does
> not migrate all customer-part identity or solve orphan recovery. Preserve all bug IDs and test suites
> when reconciling with PR #59. Check version allocation and live hot-file ownership. For identity
> work, stage one authoritative per-part model with separate actual/known condition and prove the
> complete migration/rollback journeys before closing L1/L2. Do not treat historical notes or green CI
> as user verification. Run the register checker and relevant lifecycle/native tests before pushing.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest. Execution evidence is in CHANGELOG 0.47.1; no manual playtest claimed.

## Current — 0.48.0 session 3.5 Generated tickets (Claude), 18 November 2026

Main was 0.47.0 (ed64f21): the user merged PRs #57 and #58; archived as `archive/v0.47.0`. No new Codex
commits or PRs were found after the pause; Codex's PR #58 answers are carried in D152's follow-up.
Branch `feat/generated-tickets-0480`.

The user answered the 3.5 talk-first questions (D153, approved): option B (a part the shop can buy
counts as a test part; part variety matters); tickets arrive in the morning, as many as reputation and
online rating bring; difficulty rises with the night; pool = existing problems + customer overclocks +
the clueless customer; generated customers are parody names with a profession.

Built: `shop_rating.gd` (rating, reputation, arrivals), `ticket_generator.gd` (people, PCs, problems,
complaints, pay, seeded draws, and the offer-only-if proof: diagnosis.gd evidence with owned or
affordable parts, difficulty within the night's cap, a like-for-like repair that can satisfy the real
needs), saved generated customers/reviews/world seed, morning arrivals replacing the fixed two-customer
loop, and B48 (manifest rejected bought first-slot parts after reload). Numbers are D154 proposals.

For Codex's cross-review (D154 and the CHANGELOG "Known issues"): the arrival formula and caps; the
level caps and pool levels; whether the proof meets your "suitability, workload, sequence" bar (PSU
suitability, the repaired-PC pickup check and boot-masking are in; two purchases are not budgeted
together); the "PC without any GPU still boots" gap; REPAIR_LOOP_DESIGN section 6 is yours to update.
Evidence: GitHub Actions, Godot 4.7.2 headless, 25 suites green (Generated tickets 65). No playtest yet.
Next in the plan: 3.6 testing bay (talk first). Signed: Claude (Opus 5.5, model id claude-opus-5-5).

## Previous delivery notes — historical snapshots, not current merge instructions

The following version-specific statuses are retained as provenance. The current section above and
the actual repository state supersede their old open/stacked/merge-order/ownership claims.

## Previous — 0.47.0 session 3.4 Diagnosis (Claude), 18 November 2026 (merged)

Branch `feat/diagnosis-0470`, **stacked on PR #57** (0.46.3, head 02b6343). Claude reviewed Codex's
0.46.3 follow-up first, as instructed: collection materialization, component damage custody, the wider
measurement fingerprint and the starter-model/one-time CPU marker are correct and kept unchanged. No
0.46.2 versions were reapplied. Merge order for the user: PR #57, then this PR.

Built (D150; details and proposals in D152 and CHANGELOG 0.47.0): the Findings notebook on every PC
(observations at bench open, measurements from every monitor test, work history logged inside
GameState's mutators, night number + night clock, outdated marking, no conclusions or hidden health);
the Stress lab as its own monitor app; the 06:00 limit for timed tests; an INCOMPLETE note when a run is
stopped; `diagnosis.gd` solvability/difficulty for tests and the future generator (never UI).

**Not built: the diagnosis manual.** The user deferred it on 18 November 2026 as a separate later
point (WORK_PLAN row 3.4m). Codex's manual content/format work can continue; runtime integration waits.

Codex answered the four PR questions (comment on PR #58); applied in the same PR: Relu's complaint
corrected, the solvability check requires a spare that suits the PC. Settled vs. still-proposed points
are recorded in the D152 follow-up. Codex's full code cross-review of PR #58 is still pending.
Evidence: GitHub Actions, Godot 4.7.2 headless, 24 suites green (Diagnosis 55 checks). No playtest yet.
Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session, 18 November 2026.

## Current PR #57 follow-up — 0.46.3, 18 November 2026

The user explicitly assigned Codex to fix all findings from the PR #57 review and push the result.
This overrides the earlier design-only Codex boundary **for this bounded compatibility repair**.
Main is 0.46.1 (`39b1884`, PR #56 merged). PR #57 is the unmerged compatibility patch; this follow-up
starts from its reviewed head `07d7cb9` (0.46.2). Do not describe PR #56 as still open or diagnosis as
shipped. Claude reported no unpublished work in PR #57; independently verify any newer work.

Implemented by this follow-up:
- At collection, materialize all shop-fitted parts into the actual PC record before releasing custody,
  consuming stock once. The morning card, save/reload and repeat settlement keep the same build.
- Removing a damaged shop GPU/cooler preserves it as known broken stock and restores the original's
  own health flags. Save/load retains that damaged stock and its visible damage annotation.
- Measurement signatures include catalogue hardware, fitted test parts/identity and dead-slot state.
  Prior measurements remain historical and become outdated when the relevant hardware changes.
- Starter RAM/CPU resolve to existing catalogue models while retaining their original owned uid.
  The physical cooler-before-CPU rule applies to shop CPUs too. A compatible save flag marks the
  one-time starter CPU migration so collection cannot create a free replacement on reload.

No Findings notebook, manual UI/content, standalone stress app, new cases or generator was added.
Known limitations from Claude's PR remain: identical customer-part identity is still slot-derived,
and an orphan fitted_in mark has no recovery UI. These were not the four requested review fixes.

**Claude resume:** review the 0.46.3 changes/tests in PR #57 before resuming 3.4; do not reapply the
0.46.2 versions of settlement, return_replacement, stock fitting or measurement signatures. Preserve
the real build at collection, component-specific damage and the one-time migration flag. After
cross-review and user-controlled integration, resume the existing split: Codex diagnosis/manual
content and cross-review; Claude diagnosis/manual runtime integration and tests. Check live ownership
before editing shared files. This task pushes fixes but does not authorize a merge.

Checks/evidence: see CHANGELOG 0.46.3; target Godot 4.7.2, with reproductions that failed on the reviewed
PR before the fixes. No manual graphical playtest is claimed.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest.

## Read before resuming — diagnosis design and work split, 18 November 2026

**User-approved design update, not an implemented diagnosis release.** The latest user instructions
approve pushing the diagnosis design, select a manual for optional assistance, exclude customer
follow-up questions for now, and require an explicit Codex/Claude work split. Any existing code that
conflicts with these decisions must receive a separate compatibility patch FIRST, before Claude
continues new diagnosis features. This section supersedes the earlier discussion-only handoff.

Original design baseline was main 0.46.0 (3.3b merged in PR #55). Update: PR #56 is merged as
0.46.1 and PR #57 contains the runtime compatibility work described above. Session 3.4 remains next.
The following sections describe the approved design and standing split; the top-level current user
assignment takes precedence over their older design-only/no-runtime notes.

### Read and apply

1. Read this section, DEVELOPMENT.md, the newest CHANGELOG entry, then D137/D148/D149 and D150.
2. Read docs/REPAIR_LOOP_DESIGN.md section 5 (the detailed approved diagnosis contract) and the
   diagnosis summary at the top of docs/DESIGN.md.
3. Read docs/WORK_PLAN.md's diagnosis work split. Check actual branch and file ownership before editing.

The customer complaint starts diagnosis. Complaints can contain several aspects; Findings records
physical Observations, Measurements and Work history distinctly, never the player's conclusion.
Hidden health must not leak from hover text, Hardware check, fitting permissions or other UI.
Detailed visual component inspection and the proposed example-case pack are deferred.
Findings must use the canonical night clock and night identity; preserve old measurements as
historical and mark them outdated after relevant configuration changes. No independent fake timer.
Preserve D130/D133/D146 hidden-installation and delayed pickup/comeback rules.

Story-case facts/faults stay fixed. Optional explanations and graduated guidance come through a
**manual**, consulted by the player. No automatic difficulty adjustment, mentor, new customer
follow-up dialogue, or automatic diagnosis. The manual does not read hidden fault flags to reveal
an answer. Its exact chapters, presentation and degree of guidance remain implementation/design
proposals to review, not an approved case-specific hint engine.

Temporary tests use actually owned, suitable parts; removed customer parts remain theirs. A test
swap is not a paid replacement. Permanent handover at collection settles ownership/costs; a working
part replaced unnecessarily costs the player and its original goes into stock. Keep individual part
identity and visible custody clear. Test results report observations within the test's scope.
Repeated tests cost their normal time; refused/incomplete tests cannot fabricate a completed result.
Reviewing notes/manual adds no separate diagnostic time charge; do not rewrite the global clock.

Cases must have an achievable evidence path with the player's available capabilities. Mandatory
story jobs cannot simply disappear for lack of a test part. The exact alternate-path/acquisition
solution for each such case still needs design. Optional generated tickets remain Wave 3.5;
this does not authorize a generator, testing bay, build requests or the later example-case pack.

### Work split — Codex and Claude

| Owner | Work | File boundary |
| --- | --- | --- |
| Codex | Diagnosis specification, manual content/design, ambiguity classification proposals, acceptance criteria; cross-review Claude's patch and 3.4 | HANDOFF.md and diagnosis design documents during this pass; later manual content in a dedicated file after agreeing its format. No concurrent runtime edits. |
| Claude | Audit current code/unpublished work; make the compatibility patch first when needed; then implement 3.4, manual reader integration and regression tests | Diagnosis/state/ownership/clock/save/bench/monitor runtime and associated tests. Own shared hot files for this assignment; keep the manual UI read-only with respect to PC state. |

Codex can develop manual wording and evidence-design notes in parallel with Claude's code audit/patch.
Do not both edit the same design file: Codex owns the diagnosis sections for this pass; Claude reports
necessary contract corrections in his PR for Codex to incorporate. Claude logs his own code changes
and updates implemented status at integration; this documentation push does not certify his code.
Runtime manual work is Claude's integration task, not a second Codex hot-file PR. Agree the small
manual-content interface before wiring it; do not wait for a whole future content catalogue.

### Claude's required resume order

1. Identify your actual branch/base, completed/unpublished 3.4 work and changed files. Preserve it.
2. Compare it against the detailed section 5 contract. Audit health leaks, fitting/refitting,
   temporary/permanent custody and payments, shared-clock logging, stale results and pickup secrecy.
3. **If any already-built behaviour conflicts, make a separately versioned compatibility patch and
   PR first.** Keep new diagnosis/manual features out of that patch. Describe the changed behaviour,
   add meaningful regression tests, and follow the existing cross-review/merge process. Do not
   invent a patch when the audit finds no necessary delta; report the evidence instead.
4. Codex cross-reviews that patch. Continue 3.4 from the reconciled baseline after integration;
   do not silently combine compatibility fixes and the feature release. Unpublished feature work
   should be rebased/adapted, not discarded or relabelled as already merged.
5. Implement the approved diagnosis scope and manual access using Codex's content/design. Keep
   unresolved taxonomy/detail choices marked proposed; do not invent extra case packs or dialogue.
6. Update current implementation evidence and handoff; request cross-review. User controls merge.

### Copyable prompt for Claude

> Before resuming Nightshift, read the top of HANDOFF.md on docs/handoff-current-0451 (PR #56),
> docs/REPAIR_LOOP_DESIGN.md section 5, D150 and the diagnosis split in WORK_PLAN.md. Codex owns
> diagnosis design/manual content and cross-review; you own the runtime compatibility audit/patch,
> then session 3.4 and manual integration/tests. Report your current branch and unpublished scope.
> FIRST compare existing code with the approved rules. If it conflicts, deliver a separate patch
> before continuing new features; preserve and adapt your existing work. Audit hidden-health leaks
> including fitting refusal, owned test-part/customer custody and collection settlement, Findings
> timestamps from the actual night clock, outdated measurements, and hidden installation/pickup
> boundaries. Story facts stay fixed; assistance is an optional manual. No customer follow-up
> questions, automatic difficulty changes, mentor or hidden-fault-driven answers. The later example
> cases remain deferred. Coordinate shared file ownership, run relevant regressions, obtain Codex's
> cross-review and follow the existing user-controlled merge process.

Open details: complaint layout, final ambiguity categories, manual chapters/presentation, and the
available diagnostic route for each mandatory story case. These do not reopen confirmed rules.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest. Documentation only; no Godot run or runtime implementation claimed.

## Current handoff — 0.46.1 documentation correction

**Verified 17 November 2026 against main 0.46.0, commit
`b6004d2d04bb3c97cb7d40ffa93a556760257b08`.** This patch changes documentation and version metadata
only; the game implementation remains the 0.46.0 baseline. No new gameplay is built here.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
17 November 2026, Europe/Bucharest. The user explicitly asked to correct this handoff FIRST, then
propose parallel-work choices and wait. That does not approve implementing any of those choices.

### Read next and authority

1. `DEVELOPMENT.md`, then the newest `CHANGELOG.md` entry.
2. `docs/DECISIONS.md`, especially D148 for hardware and D134–D147 for the current repair loop.
3. `docs/WORK_PLAN.md`, **Wave 3** table, for current sessions/ownership (not just the older 17-step table).
4. `docs/HARDWARE_CATALOG.md` and `docs/REPAIR_LOOP_DESIGN.md`, then the files assigned to your task.

Latest explicit user instructions and confirmed decisions control scope. Design documents contain
both decisions and proposals: do not promote proposed numbers/formulas into approved design. The
repair-loop document now distinguishes shipped sections from the approved, not-yet-built diagnosis
design; its BUILT markers, current work-plan table and numbered changelog establish implementation.
Older statuses below this CURRENT section are history, not instructions to redo or block shipped work.

### What is actually in main

| Implemented | Current state |
| --- | --- |
| Menus / 0.42.0 | Room PC slot opens work directly; Repair, Hardware and Monitor view the same selected PC; Arrange room, Pause and Continue exist. Menu decisions are D142–D144 after integration renumbering. |
| Wave 3 session 3.0 / 0.41.2 | Repair bench split into helpers. This does not mean all old engineering-plan steps are finished. |
| 3.1 / 0.43.0 | Ticket records; ready sticker and customer call actions on room PC/header ticket. |
| 3.2 / 0.44.0 | Night ends at 06:00, morning report, collection/payment and delayed comebacks, next-night transition. |
| Thermal follow-up / 0.44.1 | Screws can be done during the press using Space; locked cooler remains visible; wiping feedback and thermal-service completion guidance. |
| 3.3 / 0.45.0 | Catalogue-based hardware/PC stats, PSU boot requirement, cooler support, several GPUs in the stats model, derived FPS/pickup/diagnosis. |

The connected customer-PC hardware view, screwdriver/install faults, Shop tool upgrades, malware,
overclocking, timed monitor tests and Work + match/Client views are already part of this baseline.
Do not describe Hardware as the old separate sandbox, or anti-virus/overclocker as unimplemented.

### D148 — decisions versus proposals

**Confirmed direction:** CPU, GPU, RAM sticks, storage, PSU, cooler; motherboard/case fixed for now;
four or five prototype models per type; close-parody names; PSU and cooler as support stats;
processing/graphics with 100 as a mid-to-late-game soft ceiling, top single GPU parody at 98;
multiple GPUs allowed. This prototype selection does not cancel the earlier larger release-catalogue goal.

**Implemented trial proposals, NOT final balance:** model prices/stats in HARDWARE_CATALOG;
best GPU + half next + quarter next; 50 W base draw; 0.5°C per excess CPU watt; Counter Stroke 2
demands 11 graphics / 15 processing; repair stock tiers mapped to catalogue models with old prices.

**Actual catalogue count: 28 models** (5 CPU, 5 GPU, 4 RAM, 4 storage, 5 PSU, 5 cooler), counted
from `hardware_catalog.gd`. The old 0.45.0 changelog says 27; that historical count is inaccurate.

### Session 3.3b is now merged — 0.46.0

PR #55 merged while this correction was being prepared. WORK_PLAN now marks 3.3b done and
3.4 Diagnosis next. CPU, RAM, drives and PSU can be removed into the drawer and refitted;
the cooler must come off before the CPU. There is a second PCIe slot, two drive slots,
a PSU connector, and Order parts for catalogue purchases. Customer parts remain customer-owned
loose parts. Empty required slots prevent booting. Rearrange drawer repacks only the drawer.

Known limitations from the release: CPU removal does not update the repair bench paste stage;
RAM and drives refit in slot order. Connector positions and free fitted parts remain proposed.
This documents the merged implementation, not a new interactive playtest.

Claude's previous 3.3b reservation is historical now. No next code assignment is assumed:
confirm his next scope before touching shared hardware, inventory, PC rules or GameState files.
The established hot files are scripts/view/bench_view.gd, scripts/bench/tool_rig.gd and
scripts/state/game_state.gd. Other shared files can collide too. One open PR per hot file;
cross-review before merge. No WORK_PLAN edit here.

### Historical Wave 3 allocation (superseded by the current 0.49.0 section)

| Session | Planned version | Scope | Design conversation still needed? |
| --- | --- | --- | --- |
| 3.4 Diagnosis | 0.47.0 | Symptoms hide faults; observational Findings; standalone long stress app; owned test parts; mistaken-replacement cost/original-to-stock rule | Existing decisions recorded; implementation depends on 3.3b. |
| 3.5 Generated tickets | 0.48.0 | Events, difficulty, automated solvability checks | Yes: handling unowned test parts. |
| 3.6 Testing bay | 0.49.0 | Discover salvaged parts' true condition | Yes: bay interaction/rules. |
| 3.7 Build requests | 0.50.0 | Budget, needs/wants, assembly, half upfront/half at collection; structural review | Yes: workload requirement numbers on D148's new scale. |
| 3.8 Elegance/reviews | 0.51.0 | Elegance, shop level and online reviews | Yes: meaning of elegance/progression. |

The older workload table uses an earlier score scale; its proposed numbers need reconciliation
before build requests. Playtest gates are proposed after 3.2, 3.4 and 3.7. Personas/lore and the
other later work remain in the broader design; this table is the current Wave 3 slice only.
The old unmerged shared-PC proposal PR #19 is a proposal from a much earlier source version;
reconcile it with today's `job.parts`/ticket/inventory implementation before using it.

### Execution evidence and next action

The 0.46.0 CHANGELOG records CI run 44148883923 with 25 required suites green,
including Hardware parts (27 checks). This is Claude's recorded evidence, not a run or
interactive playtest by Codex. This documentation patch's checks are in its changelog entry.

**Next (updated 18 November):** follow the top-level work split and Claude resume order. Codex owns
design/manual content and cross-review; Claude audits and patches conflicting existing behaviour
FIRST, then resumes 3.4 integration. This push changes documentation only; no merge is authorized.

## Historical handoffs — retained for provenance, NOT current project status

Everything below records earlier deliveries. Labels such as "current", "next", "not implemented",
"do not push" or "unmerged" within those old notes apply to their original date/version only.
Use the CURRENT handoff above, current decisions/work plan and newest changelog instead.

**Historical source 0.42.0:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
16 November 2026, Europe/Bucharest. Based on merged main 0.41.0 (1a46912), not the old PR #41
branch. PR #41 and Claude's 0.38–0.41 additions are already merged. New feature/menu-navigation
branch implements the user's approved UX path. Read docs/MENU_NAVIGATION.md before future menus.
PC slot now opens the bench directly; common Repair/Hardware/Monitor header, normal/Arrange room,
Pause/Settings/Title, and Continue to last activity/view. Hardware is the actual customer PC now.
All current monitor/timing/install/malware/overclock/Shop behavior is preserved; busy monitor tests
block navigation until completed/cancelled. No bench_view/tool_rig/GameState hot-file edits or
WORK_PLAN.md changes. New UI-only navigation preferences are run-bound; canonical saves unchanged.
Push requested; open new review PR and unique archive/v0.42.0, do not merge automatically.
Claude goes next for cross-review. Older branch/current-version notes below are historical.

**Historical 0.37.0:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User-approved thermal UI/paste/bin changes: see THERMAL_SERVICE.md.
Three-choice material MenuButton, real super-paste cooling/tint/persistence, no tool toggle,
readiness-only Mount under socket, distinct tabs, retract push-button physically on the bin.
Extends PR #41 only; keep unmerged for Claude cross-review. Narrow bench_view/tool_rig/GameState
hot-file edits are explicitly user assigned and part of that same PR. WORK_PLAN.md unchanged.


**Historical 0.36.0:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. New user assignment: room PC drop slot, remove dropdown/duplicate
shortcuts, standard top-right Activities. See ROOM_WORKSHOP.md. The uploaded 02:05 recording visibly
shows v0.32.0, not the fixed room in 0.33+. Replay its native click sequence on this delivery.
No new hot-file edits; this extends existing PR #41 only. Do not merge automatically. Claude next
for cross-review. Current hardware bench remains shop stock, not a second customer-PC repair model.


**Historical 0.35.0:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User requested cloth inset, PCs off by default, then Wave 2.
The same bench-feel PR now includes a first diagnostic desktop (boot, thermal, Vapor purchase/FPS).
Anti-virus/overclocker are explicitly upcoming, not fake tools. New/missing-power PCs default off;
saved explicit power is respected. No automatic merge. See docs/SOFTWARE_WAVE_2.md.
Current user assignment supersedes the older Claude software split for this slice only.
Hot files bench_view/tool_rig/GameState are touched in this ONE existing PR; Claude reviews next.


**Historical 0.34.0:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User authorized publishing/merging room 0.33.0: PR #40 merged
at f31eaea after CI passed. Earlier local/no-push notes below are historical. New spool/brush/weight
changes are a separate review branch. Spool now stores deployed length separately from capacity;
brush starts equipped on key 1, vacuum is key 2; heavy waste can be nudged. No GameState edits.
User directly requested these narrow hot-file feel changes; no competing bench PR was open.
Claude cross-reviews the new changes before any merge. See docs/BENCH_FEEL_0_34.md.


**Historical local delivery 0.33.0 — read before historical notes:** Codex (GPT 6.1 Sol,
model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026, Europe/Bucharest. Based on integrated
main 0.32.0. PR #39 is already merged; review findings: docs/REVIEW_0_32.md (comment posted).
Storage now uses direct room furniture, 4×2 bays, zoom/pan and no per-rack buttons; popup has real
VBox layout. B16/B20 fixed here; B19 night-workshop ticket overflow reported, not changed here.
Storage sidecar schema 2 migrates v1 without losing allocations. No hot files edited. Code stays
local per prior no-push instruction; do not publish or merge automatically. Use the 0.33.0 ZIP.


**0.31.0 handoff:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. Rebased on main 0.29.0 after Claude's PR #37 landed.
Fresh piles per arrival, fourteen collectibles, heavy native obstacles; see SALVAGE_VARIETY.md/D113.
Prior local inventory fixes stay unpublished. No hot-file edits; leave new PR unmerged for review.


**Project:** Nightshift, a 2D pixel-art PC repair and shop-management game for Steam. This folder is a
small Godot 4.7.2 foundation trial, not the game. **Version at historical handoff: 0.45.0.**
**0.30.0 handoff:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 14 November 2026
(Europe/Bucharest). Stacked follow-up branch; leave 0.29.0 and this work unmerged. New Game enters
Activities; Workshop selects two actual repair PCs, Final Check never finishes/pays; third rack shelf.
Read docs/NIGHT_WORKSHOP.md for the temporary inactive-ticket save bridge and interrupted-switch
recovery. No hot files or customer/shop files changed; additive view wrappers only. Claude goes next
on cross-review and eventual canonical-state integration.

**0.29.0 storage handoff:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 14 November 2026 (Europe/Bucharest). New rack scene: F5 → Storage rack. Read docs/STORAGE.md. Keep this PR unmerged for Claude review. No hot files or customer/shop code changed. Existing purchase/drawer capacity remains separate; shared capacity enforcement needs a coordinated follow-up.

**Owner:** the user, the creative director, a complete beginner. GitHub is connected; scoped branches/PRs are current workflow, with ZIPs available for playtests.

**Signed:** Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026, 0.27.0 native dumpster physics (also 0.26.0 salvage demo). Earlier contributors: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026, 0.22.1. Earlier contributors: Claude (Sonnet 5.5, model id claude-sonnet-5-5), working in a chat session, 2026-11-12, up to 0.14.1; Claude (Opus 5.5, model id claude-opus-5-5), same session, 2026-11-13, 0.14.2 to 0.15.1. Codex: read docs/HANDOFF_FOR_CODEX.md.
**Claude did not run Godot.** Subsequent review ran the automated checks in Godot 4.6.3, not the user's real version 4.7.2 (confirmed by the user on 2026-11-12). **Update 0.14.0:** GitHub Actions ran the automated checks on Godot 4.7.2.stable.official (headless): 172 data schema and 344 regression checks, 0 failures, on 0.12.2. Still pending: human interactive validation (looks, feel, mouse and keyboard play) on 4.7.2.

## Historical update 0.32.0 — integration of all open PRs, the broken-GPU dead end, the bug register, Upgrades tab

Signed: Claude (Fable 5, model id claude-fable-5), working in a chat session, 14 November 2026.
The user's playtest hit a loop-blocker: a broken GPU "replaced" at the hardware bench still
failed the final check, because the hardware bench is a sandbox that never writes job state
(root cause RC-1 in the NEW `docs/BUGS.md` — the bug register every bug now goes into, with a
structural review every 10 versions, next at 0.30.0). 0.29.0 makes part states ONE binary
source of truth (`GameState.part_state`): the ticket, the final check and the benches all show
fitted/working per part and name the exact repair path (repair bench → tray → Replacement
stock). The spare-part bench now says what it is, and its own loop is coherent: a demo CPU
exists and the board has a cooler mount that requires the CPU first (real-life order). Also:
tool upgrades grouped under a shop Upgrades tab; the ticket is a bounded scroll like the other
cards; the main-menu card fits its buttons and status text again; and the two real
qualifications from Codex's review of the D108 fix are addressed (release-at-rim grace,
free-space cargo spawn). Still open structurally: actually connecting the customer's PC to the
hardware bench (RC-1 / D79 note).
Integration note (15 November 2026, user: "Everything ChatGPT did is correct. Merge those two PR, as
well as PR 38 ... keep an archive"): main now contains Codex's 0.29.0 storage rack, 0.30.0 night
workshop and 0.31.0 salvage variety plus this release, renumbered 0.32.0 (it first shipped alone
as 0.29.0; decisions D109-D112 became D114-D117). The new `scripts/rules/part_states.gd` is the one
part-state rule for the shop ticket, the old final check, and the night workshop. Archives:
archive/v0.29.0 (storage), v0.30.0 (night), v0.31.0 (salvage variety), v0.29.0-claude (standalone
0.29.0), v0.32.0 (this integration).

## Historical update 0.28.0 — cross-review fixes, rotation, settings, rim containment

Signed: Claude (Fable 5, model id claude-fable-5), working in a chat session, 14 November 2026.
Both cross-reviews are done: Claude reviewed and merged Codex's native dumpster physics (PR #33),
and applied all three findings from Codex's cross-review of 0.25.0 (PR #32): the shop's lower-card
tabs are bounded ScrollContainers (no more dossier overflow), trust moves at least ±1 per pickup
(trust_step; integer division used to swallow small scores), and loaded history entries are rebuilt
field by field with per-customer trust_start defaults (plus a 10-entry cap, D106). User requests in
the same release: the dossier leads with a NEEDS line; customers ROTATE per completed ticket (D104,
so Relu D. actually appears); a Settings dialog on the main menu with a sound slider (D107, its own
user://nightshift_settings.json); and the held salvage find can no longer bulldoze other finds out
of the dumpster (D108: rim barrier on layer 256 that only the carried body ignores). Wave 2 (the
software-checks monitor screen) is deliberately NOT started, per the user.

## Historical update 0.27.0 — real 2D dumpster physics trial

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
Same entry F5 → Salvage demo, now side-view with native rigid-body gravity/collisions/support/collapse.
Pull with bounded forces; lift over the visible rim before packing. E opens containers/strips PCs;
boxes become hollow frames and bags flatten, revealing the same physical contents. World release drops
in place; cargo rollback restores committed grid. Actual grip travel costs time once. Pause/focus/menu
handling preserves isolated session custody; app exit/Reset still loses this demo's progress.
Read new body/world contracts and D103. Ten suites include native engine-frame tests, plus an optional
20/50/100-body fall/settle/pulling profiler. Placeholder graphics and rigid bags, no final feel acceptance.
All five core docs revision 1.15. No hot file/customer/software/shared-save change. Existing PR #33 is
updated rather than opening a second salvage PR. Claude cross-reviews; do not self-merge. Keep 0.26.0
archive/ZIP as the previous prototype. This is an experiment; final minigame format depends on playtest.

## Historical update 0.26.0 — playable salvage sandbox

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
F5 → Salvage demo. Two test cars/sites, physical layered searching/opening/stripping, sorting, trunk
packing, effort/travel budget and few-day cycles. Only in-memory state through menu/revisits; app exit
or Reset clears it. Return/unload are sandbox transactions, not campaign stock or saves. Read
SALVAGE_DESIGN_PROPOSAL.md, D98–D102 and DEVELOPMENT's contracts. Claude's merged 0.25.0 customer/FPS/
boot rules are preserved. No hot file, customer/software code, WORK_PLAN.md or shared state was changed.
User approved the design and requested code; this first isolated slice is implemented under D91. Shared
clock/save/stock/PC adapters remain Claude's work before campaign integration. All timings/loot/cars are
tuning. Simple shapes, layered nudges and outline bags are not final graphics/3D cloth. User must assess
feel and layout; target-engine headless results are in CHANGELOG. Nine suites now include salvage.
This PR supersedes unmerged design PR #31 (renumbered to avoid Claude's customer D92–D97); preserve both
contributors' records if shared docs/version numbering advances again. Cross-review; do not self-merge.

## Historical update 0.25.0 — the customer model, first wave

Signed: Claude (Fable 5, model id claude-fable-5), working in a chat session, 14 November 2026.
The user approved docs/CUSTOMER_MODEL_MAP.md point by point before any code (D92–D97). Customers
now have professions, personas, trust, budgets and NEEDS; the boot test replaces the required-power
threshold (any output passes as long as the PC starts); the shop can buy video games (Counter
Stroke 2) and an fps simulation says how the PC runs them; the first passing final check scores
the PICKUP 0–100 against the customer's real needs, writes trust and history into the save
(`customer_state`, the shop's property, survives new_game), and says when an unhappy customer
comes back. Split: Claude owns this customer/software part; Codex builds the dumpster-salvage
minigame in parallel (docs/CODEX_PROMPT_SALVAGE.md); Claude cross-reviews Codex when both are
done. The software-checks monitor screen (boot test, anti-virus, Vapor store, overclocker) is the
next wave — the rules behind it are built, the screen is not.

## Historical update 0.22.1 — bounded performance pass

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.
The user explicitly authorised the measured performance recommendations. This isolated PR makes narrow
bench_view integration edits; it does not change tool_rig, game_state or hand rules. Claude retains
Phase 2 ownership and must cross-review before merging/continuing step 7. Read docs/PERFORMANCE.md
and the newest changelog. Settled clamped hoses now sleep and wake on changed constraints; paste
measurements/uploads and bin/paste controls skip unchanged work. Static case/tray commands live on
a separate CanvasItem. Paste height-field writes must invalidate its revision. No save format or
asynchronous-save change. Eight required suites (new cache/wake contracts); quick profiling is optional.
No interactive visual/feel acceptance is claimed.

## Historical update 0.20.1 — test cleanup only

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.
The user explicitly authorised test cleanup during Claude's engineering work. No scripts/ files change;
Claude retains the three hot files. Read docs/TESTING.md. Seven required suites remain; copied rack/fresh
checks and historical balance assertions are reduced, full diagnostics are selective and a smoke mode
is available. The existing lever bypass and rejected-selection highlight are honest, non-blocking
pending-contract failures, not gameplay fixes or passing coverage. Claude fixes/promotes those cases.
Do not merge this PR until Claude cross-review/user acceptance. Next action and exact checks: CHANGELOG.

## Historical update 0.19.1 — work plan and split of responsibilities

Signed: Claude (Opus 5.5, model id claude-opus-5-5), chat session, 13 November 2026.

The user approved `docs/WORK_PLAN.md`: 17 code-health steps in 5 phases, and a split: **Codex** does design and gameplay features, **Claude** does engineering and code health. Hot files (`scripts/view/bench_view.gd`, `scripts/bench/tool_rig.gd`, `scripts/state/game_state.gd`) have one owner at a time; during Phases 2 and 4 Claude owns them. Cross-review each other's pull requests. Prompt for Codex: `docs/CODEX_PROMPT_WORK_PLAN.md`. Docs only; no game change.

## Update 0.19.0 — bin feedback, hose recovery and silent audio

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.

Read AUDIO_DESIGN.md for the new silent contract. AudioFeedback only emits events, never sound; sim/rules/state do not depend on it. View owners stop loops on stage exit/tree exit, cooldowns/history are bounded and freed owners are pruned. New test_audio_and_vacuum.gd runs in CI. No save migration.

Video: bin fills around 35 seconds, intentionally stopping extraction; switching tools used to overwrite its only warning. Persistent status and Empty bin action fix that confusion. Tool/service rows are regrouped. Hose 2-opt untangling plus rare pinned-fold arc reseeding fix replayed crossings. Pinned reach now reserves segment count, not straight-line distance. Exact recovery feel needs human testing; no claim of graphics QA.

Cooler request is interaction design, not art. Pressure/release and lever feedback goals accepted; exact new puzzle still proposed. Back cancels unfinished mounting rather than bypassing the physical lever. Preserve existing grading/completion gates.

## Historical update 0.18.0 — trapped threads, clamp, reach and mount put-down

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026. User reports 0.17.1 pickup/removal working.

Trapped dust now exposes partial chains with a count; precise suction slowly extracts real hidden mass. Three representative chains per housing keep the view readable; specks use shorter tails after chains are removed. Disassembly remains easier; risky pick is unchanged. Normal tools cannot clean through the housing center.

Clamp supports left/right drag and stationary left-click unclip. Replacement-stock button no longer overlaps it. Entire footprint stays outside PC/bin; occupied hose reach still applies. Standard hose is shortened to 560 px, upgrade 760 px (provisional), with rotated-nozzle corner reach verified on both case profiles. Existing upgrade ownership is retained.

Recording diagnosis: right-button handling was blocked by mount.active, so tools could not be put down until the lever ended mounting; paste also inherited the cleaning mode's parts restriction. Mounting now parks tools and permits right-drag put-down throughout the lever-wait phase. This neither locks the cooler nor bypasses good-result completion. New regression/CI suite: test_bench_feedback.gd.

Cooler visual ideas are discussion proposals only (DESIGN_PROPOSALS section 6). Keep D52/D57 and existing pressure rules until an explicit redesign is selected. See latest changelog for target-engine results; no human graphical acceptance of 0.18.0 claimed.

## Historical update 0.17.1 — recording-led input bug fix

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.

The user's recording narrowed the stall to putting down and picking up tools. Reproduced on active 0.17.0: the resting-tool pickup branch returned with holding=false, so the entire held-left movement did no work until release/reclick. This explains why a freshly auto-equipped vacuum could work while later pickup appeared broken. The pickup branch now preserves the held press, including paste tools picked up from the rack.

Second confirmed fault: in Move parts mode the resting-tool hit test ran before component dragging. A parked vacuum/brush over the GPU/cooler intercepted the click, selected a tool and prevented removal. Parts-mode press/release now takes priority. Both components are tested through removal, actual under-dust vacuuming and refit.

New regression: 7 of 11 failures before the fix; expanded post-fix checks and target-engine results in CHANGELOG. This is a reproduced input cause, superseding earlier root-cause uncertainty for this recorded path. Historical 0.17.0 notes remain correct about what was known then. No dust-physics/tuning/save-format change. User visual acceptance of this patch is still needed.

## Historical update 0.17.0 — dust restoration/travel and movable clamp

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026.

Read DEVELOPMENT's 0.17.0 contract and newest changelog before editing. Initial, reopened, New dirty PC and legacy reset use shared initialization. Physical dust saves preserve looseness, locations and traps; old fraction-only saves migrate without erasing progress. Light brush contact now loosens visibly. Top-surface access is explicit, and vacuum can collect already-moving dust immediately. A switched-off vacuum cannot delete loose dirt on a timer.

Fast brushing scatters dust across the case; installed GPU/cooler catch it underneath, filter catches it with stronger grip. Area mass/progress transfers; case total never counts movement as removal. Case interior is a ninth zero-spawn area; initial particle count is unchanged. Dirty areas can become dirty again. Service-tray surface dirt stays on extracted components. Fan-driven redistribution remains queued, not implemented by this task.

Right-drag the clamp around the desk; whole footprint is kept outside PC/bin and within desk, with occupied-hose reach respected. Left-click with empty hands unclips; Shift-right-drag hose pickup is unchanged. Fixture position is session-local.

Root-cause boundary: the original first-entry stall was not reproduced on a controlled fresh 0.16.0 ticket (fresh and New dirty PC gave equal suction). Tests now exercise first entry, saved reopen, legacy saved progress, New dirty PC and reset through actual bench input, including brush response. Fixes address lost physical state, light-contact feedback and access/suction behaviour; do not claim a user-save-specific root cause was established without that save. See checks in CHANGELOG; human acceptance remains needed.

## Historical update 0.16.0 — start screen and hose

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 13 November 2026. The user identified the model as GPT 6.1 Sol; use this signature going forward. Earlier truthful unavailable-id notes remain historical. The user authorises merging all open PRs and reports testing the other AI's work. Only #10 was open at inventory; it is now merged. Older PRs were already merged.

F5 opens `start.tscn`: New game starts the existing shop demo; Load resumes saved state (disabled if no readable save); Achievements explicitly says unavailable. Existing saves are replaced only after confirmation. Startup without a save initialises memory without writing a new save. Shop's Main menu saves first. No save-format change.

Hose collisions use full square cooler/GPU housings (including link/corner checks); tools and hand-carried parts pass above the hose. Right-drag of a held tool takes priority. Shift + right-drag explicitly grabs the hose; right-drag also works with empty hands. Drop it in the visible desk clamp; empty-hand click or re-grab releases. Clamp arrangement is session-local and does not change upgrades/bin/paste/economy rules. Geometry/placement and hover are trial UI tuning.

Checks: target Godot 4.7.2 headless schema, regression and start-screen suites; see newest changelog for results. No interactive graphical acceptance is claimed: no display server was available for the attempted native launch. User playtest remains the next step.

## Documentation update 0.15.2 — read before historical notes

Signed: Codex (GPT-6, model id not exposed by this session) in ChatGPT Work, 13 November 2026. Exact deployment id is not exposed; this does not satisfy D51's exact-id requirement and must not be disguised with an invented id.

Gameplay is unchanged from 0.15.1. Accepted: A/B/D/E/F/G/H; excluded: C. Read DESIGN sections 19–20, DECISIONS D58–D60, MINIGAME_RULES and SCAM_DESIGN_PROPOSAL. Promises must be visible; actual work, agreement, claim and functional result must remain distinct. Detailed UI/balance/remedies are proposals. Do not claim those rules are coded.

Next: human-test 0.15.1, then scope persistent agreements, cleaning/claim separation and one archived toothpaste comeback. Preserve vacuum-only removal, physical lever, customer ownership and persona-based discovery. No evidence system. Python checker run for docs hygiene; no new Godot run. Branch `design/scam-direction`, PR only, do not merge. Historical notes below are superseded where inconsistent.

## 1. Historical foundation features (see current update below)
- Shop screen with one repair ticket, cash and save/load (`user://nightshift_save.json`).
- Repair bench: vacuum dust bundles out of six parts of a PC; squeeze thermal paste, wipe with a cloth,
  mount the cooler in a timed pressure minigame.
- Hardware bench: drag RAM onto a shaped (L-shaped) motherboard grid, with rotation and hover cards.
- Square cloth upgrade, final check (temperature from dust and paste), 95% rule per part.
- Checker: `python3 -I tools/check_project.py` (hygiene only; it does not run Godot).

Where things are: `DEVELOPMENT.md` section 5 (file map) and section 6 (data contracts).

## 2. What is NOT built (and must not be built unless the user asks)
Everything in `docs/DESIGN_PROPOSALS.md`: night hub and time limit, ticket board, Go out locations, real
Shop, grid inventory, general case assembly, parts catalogue, mount-minigame redesign. Independent specks and two service-removable parts are now implemented in 0.9.0.
The user said they will work on the parts catalogue themselves first. Do not start it.

## 3. Rules for every bot
1. **Read before writing:** `HANDOFF.md`, `DEVELOPMENT.md`, newest `CHANGELOG.md` entry, then the scripts.
2. **Keep the layers:** data, rules, sim, state, view (`DEVELOPMENT.md` section 4). Lower layers never draw
   or read input. Do not put physics or rules in a view.
3. **Honesty:** never describe code as tested unless it ran in Godot 4.7.2. If you could not run Godot,
   say so in the changelog entry. List only checks you actually performed, with results.
4. **Mark proposals:** anything the user has not approved, including every number, is a proposal.
5. **No real brand names or logos** in game data. Brands are parodies.
6. **Do not rewrite old changelog entries.** Add a dated "Correction" note inside them instead.
7. **One number per delivery.** Never ship a different build under a version already delivered.
8. **Small, readable changes.** The owner is a beginner; keep structure simple and explain in plain words.
9. **Do not touch the user's design decisions** (D01 to D33 in the handoff documents). Ask when unsure.
10. **Beginner-friendly files:** deliver a ZIP named `nightshift_godot_trial_vX.Y.Z.zip` whose folder is
    `nightshift_godot_trial`, with `project.godot` inside and F5 running the main scene.

## 4. How to update the changelog (every bot, every change)
1. Decide the version bump (`DEVELOPMENT.md` section 1): MINOR for a new player-visible feature, screen or
   data contract; PATCH for fixes, tuning, docs, tooling. MAJOR stays 0 until the user says otherwise.
2. Set `config/version` in `project.godot` to the new number.
3. Copy the entry template from the top of `CHANGELOG.md` and paste it as the **first** entry below
   "Unreleased", with the heading `## X.Y.Z - YYYY-MM-DD - short title`. Keep every required heading:
   Execution status, Added/Changed/Fixed/Removed, Files changed, Checks performed, Decisions proposed
   (not approved), Known issues and open items, Next action.
4. Fill in **Author** and **Based on** (previous version). **An AI must sign with its model:** name, model
   name and exact model id, and where it ran, e.g. `Claude (Opus 5.5, model id claude-opus-5-5) in a chat
   session`. Sign the same way when you update this file's **Signed** line and in your commit messages.
   If the model changed during your work, name every model that made edits. A person writes `(human)`.
5. In **Files changed** list every file added (A), modified (M), deleted (D) or renamed (R), docs included.
6. In **Execution status** say plainly whether Godot was run, by whom, on which version.
7. In **Checks performed** write only what you actually ran. Put the text `CHECKS_PLACEHOLDER` there while
   working; the checker fails until you replace it with real results.
8. Update the first line of `README.md` to `(vX.Y.Z)`, plus any instructions that changed.
9. Update `DEVELOPMENT.md` sections 5 and 6 if files or contracts changed, in the same version.
10. If the version found or fixed any bug, add or update its row in `docs/BUGS.md` (AGENTS.md rule 6);
    at every 10th version (0.30.0, 0.40.0, ...) run that file's structural review first.
11. Run `python3 -I tools/check_project.py` from the project folder and fix every FAIL.
11. Build the ZIP with the new number, check a fresh extract with the checker, and report to the user
    what was run and what was not.

If you work in parallel on a branch, put notes under "Unreleased" instead and let the integrating
contributor assign the number (`DEVELOPMENT.md` section 1).

## 5. Historical next-task list (superseded by STABILISATION.md)
1. Parts catalogue: the user is working on this; wait for their data and format.
2. Night hub with a time limit, ticket board with carry-over tickets, real Shop screen
   (`docs/DESIGN_PROPOSALS.md` section 1).
3. Mount-minigame redesign with matching squares, and loose dust specks (section 4 of that file).
4. Grid stash, then case grid with the height number (section 2 of that file).
5. Rename `scenes/main.tscn` to `hardware_bench.tscn` (a small, separate PATCH).

## 6. First thing to do on a machine with Godot 4.7.2
Open the project, press F5, click through the shop, both benches and the final check, and report any red
error text with file and line. Target-editor interactive behaviour remains unverified until that is done. In particular untested:
the 0.7.0 dust/vacuum rewrite and the timed mount minigame, which were only checked as Python models.


## 0.7.2 integrator update — Codex, 12 November 2026
The user's current task supersedes the historical next-task order above: reconcile notes, update/include the five core documents, then stabilise existing features before adding systems. Gameplay is unchanged. All five core files now live in docs/ at document version 1.2. Read them; do not rely on a separate stale pack.
Authority: latest explicit user instruction, then docs/DECISIONS.md and docs/DESIGN.md for scope; CURRENT_STATE.md for implemented facts; DEVELOPMENT.md for code contracts. Local DESIGN_PROPOSALS.md retains proposals and newer agreements but cannot reopen settled daytime/clock rules. If a genuine conflict remains, report it before implementing that decision.
Current sequence: documentation baseline; target-editor playtest; bounded save/progress fixes; proposed behaviour-preserving split of bench_view.gd; then shared PC state. Full inventory/hub/catalogue expansion is not part of this patch. Include all five core documents in every future project ZIP and refresh them whenever accepted scope or state changes.


## 0.8.0 historical handoff — Codex, 12 November 2026
Authorised user fixes implemented: shared case/board cell layout, tower/compact previews, on-board cooler/RAM/GPU cleaning geometry, faster 36-bundle cleaning, explicit syringe selection/reset on paste-stage activation, exact dust reload accounting and stale-grade invalidation. PC drawing extracted from bench_view.gd to pc_renderer.gd. Original target remains 4.7.2; actual checks run with 4.6.3. tools/test_regressions.gd passes 71 checks; GUI fresh dust, tool switching, RAM snap and profile previews observed. Payment tested by isolated state/save regression, not full human repair completion.
The user-reported absent dust was not reproduced on a fresh PC; a saved cleaned PC legitimately has no dust. Preserve saved progress, show the clean-resume message, and use New game for a genuinely new ticket. Do not automatically re-dirty a completed customer's machine to mask this distinction.
All five core documents updated to v1.3 and bundled. Read their CURRENT_STATE and STABILISATION sections; prior open-task lists are historical. Keep reviewing code; next gaps include general persistent PC state, actual case assembly, save validation/atomicity and remaining view/controller extraction. Do not start catalogue generation; user owns catalogue design. Every future ZIP includes the five docs and check logs.


## 0.9.0 historical handoff — Codex, 12 November 2026
User requested restrained base suction, independent specks, component-blocked access with physical removal, no duplicate syringe control and smoothness review. Broader physics redesign explicitly deferred. GPU/cooler move to tray and back; underneath dust is protected while installed, surface dust follows the part. Final check requires refitting. Removing cooler invalidates paste; mounting it refits. Removal state saves; old fully cleaned saves migrate without adding hidden dirt. Only these two parts are service-removable, not a full inventory implementation.
Current tuning: 51 bundles/34 specks, pull4/range50/ramp0.2. 96 regressions passed in Godot4.6.3 plus GUI GPU removal/exposure/refit observed. Target4.7.2 not run, full human payment session not run. No FPS/performance gain claim; cached blocker geometry and event-position drag fix address identified work/input issues. tools/test_regressions.gd contains reproducible tests.
All five core docs are version1.4 and bundled. Read their newest sections rather than stale historical summaries above. Next user tests pace/challenge, then discusses future physics representation. Do not add vacuum upgrades, a catalogue or a general hub without a task. Log every file change and preserve prior delivered ZIPs.


## 0.10.0 historical handoff — Codex, 12 November2026
Current explicit user task added risky pick and similar/inferior substitution. Key4 inspects cooler/GPU trapped dust and attempts extraction with per-stroke risk. Damage saved and final-check gated. Replacements panel permits equivalent/budget purchase only after damaged part removal; purchasing auto-fits and saves tier. Budget cooler affects thermal result; GPU specification metadata awaits future benchmark. No full stock, catalogue, detection/reputation or disclosure mechanics. All five core docs are1.5. New scripts dust_pick.gd and service_parts.gd keep rules/data out of view; simulation has controlled extraction API. Read newest CHANGELOG entry for actual checks. Broader physics redesign remains deferred; user playtests risk/reward now. Keep original safe access path and established once-only payout. Do not interpret an inferior part passing functional check as an instruction to auto-refund or erase the downgrade.

The same unreleased0.10.0 delivery also implements the user's follow-up request for forgiving hardware inventory handling. GridInventory handles three sample pieces, footprints, free storage, slot installation and serialisation. PartMotion handles presentation-only damped following/lift/sway/rotation. job.hardware_trial stores separate snapshots for tower/compact; this sandbox is not connected to repair-PC stock. Unsupported drops restore previous placement with a nonmodal hint; ordinary drawer drops never invoke socket rules. Latest regression count246; read final changelog. Do not claim real collision/throw physics or reuse reference assets.


## Historical 0.11.0 handoff — Codex,12 November2026
Latest authorised scope: shared tabletop throw/bounce and tactile repair-tool handling, dynamic brush, visible fresh-ticket dust, player inventory connected to replacement fitting. See docs1.6 newest sections; historical sandbox-only/no-throw notes are superseded. Added TableBody,BrushShape,ToolRig and ToolRenderer, linked GridInventory to GameState player stock. Buy stock and Fit owned stock are separate transactions; no second charge. Cooler/GPU removal, protected dust and pick risks remain. Resting service poses save; flight/tool positions do not. Hardware throws safely settle before scene exit. New dirty PC keeps economy but replaces practice work, with ticket-id save guard. Fresh dust failure not reproduced; no auto-re-dirty on opening.325 regressions in Godot4.6.3; actual final checks logged. Target4.7.2/full human payment still pending. No supplier/catalogue/reputation or3D/body-body collision expansion was made. Keep five docs, logs and source versions in future ZIPs.
