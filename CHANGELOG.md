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

### Scheduled Code checker role — 2026-11-21 (documentation only)

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: main 0.50.0 (c04a278). Open PRs #64–#67 are untouched; the integrator assigns the version.
- Added: `docs/CODE_CHECKER.md`. User decision: a scheduled Claude session is the code checker. Every
  6 hours it reviews new main commits and changed PRs (comment-only), files bugs through small docs PRs,
  runs the every-10-versions structural review in BUGS.md, and every 2 days a performance review in
  PERFORMANCE.md. It never edits game code, approves or merges. Other AIs no longer run these reviews.
- Changed: AGENTS.md rule 6, BUGS.md filing rules, WORK_PLAN.md roles, PERFORMANCE.md (review log
  section), DEVELOPMENT.md file map, HANDOFF.md note.
- Files changed: docs/CODE_CHECKER.md (A), AGENTS.md (M), docs/BUGS.md (M), docs/WORK_PLAN.md (M),
  docs/PERFORMANCE.md (M), DEVELOPMENT.md (M), HANDOFF.md (M), CHANGELOG.md (M).
- Execution: documentation only; no Godot run, no runtime, test or CI change.
- Checks: `python3 -I tools/check_project.py`, bug-register checker and its tests (results in the PR).
- Next action: the user merges this PR; the scheduled tasks are already active and read this file.

### Approved diagnosis/manual design and coordinated resume — 2026-11-18 (documentation only)

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work.
  No invented deployment id. This limitation remains explicit against D51's exact-id requirement.
- Based on: PR #56 with the previous diagnosis-review handoff; verified main 0.46.0 / b6004d2.
- Changed: record D150 and the approved optional manual/fixed story facts/no follow-up questions;
  reconcile the earlier diagnosis decisions in the working design and detailed repair-loop contract.
  Separate Observations/Measurements/Work history; specify shared-clock Findings, test limits,
  historical validity, temporary test-part ownership and collection settlement; retain hidden pickup
  rules and deferred case/visual/generator scope. Candidate taxonomies/UI details remain proposed.
- Changed: revise HANDOFF and WORK_PLAN to split work: Codex design/manual content and cross-review;
  Claude runtime audit, necessary separate compatibility patch FIRST, then 3.4/manual integration/tests.
  Replace the earlier discussion-only resume prompt with a copyable Claude assignment and boundaries.
  Correct the repair-loop introduction that incorrectly said none of its shipped sections were built.
- Files changed: HANDOFF.md (M), docs/DESIGN.md (M), docs/REPAIR_LOOP_DESIGN.md (M),
  docs/DECISIONS.md (M), docs/WORK_PLAN.md (M), CHANGELOG.md (M).
- Execution: documentation only; no Godot run, runtime code, case pack, manual runtime or save change.
  Existing release metadata remains the handoff patch's; integration assigns the next delivery version.
- Checks: `python3 -I tools/check_project.py` passed (0 problems); `git diff --check` passed.
  Checked consistent D150/manual/work-split/patch-first references across all five changed design/handoff files.
- Open: exact manual content/presentation, complaint layout, final ambiguity categories, case-specific
  mandatory-story diagnostic routes; Claude's current unpublished scope must be reported by Claude.
- Next action: Claude reads the new handoff and audits before resuming; patch conflicts first in a
  separate version/PR. Codex handles manual/design and reviews his code. No merge in this task.

### Diagnosis design review handoff — 2026-11-17 (documentation only)

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work.
  No invented deployment id; this limitation does not satisfy D51's exact-id preference.
- Based on: PR #56 head 2052ecf; verified main remains 0.46.0 / b6004d2.
- Changed: HANDOFF.md records the user's confirmed diagnosis choices, marks open story difficulty,
  assistance, complaint/observation presentation and ambiguity classification questions, and provides
  a read-before-continuing prompt. Supersedes the now-stale instruction to present A/B/C and wait.
- Files changed: HANDOFF.md (M), CHANGELOG.md (M). No runtime, save, version or other-agent edits.
- Execution: no Godot run; documentation-only. Integration assigns a version per the parallel-work rule.
- Checks: `python3 -I tools/check_project.py` passed (0 problems); `git diff --check` passed.
- Next action: discuss open choices; compare the implementer's actual branch with confirmed design;
  isolate any necessary changes to existing behaviour in a separate push after discussion. No merge.

## 0.56.0 - 2026-11-21 - The testing bay's magnifying glass

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.55.0 (PR #69, open; this branch is stacked on it).
- Type: minor (D162 point 3).

### Execution status
Godot was not run locally by Claude. GitHub Actions runs every suite headless on Godot 4.7.2; the result
is recorded under Checks performed. No graphical playtest yet; the lens is placeholder drawing.

### Added
- **The magnifying glass** in the testing bay: pick it up, hold it over a spot on the part, and after a
  moment it takes a close look (one night minute, noted on the part as before). Esc or right-click puts it
  down. Spots already looked at are ticked and cost nothing more. The cursor hides while the glass is
  over the part.
- `PartCondition.needs_lens(kind, spot)`: today every spot needs the glass; later fault types that show to
  the bare eye can say otherwise (the user: "there will be multiple types").

### Changed
- The "Look: <spot>" buttons are gone; the glass replaces them. The quick and long tests are unchanged
  (Codex replaces them with the part tests in 0.58.0).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/night/testing_bay_view.gd` | M | The magnifying glass replaces the spot buttons |
| `scripts/rules/part_condition.gd` | M | `needs_lens` |
| `tools/test_testing_bay.gd` | M | The glass with real mouse input (hover, pick up, dwell, Esc) |
| `README.md`, `project.godot`, `CHANGELOG.md`, `HANDOFF.md` | M | Version 0.56.0; the bay passes to Codex after merge |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems.
- GitHub Actions on Godot 4.7.2 (headless): see the PR; this entry is updated with the result.

### Decisions proposed (not approved)
- Dwell 0.6 seconds, lens radius 58 px, spots marked faintly until the parts have art.

### Next action
After the user merges 0.55.0 and 0.56.0, `testing_bay_view.gd` passes to Codex for the part tests (0.58.0).

## 0.55.0 - 2026-11-21 - The store down the street and storage under the counter

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.54.2 (main 2b346c1).
- Type: minor (user playtest of 0.53.0, D162).

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2 and they
passed (run 44857271062). No graphical playtest yet.

### Added
- **Storage under the counter window**: a 20 × 10 grid for anything (parts, tools, PCs waiting for pickup).
  Bring things from the stock room, drag to arrange, turn with R / Q / E, send back. It shares the stock
  room's layout file, so nothing is copied; auto-packing the stock room leaves it alone.
- **The store** outside, down the street: the tool upgrades that were the counter's catalogue. It is a
  separate place from the parts supplier (still a "later" spot).
- Briefs for Codex: `docs/PART_TESTS_DESIGN.md` (0.58.0) and the 0.57.0 section at the top of
  `docs/ANTIVIRUS_MINIGAME_DESIGN.md`.

### Changed
- The counter no longer has a tool catalogue. The stock room's summary counts what is under the counter.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rooms/under_counter_view.gd`, `scenes/under_counter.tscn` | A | Under the counter |
| `docs/PART_TESTS_DESIGN.md` | A | Part tests brief (Codex) |
| `scripts/storage/storage_data.gd`, `scripts/storage/storage_model.gd`, `scripts/storage/storage_view.gd` | M | The fixed under-counter unit; place_first, to_room, in_unit; arrange keeps it |
| `scenes/rooms/counter.tscn`, `scenes/rooms/outside.tscn`, `scripts/rooms/counter_room.gd` | M | Under-counter spot replaces the catalogue; the store outside |
| `scripts/night/night_navigation.gd`, `scripts/night/navigation_state.gd`, `scripts/night/shop_activity_view.gd` | M | The new place; the store's exit to the street |
| `tools/test_rooms.gd`, `tools/test_morning.gd`, `tools/test_room_workshop.gd` | M | Store and under-counter coverage |
| `docs/DECISIONS.md`, `docs/MENU_NAVIGATION.md`, `docs/ROOM_ART_GUIDE.md`, `docs/ANTIVIRUS_MINIGAME_DESIGN.md`, `DEVELOPMENT.md`, `HANDOFF.md`, `project.godot`, `CHANGELOG.md` | M | D162, places, art guide, the anti-virus brief, file map, handoff, version |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems.
- GitHub Actions on Godot 4.7.2 (headless), run 44857271062 on `90a11c1`: passed. 34 required suites,
  2,398 checks, 0 failures (Rooms 71, Testing bay 52, Room workshop 31, Morning report 28). The first run,
  44854128030, hung on B54 and was cancelled. The style report and diagnostics lanes are non-blocking.

### Decisions proposed (not approved)
- "Keep store upgrades separate from buying parts and tools" read as: the store sells the tool upgrades;
  parts are still ordered on the hardware bench. To be confirmed by the user.
- The grid is 20 wide by 10 high (wide, under the window); trial size.

### Next action
Claude: the magnifying glass in the testing bay (0.56.0). Codex: the anti-virus effects (0.57.0), then the
part tests (0.58.0) after 0.56.0 merges. Merges stay with the user.

## 0.54.2 - 2026-11-21 - Integrate dedicated Code checker role

- Author: Claude (Opus 5.5, model id claude-opus-5-5), original PR #68; integration by Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
- Based on: merged main 0.54.1 / 7861de7 and PR #68 head 5feb8e7.
- Type: patch (documentation and version-only metadata; no runtime or save change).

### Execution status

No new Godot run. Runtime remains identical to tested 0.54.0; this patch integrates documentation
only. It does not create or verify Claude's external scheduled tasks or claim graphical acceptance.

### Added / Changed / Fixed / Removed

- Integrate PR #68's dedicated Code checker contract and pointers: six-hourly change review,
  structural reviews at the BUGS marker and performance reviews every two days. The checker reports;
  code owners implement fixes and the user controls merges. Authors retain testing/bug-filing duties.
- Resolve the old-baseline handoff conflict while preserving integrated releases and historical
  proposals. Refresh the current Claude resume prompt and assign a delivery version under project rules.

### Files changed
| File | Change | What |
| --- | --- | --- |
| docs/CODE_CHECKER.md | A | Original dedicated review-role contract from Claude's PR #68 |
| AGENTS.md | M | Scheduled review ownership pointer |
| docs/BUGS.md | M | Structural review owner pointer; marker unchanged |
| docs/PERFORMANCE.md | M | Review ownership and empty log section |
| docs/WORK_PLAN.md | M | Dedicated checker role alongside standing author split |
| DEVELOPMENT.md | M | Register checker contract in file map |
| HANDOFF.md | M | Reconcile current integrated state and copyable resume prompt |
| docs/CURRENT_STATE.md | M | Current checker integration status |
| README.md | M | Version and integration note |
| project.godot | M | Version only, 0.54.2 |
| CHANGELOG.md | M | Original Unreleased provenance and this signed delivery record |

### Checks performed

- Project checker passed: 154 scripts, 806 references, 226 mapped files, five core docs, zero problems.
- Bug checker passed with zero problems; 12 bug-register fixtures and 9 CI-scope fixtures passed.
- Whitespace against main passed; only Markdown and config/version differ from main 0.54.1.
  All game code, scenes, tests, tools and CI are unchanged from tested 0.54.0.

### Decisions proposed (not approved)

None added by integration; retain the checker-role decision recorded in PR #68. No new automation
is configured by this merge.

### Known issues and open items

L1/L2 open; L4/L5 separate; deferred features unchanged. External schedules are outside this
integration's verification. Next structural review marker remains 0.60.0.

### Next action

Claude pulls current main, reads HANDOFF 0.54.2 and CODE_CHECKER, resumes Rooms/art/playtesting and
coordinates the next runtime owner. The dedicated checker handles scheduled reviews.

## 0.54.1 - 2026-11-21 - Integrate release chain and archive historical PC-model proposals

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work.
- Based on: integrated main 0.54.0 / d8ecf6a after user-authorized merges #64, #65, #66 and #67; resolves old PR #19.
- Type: patch (documentation/archive integration and version-only metadata; no runtime behaviour or save change).

### Execution status

No new Godot run for this documentation-only patch. Runtime files are identical to the merged
0.54.0 tree, whose 33 required Godot 4.7.2 suites passed 2,378 checks and bench smoke completed
(see 0.54.0 evidence). This is not graphical acceptance.

### Added / Changed / Fixed / Removed

- Preserve PR #19's two 0.19.3-era PC/part proposals with prominent historical/unapproved annotations;
  current DECISIONS, PART_LIFECYCLE and DEVELOPMENT take precedence. Archival merge does not approve
  remaining proposal mechanics or replace the current physical-record contract.
- Resolve conflicting DEVELOPMENT and CHANGELOG content in favour of current main, retaining the
  complete current runtime and release history; register both archived documents in the file map.
- Record completed #64–#67 integration and update Claude's copyable resume prompt: current Rooms/art/
  playtesting, Wave 3 already built, no runtime hot file reserved by this task. Keep L1/L2 open,
  L4/L5 separate, deferred features deferred and the structural review at 0.60.0.

### Files changed
| File | Change | What |
| --- | --- | --- |
| docs/PC_MODEL_PROPOSAL.md | A | Archive the old record/save/migration proposal with current-authority annotation |
| docs/PC_OWNED_PART_MODEL_PROPOSAL.md | A | Archive the old player-facing proposal with current-authority annotation |
| DEVELOPMENT.md | M | Register both historical documents; preserve current contracts |
| HANDOFF.md | M | Integration status, hot-file release and current Claude resume prompt |
| docs/CURRENT_STATE.md | M | Integrated main and historical proposal status |
| docs/WORK_PLAN.md | M | Current integration and resumed ownership coordination |
| README.md | M | Version and archival integration note |
| project.godot | M | Version only, 0.54.1 |
| CHANGELOG.md | M | This signed integration record |

### Checks performed

- Project checker passed: 154 scripts, 806 resolved references, 225 mapped files, five core docs, zero problems.
- Bug-register checker passed with zero problems; all 12 register fixtures passed.
- All 9 CI-scope fixtures passed; `git diff --check` passed.
- Comparison against merged main d8ecf6a: only nine Markdown/version files differ; project.godot
  changes only config/version. All runtime files are identical to tested 0.54.0.

### Decisions proposed (not approved)

No new proposal. The two archived documents retain their original unapproved ideas for reference;
this merge does not approve them or a full legacy-identity migration.

### Known issues and open items

L1/L2 remain open; L4 and L5 remain separate open tasks. No lost historical condition is invented.
The manual and other deferred features remain deferred. Human graphical acceptance remains pending.

### Next action

Claude pulls integrated main and resumes Rooms/art/playtesting via HANDOFF 0.54.1. Coordinate the
next runtime hot-file owner and retain all required suites. Next structural review: 0.60.0.

## 0.54.0 - 2026-11-21 - Preserve delivered physical parts and reconcile audit follow-ups

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work; no deployment id invented.
- Based on: PR #66 head f61583c8be04be8150eb547ae6f71285e70dbc33 (0.53.0), stacked after #64 builds and #65 trust/reviews; main remains 0.50.0/c04a278.
- Type: minor (new compatible physical-record and comeback-receipt contracts for the user-authorized bug correction; SAVE_FORMAT remains 1).

### Execution status
Codex ran Godot 4.7.2 stable ed1daf0bf locally, headless. The new Delivered parts suite passed 80 checks.
The four-check reproduction on the unchanged 0.53.0 parent failed its two post-handover assertions
(condition and uid loss), proving B53 before the correction. All 33 required suites passed (2,378 checks, zero failures), and the bench smoke playtest finished
without script/parse errors. No graphical/native-feel acceptance is claimed.

### Added / Changed / Fixed / Removed
- Fix B53/L3: collection now transfers an individual record before consuming shop stock. UID, actual
  health/defect and known evidence survive; owner changes once. Dead/degraded parts keep their
  effective stats, boot symptoms and load faults after collection, inactive-PC reload and save/load.
- `job.part_instances` is the migrated shop-to-customer path. Legacy originals are not assigned
  invented identities or health; L1/L2 remain explicit. Temporary parts still use shop records as
  authority; rules use permanent records after handover, not a stale shop_condition cache.
- Removing/refitting or reordering identical RAM/drive models carries each physical record; later
  replacement returns it to shop stock with the SAME UID/condition/defect, untested under D158. Parts
  not replaced leave in the customer's bag with their records retained, never as free shop stock.
- Immutable `pc_snapshot` comeback receipts retain the actual delivered PC, including loose bag
  contents. Sanitization/reload and due report cards preserve them. Existing report-only comeback
  routing, payment/reviews and social rules are not replaced by a new return-repair workflow.
- Physical measurement fingerprints include uid/model/health/defect in stable order. Known labels or
  ownership metadata alone do not invalidate measurements; empty legacy records keep old signatures.
- Record sanitizers reuse PartCondition and the shared loose-entry adapter. Compatible optional fields
  default empty; already-lost old condition cannot be reconstructed. No new inventory/clock/UI flow.
- Split the former combined L4 into L4 salvage-clock integration and L5 drawer overflow, independently
  open. Keep 41 historical bugs Fixed, not automatically Verified. Next scheduled review stays 0.60.0.
- Current handoff coordinates this stacked patch and tells Claude to resume the latest Rooms/art/
  playtest follow-up after cross-review/user-controlled integration, not old Wave 3 sessions.

### Files changed
| File | Change | What |
| --- | --- | --- |
| scripts/rules/part_instances.gd | A | Physical-record, shared loose-entry and immutable comeback-receipt adapters |
| scripts/state/game_state.gd | M | Transfer records at collection, carry them during undo/refit, return stock UID, bag/receipt preservation |
| scripts/rules/customer_pc.gd | M | Move migrated records alongside actual components, including same-model reordering |
| scripts/rules/pc_build.gd | M | Permanent condition and defect effects after shop custody ends |
| scripts/rules/part_states.gd | M | Boot observations retain the delivered source's actual condition |
| scripts/rules/morning.gd | M | Preserve optional comeback receipts across load |
| scripts/rules/work_report.gd | M | Stable physical identity/health fingerprints independent of knowledge/owner metadata |
| tools/test_delivered_parts.gd | A | Full same-model delivery/comeback/removal/refit/return-to-stock journey and all six part types |
| .github/workflows/tests.yml | M | Register Delivered parts, preserving every prior suite |
| project.godot | M | Version 0.54.0 |
| README.md | M | Correction scope, stack dependency and remaining limitations |
| HANDOFF.md | M | Live assignment, code ownership, integration order and Claude resume prompt |
| DEVELOPMENT.md | M | New file map and physical-record/receipt compatibility contract |
| docs/BUGS.md | M | B53 verified reproduction/fix; targeted review; separate L4/L5; L1/L2 and historical evidence stay explicit |
| docs/PART_LIFECYCLE.md | M | Migrated delivered-part path and exact remaining original/alias/orphan scope |
| docs/WORK_PLAN.md | M | Current bounded ownership and resume coordination |
| docs/TESTING.md | M | Required complete delivery-lifecycle scenarios |
| docs/DECISIONS.md | M | D162: user-authorized audit follow-up, preserving existing gameplay truth |
| docs/CURRENT_STATE.md | M | Current branch/implementation facts |
| docs/DESIGN.md | M | Preservation scope and deferred boundaries |
| docs/ROADMAP.md | M | Current follow-up and unchanged 0.60.0 structural checkpoint |
| docs/PROJECT_BRIEF.md | M | Current correction scope |
| CHANGELOG.md | M | This signed release record |

### Checks performed
- Godot 4.7.2: unchanged-parent reproduction, 4 checks, 2 expected failures after collection.
- Godot 4.7.2: Delivered parts 80 checks, zero failures; previous Part lifecycle 38 and Testing bay 52 passed.
- All 33 required Godot 4.7.2 suites: 2,378 checks, zero failures. Bench smoke: Playtest finished, no script/parse errors.
- Project checker: 154 scripts, 806 resolved references, 223 mapped files, five core docs; zero problems. `git diff --check` passed.
- Bug register checker: 0 problems. Register fixtures: 12 passed. CI-scope tests: 9 passed.

### Decisions proposed (not approved)
No new gameplay/balance proposal. Full legacy-original migration, orphan recovery, salvage clock costs
and drawer UI still require their bounded follow-ups; this correction does not silently design them.

### Known issues and open items
L1 legacy originals and presentation aliases remain slot-derived; L2 orphan custody remains locked.
Old saves which already lost a delivered part's condition cannot honestly recover it. Comebacks are
still report-only; receipts are history, not automatically created repair tickets. No graphical test.

### Next action
Claude cross-reviews the #64 -> #65 -> #66 chain, then this patch; user controls merges. Preserve the
Delivered parts and all previous suites. After integration, resume current Rooms/art/playtest work.
Codex releases this bounded runtime reservation after delivery/cross-review. Continue L1 migration
incrementally; handle L2 recovery safely; design L4 clock and L5 overflow separately. Review at 0.60.0.

## 0.53.0 - 2026-11-21 - Rooms instead of menus

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.52.0 (PR #65, open; stacked on #64, open).
- Type: minor (user-requested revamp, D161; supersedes the 0.42.0 menu-path rules).

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 33
suites passed (2,298 checks), including the new Rooms suite (53 checks, native clicks on the hotspots),
after one test-ordering fix (B52). No graphical playtest yet; the rooms use placeholder drawings.

### Added
- **The counter** is the main screen: front door (outside), back door (workshop), the customer window,
  the till, the ticket clipboard, your phone, the tool catalogue, the wall board, the bin (later) and the
  shutter, which ends the night.
- **The workshop**: the repair bench, hardware board and diagnostic monitor (with the PC on the bench),
  the testing bay corner, the stock room door, the door back to the counter.
- **Outside**: the shop door and your van to the salvage dump; a parts supplier spot for later.
- **The morning at the counter**: the shutter goes up and every customer walks in, one at a time, with
  what they have to say (collections, comebacks, new tickets). The slip counts how many came in; the rest of
  the shop waits until they are served; then the counter sums up who is still waiting and any review-site
  notice. No clock runs during the visits.
- **Replaceable art**: each room is a picture (`art/rooms/<room>.png`) plus clickable spots you drag in the
  Godot editor; placeholders until the picture exists; F3 shows every spot. Customer portraits go in
  `art/customers/`. Guide: `docs/ROOM_ART_GUIDE.md`.

### Changed
- No Activities hub, no workbench tabs, no morning report screen. Close-ups have one exit named after
  their room (← Workshop, ← Outside, ← Counter) plus Pause. Old links and preferences land at the counter.
- New game and the Continue fallback open the counter.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rooms/room_view.gd`, `hotspot.gd`, `room_art.gd`, `counter_room.gd`, `workshop_room.gd`, `outside_room.gd`, `legacy_redirect.gd` | A | The rooms |
| `scenes/rooms/counter.tscn`, `workshop.tscn`, `outside.tscn` | A | Room scenes (Background + hotspots) |
| `art/rooms/README.md`, `art/customers/README.md`, `docs/ROOM_ART_GUIDE.md` | A | Art folders and the artist's guide |
| `scripts/night/morning_text.gd` | A | The morning's words (from the retired morning screen) |
| `tools/test_rooms.gd` | A | Rooms suite |
| `scripts/night/activities_view.gd` → `scripts/night/night_screen.gd` | R | Only the shared helpers remain |
| `scripts/night/morning_view.gd` | D | Replaced by the counter's visits |
| `scenes/activities.tscn`, `scenes/morning.tscn` | M | Redirect to the counter |
| `scripts/night/night_navigation.gd`, `scripts/night/navigation_state.gd`, `scripts/night/night_session.gd` | M | Places, exits, resume paths, the visits flag |
| `scripts/storage/storage_view.gd`, `scripts/night/salvage_view.gd`, `scripts/night/shop_activity_view.gd`, `scripts/night/testing_bay_view.gd`, `scripts/night/software_view.gd`, `scripts/view/start_view.gd` | M | Exits to their rooms; start at the counter |
| `tools/test_menu_navigation.gd`, `test_morning.gd`, `test_night_workshop.gd`, `test_room_workshop.gd`, `test_start_screen.gd`, `test_storage.gd`, `test_testing_bay.gd`, `test_salvage_physics.gd`, `test_trust_and_reviews.gd`, `test_build_requests.gd`, `.github/workflows/tests.yml` | M | Walk through rooms instead of the hub and tabs; suite registered |
| `docs/MENU_NAVIGATION.md`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `docs/CURRENT_STATE.md`, `AGENTS.md`, `DEVELOPMENT.md`, `HANDOFF.md`, `README.md`, `project.godot`, `CHANGELOG.md` | M | Room navigation rules, D161, plan, state, agent rule 8, file map, handoff, version 0.53.0 |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems.
- GitHub Actions on Godot 4.7.2 (headless): run 44842058308 on `ff07409` failed one check (Rooms: "the till shows the cash", B52, a test-ordering defect); run 44842432173 on `98a39db`: 33 suites, 2,298 checks, 0 failures (Rooms 53, Menu navigation 38, Morning report 28); bench smoke playtest finished.

### Decisions proposed (not approved)
- "The day is not timed" read as: the morning visits have no clock; the night clock stays.
- While customers are at the counter, every other spot waits; the stock room opens off the workshop.
- Close-ups keep their current look; only rooms take new art for now.

### Known issues and open items
- Placeholder drawings only; the user plans the art. Customer portraits are optional silhouettes for now.
- Customers do not yet talk in dialogue: their visit is the old report text on a slip.

### Next action
The user playtests and plans art; Codex cross-reviews #64, #65 and this PR; merges stay with the user.

## 0.52.0 - 2026-11-20 - Trust and reviews (session 3.8)

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.51.0 (PR #64, open; this branch is stacked on it).
- Type: minor (session 3.8, D160 user approved; replaces the planned elegance score).

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 32
suites passed (2,239 checks), including the new Trust and reviews suite (38 checks, real input on the
phone), and the bench smoke playtest finished. No graphical playtest yet.

### Added
- **Reviews**: every pickup leaves a star review with a comment on the shop's FixFindr page. About a third
  of customers knock a star off for a petty reason. Customers who find something out post a one-star review
  (a two-star one for an honest mistake).
- **Trustworthiness and the shop level**: good pickups earn trust points; the level (1–6) follows them.
  Points are only lost when customers find out, or when bought reviews are caught. Upgrades come later.
- **Finding out**: at collection the game notes what was hidden (toothpaste, second-hand parts handed
  over as new, a build sold far above its worth, a working part of theirs kept); some customers find out
  2–5 mornings later, more often those who open the case. The existing delayed faults count too.
- **The phone** (Activities > Phone): the rating, every review, trustworthiness and the shop level, and
  ReviewBoost: three five-star reviews for $45. The review site may catch them the next morning: it removes
  them all, flags the page and the shop loses trust.
- The morning report shows each review and the shop's standing, and says when the level changed.

### Changed
- Reviews are records instead of plain scores (old saves migrate); the rating averages review stars.
- No elegance score (D160 supersedes that part of D140).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/reviews.gd` | A | Reviews, rating, trust points and levels, finding out, fake reviews |
| `scripts/night/phone_panel.gd` | A | The phone app |
| `tools/test_trust_and_reviews.gd` | A | Trust and reviews suite |
| `scripts/state/game_state.gd` | M | Review records, trust points, fake orders; pickup reviews; deceptions found out; the site's check |
| `scripts/rules/shop_rating.gd`, `scripts/rules/morning.gd` | M | One rating rule; found-out comebacks |
| `scripts/night/night_session.gd`, `scripts/night/morning_view.gd`, `scripts/night/activities_view.gd` | M | The morning check and standing; reviews on cards; the phone button |
| `tools/test_generated_tickets.gd`, `.github/workflows/tests.yml` | M | Saved reviews now migrate to records; suite registered |
| `docs/DECISIONS.md`, `docs/REPAIR_LOOP_DESIGN.md`, `docs/WORK_PLAN.md`, `DEVELOPMENT.md`, `HANDOFF.md` | M | D160, design 7c (with the later interactive reviews), plan, contracts, handoff |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version 0.52.0 |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems.
- GitHub Actions on Godot 4.7.2 (headless), run 44788341331 on `a0f44d7`: 32 suites, 2,239 checks, 0 failures (Trust and reviews 38, Build requests 190, Generated tickets 65, Morning report 27); bench smoke playtest finished.

### Decisions proposed (not approved)
- Every number in D160's implementation proposals; the phone lives on the Activities screen only.
- A disappointed pickup lowers the star rating but not trustworthiness (nothing was hidden).
- Second-hand parts count as a deception whenever a non-new shop part is handed over (no disclosure option yet).

### Known issues and open items
- Shop level upgrades are not defined; the level changes nothing yet.
- Interactive reviews (replying, paying for removal) are design only (7c).

### Next action
Codex cross-reviews; the user decides #64 then this PR. The Wave 3 plan is complete after this.

## 0.51.0 - 2026-11-20 - Build requests (session 3.7)

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.50.0 (main c04a278: PR #63 merged by the user; archived as archive/v0.50.0).
- Type: minor (session 3.7, D159 user approved).

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 31
suites passed (2,201 checks), including the new Build requests suite (190 checks), and the bench smoke
playtest finished. No graphical playtest yet (the playtest gate after 3.7 is the user's).

### Added
- **Build requests** (from night 4; night 5's first new customer always brings one): a use from the
  approved table, up to two wishes (quiet, room to grow, a favourite CPU or GPU brand, extra storage) and
  a budget. Half is paid when they arrive, the rest on collection; the profit is what the parts did not cost.
- **The empty build**: the basic case of its size with the cheapest motherboard, both paid from the
  deposit. Order parts and fit them at the hardware bench; each fit costs night minutes (CPU 5, RAM 3,
  drive 4, PSU 8, GPU 5, cooler 10, motherboard 10, case 15). The cooler goes on with pre-applied paste.
- **Cases**: five parody cases (basic tower and compact, a mesh tower that runs cooler, two
  sound-dampened ones). Swap the case or the motherboard from the new **Case and motherboard** panel while
  the case is empty (the old one is refunded; a case of the other size takes a board of its size).
- **Pickup for builds**: each missed need costs 40 points, each missed wish 10, on top of the usual
  temperature and fault rules (loose GPU screws and crashing untested parts still come back).
- Every PC now lists its case; a repair PC sits in the default case of its size, which changes nothing.

### Changed
- A build opens at the hardware bench; the Repair tab is off for builds (nothing to clean or repaste).
- The ticket of a build shows its needs, wishes, budget and what the parts in it cost so far.
- Scam hooks (left open on purpose, D159): a collected build keeps its value at new prices next to the
  budget and counts its parts by what the shop knew (new, untested, tested, salvaged). No consequence yet.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/build_request.gd` | A | Uses table, needs and wants, cheapest catalogue build, the empty build, assembly minutes, pickup review, ticket texts, delivery record |
| `tools/test_build_requests.gd` | A | Build requests suite |
| `scripts/data/hardware_catalog.gd` | M | Cases; cheapest board |
| `scripts/data/games.gd` | M | Install size |
| `scripts/rules/pc_build.gd` | M | `case` in the parts record, case model and heat, `is_build`, build part lines |
| `scripts/rules/ticket_generator.gd` | M | `draw_build` |
| `scripts/night/night_session.gd` | M | Build arrivals and their deposit |
| `scripts/state/game_state.gd` | M | Build record on save/load, assembly minutes, case/board swaps, deposit, build pickup review, delivery record, the customer's new PC |
| `scripts/rules/customer_pc.gd` | M | No phantom first GPU/cooler in a build; the case kept |
| `scripts/night/hardware_view.gd` | M | Case and motherboard panel, build texts, assembly refusals |
| `scripts/rules/ticket.gd`, `scripts/night/ticket_menu.gd`, `scripts/rules/part_states.gd`, `scripts/rules/findings.gd` | M | Build ticket and wording |
| `scripts/night/night_diagnostics.gd` | M | Case airflow; no repair-only notes for builds |
| `scripts/night/night_navigation.gd`, `scripts/night/navigation_state.gd`, `scripts/night/workshop_hub.gd`, `scripts/night/repair_view.gd` | M | Builds go to the hardware bench |
| `tools/test_data_schemas.gd`, `.github/workflows/tests.yml` | M | Game schema key; suite registered |
| `docs/DECISIONS.md`, `docs/REPAIR_LOOP_DESIGN.md`, `docs/WORK_PLAN.md`, `docs/PART_LIFECYCLE.md`, `DEVELOPMENT.md`, `HANDOFF.md` | M | D159, the approved uses table, plan, lifecycle stage, contracts, handoff |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version 0.51.0 |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems.
- GitHub Actions on Godot 4.7.2 (headless), run 44775665191 on `d4a6efe`: 31 suites, 2,201 checks, 0 failures (Build requests 190, Testing bay 52, Menu navigation 33, Morning report 27); bench smoke playtest finished.

### Decisions proposed (not approved)
- Every number in D159's implementation proposals (cases, minutes, wish rules, scoring, budgets, odds).
- Builds skip the paste minigame (pre-applied paste); case swaps exist for builds only, not repairs.
- Build customers are new people (not returning ones) and never the clueless profession, for now.

### Known issues and open items
- L3 applies to builds: a delivered degraded or dead part loses its condition at collection.
- The scam hooks are recorded but have no consequence; elegance (3.8) does not read builds yet.
- A build handed back unfinished pays nothing and the customer does not keep it as their PC record.

### Next action
Codex cross-reviews; the user playtests the 3.7 gate and decides the merge. Then 3.8 Elegance and
reviews (0.52.0), talk first.

## 0.50.0 - 2026-11-20 - Testing bay (session 3.6) and the 0.50.0 structural review

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.49.0 (main a62efc6: PR #61 then PR #62 merged by the user; archived as archive/v0.48.1 and archive/v0.49.0).
- Type: minor (session 3.6, D158 user approved) plus the scheduled structural review.

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 30
suites passed, including the new Testing bay suite (52 checks). No graphical playtest yet.

### Added
- **Testing bay** (Activities > Testing bay): every stock part in the drawer. Click spots on the part to
  look closely (1 night minute each): scorch marks, domed capacitors, burnt smells, or nothing unusual.
  Quick test (5 min) and long test (20 min) on the rig per part type; some faults only show in the long
  test. Mark the part working, degraded or dead (your call, free), or sell it for scrap ($2–8).
- **Untested stock:** salvage unloading now puts finds into stock as untested parts (things the shop
  cannot stock are scrapped for $1), and every customer original replaced by a shop part stays with the
  shop as untested stock, faulty or not.
- **Degraded parts:** a GPU with artifacts, memory with errors, a hot CPU, a weak cooler, a weak power
  supply, a slow drive. Fitted as a test part they behave so: the Stress lab crashes, games flicker or
  crash, temperatures rise, the PSU gives about 70%. A dead spare gives the same symptoms as a faulty
  original. A crashing part left in a customer's PC brings them back two mornings later.

### Changed
- Stock shows what the shop knows (New / Untested / Marked …) everywhere; the real condition is never
  shown. A part leaves use only when you mark it dead (or damage it yourself).
- The solvability proof for generated tickets counts only new or marked-working spares.
- Activities has a third activity button row slot: Workshop room, Salvage dump, Testing bay.

### Structural review (scheduled for 0.50.0)
- docs/BUGS.md: review entry, new root-cause rule RC-6 (one rule, several hand-written copies), RC-5
  progress, new limitations L3 (condition lost at delivery) and L4 (salvage clock, drawer overflow),
  B51 filed. Next review: 0.60.0.

### Fixed
- B51: stock records changed shape on reload (caught by CI before release).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/part_condition.gd` | A | Knowledge vs condition, inspection spots and tells, rig test results, scrap, the crashing-part fault |
| `scripts/rules/salvage_stock.gd` | A | A salvage find becomes untested stock or scrap |
| `scripts/night/testing_bay_view.gd`, `scenes/night_bay.tscn` | A | The testing bay screen |
| `tools/test_testing_bay.gd` | A | The bay journey, fitted-part behaviour, reload rebuild, screen and navigation |
| `scripts/state/game_state.gd` | M | Records with condition/defect/knowledge; availability by knowledge; bay actions; salvage intake; originals kept untested; fitted test parts carry their condition |
| `scripts/rules/pc_build.gd` | M | Defects and their effects; dead fitted shop parts contribute nothing |
| `scripts/rules/part_states.gd`, `scripts/rules/software_checks.gd`, `scripts/rules/stress_lab.gd`, `scripts/night/night_diagnostics.gd` | M | Symptoms of dead and degraded shop parts |
| `scripts/rules/morning.gd` | M | The delayed crashing-part fault |
| `scripts/night/salvage_view.gd`, `scripts/night/activities_view.gd`, `scripts/night/night_navigation.gd`, `scripts/night/navigation_state.gd`, `scripts/night/night_session.gd`, `scripts/storage/storage_sources.gd` | M | Unload into stock, bay route, resume, refresh on switch, known label in the room |
| `.github/workflows/tests.yml` | M | Suite registered |
| `docs/BUGS.md`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `docs/PART_LIFECYCLE.md`, `DEVELOPMENT.md`, `HANDOFF.md` | M | Review, D158, plan, lifecycle stage, contracts, handoff |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version 0.50.0 |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems; register fixture tests pass.
- GitHub Actions on Godot 4.7.2 (headless): 30 suites, 0 failures (Testing bay 52, Part lifecycle 38, Menu navigation 33).

### Known issues and open items
- L3: a shop part delivered inside a customer's PC loses its condition at collection (models only).
- L4: the salvage outing still uses its own demo clock; a full drawer can hide stock on the hardware bench (the bay lists all).
- Boards are not testable or stockable yet; whole PCs and add-in cards from salvage are scrapped.
- Scam hooks left open on purpose: the mark can disagree with the evidence; customers' old parts can be reused.

## 0.49.0 - 2026-11-19 - Standard Task Manajer anti-virus and return to the Wave 3 plan

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work. No deployment id is invented.
- Based on: 0.48.1 / PR #61 head 50d16027bac65d68ea4a5f99f1ec16d8f38d1751, stacked on merged main 0.48.0 (6c18522, #59 including #60).
- Type: minor (user-approved new playable anti-virus activity, D157). This takes 0.49.0; later planned versions move by one.

### Execution status
Codex ran Godot 4.7.2 stable ed1daf0bf locally, headless: project import, all 28 required suites
(1,959 checks, zero failures) and the representative bench smoke playtest (Playtest finished, no script
errors). The new Antivirus suite has 50 checks, including real viewport mouse input and key events.
The expected save-warning in its failed-write fixture is intentional. The user accepted the standard
in-chat demo; no graphical Godot playtest or graphical acceptance is claimed for this native port.

### Added / Changed / Fixed / Removed
- Scan -> Remove threat now opens Task Manajer inside the existing monitor, rather than instantly
  curing. Use the actual PC's adware/miner source and its Zombie persistence watchdog. Stop both,
  disable auto-start and reboot to verify before canonical cure. One saved infection remains one.
- Preserve six row/control identities, including ended tasks. No disappearing, moving or spawning
  rows; one bounded occasional advert; only a miner slowly changes alias. Ordinary programs can be
  closed without crashing; ending the critical desktop ends the attempt and switches the PC off.
- Protected miner asks for a funny word. Typed input visibly uppercases with caret preservation;
  native SEND and Enter share the handler. Wrong words permit retry; typing freezes simulation
  indefinitely. No form-submission dependency, input recreation or typing countdown (B50 safeguard).
- Trial attempt cost: 10 canonical night minutes, spent once on entry after boot/scan/save/time gates.
  Failed/incomplete attempts retain cost and infection. Global/local/focus pause, power cancellation,
  save/reload and stale-ticket binding are covered. No money, hardware, payment, pickup or trust change.
- Findings records visible work/outcome on the actual night clock. Cure uses existing state and
  NightSession saves. No GameState/hardware/tool hot-file edit, new saved field or schema migration.
- Reconcile handoff, design and Wave 3 allocation: 3.5 is merged; #61 remains the predecessor;
  anti-virus is a detour. Claude resumes 3.6 Testing bay, talk first, after review/integration.
  Bay is now 0.50.0 with the structural review, builds 0.51.0, elegance/reviews 0.52.0. Manual deferred.

### Files changed
| File | Change | What |
| --- | --- | --- |
| scripts/rules/antivirus_round.gd | A | Isolated standard cleanup simulation and persistence/typing/verification rules |
| scripts/night/antivirus_panel.gd | A | Native stable monitor panel and input/pause/advert feedback |
| scripts/night/software_view.gd | M | Actual monitor start, paid attempt, completion binding, cancellation and guarded exits |
| scripts/rules/malware.gd | M | Scan message explains the new removal route |
| tools/test_antivirus.gd | A | Pure behaviours plus native SEND/Enter and full monitor/save/time/isolation journeys |
| .github/workflows/tests.yml | M | Required Antivirus suite, retaining all prior suites |
| project.godot | M | Version 0.49.0 |
| README.md | M | Play instructions, branch dependency and resume/version allocation |
| HANDOFF.md | M | Current state, exact Claude resume order and copyable prompt; old review request marked historical |
| DEVELOPMENT.md | M | Module file map, native input and authoritative state/clock contracts |
| docs/ANTIVIRUS_MINIGAME_DESIGN.md | M | Approved standard contract supersedes archived original proposals |
| docs/DECISIONS.md | M | D157, accepted standard demo, implementation and deferred boundaries |
| docs/WORK_PLAN.md | M | Correct 3.5 merge state, detour and remaining session/version table |
| docs/CURRENT_STATE.md | M | Live branch/implementation facts supersede historical status paragraphs |
| docs/DESIGN.md | M | Approved calm controls and canonical infection/verification scope |
| docs/PROJECT_BRIEF.md | M | Current side-feature scope and resume point |
| docs/ROADMAP.md | M | Remaining Wave 3 gates and shifted version slots |
| docs/TESTING.md | M | Required native-input and complete cleanup journey policy |
| docs/SOFTWARE_WAVE_2.md | M | Current monitor removal route supersedes the historical one-click app |
| docs/MINIGAME_RULES.md | M | Link the approved standard anti-virus contract without changing dust/paste |
| docs/BUGS.md | M | B50 user-reported review-prototype SEND failure; explicit native-port evidence and root-cause limit |
| CHANGELOG.md | M | This signed delivery record |

### Checks performed
- Godot 4.7.2 project import passed. All 28 required suites passed, 1,959 total checks; Antivirus 50.
- Native Antivirus checks cover actual SEND/Enter/uppercase, retry/stable input, typing/focus/global
  pause, source/watchdog/reboot, 06:00/boot/save refusal, paid cancellation/reload, repeat completion
  and same-strain stale-ticket isolation. Previous Part lifecycle 38 and Board and bench state 39 retained.
- Godot bench smoke: Playtest finished; no SCRIPT ERROR or Parse Error.
- Project checker passed (135 scripts, 681 resolved references, 197 mapped files, five core docs,
  zero problems). CI-scope tests: 9 passed. Bug-register checker: zero problems; malformed-ledger
  fixtures: 12 passed. `git diff --check` passed. The published tree is checked against the local commit.

### Decisions proposed (not approved)
Ten-minute attempt cost, eight-second alias, twelve-second advert, five-second watchdog return and
overload rates are trial balance. Boss malware, new virus families, scanner/store/power-up economy,
subscriptions and deeper persistence remain deferred; none is silently approved by the standard demo.

### Known issues and open items
No graphical native feel acceptance yet. Intermediate row activity is deliberately session-local;
closing/reloading requires a fresh paid attempt, not a saved mid-round resume. The old browser SEND
failure's exact root cause was not traced; B50 evidence verifies the native implementation. Existing
L1/L2 customer-part identity/orphan custody limitations and no-GPU boot gap are not solved here.

### Next action
Claude cross-reviews #61 and this stacked feature; merges remain user-controlled. Integrate #61 first,
retarget the feature to updated main, integrate after review, then resume 3.6 Testing bay with its
required design discussion. Use 0.50.0 and do its structural review then; keep the manual deferred.
Codex's software-view/anti-virus file reservation is released after this delivery/cross-review.

## 0.48.1 - 2026-11-18 - Motherboards, GPU bracket screws, vacuum and paste kept across screens

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.48.0 (main 6c18522, PR #59 merged with PR #60 inside; archived as archive/v0.48.0).
- Type: patch (user requests and a user-reported layout bug, D155). 0.49.0 stays reserved for 3.6.

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 27
suites passed, including the new Board and bench state suite (39 checks) and Codex's Part lifecycle
suite (38). The screw placement was also checked with a render of the game's own layout numbers.
No graphical playtest yet.

### Added
- **Motherboards** are part of every PC: four parody models (two per case size). The hardware bench
  shows the customer's board by name; "Take out the motherboard" works only once every other part is
  out (otherwise it says what is still fitted). With the board out the case is shown empty, nothing can
  be fitted, the PC cannot start (the boot check names the missing motherboard) and Findings notes the
  work. "Fit the motherboard back" restores it. Generated PCs get a board that fits their case.
- The vacuum's **bin fill and the dust riding in the hose are saved** with the shop: leaving the bench,
  switching PCs or reloading no longer empties them; emptying the bin is saved too.
- Closing the game on the repair bench saves like leaving it: an unlocked press is cancelled (no
  result), the pressed paste is kept.

### Fixed
- B49: the GPU's two bracket screws were drawn on the row below the card, which is the second PCIe slot.
  They now sit on the card's rear bracket, outside the board.

### Confirmed unchanged
- Paste pressed before leaving the repair bench already stayed as pressed (the press itself is
  cancelled); now covered by a regression test, including after closing the game.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/data/hardware_catalog.gd` | M | Four boards, default per case size, helpers |
| `scripts/rules/pc_build.gd` | M | `board` in parts, `board_model`, `board_out`, missing/part lines |
| `scripts/rules/customer_pc.gd` | M | Writing the bench back keeps the board |
| `scripts/state/game_state.gd` | M | `board_out`, `board_blocker`, take out / fit back, fitting refused without a board, `vacuum_state` saved |
| `scripts/night/hardware_view.gd` | M | Motherboard button, empty-case drawing, drops refused, bracket plate and screws |
| `scripts/rules/install_faults.gd` | M | Screws on the GPU's rear bracket (B49) |
| `scripts/rules/findings.gd`, `scripts/rules/ticket_generator.gd` | M | Board in the configuration and inspection; generated boards |
| `scripts/bench/vacuum_state.gd` | A | Saved vacuum contents: sanitize, capture, restore |
| `scripts/view/bench_view.gd`, `scripts/view/bench_cleaning.gd`, `scripts/bench/hose_flow.gd` | M | Restore and save the vacuum |
| `scripts/night/repair_view.gd` | M | Save on closing the game |
| `tools/test_board_and_bench_state.gd` | A | 39 checks: board journey on the real bench, screws, vacuum, paste |
| `.github/workflows/tests.yml` | M | Suite registered |
| `DEVELOPMENT.md`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `docs/BUGS.md`, `HANDOFF.md` | M | File map and contracts, D155, plan row, B49, handoff |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version 0.48.1 |

### Checks performed
- `python3 -I tools/check_project.py`: passed. `python3 -I tools/check_bug_register.py`: 0 problems.
- GitHub Actions on Godot 4.7.2 (headless): 27 suites, 0 failures.

### Documentation
- `docs/ANTIVIRUS_MINIGAME_DESIGN.md` (proposal, D156): first design ideas for the "Task Manajer Panic"
  anti-virus mini-game, sent to Codex for review through HANDOFF.md. Nothing built.

### Known issues and open items
- Boards cannot yet be bought, swapped for another model or be faulty (needs a design talk).
- A PC with no graphics card at all at the hardware bench still boots (older gap, noted in 0.48.0).
- The anti-virus mini-game: direction chosen (D156, Task Manager panic); design proposal under review; nothing built.

## 0.48.0 - 2026-11-18 - Generated tickets: morning arrivals, online rating, reputation

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.47.0 (main ed64f21, PRs #57 and #58 merged; archived as archive/v0.47.0); includes 0.47.1
  (Codex, PR #60, commit 656221d) through a merge commit, reconciled per its handoff instructions.
- Type: minor (session 3.5: new player-facing feature, D153 user approved, D154 proposals).

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 25
suites passed, including the new Generated tickets suite (65 checks). No manual graphical playtest yet.

### Added
- **Morning arrivals**: after the night, new tickets come in. How many depends on the online rating
  (stars from the latest pickups; every pickup is a review) and the reputation (average customer trust);
  the morning report says why ("Online rating 4.1★ (6 reviews) · reputation 58/100 · 2 new customers").
  The shop holds at most 4 customer PCs; an empty shop always gets a walk-in.
- **Generated customers**: parody names with a profession (regular, gamer, clueless), each with their own
  PC and needs, saved with the game. Regulars who still trust the shop come back with a new problem.
- **Generated cases**: dust; a GPU or the memory the customer took out; a power supply too small for a
  card they fitted themselves; adware; a miner; an overclock they set; a faulty GPU; a faulty cooler; a
  dead second card. Night 1 stays the story night; one-test problems from night 2, swap problems from night
  4, extra problems on later nights. The complaint says what the customer saw, never the cause.
- Every offered case is checked first: each problem has a way to be found with what the shop owns or can
  afford to buy (D153 option B, including the test game), the difficulty fits the night, and a proper
  repair can make the customer happy. Same save, same mornings (seeded).

### Fixed
- B48: a bought GPU/cooler fitted in the first slot no longer makes the night manifest invalid after a
  reload (which locked switching between PCs). Bug from 0.46.0, found while building option B.

### Changed
- Story customers Mara and Relu no longer bring a new PC every morning; they can return as regulars.
- The solvability rules count parts the shop can afford to buy, and a customer's part lying out of the PC.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/ticket_generator.gd` | A | People, PCs, problems by night, complaint, pay, the solvable/repairable proof, seeded draws |
| `scripts/rules/shop_rating.gd` | A | Online rating, reputation, arrivals and the morning summary |
| `scripts/data/generated_people.gd` | A | Name and text pools per profession; the clueless decoy need |
| `tools/test_generated_tickets.gd` | A | 65 checks across 144 seeded cases, persistence, two mornings, B48 |
| `scripts/state/game_state.gd` | M | `people`, `person_sequence`, `reviews`, `world_seed` saved; `person()`, rating/reputation, sanitizer; capabilities allow buying |
| `scripts/night/night_session.gd` | M | Morning arrivals replace the fixed two-customer loop; manifest accepts generated customers and bought parts (B48) |
| `scripts/rules/diagnosis.gd` | M | Buyable test parts and the test game; parts out of the PC as evident conditions |
| `scripts/night/morning_view.gd`, `scripts/night/ticket_menu.gd` | M | Arrivals line; ticket window reads generated customers |
| `tools/test_morning.gd`, `tools/test_diagnosis.gd` | M | Expectations follow arrivals; owned-only cases set `buy: false` |
| `.github/workflows/tests.yml` | M | Generated tickets suite registered |
| `DEVELOPMENT.md`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `docs/BUGS.md`, `HANDOFF.md` | M | File map, generator contracts, D153/D154, plan status, B48, handoff |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version 0.48.0 and release notes |

### Checks performed
- `python3 -I tools/check_project.py`: passed (0 problems).
- GitHub Actions on Godot 4.7.2 (headless): 25 suites, 0 failures; Generated tickets 65, Diagnosis 58,
  Morning report 27.

### Decisions
- D153 (user approved): option B for test parts, morning arrivals from reputation and rating, difficulty
  by night, the pool incl. customer overclocks and clueless customers, parody-name customers.
- D154 (proposed): every number above (rating, arrivals, return chance, level caps, pool levels, pay).

### Known issues and open items
- A PC with no graphics card at all at the hardware bench still boots (older gap; generated cases use the
  repair-bench "card out" state instead). For Codex's review.
- Returning generated customers bring the PC they had, not the repaired build they collected.
- Two shop purchases in one case are not budgeted together by the solvability proof (each is checked alone).
- Storage: more than about three PCs fill the starting rack; extras wait for space until more furniture is bought.

### Next action
Codex cross-reviews; the user merges. Playtest gate after 3.4/3.5. Next plan session: 3.6 testing bay (talk first).

## 0.47.1 - 2026-11-18 - Reconcile bug register and enforce complete component journeys

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work.
  No deployment id is invented; this limitation remains explicit against D51.
- Based on: main 0.47.0, ed64f21835a1610d39bb5c6f37b6686de2f33279 (PRs #57 and #58 merged).
- Type: patch (bug-register/tooling/test improvements; no gameplay or save-schema change).

### Execution status
Target Godot 4.7.2 headless import and the new Part lifecycle suite ran locally (38 checks, zero
failures). All 25 required Godot suites passed (1,805 checks); Python checker results are below.
No manual graphical playtest or new player-facing diagnosis/manual feature is claimed.

### Added / Changed / Fixed / Removed
- Reconcile all 47 historical bugs into one canonical index and per-bug details. Add status, severity,
  area and evidence types; distinguish recorded fixes from automated/graphical/user verification.
- Correct stale next-review (now 0.50.0), RC-1/RC-4 merge status and RC-2's diagnosis-unsafe wording.
  Preserve historical reviews as explicitly superseded quotations, not active instructions.
- Track existing customer-part identity and orphan-custody limitations as L1/L2 Investigating rather
  than pretending all structural issues are solved. Define RC-5 for identity/custody journey failures.
- Add an always-run register checker and malformed-ledger unit fixtures. Validate index/detail/id
  consistency, status/severity, evidence paths and review deadlines; do not infer runtime correctness.
- Add a required cross-PC Part lifecycle suite: identical original models with different health,
  distinct same-model spares, exclusive custody, damage/return, active/inactive reload, collection,
  repeat settlement, stale measurement history and malformed optional external data.
- Record component invariants and a staged physical-part migration contract in PART_LIFECYCLE.
  Update AGENTS, handoff, testing/work plan and current state so other AIs preserve the checks and
  coordinate with Claude's open #59 instead of racing shared runtime files.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `docs/BUGS.md` | M | One index/details, explicit evidence/status, current RCs, limitations, preserved history |
| `docs/PART_LIFECYCLE.md` | A | Invariants, migration acceptance and AI integration boundaries |
| `tools/check_bug_register.py` | A | Ledger validation and due-review guard |
| `tools/test_bug_register.py` | A | Malformed-ledger validation fixtures |
| `tools/test_part_lifecycle.gd` | A | Complete two-PC custody/health/identity/reload journeys |
| `.github/workflows/tests.yml` | M | Always-run ledger checks and required lifecycle suite |
| `AGENTS.md`, `HANDOFF.md`, `docs/WORK_PLAN.md`, `docs/CURRENT_STATE.md`, `docs/TESTING.md` | M | Other-AI instructions, status/evidence and next-stage boundaries |
| `DEVELOPMENT.md` | M | New tooling/docs file-map entries |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Patch version, scope and evidence |

### Checks performed
- Target import: Godot 4.7.2, passed.
- Part lifecycle: 38 checks, zero failures.
- All 25 required Godot suites: 1,805 checks, zero failures and no script/parse errors.
- Scripted bench smoke: Playtest finished, no script/parse errors.
- Register checker: zero problems; malformed-register fixtures: 12 tests passed.
- CI scope fixtures: 9 tests passed.
- Project checker: passed, zero problems. `git diff --check`: passed.

### Decisions proposed (not approved)
No new gameplay. Exact canonical part-record field layout and orphan-recovery policy remain design/
implementation proposals; this PR records acceptance criteria, not a second writable registry.

### Known issues and open items
L1/L2 remain Investigating. The full stable customer-part migration is not implemented by these tests.
Historical B1–B41 evidence is not reconstructed or asserted as reverified. Open #59 modifies overlapping
workflow/docs/version metadata; the second integrator must preserve both sets of changes and all IDs.

### Next action
Claude cross-review, then user-controlled merge. Reconcile with #59 using HANDOFF/PART_LIFECYCLE
instructions. Coordinate ownership before runtime identity migration; keep it incremental and prove
complete journeys. The manual remains deferred. No merge authorized by this task.

## 0.47.0 - 2026-11-18 - Diagnosis: Findings notebook, Stress lab, 06:00 test limit

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a Claude Code cloud session.
- Based on: 0.46.3 (PR #57 head 02b6343, not yet merged); this branch is stacked on it.
- Type: minor (session 3.4: new player-facing diagnosis features under D150).

### Execution status
Godot was not run locally by Claude. GitHub Actions ran every suite headless on Godot 4.7.2: all 24
suites passed, including the new Diagnosis suite (55 checks). No manual graphical playtest has been done.

### Added
- **Findings notebook** on every PC (Findings tab beside the monitor; it also opens on the big screen).
  It keeps what you SAW (opening the repair bench: dust per part, parts out, cooler lever, visible
  damage; opening the hardware bench: fitted parts by model and owner, empty slots, the customer's parts
  in the drawer), what tests MEASURED (boot, Hardware check, game test, anti-virus scan, quick stress,
  Stress lab) and what you DID (parts out/in with owner and test-part stock id, cleaning, repaste,
  overclock changes, anti-virus removal, visible damage). Each entry carries the night number and the
  night clock; timed tests keep their start and end. Older looks and readings stay readable and are
  marked outdated once the PC changes. The customer's complaint heads the notebook. No conclusions,
  no hints, nothing hidden.
- **Stress lab**: the long load test is its own monitor app (20 minutes, $2 electricity). Temperature
  readings every 5 minutes on the night clock, when the fans get loud, and whether and when the PC
  crashes; a crash ends the run and only the minutes run are spent. It reports behaviour, never a cause.
- Diagnosis solvability and difficulty rules (`diagnosis.gd`, tests only): both story PCs are proven
  solvable with the starter stock; Mara's is evident, Relu's needs a known-good GPU swap before the
  masked adware can be scanned.

### Changed
- Timed tests (game test, Stress lab) are refused before any charge when they would end after 06:00.
- Switching the PC off during a timed test notes it as INCOMPLETE with no result (still no time spent).
- Monitor layout: Vapor / game test / Stress lab on the second row; the overclocker row keeps the quick
  stress test; three tabs: Work, Findings, Client.
- Hardware check failure line: "something is missing, too small or not locked" (it cannot see broken parts).
- After Codex's answers on PR #58: Relu's complaint now matches what his PC shows ("The frame rate suddenly
  tanked; now the PC powers on but the screen stays black. I can't play Counter Stroke at all."); his GPU
  fault and FPS requirement are unchanged. The solvability check now requires a spare that suits the PC
  (the PSU must power a test GPU), not just a part of the right kind.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/findings.gd` | A | Notebook entries, sanitize, outdated marking, bench inspection texts, part labels with owner |
| `scripts/rules/stress_lab.gd` | A | The Stress lab run: readings, loud fans, deterministic crash minute |
| `scripts/rules/diagnosis.gd` | A | Solvability and difficulty from the hidden truth (tests / future generator only) |
| `tools/test_diagnosis.gd` | A | 55 checks: notebook, secrecy, work history, save/switching, Stress lab, 06:00, solvability |
| `scripts/state/game_state.gd` | M | `findings` on the job, `note`/`record_finding`/`findings_text`, work logging inside mutators, `diagnosis_capabilities` |
| `scripts/night/software_view.gd` | M | Stress lab app, Findings tab, measurements noted, 06:00 guard, incomplete note on power-off |
| `scripts/night/repair_view.gd`, `scripts/night/hardware_view.gd` | M | Inspection noted when the bench opens |
| `scripts/night/night_session.gd` | M | The second demo PC starts with its own empty notebook |
| `scripts/rules/night_clock.gd` | M | `fits()`: does a test still end by 06:00 |
| `scripts/rules/work_report.gd` | M | Hardware check failure wording |
| `scripts/data/customers.gd` | M | Relu's complaint wording (Codex's correction) |
| `tools/test_software.gd` | M | Tab state and scan-notebook expectations |
| `.github/workflows/tests.yml` | M | Diagnosis suite registered |
| `DEVELOPMENT.md`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `HANDOFF.md` | M | File map, diagnosis contracts, D152 proposals, 3.4 status and the deferred manual item, handoff |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version 0.47.0 and release notes |

### Checks performed
- `python3 -I tools/check_project.py`: passed (0 problems).
- GitHub Actions on Godot 4.7.2 (headless): 24 suites, 0 failures; Diagnosis 55, Software 38,
  Hardware parts 67, Real hardware 85, Morning report 27, Regressions 625.

### Decisions proposed (not approved)
- D152 (1)–(6): notebook shape and sources, Stress lab numbers (5-minute readings, 10-minute warm-up,
  crash at minute 3 / 14), the 06:00 refusal, the Hardware check wording, difficulty levels 1–3.

### Known issues and open items
- The diagnosis manual is not built: the user deferred it on 18 November 2026 as a separate later item (WORK_PLAN 3.4m).
- `diagnosis.gd` is not a finished solvability proof for generated tickets (Codex): workload fit and
  test sequencing still need the 3.5 design/validation gate. Its levels are internal labels only.
- The notebook is read at the monitor only; the benches write into it but do not display it.
- Customer-part identity is still slot-derived (known since 0.46.2).

### Next action
Codex cross-reviews this PR after PR #57; the user controls both merges (PR #57 first). Playtest gate after 3.4.

## 0.46.3 - 2026-11-18 - PR 57 review fixes: preserve the PC, component damage and test validity

- Author: Codex (GPT-6; exact deployment model id not exposed by this session) in ChatGPT Work.
  No deployment id is invented; this limitation remains explicit against D51.
- Based on: reviewed PR #57 head 07d7cb978befcf937cdd13b6e44a4bf4733e4266 (0.46.2), based on main 0.46.1.
- Type: patch (user-authorized corrections to the compatibility patch; no new diagnosis/manual feature).

### Execution status
Godot 4.7.2 was run locally by Codex, headless. The expanded hardware suite reproduced 23 failing
assertions against the original reviewed code, then passed all 67 checks after the fixes and the additional spare-CPU pickup guard. All 23 required
suites passed (1,708 checks total, including the final hardware-suite rerun). No manual graphical playtest is claimed.

### Added / Changed / Fixed / Removed
- Collection writes fitted shop hardware into the permanent PC record before clearing custody;
  effective build, morning card, reload and repeated settlement preserve the actual machine.
- A damaged shop GPU/cooler stays damaged when removed. Clear the test-part flags before restoring
  the customer's own state. Retain the damaged shop record across save/load and show known damage.
- Fingerprint catalogue parts, temporary fitted-part identity and dead slots so changed hardware
  invalidates prior hardware, FPS and temperature measurements.
- Resolve existing starter RAM/CPU (and trial GPU/cooler) to catalogue models without replacing their
  owned uid. Bench acceptance no longer depends on the stock record being catalogue-format.
- Enforce cooler-before-CPU removal for shop test CPUs too. Persist a compatible one-time starter CPU
  migration marker so handing it over cannot manufacture a free replacement on the next load.
- Update handoff/work ownership for the user's bounded request that Codex fix PR #57; Claude resumes
  the standing runtime assignment after reviewing/integrating this follow-up. No merge authorized here.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/state/game_state.gd` | M | Permanent handover, component damage restoration, damaged stock load, starter migration, legacy fitting |
| `scripts/rules/pc_build.gd` | M | Resolve existing starter stock to its model |
| `scripts/rules/work_report.gd` | M | Hardware-aware result signature |
| `scripts/night/hardware_view.gd` | M | Format-independent fitting and shop CPU removal guard |
| `tools/test_hardware_parts.gd` | M | Handover/reload/repeat, damaged swaps, stale results and real bench starter-part regressions |
| `HANDOFF.md`, `docs/WORK_PLAN.md` | M | Current status and bounded Codex/Claude handback |
| `DEVELOPMENT.md`, `docs/BUGS.md`, `docs/DECISIONS.md` | M | Additive save contract, B42–B47 and superseded trial-stock restriction |
| `README.md`, `project.godot`, `CHANGELOG.md` | M | Version, release notes and validation |

### Checks performed
- Target import in Godot 4.7.2: passed.
- Hardware parts: 67 checks, 0 failures (23 new regression assertions failed before the runtime fixes).
- `python3 tools/test_ci_scope.py`: 9 tests passed.
- All 23 required Godot suites passed: 1,708 checks, 0 failures (the final hardware-suite rerun
  raised its count from 66 to 67; the other 22 suites were unchanged).
- Scripted bench smoke diagnostics: Playtest finished, no script/parse errors.
- `python3 -I tools/check_project.py`: passed, 0 problems. `git diff --check`: passed.

### Decisions proposed (not approved)
No new design. Existing trial prices/timings and D151's other proposed behaviour remain provisional.

### Known issues and open items
Identical customer-part identity is still slot-derived and orphan custody has no recovery UI, as
already documented by Claude. No new diagnosis notebook/manual/cases, no manual visual acceptance.
An old save lacking starter_cpu_seeded gets the existing one-time CPU migration; new saves persist it.

### Next action
Push to PR #57 for review; user controls merge. Claude then resumes 3.4 from the reconciled baseline,
preserving these invariants. Codex retains manual/design content and cross-review responsibilities.

## 0.46.2 - 2026-11-18 - Diagnosis compatibility patch: no hidden-health leaks, test-part custody (D150)

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.46.1 (main 39b1884, PR #56 merged)
- Type: patch (compatibility with the approved diagnosis rules; no new diagnosis features; job gains optional `damaged_parts`, `shop_fitted`, `shop_custody`, `dead_slots`; stock records may carry `fitted_in`/`slot`)

### Execution status
Godot was NOT run by me. GitHub Actions run 44200267247: all required suites green and the full scripted bench diagnostics. The first run (44199925403) failed four checks: three tests still asserting the D149 behaviour, and one real bug (B41, Rearrange drawer pulled a fitted test part out). No interactive playtest is claimed. Codex cross-review requested; the user controls the merge.

Correction — 18 November 2026, Codex (GPT-6; deployment id unavailable): cross-review found that
hardware/test-part changes were NOT included in the measurement signature; the "No conflict found"
audit statement below was incorrect. Collection and damage-return bugs were also found. See 0.46.3
for the reproductions/fixes; the remainder below is the historical 0.46.2 report.

### Audit (HANDOFF resume order step 2) and what changed
Hidden-health leaks found in merged code (mostly Claude's own 0.38–0.46 work), all removed:
- Hardware bench: red BROKEN tags and "Condition: BROKEN/working" on hover cards. Now only VISIBLE damage the player caused (pick snap, new `damaged_parts`) is labelled DAMAGED; hover cards show model, owner and where.
- Boot check, hardware check, night diagnosis, final check: "GPU: BROKEN - replace at...". Now missing/out parts are named ("NOT FITTED"), visible damage is named, and a hidden fault only shows as an observation (`PartStates.boot_symptoms`: GPU "no image on the screen", cooler "switches itself off after a few seconds"). The hardware check reports presence and configuration only.
- Ticket parts summary, Work tab ("still broken"), part lines ("not working or not fitted"), room card ("Needs repair"): presence only.
- Fitting permissions as an oracle: stock tiers only over a BROKEN part, the repair bench's Replacement stock enabled only for broken parts, "broken: it cannot go back in", "the customer's GPU works", the pick refusing a hidden-broken part. Now only physical fit decides; a dead customer card can be fitted and simply adds nothing (`dead_slots`).
Custody (D150 5.6 supersedes D149's transfer at fitting):
- A fitted shop part (first GPU / cooler replacement or any catalogue part in another slot) stays a player stock record marked `fitted_in` until collection; taking it out returns it to the drawer; the customer's original stays theirs (loose, `original_of`).
- `settle_custody()` at collection (morning) and at the legacy shop's paid final check: fitted shop parts go home with the PC (already paid when bought, no second charge); a working customer original that a shop part replaced enters player stock; others leave with the customer. The morning card lists what was kept.
- The pickup score reads RAM and processing from what is actually in the PC (test parts included).
No conflict found: hidden film/screw flags stay out of checks; measurements already go outdated on changes; the clock is the shared night clock (Findings timestamps are 3.4 work). Not changed, for Codex to rule on: the GPU's bracket screws are drawn loose/tight on the hardware bench (physical, D131).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/part_states.gd`, `scripts/rules/pc_build.gd`, `scripts/rules/customer_pc.gd`, `scripts/rules/software_checks.gd`, `scripts/rules/work_report.gd` | M | Known vs hidden, observations, test parts in stats, dead slots |
| `scripts/state/game_state.gd` | M | Visible damage, custody, return, settlement, load sanitizing |
| `scripts/night/hardware_view.gd`, `scripts/view/bench_view.gd`, `scripts/view/bench_parts.gd`, `scripts/view/bench_cleaning.gd`, `scripts/storage/storage_sources.gd`, `scripts/night/morning_view.gd` | M | No health in UI or permissions; custody on the bench; morning "kept" line |
| `tools/test_regressions.gd`, `tools/test_hardware_parts.gd`, `tools/test_software.gd`, `tools/test_night_workshop.gd` | M | D115-era and D149-era assertions rewritten to D150; custody, return, dead card, settlement |
| `README.md`, `CHANGELOG.md`, `project.godot`, `docs/DECISIONS.md`, `docs/BUGS.md` | M | Docs, version, B41 |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
D151: the symptom wording; visible damage named; settlement pairs a loose working original with a shop part of the same type; trial stock tiers only in the first GPU slot / cooler mount.

### Known issues and open items
Individual identity of identical customer parts is by slot order (not a per-part id). A stale `fitted_in` mark cannot be cleared from the UI if its ticket vanished. Not playtested.

### Next action
Codex cross-review; user merge. Then 3.4 (0.47.0) on this baseline.

## 0.46.1 - 2026-11-17 - Correct current handoff before parallel-work proposals

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: main 0.46.0 (b6004d2d04bb3c97cb7d40ffa93a556760257b08)
- Type: patch (documentation accuracy and matching release metadata only)

### Execution status
No game code changed. Godot was not run for this docs-only correction. The existing 0.46.0 CI
results are attributed to that version, not presented as this patch's new tests. No gameplay
implementation or manual playtest is claimed. Date: 17 November 2026, Europe/Bucharest.

### Added / Changed / Fixed / Removed
- Replace the misleading top-level 0.42.0 handoff with a verified current summary: shipped
  0.46.0 hardware bench, including the 3.3b merge that arrived during this correction.
- List shipped menu, bench split, tickets, morning cycle and thermal fixes; clarify current
  hardware/monitor integration and remaining Wave 3 sessions/design discussions.
- Separate D148 decisions from implemented trial proposals. Count actual catalogue records:
  28 (5 CPU, 5 GPU, 4 RAM, 4 storage, 5 PSU, 5 cooler), correcting the old reported count of 27.
- Mark old handoff status blocks historical, preserving provenance. Warn that the old blanket
  no-implementation introduction and old shared-PC proposal do not describe today's main.
- State coordination requirements and Codex's exact authorization: correct handoff, present choices,
  wait. No parallel feature, balance proposal document or code is started.
- Match README/project version to this docs patch; no WORK_PLAN.md or runtime script edits.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `HANDOFF.md` | M | Authoritative current state, decisions/proposals, history and ownership |
| `CHANGELOG.md` | M | Signed documentation-only correction |
| `README.md` | M | Patch version and no-gameplay-change note |
| `project.godot` | M | Version metadata only |

### Checks performed
- Reconciled handoff with project version, latest changelog, D148, Wave 3 work plan and catalogue.
- Counted catalogue declarations by type: 28 total. No catalogue file was edited.
- `python3 -I tools/check_project.py`: PASSED, 0 problems (see checker output for current counts).
- `git diff --check`: passed. No Godot run; no CI result for this patch claimed yet.

### Decisions proposed (not approved)
None implemented. Parallel-work choices will be presented to the user after the handoff correction.

### Known issues and open items
3.3b is now merged; CPU removal/paste-stage synchronization and slot-order refitting remain limitations. Shared design files
may retain historical wording; this patch deliberately corrects HANDOFF first. No runtime re-test.

### Next action
Wave 3 session 3.4 is next; confirm Claude's next assignment before parallel code.
Codex presents choices and waits for approval before any further work. No hot files touched;
no merge assumed. Preserve existing archives and create archive/v0.46.1 for the correction.

## 0.46.0 - 2026-11-17 - Wave 3 session 3.3b: hardware bench parts

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.45.0
- Type: minor (new bench behaviour; job gains optional `loose_parts`; stock records may be catalogue parts; parts may have empty slots)

### Execution status
Godot was NOT run by me. GitHub Actions run 44148883923: all 25 required suites green, including the new Hardware parts suite (27 checks), and the full scripted bench diagnostics. The first run caught the PSU connector at the compact board edge (B40). No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Added (D149): CPU, RAM, drives and the PSU come out at the hardware bench into the drawer and back; the customer keeps them as loose parts. The cooler must come off before the CPU.
- Added: board connectors for a second PCIe slot, two drives and the PSU; drawing for drives and PSUs.
- Added: Order parts on the hardware bench: any catalogue part into the drawer; fits any empty matching slot.
- Added: catalogue cards and coolers can upgrade a working first card / cooler taken out (tier `model:<id>`); the customer's old part stays loose and can be swapped back.
- Changed: a PC missing its CPU, RAM, drive or PSU does not start; the hardware check reports missing parts and a too-small PSU.
- Changed: Rearrange drawer repacks the drawer only.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `tools/test_hardware_parts.gd` | A | Suite |
| `scripts/rules/customer_pc.gd`, `scripts/rules/pc_build.gd`, `scripts/data/hardware_catalog.gd`, `scripts/data/service_parts.gd`, `scripts/data/component_data.gd`, `scripts/state/game_state.gd`, `scripts/night/hardware_view.gd`, `scripts/view/workshop_view.gd`, `scripts/rules/part_states.gd`, `scripts/rules/software_checks.gd`, `scripts/rules/work_report.gd` | M | Parts in and out, stock, upgrades, checks |
| `tools/test_hardware_ticket_pc.gd`, `.github/workflows/tests.yml` | M | Lock test updated, suite registered |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `docs/HARDWARE_CATALOG.md` | M | Docs and version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
Connector positions; fitted parts are free for the customer.

### Known issues and open items
Removing the CPU does not change the repair bench's paste stage. RAM and drives refit in slot order, not the exact slot. Not playtested.

### Next action
Session 3.4 (0.47.0): diagnosis.

## 0.45.0 - 2026-11-17 - Wave 3 session 3.3: real hardware

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.44.1
- Type: minor (new hardware model; job gains `parts`; `pc_specs` is now derived; game demands rescaled)

### Execution status
Godot was NOT run by me. GitHub Actions run 44134587054: all 24 required suites green, including the new Real hardware suite (85 checks). The first run (44134189559) failed only the data-schema guard, which needed the two new keys declared. No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Added (D148): `hardware_catalog.gd` (27 parody-named parts with six stats and prices) and `pc_build.gd` (a PC's stats from its parts; PSU and cooler support; several GPUs; replacements and broken parts applied).
- Changed: every customer PC is a parts record (`job["parts"]`, the customer's `pc`); `pc_specs` is derived from it; old saves get the customer's own PC.
- Changed: the boot check refuses a PC whose parts draw more than the PSU gives; the shop's check and the monitor add heat when the cooler is too small for the CPU (this replaces the budget cooler's fixed +8 °C with the same 8 °C from its capacity).
- Changed: FPS, the pickup and the diagnosis read graphics, processing and RAM from the parts. Counter Stroke 2's demands moved to the new scale (11 / 15) so the demo PCs perform exactly as before.
- Changed: the two repair-bench stock tiers are named catalogue models with the old prices; the ticket, the Work tab and the hardware bench show every part by name and the six stats.
- Changed (tests): the 0.25 FPS and pickup assertions use the new scale with the same meaning.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/data/hardware_catalog.gd`, `scripts/rules/pc_build.gd`, `tools/test_real_hardware.gd`, `docs/HARDWARE_CATALOG.md` | A | Catalogue, rule, suite, part list |
| `scripts/data/customers.gd`, `scripts/data/games.gd`, `scripts/data/service_parts.gd`, `scripts/state/game_state.gd`, `scripts/night/night_session.gd`, `scripts/night/night_diagnostics.gd`, `scripts/rules/software_checks.gd`, `scripts/rules/customer_pc.gd`, `scripts/rules/ticket.gd`, `scripts/rules/work_report.gd` | M | Parts everywhere |
| `tools/test_regressions.gd`, `.github/workflows/tests.yml` | M | Rescaled assertions, suite registration |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/WORK_PLAN.md`, `docs/REPAIR_LOOP_DESIGN.md` | M | Docs, plan split, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
Every number in docs/HARDWARE_CATALOG.md; multi-GPU halving; 50 W base; 0.5 °C per excess watt.

### Known issues and open items
CPU, RAM, storage and PSU cannot be taken out yet, there is one PCIe slot, and only the two stock tiers can be bought: session 3.3b. Not playtested.

### Next action
User reviews the part list; session 3.3b (0.46.0).

## 0.44.1 - 2026-11-17 - Thermal service clarity (user playtest)

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.44.0
- Type: patch (bench feedback and one order change; no save change)

### Execution status
Godot was NOT run by me. GitHub Actions run 43966771126: all required suites green (install technique 33 checks, including the three playtest fixes) and the full scripted bench diagnostics. No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Fixed (B37): the screws could not be done while holding Space: the screwdriver was refused until the 10-second press ended. It can now be taken at any time during the press; with it in hand the mouse turns screws and Space alone presses (D147).
- Fixed (B38): after the lever the cooler and its screws vanished (only the paste inspection was drawn). The locked cooler frame and its tight screws stay drawn over the paste.
- Fixed (B39): after the lever the squeezed-out figure stayed frozen while wiping, and nothing confirmed the job. It now follows the wiping, says "Clean" below 2%, then "Thermal service DONE" and the next step.
- Added: the thermal guide (steps + one NOW line) replaces the bare steps line; a verdict line after the lever.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/view/bench_thermal.gd`, `scripts/view/bench_input.gd`, `scripts/view/bench_view.gd`, `scripts/view/paste_renderer.gd` | M | Guide, verdict, screws during press, locked cooler, live wiping |
| `tools/test_install_technique.gd` | M | New checks for all three fixes |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `project.godot`, `docs/DECISIONS.md`, `docs/BUGS.md`, `docs/INSTALL_TECHNIQUE.md` | M | Docs and version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
"Clean" threshold 2%; guide wording.

### Known issues and open items
Not playtested. The guide is drawn text at fixed positions; long lines may need shortening after a look.

### Next action
User re-tests the thermal service; then session 3.3 after the part-list talk.

## 0.44.0 - 2026-11-16 - Wave 3 session 3.2: night end and morning report

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.43.0
- Type: minor (new screen and night cycle; save gains optional `night_number`, `comebacks`; ticket flags gain `nights`)

### Execution status
Godot was NOT run by me. GitHub Actions run 43963132597: all 22 required suites green, including the new Morning report suite (27 checks). The first run caught a parse error (B36). No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Added (D136/D146): End the night on Activities (confirmation names who collects; at 06:00 the only choice). `NightSession.end_night`: earlier comebacks arrive, called customers collect, others wait a night, collected PCs leave, new customers bring theirs, the clock resets, the night number goes up.
- Added: `morning.gd`: which hidden faults are felt now (film, uneven/loose cooler, malware) and which come back two mornings later (loose GPU screws, unstable/crashing overclock); pay only if the PC starts; reactions; comeback countdown.
- Added: the morning report screen, one card per PC, hover for the PC's state, Start the next night.
- Changed: `GameState.assess()` is the shop's own check without paying (the final check uses it unchanged); `collect_active()`, `advance_comebacks()`, `make_ticket_job()`, `start_next_night()`.
- Changed: the monitor refuses game tests and the long stress test after 06:00.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/morning.gd`, `scripts/night/morning_view.gd`, `scenes/morning.tscn`, `tools/test_morning.gd` | A | Rule, screen, suite |
| `scripts/state/game_state.gd`, `scripts/night/night_session.gd`, `scripts/night/activities_view.gd`, `scripts/night/software_view.gd`, `scripts/rules/ticket.gd`, `tools/test_tickets_pickup.gd`, `.github/workflows/tests.yml` | M | Collection, night cycle, End the night, 06:00 limit, nights counter |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/REPAIR_LOOP_DESIGN.md`, `docs/WORK_PLAN.md`, `docs/MENU_NAVIGATION.md` | M | Docs and version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
D146's implementation choices: pay only if it starts, -10 trust for a dead PC, two mornings for comebacks, no penalty for waiting yet.

### Known issues and open items
Only two customers exist, so new tickets are the same two people (variety is session 3.5). The report is not kept after quitting. Waiting PCs cost nothing yet.

### Next action
Playtest gate (the loop now closes). Then session 3.3 after a short talk: the part list and stat numbers.

## 0.43.0 - 2026-11-16 - Wave 3 session 3.1: tickets and pickup

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.42.0 (Codex's menu navigation, integrated by Claude on top of 0.41.2)
- Type: minor (new player actions; job gains optional `ticket`; old saves load as open)

### Execution status
Godot was NOT run by me. GitHub Actions run 43958975963: all 21 required suites green, including the new Tickets and pickup suite (30 checks, with native right-clicks in the room and on the ticket). Two earlier runs caught a crash in the ticket rule (B34). No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Added (D134/D135): `ticket.gd`, a ticket as one record derived from the job (request, customer, machine, symptoms, requirements, terms, status), with the pickup flags stored in `job["ticket"]`.
- Added: right-click a customer PC in the workshop room, or the ticket at the top of the workbench, for **Mark ready for pickup** (READY sticker, a note only) and **Call the customer** (CALLED tag: collects next morning). Both undo. Clicking the ticket opens the full ticket with the same two buttons.
- Added: `NightSession.ticket_action` changes any of tonight's tickets, active or stored, and saves both files; refused on a protected manifest or a collected ticket.
- Changed: the room's PC details show the ticket status.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/ticket.gd`, `scripts/night/ticket_menu.gd`, `tools/test_tickets_pickup.gd` | A | Rule, shared menu and window, suite |
| `scripts/state/game_state.gd`, `scripts/night/night_session.gd`, `scripts/night/night_navigation.gd`, `scripts/storage/storage_view.gd`, `.github/workflows/tests.yml` | M | Field, session API, header ticket, room right-click and stickers, suite registration |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/REPAIR_LOOP_DESIGN.md`, `docs/WORK_PLAN.md`, `docs/MENU_NAVIGATION.md` | M | Docs and version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
D145 (the header identity is the ticket); sticker colours.

### Known issues and open items
Calling has no effect yet: the morning (collection, pay, report) is session 3.2. The ticket has only repair requests.

### Next action
Session 3.2 (0.44.0) after a short talk: which hidden faults show at pickup and which come back later.

## 0.42.0 - 2026-11-16 - Direct workbench tabs, room modes, Pause and Continue

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Integrated by: Claude (Opus 5.5, model id claude-opus-5-5), 16 November 2026, on top of main 0.41.2 (repair-bench split). The user had playtested it. Its decisions D134–D136 were renumbered D142–D144 (main already had D134–D141). Integrated tree: GitHub Actions run 43952711926, all required suites green.
- Based on: merged main 0.41.0 (1a46912), including Claude's 0.38–0.41 work; new feature/menu-navigation branch
- Type: minor (approved menu roles/paths, real Pause and compatible UI-only resume preferences)

### Execution status
Codex ran Godot 4.7.2 headless locally: nineteen required suites, final applicable total 1,427
checks, zero failures; pending contracts 0/0. Native viewport input covers transitions. No manual
visual playtest or target-hardware benchmark claim. Date: 16 November 2026, Europe/Bucharest.
User approved implementing the proposal, documenting future rules and pushing; no merge requested.

### Added / Changed / Fixed / Removed
- D142: room PC slot opens work directly; remove service chooser. Keep old night_workshop scene
  only as a compatibility redirect. Shared Repair/Hardware/Monitor tabs use the SAME selected PC;
  parent ← Room, PC identity centrally, Activities top-right, Pause beside it. Repair retains its
  Cleaning/Thermal tabs. Hide obsolete footer navigation/practice entries on the night repair route.
- Build from actual 0.41 main: Hardware already projects the customer's PC (D131). Preserve its
  screwdriver/install/stock rules and all current monitor apps, timed tests/work reports and Shop.
- D143: normal room hides furniture controls, titles cannot move furniture accidentally. Arrange
  room reveals add/remove/packing and allows title dragging. Done cancels temporary hands. Camera
  stays available. Slot selection is gated during arranging. No routine Save layout/Refresh button:
  edits autosave; status reports success, a real failure reveals Retry and blocks losing that layout.
- D144: Continue loads regular save/ticket first, then last valid activity/view. Remember last
  workbench view and Repair subview per ticket. Run-bound UI preference sidecar owns no game data;
  whitelist paths, tolerate old/missing/corrupt data, protect newer format, cap maps. No per-frame IO.
- Real Pause stops physics/monitor waits; Resume, existing sound Settings and guarded Title exit.
  F10 toggles; Escape closes pause/settings, preserving existing activity Escape controls otherwise.
  Repair releases active use/audio; salvage retains its prior local pause/custody rules. Main menu
  is removed from activity body. Busy monitor tests must finish/cancel with existing power action
  before navigating; saves/custody use scene-specific exits. UI-only preference failure cannot
  overwrite repairs; Pause warns Continue may fall back.
- Mandatory MENU_NAVIGATION.md linked from AGENTS/DEVELOPMENT/core docs and new CI suite. Older
  path/status/sandbox notes are explicitly historical. No hot files or WORK_PLAN.md edits.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `AGENTS.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `CHANGELOG.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `DEVELOPMENT.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `HANDOFF.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `README.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/BUGS.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/CURRENT_STATE.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/DECISIONS.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/DESIGN.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/MENU_NAVIGATION.md` | A | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/NIGHT_WORKSHOP.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/PROJECT_BRIEF.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/ROADMAP.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/ROOM_WORKSHOP.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/SOFTWARE_WAVE_2.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/STORAGE.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `docs/TESTING.md` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `project.godot` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/activities_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/hardware_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/navigation_state.gd` | A | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/night_navigation.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/pause_menu.gd` | A | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/repair_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/salvage_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/shop_activity_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/software_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/night/workshop_hub.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/storage/storage_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `scripts/view/start_view.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `tools/test_menu_navigation.gd` | A | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `tools/test_night_workshop.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `tools/test_room_workshop.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |
| `tools/test_storage.gd` | M | Approved navigation/mode/Continue behavior, native regression coverage or permanent documentation |

### Checks performed
- Godot 4.7.2: schemas 209; regressions 599; start 20; dust 43; bench interactions 31; feedback 27;
  audio/vacuum 46; performance 24; salvage 49; salvage physics 44; storage 82; night workshop 55;
  software 36; room/workshop 30; thermal 26; install technique 24; hardware ticket PC 15;
  malware/overclock 34; menu navigation 33. All zero failures (1,427 final applicable checks).
- Native clicks validate normal/Arrange, retry, direct Resume, same-PC tabs/paste, monitor-busy exit
  refusal, actual Pause, paused Title exit and Continue. Settings, future/unknown/missing/new-run UI
  preferences and no money/stock/repair mutation covered. Final menu suite rerun after last header/
  practice-visibility changes. Expected forced-save-failure warnings are deliberate test fixtures.
- Existing storage/night/workshop tests replace obsolete hub/Save/Refresh assertions; ownership and
  native room-crash coverage retained. Three old extra-hub exit cases become shared-tab route coverage.
- Fresh extracted source imported in Godot 4.7.2 and passed all 33 menu-navigation checks without
  script errors; the deliberate failed-layout-write case emits its expected warning.
- Project hygiene, whitespace and CI scope (9 tests) passed. Full bench physics matrix not repeated:
  no core bench/tool/state or simulation changes; this is menus/wrappers and affected scene suites.

### Decisions proposed (not approved)
No new gameplay mechanics. F10 is the implemented pause shortcut to avoid stealing current Escape
hand cancellation. Ordinary hidden install faults, outing costs, test durations and pickups remain.

### Known issues and open items
- UI preference file cannot restore persistent salvage contents: salvage remains session-only under
  its existing prototype rules. Continue restores its screen, not a newly implemented salvage save.
- Main and UI preference files are separate; invalid/mismatched preferences fall back to Activities.
  Layout/game save failures block exit, preference-only failure warns without replacing repair data.
- No manual visual/feel acceptance yet. Current source is 0.42; older top-of-file status notes were
  superseded explicitly rather than deleting contributor history.

### Next action
User playtests the new review PR; Claude goes next for cross-review of route/save/pause boundaries.
Push requested; keep PR unmerged. bench_view.gd, tool_rig.gd and game_state.gd are untouched and
free subject to Claude's work-plan ownership; WORK_PLAN.md unchanged. Preserve archive/v0.41.0,
create unique archive/v0.42.0 and source ZIP. Future menu work MUST read MENU_NAVIGATION.md.

## 0.41.2 - 2026-11-16 - Wave 3 session 3.0: repair bench split (no visible change)

- Renumbered (Claude, Opus 5.5, model id claude-opus-5-5): this release was first merged as 0.42.0 (PR #48), but
  Codex's open PR #46 had already claimed 0.42.0 and pushed `archive/v0.42.0`. It is now 0.41.2 (a patch: no
  gameplay change), so PR #46 keeps 0.42.0 and its archive. Cause: I listed open PRs through the GraphQL CLI,
  which is blocked here, and did not retry through the REST API. Decision ids also collide (PR #46 uses
  D134–D136, main already has D134–D141); that is resolved when PR #46 is integrated.

- Author: Claude (Opus 5.5, model id claude-opus-5-5) in a chat session
- Based on: 0.41.1
- Type: patch (code structure only; no gameplay, save or scene change)

### Execution status
Godot was NOT run by me. GitHub Actions run 43944339054 passed every required suite (599 regression checks, all bench suites) and the full scripted bench diagnostics. The first run (43942436349) caught one error: the typed `stage_buttons` array cannot be replaced through the dynamic handle; it is now filled in place. No playtest is claimed: the bench is meant to behave exactly as in 0.41.

### Added / Changed / Fixed / Removed
- Changed: `bench_view.gd` (1482 lines) is split into five helpers: `bench_thermal.gd`, `bench_cleaning.gd`, `bench_parts.gd`, `bench_ui.gd`, `bench_input.gd`. The bench keeps all its state and a one-line wrapper per moved method with the old name, so tests, signals and the night repair bench's overrides are unchanged. bench_view.gd is now about 610 lines.
- Method: the move was done by a script that copies each function body unchanged and prefixes every bench member it touches with `bv.`; calls to methods the night repair bench overrides always go through `bv.` so the override is kept.
- Changed: `tools/ci_scope.py` treats the helpers like bench_view.gd (full test run).
- Added (docs): the Wave 3 plan (D141, WORK_PLAN.md) and the build-request design (D140, REPAIR_LOOP_DESIGN.md 7a).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/view/bench_thermal.gd`, `bench_cleaning.gd`, `bench_parts.gd`, `bench_ui.gd`, `bench_input.gd` | A | Helpers |
| `scripts/view/bench_view.gd`, `tools/ci_scope.py` | M | Wrappers, helper instances, CI scope |
| `docs/WORK_PLAN.md`, `docs/REPAIR_LOOP_DESIGN.md`, `docs/DECISIONS.md`, `docs/BUGS.md`, `DEVELOPMENT.md`, `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `project.godot` | M | Plan, design, file map, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
None new in code. The uses table in REPAIR_LOOP_DESIGN.md 7a is a proposal.

### Known issues and open items
Bench state still lives on the bench; helpers reach it dynamically (no static type checks across the seam).

### Next action
Session 3.1 (0.43.0): tickets as records and the right-click pickup menu.

## 0.41.1 - 2026-11-16 - Design record: closing the repair loop (documents only)

- Author: Claude (Fable 5.2, model id claude-fable-5-2) in a chat session
- Based on: 0.41.0
- Type: patch (documents only; no code, scene, test or save change)

### Execution status
No code changed. Godot was not run. `python3 -I tools/check_project.py` passed.

### Added / Changed / Fixed / Removed
- Added: `docs/REPAIR_LOOP_DESIGN.md`, the design agreed with the user for pickup, tickets, the morning report, diagnosis and events, marked DECIDED / PROPOSED / OPEN.
- Added: D134 to D139 in `docs/DECISIONS.md`; a roadmap section; a current-state note.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `docs/REPAIR_LOOP_DESIGN.md` | A | The design record |
| `docs/DECISIONS.md`, `docs/ROADMAP.md`, `docs/CURRENT_STATE.md`, `DEVELOPMENT.md`, `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `project.godot` | M | Decisions, roadmap, file map, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems.

### Decisions proposed (not approved)
Everything marked PROPOSED or OPEN in `docs/REPAIR_LOOP_DESIGN.md`.

### Known issues and open items
None of the design is built. The user said no coding yet.

### Next action
Continue the design conversation (build requests, ticket objects, upgrades); code only when the user asks.

## 0.41.0 - 2026-11-16 - Hardware check, timed game tests, Work + match tab

- Author: Claude (Fable 5.2, model id claude-fable-5-2) in a chat session
- Based on: 0.40.0 (playtested by the user: no bugs found)
- Type: minor (monitor rework; job gains optional `tests` and `cured`; save gains `night_minutes`)

### Execution status
Godot was NOT run by me. GitHub Actions runs the suites on Godot 4.7.2 headless; run 43886013255 passed all 18 required suites. No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Changed (D133): "Final / thermal check" is now "Hardware check": parts in place and working, cooler locked. No temperature, no grading, hidden faults stay hidden.
- Changed: a game test takes 30 night minutes and the long stress test 20; the monitor is busy for about 3 real seconds with a progress bar. A night clock is shown (no end-of-night rule yet).
- Added: two tabs beside the monitor. "Work + match" (main): work done, and how measured results match the request; "Client" (second). Measurements are stored per ticket and marked outdated when the PC changes.
- Changed: the stress test at stock settings reports the temperature, so a temperature can be measured without owning a game.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/work_report.gd`, `scripts/rules/night_clock.gd` | A | New pure rules |
| `scripts/night/software_view.gd`, `scripts/state/game_state.gd`, `scripts/rules/overclock.gd` | M | Monitor rework, stored measurements, night minutes |
| `tools/test_software.gd`, `tools/test_malware_overclock.gd` | M | New behaviour covered |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/SOFTWARE_WAVE_2.md` | M | Docs and version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI: see Execution status.

### Decisions proposed (not approved)
30 and 20 night minutes; 3 real seconds of waiting; quiet up to 65 C in the match tab (same rule as pickup).

### Known issues and open items
The night clock has no consequence yet. The workshop hub's own diagnosis report still uses the old thermal summary. Not playtested.

### Next action
User playtest; decide what the night clock should end.

## 0.40.0 - 2026-11-15 - Wave 2: anti-virus and overclocker

- Author: Claude (Sonnet 5.5, model id claude-sonnet-5-5) in a chat session
- Based on: 0.39.0
- Type: minor (two new apps; the job gains optional `infection` and `overclock`; old saves load clean)

### Execution status
Godot was NOT run by me. GitHub Actions runs the suites on Godot 4.7.2 headless; run 43734168810 passed all required suites (18, incl. the new Malware and overclock suite). No interactive playtest is claimed.

### Added / Changed / Fixed / Removed
- Added (D132): `malware.gd` (adware, hidden miner, scan, pickup faults) and `overclock.gd` (multiplier, voltage, heat, stability, stress tests, pickup faults). Numbers are trial proposals.
- Added: Anti-virus scan / Remove threat and the Overclocker controls on the diagnostic monitor, replacing the two "later" buttons. The second demo PC arrives with adware.
- Changed: the shop's final check and the monitor include overclock heat; game tests and pickup use the overclocked CPU and the miner's CPU share.
- Changed: `GameState.pickup_faults(temp)` composes install, infection and overclock faults.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/malware.gd`, `scripts/rules/overclock.gd`, `tools/test_malware_overclock.gd` | A | New rules and suite |
| `scripts/night/software_view.gd`, `scripts/night/night_diagnostics.gd`, `scripts/night/night_session.gd`, `scripts/rules/software_checks.gd`, `scripts/rules/pickup_score.gd`, `scripts/state/game_state.gd` | M | Apps, heat, fps, faults, fields |
| `tools/test_software.gd`, `.github/workflows/tests.yml` | M | Scan replaces the future-app check; suite registered |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/BUGS.md`, `docs/SOFTWARE_WAVE_2.md` | M | Docs, version, 0.40.0 structural checkpoint |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI run 43734168810: all required suites green.

### Decisions proposed (not approved)
All D132 numbers: strain penalties, +6% power per step, +4 C per step, +3 C per voltage step, hot threshold 80 C, $2 long test.

### Known issues and open items
Only the demo ticket arrives infected. Not playtested.

### Next action
Playtest 0.38-0.40, then feedback.

## 0.39.0 - 2026-11-15 - Hardware bench shows the ticket's PC, screwdriver, Shop

- Author: Claude (Sonnet 5.5, model id claude-sonnet-5-5) in a chat session
- Based on: 0.38.0
- Type: minor (new tool, new activity, hardware bench rebuilt on the job record; job gains optional `gpu_screws`)

### Execution status
Godot was NOT run by me. GitHub Actions run 43726318789 passed all required suites (17, incl. new Hardware ticket PC) on Godot 4.7.2 headless. No interactive playtest is claimed, so how the screwdriver and the hardware bench FEEL is unverified.

### Added / Changed / Fixed / Removed
- Changed (D131): the hardware bench is a projection of the ticket's PC (`customer_pc.gd`): CPU, RAM, GPU, cooler. Removed or broken parts are in the drawer; every move writes back to the job. CPU/RAM are fixed for now; shop stock can only replace a broken, removed GPU or cooler.
- Added: a screwdriver tool. Cooler screws now come after the press and before the lever, with a steps line; GPU bracket screws are tightened at the hardware bench; loose GPU screws are a hidden pickup fault (`gpu_loose`).
- Added: the Shop, the third Activities button; all tool upgrades moved there from the workshop hub.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/customer_pc.gd`, `scripts/data/upgrades.gd`, `scripts/night/shop_activity_view.gd`, `scenes/night_shop.tscn`, `tools/test_hardware_ticket_pc.gd` | A | New |
| `scripts/night/hardware_view.gd`, `scripts/view/workshop_view.gd`, `scripts/view/bench_view.gd`, `scripts/view/tool_renderer.gd`, `scripts/view/paste_renderer.gd`, `scripts/bench/tool_rig.gd`, `scripts/data/ids.gd`, `scripts/rules/install_faults.gd`, `scripts/state/game_state.gd`, `scripts/night/activities_view.gd`, `scripts/night/workshop_hub.gd` | M | See above |
| `tools/test_install_technique.gd`, `tools/test_night_workshop.gd`, `.github/workflows/tests.yml` | M | Screwdriver flow, shop, suite registration |
| `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `project.godot`, `docs/DECISIONS.md`, `docs/INSTALL_TECHNIQUE.md` | M | Docs and version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED, 0 problems. CI run 43726318789: all required suites green.

### Decisions proposed (not approved)
D131 was requested by the user; its numbers (none new) need no approval.

### Known issues and open items
CPU/RAM locked in the hardware bench; repair-bench GPU refit needs no screws; cooler screws only at the repair bench; not playtested.

### Next action
Playtest, then user feedback.

## 0.38.0 - 2026-11-15 - Cooler install technique: the film, the screws and delayed discovery

- Author: Claude (Sonnet 5.5, model id claude-sonnet-5-5)
- Based on: 0.37.0 (9c894f8), Codex's PR #41. STACKED: this branch must merge after #41 (both touch bench_view.gd and game_state.gd)
- Type: minor (new compatible mechanic; job gains two optional fields, no save-format change)

### Execution status
Godot was NOT run by me. GitHub Actions runs the suites on Godot 4.7.2 headless; the result is
recorded here: run 43717692734 passed the required suites (all 16, including the new Install technique suite). No interactive playtest is claimed, so how the screws and film FEEL
is unverified.

### Added / Changed / Fixed / Removed
- Added (D130): `scripts/rules/install_faults.gd`, a pure rule for hidden installation mistakes.
  Film left on the cooler base (+30 C at the customer's PC, -30 pickup score), screws tightened
  round the square instead of opposite corners (+10 C, -12), screws skipped or half-turned
  (+15 C, -25). One wrong screw pair is forgiven. All numbers are trial proposals.
- Added: a "Cooler base" button on the Thermal service tab that peels the clear film (drawn as a pale
  blue sheet, never explained), and four clickable corner screws while a cooler is pressed on
  (two turns each, shown as snug/tight, never judged). The lever still locks the cooler (D57) and
  records the mistakes. The first screw shows a manual hint: opposite corners, two passes.
- Changed: `PickupScore.score` takes optional `faults`; heat and complaints apply to the CUSTOMER's
  check only. `run_final_check` temperature and notes are unchanged, so the shop's own test still
  passes and never mentions the mistake. The complaint appears in the pickup misses/history.
- Changed: `clear_paste` clears the recorded faults; peeled film stays peeled for the ticket.
- New job fields `cooler_film_peeled`, `install_faults`, validated on load (unknown ids dropped).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/rules/install_faults.gd` | A | Pure rule: faults, screw geometry, heat and annoyance |
| `scripts/rules/pickup_score.gd` | M | Optional faults: customer-only heat and complaints |
| `scripts/state/game_state.gd` | M | Two job fields, set/peel functions, fault pass-through to pickup |
| `scripts/view/bench_view.gd` | M | Film button, screw clicks, faults recorded at the lever |
| `scripts/view/paste_renderer.gd` | M | Cooler base and screw drawing |
| `tools/test_install_technique.gd` | A | New suite: rule, pickup, hidden final check, save, real clicks |
| `.github/workflows/tests.yml` | M | Register the suite |
| `docs/INSTALL_TECHNIQUE.md` | A | Design and numbers |
| `project.godot`, `README.md`, `HANDOFF.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `docs/DECISIONS.md`, `docs/TESTING.md` | M | Version and documentation |

### Checks performed
- `python3 -I tools/check_project.py`: passes. Godot not run by me; suite results below once CI finishes.

### Decisions proposed
D130: install mistakes are hidden from the shop's check and felt by the customer (the user's answer, 15 November 2026: "mistakes dont come to bite you until the customer checks"). The bench is meant to feel true to the real process without being a lesson.

### Known issues and open items
- Needs a human playtest: whether the film is too easy to miss or notice, and whether clicking screws while pressing feels right (a screw click also counts as pressure).
- Faults are per mount; nothing yet makes a customer return in person (comeback days exist, the visit does not).
- Not built, from the idea list: seating the CPU with a bent-pin risk, paste patterns by CPU type, cooler variety, the tech notebook.

### Next action
Claude or the user: playtest, then tune the numbers. Hot files bench_view.gd and game_state.gd stay with PR #41 until it merges; then this branch rebases onto main.

## 0.37.0 - 2026-11-15 - Thermal controls, super-paste and retract on the vacuum bin

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: 0.36.0 (5c3866f), continuing the same unmerged PR #41
- Type: minor (new compatible material choice and revised bench interaction)

### Execution status
Codex ran Godot 4.7.2 headless locally. Fifteen required suites: final applicable total 1,312
checks, zero failures; pending contracts zero checks. Includes native UI input. No manual
visual/feel acceptance or target-hardware performance claim. Date: 15 November 2026,
Europe/Bucharest. User directly requested these narrow hot-file changes; no automatic merge.

### Added / Changed / Fixed / Removed
- D127/B26: teal Cleaning and purple Thermal service tabs, with labeled/selected borders. Mount
  cooler moves below socket/legend and is visible only with paste before active/graded completion.
  Lever and bad-result/rework rules stay; mount readiness does not demand a perfect-size blob.
- B27: remove obsolete cloth/syringe toggle widget and its state wiring. Physical tool pickup
  remains; instructions say so. Retain logical selection helpers for input/regression coverage.
- D128: canonical three-choice MenuButton: normal, super-paste, toothpaste. Dirty/locked layers
  cannot be relabeled/mixed; menu and guarded handler explain wipe/reset first.
- Super-paste: subtle blue-purple rendering/legend, normal flow, honest material. Trial cost $6,
  signed heat effect −4°C at equal completed grade. Normal $3/0°C, toothpaste free/+14°C unchanged.
  Apply signed effects in night and legacy reports, with no scam warning for premium. Main save and
  physical per-PC snapshots recognize canonical IDs without an incompatible save-shape change.
- D129: RETRACT is a native push-button on the vacuum bin. Remove external spool drawing/click
  rectangle; reel remains inside bin. Same shortening/capacity/pull-out rules, parked beside bin.
  Raw input delegates this rectangle to the button, never bin-empty/tool use. Separate Empty bin stays.
- B28: explicitly bound button font/style margins/size inside bin; native theme minimum had grown it.
- Required thermal-service suite and revised obsolete-control fixtures; native input covers menu
  open + choice, service tab, mount and retract. No extra part catalogue/clock/save ownership system.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `CHANGELOG.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `DEVELOPMENT.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `HANDOFF.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `README.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/BUGS.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/CURRENT_STATE.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/DECISIONS.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/DESIGN.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/MINIGAME_RULES.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/PROJECT_BRIEF.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/ROADMAP.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/TESTING.md` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `docs/THERMAL_SERVICE.md` | A | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `project.godot` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/bench/paste_sim.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/bench/tool_rig.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/data/layout.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/data/paste_materials.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/night/paste_snapshot.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/night/repair_view.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/state/game_state.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/view/bench_view.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/view/cleaning_renderer.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `scripts/view/paste_renderer.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `tools/test_audio_and_vacuum.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `tools/test_regressions.gd` | M | Thermal/material/bin implementation, regression coverage or signed delivery documentation |
| `tools/test_thermal_service.gd` | A | Thermal/material/bin implementation, regression coverage or signed delivery documentation |

### Checks performed
- Godot 4.7.2: schemas 209, regressions 594, start 20, dust 43, bench interactions 31, feedback 27,
  audio/vacuum 46, performance 24, salvage 49, salvage physics 44, storage 82, night workshop 53,
  software 31, room/workshop 33, thermal service 26: zero failures (1,312 final applicable total).
- Full suites initially used thermal-service 25; reran its final 26 checks after adding the
  insufficient-funds case and final silent UI-event/menu-refresh changes. No duplicate-run inflation.
- Native material choice uses the actual embedded-menu input path, not a fabricated signal.
  Same-grade premium cooling parity, charge once/insufficient funds, honest scam state, main-save
  and physical snapshot roundtrip checked. Bin click does not empty dust; old spool area is inactive.
- Full bench state/frame/paste diagnostic matrix completed without script errors. It began before
  the last menu/audio-status-only tweaks; final thermal-service checks exercise those changes.
- Fresh extracted source imported in Godot 4.7.2 and passed all 26 thermal-service checks,
  without script errors.
- CI scope: 9 tests passed. Project hygiene and diff whitespace checks passed.

### Decisions proposed (not approved)
Super-paste $6 and −4°C are provisional balance values. The three choices, better cooling/tint,
conditional Mount, removed toggle and bin button are user-approved behavior (D127–D129).

### Known issues and open items
- No manual graphical acceptance yet. Existing trial heat estimate is not a physical CPU simulator.
- Internal reel state/method names retain 'spool' for compatibility; no external spool object remains.
- Existing master-PC/owned-parts integration and later Wave 2 apps remain separate work.

### Next action
User playtests v0.37.0; Claude goes next for cross-review of PR #41 before merging. Do not
merge automatically. bench_view.gd, tool_rig.gd and game_state.gd remain owned by this ONE open
PR for review; after merge they are free subject to Claude's work-plan ownership. No competing
hot-file PR or WORK_PLAN.md edit.

## 0.36.0 - 2026-11-15 - Drag a PC into the workshop and consistent Activities exits

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: 0.35.0 (74f3e5d), extending the same unmerged PR #41
- Type: minor (physical room selection replaces PC dropdown and duplicate routes)

### Execution status
Codex ran Godot 4.7.2 headless locally. Fourteen required suites: 1,283 checks, zero failures;
pending contracts zero checks. Native viewport input is included, not only method calls.
No graphical/manual playtest or universal crash-freedom claim. Date: 15 November 2026,
Europe/Bucharest. No hot-file or WORK_PLAN.md edits in this version; no automatic merge.

### Added / Changed / Fixed / Removed
- D125: Activity Workshop enters room. Drop a real customer PC into WORKSHOP SLOT to select/open
  its canonical ticket. Reject parts/tools, unknown/stale PCs and protected manifests. Preserve
  each repair and reserved shelf allocation; slot refers to the same PC, never a duplicate.
- Remove service-hub PC dropdown and duplicate Storage shortcuts on title/activity menus.
  The active PC's shelf spot is marked ON BENCH; choose another to return the previous to its spot.
- D126/B25: one named, shared top-right Activities control on room, service hub, repair, hardware,
  software and salvage. Existing cleanup paths preserve dust/paste, throws/stock and salvage custody.
  Generic night exits block and show the error if the checkpoint fails.
- B19: service-hub ticket now has a bounded ScrollContainer above the diagnosis report.
- B16 follow-up: inspect supplied 8.13s recording; title visibly says v0.32.0 and room has old
  numbered selectors. Current room replacement came from PR #40/v0.33.0, already merged. There
  is no per-rack Button/self-free path in this source. Replay sort/save/add/multiple-title clicks
  with actual GUI input; stable control identities verified. README explains fresh-folder import.
- Furniture utility actions remain. No new global PC ownership/schema, campaign clock, hardware
  model integration, changed economics or simulation tuning. Existing hardware bench is shop stock.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `CHANGELOG.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `DEVELOPMENT.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `HANDOFF.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `README.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/BUGS.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/CURRENT_STATE.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/DECISIONS.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/DESIGN.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/NIGHT_WORKSHOP.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/PROJECT_BRIEF.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/ROADMAP.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/ROOM_WORKSHOP.md` | A | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/STORAGE.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `docs/TESTING.md` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `project.godot` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/activities_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/hardware_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/night_navigation.gd` | A | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/repair_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/salvage_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/software_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/night/workshop_hub.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/storage/storage_sources.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/storage/storage_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `scripts/view/start_view.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `tools/test_night_workshop.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `tools/test_room_workshop.gd` | A | Room selection, common night navigation, regression coverage or signed scope documentation |
| `tools/test_start_screen.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |
| `tools/test_storage.gd` | M | Room selection, common night navigation, regression coverage or signed scope documentation |

### Checks performed
- Godot 4.7.2: data schemas 206, regressions 594, start screen 20, dust flow 43, bench interactions 31,
  bench feedback 27, audio/vacuum 46, performance 24, salvage 49, salvage physics 44, storage 82,
  night workshop 53, software 31, room/workshop 33: all zero failures (1,283 total).
- After the final route guard/shortcut changes, reran start, storage, night workshop, software and
  room/workshop suites. No script errors. Pending contracts: 0/0.
- Native events: sort/save/add two types, every furniture title, PC drag to slot and one common
  Activities exit per work screen. Save-failure exit refusal, canonical counts/cash, per-PC progress
  and reload checked. Old dropdown-route assertion replaced with absence of that control.
- Fresh extracted v0.36.0 source imported in Godot 4.7.2 and passed all 33 room/workshop checks,
  with no script errors (expected forced-save-failure warning only).
- Project hygiene, diff whitespace and CI scope (9 tests) passed. Full physics diagnostic matrix
  not repeated: 0.36 changes wrappers/layout/navigation only; underlying bench hot files untouched.

### Decisions proposed (not approved)
No additional mechanics. Existing eight-room-bay capacity and visual tuning remain provisional.

### Known issues and open items
- Recording evidence is v0.32.0; an unseen newer-build failure cannot be ruled out by that video.
  Use a fresh v0.36.0 folder and check the title/room version before further playtests.
- Active PC retains a rack reservation; there is no separate PC unmount/eject inventory system.
- Shared installed-PC hardware model and later anti-virus/overclocker slices remain future work.

### Next action
User playtests v0.36.0; Claude goes next for cross-review of PR #41. Do not merge automatically.
This version edits none of bench_view.gd, tool_rig.gd or game_state.gd; those hot files remain
reserved by the earlier changes in this single PR until its review/merge, then free subject to
Claude's work-plan ownership. WORK_PLAN.md unchanged.

## 0.35.0 - 2026-11-15 - Cloth edge, off-by-default PCs and first Wave 2 monitor

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: 0.34.0 (c1d20b2), extending the same unmerged PR #41; main remains approved room 0.33.0
- Type: minor (new diagnostic desktop and shared live-boot rule)

### Execution status
Codex ran Godot 4.7.2 headless locally. Thirteen required suites: 1,250 checks, zero failures;
pending contracts zero checks. No graphical/manual playtest or target-hardware performance claim.
Date: 15 November 2026, Europe/Bucharest. New Wave 2 assignment is from the user; no automatic merge.

### Added / Changed / Fixed / Removed
- B23: cloth pickup follows the rendered skewed/rotated fabric with a one-world-pixel inset.
  Wiping radius is 35 rather than 36 world px, not one whole 8px cell; strength/upgrade shape unchanged.
- D122/B24: fresh/missing-power PCs default off; explicit saved on/off states survive. Fans initialize
  still when off. Shared SoftwareChecks.boot gates night diagnostics and legacy payment check;
  neither can pass an off PC. Legacy payment semantics otherwise remain historical/unchanged.
- D123: Workshop diagnostic desktop exposes boot, read-only thermal/final report, Vapor purchase
  and Counter Stroke 2 simulated FPS using existing rules. Case power button stays outside the
  dark monitor. Reports clear on power-down; broken/unowned/off PCs cannot fake game readings.
- Customer complaint, uses, collection request and stated game/noise targets stay in a bounded scroll.
  No completion/payment/trust transaction in the new monitor; only explicit licence purchases spend.
- Anti-virus/overclocker are explicitly upcoming. They perform no fake scan or tuning; exact mechanics
  remain future work. No campaign clock, persistent report, PC ownership migration or real OS/game app.
- Required CI software suite covers native GUI power input, rule/transaction boundaries and cloth edge.
  Older repaired-PC test fixtures now switch power on explicitly rather than hiding the new default.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `.github/workflows/tests.yml` | M | Runtime contract, regression coverage or delivery documentation |
| `CHANGELOG.md` | M | Runtime contract, regression coverage or delivery documentation |
| `DEVELOPMENT.md` | M | Runtime contract, regression coverage or delivery documentation |
| `HANDOFF.md` | M | Runtime contract, regression coverage or delivery documentation |
| `README.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/BUGS.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/CURRENT_STATE.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/CUSTOMER_MODEL_MAP.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/DECISIONS.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/DESIGN.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/MINIGAME_RULES.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/PROJECT_BRIEF.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/ROADMAP.md` | M | Runtime contract, regression coverage or delivery documentation |
| `docs/SOFTWARE_WAVE_2.md` | A | Runtime contract, regression coverage or delivery documentation |
| `docs/TESTING.md` | M | Runtime contract, regression coverage or delivery documentation |
| `project.godot` | M | Runtime contract, regression coverage or delivery documentation |
| `scenes/software.tscn` | A | Runtime contract, regression coverage or delivery documentation |
| `scripts/bench/tool_rig.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `scripts/night/night_diagnostics.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `scripts/night/software_view.gd` | A | Runtime contract, regression coverage or delivery documentation |
| `scripts/night/workshop_hub.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `scripts/rules/software_checks.gd` | A | Runtime contract, regression coverage or delivery documentation |
| `scripts/state/game_state.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `scripts/view/bench_view.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `scripts/view/tool_renderer.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `tools/test_regressions.gd` | M | Runtime contract, regression coverage or delivery documentation |
| `tools/test_software.gd` | A | Runtime contract, regression coverage or delivery documentation |

### Checks performed
- Godot 4.7.2: data schemas 206, regressions 594, start screen 20, dust flow 43, bench interactions 31,
  bench feedback 27, audio/vacuum 46, performance contracts 24, salvage 49, salvage physics 44,
  storage 82, night workshop 53, software 31: zero failures (1,250 total). Pending contracts: 0/0.
- Software suite includes real viewport mouse events on the case power button; no native GUI claim
  is based only on emitting its signal. Diagnostic and purchase rules are independently checked.
- Full bench diagnostic state/frame/paste matrix completed without script errors. Off-by-default
  fan behavior intentionally changes the baseline; this is not a no-behavior-change refactor.
- Fresh source ZIP imported and passed all 31 software checks without script errors.
- CI scope: 9 tests passed. Project hygiene and whitespace checks passed.

### Decisions proposed (not approved)
Anti-virus infection/cure rules, overclock tuning/stability/risks and campaign test timing are not
implemented; details need design. Existing trial costs, thresholds and balance remain provisional.

### Known issues and open items
- No manual visual/feel acceptance yet. B19 old workshop ticket overflow remains separate.
- Cloth uses existing tabletop collision boxes; precise new fabric pickup does not add soft-body physics.
- Explicit old powered-on saves stay on intentionally; use New Game to observe fresh off defaults.
- The desktop is customer-PC diagnostics, not a complete master-PC OS or real software execution.

### Next action
User playtests PR #41 (now 0.35.0) and Claude cross-reviews before merge. Claude goes next; hot files
bench_view.gd, tool_rig.gd and game_state.gd are free after delivery subject to Claude's current
work-plan ownership. No competing hot-file PR or WORK_PLAN.md edit. Follow-up Wave 2 app mechanics
remain future slices.

## 0.34.0 - 2026-11-15 - Retractable hose, brush-first controls and movable heavy waste

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: main 0.33.0, room PR #40 merged at f31eaea after CI passed
- Type: minor (deployed hose length/payout behavior and user-requested feel changes)

### Execution status
Codex ran Godot 4.7.2 headless locally, including the full bench diagnostic matrix.
Final applicable suite results total 1,219 checks, zero failures; pending contracts zero checks.
No graphical/manual playtest or target-hardware performance claim. Date: 15 November 2026,
Europe/Bucharest. Approved room delivery is merged; this follow-up awaits cross-review/playtest.

### Added / Changed / Fixed / Removed
- Spool actually reduces deployed hose to 140 world pixels. It stays short at rest; pulling the
  vacuum, rope or clipped clamp pays out up to the owned capacity. Passive motion cannot unspool it.
  Reel releases carried rope pins; upgrades preserve already coiled hose. Length is bench-session state.
- Repair bench starts with Brush: key 1 Brush, key 2 Vacuum. Internal simulation ids stay unchanged.
  Fix mutually exclusive button highlights on hotkey changes, preserving refused-switch behavior.
- Heavy concrete/appliances remain uncollectable obstacles but can be nudged/tipped. Lower mass and
  friction, stronger damping, grip still below weight; normal parts remain much easier to lift.
- Publish/archive approved 0.33.0 room and merge PR #40. Preserve canonical stock and existing room.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `CHANGELOG.md` | M | Gameplay, regression coverage or signed scope documentation |
| `DEVELOPMENT.md` | M | Gameplay, regression coverage or signed scope documentation |
| `HANDOFF.md` | M | Gameplay, regression coverage or signed scope documentation |
| `README.md` | M | Gameplay, regression coverage or signed scope documentation |
| `docs/BENCH_FEEL_0_34.md` | A | Gameplay, regression coverage or signed scope documentation |
| `docs/BUGS.md` | M | Gameplay, regression coverage or signed scope documentation |
| `docs/CURRENT_STATE.md` | M | Gameplay, regression coverage or signed scope documentation |
| `docs/DECISIONS.md` | M | Gameplay, regression coverage or signed scope documentation |
| `docs/DESIGN.md` | M | Gameplay, regression coverage or signed scope documentation |
| `docs/PROJECT_BRIEF.md` | M | Gameplay, regression coverage or signed scope documentation |
| `docs/ROADMAP.md` | M | Gameplay, regression coverage or signed scope documentation |
| `project.godot` | M | Gameplay, regression coverage or signed scope documentation |
| `scripts/bench/tool_rig.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `scripts/data/ids.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `scripts/salvage/salvage_body.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `scripts/salvage/salvage_data.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `scripts/view/bench_view.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `tools/test_audio_and_vacuum.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `tools/test_bench_interactions.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `tools/test_regressions.gd` | M | Gameplay, regression coverage or signed scope documentation |
| `tools/test_salvage_physics.gd` | M | Gameplay, regression coverage or signed scope documentation |

### Checks performed
- Full required suites: data schemas 206, regressions 594, start screen 20, dust flow 43,
  bench interactions 31, bench feedback 27, audio/vacuum 45, performance 24, salvage 49,
  salvage physics 44, storage 82, night workshop 53: zero failures.
- After the final passive-payout guard, reran audio/vacuum (46 checks) and regressions (594):
  zero failures. Final applicable total is 1,219; no duplicate-run inflation.
- Full playtest_bench diagnostic state/frame matrix completed without script errors. It preceded
  the final passive-payout guard; targeted spool tests cover that change. Frame figures are local
  headless observations, not a target-hardware benchmark.
- CI scope tests: 9 passed. Project hygiene and diff whitespace checks passed.

### Decisions proposed (not approved)
Numeric force/length tuning remains provisional. User approved behavior is D119–D121.

### Known issues and open items
- Deployed hose length resets with a new bench instance, like tool positions; no save schema change.
- B19 workshop ticket overflow remains open. User should playtest feel and graphical layout.

### Next action
User playtests the separate 0.34.0 PR; do not automatically merge it. Claude goes next for
cross-review. Hot files bench_view.gd and tool_rig.gd are free after this delivery; game_state.gd
was untouched and is free subject to Claude's current work-plan ownership. WORK_PLAN.md unchanged.

## 0.33.0 - 2026-11-15 - Direct room furniture and storage crash fixes (local)

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: integrated main 0.32.0 (5479b8e, Claude PR #39 already merged)
- Type: minor (new physical room layout, schema-2 storage positions and UI lifecycle fixes)

### Execution status
Codex ran Godot 4.7.2 headless locally. Twelve required suites: 1,203 checks, zero failures;
pending contracts zero checks and legacy bench smoke passed. Storage's 82 checks include actual
viewport/Button input, not only method calls. No graphical/manual playtest or universal crash
freedom is claimed. Code remains LOCAL under the user's prior no-push instruction; no merges.
Date: 15 November 2026, Europe/Bucharest.

### Added / Changed / Fixed / Removed
- User D118: remove rack-list Buttons and paged furniture. One clipped room canvas holds all
  racks, cabinets and tool boards in a 4×2 floor grid (eight equal bays, provisional tuning).
- Select/drag a furniture title to move its whole contents to a free bay. Zoom at the mouse,
  middle-pan, Fit furniture/Entire room, plus edge pan when carrying. Parts still grid-pack/rotate.
- B16: remove the self-freeing signal-emitter path entirely. Toolbar/popup nodes are built once,
  and updates change text/model state without destroying controls. Every-room selection is data input.
  Selection alone does not rewrite the layout file; actual moves/edits still autosave.
- B20: replace direct manually positioned PopupPanel children with Margin/VBox. Three real separate
  model-choice rectangles and native clicks select the correct model. Bounded scrolling inspector.
- Layout schema 2 adds room_cell to furniture. Version 1 assigns distinct bays, preserving item
  identities/shelf/cell/rotation. Invalid/duplicate/extreme positions rehome safely; versions >2 lock edits.
- Canonical item sources, CPU visibility, ownership reservations, no-free-stock behavior and safe
  writer remain. Camera is presentation-only. No room economy or purchase capacity hook added.
- Cross-review Claude PR #39 and post comment. Preserve canonical CPU/PartStates improvements.
  Reproduce B19 night-ticket overflow, report to Claude, leave outside this storage task.
- No edits to hot files, GameState/shared saves, shop, night workshop view or WORK_PLAN.md.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `CHANGELOG.md` | M | Signed local delivery record |
| `DEVELOPMENT.md` | M | Version, scope, bug/review evidence or handoff |
| `HANDOFF.md` | M | Version, scope, bug/review evidence or handoff |
| `README.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/BUGS.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/CURRENT_STATE.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/DECISIONS.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/DESIGN.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/PROJECT_BRIEF.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/REVIEW_0_32.md` | A | Version, scope, bug/review evidence or handoff |
| `docs/ROADMAP.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/STORAGE.md` | M | Version, scope, bug/review evidence or handoff |
| `docs/STORAGE_ROOM.md` | A | Version, scope, bug/review evidence or handoff |
| `docs/TESTING.md` | M | Version, scope, bug/review evidence or handoff |
| `project.godot` | M | Version, scope, bug/review evidence or handoff |
| `scripts/storage/room_canvas.gd` | A | Room geometry, persistence, drawing/input or regression tests |
| `scripts/storage/storage_data.gd` | M | Room geometry, persistence, drawing/input or regression tests |
| `scripts/storage/storage_model.gd` | M | Room geometry, persistence, drawing/input or regression tests |
| `scripts/storage/storage_store.gd` | M | Room geometry, persistence, drawing/input or regression tests |
| `scripts/storage/storage_view.gd` | M | Room geometry, persistence, drawing/input or regression tests |
| `tools/test_storage.gd` | M | Room geometry, persistence, drawing/input or regression tests |

### Checks performed
- Godot 4.7.2: Data schema 206; Regression 594; Start screen 20; Dust flow 43; Bench interaction
  26; Bench feedback 27; Audio and vacuum 36; Performance contracts 24; Salvage 49;
  Salvage physics 43; Storage 82; Night workshop 53. Total 1,203 checks, zero failures.
- Pending contracts: zero checks/failures. Bench --smoke: Playtest finished, no script errors.
- Baseline 0.32.0 separately reproduced: native signal emits locked-object/free errors; all three
  popup choice rects equal (4,4,354,54). New storage native-input path has no script/engine errors.
- Room tests cover actual sort/save/add/model clicks, non-overlapping choices, every title, stable
  node IDs, valid/blocked moves, all eight headers in one room, remove/re-add, repeated loops,
  v1 migration retaining third-shelf rotated part, numeric extremes, future read-only and save failures.
- Review geometry: broken GPU+cooler night ticket rect (32,166,630,345), bottom 511 versus report
  y=425; B19 open. See docs/REVIEW_0_32.md and PR #39 conversation comment 6886430199.
- `python3 -B tools/test_ci_scope.py`: nine tests passed. `git diff --check`: clean.
- `python3 -I tools/check_project.py`: passed, zero problems. Fresh ZIP extracted/imported on
  Godot 4.7.2; Storage 82 and Night workshop 53 passed with no script/resource errors.
- Full suite ran before final storage-only bounds/label tweaks; final Storage suite reran and passed.
  No broader repeat/benchmark claimed. Failure-injection warnings are expected, not runtime crashes.

### Decisions proposed (not approved)
D118 records the user's direct room/furniture/grid request. Four-by-two room, equal one-bay furniture,
free expansion and zoom/size tuning are provisional. Future room expansion prices and differently
sized furniture are not implemented. No approval to push or merge inferred.

### Known issues and open items
B19 workshop-ticket overlap remains open, reported in review; its fix belongs to a separate scope.
Old 0.32.0 project copies still contain B16/B20 until updated; this screen shows v0.33.0 to distinguish
it. Graphical scale/feel need the user's playtest. No target-device performance claim. Other unresolved
inventory/canonical PC integration boundaries remain as in main; source ownership is unchanged.

### Next action
User playtests the local 0.33.0 ZIP; Codex publishes only after user instruction. Claude reviews the
room change and handles B19 separately. No code pushed, no PRs merged. Hot files bench_view.gd,
tool_rig.gd and game_state.gd are untouched and remain reserved for Claude; none is claimed free.
WORK_PLAN.md unchanged. Rebase/reconcile metadata against latest main before any future push.

## 0.32.0 - 2026-11-15 - The broken-GPU dead end, the bug register and the Upgrades tab

- Author: Claude (Fable 5, model id claude-fable-5), working in a chat session
- Based on: 0.28.0 (first shipped alone as main 0.29.0, PR #37; re-based here on top of Codex's merged 0.29.0 storage rack, 0.30.0 night workshop and 0.31.0 salvage variety, with the version and D-number collisions renumbered)
- Type: minor (new register + rules, UI restructure, sandbox data; saves migrate)

### Execution status
Godot was NOT run by me directly. GitHub Actions runs the suites on Godot 4.7.2 headless.
No interactive playtest is claimed.
Standalone build (as main 0.29.0, PR #37): run 43653162382 on c335f55 succeeded — Data schema 206, Regression 586, Start
screen 20, Dust flow 43, Bench interaction 26, Bench feedback 27, Audio and vacuum 36,
Performance contracts 24, Salvage 40, Salvage physics 38, Pending contracts 0; 1046 checks,
0 failures, plus the scripted bench playtest. Five earlier pushes failed and were fixed in
place: the cooler mount overlapped a RAM slot (invalidating the whole board), the load
validator dropped the new CPU record (and a migration briefly respawned it on empty stock),
the CPU's drawer position shifted the packing that older tests pin, a salvage test read a
cargo body before the grab finished, and the menu label was sized before wrapping was set so
Godot clamped it to 600 px (recorded as the real root of B13).
Integrated build (this entry, after merging Codex's three PRs): Actions result: run 43655899663 succeeded (all 13 suites, 0 failures; the first run 43655748898 had 2 failures - start-menu Storage button outside the card, and a part-order assertion - both fixed).

### Added
- `docs/BUGS.md` (D114): the bug register. Every bug found — playtest, CI, review — gets a row
  when found and a root cause when fixed; backfilled with B1–B15. Every 10 versions (0.30.0,
  0.40.0, …) it gets a structural review pass. AGENTS.md rule 6 and the HANDOFF checklist now
  require it.
- `GameState.part_state(part_id)` (D115): ONE binary state pair per serviceable part
  (fitted/working) with the exact repair path in words. The failed final check now prints
  "GPU: BROKEN - at the repair bench: move it to the tray, then open Replacement stock."
  instead of the old aggregate notes, and the TICKET carries a parts line too — the user's
  0.28.x playtest dead-ended on a broken GPU with no visible way forward (B10/B12, RC-1/RC-2).
- The spare-part bench is coherent (D116): the starter stock includes a demo CPU, the demo
  board gained a cooler mount, and the cooler only fits once the CPU sits in the socket
  (real-life order CPU → mount → cooler, as the user asked). Its banner and the shop button
  now say plainly that it is the SHOP'S stock bench, not the customer's PC (B11).
- Upgrades tab (D117): the shop's lower card is Final check | Customer | Upgrades; both tool
  upgrades (square cloth, longer hose) moved there, and future ones land there.

- Integration (this version): `scripts/rules/part_states.gd` — the part-state rule is now PURE and
  shared (D115). `GameState.part_state`, the old final check, the shop ticket AND Codex's night
  workshop (diagnosis report + workshop ticket) all read it, so the night flow that replaced the
  shop screen names the broken part and its repair path too (BUGS.md B18). The storage rack now
  reads the canonical `GameState.inventory_components()` projection and shows the starter CPU as a
  3x3 CPU instead of silently dropping it (B17, found by Codex's review of my 0.29.0).

### Changed
- The ticket is a bounded ScrollContainer like the other cards (its new parts line must not
  recreate B5).
- Main menu: the card grew to hold its five buttons, and the status line sits inside it again
  (B13 — the salvage and settings buttons had pushed the text over the border).
- Salvage, from Codex's verified qualifications on the D108 fix: a find released while
  overlapping the rim barrier keeps its exemption until physically clear (no fling, B14), and
  a cargo body re-enters the world at the first FREE staging spot instead of the fixed point
  (no materialising inside a staged find, B15).

### Fixed
- B10 (loop-blocker): see part_state above — the path out of a broken-GPU ticket is now named
  at every surface that mentions the part, and test_0_29 walks the whole loop end to end.
- B11: coolers were unmountable at the spare-part bench (no mount slot, no CPU existed).
- B13: main-menu text out of its card.

### Removed
(nothing)

### Files changed
| File | Change | What |
| --- | --- | --- |
| `docs/BUGS.md` | A | The bug register (D114), backfilled B1–B15 with root causes RC-1..3 |
| `scripts/state/game_state.gd` | M | part_state (D115); binary per-part final-check notes; CPU in starter stock |
| `scripts/view/shop_view.gd` | M | Upgrades tab; ticket parts line + bounded ticket scroll; bench button renames |
| `scripts/view/workshop_view.gd` | M | Spare-part-bench banner |
| `scripts/data/component_data.gd` | M | Demo CPU part; cooler mount connector with "requires": "cpu" |
| `scripts/rules/placement_rules.gd` | M | Connector "requires" dependency rule |
| `scripts/view/start_view.gd` | M | Menu layout inside the grown card |
| `scripts/data/layout.gd` | M | START_CARD fits five buttons + status |
| `scripts/salvage/salvage_physics.gd` | M | Rim release grace; free-space cargo spawn probe |
| `tools/test_regressions.gd` | M | test_0_29 (end-to-end broken-GPU loop, part states, mount order, Upgrades tab); stock counts 6→7 |
| `tools/test_start_screen.gd` | M | Card-containment checks for every menu button and the status text |
| `tools/test_salvage_physics.gd` | M | Rim-release grace + cargo-spawn probe checks |
| `tools/test_data_schemas.gd` | M | Connector schema allows "requires" |
| `AGENTS.md` | M | Rule 6: the bug register |
| `DEVELOPMENT.md` | M | File map: docs/BUGS.md |
| `docs/DECISIONS.md` | M | D114–D117, D108 amendment |
| `scripts/rules/part_states.gd` | A | Pure shared part-state rule (D115) |
| `scripts/night/night_diagnostics.gd` | M | Uses the shared lines instead of "Damaged: gpu. Replace these parts." |
| `scripts/night/workshop_hub.gd` | M | Workshop ticket shows the parts line |
| `scripts/storage/storage_sources.gd` | M | Canonical component projection (CPU no longer dropped, B17) |
| `scripts/storage/storage_data.gd` | M | CPU colour |
| `tools/test_storage.gd` | M | Starter CPU appears on the rack |
| `HANDOFF.md` | M | 0.32.0 section; checklist step 10 (bug register); version |
| `README.md` | M | Version |
| `project.godot` | M | config/version 0.29.0 |
| `CHANGELOG.md` | M | This entry |

### Checks performed
- `python3 -I tools/check_project.py`: PASSED (0 problems).
- GitHub Actions (all suites) on branch `feature/0.29.0`: recorded under Execution status when
  the run finishes.

### Decisions proposed (not approved)
- The bug register's shape (table + root-cause sections + reviews) and the backfilled list.
- The spare-part bench staying a SANDBOX for now, clearly labelled; connecting the customer's
  real PC to it is the open structural step (RC-1, D79 note) — proposed as its own future wave.
- Demo CPU and cooler-mount geometry; the "requires" rule living on the connector.
- Why the GPU broke at all: the pick tool's damage roll (D-series pick risk) — the bench shows
  "DAMAGED" while cleaning, but the user met it only at the check. part_state surfaces it
  everywhere now; if it still reads as "random", the pick's risk/reward needs a design pass.

### Known issues and open items
- Integration was done by merging Codex's PRs #35/#36/#38 (archives archive/v0.29.0, archive/v0.30.0,
  archive/v0.31.0 preserved) and renumbering Claude's release 0.29.0 → 0.32.0, D109-D112 → D114-D117.
- RC-1 remains structurally open: the customer's PC and the spare-part bench are still two
  models; D115 surfaces one truth but does not merge them. Proposed next structural wave.
- Wave 2 (software-checks monitor screen) still NOT started, per the user.
- First structural bug review due at 0.30.0 (D114).

### Next action
User playtest of 0.29.0 (the broken-GPU loop, the Upgrades tab, the menu). Then, on the user's
word: wave 2 or the RC-1 structural wave.

## 0.31.0 - 2026-11-15 - Fresh random salvage piles, more parts and heavy obstacles

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: main 0.29.0 (e6f89e3), rebased after Claude PR #37; inventory/night PRs remain separate
- Type: minor (new salvage content, per-arrival generation rule and heavy physics)

### Execution status
Codex ran Godot 4.7.2 headless locally: ten required suites, 1,060 checks, zero failures;
zero pending-contract checks and scripted bench smoke passed. No graphical/user playtest or
target-hardware performance claim. Date: 15 November 2026, Europe/Bucharest.
Independent main-based PR; prior local inventory/night fixes remain unpublished and unchanged.

### Added / Changed / Fixed / Removed
- Fresh random pile on EVERY successful arrival, including same-night return visits. Reopening
  the active visit/containers does not reroll; normal travel cost still applies. Cargo/shelf stay.
  Old stable/few-day pile refresh rule is superseded by user-requested D113; UI now explains visits.
- Fourteen collectible PC/part kinds: previous PC/GPU/RAM/PSU/drive plus CPU, motherboard, cooler,
  fan, SSD, HDD, Wi-Fi, sound and network cards. All pack/rotate in the trunk and remain untested.
- Random root counts, size-varied bags/boxes, shuffled mix, weighted per-site component selection,
  small tilts and random positions replace fixed columns. Contents are real records generated once.
- Concrete blocks/heavy appliances are massive native dynamic obstructions with high friction and
  reduced bounded grip/torque. HEAVY markings/hints explain barely nudging/working around them.
  They can fall with the pile but cannot be packed or opened into lightweight shells.
- Rotated root hulls start without overlap; no-space roots are skipped. Generation caps all visible
  and hidden records at 64. Newly exposed contents stay on their own side of the bin rim.
- Random visit IDs include session nonce/serial/seed to avoid matching cargo. Debug seed override
  reproduces a report. Cycle metadata remains only for legacy/debug code, no longer a reroll gate.
- Rebased on Claude’s main 0.29.0 update (PR #37); its GPU/CPU/UI fixes and salvage grace/staging
  tests are retained. No edits to its hot files.
- Follow the new bug-register rule: record B16 as local-only and B17 as a pending CPU-adapter compatibility gap, plus
  structural review preparation. No inventory fix code or branch was published.
- No shared stock/save/customer/bench changes, new commerce or finished repair-catalogue claim.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `CHANGELOG.md` | M | Signed salvage delivery record |
| `docs/BUGS.md` | M | Record prior pending rack bug and prepare structural checkpoint review; no inventory fix code published |
| `DEVELOPMENT.md` | M | Version, current scope, decision reconciliation or handoff |
| `HANDOFF.md` | M | Version, current scope, decision reconciliation or handoff |
| `README.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/CURRENT_STATE.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/DECISIONS.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/DESIGN.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/PROJECT_BRIEF.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/ROADMAP.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/SALVAGE_DESIGN_PROPOSAL.md` | M | Version, current scope, decision reconciliation or handoff |
| `docs/SALVAGE_VARIETY.md` | A | Version, current scope, decision reconciliation or handoff |
| `docs/TESTING.md` | M | Version, current scope, decision reconciliation or handoff |
| `project.godot` | M | Version, current scope, decision reconciliation or handoff |
| `scripts/salvage/salvage_body.gd` | M | Variety/arrival/heavy physics and regression contracts |
| `scripts/salvage/salvage_data.gd` | M | Variety/arrival/heavy physics and regression contracts |
| `scripts/salvage/salvage_pile.gd` | M | Variety/arrival/heavy physics and regression contracts |
| `scripts/salvage/salvage_session.gd` | M | Variety/arrival/heavy physics and regression contracts |
| `scripts/salvage/salvage_view.gd` | M | Variety/arrival/heavy physics and regression contracts |
| `tools/test_salvage.gd` | M | Variety/arrival/heavy physics and regression contracts |
| `tools/test_salvage_physics.gd` | M | Variety/arrival/heavy physics and regression contracts |

### Checks performed
- Godot 4.7.2: Data schema 206; Regression 586; Start screen 20; Dust flow 43;
  Bench interaction 26; Bench feedback 27; Audio and vacuum 36; Performance contracts 24;
  Salvage 49; Salvage physics 43. Total 1,060 checks, zero failures/script errors.
- Pending contracts: zero checks/failures. Legacy bench --smoke: Playtest finished, no script errors.
- Salvage tests cover 128 seeded piles, no initial rotated-hull overlap, bounds/caps, catalogue and
  weighted variety, valid hidden identities, fresh visit IDs, trunk/rotation/cargo and reveal invariants.
- Native tests verify sustained heavy pull stays below 35 pixels displacement while ordinary parts
  lift over 100 pixels, plus a generated pile with opened containers stays bounded/finite. No frame-time
  threshold or performance benchmark inferred from this. All previous native cases still pass.
- `python3 -B tools/test_ci_scope.py`: nine tests passed. `git diff --check`: clean.
- `python3 -I tools/check_project.py`: passed, zero problems. Fresh ZIP extracted/imported on
  Godot 4.7.2; Salvage 49 and Salvage physics 43 passed, no script/resource errors.

### Decisions proposed (not approved)
D113 records the user's approved new arrival/randomness/content/heavy-item request. Root counts,
weights, dimensions, 64-record cap, effort and force/mass/friction values are provisional tuning.
No release catalogue, final balance or repair-stock integration approved by this prototype.

### Known issues and open items
Independent branch starts from main 0.29.0, so its test entry is the title-menu Salvage demo. The
pending night activity wrapper will inherit the new session/view behavior when integrated later.
App exit still discards standalone salvage progress. Left-behind unclaimed/sorting items are cleared
on next arrival. Heavy bodies can move under gravity/contacts; they are not immovable scenery.
Graphics/feel and target-device timing require a user playtest. No new owned-part model implemented.

### Next action
Claude cross-reviews the new separate PR next: arrival semantics, cargo identity, bounds and heavy
physics; user playtests variety and weight. Do not auto-merge. Prior inventory/night PRs and local
patches are unchanged; do not publish them with this PR. Hot files bench_view.gd, tool_rig.gd and
game_state.gd are untouched and remain reserved for Claude; none is claimed free. WORK_PLAN.md is
unchanged. Reconcile version metadata when combining the pending branches.

## 0.30.0 - 2026-11-14 - Night activities, two customer PCs and diagnostic-only checks

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: 0.29.0 (unmerged feature/storage-rack, 373115e); main remains 0.28.0
- Type: minor (new activity/workshop screens, multiple ticket-linked PCs and manifest contract)

### Execution status
Codex ran Godot 4.7.2 headless locally. All 12 required suites passed in the final applicable runs:
1,112 checks, zero failures; pending contracts zero checks. Scripted legacy bench smoke passed.
No graphical/manual playtest is claimed. Date: 14 November 2026, Europe/Bucharest.
Follow-up is stacked on the unmerged rack branch; neither PR is merged by this delivery.

### Added / Changed / Fixed / Removed
- New/Load Game enters Activities: Workshop, Salvage dump, Storage and a disabled future-activity
  space. Removed Salvage from the title menu. The dump now returns to Activities.
- Existing square-cloth and longer-hose upgrades stay purchasable in Workshop, at unchanged prices.
- Workshop selects between two real customer repair PCs on New Game (the two existing customers;
  one extra compact PC). Each has its own dust, damage, removal/replacement, scams and paste work.
  Existing saves migrate their actual single job; they never gain fabricated extra client PCs.
- A ticket has an optional physical PC identity. Future build orders with no client hardware do
  not create rack objects or occupy PC space; build-order intake itself is not implemented.
- Third shelf on every rack. Smaller drawn cells keep all three levels visible; saved grid-cell
  placements retain their meaning. Storage reads the restored current ticket manifest.
- Final Check reports boot/heat/parts/owned-game fps, without completing, paying, recording pickup,
  advancing customer rotation or changing relationships. Switch PCs at any point from Workshop.
- In the night repair route a good cooler lever mount commits paste automatically (same existing
  cost/scam rule), so no extra completion button. Paste float32 field is saved with its PC.
- Isolated NightSession bridge: active job remains in GameState; inactive jobs use a versioned
  manifest. Checkpoint/readback precedes switching; missing/damaged/future manifests lock switching
  and preserve their files. Existing money/stock/customer state are never copied into the manifest.
- Additive scene wrappers keep Claude's hot files, shop/customer data and WORK_PLAN.md untouched.
  Hardware bench remains the SHOP STOCK sandbox, not customer assembly. Daytime pickup, global
  night clock, campaign salvage transfer and final canonical PC/part model remain future work.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `CHANGELOG.md` | M | Signed follow-up delivery record |
| `.github/workflows/tests.yml` | M | Version/autoload or required suite |
| `DEVELOPMENT.md` | M | Scope, contracts, controls and coordination handoff |
| `HANDOFF.md` | M | Scope, contracts, controls and coordination handoff |
| `README.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/CURRENT_STATE.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/DECISIONS.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/DESIGN.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/NIGHT_WORKSHOP.md` | A | Scope, contracts, controls and coordination handoff |
| `docs/PROJECT_BRIEF.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/ROADMAP.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/STORAGE.md` | M | Scope, contracts, controls and coordination handoff |
| `docs/TESTING.md` | M | Scope, contracts, controls and coordination handoff |
| `project.godot` | M | Version/autoload or required suite |
| `scenes/activities.tscn` | A | Night navigation scene |
| `scenes/night_bench.tscn` | A | Night navigation scene |
| `scenes/night_hardware.tscn` | A | Night navigation scene |
| `scenes/night_salvage.tscn` | A | Night navigation scene |
| `scenes/night_workshop.tscn` | A | Night navigation scene |
| `scripts/night/activities_view.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/hardware_view.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/night_diagnostics.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/night_session.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/paste_snapshot.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/repair_view.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/salvage_view.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/night/workshop_hub.gd` | A | New night activity/PC routing, manifest or diagnostics; see file map |
| `scripts/storage/storage_data.gd` | M | Third shelf and ticket-linked physical PCs |
| `scripts/storage/storage_sources.gd` | M | Third shelf and ticket-linked physical PCs |
| `scripts/storage/storage_view.gd` | M | Third shelf and ticket-linked physical PCs |
| `scripts/view/start_view.gd` | M | New/load activities routing, remove title-screen salvage |
| `tools/test_night_workshop.gd` | A | Updated route/capacity contracts and disposable-save verification |
| `tools/test_salvage_physics.gd` | M | Updated route/capacity contracts and disposable-save verification |
| `tools/test_start_screen.gd` | M | Updated route/capacity contracts and disposable-save verification |
| `tools/test_storage.gd` | M | Updated route/capacity contracts and disposable-save verification |

### Checks performed
- Godot 4.7.2: Data schema 198; Regression 564; Start screen 14; Dust flow 43; Bench interaction
  26; Bench feedback 27; Audio and vacuum 36; Performance contracts 24; Salvage 40;
  Salvage physics 32; Storage 55; Night workshop 53. Total 1,112 checks, zero failures.
- Pending contracts: zero checks/failures. Scripted bench --smoke: Playtest finished, no script errors.
- Night coverage includes real scene navigation/PC picker, physical paste JSON roundtrip/reopening,
  lever-only commit and no double charge, canonical replacement consumption across switches,
  legacy migration, interrupted-switch recovery, future manifest protection and failed saves.
- Initial full run exposed a test fixture assuming the gamer was always second; corrected fixture
  sets its own rotation counter. Affected start/storage/salvage-physics/night suites rerun and passed.
  Physics activity-navigation tests now use disposable main/manifest saves rather than default saves.
- `python3 -B tools/test_ci_scope.py`: nine tests passed. `git diff --cached --check`: clean.
- `python3 -I tools/check_project.py`: passed, zero problems. Fresh ZIP extracted/imported on
  Godot 4.7.2: Night workshop 53 and Storage 55 passed; no script/resource errors.

### Decisions proposed (not approved)
D110–D112 record user-approved shelf, ticket/PC distinction, night checks/switching and activity hub.
The temporary inactive-job bridge/marker namespace is an implementation seam for Claude to review,
not approval of a final shared-PC schema. Two-PC demo layout/fault assignment is provisional tuning.

### Known issues and open items
The legacy final-check method still pays when called from legacy code; new night navigation never
calls it or enters that old shop route. Shared thermal evaluation should be extracted when Claude
integrates the canonical diagnostic/pickup split to avoid formula drift. Missing manifests protect
the file and recover the active PC but cannot reconstruct absent inactive data. Physical paste is
saved at bench checkpoints/exit; transient hand/tool poses and an unsecured mount are not resumed.
No target-hardware performance claim. Graphical readability/feel need the user's playtest.
Existing rack pricing/capacity hooks and salvage campaign isolation are unchanged.

### Next action
Claude goes next: cross-review the stacked PR, particularly checkpoint/recovery and the namespaced
marker bridge; user playtests New Game → Activities → Workshop, switches unfinished PCs, tests paste
and three-shelf readability. Keep both PRs unmerged. Hot files bench_view.gd, tool_rig.gd and
game_state.gd remain reserved for Claude's active work and are untouched; none is claimed free here.
WORK_PLAN.md is unchanged. Reconcile version metadata if Claude's parallel delivery lands first.

## 0.29.0 - 2026-11-14 - General storage rack and furniture expansion

- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work
- Based on: 0.28.0 (main 08a11a4)
- Type: minor (new player-visible inventory scene and auxiliary layout contract)

### Execution status
Codex ran Godot 4.7.2 headless locally. All 11 required suites passed (1,059 checks),
plus the zero-check pending-contract report and scripted bench smoke diagnostics. No graphical
or user playtest is claimed. All checks use isolated test saves. Date: 14 November 2026,
Europe/Bucharest. Delivery is an unmerged feature branch; no game-state hot file was edited.

### Added / Changed / Fixed / Removed
- Start menu → Storage rack. General inventory projects current owned parts, included tools and
  the active customer PC onto space-limited shelves. Generic names, colours and hover details.
- Smooth pickup following, rotation around the grab point, valid/invalid placement previews,
  safe cancellation, cross-shelf/furniture movement, paging and a visible overflow waiting area.
- Add steel racks, shallow component cabinets or tool boards; remove empty furniture. Furniture
  is free in this prototype, capped at eight units. No new economy or purchase charging.
- Layout-only safe save, malformed-save reconciliation, backup recovery, future-version guard,
  write-failure reporting. Source records remain canonical; no stock duplication or ownership transfer.
- Separate feature files avoid Claude's hot files and customer/shop screen. One small menu hook.
- Existing purchase/intake/drawer capacity checks remain unchanged; shared capacity integration
  is an explicit follow-up. Customer PC includes its fitted parts; installed shop stock keeps a
  marked reservation. Tool kit ownership and single-PC source remain the current trial's limits.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `CHANGELOG.md` | M | Signed 0.29.0 delivery record |
| `.github/workflows/tests.yml` | M | Add required Storage suite |
| `DEVELOPMENT.md` | M | File map and layout-only save contract |
| `HANDOFF.md` | M | Version, coordination boundaries and next action |
| `README.md` | M | Version and entry instructions |
| `docs/CURRENT_STATE.md` | M | Storage feature scope and prototype limitations |
| `docs/DECISIONS.md` | M | Storage feature scope and prototype limitations |
| `docs/DESIGN.md` | M | Storage feature scope and prototype limitations |
| `docs/PROJECT_BRIEF.md` | M | Storage feature scope and prototype limitations |
| `docs/ROADMAP.md` | M | Storage feature scope and prototype limitations |
| `docs/STORAGE.md` | A | Controls, ownership/capacity/save boundaries and review handoff |
| `docs/TESTING.md` | M | Storage verification and manual playtest steps |
| `project.godot` | M | Version 0.29.0 |
| `scenes/storage.tscn` | A | New inventory scene |
| `scripts/storage/storage_data.gd` | A | Isolated storage module; see DEVELOPMENT file map |
| `scripts/storage/storage_model.gd` | A | Isolated storage module; see DEVELOPMENT file map |
| `scripts/storage/storage_sources.gd` | A | Isolated storage module; see DEVELOPMENT file map |
| `scripts/storage/storage_store.gd` | A | Isolated storage module; see DEVELOPMENT file map |
| `scripts/storage/storage_view.gd` | A | Isolated storage module; see DEVELOPMENT file map |
| `scripts/view/start_view.gd` | M | Isolated Storage rack menu button |
| `tools/test_storage.gd` | A | 55 ownership, packing, persistence and scene-input checks |

### Checks performed
- Godot 4.7.2 headless: Data schema 198; Regression 564; Start screen 14; Dust flow 43;
  Bench interaction 26; Bench feedback 27; Audio and vacuum 36; Performance contracts 24;
  Salvage 40; Salvage physics 32; Storage 55. Total 1,059 checks, zero failures or script errors.
- Pending contracts: zero checks, zero failures. Bench `--smoke`: Playtest finished, no script errors.
- `python3 -B tools/test_ci_scope.py`: nine tests passed. `git diff --cached --check`: clean.
- Storage tests exercise failure/recovery paths intentionally; backup/read and blocked-write warnings
  are expected. They verify ownership is unchanged by rack operations.
- `python3 -I tools/check_project.py`: passed, zero problems. Fresh source ZIP extracted: hygiene,
  Godot 4.7.2 import and Storage suite passed; no missing resource or script errors.

### Decisions proposed (not approved)
D109 records the user-approved rack and expansion feature. Furniture being free, eight-unit cap,
sizes, fixed starter tool IDs and reserving shelf space for fitted shop parts are provisional.
A single capacity API shared by purchases/intake/salvage is the proposed next integration, not built.

### Known issues and open items
Graphical layout, mouse feel and display scaling need user playtest. No target-hardware performance
claim. Current trial exposes only one active customer PC and RAM/GPU/cooler stock; future canonical
PC/tool/catalogue records should extend the adapter, not create parallel owned stock. Furniture
layout persists across New game; the current source inventory is reconciled on entry. Storage does
not block buying/intake, and does not replace the old hardware drawer yet. Salvage remains isolated.

### Next action
Claude goes next: cross-review this unmerged PR and coordinate shared capacity/canonical item hooks;
user playtests F5 → Storage rack. Do not merge automatically. Codex is finished editing these files.
Hot files bench_view.gd, tool_rig.gd and game_state.gd were untouched and remain reserved for Claude's
current engineering work; none is claimed free by this delivery. WORK_PLAN.md is unchanged.

## 0.28.0 - 2026-11-14 - Cross-review fixes, customer rotation, settings, rim containment

- Author: Claude (Fable 5, model id claude-fable-5), working in a chat session
- Based on: 0.27.0
- Type: minor (new menu feature, rotation rule, save hardening; saves migrate)

### Execution status
Godot was NOT run by me directly. GitHub Actions ran all eleven suites on Godot 4.7.2 headless.
No interactive playtest is claimed.
Actions result: run 43612741461 on 9d6251f succeeded — Data schema 198, Regression 564, Start
screen 14, Dust flow 43, Bench interaction 26, Bench feedback 27, Audio and vacuum 36,
Performance contracts 24, Salvage 40, Salvage physics 32, Pending contracts 0; 1004 checks,
0 failures, plus the scripted bench playtest. The first push failed one new check (sparse visit
records crashed the history normaliser); fixed in 9d6251f and caught only because test_0_28
feeds the loader damaged saves.

### Added
- Settings on the main menu (D107): a sound slider (master volume, applied live, muted at zero).
  Kept in its own `user://nightshift_settings.json` — never in the game save, survives new games.
- Customer rotation (D104): completing a ticket brings the NEXT customer in, so Relu D. actually
  appears after Mara's PC is done. Abandoning a ticket keeps the same customer waiting. The
  counter is the shop's property (saved, kept across new games); the ticket's name, complaint and
  payout now come from the customer record.
- The dossier leads with a NEEDS line (user request): "NEEDS: boots up, runs quiet" for Mara,
  "NEEDS: boots up, Counter Stroke 2 at 60 fps" for Relu. A clueless customer's line will show
  only what they SAY (the stated decoy, D93).

### Changed
- Both lower-card shop tabs (Final check, Customer) are now bounded ScrollContainers: long text
  scrolls inside the card instead of spilling over the footer (Codex cross-review of 0.25.0,
  finding 1 — also the user's screenshot).
- Trust moves at least ±1 per pickup (D105, Codex finding 2): happy gains max(1, round((score−70)/10)),
  unhappy loses at least 1. Integer division used to swallow scores 61–79 entirely.
- Salvage (D108, user playtest): the held find can no longer bulldoze other finds out of the
  dumpster. A rim barrier (layer 256, rim to ceiling) stops every body except the held one; only
  the carried find crosses the rim. Releasing a find exactly over the 12 px rim column will
  depenetrate it sideways — accepted for the prototype.

### Fixed
- Loaded customer history is rebuilt field by field (D106, Codex finding 3): junk entries are
  dropped instead of crashing the shop with an invalid cast, a missing trust defaults to that
  customer's own trust_start (Relu 65, not 50), scores/comebacks are clamped, and each customer
  keeps only the last 10 visits (proposal).

### Removed
- The unused PAYOUT constant (the payout comes from the customer record now).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/state/game_state.gd` | M | Rotation counter, trust_step, history normalisation + cap, settings load/save, payout from record |
| `scripts/view/shop_view.gd` | M | ScrollContainer tabs, NEEDS line, defensive history read |
| `scripts/view/start_view.gd` | M | Settings button + dialog with the sound slider |
| `scripts/salvage/salvage_physics.gd` | M | Rim barrier (layer 256); held body drops the barrier bit |
| `scripts/salvage/salvage_body.gd` | M | Default collision mask includes the barrier |
| `tools/test_regressions.gd` | M | test_0_28 (rotation, trust steps, damaged saves, history cap, settings, dossier bounds); rotation pins in older money asserts; scroll-based tab checks |
| `tools/test_start_screen.gd` | M | Settings dialog and slider checks |
| `tools/test_salvage_physics.gd` | M | Rim-barrier containment + carried-find crossing checks |
| `docs/DECISIONS.md` | M | D104–D108 |
| `HANDOFF.md` | M | 0.28.0 section; version |
| `README.md` | M | Version |
| `project.godot` | M | config/version 0.28.0 |
| `CHANGELOG.md` | M | This entry |

### Checks performed
- `python3 -I tools/check_project.py`: PASSED (0 problems).
- GitHub Actions (all suites) on branch `feature/0.28.0`: recorded under Execution status when
  the run finishes.

### Decisions proposed (not approved)
- History cap at 10 visits per customer; the rotation order (simply the order in `customers.gd`).
- Trust step sizes (±1 minimum, about 1 per 10 points from the threshold).
- "Abandoning keeps the same customer" as the New-game rule.
- The dossier keeps showing the exact budget for the prototype (Codex flagged it; later pricing
  may hide the customer's true maximum).

### Known issues and open items
- Ticket IDs restart at T001 per run, so history from different runs shares IDs (Codex); real
  comeback/scam resolution needs unambiguous visit identity — before the night loop.
- Wave 2 (the software-checks monitor screen: boot test, anti-virus, Vapor store) is NOT started,
  per the user's explicit instruction.
- Relu's fps need is scored invisibly until the software screen exists; the dossier at least
  names it now.

### Next action
Await the user's playtest of 0.28.0; wave 2 (software-checks screen) only when the user says so.


## 0.27.0 - 2026-11-14 - Native 2D dumpster gravity, collisions and opening containers
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: 0.26.0, 15d616f4fe2654a6ae79eb6124693dd194e7d4cc, continuing the existing unmerged salvage PR #33; latest main remains 0.25.0.
- Type: minor — user-authorised side-view native-physics experiment; no shared campaign/save contract change.

### Execution status
Codex ran Godot 4.7.2.stable.official.ed1daf0bf locally, headless. All ten required suites passed:
974 checks, zero failures. The bench smoke diagnostic completed without script errors. Native tests await
actual PhysicsServer2D frames; these are not fake manually stepped body positions. No human visual/feel
acceptance is claimed. The user decides whether this trial is fun enough to keep.

### Added / Changed / Fixed / Removed
- Replaced the floating top-down overlap/nudge pile with a side-view native RigidBody2D world: gravity,
  object-object collisions, support, natural falling/rotation and sleep. Initial columns do not overlap.
- Added bounded force/torque mouse grips. Held bodies still collide with the pile; removing support can
  make it collapse. Removed the artificial overlap-percentage blocking rule and custom pile solver.
- Visible floor/rim/sorting geometry matches static colliders. A find must physically clear the rim
  before a trunk claim; dropping the cursor on the grid cannot extract a still-trapped item.
- Boxes/PCs open into three-wall hollow bodies with their pre-generated tangible contents; bags flatten
  into light bodies and spill contents. Reopening cannot reroll/spawn more rewards. Rigid placeholders,
  not real soft bags or final graphics.
- World cancellation releases in place, avoiding teleportation into a now-occupied old pose. Cargo
  rollback still restores its committed placement and removes its transient body. Pause/focus/menu and
  motion-time charging coordinate native state without changing UID/cycle/return rules.
- Added native physics tests and a separate 20/50/100-body stress profiler. Pure salvage time/grid/UID
  checks remain; obsolete fake-solver/percentage-gate checks were removed and scene/input checks moved
  to the real native-frame suite. Ten suites now required. No host timing pass/fail thresholds.
- Reconciled core docs to revision 1.15, recorded D103 as an authorised prototype trial, and updated
  handoff/contracts. Same session-only progress, no campaign inventory/save/clock/customer/software
  integration. No hot file or WORK_PLAN.md edit. Existing PR #33 is updated, not merged.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/salvage/salvage_body.gd` | A | Native body shapes, material/sleep/CCD and bounded grip force/torque integrator |
| `scripts/salvage/salvage_physics.gd` | A | Native world/bounds, pose/identity sync, picking, pause and cargo grip handoff |
| `scripts/salvage/salvage_pile.gd` | M | Non-overlapping side-view generation, opening/flattening; remove fake physics/occlusion/picking |
| `scripts/salvage/salvage_session.gd` | M | Engine-owned motion mode, physical extraction/release, one motion charge, logical cargo rollback |
| `scripts/salvage/salvage_view.gd` | M | Native-world lifecycle/input/query integration, cutaway/rim/hollow-container drawing and grip line |
| `tools/test_salvage.gd` | M | 40 retained pure rule cases, remove obsolete fake-physics checks; move scene coverage |
| `tools/test_salvage_physics.gd` | A | 27 native-frame support/collision/grip/opening/cargo/pause/scene checks |
| `tools/profile_salvage_physics.gd` | A | Optional fall/settle/pulling physics-phase percentile/load profile |
| `.github/workflows/tests.yml` | M | Tenth required native physics suite |
| `docs/SALVAGE_DESIGN_PROPOSAL.md` | M | Current physics-trial behaviour and limits; retain historical first slice |
| `docs/DECISIONS.md`, `docs/DESIGN.md`, `docs/MINIGAME_RULES.md` | M | D103, native support/opening/extraction/release rules |
| `docs/PROJECT_BRIEF.md`, `docs/CURRENT_STATE.md`, `docs/ROADMAP.md` | M | Revision 1.15, trial status and isolated next steps |
| `docs/TESTING.md` | M | Ten-suite policy, real engine-frame checks and correct profiling method |
| `DEVELOPMENT.md` | M | Four new files, native-world ownership, pause/custody/motion contracts |
| `HANDOFF.md` | M | Signed 0.27.0 trial instructions, scope and cross-review handoff |
| `README.md`, `project.godot` | M | Version and updated play instructions; normal launch/autoloads unchanged |
| `CHANGELOG.md` | M | This signed delivery entry |

### Checks performed
Godot 4.7.2 suites: schema 198, regression 543, start screen 10, dust flow 43, bench interaction 26,
bench feedback 27, audio and vacuum 36, performance contracts 24, salvage rules 40, native salvage
physics 27: all passed, zero failures (974 total). Bench --smoke: Playtest finished; no script/parse errors.
Initial native probe confirmed 17 generated bodies settled; flatter bag colliders stopped prolonged
rocking. Actual tests prove support removal/collapse, collisions/floor, force pulling, sleep, pause,
container contents/hollow walls, physical rim clearance, cargo rollback, real menu/input and campaign isolation.
Python CI-scope tests: 9 passed. Project hygiene PASSED (zero problems); diff check PASSED; workflow YAML parsed and tenth suite listed.
Fresh source ZIP extracted: hygiene checker PASSED, Godot 4.7.2 import PASSED, pure salvage
40 checks/zero failures PASSED, native salvage physics 27 checks/zero failures PASSED. All five core
documents included; no cache/generated UID sidecars. No graphical acceptance is claimed.

Native stress profile, same container/engine, headless, sequential (no competing Godot test): 240 samples
of fall/settle, 60 of late-settle, 120 of pulling per load. Physics-phase wall time spans physics_frame
through process_frame, including native physics and model sync/dispatch. It is not just the view callback
and does not use the coarse Performance.TIME_PHYSICS_PROCESS monitor as a per-frame percentile source.

| Bodies | Fall/settle mean ms | p95 ms | p99 ms | Max ms | Pulling mean ms | Pulling p95 ms | Sleeping after 240 ticks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 20 | 0.284 | 0.516 | 0.660 | 0.981 | 0.254 | 0.434 | 20 |
| 50 | 0.793 | 1.038 | 1.278 | 1.997 | 0.795 | 1.076 | 50 |
| 100 | 1.453 | 2.472 | 3.954 | 5.453 | 1.209 | 1.659 | 100 |

These are synthetic simple-box loads, not a GPU/whole-game FPS guarantee or comparable to 0.26.0's
33 us fake-pile view callback. Reproduce with tools/profile_salvage_physics.gd. Normal generated sites
start with 17 visible bodies; pre-generated contents add bodies only on opening.

### Decisions proposed (not approved)
Force/torque/velocity limits, friction/damping, primitive bag geometry, rim height, transfer-point target,
spawn layout and all previous car/time/loot tuning remain provisional. Final camera/minigame choice
awaits user feel feedback. Soft bodies, 3D and new campaign integration are not introduced.

### Known issues and open items
Headless tests cannot assess human drag feel/art/readability. Bags remain rigid approximations; 3D depth
is absent. Synthetic CPU numbers do not predict every player's hardware or graphical frame costs.
Scene/session progress is still in-memory only. Claude must supply reviewed campaign state adapters.

### Next action
User tests F5 → Salvage demo: pull a support, open/tilt a box or bag, lift over the rim and pack; compare
feel with 0.26.0. Claude cross-reviews force stability/native lifecycle/custody and the proposed adapters.
Do not self-merge PR #33. Who goes next: user for feel and Claude for cross-review; Codex for separately
requested Claude review/tuning. Hot files free to Codex: none; Claude retains all three.

## 0.26.0 - 2026-11-14 - Playable standalone night salvage demo
- Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
- Based on: main 0.25.0, 4377ff4e161a3e8565775b6c3ddd7577ec6bd57a (Claude's merged customer wave).
- Type: minor — new isolated scene and minigame. No campaign save-format or customer/bench rule change.

### Execution status
Codex ran Godot 4.7.2.stable.official.ed1daf0bf locally, headless: all nine required suites passed,
958 checks, zero failures; the representative bench smoke diagnostic completed without script errors.
New salvage checks were rerun after further isolated handling/feedback fixes and passed. No interactive
visual/feel acceptance is claimed; no display server was available. Read the PR checks for independent
Actions results rather than treating them as already run in this entry.

### Added / Changed / Fixed / Removed
- Added F5 → Salvage demo, separate from New/Load. Two test cars trade speed for trunk size; two sites
  have different hardware odds, travel costs and few-day deterministic refresh cycles.
- Move/open bags and boxes, uncover clues and parts, strip a PC, use the sorting area and pack a
  rotatable trunk grid. Mostly covered objects require clearing cover first. Weighted following/sway,
  restrained neighbour nudges/throws/edge bounce and sleeping bodies provide a bounded 2D prototype.
- Explicit partial-effort/drag/travel charges; idle wall time does not also consume the night. Return
  travel is reserved and charged once. Pause, cancellation, focus loss and failed drops preserve custody.
- Finds retain true hidden versus untested condition, sample tier/rated output and UID. A packed PC
  takes its real hidden child parts with it; stripping reveals them and marks the case incomplete.
  Cross-site movement cannot resurrect a duplicate on the original site. Cargo/shelf survive refresh.
- Return/unload move items once into an isolated demo shelf. Menu/revisits retain the session; app exit
  or Reset clears it. No shared save, night/day, stock, money or customer writes. Campaign wiring waits
  for Claude's reviewed APIs and shared-PC model; no pretending broken stock fits today's working-only loader.
- UI preserves warnings, shows hover/action/time/grid feedback, skips unchanged controls and emits
  existing silent handling/UI events. No new sounds/assets, final graphics or full soft-body/3D physics.
- Incorporated approved design PR #31 and renumbered its decisions D98–D102 around Claude's customer
  D92–D97. All five core docs revision 1.14. No hot file, customer/software code or WORK_PLAN.md edit.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scenes/salvage.tscn` | A | Separate salvage screen |
| `scripts/salvage/salvage_data.gd` | A | Car/site/shape/sample ratings, local layout and tuning |
| `scripts/salvage/cargo_grid.gd` | A | Committed UID/rotation/footprint grid packing |
| `scripts/salvage/salvage_pile.gd` | A | Deterministic layered pile/containers, obstructions and bounded physical response |
| `scripts/salvage/salvage_session.gd` | A | Isolated effort/travel/cycles, custody, nested PCs and return/unload |
| `scripts/salvage/salvage_view.gd` | A | Map/pile/trunk input and drawing, cached controls, hints/pause/feedback |
| `scripts/view/start_view.gd` | M | Independent Salvage demo entry; New/Load unchanged |
| `tools/test_salvage.gd` | A | 51 correctness/input/isolation checks plus an informational idle CPU observation |
| `.github/workflows/tests.yml` | M | Ninth required salvage suite |
| `docs/SALVAGE_DESIGN_PROPOSAL.md` | A | Reconciled approved direction, implemented slice, future contracts and limits |
| `docs/DECISIONS.md` | M | D98–D102 and design revision |
| `docs/DESIGN.md` | M | Approved salvage scope and implementation/integration distinction |
| `docs/DESIGN_PROPOSALS.md` | M | Reconcile older salvage/backpack labels and concurrent decision IDs |
| `docs/MINIGAME_RULES.md` | M | Salvage rules, prototype tuning and session-only boundary |
| `docs/PROJECT_BRIEF.md`, `docs/CURRENT_STATE.md`, `docs/ROADMAP.md` | M | Current playable scope, prototype limitations and collaboration |
| `docs/TESTING.md` | M | Nine-suite policy and salvage correctness coverage |
| `DEVELOPMENT.md` | M | All new files and session/custody/clock contracts |
| `HANDOFF.md` | M | Signed handoff, starting instructions, exact integration limits |
| `README.md` | M | Version and play instructions |
| `project.godot` | M | Version only; normal main scene/autoloads unchanged |
| `CHANGELOG.md` | M | This signed delivery entry |

### Checks performed
Godot 4.7.2: schema 198, regression 543, start screen 10, dust flow 43, bench interaction 26, bench
feedback 27, audio and vacuum 36, performance contracts 24, salvage 51: all passed, zero failures.
Salvage covers grid bounds/overlap/rotation, obstruction/clearing, proportional effort/cancel/pause,
return replay, generated contents, custody across cars/sites, PC stripping, cycle refresh, unload replay,
throw bounds/sleep, real menu/input and absence of campaign money/stock/job side effects.
Representative --smoke diagnostic: Playtest finished; no SCRIPT ERROR/Parse Error. Python CI-scope
integration tests: 9 passed. Diff audit confirms no hot file/customer/software/WORK_PLAN changes.
New scene headless startup passed. Idle salvage-view physics probe: 60 warmup + 600 ticks, mean 33.1 us,
p50 27 us, p95 52 us, p99 96 us, max 1011 us. Same container/engine, CPU only; not player FPS or a gate.
Project checker: PASSED, zero problems. Workflow YAML parsed; ninth suite listed. git diff --check
passed. Fresh source ZIP extracted: checker PASSED (zero problems), target Godot 4.7.2 import PASSED,
Salvage 51 checks/zero failures PASSED. All five core docs included; caches/generated UID sidecars excluded.

### Decisions proposed (not approved)
All prototype numbers: car models/speeds/grids, 180-minute budget, 3/4-day refresh, loot weights, effort
holds/costs/drag rate and physics weights. Return reservation/refusal is a playable default, not the final
overtime policy. On-site disassembly is limited to the prototype PC's hidden RAM/GPU; full catalogue,
vehicle purchases, tip events, diagnosis and campaign transfers are not authorised through this demo.

### Known issues and open items
Session-only: app exit/Reset loses salvage progress; goods never enter campaign repair stock. No shared
clock/save/PC adapter yet. Simple top-down layers/nudges are not full stacked rigid bodies or soft bags.
Only hardware packs; unopened bags/boxes stay on site. Human layout/feel testing remains required.
This reconciles/supersedes unmerged design PR #31; keep Claude's newer decisions intact. If parallel work
advances versions/IDs again, reconcile at integration, preserving both contributors' entries.

### Next action
Claude cross-reviews the isolated minigame and proposed state interfaces; user playtests F5 → Salvage
demo. Codex reviews Claude's work when requested. Do not self-merge. No campaign wiring until Claude
hands over reviewed APIs. Who goes next: Claude for cross-review and the user for feel; Codex for the
separately requested Claude review. Hot files free to Codex: none; Claude retains them.

## 0.25.0 - 2026-11-14 - The customer model, first wave

- Author: Claude (Fable 5, model id claude-fable-5), working in a chat session
- Based on: 0.24.0
- Type: minor (new data/rules layer, a save field, a final-check rule change; saves migrate)

### Execution status
Godot was NOT run by me directly. GitHub Actions runs the automated suites on Godot 4.7.2
headless on push; the result is recorded below once the run finishes. No interactive playtest
is claimed.
Actions result: run 43588417213 on 305acd0 succeeded — Data schema 198, Regression 543, Start screen 10, Dust flow 43, Bench interaction 26, Bench feedback 27, Audio and vacuum 36, Performance contracts 24, Pending contracts 0; 907 checks, 0 failures, plus the scripted bench playtest.

### Added
- `docs/CUSTOMER_MODEL_MAP.md`: the whole customer/software system as approved point by point
  by the user before any code (D92–D97), with the wave-1 scope marked.
- Customers v2 (`scripts/data/customers.gd`): profession (regular / gamer / clueless first cut),
  persona, about, trust_start, budget, payout and NEEDS. Mara V. (regular: boots + quiet) is
  joined by Relu D. (gamer: Counter Stroke 2 at 60 fps). Portraits stay blank on purpose —
  they must later derive from the character's actual look.
- Video games (`scripts/data/games.gd`): the shop BUYS games to test with (an investment).
  One test game, Counter Stroke 2 ($12; gpu demand 55, cpu demand 60, 8 GB minimum — proposals).
  `GameState.buy_game` / `owns_game`; owned games are the shop's property: saved, and kept
  across new tickets.
- FPS simulation (`scripts/rules/fps_sim.gd`, D94): fps = 60 × the worst of gpu/demand and
  cpu/demand; heat throttles the GPU linearly from 60 C (no loss) to 90 C (half); RAM under the
  game's minimum keeps 35% of the frames. The job now carries `pc_specs` (cpu_power, ram_gb).
- Pickup score (`scripts/rules/pickup_score.gd`, D95): the FIRST passing final check scores the
  pickup 0–100 against the customer's REAL needs (temperature, each named game at its minimum
  fps on the PC as handed back, quiet). 70+ leaves happy; unhappy customers come back about it,
  angrier sooner (<40 → 1 day, <60 → 2, else 3). Trust moves by (score−70)/10 per visit. The
  score, misses and comeback land in `customer_state` (trust + history) in the save, which
  survives new_game. The shop result and the Customer tab show the score and the comeback.

### Changed
- Boot test replaces the power threshold (D97, supersedes D79's threshold): the PC can be handed
  back with ANY power output as long as it boots — it boots when nothing is broken and nothing
  is left out. The final check reports "Boot test: the PC starts." / "Boot test FAILED". GPU
  power levels stay; they now feed the fps simulation instead of gating the check.
- The Customer tab is a dossier (name — profession — trust N/100, about, complaint, uses,
  habits, time, budget and payout, last visit's score and comeback); the shop's lower card grew
  to fit it.
- `required_power` is erased from loaded jobs (migration); `pc_specs` is sanitised on load.

### Fixed
(nothing)

### Removed
- The "needs at least N graphics output" final-check rule and its regression checks (replaced
  by boot-test assertions).

### Files changed
| File | Change | What |
| --- | --- | --- |
| `docs/CUSTOMER_MODEL_MAP.md` | A | The approved map, wave-1 scope and the user's answers |
| `scripts/data/games.gd` | A | Buyable test games and their demands |
| `scripts/rules/fps_sim.gd` | A | Simulated frame rate (thermal throttle, RAM stutter) |
| `scripts/rules/pickup_score.gd` | A | Pickup score 0–100 and comeback days |
| `scripts/data/customers.gd` | M | Customer records v2 (professions, trust, budget, needs); Relu D. added |
| `scripts/state/game_state.gd` | M | pc_specs, boot test, buy/owns game, customer_state save + pickup recording |
| `scripts/view/shop_view.gd` | M | Dossier Customer tab; pickup line in the check result |
| `scripts/data/layout.gd` | M | Taller lower card for the dossier |
| `scripts/data/service_parts.gd` | M | Comment: power feeds the fps simulation now |
| `tools/test_data_schemas.gd` | M | Customers v2 + games schemas, profession membership, needs reference real games |
| `tools/test_regressions.gd` | M | Boot-test assertions replace power gating; new test_0_25 (fps, buying, pickup, trust, history, persistence) |
| `docs/DECISIONS.md` | M | D92–D97 |
| `DEVELOPMENT.md` | M | File map: the three new files; customers.gd description |
| `HANDOFF.md` | M | 0.25.0 section; version |
| `README.md` | M | Version |
| `project.godot` | M | config/version 0.25.0 |
| `CHANGELOG.md` | M | This entry |

### Checks performed
- `python3 -I tools/check_project.py`: result recorded below.
- GitHub Actions (all suites incl. the new checks) on branch `feature/0.25.0`: recorded under
  Execution status when the run finishes.

### Decisions proposed (not approved)
- All numbers: Counter Stroke 2's price/demands, throttle curve (60→90 C to half), RAM stutter
  share (35%), score weights (temp 25, missed game 35, missed quiet 40), happy threshold (70),
  trust step ((score−70)/10), comeback days (1/2/3), Mara's and Relu's trust/budget/payout.
- "Quiet" read as final temp ≤ 65 C (hot PCs are loud PCs) until fans/noise are simulated.
- Relu D.'s record itself (a second scripted customer to exercise the gamer needs).

### Known issues and open items
- The software-checks monitor screen (boot test, anti-virus, Vapor store, overclocker) is the
  next wave; only its rules exist. The overclocker minigame is second wave (user).
- Comeback visits need the night loop; the days are recorded, nothing returns yet.
- Scam discovery (habits → delayed trust loss) is designed (D95) but not built.
- Codex builds the dumpster-salvage minigame in parallel; Claude cross-reviews when both are done.

### Next action
Build the software-checks monitor screen (wave 2): boot test app, Vapor store (buy + run
Counter Stroke 2 with the simulated fps), anti-virus first cut.


## 0.24.0 - 2026-11-14 - Unscrewing takes time; colour-coded tools; salvage assigned to Codex
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.23.0
- Type: minor (interaction change). From the user's direction ("picking up stuff should take time; the night is about managing limited time").

### Execution status
**Godot was NOT run by me directly.** GitHub Actions runs everything on Godot 4.7.2 headless; results below. Not hand-tested.

Actions result (Godot 4.7.2 headless, run 43584646673, branch feature/0.24.0): checker passed; all nine suites green (876 checks, 0 failures) including the new D89/D90 checks. A first run failed one older check that pressed and released a fitted part in the same frame; it now holds through the unscrew time, which keeps what it really tested (event positions driving the drag).

### Added / Changed / Fixed / Removed
- Added (D89): unscrewing. In Move parts mode, a FITTED cooler or GPU is freed by holding on it for 1.2 s (progress ring at the cursor; letting go or slipping more than 24 px off cancels with a message; switching tool or stage cancels silently). The drag starts the moment it frees. A part lying in the tray lifts instantly. Direct calls to `_begin_part_drag` (tests, future code) bypass the hold on purpose.
- Added (D90): the four tool buttons are colour-coded in all button states: vacuum blue, brush amber, move parts green, pick red.
- Added (D91): `docs/CODEX_PROMPT_SALVAGE.md`, the user's parallel assignment for Codex: the street/dumpster salvage minigame, design proposal first, own scene and scripts, no hot files, saved fields through Claude.
- Noted (D91): the customer model rework and the software-checks screen are to be MAPPED before any code; nothing of them is built here.
- Tests: press alone does not lift a fitted part; early release cancels and the part stays fitted; holding through the time lifts it; the bench-interaction suite holds through the unscrew; every tool button has its own colour.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/view/bench_view.gd` | M | unscrew hold, progress ring, button colours |
| `tools/test_regressions.gd`, `tools/test_bench_interactions.gd` | M | D89/D90 checks |
| `docs/CODEX_PROMPT_SALVAGE.md` | A | assignment prompt |
| `docs/DECISIONS.md` (D89-D91), `DEVELOPMENT.md`, `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | docs, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
The 1.2 s duration and the 24 px slip allowance; which other pickups get timings next; the four colours.

### Known issues and open items
Tool drawings do not yet carry their button colours. The customer/software mapping is the next design conversation.

### Next action
User playtest of 0.24.0 (feel of the unscrew hold). User gives Codex docs/CODEX_PROMPT_SALVAGE.md. Then the customer/software mapping conversation. Hot files stay with Claude.

## 0.23.0 - 2026-11-14 - Dust is not a blocker; the shop knows its customer
- Author: Claude (Fable 5, model id claude-fable-5) in a chat session; the project is in the user's GitHub repository `123rearearcode/nighshift_real`.
- Based on: 0.22.1 (Codex's idle-performance pass, merged after cross-review)
- Type: minor (rule change and a new shop tab). From the user's 0.22.x playtest.

### Execution status
**Godot was NOT run by me directly.** GitHub Actions runs everything on Godot 4.7.2 headless; results below. Not hand-tested.

Actions result (Godot 4.7.2 headless, run 43581035981, branch feature/0.23.0): checker passed; all suites green, 0 failures (counts recorded in the log; regression includes the new D87/D88 checks). Two earlier pushes failed the checker because my edit script aborted half-way (wrong anchor text), leaving the version bumped without its changelog entry; the checker caught exactly that.

### Added / Changed / Fixed / Removed
- Changed (D87, the user's screenshot): the final check no longer fails a cool PC for leftover dust. Dust counts only through the temperature it adds; the notes still name the dusty parts, the "Every part must be cleaned" line is gone, and the shop's hint text says the new rule. Functionality is still required: broken parts, parts left out or missing graphics output fail as before, and a fully dusty PC still fails on temperature alone.
- Added (D88): a Customer tab on the shop's lower card (tab buttons Final check | Customer; running the check returns to the result). It shows who the customer is, what they use the PC for (the source of the required graphics output), their habits (written for the scam direction: Mara V. never opens the case, notices noise, writes reviews), their time and the payment. `scripts/data/customers.gd` (fictional people only); the job carries `customer_id` with save migration.
- Tests: customers schema; dusty-but-cool PC passes with notes and gets paid; part left out still fails; fully dusty still fails on temperature; customer on the job and after an old-save load; shop tab swap, content and return-on-check.

### Files changed
| File | Change | What |
| --- | --- | --- |
| `scripts/data/customers.gd` | A | customer records |
| `scripts/state/game_state.gd` | M | D87 rule, customer fields + migration |
| `scripts/view/shop_view.gd` | M | tabs, customer text, hint wording |
| `tools/test_regressions.gd`, `tools/test_data_schemas.gd` | M | new checks |
| `DEVELOPMENT.md`, `docs/DECISIONS.md` (D87-D88), `HANDOFF.md`, `README.md`, `CHANGELOG.md`, `project.godot` | M | docs, version |

### Checks performed
`python3 -I tools/check_project.py`: PASSED. Godot 4.7.2 via Actions: see Execution status.

### Decisions proposed (not approved)
Mara V.'s habits and patience text; which habits ever become mechanics; the tab layout.

### Known issues and open items
The night loop ("advancing through the night") the user wants next is not started; the customer record is its first building block.

### Next action
User playtest of 0.23.0 (final check should now pass; read the Customer tab). Then: the user wants the night loop; design first (Codex, per the work split), while Claude continues work plan step 7. Hot files stay with Claude.

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
