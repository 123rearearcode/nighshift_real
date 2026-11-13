# Changelog

Every change to this project is recorded here, newest first. Rules, the version scheme and
the release checklist are in `DEVELOPMENT.md`. Versions follow `MAJOR.MINOR.PATCH`; the source
of truth for the current version is `config/version` in `project.godot`.

**Entry template** (copy for each new version; keep these headings, `tools/check_project.py` checks them):

```
## X.Y.Z - YYYY-MM-DD - short title
- Author: who made the change. A person: name and "(human)". An AI: name, model name and exact model id, and where it ran, e.g. "Claude (Opus 5.5, model id claude-opus-5-5) in a chat session". The checker fails without it.
- Based on: previous version
- Type: major / minor / patch (and why)

### Execution status
Was Godot actually run? By whom? Say so plainly. Never imply untested code was tested.

### Added / Changed / Fixed / Removed
What changed, from a player's point of view and a developer's.

### Files changed
| File | Change | What |
Every file added (A), modified (M), deleted (D) or renamed (R), docs included.

### Checks performed
Only checks that were actually run, with their results.

### Decisions proposed (not approved)
Anything the user has not yet accepted. Numbers are proposals unless stated.

### Known issues and open items
### Next action
```

Contributors working in parallel add their notes under **Unreleased** on their own branch;
the integrating contributor turns them into a numbered entry at merge time.

## Unreleased

(nothing yet)

## 0.22.1 - 2026-11-13 - Reduce idle bench work and add a quick CPU profiler
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.22.0, main 9d9be8ec868ae1f02bfdf1c5e38b292309df257e.
- Type: patch — performance/tooling only; no intended gameplay, balance or save-format change.

### Execution status
Codex ran Godot 4.7.2.stable.official.ed1daf0bf locally, headless. All eight required suites passed
(854 checks, zero failures). No interactive graphics/feel acceptance is claimed. Full baseline/changed
scripted comparisons and a separate sequential quick profile were run; details below and in PERFORMANCE.md.
GitHub Actions is not claimed here; inspect the PR checks for its independent result.

### Added / Changed / Fixed / Removed
- Settled clamped hoses can sleep; nozzle/pin/anchor/length/obstacle changes wake them. Small nozzle
  movements accumulate while asleep. Existing rope iterations, recovery, tug, spool and attachment stay intact.
- Idle stuck dust skips unnecessary tool-distance/access queries. Residual pull decay, airborne dust,
  hose flow, fans and saving continue. The existing stationary component-transform guard was already sufficient.
- Paste measurements and texture uploads cache unchanged state, with material/overlay/identity invalidation;
  bin and paste controls skip redundant updates. Stage entry resets the paste UI key.
- Static background/case/grid/tray drawing moved to its own CanvasItem; animated drawing remains in the bench.
- Added correctness tests and an optional short CPU profiler (mean, p50/p95/p99/max). Safe save writing is
  unchanged: dirty-PC saves measured about 2.3 ms mean / 4.0 ms p99 here; no asynchronous-save rewrite justified.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/hose_sim.gd` | M | clamped idle sleep, complete constraint wake key, diagnostic counters |
| `scripts/bench/dust_sim.gd` | M | skip inactive tool-distance/access work on stuck dust |
| `scripts/bench/paste_sim.gd` | M | revision invalidation and isolated cached measurements |
| `scripts/view/bench_view.gd` | M | narrow static-layer and cached-control integration |
| `scripts/view/bench_backdrop.gd` | A | retained static background, tray and PC drawing |
| `scripts/view/pc_renderer.gd` | M | reusable static PC draw and compatible optional dynamic-only path |
| `scripts/view/paste_renderer.gd` | M | texture-local revision/material/overlay cache |
| `tools/test_performance.gd` | A | 24 correctness checks, no host timing thresholds |
| `tools/profile_bench.gd` | A | short isolated CPU/draw/full-save percentile profile |
| `.github/workflows/tests.yml` | M | eighth required suite and optional manual quick profile |
| `docs/PERFORMANCE.md` | A | measured comparison, cache/wake contracts, limitations and handoff |
| `docs/TESTING.md` | M | eight-suite policy, profiler instructions, clarify fixed pending cases |
| `docs/CURRENT_STATE.md` | M | scoped engineering progress note |
| `DEVELOPMENT.md` | M | file map and cache/static-layer contracts |
| `HANDOFF.md` | M | version, signature, scoped ownership exception and review handoff |
| `README.md` | M | version heading |
| `project.godot` | M | version metadata |
| `CHANGELOG.md` | M | this signed delivery entry |

### Checks performed
Godot target-engine suites: data schema 182, regression 506, start screen 10, dust flow 43, bench
interaction 26, bench feedback 27, audio and vacuum 36, performance contracts 24: all passed, zero failures.
The new suite initially exposed mistakes in its fixtures (pin arguments, CPU deposit coordinates and
bin capacity name); these were corrected before the passing run. Existing suites passed on the first run.
Python CI-scope integration tests: 9 passed. Workflow YAML parsed. git diff --check passed.
Project hygiene: PASSED, zero problems. Fresh source ZIP extracted and checked: PASSED, zero problems; all five core documents included.
All 311 non-timing PLAYTEST rows match untouched 0.22.0 exactly; both full runs completed without script
errors. Same-host sequential profiler: clamped idle cleaning mean 3.264 -> 0.300 ms (~91% less work);
idle clean CPU drawing 1.267 -> 0.926 ms. Detailed percentiles and limits: docs/PERFORMANCE.md.

### Decisions proposed (not approved)
None. No new mechanic or balance number. Timings are observations on this host, not a player FPS target.

### Known issues and open items
Headless CPU timings exclude GPU/display latency. Small save samples and container storage cannot
predict every player's disk spikes; repeat profiling as inventory grows. Active paste spreading remains
broadly unchanged. Human check of static layering, tool feel, spool and clamp still required.
This is the user's explicit performance pass during Claude's Phase 2 ownership: only narrow bench_view
integration edits; tool_rig.gd, game_state.gd, hand-state rules and WORK_PLAN.md are untouched.

### Next action
Claude cross-reviews this PR before Phase 2 step 7; user playtests, then decides integration. Do not merge
automatically. Preserve cache invalidation/static redraw contracts during the view split. Who goes next:
Claude. Hot files free: none (Claude retains Phase 2 ownership; this PR reserves bench_view integration
until reviewed/integrated).

## 0.22.0 - 2026-11-14 - Hose attached for good, spool reels the vacuum in, PC power button
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.21.0
- Type: minor (interaction changes and a new control). From the user's playtest video of 0.21.0. Hot files edited by Claude (Phase 2 owner).

### Execution status
**Godot was NOT run by me directly.** Diagnosed from the user's screen recording (the detached hose end is visible, pinned short at the clamp while the vacuum rests 150 px away). GitHub Actions runs everything on Godot 4.7.2 headless; results below. Not hand-tested.

Actions result (Godot 4.7.2 headless, run 43517063316, branch feature/0.22.0): checker passed; all suites green (data schema 182, regression 506, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures; pending defects 0). Two earlier runs failed and taught something: the first hard-attachment attempt broke Codex`s zero-self-crossing hose replays (the simulation now stays untouched and the renderer bridges the end instead), and the reel-in tidiness check needed settle frames.

### Added / Changed / Fixed / Removed
- Fixed (D83), two halves: `_apply_hose_tug` now understands a pinned hose: past a clip or a gripping hand only the REMAINING segments count, so a hose clipped near its nozzle drags the vacuum onto a short leash instead of letting the end dangle 150 px away (the video's case); the length correction is capped at 24 px per step (no teleports). And the DRAWN hose always ends on the vacuum: the few pixels the simulation lags are bridged in the renderer. (A first attempt made the attachment a hard constraint in the simulation; Codex's zero-self-crossing replay tests caught it tangling the hose, so the simulation keeps its untangling behaviour untouched.)
- Changed (D84): the spool now actually reels in: clicking it unclips the hose and drags the vacuum back to the spool, where it parks; the hose settles in a tidy lay. Picking the vacuum up (or grabbing the hose) stops the reel. A held vacuum is put down first.
- Added (D85): a PC power button on the case (top-right). Off: fan targets drop to 0 and the fan audio loop stops; the state is in `job.pc_powered` (saved, migrated). Nothing else reacts yet; noted for the fan mechanic.
- Investigated (D86): "items disappear on collision without space" did not reproduce: a new stress test hurls tools into the crowded tray corner 12 times and every tool stays on the table with the hose still attached. Part collision results are now clamped into the table too.
- Tests: hose end attached after a near-nozzle clip and far park; short-leash distance bound; spool reel full cycle, start-with-tool-in-hand, interrupt by taking the vacuum; power off/on with fan RPM decay and save/load; the 12-throw stress barrage.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/hose_sim.gd` | M | hard end attachment + relaxation |
| `scripts/bench/tool_rig.gd` | M | pinned-length tug, spool reel, interrupts |
| `scripts/view/bench_view.gd` | M | spool click starts the reel; power button; part clamp |
| `scripts/state/game_state.gd` | M | `pc_powered` + setter + migration |
| `scripts/data/layout.gd`, `scripts/view/cleaning_renderer.gd` | M | power button rect + drawing |
| `tools/test_regressions.gd` | M | new and updated checks |
| `docs/DECISIONS.md` (D83-D86), `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | docs, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Reel speed 520 px/s and the vacuum's parking spot by the spool; the power button's position and that it only affects fans for now; the 24 px per step tug cap.

### Known issues and open items
The disappearance report (D86) is unreproduced; needs the user's eyes again. Loose items still do not spawn.

### Next action
User playtest of 0.22.0 (clip the hose near the nozzle and park the vacuum far: it should be leashed, never detached; the spool reel; the power button). Then Claude: work plan step 7. Hot files stay with Claude.

## 0.21.0 - 2026-11-13 - GPU power requirement, rotatable clamp, hose always clips, 95% grade threshold, D57 restored
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.20.1 (Codex's test cleanup, merged after cross-review)
- Type: minor (new requirement mechanic and job fields). Hot files edited by Claude (Phase 2 owner).

### Execution status
**Godot was NOT run by me directly.** GitHub Actions runs everything on Godot 4.7.2 headless; results below. Not hand-tested.

Actions result (Godot 4.7.2 headless, run 43513412848, branch feature/0.21.0): checker passed; all suites green (data schema 182, regression 492 including the promoted and new checks, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures); the pending-defects lane reports 0 known defects. A first run failed 4 checks: the clamp refused to turn at its default spot (it sits so close to the table edge that a 15 degree turn poked 3 px out; turning now nudges it inward instead of refusing) and two of Codex`s 0.19-era tests enforced exactly the refusal the user reported as "the hose does not attach"; they now test the D80 rule (the nearest reachable section clips).

### Added / Changed / Fixed / Removed
- Added (D79): graphics power. `ServiceParts.option` gains `power` (similar 100, budget 65); the job gains `required_power` (trial: 60) with save migration; the final check reports "Graphics output is X; this PC needs at least Y" and fails when short (a broken GPU outputs 0). This is the first cut of the user's "PC needs to output at least as much" rule; naming is provisional. The hardware bench's status line now says it is the shop's own spare-parts bench and points to Replacement stock on the repair bench for the customer's parts (the user tried to fix the customer's GPU there; connecting the customer's PC to the hardware bench is open).
- Added (D80): the clamp turns while carried (wheel/Q/E route to it; a blocked turn is refused). Oriented hit box and drawing; `clamp_angle`, `clamp_hit`, `rotate_clamp`.
- Fixed (D80): dropping the hose on the clamp could refuse ("did not attach") when the grabbed section could not stay stretched there; now the nearest section that reaches is clipped instead.
- Changed (D81): wiping a graded CPU clears the result only below 95% of the graded paste (`job.paste_graded_units`, set at the lever; `KEEP_GRADE_ABOVE`). Tidying beside the CPU still never clears (0.20.0 rule).
- Changed (D82, restores D57): a stage switch mid-mount lifts the cooler off ungraded (`MountSession.cancel`, `_cancel_mount`) instead of securing it as it lies. Codex's cross-review was right that 0.19.7 violated D57.
- Fixed: a refused tool switch (e.g. while carrying the hose) no longer highlights the refused button (the keyboard handler left the radio on the wrong tool; Codex's pending-contract check caught it).
- Tests: Codex's three pending-contract checks promoted into the regression suite (now passing, stronger: remount after lift-off works, paste survives); the pending lane is an empty stub for future known defects. New checks: clamp turning/hit/park, near-bin hose drop clips a reachable section, bench-level clamp clip, grade kept at >= 95% and cleared below, dead GPU fails with the numbers, budget GPU passes 60 and fails 100, requirement survives save/load, schema covers `power`.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/state/game_state.gd` | M | power requirement, graded units, migrations |
| `scripts/bench/tool_rig.gd`, `scripts/view/tool_renderer.gd` | M | rotatable clamp, hose clip fallback |
| `scripts/bench/mount_session.gd`, `scripts/view/bench_view.gd` | M | cancel; stage-switch lift-off, highlight fix, 95% threshold |
| `scripts/data/service_parts.gd`, `tools/test_data_schemas.gd` | M | power field + schema |
| `scripts/view/workshop_view.gd` | M | spare-parts status line |
| `tools/test_regressions.gd`, `tools/test_pending_contracts.gd` | M | promoted + new checks; empty lane |
| `docs/DECISIONS.md` (D79-D82), `docs/HAND_STATES.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | docs, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Power numbers (100/65/60), clamp turn refusal rule, 95% threshold value.

### Known issues and open items
The customer's PC is still not openable on the hardware bench (D79 notes it). Loose items still do not spawn.

### Next action
User playtest of 0.21.0 (clamp turning, hose clipping, paste touch-ups, the GPU flow through Replacement stock). Then Claude: work plan step 7. Hot files stay with Claude.

## 0.20.1 - 2026-11-13 - Retain useful coverage and make expensive diagnostics selective
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.20.0, main 05fb996b375aff79ba94ea39abe44ba6b4834af0.
- Type: patch (user-authorised test/tooling cleanup; no gameplay or save change).

### Execution status
Codex ran the required suites in Godot 4.7.2.stable.official.ed1daf0bf headlessly, plus short diagnostics and a separate known-defect report. No human feel, graphical or GPU validation is claimed. No scripts/ production file, hot file or WORK_PLAN.md is edited. Claude retains Phase 2 engineering ownership.

### Added / Changed / Fixed / Removed
- Required coverage remains in all seven suites. Replaced the obsolete syringe-label search with actual action wiring; dust expectations derive from zone configuration/initial state instead of 85/70/7 tuning literals.
- Removed the historical vacuum-duration pass gate; --tuning retains it as a clearly labelled observation. Consolidated duplicated fresh/rack checks into their existing dedicated suites, retaining partial-progress reload and stale-scene ticket protection.
- Still simulates and observes all 47 pick pre-completion frames, but reports one assertion rather than 47. Counts decrease without discarding those observations.
- Removed assertions that endorse tab navigation as the securing lever. New test_pending_contracts.gd uses the correct no-auto-secure rule plus selection/actual-tool consistency; these existing runtime defects remain visible as a separate failing, non-blocking CI lane pending Claude's fix. No known bug is fixed or concealed as passing coverage.
- Full diagnostic matrix remains unchanged by default. --smoke selects representative brush, vacuum, click and paste cases, retaining reach and state tables; --tuning is optional. Full mode/frame measurements run for bench/data/geometry or diagnostic-driver changes and manual request; other runtime edits use smoke.
- Pure Markdown plus only a version bump runs project hygiene and scope integration tests, without downloading Godot or rerunning the game. Actual non-version project settings, deleted/renamed code, unknown history and manual runs are handled conservatively.
- Superseded push/PR runs on the same branch cancel rather than run duplicate in-progress work. CI no longer swallows a nonzero suite exit or stops on its display-only missing-summary grep: later suites still run and the job retains the failure. Style backlog stays non-blocking. Added test-policy documentation and map/handoff/version updates.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Test cleanup, diagnostic scheduling or signed release documentation |
| `CHANGELOG.md` | M | Signed release record and honest known-defect results |
| `DEVELOPMENT.md` | M | Test cleanup, diagnostic scheduling or signed release documentation |
| `HANDOFF.md` | M | Test cleanup, diagnostic scheduling or signed release documentation |
| `README.md` | M | Test cleanup, diagnostic scheduling or signed release documentation |
| `docs/TESTING.md` | A | Test cleanup, diagnostic scheduling or signed release documentation |
| `project.godot` | M | Test cleanup, diagnostic scheduling or signed release documentation |
| `tools/ci_scope.py` | A | CI scope selection and real temporary-Git fixtures |
| `tools/playtest_bench.gd` | M | Test cleanup, diagnostic scheduling or signed release documentation |
| `tools/test_ci_scope.py` | A | CI scope selection and real temporary-Git fixtures |
| `tools/test_pending_contracts.gd` | A | Test cleanup, diagnostic scheduling or signed release documentation |
| `tools/test_regressions.gd` | M | Test cleanup, diagnostic scheduling or signed release documentation |

### Checks performed
Godot 4.7.2: schema 182, regression 463, start 10, dust flow 43, interaction 26, feedback 27, audio/vacuum 36 — 787 required checks, zero failures. The 51-count reduction from 838 is 46 repeated pick assertions, one historical pace gate, two copied freshness/rack checks and two assertions blessing auto-secure/its follow-on; coverage and known defects are documented in TESTING.md. Short diagnostic completed with 66 PLAYTEST lines and no script errors; --smoke --tuning also completed and reported 22.93 simulated clear seconds without a pass threshold. Known-defect report: 6 checks, 3 failures reproducing the existing two tab bypasses and rejected-selection highlight; explicitly not a clean overall defect report. Nine real-Git CI scope tests passed. Workflow shell fixtures verified that a nonzero process with a passing summary and a missing summary both preserve failure while all seven suites are attempted; all-pass fixture succeeds. Workflow YAML parses. Project checker PASSED: 52 scripts, 195 resource references, 82 mapped files and five core docs. git diff --check passed. No production scripts differ from main.

### Decisions proposed (not approved)
No new game mechanics. The user authorised test selection/cleanup. Correct lever behaviour remains the existing D57 requirement. The temporary non-blocking defect lane must be promoted to required coverage once Claude fixes the runtime; it is not permanent permission to ignore those bugs.

### Known issues and open items
The known lever/highlight defects remain unfixed in production code, owned by Claude. Full diagnostic timings are machine-dependent; no measured speed-up is claimed. New CI conditions require validation on the actual branch. Claude cross-review/user acceptance required before merge; Codex will not merge.

### Next action
Claude cross-reviews the test/CI changes, fixes the bench defects and promotes pending-contract cases; user reviews the cleanup PR. Hot files bench_view.gd, tool_rig.gd and game_state.gd remain reserved to Claude throughout Phase 2; none is edited by this patch.

## 0.20.0 - 2026-11-13 - Spool, loose items and trash can, paste-wipe fix, parts-removal repro
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.7
- Type: minor (new bench furniture and a carrying system). From the user's 0.19.7 playtest. Hot files edited by Claude (Phase 2 owner).

### Execution status
**Godot was NOT run by me directly.** GitHub Actions runs everything on Godot 4.7.2 headless; results below. The user's "cannot remove components" report could NOT be reproduced: a new live-play test (keyboard 3, real clicks, physics stepped like play) removes and refits the cooler green. The report needs the user's exact steps; see Known issues.

Actions result (Godot 4.7.2 headless, run 43507545917, branch feature/0.20.0): checker passed; all suites green (data schema 182, regression 514 with 22 new checks, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures); PLAYTEST STATE includes the CARRYING_ITEM rows, no mismatches. A first run failed 3 of my new checks: two were test timing (the parked part eases to its spot for about a second before it can be clicked where it is drawn), one was test order (the cloth equips snapped to the cursor, so equipping it over the CPU wiped the CPU on the way out - which is also a live trap: carrying the cloth ACROSS the CPU with the button held wipes it; that is by design, only the overflow is now safe).

### Added / Changed / Fixed / Removed
- Fixed (D78, from the screenshot): wiping the squeezed-out paste BESIDE the CPU after pulling the lever cleared the mounted grade, so Complete repaste went dark. Now only wiping the CPU itself clears the result (`PasteSim.last_wipe_on_cpu`); tidying the overflow keeps the grade and the button.
- Added (D75): a hose spool beside the bin. Clicking it (empty hands or a held tool) unclips the hose from the clamp and re-lays it neatly from the bin to the nozzle. `ToolRig.rewind_hose`, `Layout.BENCH_SPOOL`, new cues `hose.rewind` and `item.trash`.
- Added (D76): loose items (`scripts/bench/bench_items.gd`): coin and screw kinds, picked up with EMPTY hands only (new hand state `CARRYING_ITEM`; a hand with a tool uses the tool — the user left this design choice to me), carried on the cursor, dropped anywhere on the table or onto the new trash can (`Layout.BENCH_TRASH`), which destroys them. Items are session-local and not saved. Nothing spawns them in normal play yet; random finds such as coins are the next gameplay step.
- Noted (D77): the menu screen already shows the version (Codex built it in 0.16.0); covered by a new test now.
- Added tests (regression suite): live cooler remove/refit through real input; overflow wipe keeps the result, CPU wipe clears it; spool re-lays and unclips; item pickup/carry/trash/drop rules and machine rows; version label on the menu. Playtest state table gains CARRYING_ITEM rows.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/bench_items.gd` | A | loose items |
| `scripts/bench/hand_state.gd`, `scripts/view/bench_view.gd` | M | CARRYING_ITEM, spool/trash/items wiring, wipe fix |
| `scripts/bench/paste_sim.gd`, `scripts/bench/tool_rig.gd` | M | last_wipe_on_cpu; rewind_hose |
| `scripts/view/cleaning_renderer.gd`, `scripts/data/layout.gd`, `scripts/data/audio_cues.gd` | M | spool/trash/item drawing, rects, cues |
| `tools/test_regressions.gd`, `tools/playtest_bench.gd` | M | tests, state rows |
| `docs/HAND_STATES.md`, `docs/DECISIONS.md` (D75-D78), `DEVELOPMENT.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | docs, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Spool and trash positions and looks; item kinds and sizes; items not saved; CARRYING_ITEM from empty hands only.

### Known issues and open items
- "Cannot remove components" is NOT fixed because it did not reproduce: the live test removes and refits the cooler. The user should say exactly what they click (Move parts button or key 3?), at which stage, and what happens (nothing lifts? snaps back? the under-dust stays covered?). A stale save with `removed_parts` oddities is one suspect.
- Nothing spawns loose items yet.

### Next action
User: retry removing the cooler in 0.20.0 and describe the exact clicks if it still fails; playtest the spool, trash and paste fix. Claude: work plan step 7 after that. Hot files stay with Claude.

## 0.19.7 - 2026-11-13 - The hand-state machine is real
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.6
- Type: patch (interaction correctness). Work plan Phase 2 step 6. Hot files edited by Claude (owner during Phase 2).

### Execution status
**Godot was NOT run by me directly.** GitHub Actions ran everything on Godot 4.7.2 headless; results below. The ordinary flows are covered by the unchanged suites, the state table and the playtest tables; the FEEL of the bench needs the user's hands, and a user playtest of this version is the step's real acceptance test.

Actions result (Godot 4.7.2 headless, run 43501072475, branch feature/hand-machine): checker passed; all suites green with the new checks (data schema 182, regression 492 of which 31 are new hand-machine checks, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures); PLAYTEST STATE all rows match; brush/vacuum/reach/click/paste playtest tables identical to 0.19.4 line by line. Two earlier runs failed and were fixed: wrong preload names in the new tests plus the playtest hitting its 300 s step timeout (now 540 s), and my first gate refused the mid-mount right-click put-down, caught by the 0.17.1 bench-feedback test (now it parks the tool instead). A double put-down sound in that fallback was removed after the green run (one-line change; _park_tool already plays it).

### Added / Changed / Fixed / Removed
- Added `scripts/bench/hand_state.gd`: the machine from `docs/HAND_STATES.md`. `derive(flags)` names the state, `MOVES` lists the allowed changes, `allowed(from, to)` answers for one. Letting go is always allowed.
- Changed: the bench asks `_may_enter(<state>)` before every act that takes something into the hands: equipping (one choke point, `_equip_tool`, now returning whether it happened), keyboard/button tool switching, beginning a throw, grabbing the hose, taking the clamp, lifting a part, starting a mount, opening the stock panel, toggling the cloth. A refused act does nothing, silently.
- Newly impossible (each was physically possible before and is now also a regression test): taking or throwing a tool mid-mount; the wipe toggle mid-mount (it reverts); taking a tool, by click or keyboard, while carrying the hose; carrying two things at once. Putting a tool DOWN stays possible everywhere (letting go is always allowed): where a throw is forbidden, the same right-click parks the tool gently instead, which keeps 0.17.1's mid-mount put-down working (its test caught my first version refusing it).
- Changed behaviour (superseding 0.19.x auto-release): a keyboard tool switch while gripping the hose is refused instead of silently dropping the hose; the gripping hand is still on the button. `tool_rig.select`'s auto-release stays as a safety net for direct calls.
- Changed (hole in the spec closed): a stage switch mid-mount now behaves like pulling the lever: the mount finishes with the paste as it lies, instead of leaving a frozen mount running behind the cleaning stage and (with the gates) no way to equip anything.
- `hand_state()` now delegates to the machine; same answers as 0.19.6 (the state table proves it).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/hand_state.gd` | A | the machine |
| `scripts/view/bench_view.gd` | M | gates at every hand-entry point |
| `docs/HAND_STATES.md` | M | now describes the enforced rules |
| `tools/test_regressions.gd` | M | machine rules + bench refusal tests |
| `DEVELOPMENT.md`, `docs/WORK_PLAN.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | map, status, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Refusing instead of auto-releasing on a tool switch while gripping the hose; a stage switch mid-mount securing the cooler as it lies. Both are one-line changes to flip if the user prefers the old way.

### Known issues and open items
Focus loss and leaving the bench mid-state are still unhandled (step 7). The full press/release routing through the machine (replacing the `_input` chain) is step 9.

### Next action
**User playtest of 0.19.7**: normal play must feel identical; also try switching stages mid-mount and switching tools while dragging the hose. Then Claude: step 7 (transition and failure tests). Hot files stay with Claude.

## 0.19.6 - 2026-11-13 - Hand states named and made visible (no behaviour change)
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.5
- Type: patch (specification and instrumentation; no behaviour change). Work plan Phase 2 step 5. **Phase 2 has begun: the hot files belong to Claude until it ends.**

### Execution status
GitHub Actions ran everything on Godot 4.7.2 headless; results below, including whether the new state table shows any mismatch.

Actions result (Godot 4.7.2 headless, run 43495666973, branch feature/hand-states): checker passed; suites unchanged (785 checks, 0 failures). The PLAYTEST STATE table walks all eight states and every row matches its expected state, no MISMATCH markers.

### Added / Changed / Fixed / Removed
- Added `docs/HAND_STATES.md`: the eight hand states (PANEL_OPEN, MOUNTING, DRAGGING_CLAMP, CARRYING_HOSE, DRAGGING_PART, THROWING, USING_TOOL, FREE), how each derives from today's flags in priority order, and the allowed moves between them. This is the specification step 6 will enforce; two known holes (focus loss, leaving the bench mid-state) are written down for step 7's tests.
- Added `bench_view.hand_state()`: read-only, derived from the existing flags; nothing acts on it yet.
- Added a `PLAYTEST STATE` table to the scripted playtest: one action sequence that passes through all eight states, printing the derived state beside the expected one, with a MISMATCH marker.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `docs/HAND_STATES.md` | A | specification |
| `scripts/view/bench_view.gd` | M | `hand_state()` (read-only) |
| `tools/playtest_bench.gd` | M | state table |
| `DEVELOPMENT.md`, `docs/WORK_PLAN.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | map, status, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Treating "applying the tool" as a property inside USING_TOOL rather than a ninth state; the priority order of derivation.

### Known issues and open items
The forbidden moves are still physically possible until step 6; the table only makes today's truth visible.

### Next action
Claude: step 6 (the hand state machine itself). Hot files stay with Claude; Codex continues design/non-hot work only.

## 0.19.5 - 2026-11-13 - Code-style checker in CI (report-only)
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`. Earlier 0.19.x steps were made by Claude (Opus 5.5, model id claude-opus-5-5); the session's model changed before this version.
- Based on: 0.19.4
- Type: patch (CI only; no game change). Work plan Phase 1 step 4, the last Phase 1 step.

### Execution status
No game code changed. GitHub Actions ran everything on Godot 4.7.2 headless; results below.

Actions result (Godot 4.7.2 headless, run 43490915074, branch feature/gdlint): checker passed; suites unchanged (data schema 182, regression 461, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures). First gdlint report: 767 findings, of which 737 are lines over 100 characters; the substantive rest: 13 duplicated scene/script loads, 9 definitions out of order, 2 files over the length limit (bench_view, test_regressions), 2 classes with too many public methods, 1 function with too many returns (_input), 2 naming complaints (GameState_base, CELL).

### Added / Changed / Fixed / Removed
- Added: a `gdlint` step (gdtoolkit 4.x) in the workflow, over `scripts/` and `tools/`. Report-only: it never fails the build while the style backlog exists; the log keeps the full report. Once the backlog is cleared, removing its `continue-on-error` line makes it blocking.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | gdlint step |
| `docs/WORK_PLAN.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | status, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 suites and the gdlint report via Actions: see Execution status.

### Decisions proposed (not approved)
Which style rules to enforce (or silence) when making the step blocking is an open choice; the default rules are in use for the report.

### Known issues and open items
The style backlog itself is untouched; clearing it is routine follow-up work inside later steps, not a step of its own.

### Next action
Phase 1 is complete. Claude: Phase 2 step 5 (naming the hand states, no behaviour change) next; from then until the end of Phase 2, the hot files (`bench_view.gd`, `tool_rig.gd`, `game_state.gd`) are owned by Claude, so Codex should not edit them (design docs and non-hot gameplay files remain free).

## 0.19.4 - 2026-11-13 - Layout and ID constants in one place
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.3
- Type: patch (code health; no behaviour change). Work plan Phase 1 step 3. Touched the hot files (`bench_view.gd`, `tool_rig.gd`, `game_state.gd`) for literal replacement only.

### Execution status
GitHub Actions ran the checker, all suites and the scripted playtest on Godot 4.7.2 headless; results below, including a comparison of the playtest tables with 0.19.3.

Actions result (Godot 4.7.2 headless, run 43488415071, branch feature/constants): checker passed; suites unchanged (data schema 182, regression 461, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures). All 293 scripted-playtest rows (brush, vacuum, reach, click and paste tables) are identical to 0.19.3 (run 43486404945), compared line by line; only the frame-time rows, which are timings, differ.

### Added / Changed / Fixed / Removed
- Added `scripts/data/layout.gd`: every fixed screen position that was typed in more than one place or is a physical work area (bench table, PC area, tray, bin, clamp, socket, lever, side panel; shop, hardware-bench and start-screen cards; the window). Values unchanged.
- Added `scripts/data/ids.gd`: tool ids, tool groups per stage, the cleaning-stage tool slots, stage numbers, serviceable part ids. Values unchanged, so saves are unaffected.
- Changed: the scripts that owned these values keep their constant names as aliases (`ToolRig.TABLE`, `ServiceAccess.TRAY`, `DustBin.RECT`, `bench_view.PANEL_X`, `SECURE_LEVER`, ...), so other code and the tests did not change. Typed literals such as `"vacuum"`, `["vacuum","brush","pick"]`, `{"vacuum":0,"brush":1,"pick":3}` and `Rect2(0, 0, 1280, 720)` were replaced in `bench_view.gd`, `tool_rig.gd`, `tool_renderer.gd`, `service_access.gd`, `dust_bin.gd`, `dust_zones.gd`, `service_parts.gd`, `pc_renderer.gd`, `game_state.gd`, `shop_view.gd`, `start_view.gd`, `workshop_view.gd`, `hover_card.gd`. Player-visible text (e.g. "cloth", "Under cooler") was left as text.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/data/layout.gd`, `scripts/data/ids.gd` | A | constants |
| the 13 scripts listed above | M | literals replaced by constants |
| `DEVELOPMENT.md`, `docs/WORK_PLAN.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | map, status, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. A search confirms no tool/part id string remains outside `ids.gd` except player-visible text, and no screen rectangle literal remains outside `layout.gd` and `pc_layout.gd`. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
None.

### Known issues and open items
Other numbers (tool sizes, hose attach point, panel button positions inside `_build_ui`) were left where they are: they are each used in one place. Step 14 (layout controls) will handle the buttons.

### Next action
Claude: Phase 1 step 4 (gdlint in CI, report-only). Hot files are free again for Codex after this merge.

## 0.19.3 - 2026-11-13 - Frame-time measurement in the scripted playtest
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.2
- Type: patch (measurement tooling; no gameplay change). Work plan Phase 1 step 2.

### Execution status
GitHub Actions ran the checker, all suites and the scripted playtest on Godot 4.7.2 headless; results below. Headless means the drawing *script* runs but nothing reaches a graphics card: GPU time is not measured, and the machine is GitHub's, not the user's.

Actions result (Godot 4.7.2 headless, run 43485647941, branch feature/frame-times): checker passed; suites unchanged (data schema 182, regression 461, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures).

Frame-time table (microseconds; each column is one subsystem measured on its own, CPU side only):

| Scene | Physics avg | Physics worst | Redraw avg | Redraw worst | State check |
| --- | --- | --- | --- | --- | --- |
| idle bench | 1,213 | 3,753 | 934 | 998 | ok |
| brushing | 1,722 | 4,014 | 956 | 1,018 | ok (holding) |
| vacuum + moving hose | 3,437 | 4,723 | 944 | 1,332 | ok (holding) |
| paste flowing | 3,351 | 5,984 | 79 | 114 | ok (mounting) |
| idle paste stage | 116 | 551 | 54 | 92 | ok |

Reading: these are subsystem costs, not total frame times: they exclude GPU work and the rest of the engine, so they do not prove a whole frame fits in 16.7 ms; they show where our own scripts spend time. The moving hose and flowing paste are the most expensive (about 3.4 ms per physics tick). The idle cleaning bench still spends about 1.2 ms per tick with nothing happening (the dust simulation runs anyway): the obvious first saving if one is ever needed.

Correction: a first run (43483351739) reported 4.4 ms for the idle paste stage. Codex's cross-review found why: the "paste flowing" scene starts a 10 s mount but measures 3 s, and the next scene did not end it (`_on_clear_pressed` returns while mounting), so the "idle" scene was still simulating paste. Each scene now ends any mount first, and the table prints a state check per scene; the idle paste stage is 0.12 ms.

### Added / Changed / Fixed / Removed
- Added: a frame-time table at the end of `tools/playtest_bench.gd` (`PLAYTEST FRAMES` lines). Five scenes (idle bench, brushing, vacuum with a moving hose, paste flowing, idle paste stage), 180 real engine frames each; per scene the average and worst physics tick and the average and worst redraw (CPU side), in microseconds. It never fails the build.
- Changed (hot file, small): `bench_view.gd`'s `_draw` now times itself into `last_draw_usec` and calls the old body, renamed `_draw_scene`. No drawing change.
- Changed: the playtest watchdog now quits only after 5 s without progress, so the table can wait for real frames.
- Fixed (found by Codex's cross-review): scenes are isolated (any active mount is finished first) and each table row ends with a state check.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `tools/playtest_bench.gd` | M | frame-time table, watchdog |
| `scripts/view/bench_view.gd` | M | `_draw` timing wrapper |
| `DEVELOPMENT.md`, `docs/WORK_PLAN.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | map, status, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
None.

### Known issues and open items
Real frame rate on the user's PC (with the GPU) is still unknown: one debug run on the user's machine would complete the picture.

### Next action
Claude: Phase 1 step 3 (layout and ID constants). It touches the hot files briefly (replacing literals only); Codex should not have open work on `bench_view.gd`, `tool_rig.gd` or `game_state.gd` during it.

## 0.19.2 - 2026-11-13 - Shared test helper and one-loop test workflow
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.1
- Type: patch (test tooling only; no game change). Work plan Phase 1 step 1.

### Execution status
No game code changed. GitHub Actions ran all suites on Godot 4.7.2 headless; result below. The check counts must equal 0.19.1's.

Actions result (Godot 4.7.2 headless, run 43454879880, branch feature/test-support): checker passed; same counts as 0.19.1: data schema 182, regression 461, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36; 0 failures. A first run did not start because the new step name contained ": " (invalid YAML); fixed.

### Added / Changed / Fixed / Removed
- Added `tools/test_support.gd`: the shared base for test suites (`check`, `use_test_save`/`restore_save`, `click`, `finish`). Each of the 7 suites now `extends "res://tools/test_support.gd"` instead of `SceneTree`; their copied `checks`/`failed` counters, `check()` functions, the two copied `click()` helpers and the summary/quit lines were removed. The summary text is unchanged. Save-path handling inside the suites is untouched for now (the helper is there for new suites).
- Changed: the workflow runs the 7 suites in one loop step (a list of file and summary name). Every suite runs even if an earlier one fails; the step fails if any suite fails, prints no summary or has a script error. Logs are still kept per suite.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `tools/test_support.gd` | A | shared test base |
| `tools/test_*.gd` (7) | M | extend the base; duplicates removed |
| `.github/workflows/tests.yml` | M | one loop step for all suites |
| `DEVELOPMENT.md`, `docs/WORK_PLAN.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | map, status, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
None.

### Known issues and open items
None.

### Next action
Claude: Phase 1 step 2 (frame-time measurement in `tools/playtest_bench.gd`). Hot files remain free for Codex.

## 0.19.1 - 2026-11-13 - Work plan and split of responsibilities
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.19.0 (main 82170d1)
- Type: patch (documentation only; no game change)

### Execution status
No game code changed. GitHub Actions runs the checker and all Godot 4.7.2 suites on this branch; result below.

Actions result (Godot 4.7.2 headless, run 43453326512, branch docs/work-plan): checker passed; data schema 182, regression 461, start screen 10, dust flow 43, bench interaction 26, bench feedback 27, audio and vacuum 36 checks; 0 failures.

### Added / Changed / Fixed / Removed
- Added `docs/WORK_PLAN.md`: the user-approved code-health plan (17 steps in 5 phases, from Claude's code review and Codex's improvement list) and the split of responsibilities: Codex does design and gameplay features, Claude does engineering and code health. Hot files (`bench_view.gd`, `tool_rig.gd`, `game_state.gd`) have one owner at a time; cross-review; handoff line in every "Next action".
- Added `docs/CODEX_PROMPT_WORK_PLAN.md`, a prompt for the user to give Codex.
- Changed: `AGENTS.md` rule 5, `HANDOFF.md` current update, `docs/ROADMAP.md` note, `DEVELOPMENT.md` file map.
- Fixed: README install step still named the 0.18.0 ZIP.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `docs/WORK_PLAN.md` | A | plan and split |
| `docs/CODEX_PROMPT_WORK_PLAN.md` | A | prompt for Codex |
| `AGENTS.md`, `HANDOFF.md`, `DEVELOPMENT.md`, `README.md`, `docs/ROADMAP.md`, `CHANGELOG.md`, `project.godot` | M | rule, handoff, map, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Step order inside each phase and the "done when" criteria are Claude's proposals; the split and the plan as a whole were approved by the user.

### Known issues and open items
Codex has not yet confirmed the plan.

### Next action
Claude starts Phase 1 step 1 (shared test helper, workflow loop): touches `tools/` and the workflow only. Hot files are free for Codex until Phase 1 step 3 is announced.

## 0.19.0 - 2026-11-13 - Clear vacuum state, hose recovery and silent audio groundwork
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.18.0 (merged main 63a0dbc2a0dfa99940fd4d1aa34015cb492c6400)
- Type: minor (new silent feedback service/cue contract and control organisation)

### Execution status
Codex ran Godot 4.7.2.stable.official.ed1daf0bf headlessly. Inspected the user's 58.7-second recording: bin reaches 100% around 35 seconds, intentionally disabling suction; tool changes replace its transient warning. No graphical acceptance or sound playback is claimed. A controlled rapid-drag replay reproduced hose crossings before the fix.

### Added / Changed / Fixed / Removed
- Persistent bin status and nearby Empty bin action retain the full-bin warning across tool changes. Capacity/manual emptying remain; no vacuum-strength or save-schema change.
- Cleaning tools and maintenance have separate rows; thermal material/tool selection precedes mount/completion. Clear stage names avoid competing numeric shortcuts; practice ticket reset is labelled. Completion remains gated by actual mount result.
- Hose link untangling prevents persistent self-crossings; rare pinned folds recover via outward arc reseeding. Reset local velocity avoids adding a whip impulse. Occupied clamp reach reserves the pinned segment length rather than the straight bin-to-pin distance.
- Added silent AudioFeedback autoload, 28 semantic cues, six native mixer buses, owner-scoped loop deduplication/update/cleanup, one-shot cooldowns and bounded diagnostics. Hooked actual contact/work, handling, fans, bin/clamp/hose, UI and final checks. No audio files, players or playback are added. Detailed sound direction and adapter boundaries in AUDIO_DESIGN.md.
- Back from an unlocked mount cancels it instead of completing mounting via navigation; deliberate physical lever remains required. User clarified cooler work is interaction design, not art; pressure/release and lever feedback goals are accepted, exact redesigned puzzle remains proposed.
- Updated all five core docs, minigame rules, workflow map/contracts and CI. No new scam, campaign, fan-driven dust or cooler artwork mechanics.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `CHANGELOG.md` | M | Signed release history and verification |
| `DEVELOPMENT.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `HANDOFF.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `README.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `default_bus_layout.tres` | A | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/AUDIO_DESIGN.md` | A | Sound design contract and implementation boundary |
| `docs/CURRENT_STATE.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/DECISIONS.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/DESIGN.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/DESIGN_PROPOSALS.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/MINIGAME_RULES.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/PROJECT_BRIEF.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `docs/ROADMAP.md` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `project.godot` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/audio/audio_feedback.gd` | A | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/bench/dust_sim.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/bench/hose_sim.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/bench/tool_rig.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/data/audio_cues.gd` | A | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/view/bench_view.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/view/cleaning_renderer.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/view/shop_view.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/view/start_view.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `scripts/view/workshop_view.gd` | M | Feedback, hose reliability, silent audio wiring or updated project record |
| `tools/test_audio_and_vacuum.gd` | A | Feedback, hose reliability, silent audio wiring or updated project record |

### Checks performed
Godot 4.7.2 headless: regression 461, schema 182, menu 10, dust flow 43, pickup/parts interaction 26, bench feedback 27 and new audio/vacuum 36 checks — 785 total, zero failures. New checks cover actual full-bin pause/tool-change/empty/resume, silent mixer/event lifecycles, stale-loop cleanup, grouped controls, paste contact and unlocked-mount cancellation, rapid free/pinned hose transitions. Pre-fix free-hose replay: up to 10 crossings on 625/960 frames; fixed free 960-frame and clamp-transition 480-frame replays have zero crossings. Python project checker PASSED: 46 scripts, 155 resource references, 70 mapped files and all five core docs. git diff --check passed. Fresh source ZIP extraction passed the same checker and all 36 new audio/vacuum checks in Godot 4.7.2.

### Decisions proposed (not approved)
Sound palette, sample variants, fades, voice budgets, settings and playback adapter are future proposals. No sounds are produced now. Exact cooler pressure/release puzzle and lever gesture require selection; new artwork is deferred. Hose recovery is pragmatic tabletop untangling, not a 3D knot solver.

### Known issues and open items
Human mouse-feel/layout acceptance is pending, especially rare pinned-fold recovery motion. A full bin intentionally stops suction. Sound assets/playback/mix/settings do not exist. No complete game/campaign or Steam build is claimed. Existing larger promise/claim/consequence work remains.

### Next action
Human-test full-bin/empty/resume and fast hose/clamp movement. Choose the next cooler interaction rule, then independently approve the first sound palette/sample slice. Preserve this version as a baseline before new work.

## 0.18.0 - 2026-11-13 - Trapped dust tails, clamp dragging and mounting put-down
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.17.1 (user reports tested and working)
- Type: minor (new precision extraction option plus reach/handling fixes)

### Execution status
Godot 4.7.2.stable.official.ed1daf0bf run headlessly by Codex. Inspected user's 23-second mounting recording: right input was blocked by mount.active until the lever finished; paste also inherited the cleaning parts-mode gate. Automated checks cover those states and the new dust/clamp/reach rules. No human graphical acceptance of this patch is claimed.

### Added / Changed / Fixed / Removed
- Added representative tails/count for real hidden dust; precise vacuuming outside a housing slowly extracts pinned clumps. Normal center access stays blocked; disassembly remains easier and pick risky. Threads are derived from existing mass, with smaller speck tails as chains clear.
- Clamp can be left- or right-dragged; stationary left-click unclips on release. Quick drags use release position; selection cancels capture. Replacement-stock button moved below desk to stop overlapping fixture controls. Footprint/case/bin/occupied-reach restrictions retained.
- Standard hose 640 -> 560 px; longer upgrade 860 -> 760 px (provisional). Actual tower/compact corner tests verify tight reach with rotated nozzle. Upgrade ownership/cost unchanged.
- Mount start parks tools. Right-drag put-down works during mounting and after its timer expires, without clicking the lever, grading or resetting. Paste input no longer inherits the cleaning parts-mode restriction.
- Added dedicated feedback regression/CI step and reconciled five core docs/minigame rules. Cooler visual improvements are documented as proposals, not coded changes.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Bench feedback, control fixes, verification or current design record |
| `CHANGELOG.md` | M | Bench feedback, control fixes, verification or current design record |
| `DEVELOPMENT.md` | M | Bench feedback, control fixes, verification or current design record |
| `HANDOFF.md` | M | Bench feedback, control fixes, verification or current design record |
| `README.md` | M | Bench feedback, control fixes, verification or current design record |
| `project.godot` | M | Bench feedback, control fixes, verification or current design record |
| `scripts/bench/dust_sim.gd` | M | Bench feedback, control fixes, verification or current design record |
| `scripts/bench/hose_sim.gd` | M | Bench feedback, control fixes, verification or current design record |
| `scripts/view/bench_view.gd` | M | Bench feedback, control fixes, verification or current design record |
| `scripts/view/cleaning_renderer.gd` | M | Bench feedback, control fixes, verification or current design record |
| `tools/test_regressions.gd` | M | Bench feedback, control fixes, verification or current design record |
| `tools/test_bench_feedback.gd` | A | Trapped-thread/fixture/reach/mount regression |
| `docs/PROJECT_BRIEF.md` | M | Bench feedback, control fixes, verification or current design record |
| `docs/DESIGN.md` | M | Bench feedback, control fixes, verification or current design record |
| `docs/DECISIONS.md` | M | Bench feedback, control fixes, verification or current design record |
| `docs/CURRENT_STATE.md` | M | Bench feedback, control fixes, verification or current design record |
| `docs/ROADMAP.md` | M | Bench feedback, control fixes, verification or current design record |
| `docs/MINIGAME_RULES.md` | M | Bench feedback, control fixes, verification or current design record |
| `docs/DESIGN_PROPOSALS.md` | M | Bench feedback, control fixes, verification or current design record |

### Checks performed
Godot 4.7.2 headless: regression 461, schema 182, menu 10, dust flow 43, pickup/parts interaction 26 and new bench feedback 27 checks — 749 total, zero failures. Feedback checks cover tail-only slow extraction, covered-center blocking, clamp left/right drag and UI exclusion, occupied release, capture cancellation, tower/compact corner reach, and put-down before/after mount timeout without securing. Python project checker PASSED: 43 scripts, 148 resource references, 66 mapped files, five core docs; git diff --check passed. No graphical acceptance claimed.

### Decisions proposed (not approved)
Tail count, precision radius, resistance, hose lengths and drag threshold are trial tuning. Cooler silhouette/compression/cutaway/material/lever/UI ideas in DESIGN_PROPOSALS section 6 are proposals only; current pressure rules are unchanged.

### Known issues and open items
Human visual/feel acceptance pending. Clamp arrangement remains session-local. Owned longer-hose upgrade intentionally still adds reach. Partial tails represent a few hidden groups, not every particle; dirt mass is unchanged. Cooler art/animation redesign remains open.

### Next action
Playtest tail extraction versus disassembly, clamp drag, base/upgrade reach and tool put-down before lever. Discuss/select the first cooler presentation slice.

## 0.17.1 - 2026-11-13 - Restore same-press tool pickup and component removal
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.17.0
- Type: patch (reproduced input bugs; no new feature or save contract)

### Execution status
Codex inspected the user's 42-second recording and reproduced both paths on active 0.17.0 with Godot 4.7.2.stable.official.ed1daf0bf headless. Before the fix, 7 of 11 recording-led checks failed. Expanded post-fix coverage includes cleaning tools, paste-tool rack pickup, and both removable components. No interactive graphical acceptance of this patch is claimed.

### Added / Changed / Fixed / Removed
- Fixed: left-click pickup of a resting tool returned with holding=false, so moving it during that press did no work until release/reclick. Pickup now starts the same held stroke, including cloth/syringe moved from rack onto CPU. Releasing left still stops use.
- Fixed: Move parts clicks were intercepted by tools lying over a component. Explicit parts-mode press/release now routes to component dragging first. GPU/cooler can be removed, cleaned underneath and refitted even with a parked vacuum covering them.
- Added: recording-led regression and CI step. Updated current handoff/core documents to supersede prior uncertainty with the reproduced input cause. No dust strength, physics, inventory, payment or save-format change.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Input correction, verification or current handoff |
| `CHANGELOG.md` | M | Input correction, verification or current handoff |
| `DEVELOPMENT.md` | M | Input correction, verification or current handoff |
| `HANDOFF.md` | M | Input correction, verification or current handoff |
| `README.md` | M | Input correction, verification or current handoff |
| `project.godot` | M | Input correction, verification or current handoff |
| `scripts/view/bench_view.gd` | M | Input correction, verification or current handoff |
| `tools/test_bench_interactions.gd` | A | Recording-led interaction regression |
| `docs/PROJECT_BRIEF.md` | M | Input correction, verification or current handoff |
| `docs/DESIGN.md` | M | Input correction, verification or current handoff |
| `docs/DECISIONS.md` | M | Input correction, verification or current handoff |
| `docs/CURRENT_STATE.md` | M | Input correction, verification or current handoff |
| `docs/ROADMAP.md` | M | Input correction, verification or current handoff |

### Checks performed
Godot 4.7.2 headless: 461 regression, 182 schema, 43 dust-flow, 10 menu and 26 recording-led bench-interaction checks; 722 total, zero failures. New baseline reproduction failed 7 of its original 11 checks before the fix. The expanded suite verifies actual under-dust vacuuming and refit for both components plus cloth/syringe rack pickup. Python project checker PASSED: 42 scripts, 141 resource references, 65 mapped files, five core docs; git diff --check passed. No graphical acceptance claimed.

### Decisions proposed (not approved)
None. This restores intended interactions rather than adding mechanics or retuning the minigames.

### Known issues and open items
User graphical acceptance still needed. The supplied recording uses the earlier eight-region UI, but both faults were reproduced on the current nine-region 0.17.0 code. Previous broad first-entry uncertainty is resolved for this input sequence; do not claim every possible unrelated input issue is fixed.

### Next action
Playtest put-down/pickup without an extra click, and component remove/clean/refit. Then resume the existing work-order/consequences scope.

## 0.17.0 - 2026-11-13 - Physical dust restoration, case-wide scattering and movable clamp
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.16.0
- Type: minor (case-wide dust transport, additive physical-state save contract and movable fixture)

### Execution status
Codex ran Godot 4.7.2.stable.official.ed1daf0bf headlessly. The original first-entry stall was not reproduced on a controlled fresh 0.16.0 ticket: first/new tickets gave equal suction. Current tests cover first entry, physical-save reopen, legacy-save reopen, New dirty PC and reset using actual mouse/tool simulation. Do not claim a user-save-specific root cause was established. No graphical/human acceptance is claimed.

### Added / Changed / Fixed / Removed
- Shared dust initialization/restoration across entry/reset paths; real saved dust includes positions, looseness, current areas and traps, with atomic validation and fractional fallback for old/damaged saves. Light brush contact visibly loosens dirt; accessible tops are explicitly reachable, and vacuum collects already-moving dust immediately.
- Fast brushing sends dirt across the case instead of confining it to the originating part. Installed GPU/cooler catch it underneath; filter catches it with stronger grip. A new zero-spawn Case interior area tracks scattered dirt. Dirt movement conserves mass and can re-dirty cleaned areas; no false removal credit. Extracted component surfaces remain on their service tray.
- Removed automatic threshold shake-off and vacuum-off timed deletion. Physical dirt is not deleted by stopping suction or reaching a progress threshold. Existing quality threshold stays provisional.
- Right-drag movable clamp with full-footprint case/bin exclusion, desk bounds and occupied-hose reach. Left-click with empty hands unclips. Renderer/hit-tests use actual pose; invalid placement is visibly flagged. Session-local fixture arrangement.
- CI includes a dedicated first-use/save/transport/clamp suite. Catalogue, campaign, scams and fan airflow remain unchanged.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `CHANGELOG.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `DEVELOPMENT.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `HANDOFF.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `README.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `project.godot` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/bench/dust_sim.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/bench/dust_snapshot.gd` | A | Physical dust snapshot contract |
| `scripts/bench/tool_rig.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/data/dust_zones.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/state/game_state.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/view/bench_view.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/view/cleaning_renderer.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/view/pc_renderer.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `scripts/view/tool_renderer.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `tools/test_regressions.gd` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `tools/test_dust_flow.gd` | A | Dust flow, movable clamp, verification or reconciled handoff |
| `docs/PROJECT_BRIEF.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `docs/DESIGN.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `docs/DECISIONS.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `docs/CURRENT_STATE.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `docs/ROADMAP.md` | M | Dust flow, movable clamp, verification or reconciled handoff |
| `docs/MINIGAME_RULES.md` | M | Dust flow, movable clamp, verification or reconciled handoff |

### Checks performed
Godot 4.7.2: schema 182 checks, regression 461 checks, start-screen integration 10 checks, dedicated dust-flow/clamp integration 43 checks; zero failures (696 total). First-use suite exercises fresh, physical-save, legacy-save, New dirty PC and reset paths. Four headless scene startup smoke checks passed with isolated saves. Python project checker PASSED (41 scripts, 137 references, 64 mapped files, five core docs); git diff --check passed. Expected damaged-save recovery warnings occur in dedicated fixtures. An initial CI/clean-package regression caught the old clean-resume wording assertion after the status text changed; the assertion now checks the truthful threshold/remaining-dirt explanation. No graphical/human acceptance is claimed.

### Decisions proposed (not approved)
Light-contact rate, scattering speeds, grip/settling/capture tuning and 95% quality tolerance remain playtest values. No fan-driven transport or new scam consequences are approved by this implementation.

### Known issues and open items
Original user-save-specific startup stall not reproduced from a clean baseline; human acceptance required. Old fraction-only saves cannot reconstruct past particle positions that were never stored; new saves do. Clamp pose remains session-local. No new graphical validation; default fixture/rendering remain placeholder art. Full promise/claim/consequence systems remain unimplemented.

### Next action
Playtest first-use tools on the user's save, cross-case brushing/traps, save/reopen and movable clamp. Preserve any still-failing save for a precise reproduction. Continue work-order/consequence scope afterwards.

## 0.16.0 - 2026-11-13 - Start menu and snag-free hose with desk clamp
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work. Model identified by the user.
- Based on: 0.15.2 (PR #10 merged by explicit user instruction)
- Type: minor (new player-visible start screen and optional hose-clamp mechanic)

### Execution status
Godot 4.7.2.stable.official.ed1daf0bf was run headlessly by Codex for schema, regression and start-screen integration checks. Earlier intermediate checks used locally installed 4.6.3; the final results below are on 4.7.2. Native graphical launch failed because no display server was available, so visual/mouse-feel acceptance is not claimed. The user reports testing prior AI work, not this new feature.

### Added / Changed / Fixed / Removed
- Added New game / Load game / Achievements start screen. New enters the existing demo, Load restores progress; achievements clearly unavailable. Confirm before replacing an existing save; disable Load if no readable save. Menu-only startup without a save does not create one. Shop Main menu saves before returning.
- Fixed hose routing around complete cooler/GPU housings rather than rounded fan-like obstacles; links as well as nodes clear housing corners. Renderer follows the collision-tested links.
- Fixed tools snagging/stealing hose input: hose slides under tools/held parts; held-tool right-drag wins. Shift-right-drag (or empty-hand right-drag) grabs along the hose, including between nodes. Optional visible desk clamp parks a carried section; click with empty hands or re-grab to release. Too-short sections cannot stretch into it.
- Added menu/save integration coverage and hose regressions; CI runs the new suite. No save format or cleaning/paste/economy balance changes.
- Merged the only open PR at inventory (#10); older other-AI PRs were already merged. User's new merge instruction supersedes the earlier docs-only no-merge restriction. Signed current work with the user-identified model; historical signature correction appended without rewriting history.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Menu/hose implementation, verification or reconciled documentation |
| `CHANGELOG.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `DEVELOPMENT.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `HANDOFF.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `README.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `project.godot` | M | Menu/hose implementation, verification or reconciled documentation |
| `scenes/start.tscn` | A | Menu/hose implementation, verification or reconciled documentation |
| `scripts/view/start_view.gd` | A | Menu/hose implementation, verification or reconciled documentation |
| `scripts/state/game_state.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `scripts/bench/hose_sim.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `scripts/bench/tool_rig.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `scripts/view/bench_view.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `scripts/view/shop_view.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `scripts/view/tool_renderer.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `tools/test_regressions.gd` | M | Menu/hose implementation, verification or reconciled documentation |
| `tools/test_start_screen.gd` | A | Menu/hose implementation, verification or reconciled documentation |
| `docs/PROJECT_BRIEF.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `docs/DESIGN.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `docs/DECISIONS.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `docs/CURRENT_STATE.md` | M | Menu/hose implementation, verification or reconciled documentation |
| `docs/ROADMAP.md` | M | Menu/hose implementation, verification or reconciled documentation |

### Checks performed
Godot 4.7.2: data schema 179 checks, 0 failures; regression 461 checks, 0 failures; start-screen integration 10 checks, 0 failures. Save recovery warnings are intentional tests of damaged saves. Python project checker PASSED: 39 scripts, 130 resource references, 62 mapped files, five core documents; git diff --check passed. Target-engine headless startup smoke checks passed for start, shop, repair bench and hardware bench (isolated smoke save directory).

### Decisions proposed (not approved)
Clamp position/appearance, Shift-right input and collision/render tuning are implementation choices for playtest. Achievements content/unlocks and existing scam balance remain open. No new campaign or scam system is approved by this feature.

### Known issues and open items
No interactive graphical validation in this runtime. Clamp/bin/hose arrangements are session-local; this does not add their persistence. Achievements is a placeholder; no Steam integration. Original work-order/claims/consequence backlog remains. User acceptance needed for hose feel/corner clearance and menu layout.

### Next action
Run/check the feature PR, integrate under the user's merge instruction, then human-playtest menu/load and hose/clamp controls. Continue promises/claims/one-consequence work afterwards.

## 0.15.2 - 2026-11-13 - Approved scams, customer promises and minigame rules
- Author: Codex (GPT-6, model id not exposed by this session) in ChatGPT Work. Exact deployment model id is unavailable; see Known issues.
- Correction (2026-11-13): the user identifies this Codex session as GPT 6.1 Sol; current contributions are signed `Codex (GPT 6.1 Sol, model id gpt-6.1-sol)`. Preserve the original unavailable-id disclosure as the state of knowledge when that patch was written.
- Based on: 0.15.1
- Type: patch (documentation and version metadata only)

### Execution status
Godot was NOT run for this patch. Gameplay scripts/scenes are unchanged. Current gameplay is 0.15.1; this patch does not implement its newly documented design. Human acceptance is still needed. Branch `design/scam-direction`, PR without merge.

### Added / Changed / Fixed / Removed
- Record user acceptance of A/B/D/E/F/G/H and rejection of C. Preserve stable IDs, normal filter work and ownership rules.
- Specify visible customer promises and intended separation of agreement, actual work, completion claim and functional result. Retain physical dust/paste rules; document the current cleanliness gate as an implementation gap.
- Add a completion checklist and scoped next steps; reconcile the five core document summaries and current GitHub workflow. Consequence numbers/UI/limited-service details stay proposals.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `CHANGELOG.md` | M | Approved design, state tracking or contributor handoff |
| `DEVELOPMENT.md` | M | Approved design, state tracking or contributor handoff |
| `HANDOFF.md` | M | Approved design, state tracking or contributor handoff |
| `README.md` | M | Approved design, state tracking or contributor handoff |
| `project.godot` | M | Version metadata only |
| `docs/PROJECT_BRIEF.md` | M | Approved design, state tracking or contributor handoff |
| `docs/DESIGN.md` | M | Approved design, state tracking or contributor handoff |
| `docs/DECISIONS.md` | M | Approved design, state tracking or contributor handoff |
| `docs/CURRENT_STATE.md` | M | Approved design, state tracking or contributor handoff |
| `docs/ROADMAP.md` | M | Approved design, state tracking or contributor handoff |
| `docs/DESIGN_PROPOSALS.md` | M | Approved design, state tracking or contributor handoff |
| `docs/DESIGN_AGENT_PROMPT.md` | M | Approved design, state tracking or contributor handoff |
| `docs/SCAM_DESIGN_PROPOSAL.md` | A | Approved design, state tracking or contributor handoff |
| `docs/MINIGAME_RULES.md` | A | Approved design, state tracking or contributor handoff |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems; 37 scripts scanned, 121 resource references, 59 mapped files, all five core documents present. `git diff --check`: passed. File-scope review confirms only Markdown documents and project.godot version metadata changed; no scripts/scenes. Godot was not run.

### Decisions proposed (not approved)
Exact limited-service zone lists, functional thresholds, promise-strip UI, quote revision flow, complaint delays/odds/remedies and numerical balance. Accepted concepts do not approve all earlier examples. D56 fans remain queued.

### Known issues and open items
D51 requests an exact model id; this session exposes no deployment id. The truthful signature above is not full exact-id compliance. The checker only recognises the words `model id`, not their truth/completeness. No gameplay implementation or human acceptance is claimed. A delivered-job archive and a reader for `job.scams` are still missing.

### Next action
Review this documentation PR without merging automatically; human-test the baseline, then implement persistent promises, claim separation and the first delayed toothpaste consequence in bounded gameplay changes.

## 0.15.1 - 2026-11-13 - Physical cooler lever; handoff and prompt for Codex
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.15.0
- Type: patch (interaction change and docs)

### Execution status
**Godot was NOT run by me directly.** GitHub Actions runs the checker and the Godot 4.7.2 suites; results below. Not hand-tested.

Actions result (Godot 4.7.2 headless, run 43335195703, branch feature-0.15.1): checker passed; Data schema checks 179, failures 0; Regression checks 442, failures 0.

### Added / Changed / Fixed / Removed
- Changed (user request): the cooler is secured by physically clicking a retention **lever** drawn beside the socket (`SECURE_LEVER` in `bench_view.gd`, drawn by `PasteRenderer.draw_lever`). It stands up and glows while it can be pulled and folds down once locked. The Secure cooler button and the Enter shortcut are removed (my reading of "physically click"; easy to restore). When the 10 s of pressing run out, pressing stops and the lever waits; nothing secures automatically (`MountSession.step`).
- Added: `docs/HANDOFF_FOR_CODEX.md` (what changed since Codex's 0.11.0, workflow, what the user will ask). Rewrote `docs/DESIGN_AGENT_PROMPT.md` as a prompt addressed to Codex, with a delivery path (branch, docs-only 0.15.2, PR, no merge).
- Docs: D57 in DECISIONS, DESIGN section 18, README.
- Tests: time running out never secures; a click elsewhere does not secure; a click on the lever does.

### Files changed
A `docs/HANDOFF_FOR_CODEX.md`; M `docs/DESIGN_AGENT_PROMPT.md`, M `scripts/view/bench_view.gd`, M `scripts/view/paste_renderer.gd`, M `scripts/bench/mount_session.gd`, M `tools/test_regressions.gd`, M `docs/DECISIONS.md`, M `docs/DESIGN.md`, M `DEVELOPMENT.md`, M `HANDOFF.md`, M `README.md`, M `CHANGELOG.md`, M `project.godot`.

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Lever position (right of the socket), removing Enter, no automatic securing.

### Known issues and open items
The lever's look is placeholder shapes, like everything else.

### Next action
User playtest of the lever; give Codex the prompt.

## 0.15.0 - 2026-11-13 - Complete repaste, toothpaste scam, paste retune, bigger bin, design docs
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.14.3
- Type: minor (new player-visible feature and job data fields)

### Execution status
**Godot was NOT run by me directly.** GitHub Actions runs the checker, the data-schema suite, the regression suite and the scripted playtest on Godot 4.7.2 headless; results below. The user had playtested 0.14.2/0.14.3 by hand before this version; 0.15.0 itself is not hand-tested.

Actions result (Godot 4.7.2 headless, run 43332509024, branch feature-0.15.0): checker passed; Data schema checks 179, failures 0; Regression checks 439, failures 0; scripted playtest ran (paste table recorded in the log).

### Added / Changed / Fixed / Removed
- Added: **Complete repaste** button after mounting. Works only on PERFECT or GOOD ENOUGH; otherwise it says to wipe and retry. Thermal paste costs $3 when completed (proposal). The final check now counts the paste only once completed (`job.paste_done`); an older save with a grade counts as completed thermal paste.
- Added: **toothpaste** (`scripts/data/paste_materials.gd`). Switch with the **Paste:** button while the CPU is bare. Free; yield thickness x1.5 and mobility x0.75 (needs more pressure); +14 C in the final check; the customer still pays; `job.scams` records "toothpaste". Minty-white drawing. Wiping or clearing the paste removes the completion and the scam record. All numbers are proposals.
- Changed (paste retune from the scripted playtest table): gauge "about right" is 100-160 units (was 110-145, which did not match the outcomes); PERFECT needs 93% coverage (was 95%) and up to 25% squeezed out (was 20%); GOOD ENOUGH from 88% (was 90%). The mounting bars use the same lines as the grade (`PasteSim.PERFECT_COVER`, `PasteSim.MESSY_OVERFLOW`). Effect in the table: a pea-sized dot now gives PERFECT with a 2.5 s press and MESSY by 4 s; before, only a narrow window worked.
- Changed: dust bin 90 -> 140 units (user: "the tank is just a bit too small").
- Added: playtest paste table (4 patterns x 4 squeeze times x 5 press times) and `scripted_pressing` hook.
- Docs: DECISIONS (D45-D56: catch-up of 0.12-0.14 decisions, Complete repaste, toothpaste, scam direction, dust minigame purpose open, fans postponed), DESIGN sections 18-19, ROADMAP position after 0.15.0, CURRENT_STATE update note, DESIGN_PROPOSALS section 5, new `docs/DESIGN_AGENT_PROMPT.md`.
- Tests: schema checks for paste materials; regression checks for completion rules and cost, no double charge, toothpaste free/recorded/saved/hotter-but-passing, final-check notes, wipe undoes completion, old-save migration, toothpaste spreads less, mounting bars match grades, and a full bench run (squeeze, press, secure, Complete repaste).

### Files changed
A `scripts/data/paste_materials.gd`, A `docs/DESIGN_AGENT_PROMPT.md`; M `scripts/bench/paste_sim.gd`, M `scripts/bench/mount_session.gd`, M `scripts/bench/dust_bin.gd`, M `scripts/state/game_state.gd`, M `scripts/view/bench_view.gd`, M `scripts/view/paste_renderer.gd`, M `tools/test_regressions.gd`, M `tools/test_data_schemas.gd`, M `tools/playtest_bench.gd`, M `docs/DECISIONS.md`, M `docs/DESIGN.md`, M `docs/ROADMAP.md`, M `docs/CURRENT_STATE.md`, M `docs/DESIGN_PROPOSALS.md`, M `DEVELOPMENT.md`, M `HANDOFF.md`, M `README.md`, M `CHANGELOG.md`, M `project.godot`.

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
$3 thermal paste, toothpaste +14 C / x1.5 yield / x0.75 mobility / free, new grade lines and gauge zone, 140-unit bin, MESSY not completable.

### Known issues and open items
- What "fixing the thermal paste game" should cover beyond this was not specified; the retune and completion step are my reading. The mount readability idea (two squares) is still open.
- Toothpaste has no later consequence yet (D53/D54).
- The dust minigame's purpose is open (D55). Fans moving dust are postponed (D56).

### Next action
User playtest of the paste game; design pass on the scam direction using `docs/DESIGN_AGENT_PROMPT.md`.

## 0.14.3 - 2026-11-13 - Rule: AI contributors sign with their model
- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.14.2
- Type: patch (workflow rule, docs and tooling only; no game change)

### Execution status
No game code changed, so Godot behaviour is the same as 0.14.2. GitHub Actions runs the checker and the Godot 4.7.2 suites on this branch; result recorded below once it has finished.

Actions result (Godot 4.7.2 headless, run 43328137536, branch feature-0.14.3): checker passed; Data schema checks 172, failures 0; Regression checks 422, failures 0.

### Added / Changed / Fixed / Removed
- Added (user rule): every AI edit is signed with the model that made it, with the exact model id, in the changelog Author line, the HANDOFF signature and git commit messages. A person writes "(human)".
- Added: `tools/check_project.py` fails when the newest changelog entry has no Author line, or an AI author without "model id".
- Changed: changelog template, `DEVELOPMENT.md` section 2, `HANDOFF.md` section 4 step 4 and its Signed line (now names both models that worked in this session), `AGENTS.md` rule 4.
- Note: older entries are not rewritten (changelog rule). Entries 0.14.1 and earlier were made by Claude Sonnet 5.5 (model id claude-sonnet-5-5); 0.14.2 by Claude Opus 5.5 (model id claude-opus-5-5).

### Files changed
M `tools/check_project.py`, M `CHANGELOG.md`, M `DEVELOPMENT.md`, M `HANDOFF.md`, M `AGENTS.md`, M `project.godot`, M `README.md`.

### Checks performed
`python3 -I tools/check_project.py`: PASSED; also confirmed it FAILS on a copy whose newest Author line lacks "model id".

### Decisions proposed (not approved)
The exact wording and the "(human)" marker for people are proposals.

### Known issues and open items
None new.

### Next action
User playtest of 0.14.2 (this version plays the same). Then 0.15.0 (fans).

## 0.14.2 - 2026-11-13 - Click fix, grab the hose, rounder see-through hose, softer knocks
- Author: Claude (Opus 5.5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.14.1
- Type: patch (fixes from the user's play of 0.14.1, plus hose handling)

### Execution status
**Godot was NOT run by me directly.** New this version: `tools/playtest_bench.gd`, a scripted playtest that drives the real bench (scripted pointer, real mouse events) on Godot 4.7.2 in GitHub Actions and prints a table. Its findings are below. Results of the regression run are recorded below once it has finished. Nothing has been seen in a window.

Actions result (Godot 4.7.2 headless, run 43325348290, branch feature-0.14.2): Data schema checks 172, failures 0; Regression checks 422, failures 0 (including 80 real left clicks at 8 angles, all using the held tool). The scripted playtest table also shows every click using the held tool, the vacuum working at every angle, and the bin now filling a little later because dust is still riding the hose. Earlier runs on this branch failed 2 checks (the hose still folded to 87 degrees while being whipped around; my grab test pulled further than the hose allows) and were fixed.

### Added / Changed / Fixed / Removed
- Fixed (confirmed by the scripted playtest): with a tool in hand, a left click could pick up the resting tool lying next to it instead of using the held tool. The held tool shoves resting tools right up against itself, and the old pickup box (unturned, 60 x 84) of the neighbour then covered the cursor. It happened in 19 of 80 tested angle/position combinations, and which ones depended on the tool's angle. This is the most likely cause of "the brush only works when tilted the right way" and "the vacuum stopped working once I rotated it". Now a left click with a tool in hand always uses it; picking up by click works with empty hands, and the pickup box turns with the tool.
- Playtest findings that did NOT show a fault: with the scripted strokes, the brush tossed dust at every angle (8 angles x 2 stroke directions x 6 parts), and the vacuum cleaned every part equally at every angle. The vacuum cannot reach the top 40 px of the bench (the tool body is kept on the table); no dust zone is there.
- Added: right-drag the hose to move it out of the way. A tool in hand is put down first. The bin side of the hose cannot be stretched by hand; pulling the vacuum side drags a resting vacuum along.
- Changed: the hose curves round pieces. A bending limit (no joint folds past about 52 degrees at rest) and obstacles with rounded corners (up to 20 px). A Python copy of the hose showed the bending limit and obstacles keep nudging each other for ever (creep of up to 70 px per half second) unless there are 20 solver iterations and the hose comes to rest once nothing has moved it for 30 steps; both are in.
- Changed: the hose is drawn as a see-through tube through a smooth curve (8 px, rims, ribs, highlight). Swallowed dust is visible riding inside it to the bin.
- Changed: swallowed dust now fills the bin when it ARRIVES (0.7 s trip at full suction). With the suction off it waits in the hose; with the bin full it waits at the bin end. Cleaning progress still counts the moment dust is swallowed. `scripts/bench/hose_flow.gd`.
- Changed: tools knock each other less. Bounce 0.35 -> 0.12, spin from sliding 0.004 -> 0.0015 (max 4 rad/s), and a piece shoved by a held piece moves at most 200 px/s.
- Added: `scripted_pointer` and `_pointer()` in `bench_view.gd` (only the playtest sets it).
- Added tests: rounded corners, no sharp folds, bending limit adds no wriggle, hose grab/follow/limit/release, dust riding the hose (delay, waits without suction, full bin), shove speed cap, and 80 real left clicks at 8 angles that must all use the held tool.
- CI: the playtest runs as its own step with a 300 s timeout and a watchdog; it never fails the build.

### Files changed
`scripts/bench/hose_sim.gd`, `scripts/bench/hose_flow.gd` (new), `scripts/bench/tool_rig.gd`, `scripts/bench/piece_collision.gd`, `scripts/view/bench_view.gd`, `scripts/view/tool_renderer.gd`, `tools/playtest_bench.gd` (new), `tools/test_regressions.gd`, `.github/workflows/tests.yml`, `project.godot`, `README.md`, `HANDOFF.md`, `DEVELOPMENT.md`, `CHANGELOG.md`.

### Checks performed
`python3 -I tools/check_project.py` (no Godot); hose bending limit, rounded obstacles and resting simulated in Python before writing the GDScript (sweeps over obstacle positions, end positions and both hose lengths). Godot checks via Actions: see Execution status.

### Decisions proposed (not approved)
Right mouse to grab the hose; left click never swaps tools while one is held; hose width 8 px and see-through look; 0.7 s trip through the hose; 200 px/s shove cap.

### Known issues and open items
- "The hose itself doesn't work" was not specific enough to diagnose; this version makes the hose grabbable and shows dust travelling through it. Needs the user's description if something else was meant.
- "The brush only works on the component": not reproduced by the playtest; may have been the click bug.
- Tossed dust still stays on its own part (moving it across parts is planned with the fans in 0.15.0).

### Next action
User playtest of 0.14.2. Then 0.15.0 (fans).

## 0.14.1 - 2026-11-13 - Hose calm-down, rotation fixes, middle-mouse turning, clogged filter
- Author: Claude (Sonnet 5.5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.14.0
- Type: patch (fixes after the user's first play of 0.14.0, plus small features)

### Execution status
**Godot was NOT run by me directly.** Results of the GitHub Actions run on Godot 4.7.2 are recorded below once it has finished. Nothing has been seen in a window. The cause of "the vacuum stops working once rotated" is a hypothesis (see Known issues), not a confirmed diagnosis.

Actions result (Godot 4.7.2 headless, run 43317697722, branch feature-0.14.1): Data schema checks 172, failures 0; Regression checks 406, failures 0. Two earlier runs failed (zone schema did not know grip_scale; hose still wriggled) and were fixed.

### Added / Changed / Fixed / Removed
- Fixed (hypothesis): the hose could count as taut while merely bent around a piece, dragging the vacuum off the cursor after turning it. Now only a nearly straight hose (ends at least 90% of its length apart) tugs. The nozzle end of the hose is no longer pushed by obstacles.
- Fixed: the hose wriggled for a long time after moving. Cause found by reproducing the hose maths in Python: the bending-smoothing term pumped energy into a slack hose forever (it drifted 30 px per half second). Smoothing is now 0, damping is stronger, speeds are capped, and a calm hose stops completely.
- Changed: the hose is thinner (drawn 5 px instead of 8; obstacle radius 3).
- Fixed: bristle bend ignored the tool's rotation (the sweep speed is now turned into the brush's own frame).
- Added: middle mouse turns the held tool (wheel notches, or hold the middle button and drag sideways, 26 px per 15 degrees). Q/E still work. `ToolRig.rotate_steps`.
- Added: the filter's dust grips 1.5 times harder (`grip_scale` on the `front_filter` zone), so the clogged filter is a deliberate time cost.
- Added: parts still fitted in the PC (cooler, GPU) are obstacles the hose lies around. Parts lying on the bench already were.
- Added tests: rotated vacuum keeps the nozzle on the cursor (7 angles, pieces around), a calm hose stops moving, the filter grip.

### Files changed
`scripts/bench/hose_sim.gd`, `scripts/bench/tool_rig.gd`, `scripts/bench/dust_sim.gd`, `scripts/data/dust_zones.gd`, `scripts/view/bench_view.gd`, `scripts/view/tool_renderer.gd`, `tools/test_regressions.gd`, `project.godot`, `README.md`, `HANDOFF.md`, `CHANGELOG.md`.

### Checks performed
`python3 -I tools/check_project.py` (no Godot). Godot checks via Actions: see Execution status.

### Decisions proposed (not approved)
Filter grip 1.5x, hose thickness, 26 px per turn step, wheel direction (wheel up turns anticlockwise) are proposals. Whether installed parts should also physically block the vacuum body is not decided.

### Known issues and open items
- Cause of the vacuum/brush stopping after rotation not reproduced; if it still happens, note the angle and what the status line says.
- "Components do not interact with the vacuum": the vacuum already shoves parts lying on the bench; fitted parts only affect the hose. Needs clarification of what is expected.
- Tool pickup boxes still ignore rotation.

### Next action
User playtest of 0.14.1. Then 0.15.0 (fans swirl dust, dust can slip under cooler/GPU).

## 0.14.0 - 2026-11-12 - Piece physics, hose tug and longer-hose upgrade
- Author: Claude (Sonnet 5.5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.13.0
- Type: minor (new features: collisions between pieces, hose obstacles and tug, a shop upgrade)

### Execution status
**Godot was NOT run by me directly.** Results of the GitHub Actions run on Godot 4.7.2 for this version are recorded below once it has finished. Nothing has been seen in a window.

Actions result (Godot 4.7.2 headless, run 43314496463, branch feature-0.14.0): Data schema checks 172, failures 0; Regression checks 397, failures 0. A first run failed 2 checks (hose tug woke a resting thrown vacuum; stretch test too loose); fixed by a 4px slack deadband, pull-back past full length, 4% stretch limit and 14 hose iterations. Game feel is still untested by me.

### Added / Changed / Fixed / Removed
- **Piece physics (option B: rotated boxes):** tools and loose parts lying on the bench are solid boxes (`scripts/bench/piece_collision.gd`, a pure function on dictionaries). Overlaps are pushed apart, speed is passed on with some bounce, and sliding gives a little spin. A held tool or a dragged part is never pushed but shoves everything else; resting pieces wake up when shoved and slide to a stop. Pieces hopping higher than 16 px fly over others. Masses (proposals): vacuum 3.0, GPU 2.5, cooler 2.0, brush 0.6, pick 0.4, syringe 0.4, cloth 0.3. Parts sitting snapped in the service tray get a physics body only when shoved. Tools collide with a smaller box (40 x 68 px) than their click box.
- **Hose goes around pieces:** the hose is no longer pinned to the vacuum. Its end is drawn toward the vacuum by a spring, solid pieces (except the vacuum) push hose points out of them, and the fixed end stays on the bin (option a, as chosen).
- **Soft tug (as chosen):** when the hose is taut it cannot follow, and the gap drags the vacuum back toward the bin; the hose can stretch at most 4% past its length. This also reels in a thrown or resting vacuum that ends up out of reach. Base hose length is 640 px (reaches every part of the PC from the bin; around obstacles it reaches less).
- **Longer hose upgrade (option d):** a new shop upgrade, "Buy longer vacuum hose ($40, demo price)", makes the hose 860 px. Saved with the other upgrades.
- Shop screen: the buttons were rearranged to make room (New game moved down, the note moved down).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/piece_collision.gd` | A | box collisions |
| `scripts/bench/hose_sim.gd` | M | free end with spring, obstacles, tug, variable length |
| `scripts/bench/tool_rig.gd` | M | collision pieces, apply collisions, hose tug, long-hose switch |
| `scripts/view/bench_view.gd` | M | runs piece collisions each step, part pieces, long-hose on entry |
| `scripts/state/game_state.gd` | M | `long_hose` upgrade price |
| `scripts/view/shop_view.gd` | M | upgrade button and layout |
| `tools/test_regressions.gd` | M | tests for collisions, hose obstacles, tug and the upgrade |
| `README.md`, `DEVELOPMENT.md`, `HANDOFF.md`, `project.godot`, `CHANGELOG.md` | M | docs and version 0.14.0 |

### Checks performed
- `python3 -I tools/check_project.py`: passed.
- Not performed: any play in a window.

### Decisions proposed (not approved)
- Masses, bounce (0.35), the 4% stretch limit, hose lengths (640 / 860) and the upgrade price ($40) are proposals.
- Installed parts are not obstacles: the hose lies over the PC itself.

### Known issues and open items
- A taut hose does not push pieces (only the vacuum is tugged).
- Tool pickup boxes still ignore rotation.
- The hardware bench (`workshop_view.gd`) pieces have their own, separate physics and do not use the new collisions.

### Next action
Play the bench: shove tools and parts around, drag the vacuum to the far corners, and report the feel. Then 0.15.0: fans swirl unsettled dust, and dust can slip under the cooler and GPU.

## 0.13.0 - 2026-11-12 - Dust tossing, bounds, vacuum hose and dust bin
- Author: Claude (Sonnet 5.5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.12.3
- Type: minor (new features: dust tossing and shedding, floating dust, vacuum hose, dust bin)

### Execution status
**Godot was NOT run by me directly. GitHub Actions ran the automated checks on Godot 4.7.2.stable.official (headless), run 43311306498 on branch `feature-0.13.0`: `Data schema checks: 172, failures: 0` and `Regression checks: 381, failures: 0`** (the suite grew from 344 to 381 checks for this version). The only warnings in the log are the two deliberate save-recovery lines. Not covered: anything seen in a window (looks, feel, mouse and keyboard play, how the hose and bin look), and the hardware bench clamp in `workshop_view.gd`.

### Added / Changed / Fixed / Removed
- **Brush tosses dust instead of removing it (interpretation: "displace and toss around"):** when a bundle's grip is loosened enough, the stroke sets it sliding and spinning along the stroke. It is kept inside its own part's dust area (the area moves and turns with the part), bounces off the area's edges, then settles and grips again at 75% of normal, so brushing again can toss it again. The brush removes nothing. A tossed bundle is not pulled by the vacuum until it settles (about one second at most).
- **Brushed chains drop smaller dust:** a touched chain of 3 or more nodes sometimes chips its free end off as a separate speck (about 1.4 chances per second at full brush speed). The weight moves with it, so each part's dust total and cleaning progress do not change. Cap: 420 bundles in total.
- **Floating dust:** cosmetic motes drift above dusty spots, burst up where dust is tossed or shed, and are drawn into the vacuum nozzle. They are never counted anywhere.
- **Tools cannot leave the bench:** a held tool follows the cursor but its position is clamped to the bench (taking its turned size into account). Before, the tool stayed behind and was not drawn while the cursor was outside the bench, so it seemed to vanish. The same clamp now applies to a part being dragged in Move parts mode, and a drawer part held on the hardware bench is kept inside the window. Thrown tools and parts were already bounded by their physics.
- **Vacuum hose:** a 24-point rope with fixed-length links, anchored to the dust bin and pinned to the vacuum. It swings and trails when the vacuum moves or is thrown. It does not limit how far the vacuum can go (its length, 736 px, covers the whole bench).
- **Dust bin (a first version of dust management):** the vacuum's dust fills the bin (capacity 90 dust units; a dirty PC holds about 290, so expect three or so empties). When it is full the vacuum stops pulling and the status line says so. Click the bin (bottom right of the bench) to empty it. The bin level is not saved: leaving the bench empties it. Capacity and the instant, free emptying are proposals.
- A loose bundle that is released mid-flight still vanishes without counting toward the bin (existing behaviour, unchanged).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/dust_sim.gd` | M | TOSSED state, toss/shed, confining zone areas, swallowed count, kicked positions |
| `scripts/bench/hose_sim.gd` | A | vacuum hose rope |
| `scripts/bench/dust_bin.gd` | A | dust bin rules and position |
| `scripts/bench/dust_motes.gd` | A | floating dust |
| `scripts/bench/tool_rig.gd` | M | keep_inside clamp, hose |
| `scripts/bench/service_access.gd` | M | dragged part clamped to the bench |
| `scripts/view/tool_renderer.gd` | M | tool no longer hidden outside the bench; hose drawing |
| `scripts/view/cleaning_renderer.gd` | M | tossed dust colour, motes, bin drawing |
| `scripts/view/bench_view.gd` | M | bin, motes, full-bin suction stop, click to empty |
| `scripts/view/workshop_view.gd` | M | held part kept inside the window |
| `tools/test_regressions.gd` | M | tests for tossing, shedding, bounds, hose, bin, motes |
| `README.md`, `DEVELOPMENT.md`, `HANDOFF.md`, `project.godot`, `CHANGELOG.md` | M | docs and version 0.13.0 |

### Checks performed
- `python3 -I tools/check_project.py`: passed.
- GitHub Actions on Godot 4.7.2: 172 schema and 381 regression checks, 0 failures (see Execution status).
- Not performed: any play in a window.

### Decisions proposed (not approved)
- Toss strength, friction, shed rate, bin capacity (90) and instant free emptying are all proposals.
- Dust stays inside its own part's area when tossed. Dust tossed out of the PC, or onto other parts, was avoided on purpose: it could land under an installed part and become unreachable.

### Known issues and open items
- The hardware bench clamp (`workshop_view.gd`) has no regression check: it needs a running scene.
- Tool pickup boxes still ignore rotation.
- The bin is not saved; it resets when you leave the bench.

### Next action
Run the checks on GitHub, then play the bench: brush a dusty fan, vacuum until the bin fills, empty it, and report what feels wrong.

## 0.12.3 - 2026-11-12 - First verified run on Godot 4.7.2
- Author: Claude (Sonnet 5.5) in a chat session, with the project now in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.12.2
- Type: patch (documentation and version only; no script or workflow change)

### Execution status
**Godot was run, by GitHub Actions, not by me directly.** The workflow ran on the merged-candidate branch of 0.12.2 (pull request #1, run 43307104479, event pull_request; the push run 43307071658 also passed) on Ubuntu with `Godot Engine v4.7.2.stable.official.ed1daf0bf`, headless. Results read from the log: `Data schema checks: 172, failures: 0` and `Regression checks: 344, failures: 0`. The hygiene checker and project import also ran. The log contains two `WARNING: Save file ...` lines, which are printed on purpose by the save-recovery test.

### Added / Changed / Fixed / Removed
- Recorded the 4.7.2 result in README, HANDOFF, `docs/CURRENT_STATE.md` and DEVELOPMENT.md. Earlier changelog entries keep their original wording (they were true when written).
- Repository note: the first upload to GitHub lacked the `docs`, `scenes`, `scripts` and `tools` folders (browser drag-and-drop dropped them), which made the first workflow run fail at its first step. Fixed by pull request #1 (0.12.2 content). GitHub access for Claude was set up afterwards.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | version 0.12.3 |
| `README.md`, `HANDOFF.md`, `docs/CURRENT_STATE.md`, `DEVELOPMENT.md` | M | 4.7.2 verification recorded |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- The GitHub Actions run described above (on 0.12.2).
- `python3 -I tools/check_project.py` on this version (result in the delivery message).
- Not performed: human play on 4.7.2. The tests run without a window, so they do not cover how the brush looks or feels, mouse dragging, or the Q/E keys.

### Decisions proposed (not approved)
None.

### Known issues and open items
- Human interactive validation on 4.7.2 is still pending.
- Workflow actions `actions/checkout@v4` and `actions/upload-artifact@v4` produce a Node.js 20 deprecation warning; harmless now, upgrade later.

### Next action
Play the repair bench on 4.7.2 (brush, paste wipe, Q/E) and report what feels wrong. Then continue the `bench_view.gd` split, one extraction per patch, with the Actions run after each.

## 0.12.2 - 2026-11-12 - Workflow finds the project folder
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.12.1
- Type: patch (workflow only; no game script changed)

### Execution status
**Godot was NOT run by me and this workflow change was not run.** The first GitHub run of 0.12.1 (user's log) failed at the first step: `tools/check_project.py` was not found in the checkout. Cause not confirmed; most likely the files were uploaded inside an extra folder or the `tools` folder was not uploaded. Nothing after that step has run yet.

### Added / Changed / Fixed / Removed
- `.github/workflows/tests.yml` now first looks for `project.godot` anywhere in the repository and uses that folder for every step. If none exists, or `tools/check_project.py` is missing, it stops with a plain message and lists what is there. Logs are written to the workspace root so they upload from any layout.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | project-folder discovery, `cd` in each step |
| `project.godot`, `README.md`, `HANDOFF.md`, `CHANGELOG.md` | M | version 0.12.2, this entry |

### Checks performed
- `python3 -I tools/check_project.py` (result in the delivery message).
- Not performed: any run of the workflow.

### Decisions proposed (not approved)
None.

### Known issues and open items
- Everything after the first step is still unproven: the Godot download, the import step, both test scripts.

### Next action
Replace `.github/workflows/tests.yml` in the repository with this version, open Actions and send the new log.

## 0.12.1 - 2026-11-12 - Automatic tests and data schema checks
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.12.0
- Type: patch (tooling and documentation only; no game script changed)

### Execution status
**Godot was NOT run by me, and the GitHub workflow was NOT run.** Both new files are unexecuted. I only confirmed that Godot 4.7.2 stable is published and that its release file address answers with a redirect, not an error. The first GitHub run is the first real test of everything, including `test_data_schemas.gd` and the 0.12.0 checks.

### Added / Changed / Fixed / Removed
- **Added `.github/workflows/tests.yml`.** On every push or pull request GitHub downloads Godot 4.7.2, runs the hygiene checker, the data schema checks and the regression suite, and keeps the logs. It fails if a summary line is missing, a check failed, or the log contains `SCRIPT ERROR` or `Parse Error`, because a script that fails to load could otherwise look like a pass.
- **Added `tools/test_data_schemas.gd`.** Checks components, service options, boards, connectors, case profiles and dust zones for exact keys and value types (an unexpected key is a failure, to catch typos), plus consistency: board fits in the case, parts inside the case, connectors on usable board cells, unique ids, rotations 0-3, `covered_by` pointing at a real zone. It also proves the validator can fail by feeding it a deliberately broken dictionary.
- Docs: README, DEVELOPMENT.md (file map, new Automated tests section, queued bench split).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | A | automatic test run |
| `tools/test_data_schemas.gd` | A | data schema checks |
| `DEVELOPMENT.md`, `README.md`, `HANDOFF.md`, `project.godot`, `CHANGELOG.md` | M | docs and version 0.12.1 |

### Checks performed
- `python3 -I tools/check_project.py` (result in the delivery message).
- Manual read-through of the board rows and connector positions against the checks in `test_data_schemas.gd`: all connectors lie on `#` cells in both profiles; the board, fan, PSU and filter lie inside both cases.
- Not performed: any run in Godot, any run of the workflow.

### Decisions proposed (not approved)
None.

### Known issues and open items
- If the schema checks fail on first run, the data or the check may be wrong; read the label first.
- The log grep (`SCRIPT ERROR|Parse Error`) might trip on a message the save-recovery test prints on purpose. If so, narrow the grep.

### Next action
Put the project on GitHub (or push this version), open the Actions tab, read the first result and send it to me. Then continue the `bench_view.gd` split, one extraction per patch.

## 0.12.0 - 2026-11-12 - Working brush, CPU-only paste gauge, tool rotation
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.11.3
- Type: minor (new feature: tool rotation; plus two behaviour fixes)

### Execution status
**Godot was NOT run by me.** Nothing here has been executed in any Godot version. The new regression checks are written but unrun. Run `godot --headless --path . --script res://tools/test_regressions.gd` on 4.7.2 and report failures with file and line.

### Added / Changed / Fixed / Removed
- **Brush now visibly works (interpretation, please confirm).** Before, the brush only lowered a bundle's grip and never removed anything, so it looked dead unless you then vacuumed. Now a moving brush loosens a bundle, and once its grip is below 35% of normal the stroke flicks it off along the brushing direction; it flies a short way and vanishes. Brushing slower than a quarter of full speed only loosens. The vacuum still works and is still faster on stubborn dust. Touch distance widened from 8 to 12 px.
- **Paste gauge counts only paste on the CPU.** Squeezing or wiping paste beside the CPU no longer moves the gauge. `total_deposited` is now paste on the CPU cells only; wiping lowers it only by paste removed from CPU cells.
- **Rotate tools:** Q turns the held tool 15 degrees anticlockwise, E clockwise (hold to keep turning). The working tip stays on the cursor, and the brush bristle contacts follow the rotation. Each tool remembers its angle. Not held tools cannot be turned.
- Square cloth wiping area is not rotated (still an axis-aligned square); rotation is visual for the cloth.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/dust_sim.gd` | M | flick constants, `_step_stuck` flick, loose-bundle slowdown, touch distance 12 |
| `scripts/bench/paste_sim.gd` | M | `deposit` and `wipe` count CPU cells only for the gauge |
| `scripts/bench/tool_rig.gd` | M | `turns`, `TURN_STEP`, `rotate_held`, tip-correct follow target |
| `scripts/view/part_motion.gd` | M | optional `turn` argument to `step` |
| `scripts/view/bench_view.gd` | M | Q/E keys, hint text |
| `tools/test_regressions.gd` | M | checks for flick, gauge, rotation |
| `project.godot`, `README.md`, `HANDOFF.md`, `CHANGELOG.md` | M | version 0.12.0, this entry |

### Checks performed
- `python3 -I tools/check_project.py` (see result in the delivery message).
- Not performed: any run in Godot.

### Decisions proposed (not approved)
- Flick threshold 35%, flick speed 240 px/s, 15 degree turn step are proposals.

### Known issues and open items
- Brush feel (how fast dust comes off) is untested; tune `BRUSH_LOOSEN_RATE`, `FLICK_AT` in `dust_sim.gd`.
- Tool pickup hit boxes ignore rotation.

### Next action
Run the regression suite on 4.7.2, then try the brush on a dusty PC and Q/E on each tool.

## 0.11.3 - 2026-11-12 - Engine version restored to 4.7.2
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.11.2
- Type: patch (documentation and project metadata only; no script changes)

### Execution status
**Godot was NOT run by me.** No GDScript changed in this version. All earlier caveats stand: the 0.11.1 split and the 0.11.2 save changes have not been run in Godot by anyone, and Codex's 325 checks ran in 4.6.3, not 4.7.2.

### Added / Changed / Fixed / Removed
- **Reverted the 0.11.1 engine change.** The user first said 4.6.3, then confirmed the real engine is Godot 4.7.2. `config/features` in `project.godot` is "4.7" again, and every document and the checker text that I changed to 4.6.3 in 0.11.1 says 4.7.2 again.
- What is true now: the real engine is 4.7.2; the only engine any AI has run is 4.6.3 (Codex); so nothing has been verified on 4.7.2 yet. The earlier 0.11.1 statement that Codex's checks ran "on the real engine" was wrong.
- Added Correction notes inside the 0.11.1 and 0.11.2 entries instead of rewriting them. Everything else in those entries stands.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | version 0.11.3; `config/features` back to "4.7" |
| `AGENTS.md`, `README.md`, `HANDOFF.md`, `DEVELOPMENT.md`, `STABILISATION.md`, `docs/CURRENT_STATE.md`, `docs/PROJECT_BRIEF.md` | M | engine statements back to 4.7.2, version references |
| `tools/check_project.py` | M | message text says 4.7.2 |
| `CHANGELOG.md` | M | this entry and two Correction notes |

### Checks performed
- `python3 -I tools/check_project.py`: passed (version 0.11.3, required sections, 29 scripts scanned, `res://` references resolve, file map complete, five core documents present).
- `grep` over `project.godot`, `AGENTS.md`, `README.md` and `tools/check_project.py`: every engine statement says 4.7.2, and `config/features` is "4.7".
- Not performed: any run in Godot.

### Decisions proposed (not approved)
None.

### Known issues and open items
- Nothing has been run on Godot 4.7.2. If 4.7.2 behaves differently from 4.6.3, the regression suite is the first place to find out.

### Next action
On Godot 4.7.2 run `python3 -I tools/check_project.py`, then `godot --headless --path . --script res://tools/test_regressions.gd`, then click through the shop, repair bench and hardware bench, and report any red error text with file and line.

## 0.11.2 - 2026-11-12 - Safe save writing and recovery
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.11.1
- Type: patch (bug-risk fix: a crash or full disk while saving could destroy the save; no save format change)

### Execution status
**Godot was NOT run by me.** The new checks in `tools/test_regressions.gd` were written but never executed. Run the suite and report the result.

**Correction (0.11.3):** the claim below that the real engine is Godot 4.6.3 was wrong. The user later confirmed the real engine is **Godot 4.7.2**. Codex's checks ran in 4.6.3, which is not the user's engine. The rest of this entry is unchanged history.

### Added / Changed / Fixed / Removed
- `SaveStore.write` now writes `<save>.tmp`, reads it back to confirm it parses, moves the previous save to `<save>.bak`, then moves the new file into place. If any step fails the previous save is left in place and a warning is printed.
- `SaveStore.read` now falls back to `.bak`, then `.tmp`, when the main file is missing or damaged, with a warning saying so. If every copy is unreadable it returns null and the game starts a new game, as before for a missing save.
- Parsing uses `JSON.new().parse()` so a damaged file no longer prints an engine error.
- Seven new regression checks (`test_save_store`): empty read, write/read, no leftover temp file, `.bak` holds the previous save, recovery from a damaged main file, all-damaged returns null. The suite's cleanup also deletes `.bak`/`.tmp` of its test save.
- `.bak` is only the previous save, written on every save (autosave included). It is crash protection, not a long-term backup.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | version 0.11.2 |
| `scripts/state/save_store.gd` | M | safe write, fallback read |
| `tools/test_regressions.gd` | M | `test_save_store` and cleanup of `.bak`/`.tmp` |
| `docs/DESIGN_PROPOSALS.md` | M | notes from the reference footage the user supplied |
| `README.md`, `HANDOFF.md`, `DEVELOPMENT.md` | M | version, file map and save notes |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- `python3 -I tools/check_project.py`: passed (version 0.11.2, required sections, 29 scripts scanned, `res://` references resolve, file map complete, five core documents present).
- Python port of the `SaveStore` read/write logic run against a real temporary folder with the same sequence as the new regression checks plus a simulated crash (half-written temp file with an intact main save): all 9 assertions passed. This verifies the algorithm, not the GDScript or Godot's `DirAccess`/`FileAccess` behaviour.
- NOT performed: any run in Godot, the regression suite (including the 7 new checks), import or click-through.

### Decisions proposed (not approved)
Keeping one previous generation (`.bak`) is a proposal. A longer backup history (for example one per night) can come with the night loop.

### Known issues and open items
- Never run in Godot by this author; the new checks are unexecuted. On Windows `DirAccess.rename_absolute` may remove the target first, so the swap is safe against a failed write but not strictly atomic; the `.bak` fallback covers that window.
- `GameState.load_game()` still does not validate every field type inside a loaded save.

### Next action
Run the regression suite in Godot 4.6.3 and report any failing label. Then continue the bench split with the replacement panel.

## 0.11.1 - 2026-11-12 - Bench split step 1 and Godot 4.6.3 correction
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: user-supplied 0.11.0 ZIP (built by Codex).
- Type: patch (refactor with no intended behaviour change, plus documentation correction)

### Execution status
**Godot was NOT run by me** (the sandbox has none). I could not run `tools/test_regressions.gd`. The 325-check suite and the 0.11.0 behaviour were verified by Codex in Godot 4.6.3 on the unsplit code; this split has NOT been through that suite. First action for anyone with Godot: run the suite (command in README) and report failures.

**Correction (0.11.3):** the claim below that the real engine is Godot 4.6.3 was wrong. The user later confirmed the real engine is **Godot 4.7.2**. Codex's checks ran in 4.6.3, which is not the user's engine. The rest of this entry is unchanged history.

### Added / Changed / Fixed / Removed
- **Engine version corrected:** the user confirmed on 2026-11-12 that the real engine is Godot 4.6.3, not 4.7.2. README, HANDOFF, DEVELOPMENT, STABILISATION, CURRENT_STATE, PROJECT_BRIEF, AGENTS and the checker text now say 4.6.3, and `config/features` in `project.godot` is "4.6" (was "4.7"). Older changelog entries and per-version notes that mention a 4.7.2 target are history; they were wrong, not rewritten. Consequence: Codex's automated checks ran on the real engine; only human playtesting is pending.
- **Split of `bench_view.gd` (991 to 841 lines), step 1:** moved the paste drawing into `paste_renderer.gd`, the dust and cleaning-panel drawing into `cleaning_renderer.gd`, the mounting pressure session into `mount_session.gd` (no input, no drawing), and shared text/bar helpers into `ui_style.gd`. Code was moved, not rewritten; the numbers are unchanged. `bench_view.gd` keeps every member name the regression suite uses.
- **Save I/O split out of `game_state.gd`:** `save_store.gd` holds reading and writing the JSON file with the same behaviour as before.
- Not extracted yet, deliberately: the replacement panel (the suite touches its members directly), service-part dragging, and the input handler. One extraction per patch, retested each time, as STABILISATION.md asks.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | version 0.11.1; `config/features` 4.7 to 4.6 |
| `scripts/view/bench_view.gd` | M | delegates drawing/mounting to the new files; uses `mount.active`, `mount.pressure` |
| `scripts/view/ui_style.gd` | A | shared colours, `label`, `bar` |
| `scripts/view/paste_renderer.gd` | A | paste stage/panel drawing and paste picture |
| `scripts/view/cleaning_renderer.gd` | A | dust and cleaning panel drawing |
| `scripts/bench/mount_session.gd` | A | timed mounting session and its constants |
| `scripts/state/save_store.gd` | A | JSON save read/write |
| `scripts/state/game_state.gd` | M | uses `SaveStore` |
| `tools/check_project.py` | M | message text says 4.6.3 |
| `AGENTS.md`, `README.md`, `HANDOFF.md`, `DEVELOPMENT.md`, `STABILISATION.md`, `docs/CURRENT_STATE.md`, `docs/PROJECT_BRIEF.md` | M | engine version correction; file map, contracts and handoff version |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- `python3 -I tools/check_project.py`: passed (version agreement 0.11.1, required sections, 29 scripts scanned for tabs, brackets and `extends`, 85 `res://` references resolve, file map covers 47 files, five core documents present).
- Ad hoc static check (script not shipped): none of the names removed from `bench_view.gd` (`_paste_at`, `_legend_item`, paste/dust colour constants, mount constants, `mount_time_left`) is referenced anywhere outside the new files that define them, including `tools/test_regressions.gd`; every call to `UiStyle`, `PasteRenderer`, `CleaningRenderer` and `SaveStore` names an existing function with a matching number of arguments (0 problems).
- Read-through: moved functions were compared against the 0.11.0 text; the only intended differences are `mounting`/`pressure`/`mount_time_left` becoming `mount.active`/`mount.pressure`/`mount.time_left`, and `_step_mount` calling `MountSession.step` (same order: pressure, paste steps, time, then finish).
- NOT performed: any run in Godot, the regression suite, import, scene start-up or a click-through. GDScript syntax and type errors in the new files are therefore possible and unproven absent.

### Decisions proposed (not approved)
Next extractions in order: replacement panel as its own node with signals (and update the suite's direct member access), service-part dragging as a controller, then splitting input handling. Separate stage nodes or scenes for cleaning and paste can follow once these are done.

### Known issues and open items
- Not run through the regression suite or in Godot by this author.
- `bench_view.gd` is still 841 lines.
- Behaviour that was already open stays open: unsafe save writes (addressed next in 0.11.2), full damaged-save validation, human playtest.

### Next action
Run `python3 -I tools/check_project.py`, then `godot --headless --path . --script res://tools/test_regressions.gd`, then open the project in Godot 4.6.3 and click through the shop, repair bench (both stages, mounting) and hardware bench. Report red error text with file and line.

## 0.11.0 - 2026-11-12 - Tabletop throws, flexible brush and shared replacement stock
- Author: Codex in ChatGPT workspace; source ZIP, no GitHub push.
- Based on:0.10.0.
- Type: minor (shared stock/save contracts, physical tabletop motion and repair-tool rig).

### Execution status
Executed Godot4.6.3 regression/import/scene startup and native GUI checks. Target4.7.2 is unavailable; complete human repair/payment playthrough not performed. Fresh-ticket dust absence was not reproduced; do not claim a proven original root cause.

### Added / Changed / Fixed / Removed
Shared TableBody dynamics: momentum/spin, edge reflection, separate vertical hop/gravity/floor bounce, friction/rest and rotated-extent fit checks. Hardware flick-release throws, Shift-release precisely places, flight reserves committed cells and settlement chooses nearest free grid space with recovery/exit handling. Repair-tool rig gives vacuum/brush/pick/cloth/syringe damped follow, physical shapes, shadows and right-drag toss/recovery. Replaced circular brush drawing/contact with13 bending bristles; actual tips loosen dust after broad-phase/access checks. Added service GPU/cooler spring pickup, tabletop throws, physical-position recovery, saved resting poses and rigid surface-dust transforms. Fixed edge reflection to use captured collision side rather than exact float equality; fixed topmost tool hit order and hidden-stage tool click filtering. No measured FPS claim.
Player inventory now persists one unique owned stock list and one shared layout. Hardware and replacement UI use the same records. Buy adds stock only with funds/space; fit consumes an available owned UID once without a second charge and keeps customer originals separate. Installed hardware stock is unavailable for fitting. Old snapshots migrate once; empty stock never respawns. Existing replacement prices, payout and cloth price unchanged. Six initial demo items are a trial allowance, not a final catalogue. Fixed cooler drawing/labels which initially inherited GPU appearance.
Fresh jobs explicitly initialise all dust fractions0. Added brighter dust and ticket/visible-count status. New dirty PC starts a new practice ticket preserving money/stock/upgrades; stale scene save guard protects its dust. Cleaned saved PCs still stay clean. Full intake/customer storage remains unimplemented. Updated five core docs to1.6 and contributor contracts.

### Files changed
- M: CHANGELOG.md
- M: DEVELOPMENT.md
- M: HANDOFF.md
- M: README.md
- M: STABILISATION.md
- M: docs/CURRENT_STATE.md
- M: docs/DECISIONS.md
- M: docs/DESIGN.md
- M: docs/PROJECT_BRIEF.md
- M: docs/ROADMAP.md
- M: project.godot
- A: scripts/bench/brush_shape.gd
- M: scripts/bench/dust_sim.gd
- M: scripts/bench/grid_inventory.gd
- A: scripts/bench/table_body.gd
- A: scripts/bench/tool_rig.gd
- M: scripts/data/service_parts.gd
- M: scripts/state/game_state.gd
- M: scripts/view/bench_view.gd
- M: scripts/view/pc_renderer.gd
- A: scripts/view/tool_renderer.gd
- M: scripts/view/workshop_view.gd
- M: tools/test_regressions.gd

### Checks performed
- Godot4.6.3 regression suite:325 checks, zero failures. Existing repair/paste/access/payment cases retained; changed purchase/fit assertions reflect explicit buying then owned-stock consumption.
- Added edge velocity reversal, floor bounce/rest, rotated containment at30/60/144Hz, large GPU boundary fit, all five tools' toss/recovery, bristle deformation/relaxation and contact-based loosening, topmost/visible tool pickup and paste-rack pickup, stock costs/UID conservation/ownership/installed exclusion/full-empty inventory, legacy migration, fresh/partial/new-ticket dust and stale save protection, service toss/recovery/refit, hardware throw/resnap/rotation/conservation.
- GUI observed dust immediately on opening and on a new ticket without Reset; physical brush use/drop; stock purchase appearing in the same hardware drawer; corrected cooler shapes and readable replacement menu. Quantitative bounce/settlement was checked by actual GDScript tests rather than a claimed human visual timing/FPS measurement.
- Editor import and all three10-frame headless scene startups passed in Godot4.6.3 with no reported script errors. GUI launched with dummy audio; no new sound claimed.
- Python consistency checker passed:24 GDScript files,73 resource references,42 mapped files and five core docs. Fresh extracted ZIP checker/regressions passed; final package repeats these after the cloth-rack pickup guard check.

### Decisions proposed (not approved)
Restitution0.60,floor rebound0.33,gravity950,tool/body shapes,13-bristle shape,fast-release threshold450 and friction values are trial tuning. Model is bounded2.5D/tabletop, not full3D or body-body collisions. Starter stock is a small demonstration allowance. No engine migration chosen. Broader particle physics and material-dependent collisions/audio remain open.

### Known issues and open items
No inter-object collision, throw-induced damage or persistent flight velocities. Free tools return to rack on re-entry. Full part catalogue/suppliers/customer PC storage and discovery/reputation/disclosure are not implemented. GPU downgrade remains specification metadata rather than a benchmark. New dirty PC replaces current practice work, not a customer queue. Atomic saves/full validation remain future work. Target4.7.2 and full human payment path unverified. Saved clean work is not automatically re-dirtied.

### Next action
User playtests toss versus precise placement, repair-tool contact and shared stock flow. If fresh dust still appears absent, report visible-group count/ticket status and whether it was a clean saved job; preserve save for diagnosis. Choose body-pair collision/material/audio feel or next shared-PC task afterwards. Include five docs and changelog in future handoffs.

## 0.10.0 - 2026-11-12 - Risky pick, substitutions and free inventory handling
- Author: Codex in ChatGPT workspace; manual ZIP, no GitHub push.
- Based on: 0.9.0.
- Type: minor (new pick/damage/replacement and free inventory interaction, additive saved fields).

### Execution status
Executed Godot4.6.3 regressions and native GUI checks. Target4.7.2 not available; complete human repair/payment session not performed. This single delivery includes the user's inventory follow-up while pick implementation was still underway.

### Added / Changed / Fixed / Removed
Pick key4: safe hover inspection, timed extraction under installed GPU/cooler, visible per-attempt damage risk. Damage persists, stops picking that part and blocks final check. Equivalent/budget replacements require damaged part in tray, charge once, fit and save tier; inferior functional parts can pass. Cooler downgrade changes thermal estimate; GPU quality is stored/reported only. Fresh paste required for replacement cooler. Shop reports downgrade notes on passing check too. Opaque replacement window fixes visual overlap.
Hardware sandbox: separate storage rules from installation. Three generic sample pieces,12x8 free drawer cells, rotated footprints, overlap/bounds checks, compatible socket highlights, gentle nonmodal rollback hints, Esc cancel. Damped pickup following/lift/shadow/sway/turning and soft settling; no rigid-body throw simulation. Per-profile arrangements/rotations/installations save. Added pure inventory controller and presentation motion helper. Fixed in-place rotation to use committed logical center rather than delayed animated position. Canonical installed snapshot cells avoid irrelevant coordinate drift. Sample stock is not the release catalogue; sandbox stays separate from repair-PC stock. Updated five core docs to1.5.

### Files changed
- M: CHANGELOG.md
- M: DEVELOPMENT.md
- M: HANDOFF.md
- M: README.md
- M: STABILISATION.md
- M: docs/CURRENT_STATE.md
- M: docs/DECISIONS.md
- M: docs/DESIGN.md
- M: docs/PROJECT_BRIEF.md
- M: docs/ROADMAP.md
- M: project.godot
- A: scripts/bench/dust_pick.gd
- M: scripts/bench/dust_sim.gd
- A: scripts/bench/grid_inventory.gd
- M: scripts/data/component_data.gd
- A: scripts/data/service_parts.gd
- M: scripts/state/game_state.gd
- M: scripts/view/bench_view.gd
- A: scripts/view/part_motion.gd
- M: scripts/view/shop_view.gd
- M: scripts/view/workshop_view.gd
- M: tools/test_regressions.gd

### Checks performed
- Godot4.6.3 regression suite:246 checks, zero failures. Pick success/damage, attempt timing, broken-part payment gate, purchases/prices/insufficient funds/repeat rejection, degradation, cooler penalty, load validation and previous payment/dust/access checks retained.
- Grid checks include500 randomized rearrangements, bounds/overlap/conservation, installed slot occupancy, canonical save/load, cancelled/queued-event drops, in-place rotation, vertical GPU packing, profile/re-entry persistence. Presentation motion converges at30/60/144Hz in scripted simulation, not an FPS benchmark.
- Native GUI: safe inspection and successful trapped-dust extraction observed; replacement overlay readability corrected and verified. Hardware RAM moved to a new drawer location then rotated successfully, with neutral success feedback.
- Final editor import and all three ten-frame headless scene startups passed in Godot4.6.3 without script errors. GUI environment emits missing-audio-device/VSync driver warnings and falls back to dummy audio; no new game audio is claimed.
- Python consistency checker passed:20 GDScript files,52 resolved resource references,38 mapped files and five core docs. Fresh extracted ZIP checker passed and all246 GDScript regressions passed again.

### Decisions proposed (not approved)
Demo pick0.8s/12% risk, GPU equivalent/budget$40/$18, cooler$16/$7; budget65% specification/cooler+8C.12x8 drawer and motion parameters are playtest choices. Controlled tactile motion rather than full rigid-body inventory physics is provisional; no engine switch selected. Reference recording used to understand interaction only, no assets/code reused.

### Known issues and open items
No customer discovery/disclosure/relationship/reputation effects or full part stock/catalogue. GPU downgrade has no actual performance benchmark yet. Service pick/removal only GPU/cooler. Separate hardware sandbox does not modify the repair-PC's components. No pickup/drop sounds or throw/collision simulation. Atomic saves/full malformed-save validation still open; target4.7.2 and complete human repair payment unverified. No measured FPS improvement claim. Particle identities/paste picture not saved, only prior documented progress/result fields.

### Next action
User playtests pickup/rotation/snapping and risk versus safe disassembly. Then decide feel refinements and broader dust physics approach; integrate shared PC/owned stock in a separate task. Preserve five docs and logs in future handoffs.

## 0.9.0 - 2026-11-12 - Restrained vacuum, specks and service access
- Author: Codex in ChatGPT workspace; manual ZIP, no GitHub push.
- Based on: 0.8.0.
- Type: minor (new service removal/access and additive saved job fields).

### Execution status
Godot4.6.3 regression/GUI checks performed; target4.7.2 not available. Full human repair/payment session not performed. Broader physics redesign deferred by user.

### Added / Changed / Fixed / Removed
Removed redundant dedicated syringe button; paste tab still selects syringe and clears cloth mode. Base suction7.5->4, radius72->50, ramp0.12->0.2. Added independent specks and increased dust to51 bundles/34 specks. Added GPU/cooler drag-to-tray/refit, hidden dust underneath and tool blockers/path checks. Surface dust follows parts. Added saved removal state and reassembly gate for final check. Cooler removal invalidates old paste. Preserved payouts/prices. Cached blocker geometry, frame-driven redraw and time-based smoothing; fixed both benches' pickup/drop to use mouse event positions. Core docs1.4 bundled.

### Files changed
- M: CHANGELOG.md
- M: DEVELOPMENT.md
- M: HANDOFF.md
- M: README.md
- M: STABILISATION.md
- M: docs/CURRENT_STATE.md
- M: docs/DECISIONS.md
- M: docs/DESIGN.md
- M: docs/PROJECT_BRIEF.md
- M: docs/ROADMAP.md
- M: project.godot
- M: scripts/bench/dust_sim.gd
- A: scripts/bench/service_access.gd
- M: scripts/data/dust_zones.gd
- M: scripts/state/game_state.gd
- M: scripts/view/bench_view.gd
- M: scripts/view/pc_renderer.gd
- M: scripts/view/workshop_view.gd
- M: tools/test_regressions.gd


### Checks performed
- Godot4.6.3 GDScript regressions:96 checks, zero failures. Includes old persistence/payment cases plus specks/access/part removal/refit/invalid drops/queued mouse event positions and removed-state saves.
- Unobstructed scripted vacuum timing20.45s; previous same-model0.8.0 benchmark8.20s. Does not measure human play or removal time.
- GUI GPU dragged to tray, exposed underlying dust visible, GPU refitted to original slot. Single paste selection control checked by code/UI tree regression; no separate syringe button created.
- Final three-scene headless startup checks: all exited0 without reported errors.
- Python consistency checker passed; fresh extracted ZIP consistency/regression checks passed.

### Decisions proposed (not approved)
Counts, suction rates, exact tray geometry and simplified access boundaries are tuning. Stronger late-game vacuum direction noted but no upgrade purchase added. Broad physics model deliberately unchanged.

### Known issues and open items
Only GPU/cooler removable; no general parts inventory or case assembly. Exact particle identities not saved (zone fractions are). Target4.7.2 and full human payment path unverified. Loose-bundle lifetime and motion remain simplified. No measured FPS improvement claim. Old saves preserve legitimately clean progress.

### Next action
User tests weaker vacuum, specks and remove/clean/refit sequence; then discuss future physics representation. Preserve logs and five core docs in all future handoffs.

## 0.8.0 - 2026-11-12 - Shared PC grids, faster cleaning and tool/persistence fixes
- Author: Codex in ChatGPT workspace; manual ZIP delivery, no GitHub push.
- Based on: 0.7.2 (gameplay originally from Claude 0.7.1).
- Type: minor (new shared layout/height contract and preview models; bug fixes/tuning included).

### Execution status
Godot 4.6.3 headless and GUI checks performed. Target Godot 4.7.2 not available. No complete human repair/payment session; payout verified in isolated regression save.

### Added / Changed / Fixed / Removed
Shared PCLayout used by cleaning and hardware; components now on model grid rather than disconnected panels. Two explicit case/board previews fit uniformly into their display area; height and board validation added. Extracted PC drawing into PCRenderer. Cleaning reduced from 110 to 36 bundles; suction 2.5 to 7.5, radius 55 to 72, ramp 0.25 to 0.12. Fresh dust verified; genuine saved clean PCs preserved with clear notice. Paste stage selects syringe; explicit syringe button/key 3; redo deposit or effective wipe clears stale grade. Exact partial-bundle restore prevents reload progress gains. Existing monetary amounts and single-payout gate retained and tested. Improved numeric dust-field validation. Five core docs updated to 1.3.

### Files changed
- M: CHANGELOG.md
- M: DEVELOPMENT.md
- M: HANDOFF.md
- M: README.md
- M: STABILISATION.md
- M: docs/CURRENT_STATE.md
- M: docs/DECISIONS.md
- M: docs/DESIGN.md
- M: docs/PROJECT_BRIEF.md
- M: docs/ROADMAP.md
- M: project.godot
- M: scripts/bench/dust_sim.gd
- M: scripts/data/component_data.gd
- M: scripts/data/dust_zones.gd
- A: scripts/data/pc_layout.gd
- A: scripts/rules/layout_rules.gd
- M: scripts/rules/placement_rules.gd
- M: scripts/state/game_state.gd
- M: scripts/view/bench_view.gd
- A: scripts/view/pc_renderer.gd
- M: scripts/view/workshop_view.gd
- A: tools/test_regressions.gd

### Checks performed
- Godot 4.6.3 engine regression suite: 71 checks, zero failures. Includes initial dust, 20 reloads per sample fraction, board/case geometry at three display sizes, type/rotation/cutout/occupancy/depth validation, actual bench stage/tool state, saved-paste invalidation, payout once/reload and upgrade money/persistence.
- Scripted GDScript vacuum sweep: 8.20 s over all 36 bundles. Ideal pointer motion, not a human-time estimate.
- GUI: fresh bench visibly dusty without Reset; syringe visible after cloth then Apply paste; valid RAM dragged/snapped into slot; tower and compact previews observed. Visual inspection caught overlapping progress labels and prompted spacing corrections.
- Final scene smoke checks in Godot 4.6.3: all three scenes exited 0 without reported errors.
- Python checker and fresh extraction passed; regression suite also rerun from the fresh extracted archive.

### Decisions proposed (not approved)
All timing/dust density and demo model dimensions remain tuning. Display fitting preserves logical footprints; does not auto-enlarge incompatible cases/boards. Case profile buttons are previews. Full catalogue and persistent PC assembly not introduced.

### Known issues and open items
No target 4.7.2 run; exact paste picture not saved; RAM installation resets on scene/profile change; save writes not atomic; full schema validation pending. Saved clean machines intentionally remain dust-free. Clock/hub/economy expansion not built. Remaining bench UI/mount-session split still open.

### Next action
User imports separate 0.8.0 folder, verifies controls/cleaning pace and completes the repair once. Report any errors and actual editor version. Review persistent hardware state as a separate task; keep catalogue work with user.

## 0.7.2 - 2026-11-12 - Reconciled design and stabilisation baseline
- Author: Codex in ChatGPT workspace; no GitHub push.
- Based on: user-supplied 0.7.1 ZIP.
- Type: patch (documentation and application version metadata only).

### Execution status
Godot 4.6.3 headless import and three scene-start smoke checks run; target Godot 4.7.2 and interactive testing NOT run. Gameplay scripts/scenes unchanged from 0.7.1. This does not certify stability.

### Added / Changed / Fixed / Removed
Checker now rejects handoffs missing any of the five non-empty core documents. Included all five original documents, updated to document v1.2; reconciled daytime/continuous-night timing; incorporated recorded nested grids, height, parody brands, catalogue fields and hub direction without promoting proposals. Added stabilisation checklist and a proposed small-step bench refactor. Corrected current verification status; original changelog history is preserved.

### Files changed
- M: project.godot
- M: README.md
- M: HANDOFF.md
- M: AGENTS.md
- M: DEVELOPMENT.md
- M: docs/DESIGN_PROPOSALS.md
- M: CHANGELOG.md
- M: tools/check_project.py (require all five non-empty core documents)
- A: STABILISATION.md
- A: docs/PROJECT_BRIEF.md
- A: docs/DESIGN.md
- A: docs/ROADMAP.md
- A: docs/DECISIONS.md
- A: docs/CURRENT_STATE.md

### Checks performed
- Godot 4.6.3 headless editor import: exit 0, no reported script errors.
- Shop, repair bench and hardware bench: ten-frame headless startup each exited 0 without reported errors.
- Byte comparison against supplied ZIP: all 11 GDScript files and three scenes unchanged.
- Updated Python consistency checker: passed, zero problems; five core documents required.
- Negative guard check: a temporary copy missing DESIGN.md correctly failed.
- Fresh ZIP extraction: consistency checker passed (result verified during packaging).
- Target Godot 4.7.2, GUI input and save/reload playtest: not performed.

### Decisions proposed (not approved)
Bench split into cleaning presentation, paste presentation and mounting-session control is explained, not implemented. Exact hierarchy, catalogue format/condition placement, balance and save changes remain open.

### Known issues and open items
Partial persistence, dust reload rounding, possible stale paste grade, unvalidated save field types, RAM state not saved, target-editor tests pending. See STABILISATION.md. Original scripts have not been functionally changed.

### Next action
Target-editor manual test checklist, then bounded persistence bug-fix patch. Do not add catalogue/hub mechanics or broadly refactor as a side effect.

## 0.7.1 - 2026-11-12 - Handoff package, design proposals, shop button order
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.7.0
- Type: patch (documentation and one menu reorder; no rules, data or save changes)

### Execution status
**Godot was NOT run.** Only one code file changed: the order of buttons in `shop_view.gd`. Everything else
is documentation. The user asked mid-task to leave the parts catalogue for later, so none of it was started.

### Added / Changed
- `HANDOFF.md`: signed handoff with the project state, rules for every bot, step-by-step changelog update
  instructions, open tasks and the first thing to do on a machine with Godot.
- `AGENTS.md`: short pointer so any AI agent finds `HANDOFF.md` first.
- `docs/DESIGN_PROPOSALS.md`: records what was agreed in chat (night hub, limited time, carry-over tickets,
  Shop as a hub option, three nested grids, case fittings as grid items, the height number, catalogue
  fields, parody brands) and what is still open. Nothing in it is built.
- Shop screen: **Hardware bench** now comes before **Run final check**, as requested.
- `DEVELOPMENT.md` file map updated; README first line and ZIP name now say 0.7.1.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | version 0.7.1 |
| `scripts/view/shop_view.gd` | M | button order and labels (repair bench, hardware bench, final check) |
| `HANDOFF.md` | A | signed handoff and bot instructions |
| `AGENTS.md` | A | pointer for AI agents |
| `docs/DESIGN_PROPOSALS.md` | A | design notes, status-marked |
| `DEVELOPMENT.md` | M | file map |
| `README.md` | M | version, button order |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- `python3 -I tools/check_project.py`: passed (version agreement 0.7.1, required sections, 11 scripts scanned for tabs, brackets and `extends`, `res://` references resolve, file map covers all 23 files). It does not run Godot.
- Read back the shop button list in `shop_view.gd` after the edit: order is repair bench, hardware bench, final check, square cloth, new game.
- Not performed: any run in Godot.

### Decisions proposed (not approved)
See `docs/DESIGN_PROPOSALS.md`; each item is marked AGREED, PROPOSED or OPEN there.

### Known issues and open items
- Queued but not built: loose dust specks, mount-minigame redesign (matching squares), parts catalogue,
  night hub, ticket board, grid inventory.
- Untested in Godot: all code from 0.5.0 onward.

### Next action
The user works on the parts catalogue. Meanwhile, open the project in Godot 4.7.2, press F5, and report any
red error text.

## 0.7.0 - 2026-11-12 - Whole-PC dust bundles with a vacuum, timed mount minigame, square cloth upgrade
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.6.0
- Type: minor (new tools, new minigame, new upgrade, new data file, new job/save keys)

### Execution status
**Godot was NOT run** (the sandbox has none). Nothing here has been seen working in Godot. The dust-bundle
tuning and the paste-pressure tuning were done in separate Python models of the same maths; those models are not
the GDScript, so a typo or a different feel in Godot is possible. If anything errors, look first in `dust_sim.gd`
and `bench_view.gd`, which were rewritten.

### Added / Changed
- **Square cloth upgrade:** bought in the shop ($40, demo price; start cash $100, payout $60). `PasteSim.wipe` has a
  `square` flag using the larger of the x and y distances, so the cloth covers a 9 x 9 cell square (81 cells, about
  17% more than the round cloth's 69, and it reaches corners). Cursor outline is a square when owned. Stored in
  `GameState.upgrades` and saved; New game resets it.
- **Vacuum replaces the air blower.** It only pulls toward the nozzle; nothing is pushed away. Suction builds over
  0.25 s and fades with distance.
- **Dust is now bundles:** chains of 3 to 14 nodes anchored at one end, each with a grip that grows with length. Suction
  builds "pull" on a bundle; at pull = grip it comes free and is swallowed at the nozzle. Pull fades if you move
  away. Gripped bundles stretch toward the nozzle. Longest bundle about 2 s of full-suction holding.
- **Brush changed role:** it no longer removes anything; it lowers a bundle's grip (down to 20%), shown as a lighter
  colour, so vacuuming it afterwards is quicker.
- **Whole-PC cleaning:** six parts (case fan, CPU cooler, motherboard + RAM, graphics card, power supply, front dust
  filter), 110 bundles, defined in new `scripts/data/dust_zones.gd`. Each part has a percent bar and counts as clean at
  95% (the rest drops away). The cooler fan and the case fan each spin at an RPM tied to their own part (30 to 240).
  Dust progress is saved per part (autosave every 3 s while cleaning, and on leaving).
- **Final check:** dust penalty is now the sum over parts of `temp_penalty * (1 - removed)` (max 60 C), and the job
  fails unless every part is at least 95% clean, even if the temperature is low enough.
- **Timed mount minigame:** replaces the automatic 600-step spread. Hold the mouse over the socket (or Space) to raise
  pressure, release to lower it; pressure lowers the paste yield thickness (0.25 to 0.01), running 3 flow steps per
  tick. 10 s limit, Enter or Secure cooler ends early. Live bars: pressure, CPU covered (line at 95%), squeezed out
  (line at 20%), time. Squeezed-out paste shows orange live; bare CPU shows red only after mounting. Grade still from
  `evaluate()`.
- Save: additive keys `upgrades` and `job.dust`; SAVE_FORMAT stays 1. Old saves with `cleaned: true` load as only the
  cooler clean. `mark_cleaned()` removed (`set_dust()` replaces it).
- `PasteSim.MOUNT_STEPS` removed; `step()` takes an optional yield thickness.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | version 0.7.0 |
| `scripts/data/dust_zones.gd` | A | six dust zones, penalties, CLEAN_AT |
| `scripts/bench/dust_sim.gd` | M | rewritten: bundles, vacuum, brush loosening, per-zone progress |
| `scripts/bench/paste_sim.gd` | M | square wipe, `step(yield_h)`, `yield_for_pressure`, press constants, removed MOUNT_STEPS |
| `scripts/view/bench_view.gd` | M | rewritten: whole-PC view, tools, zone list, timed mount minigame, square cloth cursor |
| `scripts/state/game_state.gd` | M | upgrades, dust per part, new final check rules, save keys |
| `scripts/view/shop_view.gd` | M | parts-clean count, square cloth button |
| `DEVELOPMENT.md` | M | file map, data contracts, APIs |
| `README.md` | M | version, screens, controls |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- `python3 -I tools/check_project.py`: passed (version agreement, required sections, 11 scripts scanned for tabs, brackets and `extends`, 20 `res://` references resolve, file map complete). It does not run Godot.
- Python model of the bundle/vacuum system (`proto_bundles.py` in the session scratch folder, same constants, a scripted nearest-bundle player that never wastes movement): at PULL_RATE 2.5 the whole PC (110 bundles) cleared in about 80 s, shortest bundle 0.58 s and longest 2.07 s of full-suction holding. Whole-PC time is a best case; a human will be slower. This is a model, not the GDScript.
- Python model of the mount minigame (numpy, same flow equations): holding all 10 s gave coverage 100% / squeezed out 47% (MESSY); releasing at coverage >= 95% gave PERFECT (95% / 13%); releasing at 90% gave GOOD ENOUGH; a 1.5 s tap gave BALD SPOTS. Release up to about 0.4 s late still PERFECT, 0.6 s late MESSY.
- Cell count of the cloth shapes at radius 4.5 on the 51 x 51 grid: round 69 cells, square 81 cells (ratio 1.17).
- Not performed: any run in Godot; any test of keyboard/mouse input, drawing, save/load round trip, or the old-save migration.

### Decisions proposed (not approved)
- Zone list, bundle counts and per-part temperature penalties (total 60 C).
- Brush as a loosener only; vacuum as the only remover.
- Clean threshold 95% per part, and "every part must be clean" as a hard rule for the job.
- Square cloth price $40 and its 9 x 9 size; pressure rates (0.45 up, 0.9 down per second) and the 10 s limit.
- Fan RPM scale 30 to 240 for both fans.

### Known issues and open items
- Not run in Godot: feel, hold times and input handling are unverified in the real engine.
- A bundle flung loose while the nozzle is far away is removed after 1.5 s; this can look like it vanished.
- The mount minigame is easiest if you release as soon as covered passes the line; a human reaction delay of about
  0.4 s still reaches PERFECT in the model, 0.6 s late tends to MESSY.
- The "Reset all dust" button saves progress as zero immediately.
- `scenes/main.tscn` is still the legacy name of the hardware bench.

### Next action
Open in Godot 4.7.2, press F5, go through the shop, the repair bench (both stages) and the final check, and send any red
error text with its file and line. Then tune hold times and the paste pressure feel by playing.

## 0.6.0 - 2026-11-12 - Fan RPM matches the spin; paste wiped with a cloth
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.5.1
- Type: minor (new wipe-cloth tool; also fixes the fan readout)

### Execution status
**Godot was NOT run** (the sandbox has none). This release answers two things the user reported
after running the earlier versions: the fan's RPM text did not match how fast it spun, and the
"Wipe paste off" button seemed to just take you back to applying paste. The changes are in
`bench_view.gd` and `paste_sim.gd`; if the cooler bench errors, look there first.

### Fixed
- **Fan RPM:** the readout was a formula of dust removed (300 to 2200 RPM) while the blades turned at a
  separate, unrelated value (1.5 to 16 rad/s, which is only about 14 to 153 RPM), so the two never agreed.
  Now one smoothed value, `fan_rpm`, drives both: the blades turn at `fan_rpm * TAU / 60` radians per second
  and the readout shows `fan_rpm`.
- The range is now 30 RPM (clogged) to 240 RPM (clean). It is low on purpose: with 7 blades and 60
  updates per second, motion above about 250 RPM looks like it stutters or runs backwards. At 240 RPM the
  fan turns 24 degrees per update, under half the 51 degree blade spacing. Real PC fans run faster; a
  note on the screen says this is a demo scale.

### Added
- **Wipe with cloth:** a toggle button. Hold the left mouse button and rub over the paste; the cloth has a
  round reach, removes a share of paste per tick (strongest at its centre) and clears thin films completely.
  Works before and after mounting. If the cooler was already mounted, the grade is cleared as soon as you
  start wiping, since that paste no longer exists. The cursor becomes a cloth with a reach ring.
- **Clear all paste (instant):** the old reset behaviour, kept as its own button for quick retries.
- A hint appears if you try to squeeze more paste while the cooler is still mounted.
- `PasteSim.wipe(cx, cy, radius, strength) -> float` returns the amount removed and keeps `total_deposited`
  equal to the paste actually on the grid.

### Changed
- The paste panel reads "Paste on the CPU socket" (it was "Paste squeezed") because wiping lowers it.
- Mounting turns the cloth off. The saved-result message now points to Clear all paste.
- Fan panel text: "The blades turn at exactly this speed; dust slows them down" plus the demo-scale note.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | `config/version` 0.6.0 |
| `scripts/view/bench_view.gd` | M | `fan_rpm` replaces `fan_speed`; cloth tool, buttons, cursor, hints, panel text |
| `scripts/bench/paste_sim.gd` | M | added `wipe()` and its two constants |
| `README.md` | M | version, fan and wipe descriptions |
| `DEVELOPMENT.md` | M | PasteSim API line, constants location, bench file purpose |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- Python port of `paste_sim.gd` (`deposit`, `step`, `wipe`; a line-by-line copy, not Godot):
  - `total_deposited` equals the sum of the grid after deposit, spreading and wiping.
  - A cloth held still on a fresh 120-unit blob clears it in about 0.9 s at strength 0.12 (0.4 s at the
    first value tried, 0.25, which I judged too instant and lowered).
  - One 6-row sweep of the CPU at 300 px/s clears the CPU; a spread-out film needed a second pass for a few
    faint traces (0.85 units left of 120). The paste squeezed out past the CPU stays until wiped.
  - Wiping an empty grid removes nothing.
- Fan maths in Python: 30, 135 and 240 RPM each convert to a blade speed and back to the same RPM; 240 RPM is
  24 degrees per 60 Hz update, under half the 51.4 degree blade spacing, so no aliasing. The old build turned
  the blades at most 153 RPM while the readout said 2200.
- Read the edited `bench_view.gd` back around the new branches and the grep of every new name; no stale
  `fan_speed` or `_on_wipe_pressed` references remain.
- Ran `python3 -I tools/check_project.py`: passed with 0 problems (version 0.6.0 agrees across `project.godot`,
  the newest changelog entry and the README header; 10 `.gd` scripts have no tabs, balanced brackets and an
  `extends`; 16 `res://` references resolve; file map covers 19 files).
- Not performed: any run in Godot 4.7.2. Cloth feel, and whether the blades visibly match the readout on screen,
  are untested.

### Decisions proposed (not approved)
- Reading of the wipe report: I took "it just takes you back to apply thermal paste" to mean the wipe
  button behaved like an instant reset rather than a wipe. If you meant something else, say so.
- Fan scale 30 to 240 RPM, cloth reach 4.5 cells and cloth strength 0.12 are demo values to tune by feel.
  A realistic RPM range would need motion blur and is not done.

### Known issues and open items
- Carried over: dust and paste pictures are not saved, one ticket only, leaving the bench half-cleaned loses
  progress, GUI/UX deliberately plain.
- Wiping a spread-out film takes a second pass: one quick pass over the CPU leaves faint traces.
- Squeezed-out paste outside the CPU also has to be wiped if you want the socket clean; it does not block anything.

### Next action
Run it in Godot 4.7.2: watch the fan against its RPM readout, mount paste, then wipe it off. Report the feel.

## 0.5.1 - 2026-11-12 - Versioning and handoff documentation
- Author: Claude (Sonnet 5.5) in a chat session; no git repository was involved.
- Based on: 0.5.0
- Type: patch (versioning, documentation and tooling; one small player-visible addition, the version label)

### Execution status
**Godot was NOT run** (the sandbox has none). Nothing in 0.5.1 has been opened in Godot 4.7.2.
The version plumbing touches `project.godot`, `game_state.gd` and `shop_view.gd`, so if the
project fails to open or the shop screen errors, look there first. The user has run earlier
versions up to 0.4.0 (reported that cleaning and paste "don't feel bad"); 0.5.0 has not been
reported on yet.

### Added
- `config/version="0.5.1"` in `project.godot`: the single source of truth for the version.
- Version label at the bottom-left of the shop screen: "Nightshift foundation trial v0.5.1 | save format 1".
- `GameState.game_version()` (reads `config/version`) and `GameState.SAVE_FORMAT` (integer, currently 1).
- `DEVELOPMENT.md`: version scheme, logging rules, release checklist, architecture layers, file map,
  data contracts, GDScript conventions, verification rules and a handoff template for other contributors.
- `tools/check_project.py`: consistency checker (version agreement, required changelog sections,
  `res://` paths exist, no tabs, brackets balanced, file map complete). It does not run Godot.
- `tools/.gdignore` so Godot skips the `tools/` folder.
- CHANGELOG restructured: rules and template at the top, an Unreleased section, and per-entry
  author, base version, type, files changed and checks. Entries 0.1.0 to 0.5.0 were reconstructed
  with their file lists (see their notes).

### Changed
- Save file now stores `save_format` and `game_version` instead of `"version": 1`. Older saves still
  load (the reader falls back to the old key). A save from a newer format logs a warning and loads
  what it recognises. Saved data shape is otherwise unchanged, so `SAVE_FORMAT` stays 1.
- ZIP files are now named with the version, `nightshift_godot_trial_v0.5.1.zip`. The folder inside
  keeps the name `nightshift_godot_trial` so importing is unchanged.
- README: header version, new Versioning section, structure list updated, unzip step uses the versioned name.
- CHANGELOG: correction and addendum added to the 0.5.0 entry (see there).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | M | added `config/version` |
| `scripts/state/game_state.gd` | M | `SAVE_FORMAT`, `game_version()`, new save keys, format check on load |
| `scripts/view/shop_view.gd` | M | `version_label` |
| `DEVELOPMENT.md` | A | contributor guide |
| `tools/check_project.py` | A | consistency checker |
| `tools/.gdignore` | A | keeps Godot out of `tools/` |
| `CHANGELOG.md` | M | restructured, history reconstructed, this entry |
| `README.md` | M | version, versioning section, structure list |

### Checks performed
- Ran `python3 -I tools/check_project.py` on the finished project: passed with 0 problems (version
  0.5.1 agrees across `project.godot`, the newest changelog entry and the README header; 10 `.gd` scripts
  have no tabs, balanced brackets and an `extends` line; 16 `res://` references resolve; the file map in
  `DEVELOPMENT.md` covers all 19 tracked files).
- Negative test: on a scratch copy I injected five faults (version mismatch, a tab, an unclosed bracket,
  a broken `res://` path, a file missing from the file map). The checker reported all five. It also
  caught an unfilled placeholder in this entry before the results above were recorded.
- Found and fixed during that test: the checker's summary lines said "ok" even when a check had failed;
  they are now labelled "info".
- Reviewed the edits to `game_state.gd` and `shop_view.gd` by reading them back; no other check applies.
- Not performed: any run in Godot 4.7.2. The checker is a hygiene check, not a test of the game.

### Decisions proposed (not approved)
- The version scheme in `DEVELOPMENT.md` (0.MINOR.PATCH while a trial; 1.0.0 reserved for when you
  declare a real production build) and the rule that every delivered change gets a new number.
- Placing this project in `game/` of your repository, with the five design documents in `docs/`.
  This matches the layout proposed in PROJECT_BRIEF.md but has not been confirmed.

### Known issues and open items
- Carried over from 0.5.0 (below): dust and paste pictures are not saved, one ticket only, the
  half-cleaned cooler loses progress, GUI/UX deliberately plain.
- `scenes/main.tscn` is the hardware bench but keeps its original name; renaming it would touch the
  shop scene and README, so it is deferred and noted in `DEVELOPMENT.md`.
- No git history exists for this project. This changelog is the only record of 0.1.0 to 0.5.0.

### Next action
Run 0.5.0 or 0.5.1 in Godot 4.7.2 and report errors and feel. Then the next feature is the day/night
skeleton (Open/Close shop, pausable night clock, several tickets), as a 0.6.0 minor release.

## 0.5.0 - 2026-11-12 - Repair ticket, saving, clearer paste
- Author: Claude (Sonnet 5.5) in a chat session. Reconstructed entry: written from the build
  history on 2026-11-12; no git log existed.
- Based on: 0.4.0
- Type: minor (new game state, save/load and a new main screen)

### Execution status
**Godot was NOT run by me** (the sandbox has none). You ran v0.4.0 and reported the cleaning
and paste "don't feel bad" but the paste needs work and clearer visuals. Nothing in 0.5.0 has
been opened in Godot.

### Changed: paste clarity
- CPU is now dark blue and the paste light cyan to white (it was silver on grey), shaded by thickness
  with a dark rim on every paste edge so blobs and lines read clearly.
- Faint "aim here" crosshair at the CPU centre until paste is down.
- Live "CPU covered / squeezed out" readout and a progress bar while the cooler presses.
- After mounting, the cooler lifts and shows red = bare CPU cells, orange = squeezed-out paste, with a legend.
- The plate drawn over the socket is slightly more transparent so the spreading stays visible.
- Paste physics, numbers and grading are unchanged.

### Added: first game loop
- `GameState` autoload (`scripts/state/game_state.gd`): cash ($100 start), one ticket
  (overheating PC, placeholder customer), final check, auto-save/load to `user://nightshift_save.json`.
- New main screen `scenes/shop.tscn` with the ticket checklist, cash, final check and New game.
- Final check: 42 C base, +40 C if the cooler is not clean, plus a paste penalty
  (PERFECT 0, MESSY 3, GOOD ENOUGH 4, BALD SPOTS 18, TOO LITTLE 35, no paste 40). Passes under 75 C and pays $60 once.
  Cleaned + any paste except TOO LITTLE passes; a dusty cooler always fails.
- The bench saves "cleaned" and the paste grade; re-entering a cleaned cooler starts clean.
- Navigation: shop opens the cooler bench and the hardware bench; both have a way back.
- `project.godot`: main scene is now the shop; GameState registered as an autoload.

### Correction and addendum (added in 0.5.1)
- Correction: the original wording said the socket plate was "slightly lighter". In the code the plate
  fill is slightly more transparent (peak alpha 0.20, was 0.25) and its border slightly stronger (alpha 0.7, was 0.6).
- Changes found while reconstructing this entry that were not logged at the time: the status text
  panel on the cooler bench moved down to y=440 to make room for the live readout; "Back to workshop"
  became "Back to shop" (y=645) and now returns to the shop scene; the paste socket background is
  slightly darker; the "CPU heat spreader" label colour changed to suit the new CPU colour; the
  workshop screen's bench button was repurposed as "Back to shop".

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/state/game_state.gd` | A | cash, ticket, final check, save/load (autoload) |
| `scenes/shop.tscn` | A | main scene, uses `shop_view.gd` |
| `scripts/view/shop_view.gd` | A | shop screen: ticket checklist, cash, buttons |
| `project.godot` | M | main scene is `shop.tscn`; `GameState` autoload |
| `scripts/view/bench_view.gd` | M | rewritten: clearer paste visuals, live stats, saves progress via GameState |
| `scripts/bench/paste_sim.gd` | M | added `measure()`; `evaluate()` uses it |
| `scripts/bench/dust_sim.gd` | M | added `clear_all()` |
| `scripts/view/workshop_view.gd` | M | bench button became "Back to shop" |
| `README.md` | M | rewritten for the new screens |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- Bracket-balance check of every script.
- A Python check of the final-check temperature table (which paste grades pass or fail).
- The earlier line-by-line Python port of the paste rules (unchanged logic).
- Not performed: any run in Godot.

### Known issues and open items
- The dust and paste pictures are not saved; only "cleaned" and the paste grade are.
- One ticket only; no day/night, customers, parts consumption or timers. Ticket values are demo values.
- Leaving the bench half-cleaned loses that progress.
- GUI and UX are deliberately plain (planned for later).

## 0.4.0 - 2026-11-12 - Cooler bench: dust cleaning and thermal paste
- Author: Claude (Sonnet 5.5) in a chat session. Reconstructed entry (no git log existed).
- Based on: 0.3.0
- Type: minor (new bench screen and two simulations)

### Execution status
**Godot was NOT run.** The sandbox has no Godot, so no version of this project had been
opened, parsed or played in Godot 4.7.2 when this was written. The user later ran it and
reported it "doesn't feel bad", with paste needing work and clearer visuals (addressed in 0.5.0).

### Added
- `scenes/bench.tscn` and a button on the workshop screen to open it (and Back to return).
- Step 1, cleaning: 450 dust specks in clumps on a cooler with a spinning fan.
  - Air blower: strength ramps up over 0.3 s, falls off with distance, wears down each
    speck's grip (specks shake as they loosen), then blows loose specks away with drag and gravity.
  - Brush: small radius, effectiveness scales with how fast you drag.
  - Fan speed and an RPM readout recover as dust is removed; 95% counts as clean and leftovers drop off.
  - Air streak particles and a cursor ring show the tool's reach.
- Step 2, thermal paste: squeeze paste on a 51 x 51 grid (hold to build a blob, drag to draw lines),
  gauge with a "pea-sized" green zone, Mount cooler (paste spreads like thick paste: only cells above a
  yield thickness flow, thicker flows faster, so it stops as a thin film), then a grade:
  PERFECT / GOOD ENOUGH / MESSY / BALD SPOTS / TOO LITTLE from CPU coverage and overflow. Wipe to retry.

### Changed
- `workshop_view.gd`: bench button; hover card variable typed more strictly.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/bench/dust_sim.gd` | A | dust physics |
| `scripts/bench/paste_sim.gd` | A | paste spreading physics and grading |
| `scripts/view/bench_view.gd` | A | bench drawing, input, buttons |
| `scenes/bench.tscn` | A | bench scene |
| `scripts/view/workshop_view.gd` | M | bench button; `HoverCard` type |
| `README.md` | M | bench instructions |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- Dust physics and paste spreading were prototyped and tuned in Python (numpy), not in Godot.
- The paste rules were re-checked with a line-by-line Python port of `paste_sim.gd`
  (a pea of 120 units gives 97% coverage and 16% squeezed out; 60 units gives 76%; 200 units
  gives 100% and 30% squeezed out; total paste is conserved).
- A crude bracket-balance check of every script.
- Not performed: any run in Godot. Feel could not be judged until played.

### Decisions proposed (not approved)
Scoring follows common PC-building guidance found online: a thin even film is the goal, the single
"pea" dot is the standard method, too much paste is mostly a mess while too little causes hot spots,
and spreading by hand can trap air (not modelled). All numbers are demo values, not approved balance.

### Known issues and open items
- The bench is not tied to any PC or job; dust and paste results are not stored anywhere.
- No sound. No time pressure. Compressed-air can limits were left out on purpose.
- Paste is graded by coverage and overflow only (no thickness or air-bubble model).
- Brush and air numbers are untested by hand; the brush may need retuning.
- The paste step can be done without cleaning first (kept open so you can test each part).

## 0.3.0 - 2026-11-12 - Four-direction rotation
- Author: Claude (Sonnet 5.5) in a chat session. Reconstructed entry (no git log existed).
- Based on: 0.2.0
- Type: minor (rotation model changed from two states to four facings)

### Execution status
**Godot was NOT run.** The sandbox has no Godot. Treat as untested at the time of writing.

### Changed
- Rotation is now a facing: Up, Right, Down, Left (0-3), not two states.
- R rotates clockwise, Shift+R counter-clockwise. It works while dragging and also
  while hovering the part in the drawer. Right-click and mouse wheel still rotate while dragging.
  An installed part must be picked up before it can rotate.
- A black triangle on the part shows its facing. Rotation is restored if a drop is rejected.
- Connectors can list `allowed_rotations`. Demo values (not real hardware rules):
  R1 = Up, R2 = Up or Down, R3 = Right. New rejection message: "Wrong facing".
- Hover cards show the part's facing and the facings a slot needs; the legend lists them.
- `check_placement` and `hover_info.for_component` take an integer facing instead of a bool.
- Slot R3 renamed "RAM slot 3" (its facing now explains the orientation).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/data/component_data.gd` | M | `allowed_rotations` on RAM slots; R3 renamed |
| `scripts/rules/placement_rules.gd` | M | facings, direction names, `allowed_rotations`, "Wrong facing" |
| `scripts/rules/hover_info.gd` | M | facing lines; now preloads `placement_rules.gd` |
| `scripts/view/workshop_view.gd` | M | R / Shift+R / wheel rotation, facing marker, legend |
| `README.md` | M | controls and things to try |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- A Python script confirming board data is consistent. Not performed: any run in Godot.

### Known issues and open items
- The "slot already occupied" rule still cannot be triggered with a single part.
- Drop target is the cell under the pointer, not the part's corner.
- Hover cards appear immediately (no delay).

## 0.2.0 - 2026-11-12 - Rotation and hover cards
- Author: Claude (Sonnet 5.5) in a chat session. Reconstructed entry (no git log existed).
- Based on: 0.1.0
- Type: minor (rotation and hover cards)

### Execution status
**Godot was NOT run.** The sandbox has no Godot, so neither this version nor 0.1.0 had been
opened, parsed or played in Godot 4.7.2 when this was written.

### Added
- Rotation: R key or right-click while dragging turns the part a quarter turn
  (1x4 becomes 4x1). Rotation is kept when the part is installed and restored if a
  drop is rejected.
- New sideways RAM slot R3 (4x1) so rotation matters: upright RAM fits R1/R2,
  rotated RAM fits R3. A wrong-orientation drop explains how to fix it.
- Hover cards (fade in near the mouse): RAM (category, model, capacity, standard,
  speed, connector, size - placeholder values), each slot (accepted type, required
  size, free/occupied), the board (grid size, usable cells, connector count), cutouts.
  Hovered RAM or slot gets a white outline. Cards hide while dragging.
- `check_placement` now takes a `rotated` flag.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/data/component_data.gd` | M | RAM `details`; third RAM slot R3 |
| `scripts/rules/placement_rules.gd` | M | `rotated_footprint`, rotated flag, wrong-orientation message |
| `scripts/rules/hover_info.gd` | A | hover card text |
| `scripts/view/hover_card.gd` | A | fading hover card drawing |
| `scripts/view/workshop_view.gd` | M | rewritten: rotation and hover |
| `README.md` | M | controls |
| `CHANGELOG.md` | M | this entry |

### Checks performed
- A Python script confirming the board data is consistent (all connector cells on board cells,
  none overlapping). Not performed: any run in Godot.

### Known issues and open items
- The "slot already occupied" rule exists but cannot be triggered yet: there is only one
  part, and picking it up empties its slot. It needs a second part to test.
- Rotation is two states (upright/sideways), not four 90-degree directions (fixed in 0.3.0).
- The drop target is the cell under the mouse pointer, not the part's corner.
- Hover cards fade in immediately (no delay).

## 0.1.0 - 2026-11-12 - Foundation trial
- Author: Claude (Sonnet 5.5) in a chat session. Reconstructed entry (no git log existed).
- Based on: nothing (first version)
- Type: minor (initial project)

### Execution status
**Godot was NOT run.** The sandbox has no Godot. The only check was a Python script confirming
the board data was consistent.

### Added
- Project settings: 1280x720 window, Compatibility renderer, main scene `res://scenes/main.tscn` (F5 runs it).
- Workshop screen: labelled PC CASE, MOTHERBOARD and PARTS DRAWER, status panel, slot legend.
- One motherboard: 10x10 grid, L-shaped (top-right 4x4 block is a cutout), drawn cell by cell.
- Connectors: two DDR4_DIMM RAM slots (1x4), a CPU socket (3x3), a PCIe x16 slot (8x1).
- One RAM stick (DDR4_DIMM, 1x4 cells) in the drawer.
- Drag and drop with the left mouse button; green/red target highlight while dragging.
- Placement rules, checked in order: off grid, cutout, no connector, wrong connector type,
  footprint mismatch, slot occupied. Invalid drops return the RAM to where it came from
  and show a red explanation.
- Installed RAM can be picked up again and moved. Reset button.
- Board data validation at startup (warnings appear in Output if data is inconsistent).
- `.gitignore` for Godot's `.godot/` cache.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `project.godot` | A | settings, main scene |
| `.gitignore` | A | ignore `.godot/` and exports |
| `scenes/main.tscn` | A | workshop scene (later renamed in role to "hardware bench") |
| `scripts/data/component_data.gd` | A | RAM stick and demo board data |
| `scripts/rules/placement_rules.gd` | A | placement rules and board validation |
| `scripts/view/workshop_view.gd` | A | drawing, mouse input, status text |
| `README.md` | A | run instructions |
| `CHANGELOG.md` | A | this file |

### Checks performed
- A Python script confirming the board data is consistent. Not performed: any run in Godot.

### Known issues and open items
- Drop target is the cell under the pointer, not the part's corner. No rotation.
