# Nightshift — Bug register

Every bug goes here when it is found (user playtest, CI, cross-review), not only when it is
fixed. One row per bug in the table; bigger bugs get a section below with the root cause. The
goal is to see STRUCTURAL problems: when several bugs share a root cause, that cause is the
real bug. Rules for keeping this file are in `AGENTS.md` (rule 6) and `DEVELOPMENT.md`.

**Structural review: every 10 versions** (0.30.0, 0.40.0, …) the integrating AI re-reads this
whole file, writes a short "Patterns" entry at the top of the Reviews section below, and
proposes structural work to the user. The 0.30.0 checkpoint was prepared by Codex and completed by Claude at integration (0.32.0, see Reviews); the next regular review is **0.40.0**.

## How to file a bug

Add a table row at once (ID, found version, status `open`). Fill `Fixed` when a release fixes
it. If the root cause is not local — if the same cause could bite again elsewhere — add a
section under "Root causes" and say what the structural answer would be, even if only the local
fix ships now.

| ID | Found | Fixed | Reported by | Symptom | Root cause (short) |
| --- | --- | --- | --- | --- | --- |
| B1 | 0.19.x | 0.19.7 | Codex review | Idle paste bench kept an active mounting session | stage state not cleared on switch |
| B2 | 0.21.0 | 0.22.0 | user video | Hose end detached from the vacuum; vacuum stayed behind | two owners of one position (hose sim vs tool rig), no bridge |
| B3 | 0.21.0 | 0.22.1 | user video | Crowded tools "disappear" (teleport across the obstruction) | collision resolver pushed to the far side; no table clamp |
| B4 | 0.22.x | 0.23.0 | user playtest | Final check demanded full cleaning the design no longer wanted | rule lived in code, not in the agreed design (D87 settled it) |
| B5 | 0.25.0 | 0.28.0 | Codex cross-review + user screenshot | Customer dossier text overflowed its card and the footer | plain Labels grow to content; fixed rects do not bound them (see RC-2) |
| B6 | 0.25.0 | 0.28.0 | Codex cross-review | Trust never moved for scores 61–79 | integer division swallowed small deltas |
| B7 | 0.25.0 | 0.28.0 | Codex cross-review | Hand-edited/damaged save crashed the shop (invalid cast) | loaded data trusted without per-field validation (see RC-3) |
| B8 | 0.28.0 | 0.28.0 | CI (new test) | History normaliser crashed on visit records missing keys | `get()` default passed the type test, then direct `[]` access hit the missing key |
| B9 | 0.26/0.27 | 0.28.0 | user playtest | Held salvage find bulldozed other finds out of the dumpster | zone decided by bare x-position; no ownership gate at the rim (D108) |
| B10 | 0.28.0 | 0.32.0 | user playtest | **Loop-blocker:** GPU replaced "at the hardware bench" but the final check still failed | two disconnected PCs: the sandbox never writes job state (see RC-1) |
| B11 | 0.28.0 | 0.32.0 | user playtest | Coolers unmountable at the hardware bench ("needs a mount"); no CPU exists | sandbox board had no COOLER_MOUNT slot and stock had no CPU (see RC-1) |
| B12 | 0.28.0 | 0.32.0 | user playtest | Broken GPU came as a surprise at the final check | damage feedback was a 3 s status line; ticket/check never showed part states (see RC-2) |
| B13 | 0.28.0 | 0.32.0 | user playtest | Main-menu status text crossed the card border | buttons were added without growing the card; AND the label was sized before autowrap was set, so Godot clamped it to its one-line width (600 px) and it never shrank back (see RC-2) |
| B14 | 0.27.0 | 0.32.0 | Codex review of the D108 plan | Releasing a find overlapping the rim barrier could fling it | collider re-enabled inside a body; fixed with a grace exemption until clear |
| B15 | 0.27.0 | 0.32.0 | Codex cross-review | Cargo re-entry at a fixed point could spawn inside a staged find | fixed spawn coordinates; fixed with a free-space probe |


| B16 | rack/night PRs #35/#36; still present in main 0.32.0 | 0.33.0 (PR #40 merged) | user screenshots + Codex signal regression | Selecting new rack furniture crashes with locked-object/free errors after sort/save/add | Sidebar rebuilt and synchronously freed the Button emitting its own pressed signal; method-only tests missed lifecycle (RC-4) |

| B17 | pending rack/night integration with main 0.29.0 | 0.32.0 | Codex code review | Rack would omit the new starter CPU after combining branches | Rack adapter dispatches RAM explicitly, everything else through GPU/cooler ServiceParts; main now supplies a cpu record (RC-1); fixed in 0.32.0: the rack reads the canonical `GameState.inventory_components()` projection (test_storage checks the CPU appears) |

| B18 | 0.30.0 | 0.32.0 | Claude integration review | The night workshop diagnosis said only "Damaged: gpu. Replace these parts." - the B12 dead end again, on the screen that replaced the shop | a second surface wrote its own aggregate notes instead of reading the shared part rule (RC-1/RC-2); fixed with the pure `part_states.gd` rule used by every surface |

| B19 | 0.32.0 | 0.36.0 | Codex review of PR #39 | Night-workshop ticket grows over diagnosis report when parts are broken | Parts summary appended to plain Label; measured y=166..511 against report y=425 (RC-2); bounded ticket ScrollContainer added/tested in 0.36.0 |
| B20 | storage PR #35; still present in 0.32.0 | 0.33.0 (PR #40 merged) | user recording + Codex GUI regression | Add-furniture choices overlap; only last choice is usable | PopupPanel Container repositions direct Button children despite hand-set positions; replaced by Margin/VBox layout |

| B21 | before 0.34.0 | 0.34.0 | user playtest | Spool moves vacuum back but full hose immediately lies on the desk again | One length represented both deployed hose and capacity; reset re-created a full-length chain. Separate capacity from deployed length and pay out only under pulling |
| B22 | tool selection before 0.34.0; exposed by brush-first test | 0.34.0 | regression test | Hotkey selection can leave two tool buttons highlighted | set_pressed_no_signal on one Button did not clear its group peer; explicitly synchronize every tool highlight after an accepted switch |

## Root causes (structural)

### RC-1: more than one representation of "the customer's PC" (B10, B11)
The job (`game_state.gd`) is the real customer PC. The repair bench reads/writes it. The
hardware bench is a SANDBOX over `player_inventory` + a demo board — fitting a GPU there never
touched the job, and nothing told the player. Worse, the sandbox's own loop was incoherent
(coolers had no slot, no CPU existed), so it looked broken rather than separate.
0.29.0 answer: one source of truth surfaced everywhere — `GameState.part_state()` is the only
way part states are read; ticket, final check and benches all show it with the exact repair
path; the sandbox says plainly what it is and got a coherent CPU → mount → cooler loop.
Still open structurally: actually CONNECTING the customer's PC to the hardware bench (D79 note)
so there is only ONE parts model. That is the next structural step, not patched here.

### RC-2: fixed-rect UI with growing content, and state without a surface (B5, B12, B13)
Labels and cards were sized by hand and content grew past them; important state (a broken part)
lived in the model with no persistent surface. Pattern answer: every long text sits in a bounded
scrolling container with a containment regression check; every player-relevant state must have a
place on screen that shows it binary and names the next action.

### RC-3: loaded and external data trusted as-shaped (B7, B8)
Save data (and any future imported data) must be rebuilt field by field with defaults and
clamps, never cast in the UI. B8 showed even the VALIDATOR can make the same mistake — tests
must feed damaged data on purpose.

### RC-4: destroying an event source while its signal is active (B16)
Original local rack/night patches kept selection controls alive and deferred structural deletion.
Local 0.33.0 replaces selectors entirely with a drawn room and keeps toolbar/popup nodes stable.
A native Button-signal regression reproduces the old failure; direct method calls had missed it.
The older patches were not included in the remote integration. The 0.33.0 room replacement remains
local under the no-push instruction. Proposed structural
answer: UI lifecycle tests should exercise signal dispatch, with stable controls for state-only updates.

## Reviews (newest first)

### 0.40.0 - structural checkpoint (short, by Claude)
Read at the checkpoint, not a full audit. RC-1 (two PC models) is structurally closed from 0.39.0: the
hardware bench and the repair bench both read the ticket's job record (`customer_pc.gd`). New hidden-fault
sources (install faults, infection, overclock) all follow one pattern: a pure rule with heat / annoyance /
complaint tables, summed by `pickup_score.gd` and composed in `GameState.pickup_faults`. Risks I see:
(1) `bench_view.gd` is now about 1500 lines: the cooler-install ritual, tool hand-state and mounting all
live in it; splitting the install ritual into its own helper is the next structural step before more rituals
(RAM, CPU) are added. **Done in 0.41.2** (five helpers; the bench keeps state and wrappers). (2) The pickup-fault composition is a growing list in `game_state.gd`; a fourth source
should move it into one rule script. (3) Nothing from 0.38-0.40 has been playtested by the user. No new
bug-register entries; B-ids unchanged.

### 0.32.0 - integration review (the 0.30.0 checkpoint, completed)

Claude (Sonnet 5.5, model id claude-sonnet-5-5), 15 November 2026, after merging PRs #35, #36 and #38.
Patterns confirmed from Codex's preparation: (1) RC-1 recurred immediately: two independently
built surfaces (shop ticket, night diagnosis) each described part state their own way, and a CPU
stock record I added broke a third (the rack's per-kind dispatch). Both fixes are now
STRUCTURAL: one pure rule (`part_states.gd`) and one canonical component projection
(`inventory_components()`); new surfaces must read them, never re-derive. (2) Parallel branches
collided on version numbers and decision ids (three branches each claimed 0.29-0.31; D109-D113
used twice). Proposed process fix, for the user: the integrating AI assigns the next version and
decision-id block BEFORE a parallel branch starts, and branches record them in their PR body.
(3) The old shop scene is now partly legacy (the night workshop replaced it as the player-facing
flow) but still carries the legacy payout path and tests; retiring it deliberately is a later,
explicit step. (4) RC-4 (UI lifecycle tests that exercise signal dispatch) accepted as proposed by
Codex; a shared helper is the next structural test work. Next structural checkpoint: 0.40.0.

### 0.31.0 branch — preparation for the 0.30.0 structural checkpoint

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
Patterns: RC-1 still needs one canonical customer-PC/part model; B17 shows derived type lists can
drift as main gains CPU stock. Pending rack adapter must consume the canonical component projection
before integration. Inventory and inactive-ticket bridges
must remain explicit until integrated. RC-2 needs bounded labels plus persistent actionable state;
new salvage labels use short cargo names and detailed hover text. RC-3 needs per-field save validation
and identity checks; new random visits must never duplicate packed cargo. RC-4 adds event-source
lifetime to the UI test gap. Proposed next structural work (not implemented): consolidate a reusable
signal-driven UI test helper and finish canonical PC/state seams before expanding duplicate models.
This review is prepared in a PR, not a claim that pending branches were merged. Next regular
structural checkpoint after integration: 0.40.0.

| B23 | 0.34.0 | 0.35.0 | user playtest | Cloth reacts outside its intended edge | generic whole-tool pickup rectangle ignored fabric silhouette; wipe reach reduced one world pixel |
| B24 | 0.34.0 | 0.35.0 | user request + Codex review | Fresh PCs spin fans immediately; legacy final check can pay while off | default power true and two boot-rule implementations disagree; shared pure boot rule now gates both paths |

| B25 | 0.35.0 | 0.36.0 | user playtest | Activities appears in different positions or is missing on night work screens | per-screen navigation implementations diverged; shared top-right helper and native exit tests |

### 0.36.0 follow-up evidence for B16
The uploaded Screen Recording 2026-11-15 020515(1).mp4 visibly identifies v0.32.0 at 1s and
shows the old numbered furniture sidebar at 6s. Main includes its replacement from merged PR #40
(v0.33.0); current PR has no storage .free() path or per-furniture Button list. Repeat native
sort/save/add/multiple-title selections and assert persistent control identities in the new build.
This identifies a build mismatch in this evidence, not a claim that unseen current-build failures
are impossible. Fresh-folder/version instructions are in README. Signed Codex (GPT 6.1 Sol,
model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.

| B26 | 0.36.0 | 0.37.0 | user screenshot | Mount cooler remains in side panel even after a locked mount | visibility gated only by stage/active flag; shared readiness includes mass, result, completion and stage |
| B27 | 0.36.0 | 0.37.0 | user screenshot | Obsolete cloth/syringe toggle duplicates physical tool pickup | old toggle widget/state wiring retained; removed widget and updated fixtures |
| B28 | 0.37.0 development | 0.37.0 | native UI regression | Retract Button's minimum size protrudes outside bin | native theme inflated requested rectangle; bounded font/margins and reset size after overrides |
| B29 | 0.37.0 extension | 0.37.0 | Codex review | Premium negative heat modifier would be ignored in legacy check | legacy only added positive penalties; signed modifier now applies in both report paths, checked together |
