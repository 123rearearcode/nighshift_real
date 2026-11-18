# Handoff — current state first

## Current — 0.48.0 integration: PR #60 (0.47.1) reconciled into PR #59, 18 November 2026

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

### Remaining Wave 3 work (planned, not implemented by this correction)

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
