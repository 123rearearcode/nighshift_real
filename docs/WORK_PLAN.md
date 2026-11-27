# Work plan — code health and responsibilities (from 0.19.1)

## Current bounded assignment — 0.58.0, 27 November 2026

The user authorized the reviewed antivirus direction, with very simple clues for nontechnical players, then asked for Claude's new PRs to be reviewed first. Codex owns antivirus rules/panel/effects, monitor launch, shared Settings in title/pause, and only the app-preference portion of GameState for this feature. No PC ownership, save migration, bench or tool-rig rewrite. Reviewed #87/#88 on a8667b7; B63 is recorded, both remain unmerged by this task. Base is merged main dfbf5aa. Per-part work stays 0.59.0 and scheduled checker 0.60.0.

Signed: Codex (GPT-6; model id not exposed by this session), ChatGPT Work.

## Current bounded assignment — 0.57.5, 25 November 2026

The user reviewed Batch A v2, authorized installation, and requested Claude's art PR be merged first.
#79 is now merged at 87dd2b6. Codex owns the bounded counter/Hotspot/storage-presentation integration
in a new PR, including source approvals/credits, coordinates and affected native-input checks. No
GameState/bench/tool-rig ownership is claimed. Keep #77/#78 and deferred 0.58.0/0.59.0/checker 0.60.0
scope unchanged. Read current HANDOFF and ART_PRODUCTION_PROGRESS before continuing.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Permanent art coordination — 0.57.2, 23 November 2026

User rule: NO artwork enters gameplay without prior human approval of the exact revision/use. Agents
read ART_PRODUCTION_PROGRESS first, follow its active creation list and record creator/edit history and
human approvals in ART_ASSET_LOG. First-day list remains current until creation completes; Codex or the
assigned coordinator then migrates live agent references and remaining work to the permanent queue,
reminds the user and eventually removes the obsolete file under documented retirement conditions.
This docs task creates/installs no art and reserves no runtime hot files. Prior #73/#74/#75 are merged;
pending gameplay slots and scheduled checker role remain unchanged. Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Current first-day assignment — 0.57.0, 23 November 2026

After pushing creator/checklist tracking to #74 (0.56.3), the user assigned Codex the bounded first-day
customer opening in a separate PR. Codex owns GameState/NightSession/counter/title/resume for this
patch; do not overlap those hot files. Existing two repair jobs are introduced without duplicating PCs,
charging time or paying. New pending-ID queue is compatible optional save data; existing saves skip it.
Version reservations move: opening 0.57.0, anti-virus effects 0.58.0, per-part tests 0.59.0. Earlier
numbered briefs remain historical, their gameplay requirements remain pending. Art task/status/credits
are retained. Main/branch integration and current instructions: HANDOFF. Checker marker 0.60.0 unchanged.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Art coordination — 0.56.2, 23 November 2026

The user will assign asset creation to Claude/Gemini using ART_DIRECTION.md and FIRST_DAY_ART_CHECKLIST.
Read those first; work in bounded ART IDs/draft folders with one common layout/anchor/pixel contract.
Environment/layout and character/prop packets are suggestions for assignment, not work already started.
This docs-only task launches no agents and reserves no runtime hot files. Separate any layered-screen/
hover-storage implementation from asset delivery, preserve the existing 20 x 10 shared storage model,
and coordinate with pending Codex 0.57.0/0.58.0 before overlapping files. Checker PR #73 is untouched.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Current integration — 0.54.1, 21 November 2026

User-authorized merges #64–#67 are complete. PR #19 is being resolved as historical proposal archival,
not a new implementation assignment. Current main/runtime contracts supersede its old baseline and
phase ownership. Codex's bounded delivery patch and this documentation integration are complete;
no runtime hot file remains reserved by this task. Claude resumes Rooms/art/playtesting from the
current main after reading HANDOFF's 0.54.1 resume prompt. Coordinate ownership for the next edit;
retain the standing split, all lifecycle tests, deferred features and the 0.60.0 structural review.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Current bounded audit follow-up — 0.54.0, 21 November 2026

The user assigned Codex the delivery-condition/identity correction and ledger split. Codex owns the
affected GameState/CustomerPC/PcBuild/receipt files for this patch, stacked on #66 head f61583c rather
than a competing main-based rewrite. Cross-review/integrate #64 -> #65 -> #66 -> this follow-up under
the user's merge direction, preserving every suite including Delivered parts. Claude then resumes
the current Rooms/art/playtest work. The full legacy-original identity migration and orphan recovery
remain L1/L2; clock integration L4 and drawer visibility L5 are separate future tasks. No new clock or
UI flow is invented. HANDOFF's current section supersedes older ownership and resume claims below.

Written 2026-11-13 by Claude (Opus 5.5, model id claude-opus-5-5); approved by the user the same day
("go ahead"). Combines Claude's code health review and Codex's improvement list. Each step is one version,
one pull request, all checks green before merging. A step that should not change behaviour must leave
the scripted playtest tables (`tools/playtest_bench.gd`) identical.

## Who does what (user decision, 2026-11-13)
**Codex — game design and gameplay features:** design documents and decisions (scams, customers, the
dust minigame purpose, the PC/owned-part model design), new gameplay features and their tests, feel
tuning from the user's playtests.
**Code checker — reviews (user decision, 2026-11-21):** a scheduled Claude session reviews every change
(6-hourly), runs the every-10-versions structural bug review and a performance review every 2 days. It
reports and files bugs; it does not edit game code or merge. See `docs/CODE_CHECKER.md`.
**Claude — engineering and code health:** steps 1–15 and 17 below; the build half of step 16 on top of
Codex's design; investigating unclear bugs with the scripted playtest.

18 November 2026 current assignment: the user authorized Codex's bug-audit follow-up (0.47.1):
reconcile BUGS, enforce its schema/evidence rules, add complete cross-PC lifecycle coverage, and
document staged component identity/custody work. Claude's open #59 owns shared runtime/generator work;
this follow-up does not edit those hot files. HANDOFF and PART_LIFECYCLE describe integration and the
still-open L1/L2 scope. Preserve ALL workflow suite/check entries when reconciling the two branches.

## Rules so the two agents do not collide
1. **One owner per hot file at a time.** Hot files: `scripts/view/bench_view.gd`, `scripts/bench/tool_rig.gd`,
   `scripts/state/game_state.gd`. During Phases 2 and 4 Claude owns them; Codex works in other files or
   waits. Outside those phases, the agent assigned the task owns them for that version.
2. **One open pull request per hot file.** The next one starts from the updated `main`.
3. **Cross-review.** Each agent reads the other's pull request before it is merged and leaves a short
   comment. The user decides anything that changes game behaviour.
4. **Handoff line per version.** Each changelog entry's "Next action" names who goes next and which hot
   files are free.
5. **Design before code.** New mechanics start as a Codex proposal; the user approves; the file owner builds.
6. **Unchanged:** sign with your model (D51), bump the version, follow the changelog template, keep
   `archive/vX.Y.Z` branches, never claim untested work was tested.

## Diagnosis work split — 18 November 2026 (D150)

Current bounded exception: after reviewing PR #57, the user assigned Codex to fix its four findings
and push all changes. Codex owns the affected runtime/test files for that 0.46.3 follow-up on the
existing PR. Claude resumes the standing split below after reviewing/integrating this patch under
the existing user-controlled merge process; do not race edits to those shared files. See HANDOFF.md.

The user requested separate Codex/Claude assignments while pushing the approved diagnosis design.
This scope refines the general division above for session 3.4; it does not claim either agent's
unpublished code is complete. Main was verified at 0.46.0; actual branch/file ownership is checked
before edits. Current detailed contract: REPAIR_LOOP_DESIGN.md section 5; resume prompt: HANDOFF.md.

| Owner | Deliverables | Boundaries |
| --- | --- | --- |
| Codex | Diagnosis specification, manual wording/content design, ambiguity/evidence acceptance criteria; cross-review patch and 3.4 | Own diagnosis design sections in this documentation pass. No simultaneous edits to runtime/hot files. Dedicated manual content file/format can be agreed next; no example-case pack now. |
| Claude | Audit merged and unpublished code; patch conflicting existing behaviour FIRST; then diagnosis runtime, standalone stress app, Findings, custody/clock/save integration, manual reader and regression tests | Own runtime files needed for 3.4, including shared hot files and hardware/monitor/state rules. Keep manual read-only with respect to PC state. Do not rewrite Codex's design sections concurrently. |

Parallel work: Codex can develop manual content/evidence specifications while Claude audits/patches.
Agree the manual content interface before Claude wires it. Codex reviews code against the approved
contract; Claude reports necessary design-contract clarifications in his PR for Codex to reconcile.
Each agent logs their own changes. Follow existing cross-review and user-controlled merge rules.

**Required order:** audit current branch -> separate compatibility patch if existing behaviour
conflicts -> Codex cross-review/integration under existing merge rules -> resume 3.4 from that
baseline -> feature cross-review. Preserve/rebase unpublished feature work. The patch excludes new
diagnosis/manual features and gets its own version/PR; no artificial patch is required if the audit
finds no delta. Check health leaks/refitting, temporary versus permanent ownership/costs, actual night
clock timestamps, stale measurements and hidden-installation pickup rules. New features that do not
exist yet belong in 3.4, not in a falsely labelled compatibility patch.

Assistance is an optional manual; story facts stay fixed. No customer follow-up dialogue, automatic
difficulty scaling, mentor or hidden-fault-based answer. Detailed visuals/example cases remain later.
This documentation pass does not begin runtime work, add a generator or supersede later talk-first gates.

Recorded by Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest.

## Phase 1 — Quick wins (no gameplay change) — Claude
1. **Shared test helper and simpler workflow.** `tools/test_support.gd` (check, summary line, temporary
   save path, bench loader); the 7 suites use it; the workflow runs them in one loop. Done when the same
   checks pass and each suite's summary line is still in the log.
2. **Frame-time measurement.** The playtest records physics-tick and redraw times for an idle bench,
   heavy brushing, vacuuming with a moving hose, and flowing paste (average and worst); never fails the
   build. Done when the table is in the log; the user compares once on their PC.
3. **Layout and ID constants.** `scripts/data/layout.gd` (table, PC area, socket, lever, bin, panel) and
   `scripts/data/ids.gd` (tools, stages, parts). No value changes. Done when no coordinate or id is
   duplicated across files and playtest tables are identical.
4. **Code-style checker in CI.** gdtoolkit `gdlint`, report-only first, blocking once the backlog is fixed.

## Phase 2 — Predictable interactions — Claude (hot files locked)
5. **Name every hand state (no behaviour change).** States: FREE, USING_TOOL, THROWING, CARRYING_HOSE,
   DRAGGING_PART, DRAGGING_CLAMP, MOUNTING, PANEL_OPEN, and the allowed moves. A read-only derived state is
   printed in the playtest. Safety net for step 6.
6. **Hand state machine.** `scripts/bench/hand_state.gd` (pure rules); the bench input asks it what a
   press/release means instead of checking ~10 flags. Done when click/pickup/throw tests and playtest tables
   are unchanged and the user confirms the feel by hand.
7. **Transition and failure tests.** Focus lost while holding, leaving mid-mount, tool switch while carrying
   the hose, dropping a part outside the tray, two buttons at once; add the missing focus and window-close
   handling.

## Phase 3 — Saves — Claude
8. **Close the save gaps.** On-screen message when a save fails; save on window close and when leaving
   mid-action; one small migration function per format change (`save_format` 2 when first needed); tests
   for damaged, missing, failed and every recent old save shape.

## Phase 4 — Break up the bench — Claude (hot files locked)
Before step 9: a small public bench test API (click at, press lever, pick tool) and tests moved onto it.
9. Input routing on top of the hand state.
10. One controller script per tool (vacuum, brush, pick, syringe, cloth).
11. Interface building.
12. Replacement panel.
Done when `bench_view.gd` is under about 500 lines and only coordinates.
13. **Break up long functions** (hose step, dust setup, save loading); the hose gets the Python check again.

## Phase 5 — Ready to grow
14. Reusable layout controls, structure only (no visual polish; still deferred) — Claude.
15. Typed job record (`JobState` with explicit save conversion) — Claude.
16. Shared PC and owned-part model, when multiple PCs come — design: Codex; build: Claude.
17. Exported-build checks before release preparation — Claude.

## Features during this plan
Codex may continue features during Phase 1 and Phase 3 (outside hot files when Claude holds them). During
Phases 2 and 4, features must not touch `bench_view.gd`, `tool_rig.gd` or `game_state.gd`; after step 10,
features land in the per-tool scripts.

## Wave 3 — closing the repair loop (user approved the plan, 16 November 2026)
Current resume, 19 November 2026 (D157): generated tickets 3.5 are merged in #59 with #60's safeguards.
PR #61 adds the 0.48.1 requests. Codex's user-approved anti-virus detour is 0.49.0 stacked on #61;
after cross-review and user-controlled integration, Claude resumes **3.6 Testing bay, talk first**.
This consumes the old 0.49.0 reservation: later versions shift by one; the structural review stays
at 0.50.0 (now the bay release). Manual 3.4m remains deferred. See HANDOFF for exact resume order.

Design: docs/REPAIR_LOOP_DESIGN.md (D134 to D141). One session = one release the user can playtest.
Version 0.42.0 is taken by the parallel menu-navigation work (Codex, PR #46), so session 3.0 shipped as 0.41.2.
Session 3.3 was split in two on 17 November 2026 (D148): the hardware model (0.45.0) and the hardware bench
parts (3.3b, 0.46.0); later sessions moved up one version.
Sessions marked "talk first" need a short design conversation with the user before coding.

| Session | Version | What the player gets | Talk first? | State |
| --- | --- | --- | --- | --- |
| 3.0 Bench clean-up | 0.41.2 | nothing visible: bench_view.gd split into helpers | no | done |
| 3.1 Tickets and pickup | 0.43.0 | tickets as records; right-click a PC: Ready for pickup (sticker) / Call customer | no | done |
| 3.2 Night end and morning report | 0.44.0 | 06:00 ends the night; one card per PC, hover for state; next night | yes: what surfaces at pickup vs later (answered: D146) | done (0.44.0) |
| 3.3 Real hardware | 0.45.0 | named parts with processing, graphics, RAM, storage, PSU, cooler; PSU/cooler as support stats; several GPUs | answered (D148) | done (0.45.0) |
| 3.3b Hardware bench parts | 0.46.0 | CPU, RAM, storage, PSU in and out at the hardware bench; a second PCIe slot; buy any catalogue part | no | done (0.46.0) |
| 3.4 Diagnosis | 0.47.0 | D150: complaint/evidence separation; Findings on real night clock; standalone stress app (Stress lab); owned temporary test parts; collection settlement (0.46.2/0.46.3) | core approved; detailed presentation/taxonomy still proposed | merged in PR #58 after #57; manual playtest still not recorded |
| 3.4m Diagnosis manual | later (unassigned version) | optional manual: explanations and graduated guidance, read-only, never reads hidden faults (D150) | yes: Codex's content format first | **deferred by the user on 18 November 2026** as a separate later point; not part of 0.47.0 |
| 3.5 Generated tickets | 0.48.0 | morning arrivals from rating and reputation; generated and returning customers; problems by night; each case proven solvable (buying a test part counts) and repairable | answered (D153) | merged in #59, including #60's safeguards; earlier cross-review notes remain in D154 |
| 0.48.1 user requests | 0.48.1 | motherboard as a PC part (remove everything first), GPU bracket screws (B49), vacuum and paste kept across screens (D155) | answered (D155) | built by Claude in open #61; predecessor of the detour |
| Anti-virus detour | 0.49.0 | approved standard Task Manajer in the monitor; native uppercase SEND/Enter, fixed rows, calm pacing | answered through in-chat demos (D157) | implemented by Codex; cross-review/user-controlled integration after #61 |
| 3.6 Testing bay | 0.50.0 | untested parts from salvage and customers; physical inspection and rig tests; degraded parts; the player's mark; scrap; required 0.50.0 structural review | answered (D158) | merged by the user in #63 (played: "all looks good so far") |
| 3.7 Build requests | 0.51.0 | budget, uses (needs) and wants (quiet, headroom, brand, storage); swappable cases; assemble at the hardware bench on the night clock; half up front, half on collection; from nights 4–5 | answered (D159) | built by Claude; awaiting Codex cross-review, the user's playtest (gate after 3.7) and merge |
| 3.8 Trust and reviews (was Elegance) | 0.52.0 | no elegance (D160); trustworthiness and the shop level (up with good work, down only when customers find out); star reviews with comments, some petty; the phone app with fake reviews | answered (D160) | built by Claude, stacked on #64; awaiting Codex cross-review and the user's merge |
| Rooms revamp (user request after Wave 3) | 0.53.0 | no menus: the counter is the main screen, doors to the workshop and outside, stations and close-ups, the morning's customers at the counter; art + replaceable hotspots | answered (D161) | built by Claude, stacked on #65; awaiting the user's playtest and merge |

Playtest gates proposed: after 3.2, 3.4 and 3.7. Later, not in Wave 3: personas and lore, the upsell, the
wrong self-diagnosis, upgrades.

## Status
| Step | State | Version |
| --- | --- | --- |
| Plan | approved | 0.19.1 |
| 1 Shared test helper, workflow loop | done | 0.19.2 |
| 2 Frame-time measurement | done (first numbers in CHANGELOG 0.19.3) | 0.19.3 |
| 3 Layout and ID constants | done | 0.19.4 |
| 4 gdlint in CI (report-only) | done (backlog count in CHANGELOG 0.19.5) | 0.19.5 |
| 5 Hand states named and shown | done | 0.19.6 |
| 6 Hand state machine | done | 0.19.7 |
| 7–17 | not started (Wave 3 3.0 did the bench split of steps 11–12 and part of 9; see Wave 3) | — |
