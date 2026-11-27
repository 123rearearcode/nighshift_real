# Nightshift — Bug register

Current ledger reconciliation: **0.54.0**, 21 November 2026 (targeted delivery-lifecycle follow-up).
The scheduled structural review was completed at 0.50.0 on 20 November; both entries are below.
Recorded fixes remain distinct from verification; historical fixes have not all been replayed.
Next structural review: **0.60.0**.

Targeted consolidation **0.57.7**, 25 November 2026: B59 imported from checker #77, critically
reproduced on main 0.57.6 / 842d0c2 and re-triaged High (blocked loop). It remains Open; this is
not a structural review or a fix. Full current-state evidence: [REVIEW_CONSOLIDATION.md](REVIEW_CONSOLIDATION.md).

## Filing and verification rules

- Add a bug immediately when found, including failures in CI and cross-review. Allocate the next
  unused B-id after checking main and open PRs; never reuse an id or silently renumber a merged record.
- Keep exactly one row in the index and one B-id detail section. Long reproductions belong in details.
- Status: **Open -> Investigating -> Fixed -> Verified**. Reopen a recurrence on the original id when
  it is the same defect; use a new linked id when the trigger/root cause is genuinely different.
- Fixed means a correction is recorded in a version; Verified requires named Automated, Graphical or
  User evidence and a reproducible test/fixture. Automated verification does not imply user acceptance.
- Severity describes impact: Critical = irrecoverable save/ownership loss; High = crash, blocked loop,
  duplication or incorrect major outcome; Medium = recoverable wrong behaviour; Low = minor presentation.
  Historical severity is retrospective triage, not a claim the issue is still present.
- Record exact build/commit, reproduction, expected/actual result, root cause, fix PR and regression
  evidence where available. Explicitly say Unknown/Not linked when history lacks that evidence.
- Diagnosis must expose known observations, measurements and visible damage, never hidden faults.
  A state needing a surface does not authorize a new fault-revealing label (D150).
- Run `python3 -I tools/check_bug_register.py` and `python3 -B tools/test_bug_register.py` after changes.
  At every tenth minor version, reconcile current root-cause status, add a review and advance the marker.
  Since 21 November 2026 the scheduled Code checker runs this review, not the integrating AI (docs/CODE_CHECKER.md).
- Known design limitations below are not silently classified as fixed bugs; investigate/reproduce first.

## Bug index

| ID | Status | Severity | Area | Summary | Fixed in | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| B1 | Fixed | Medium | Bench | Idle paste bench kept an active mounting session | 0.19.7 | Historical fix report; see details |
| B2 | Fixed | High | Physics | Hose end detached from the vacuum; vacuum stayed behind | 0.22.0 | Historical fix report; see details |
| B3 | Fixed | High | Physics | Crowded tools "disappear" (teleport across the obstruction) | 0.22.1 | Historical fix report; see details |
| B4 | Fixed | Medium | Rules | Final check demanded full cleaning the design no longer wanted | 0.23.0 | Historical fix report; see details |
| B5 | Fixed | Medium | UI | Customer dossier text overflowed its card and the footer | 0.28.0 | Historical fix report; see details |
| B6 | Fixed | Medium | Customers | Trust never moved for scores 61–79 | 0.28.0 | Historical fix report; see details |
| B7 | Fixed | High | Save | Hand-edited/damaged save crashed the shop (invalid cast) | 0.28.0 | Historical fix report; see details |
| B8 | Fixed | High | Save | History normaliser crashed on visit records missing keys | 0.28.0 | Historical fix report; see details |
| B9 | Fixed | High | Salvage | Held salvage find bulldozed other finds out of the dumpster | 0.28.0 | Historical fix report; see details |
| B10 | Fixed | High | PC model | **Loop-blocker:** GPU replaced "at the hardware bench" but the final check still failed | 0.32.0 | Historical fix report; see details |
| B11 | Fixed | High | PC model | Coolers unmountable at the hardware bench ("needs a mount"); no CPU exists | 0.32.0 | Historical fix report; see details |
| B12 | Fixed | Medium | Feedback | Broken GPU came as a surprise at the final check | 0.32.0 | Historical fix report; see details |
| B13 | Fixed | Medium | UI | Main-menu status text crossed the card border | 0.32.0 | Historical fix report; see details |
| B14 | Fixed | High | Salvage | Releasing a find overlapping the rim barrier could fling it | 0.32.0 | Historical fix report; see details |
| B15 | Fixed | High | Salvage | Cargo re-entry at a fixed point could spawn inside a staged find | 0.32.0 | Historical fix report; see details |
| B16 | Fixed | High | UI lifecycle | Selecting new rack furniture crashes with locked-object/free errors after sort/save/add | 0.33.0 (PR #40 merged) | Historical fix report; see details |
| B17 | Fixed | Medium | Inventory | Rack would omit the new starter CPU after combining branches | 0.32.0 | Historical fix report; see details |
| B18 | Fixed | Medium | Diagnosis | The night workshop diagnosis said only "Damaged: gpu. Replace these parts." - the B12 dead end again, … | 0.32.0 | Historical fix report; see details |
| B19 | Fixed | Medium | UI | Night-workshop ticket grows over diagnosis report when parts are broken | 0.36.0 | Historical fix report; see details |
| B20 | Fixed | Medium | UI | Add-furniture choices overlap; only last choice is usable | 0.33.0 (PR #40 merged) | Historical fix report; see details |
| B21 | Fixed | Medium | Hose | Spool moves vacuum back but full hose immediately lies on the desk again | 0.34.0 | Historical fix report; see details |
| B22 | Fixed | Medium | Input | Hotkey selection can leave two tool buttons highlighted | 0.34.0 | Historical fix report; see details |
| B23 | Fixed | Low | Tools | Cloth reacts outside its intended edge | 0.35.0 | Historical fix report; see details |
| B24 | Fixed | High | Power | Fresh PCs spin fans immediately; legacy final check can pay while off | 0.35.0 | Historical fix report; see details |
| B25 | Fixed | Low | Navigation | Activities appears in different positions or is missing on night work screens | 0.36.0 | Historical fix report; see details |
| B26 | Fixed | Low | Thermal | Mount cooler remains in side panel even after a locked mount | 0.37.0 | Historical fix report; see details |
| B27 | Fixed | Low | UI | Obsolete cloth/syringe toggle duplicates physical tool pickup | 0.37.0 | Historical fix report; see details |
| B28 | Fixed | Low | UI | Retract Button's minimum size protrudes outside bin | 0.37.0 | Historical fix report; see details |
| B29 | Fixed | Medium | Thermal | Premium negative heat modifier would be ignored in legacy check | 0.37.0 | Historical fix report; see details |
| B30 | Fixed | Medium | Save | Missing navigation preference version could fail future-format guard | 0.42.0 | Historical fix report; see details |
| B31 | Fixed | High | Save | Leaving room after failed layout save can lose new layout | 0.42.0 | Historical fix report; see details |
| B32 | Fixed | High | Navigation | Changing screen mid-test discards pending measurement | 0.42.0 | Historical fix report; see details |
| B33 | Fixed | High | Integration | Repair bench built no buttons after the split; scenes broke | 0.41.2 | Historical fix report; see details |
| B34 | Fixed | High | Save | Ticket flags crashed on jobs without a stored ticket | 0.43.0 | Historical fix report; see details |
| B35 | Fixed | Medium | Release | Two branches both released as 0.42.0 | 0.41.2 | Historical fix report; see details |
| B36 | Fixed | High | Integration | Monitor screen failed to load (parse error), night workshop suite hung | 0.44.0 | Historical fix report; see details |
| B37 | Fixed | Medium | Input | Cannot do the cooler screws while holding Space | 0.44.1 | Historical fix report; see details |
| B38 | Fixed | Low | Thermal | Cooler and screws disappear after clicking the lever | 0.44.1 | Historical fix report; see details |
| B39 | Fixed | Low | Feedback | Wiping after the lever gives no feedback | 0.44.1 | Historical fix report; see details |
| B40 | Fixed | Low | Layout | New PSU connector reached past the compact board's edge in one display size | 0.46.0 | Historical fix report; see details |
| B41 | Fixed | High | Inventory | Rearrange drawer pulled a shop test part out of its slot | 0.46.2 | Historical fix report; see details |
| B42 | Verified | High | Custody | Collection loses shop-fitted CPU/RAM/storage/PSU/second GPU from the recorded PC | 0.46.3 | Automated: hardware lifecycle regressions |
| B43 | Verified | High | Condition | A damaged test GPU/cooler returns as working stock and damages the customer's healthy original | 0.46.3 | Automated: hardware lifecycle regressions |
| B44 | Verified | High | Measurements | Hardware changes leave old measurements marked current | 0.46.3 | Automated: hardware lifecycle regressions |
| B45 | Verified | Medium | Inventory | Owned starter RAM/CPU are rejected as test parts | 0.46.3 | Automated: hardware lifecycle regressions |
| B46 | Verified | Medium | Input | A fitted shop CPU can be removed through the cooler | 0.46.3 | Automated: hardware lifecycle regressions |
| B47 | Verified | High | Migration | Handing over the starter CPU recreates a free one on reload | 0.46.3 | Automated: hardware lifecycle regressions |
| B48 | Verified | High | Save | A bought GPU/cooler fitted in the first slot makes the night manifest invalid after a reload; PC switching locks | 0.48.0 | Automated: generated-tickets B48 regression |
| B49 | Verified | Low | Layout | GPU bracket screws drawn on the second PCIe slot instead of the card's rear bracket | 0.48.1 | Automated: bracket screw geometry regression |
| B51 | Verified | Medium | Save | Stock records changed shape on reload (an empty defect key), so a menu path looked as if it altered the stock | 0.50.0 | Automated: menu navigation stock-equality regression |
| B50 | Verified | Medium | Anti-virus input | Review prototype SEND did not complete a mainframe override; native port must support actual click and Enter | 0.49.0 | Automated: native SEND/Enter and uppercase regression |
| B52 | Verified | Low | Test harness | The Rooms suite clicked the till while the ticket window it had just opened was still in the tree, so the open dialog took the click | 0.53.0 | Automated: Rooms suite (CI run 44842432173) |
| B53 | Verified | High | Component lifecycle | Collection consumes individual shop records and heals their delivered parts by keeping only model names | 0.54.0 | Automated: delivered-parts full-journey regressions |
| B54 | Verified | Medium | Test harness | The Rooms suite preloaded a view script, which then failed to compile (no autoloads yet); the scene later loaded without its script, the test errored mid-coroutine and CI hung for 30+ minutes | 0.55.0 | Automated: Rooms suite under the suite timeout (CI run 44857271062) |
| B55 | Verified | Medium | Input | Pausing (F10) with the magnifying glass over the part leaves the mouse cursor hidden for the whole pause menu | 0.58.7 | Automated: Testing bay suite (pause with the glass over the part), GitHub Actions run 46062635008 |
| B56 | Verified | Low | Storage | The stock room still draws each item kept under the counter, as a degenerate rectangle at the room's origin | 0.58.7 | Automated: Storage suite (`room_drawn_items`), GitHub Actions run 46062635008 |
| B57 | Verified | Low | Performance | When the shop is low on cash, each build-request arrival blocks the morning step for about 165 ms (up to about 317 ms): the cheapest-build search runs twice per attempt for all 12 attempts | 0.58.7 | Automated: Build requests suite (24 low-cash draws identical with and without the cache; searches cut), GitHub Actions run 46062635008 |
| B58 | Verified | Low | Test harness | Night-workshop fixture bypassed new opening intake, then assumed a PC switch and bench return had succeeded | 0.57.0 | Automated: intake-aware Night workshop 57 checks, First customer 32 |
| B59 | Verified | High | Save / Navigation | Invalid ticket manifest during pending opening intake blocks continuation; a wrong-run primary can hide a valid backup | 0.58.2 | Automated: Save safety suite, GitHub Actions run 46033946684 |
| B60 | Verified | Low | Test harness | The new storage pull-up checks looked at the drawer a fixed 30 frames after hovering or leaving; headless frames are faster than the 0.22 s slide, so the drawer was still moving | 0.57.8 | Automated: Rooms and Counter art suites, GitHub Actions run 45703005341 |
| B61 | Verified | Low | Diagnosis / Presentation | In the testing bay the magnifying glass shows only the healthy inspection picture, so a clue the lens has already revealed disappears inside the glass when you look at it again | 0.58.1 | Automated: Testing bay suite, GitHub Actions run 46021841002 |
| B62 | Verified | Medium | Save | While fixing B59, the new manifest check also skipped a ticket book written by a newer game version, read the older backup instead and would have let the next save overwrite the newer one | 0.58.2 | Automated: Night workshop suite, GitHub Actions run 46033946684 |
| B63 | Verified | High | Save recovery | PR #88 retains the previous run's later mornings, prunes a new game's morning-1 backup and can restore the old playthrough | 0.58.2 | Automated: Save safety suite, GitHub Actions run 46042764485 |
| B64 | Verified | Low | Help | Pause still directs the player to the retired Activities screen | 0.58.0 | Graphical: F10 during adware cleanup; docs/ANTIVIRUS_0580_VALIDATION.md |
| B65 | Verified | Low | Test harness | Initial effects-setting fixture injected root-viewport clicks into a separate dialog window, then tried to cast its unchanged malformed setting to bool | 0.58.0 | Automated: Antivirus 67 checks; dialog control signals and guarded value comparison |
| B66 | Verified | Low | Antivirus feedback | Per-PC adware names still received a hardcoded FreeCursors reaction after stopping | 0.58.0 | Automated: alias-specific tools/test_antivirus.gd regression (68 checks); graphical mismatch reproduced |

| B67 | Verified | Low | Antivirus presentation | The typing panel lets scan clues show through behind the word input | 0.58.0 | Graphical: corrected opaque prompt; docs/ANTIVIRUS_0580_VALIDATION.md |
| B68 | Verified | Low | Antivirus feedback | A stopped miner keeps changing its alias while its helper still runs | 0.58.0 | Automated: tools/test_antivirus.gd, final alias retained after clock advance |
| B69 | Verified | Medium | Bench presentation | Using the brush instantly covered the whole open PC in a dust texture that could not be moved or vacuumed | 0.58.4 | Automated: Dust flow suite, GitHub Actions run 46053534084 |
| B70 | Verified | Low | Bench presentation | With the pick in hand, a stray dash showed just above the pick's bend | 0.58.4 | Automated: Bench feedback suite, GitHub Actions run 46053534084 |
| B71 | Verified | Medium | Collection presentation | The collection slip called every replaced original kept by the shop "working", even a broken one, although the shop has not tested it | 0.58.7 | Automated: Morning report suite, GitHub Actions run 46062635008 |
| B72 | Verified | Low | Test harness | The new B56 storage check declared a loop variable `uid` in a function that already has `var uid`, so the Storage suite failed to parse | 0.58.7 | Automated: Storage suite, GitHub Actions run 46062635008 |
| B73 | Verified | Low | Bench presentation | The vacuum on/off switch stayed on screen while mounting the cooler (the thermal paste stage) | 0.58.9 | Automated: Audio and vacuum suite, GitHub Actions run 46071704212 |

| B74 | Verified | Low | Counter loading | Every return reloads the counter’s large texture set after scene disposal, causing a visible pause | 0.58.10 | Automated: Counter art suite (40 checks), integrated 41 required suites / 2,648 checks, local Godot 4.7.2; targeted samples in COUNTER_LOADING.md |

## Known limitations and design debt (not closed bugs)

| ID | Status | Priority | Limitation | Next action |
| --- | --- | --- | --- | --- |
| L1 | Investigating | High | Legacy customer originals remain slot/order-derived; delivered shop parts now retain individual records through handover and reuse | Continue the staged migration in PART_LIFECYCLE.md; do not claim all originals or bench aliases have migrated |
| L2 | Investigating | High | Orphan fitted_in custody marks have no recovery UI | Establish a safe reproduction/recovery policy; never clear an unknown mark just to make stock available |
| L3 | Fixed | Medium | Delivered-part condition loss is fixed for future handovers in 0.54.0 (B53); already-lost old condition cannot be reconstructed | Preserve physical records/receipts and the delivered-parts suite; no invented recovery of old lost data |
| L4 | Open | Low | Salvage outings still use the demo clock rather than canonical night minutes | Design the visit/travel charging contract independently of storage UI |
| L5 | Open | Low | A full hardware drawer can hide overflow stock although the testing bay lists all parts | Address drawer overflow visibility independently of salvage-clock integration; split from former combined L4 |

L1/L2 were already listed in HANDOFF. This PR tests supported shop-part journeys; it does not claim
to have migrated all customer-part identity or solved orphan recovery. Neither is an excuse to bypass
ownership safeguards or to drop parts during save normalization.

## Current root causes

### RC-1 — Multiple PC representations: original disconnected-bench defect CLOSED

The old sandbox/customer-PC disconnect was addressed by the shared ticket PC. B10/B11 are historical;
B17/B18 demonstrate why new screens must use canonical projections. Do not rebuild a second PC model.
The later identity/custody issue is tracked separately as RC-5, not by reopening this old integration.

### RC-2 — UI containment and player-visible state: continuing prevention rule

B5/B13/B19 require bounded long content and layout tests. B12/B18 require durable feedback for what the
player knows. Under D150, display evidence and known state, never an automatic hidden-part diagnosis.
Use actual input/signal tests for buttons and realistic long text, not only direct callback invocation.

### RC-3 — Unsafe optional/external data reads: continuing prevention rule

B7/B8/B30/B34 repeat save/default mistakes. Read each optional value once into a local, validate that
value's type/range, then use it; do not validate get(key, fallback) and subsequently index a missing
key. Validate nested malformed records and missing keys as well as top-level containers. Preserve
unknown/future data according to existing protected-save contracts. No new validation framework needed.

### RC-4 — Event-source lifetime: fixed defect, retained regression requirement

B16's synchronous deletion of a button during its own signal is fixed by stable controls/deferred
structural changes. The room replacement was merged in PR #40; the old local/no-push note is historical.
Retain native sort/add/select/drop/exit tests; call-only tests missed this failure before.

### RC-5 — Component identity, custody and incomplete journeys: ACTIVE structural follow-up

B41–B47 show that successful fitting is not enough: removal, damage, collection and reload must agree.
A model name or slot is not a physical identity. See PART_LIFECYCLE.md for the accepted staged direction,
current coverage, invariants, migration boundaries and the parts still awaiting implementation.
0.50.0 progress (shop stock only): every stock record now keeps actual condition (+ defect) apart from
the shop's knowledge (label, notes, tests done) — invariant 7 for shop parts. A fitted test part behaves
as its record says through a derived job copy (`shop_condition`) that is rebuilt from the records on load
and PC switch, never trusted from the save. Customer parts are still slot-derived (L1); see L3.

### RC-6 — One rule, several hand-written copies: NEW prevention rule (0.50.0)

B48 (the night manifest validated replacement tiers with its own list while the loader used
`ServiceParts.option`), B51 (a record created in one shape and reloaded in another) and B49 (screw
positions assumed the row under the GPU was free, until a later slot used it) are one pattern: a rule
copied by hand drifts from its source. Prevention: validate with the same function that defines the
shape (`ServiceParts.option`, the record sanitizers), make created and reloaded records identical, and
test positions against the real connector rectangles. A deliberate derived copy (such as
`shop_condition`) must name its authority, be rebuilt from it at load/switch, and have a test that
tampers with the copy.

## Reviews (newest first)

### 0.54.0 — targeted delivery-lifecycle follow-up, 21 November 2026

User authorized the review recommendations. Reproduced L3 on the unchanged 0.53.0 parent: a degraded
GPU lost both its fault and its physical uid at settlement (two failing regression checks). Filed B53,
fixed the handover path, and added the complete delivered-parts journey. Physical records retain uid,
model, condition/defect and knowledge; ownership changes once. Removal/refitting, identical RAM
reordering, inactive-PC reload, repeat collection, return to stock and immutable comeback receipts
preserve those facts. Rules derive behaviour from these records, not the cleared shop-condition cache.

This advances RC-5/L1 for the shop-to-customer path only: legacy originals and bench presentation
aliases have not all migrated; orphan custody L2 remains untouched and locked. Split L4 (clock) from
L5 (drawer overflow), with independent next actions. B1–B41 remain Fixed; this focused regression does
not supply missing historical per-bug evidence or imply graphical/user acceptance. The scheduled
0.50.0 review was already completed; the next scheduled structural review stays 0.60.0.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

### 0.50.0 — scheduled structural review, 20 November 2026

Scope: B48–B51 and the 0.48.0–0.50.0 changes (generated tickets, motherboards and saved tools, the Task
Manajer, the testing bay). Findings: (1) RC-6 is new — three of the four new bugs were hand-copied rules
drifting from their source; (2) RC-5 advanced for shop stock (actual vs known condition; fitted test
parts derive from the stock record) but L1/L2 stay Investigating, and L3 (condition lost at delivery) is
recorded instead of being silently accepted; (3) RC-2 held: B49 and B50 were caught and are now covered by
geometry and real-input tests; the bay's tests click through the viewport and check that no hidden
condition reaches visible text; (4) RC-3 held: the new saved shapes (`people`, `vacuum_state`, part
knowledge) have sanitizers with malformed-data checks. Actions taken: RC-6 rule; L3/L4 recorded; B51
filed; the bay journey is covered end to end (arrival, inspection, tests, mark, scrap, fitting, return,
settlement, reload). Next scheduled structural review: 0.60.0.

Signed: Claude (Opus 5.5, model id claude-opus-5-5), Claude Code cloud session, 20 November 2026.

### 0.47.1 — focused ledger and lifecycle review, 18 November 2026

Reconciled 47 historical records into one index with details. The old next-review marker, stale
RC-1/RC-4 status and fault-revealing RC-2 wording are corrected. Historical reports remain below,
explicitly superseded by the current status above. B42–B47 have executable automated evidence;
B1–B41 remain Fixed until their individual evidence is linked/reverified. No human acceptance is implied.

Recent pattern: part fit -> return -> damage -> collect -> reload spans several representations.
Added cross-PC lifecycle scenarios rather than another forward-only fitting test. Shared hot runtime
files are active in Claude's PR #59, so this PR does not race a canonical-registry rewrite. The staged
identity/custody work remains explicit in L1/L2 and the handoff instead of being reported as complete.
Next scheduled structural checkpoint: 0.50.0. Do not let generated-ticket work erase this gate.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest.

## Historical reviews and root-cause notes (superseded snapshots)

These are preserved as provenance. Their old versions, local-only notes, proposed next steps and
then-current design wording do not override the current status, D150 or the latest user instruction.

> ## Root causes (structural)
>
> ### RC-1: more than one representation of "the customer's PC" (B10, B11)
> The job (`game_state.gd`) is the real customer PC. The repair bench reads/writes it. The
> hardware bench is a SANDBOX over `player_inventory` + a demo board — fitting a GPU there never
> touched the job, and nothing told the player. Worse, the sandbox's own loop was incoherent
> (coolers had no slot, no CPU existed), so it looked broken rather than separate.
> 0.29.0 answer: one source of truth surfaced everywhere — `GameState.part_state()` is the only
> way part states are read; ticket, final check and benches all show it with the exact repair
> path; the sandbox says plainly what it is and got a coherent CPU → mount → cooler loop.
> Still open structurally: actually CONNECTING the customer's PC to the hardware bench (D79 note)
> so there is only ONE parts model. That is the next structural step, not patched here.
>
> ### RC-2: fixed-rect UI with growing content, and state without a surface (B5, B12, B13)
> Labels and cards were sized by hand and content grew past them; important state (a broken part)
> lived in the model with no persistent surface. Pattern answer: every long text sits in a bounded
> scrolling container with a containment regression check; every player-relevant state must have a
> place on screen that shows it binary and names the next action.
>
> ### RC-3: loaded and external data trusted as-shaped (B7, B8)
> Save data (and any future imported data) must be rebuilt field by field with defaults and
> clamps, never cast in the UI. B8 showed even the VALIDATOR can make the same mistake — tests
> must feed damaged data on purpose.
>
> ### RC-4: destroying an event source while its signal is active (B16)
> Original local rack/night patches kept selection controls alive and deferred structural deletion.
> Local 0.33.0 replaces selectors entirely with a drawn room and keeps toolbar/popup nodes stable.
> A native Button-signal regression reproduces the old failure; direct method calls had missed it.
> The older patches were not included in the remote integration. The 0.33.0 room replacement remains
> local under the no-push instruction. Proposed structural
> answer: UI lifecycle tests should exercise signal dispatch, with stable controls for state-only updates.
>
> ## Reviews (newest first)
>
> ### 0.40.0 - structural checkpoint (short, by Claude)
> Read at the checkpoint, not a full audit. RC-1 (two PC models) is structurally closed from 0.39.0: the
> hardware bench and the repair bench both read the ticket's job record (`customer_pc.gd`). New hidden-fault
> sources (install faults, infection, overclock) all follow one pattern: a pure rule with heat / annoyance /
> complaint tables, summed by `pickup_score.gd` and composed in `GameState.pickup_faults`. Risks I see:
> (1) `bench_view.gd` is now about 1500 lines: the cooler-install ritual, tool hand-state and mounting all
> live in it; splitting the install ritual into its own helper is the next structural step before more rituals
> (RAM, CPU) are added. **Done in 0.41.2** (five helpers; the bench keeps state and wrappers). (2) The pickup-fault composition is a growing list in `game_state.gd`; a fourth source
> should move it into one rule script. (3) Nothing from 0.38-0.40 has been playtested by the user. No new
> bug-register entries; B-ids unchanged.
>
> ### 0.32.0 - integration review (the 0.30.0 checkpoint, completed)
>
> Claude (Sonnet 5.5, model id claude-sonnet-5-5), 15 November 2026, after merging PRs #35, #36 and #38.
> Patterns confirmed from Codex's preparation: (1) RC-1 recurred immediately: two independently
> built surfaces (shop ticket, night diagnosis) each described part state their own way, and a CPU
> stock record I added broke a third (the rack's per-kind dispatch). Both fixes are now
> STRUCTURAL: one pure rule (`part_states.gd`) and one canonical component projection
> (`inventory_components()`); new surfaces must read them, never re-derive. (2) Parallel branches
> collided on version numbers and decision ids (three branches each claimed 0.29-0.31; D109-D113
> used twice). Proposed process fix, for the user: the integrating AI assigns the next version and
> decision-id block BEFORE a parallel branch starts, and branches record them in their PR body.
> (3) The old shop scene is now partly legacy (the night workshop replaced it as the player-facing
> flow) but still carries the legacy payout path and tests; retiring it deliberately is a later,
> explicit step. (4) RC-4 (UI lifecycle tests that exercise signal dispatch) accepted as proposed by
> Codex; a shared helper is the next structural test work. Next structural checkpoint: 0.40.0.
>
> ### 0.31.0 branch — preparation for the 0.30.0 structural checkpoint
>
> Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
> Patterns: RC-1 still needs one canonical customer-PC/part model; B17 shows derived type lists can
> drift as main gains CPU stock. Pending rack adapter must consume the canonical component projection
> before integration. Inventory and inactive-ticket bridges
> must remain explicit until integrated. RC-2 needs bounded labels plus persistent actionable state;
> new salvage labels use short cargo names and detailed hover text. RC-3 needs per-field save validation
> and identity checks; new random visits must never duplicate packed cargo. RC-4 adds event-source
> lifetime to the UI test gap. Proposed next structural work (not implemented): consolidate a reusable
> signal-driven UI test helper and finish canonical PC/state seams before expanding duplicate models.
> This review is prepared in a PR, not a claim that pending branches were merged. Next regular
> structural checkpoint after integration: 0.40.0.
>
>
>
> ### 0.36.0 follow-up evidence for B16
> The uploaded Screen Recording 2026-11-15 020515(1).mp4 visibly identifies v0.32.0 at 1s and
> shows the old numbered furniture sidebar at 6s. Main includes its replacement from merged PR #40
> (v0.33.0); current PR has no storage .free() path or per-furniture Button list. Repeat native
> sort/save/add/multiple-title selections and assert persistent control identities in the new build.
> This identifies a build mismatch in this evidence, not a claim that unseen current-build failures
> are impossible. Fresh-folder/version instructions are in README. Signed Codex (GPT 6.1 Sol,
> model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
>

## Bug details

### B1 — Idle paste bench kept an active mounting session

- Found: 0.19.x
- Reported by: Codex review
- Fixed in: 0.19.7
- Root cause: stage state not cleared on switch
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B2 — Hose end detached from the vacuum; vacuum stayed behind

- Found: 0.21.0
- Reported by: user video
- Fixed in: 0.22.0
- Root cause: two owners of one position (hose sim vs tool rig), no bridge
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B3 — Crowded tools "disappear" (teleport across the obstruction)

- Found: 0.21.0
- Reported by: user video
- Fixed in: 0.22.1
- Root cause: collision resolver pushed to the far side; no table clamp
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B4 — Final check demanded full cleaning the design no longer wanted

- Found: 0.22.x
- Reported by: user playtest
- Fixed in: 0.23.0
- Root cause: rule lived in code, not in the agreed design (D87 settled it)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B5 — Customer dossier text overflowed its card and the footer

- Found: 0.25.0
- Reported by: Codex cross-review + user screenshot
- Fixed in: 0.28.0
- Root cause: plain Labels grow to content; fixed rects do not bound them (see RC-2)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B6 — Trust never moved for scores 61–79

- Found: 0.25.0
- Reported by: Codex cross-review
- Fixed in: 0.28.0
- Root cause: integer division swallowed small deltas
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B7 — Hand-edited/damaged save crashed the shop (invalid cast)

- Found: 0.25.0
- Reported by: Codex cross-review
- Fixed in: 0.28.0
- Root cause: loaded data trusted without per-field validation (see RC-3)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B8 — History normaliser crashed on visit records missing keys

- Found: 0.28.0
- Reported by: CI (new test)
- Fixed in: 0.28.0
- Root cause: `get()` default passed the type test, then direct `[]` access hit the missing key
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B9 — Held salvage find bulldozed other finds out of the dumpster

- Found: 0.26/0.27
- Reported by: user playtest
- Fixed in: 0.28.0
- Root cause: zone decided by bare x-position; no ownership gate at the rim (D108)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B10 — **Loop-blocker:** GPU replaced "at the hardware bench" but the final check still failed

- Found: 0.28.0
- Reported by: user playtest
- Fixed in: 0.32.0
- Root cause: two disconnected PCs: the sandbox never writes job state (see RC-1)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B11 — Coolers unmountable at the hardware bench ("needs a mount"); no CPU exists

- Found: 0.28.0
- Reported by: user playtest
- Fixed in: 0.32.0
- Root cause: sandbox board had no COOLER_MOUNT slot and stock had no CPU (see RC-1)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B12 — Broken GPU came as a surprise at the final check

- Found: 0.28.0
- Reported by: user playtest
- Fixed in: 0.32.0
- Root cause: damage feedback was a 3 s status line; ticket/check never showed part states (see RC-2)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B13 — Main-menu status text crossed the card border

- Found: 0.28.0
- Reported by: user playtest
- Fixed in: 0.32.0
- Root cause: buttons were added without growing the card; AND the label was sized before autowrap was set, so Godot clamped it to its one-line width (600 px) and it never shrank back (see RC-2)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B14 — Releasing a find overlapping the rim barrier could fling it

- Found: 0.27.0
- Reported by: Codex review of the D108 plan
- Fixed in: 0.32.0
- Root cause: collider re-enabled inside a body; fixed with a grace exemption until clear
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B15 — Cargo re-entry at a fixed point could spawn inside a staged find

- Found: 0.27.0
- Reported by: Codex cross-review
- Fixed in: 0.32.0
- Root cause: fixed spawn coordinates; fixed with a free-space probe
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B16 — Selecting new rack furniture crashes with locked-object/free errors after sort/save/add

- Found: rack/night PRs #35/#36; still present in main 0.32.0
- Reported by: user screenshots + Codex signal regression
- Fixed in: 0.33.0 (PR #40 merged)
- Root cause: Sidebar rebuilt and synchronously freed the Button emitting its own pressed signal; method-only tests missed lifecycle (RC-4)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B17 — Rack would omit the new starter CPU after combining branches

- Found: pending rack/night integration with main 0.29.0
- Reported by: Codex code review
- Fixed in: 0.32.0
- Root cause: Rack adapter dispatches RAM explicitly, everything else through GPU/cooler ServiceParts; main now supplies a cpu record (RC-1); fixed in 0.32.0: the rack reads the canonical `GameState.inventory_components()` projection (test_storage checks the CPU appears)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B18 — The night workshop diagnosis said only "Damaged: gpu. Replace these parts." - the B12 dead end again, on the screen that replaced the shop

- Found: 0.30.0
- Reported by: Claude integration review
- Fixed in: 0.32.0
- Root cause: a second surface wrote its own aggregate notes instead of reading the shared part rule (RC-1/RC-2); fixed with the pure `part_states.gd` rule used by every surface
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B19 — Night-workshop ticket grows over diagnosis report when parts are broken

- Found: 0.32.0
- Reported by: Codex review of PR #39
- Fixed in: 0.36.0
- Root cause: Parts summary appended to plain Label; measured y=166..511 against report y=425 (RC-2); bounded ticket ScrollContainer added/tested in 0.36.0
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B20 — Add-furniture choices overlap; only last choice is usable

- Found: storage PR #35; still present in 0.32.0
- Reported by: user recording + Codex GUI regression
- Fixed in: 0.33.0 (PR #40 merged)
- Root cause: PopupPanel Container repositions direct Button children despite hand-set positions; replaced by Margin/VBox layout
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B21 — Spool moves vacuum back but full hose immediately lies on the desk again

- Found: before 0.34.0
- Reported by: user playtest
- Fixed in: 0.34.0
- Root cause: One length represented both deployed hose and capacity; reset re-created a full-length chain. Separate capacity from deployed length and pay out only under pulling
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B22 — Hotkey selection can leave two tool buttons highlighted

- Found: tool selection before 0.34.0; exposed by brush-first test
- Reported by: regression test
- Fixed in: 0.34.0
- Root cause: set_pressed_no_signal on one Button did not clear its group peer; explicitly synchronize every tool highlight after an accepted switch
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B23 — Cloth reacts outside its intended edge

- Found: 0.34.0
- Reported by: user playtest
- Fixed in: 0.35.0
- Root cause: generic whole-tool pickup rectangle ignored fabric silhouette; wipe reach reduced one world pixel
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B24 — Fresh PCs spin fans immediately; legacy final check can pay while off

- Found: 0.34.0
- Reported by: user request + Codex review
- Fixed in: 0.35.0
- Root cause: default power true and two boot-rule implementations disagree; shared pure boot rule now gates both paths
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B25 — Activities appears in different positions or is missing on night work screens

- Found: 0.35.0
- Reported by: user playtest
- Fixed in: 0.36.0
- Root cause: per-screen navigation implementations diverged; shared top-right helper and native exit tests
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B26 — Mount cooler remains in side panel even after a locked mount

- Found: 0.36.0
- Reported by: user screenshot
- Fixed in: 0.37.0
- Root cause: visibility gated only by stage/active flag; shared readiness includes mass, result, completion and stage
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B27 — Obsolete cloth/syringe toggle duplicates physical tool pickup

- Found: 0.36.0
- Reported by: user screenshot
- Fixed in: 0.37.0
- Root cause: old toggle widget/state wiring retained; removed widget and updated fixtures
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B28 — Retract Button's minimum size protrudes outside bin

- Found: 0.37.0 development
- Reported by: native UI regression
- Fixed in: 0.37.0
- Root cause: native theme inflated requested rectangle; bounded font/margins and reset size after overrides
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B29 — Premium negative heat modifier would be ignored in legacy check

- Found: 0.37.0 extension
- Reported by: Codex review
- Fixed in: 0.37.0
- Root cause: legacy only added positive penalties; signed modifier now applies in both report paths, checked together
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B30 — Missing navigation preference version could fail future-format guard

- Found: 0.42.0 development
- Reported by: Codex review
- Fixed in: 0.42.0
- Root cause: guard used get() then indexed absent key; same optional-key rule as RC-3, now get() consistently and regression-covered
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B31 — Leaving room after failed layout save can lose new layout

- Found: storage before 0.42.0
- Reported by: UX implementation review
- Fixed in: 0.42.0
- Root cause: main checkpoint did not guard separate layout writer; visible Retry and route refusal now protect it
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B32 — Changing screen mid-test discards pending measurement

- Found: monitor 0.41.0
- Reported by: UX implementation review
- Fixed in: 0.42.0
- Root cause: navigation did not check busy state; wait/cancel with existing power action before changing view
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B33 — Repair bench built no buttons after the split; scenes broke

- Found: 0.41.2 development
- Reported by: CI (run 43942436349)
- Fixed in: 0.41.2
- Root cause: helper assigned a plain Array to the bench's typed `Array[Button]` through an untyped handle; now filled in place with `assign()`
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B34 — Ticket flags crashed on jobs without a stored ticket

- Found: 0.43.0 development
- Reported by: CI (runs 43954390196, 43956781173)
- Fixed in: 0.43.0
- Root cause: sanitize used get() to test a key, then indexed the absent key (same pattern as B30, RC-3); now reads each value once with get()
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B35 — Two branches both released as 0.42.0

- Found: 0.41.2 release
- Reported by: Claude, at merge
- Fixed in: 0.41.2
- Root cause: open PRs were listed through the blocked GraphQL CLI and the failure was not retried over REST; release renumbered, and the integrating AI must list open PRs over REST before choosing a version
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B36 — Monitor screen failed to load (parse error), night workshop suite hung

- Found: 0.44.0 development
- Reported by: CI (run 43961321306)
- Fixed in: 0.44.0
- Root cause: Activities gained a `Clock` constant, but the monitor screen extends Activities and already declares `Clock`; parent constants now use names no subclass uses (`NightClock`, `TicketRule`)
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B37 — Cannot do the cooler screws while holding Space

- Found: 0.39.0
- Reported by: user playtest
- Fixed in: 0.44.1
- Root cause: screwdriver pick-up was gated on the press timer reaching zero (D131 "after the press"); now allowed during the press, mouse turns screws while Space presses
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B38 — Cooler and screws disappear after clicking the lever

- Found: 0.38.0
- Reported by: user playtest
- Fixed in: 0.44.1
- Root cause: screws were drawn only while mounting and the locked state showed only the paste inspection; locked cooler frame and screws now stay drawn
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B39 — Wiping after the lever gives no feedback

- Found: 0.38.0
- Reported by: user playtest
- Fixed in: 0.44.1
- Root cause: squeezed-out stats were frozen at the lever value and no step said "done"; live re-measure, "Clean" confirmation, guide and verdict
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B40 — New PSU connector reached past the compact board's edge in one display size

- Found: 0.46.0 development
- Reported by: CI (run 44148392689)
- Fixed in: 0.46.0
- Root cause: it touched the board's right edge exactly and float cell sizes put it a fraction outside; moved one cell in
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B41 — Rearrange drawer pulled a shop test part out of its slot

- Found: 0.46.2 development
- Reported by: CI (run 44199925403)
- Fixed in: 0.46.2
- Root cause: the drawer-only repack kept the customer's fitted parts but not shop parts fitted for a test; they are kept on their slots too
- Reproduction: Not preserved as a complete procedure in the old row; recover from the referenced playtest/CI/review before claiming an independent reproduction.
- Regression / evidence: Historical fix report retained above; bug-specific test/PR link and current-build verification not yet reconciled. Do not mark Verified solely from the fixed version.

### B42 — Collection loses shop-fitted CPU/RAM/storage/PSU/second GPU from the recorded PC

- Found: 0.46.2
- Reported by: Codex PR #57 review + Godot regression
- Fixed in: 0.46.3
- Root cause: settlement cleared temporary custody without writing the models into permanent parts; materialize physical contents before consuming stock
- Reproduction: See executable review regressions and cross-PC lifecycle scenario.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_hardware_parts.gd` (review_regressions), plus cross-PC journeys in `tools/test_part_lifecycle.gd`. No manual/user acceptance claimed.

### B43 — A damaged test GPU/cooler returns as working stock and damages the customer's healthy original

- Found: 0.46.2
- Reported by: Codex PR #57 review + Godot regression
- Fixed in: 0.46.3
- Root cause: return_replacement retained slot damage rather than component damage; preserve broken shop stock, clear test-part flags, then restore the original's own flags; retain broken stock on load
- Reproduction: See executable review regressions and cross-PC lifecycle scenario.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_hardware_parts.gd` (review_regressions), plus cross-PC journeys in `tools/test_part_lifecycle.gd`. No manual/user acceptance claimed.

### B44 — Hardware changes leave old measurements marked current

- Found: 0.45.0 hardware / 0.46.2 test parts
- Reported by: Codex PR #57 review + Godot regression
- Fixed in: 0.46.3
- Root cause: the signature omitted catalogue parts, shop_fitted and dead_slots; include hardware/configuration identity in result validity
- Reproduction: See executable review regressions and cross-PC lifecycle scenario.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_hardware_parts.gd` (review_regressions), plus cross-PC journeys in `tools/test_part_lifecycle.gd`. No manual/user acceptance claimed.

### B45 — Owned starter RAM/CPU are rejected as test parts

- Found: 0.46.2
- Reported by: Codex PR #57 review + Godot regression
- Fixed in: 0.46.3
- Root cause: state and bench required catalogue-format stock; resolve legacy stock models without replacing uid or ownership
- Reproduction: See executable review regressions and cross-PC lifecycle scenario.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_hardware_parts.gd` (review_regressions), plus cross-PC journeys in `tools/test_part_lifecycle.gd`. No manual/user acceptance claimed.

### B46 — A fitted shop CPU can be removed through the cooler

- Found: 0.46.3 development
- Reported by: Starter CPU regression
- Fixed in: 0.46.3
- Root cause: pickup guard only identified customer-prefixed CPUs; identify the physical kind of shop CPUs too
- Reproduction: See executable review regressions and cross-PC lifecycle scenario.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_hardware_parts.gd` (review_regressions), plus cross-PC journeys in `tools/test_part_lifecycle.gd`. No manual/user acceptance claimed.

### B47 — Handing over the starter CPU recreates a free one on reload

- Found: 0.46.3 development
- Reported by: Starter CPU collection/reload regression
- Fixed in: 0.46.3
- Root cause: legacy migration used absence of the uid as its only trigger; persist a one-time starter_cpu_seeded flag
- Reproduction: See executable review regressions and cross-PC lifecycle scenario.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_hardware_parts.gd` (review_regressions), plus cross-PC journeys in `tools/test_part_lifecycle.gd`. No manual/user acceptance claimed.

### B48 — A bought GPU/cooler fitted in the first slot makes the night manifest invalid after a reload

- Found: 0.48.0 development (defect present since 0.46.0, D149 bought catalogue parts)
- Reported by: Claude, code reading while building D153 option B (bought test parts), PR #59
- Fixed in: 0.48.0 (PR #59)
- Root cause: `NightSession._valid` accepted only the two old trial tiers ("similar", "budget") in `service_replacements`, while the save loader already accepted every ServiceParts option including "model:<id>"; an inactive PC holding a bought first-slot part failed validation when the manifest was re-read, so the session entered read-only protection. Fix: validate with `ServiceParts.option()` like the loader.
- Reproduction: Buy a catalogue GPU, take the customer's GPU out at the repair bench and fit the bought one as a test part (`service_replacements.gpu` becomes "model:<id>"); switch to another open PC; save and reload; `NightSession.ensure()` rejects the manifest and PC switching is locked.
- Expected / actual: switching stays available after reload / manifest rejected, read-only protection.
- Regression / evidence: Automated Godot 4.7.2 regression in `tools/test_generated_tickets.gd` (section "B48"), GitHub Actions on PR #59. Not reproduced on the pre-fix build in CI (found by reading code); no graphical or user verification claimed.

### B49 — GPU bracket screws drawn on the second PCIe slot instead of the card's rear bracket

- Found: 0.48.0 (present since the hardware-bench screws of 0.39/0.40; made visible by the second PCIe slot of 0.46.0)
- Reported by: User, 18 November 2026 ("the screws on the GPUs on the hardware board are at the wrong place")
- Fixed in: 0.48.1
- Root cause: `InstallFaults.gpu_screw_centers` placed both screws on the board row just below the GPU slot; since 0.46.0 that row is the second PCIe slot (`pcie_2`), so the screws sat on that slot or on a second card. Fix: both screws on the card's metal I/O bracket at the rear of the case (left end of the card, just outside the board), drawn on a bracket plate.
- Reproduction: Open the night hardware bench with the GPU fitted: the two screw circles lie inside the PCIe 2 connector rectangle (confirmed with a geometry render from the game's own layout numbers).
- Expected / actual: screws on the GPU bracket / screws on the second PCIe slot.
- Regression / evidence: Automated Godot 4.7.2 geometry checks for both case sizes in `tools/test_board_and_bench_state.gd` (screws outside the board, inside the bracket, off every connector; hit test). No graphical playtest or user acceptance claimed yet.

### B50 — Mainframe override confirmation failed in the review prototype

- Found: in-chat fast anti-virus review prototype, 19 November 2026 (not a shipped Godot feature)
- Reported by: user: "the send button doesnt actually work"; also requested visibly uppercase typing
- Fixed in: 0.49.0 native integration; the subsequent standard in-chat demo was accepted by the user
- Root cause: the original browser failure was not captured with an execution trace, so its exact cause remains unknown. The native implementation removes any browser/form dependency: stable SEND Button.pressed and LineEdit.text_submitted share a single explicit handler; text_changed uppercases input while preserving the caret. No controls are recreated during typing.
- Reproduction: start a miner cleanup, click End on its protected source, type the displayed word, click SEND; repeat in a fresh attempt with Enter. A wrong word must show an error and allow correction. Let time pass during partial input; characters and control identity must survive.
- Expected / actual: the correct word stops the process via either confirmation path / the user reported that SEND did nothing in the fast prototype.
- Regression / evidence: Automated Godot 4.7.2 viewport mouse and keyboard input in `tools/test_antivirus.gd` proves native SEND, Enter, immediate uppercase, wrong-word retry and stable input. This verifies the native port, not a reproduced root cause in the old browser prototype. User accepted the standard in-chat version; graphical Godot acceptance remains pending.

### B51 — Stock records changed shape on reload, so a menu path looked as if it altered the stock

- Found: 0.50.0 development, GitHub Actions (Menu navigation suite)
- Reported by: CI, failing check "menu paths do not charge, restock or finish repairs"
- Fixed in: 0.50.0 (before release)
- Root cause: the new stock-record loader always added an empty `defect` key, while freshly created records had none; after a reload the inventory compared unequal, as if a navigation had changed it (RC-6). Fix: a `defect` key only on degraded parts, in both creation and load.
- Reproduction: start a new game, take the menu path Title → Continue → workbench → room, compare `player_inventory` with the value before the path.
- Expected / actual: identical stock / stock unequal after the reload inside the path.
- Regression / evidence: Automated Godot 4.7.2 `tools/test_menu_navigation.gd` (unchanged check now passes) and the reload checks in `tools/test_testing_bay.gd`. No user verification claimed.

### B52 — The Rooms suite clicked through a ticket window that was still open

- Found: 0.53.0 development, GitHub Actions (Rooms suite, run 44842058308)
- Reported by: CI, failing check "the till shows the cash"
- Fixed in: 0.53.0 (before release)
- Root cause: the test opened a ticket window from the clipboard, called `queue_free()` on it and clicked the till in the same frame. An open dialog in the tree takes the next click, so the till never received it. A test-ordering defect, not a game bug: the till works when the window is closed.
- Reproduction: in `tools/test_rooms.gd`, open a ticket from the counter's clipboard, free the window with `queue_free()` only, then click the till at once.
- Expected / actual: the message shows the till's cash / the message is unchanged (the click went to the closing dialog).
- Regression / evidence: the test now hides the window and waits two frames before the next click. Automated Godot 4.7.2 `tools/test_rooms.gd`, CI run 44842432173 on `98a39db`: the check passes. No user verification claimed.


### B53 — Collection loses physical identity and heals delivered shop parts

- Found: 0.50.0 structural review L3; reproduced by Codex on unchanged 0.53.0 parent f61583c, 21 November 2026
- Reported by: Claude's L3 review finding; user authorized implementation after Codex's audit report
- Fixed in: 0.54.0, stacked after the Rooms PR #66
- Root cause: settle_custody copied catalogue model names, removed the stock records and cleared shop_condition. Only those deleted records held actual condition, defect, knowledge and uid, so dead/degraded fitted stock silently became ordinary permanent components. The same loss affected build requests.
- Reproduction: fit an untested degraded GPU with artifacts; confirm load instability at minute 12; settle custody; the original build then had no artifacts/instability and no surviving physical uid. Repeat with dead RAM/CPU/PSU/cooler/storage to observe wrong post-delivery contribution or boot symptoms.
- Expected / actual: ownership changes while the individual part and its condition persist / physical identity and condition were lost at handover.
- Regression / evidence: Automated Godot 4.7.2 `tools/test_delivered_parts.gd`: complete collection/receipt/comeback/reload path; identical RAM with different health reordered/removed/refitted; delivered GPU temporarily swapped, restored and later returned to stock with its same uid/defect; every supported kind in degraded and broken states. The four-check probe on the unchanged parent failed its two post-handover checks. No graphical acceptance claimed.

### B54 — A test preloaded a view script and hung CI

- Found: 0.55.0 development, GitHub Actions run 44854128030 (cancelled by Claude after 33 minutes in "Required test suites")
- Reported by: CI log: `Compile Error: Identifier not found: GameState` at `scripts/rooms/under_counter_view.gd:33`, then `Node not found: "BackButton"` in `tools/test_rooms.gd`
- Fixed in: 0.55.0 (before release)
- Root cause: `tools/test_rooms.gd` preloaded `under_counter_view.gd` to read a constant. A `--script` test compiles before the autoloads (GameState, NightSession) exist, so the view failed to compile and stayed cached as broken; when the test later opened the scene it had no script and no back button. The error stopped the test coroutine before `finish()`, so Godot never quit, and the CI step has no per-suite time limit. Two defects: the preload (test) and the missing timeout (CI).
- Reproduction: preload any script that names an autoload from a SceneTree test script, then open its scene in the test.
- Expected / actual: the suite runs and reports / the suite never exits and the job stalls until GitHub's six-hour limit.
- Regression / evidence: the test reads the constant from the running scene's script (`get_script_constant_map()`); every suite now runs under `timeout 600`. Automated Godot 4.7.2, CI run 44857271062 on `90a11c1`: the Rooms suite completes (71 checks, 0 failures) and the job finishes in about two minutes. No user verification claimed.

### B55 — Pausing with the magnifying glass leaves the cursor hidden

- Found: Code checker change review, 21 November 2026, PR #70 head `6df5f89` (0.56.0, not merged)
- Reported by: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), code review only
- Fixed in: 0.58.7, by Claude (Opus 5.5, model id claude-opus-5-5).
- Root cause: confirmed, from code: `scripts/night/testing_bay_view.gd` sets `Input.MOUSE_MODE_HIDDEN` (window-wide) while the lens is over `PART_RECT.grow(LENS_RADIUS)` and only restores it in its own `_input` / `_put_lens_down` / `_exit_tree`. F10 opens `pause_menu.gd`, which sets `SceneTree.paused = true`; the bay (default process mode) then receives no `_input`, so the cursor stays hidden. The pause panel (`Rect2(420,170,440,360)`) sits almost exactly over `PART_RECT` (`Rect2(420,132,450,300)`), so its buttons must be used blind. The fix: the bay remembers whether it hid the cursor (`cursor_hidden`), shows it on `NOTIFICATION_PAUSED` and hides it again on `NOTIFICATION_UNPAUSED` only if the glass is still over the part; the shared pause menu also makes the cursor visible when it opens.
- Reproduction (expected path, not run): testing bay, select a part, pick up the glass, move it over the part, press F10.
- Expected / actual: the pause menu shows a cursor / the cursor stays hidden until the pause closes (Esc or F10 again) or the scene changes.
- Regression / evidence: `tools/test_testing_bay.gd` holds the glass over the part, opens the shared pause layer and checks the tree is paused, the bay's cursor is shown and the mouse mode is visible; after closing, the glass is still in hand, the cursor hidden again and no night minute was spent. Headless Godot does not hide a real cursor, so the check reads the bay's own state as well as the mouse mode. Automated evidence: `Testing bay` suite passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46062635008 on `cd204ef`.

### B56 — The stock room draws items kept under the counter at its origin

- Found: Code checker change review, 21 November 2026, PR #69 head `928610e` (0.55.0, not merged)
- Reported by: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), code review only
- Fixed in: 0.58.7, by Claude (Opus 5.5, model id claude-opus-5-5).
- Root cause: confirmed, from code: `scripts/storage/storage_view.gd` `_draw_room` loops over every entry in `model.placements` and calls `_draw_item(uid, _world_item(uid), ...)`. `_world_item` finds only units in `model.units`, so a placement in the new fixed `counter` unit returns `Rect2()`, and `_draw_item` draws `Rect2().grow(-2)` (a negative-size rect around world (0,0)) plus its outline. The comment in `storage_data.gd` says the stock room does not draw the counter unit. Since 0.58.4 the backpack is a second unit outside the room with the same effect. The fix: `room_drawn_items()` lists only placements with a world rectangle, and `_draw_room` draws those.
- Reproduction (expected path, not run): keep one or more items under the counter, open the stock room, zoom in at the top-left of the room view.
- Expected / actual: nothing from under the counter is drawn in the stock room / a small coloured mark per kept item at the room origin (presentation only; hit-testing returns no rect, so it cannot be grabbed).
- Regression / evidence: `tools/test_storage.gd` puts one item under the counter and one in the backpack, then checks neither is among the room's drawn items and every drawn item has a real rectangle. Automated evidence: `Storage` suite passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46062635008 on `cd204ef`.

### B57 — Build-request drawing blocks the morning step when the shop is low on cash

- Found: Code checker performance review, 23 November 2026, main `960b847` (0.56.1). The code came in with 0.51.0 (PR #64).
- Reported by: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), measured with a scratch timing script (not committed)
- Fixed in: 0.58.7, by Claude (Opus 5.5, model id claude-opus-5-5).
- Root cause: from code, consistent with the timings: `scripts/rules/ticket_generator.gd` `draw_build()` calls `BuildRequest.cheapest()` twice per attempt (once without wants, once with them), for up to `DRAWS` = 12 attempts. It checks affordability (`base.cost > money + deposit`) only after both calls. `cheapest()` in `scripts/rules/build_request.gd` is an uncached brute-force search over CPUs × GPU sets × cases × cooler/PSU options, at 9–60 ms per call in this container. `night_session.gd` `_arrivals()` runs `draw_build` synchronously for each build-request slot, up to 3 per morning. The fix keeps every random draw and every comparison as before: `cheapest()` remembers its answers by its arguments (a JSON key; at most 512 kept; callers get a copy), and the search skips a CPU/GPU/case combination whose parts already cost at least the best found (a cooler and PSU only add, and the comparison is strict, so the answer is unchanged).
- Reproduction (run): a SceneTree script at `960b847`, Godot 4.7.2.stable.official headless, 4-vCPU cloud container. It calls `TicketGenerator.draw_build(GameState.make_ticket_job(""), new_person, money, night, rng_for(12345, night, slot))` for nights 4/6/8/12 × slots 0–5. Two runs: at money 500, mean 18.3 / 18.8 ms, max 47 ms. At money 0, mean 165 / 166 ms, p95 282 / 262 ms, max 306 / 317 ms, and 17 of 24 slots found no affordable request.
- Expected / actual: the morning step finishes without a noticeable stall / with a low-cash shop it can stall for roughly 0.5–1 s (up to 3 slots × 165–317 ms). This is estimated from the per-slot timings; the full morning step was not timed, and no game was played.
- Regression / evidence: `tools/test_build_requests.gd` draws the checker's 24 low-cash slots (seed 12345, nights 4/6/8/12, slots 0–5, money 0) with and without the cache and checks the results are identical, that the cached run needs at most a third of the searches, and that changing a returned build does not change the remembered one; it prints both timings. Automated evidence: `Build requests` suite passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46062635008 on `cd204ef`.

### B58 — Night-workshop fixture skipped the new customer intake

- Found: local Godot 4.7.2 regression run during 0.57.0 development, 23 November 2026. B57 is already allocated by open checker PR #73.
- Reported by: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
- Fixed in: 0.57.0
- Root cause: the existing fixture called the product title's New game, forced a storage scene and proceeded directly into night work. The new opening gate correctly rejected its later PC switch; the fixture then assumed its bench return reopened a bench and accessed `paste` on storage_view, stopping the coroutine before the suite could finish. This is a test setup compatibility bug, not a reason to weaken the opening gate.
- Reproduction: run the unchanged parent `tools/test_night_workshop.gd` against the opening runtime. The bounded local probe reports Invalid access to property or key 'paste' on storage_view at the old fixture's line 193; it was stopped after 12 seconds instead of waiting indefinitely. Earlier save-error warnings are intentional failure-injection checks.
- Expected / actual: fixture serves initial customers then tests all night routes / it skipped intake and assumed the old night-ready setup.
- Regression / evidence: the fixture now accepts the two seeded customers in a bounded loop and asserts the queue is empty before continuing. All prior assertions remain. Godot 4.7.2 Night workshop: 57 checks, zero failures; the new native/cold-reload First customer suite: 32 checks, zero failures. No graphical acceptance claim.

### B59 — Protected ticket manifest during pending opening intake blocks continuation

- Found: Code checker change review of main `8342874` (PR #75, 0.57.0), 24 November 2026;
  originally reproduced at `1897eda` (0.57.2) and proposed in PR #77.
- Reported by: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled).
  Critically revalidated for 0.57.7 against main `842d0c2` (0.57.6) by
  Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
- Status / severity: Open / High. The original report said Medium; the register defines a blocked
  loop as High. No irrecoverable ownership loss has been demonstrated. This is reproduction, not a fix.
- Fixed in: 0.58.2 (developed as 0.57.11), by Claude (Opus 5.5, model id claude-opus-5-5), with the user's recovery policy (D172):
  `SaveStore.read()` takes an optional accept check and `ensure()` refuses a manifest from another run, so the
  .bak/.tmp behind it is read; every morning is backed up (`scripts/state/save_backups.gd`, newest 3 kept);
  when the counter finds the ticket book untrustworthy, or waiting customers without tickets, it shows "The
  ticket book is damaged" with "Restore this morning's backup" (`NightSession.restore_morning`). Restoring
  sets the current files aside (never deletes), tries the newest backup that loads and checks out, and puts
  the player's own files back if none does (the game then stays protected, as before). No job is invented,
  no pending ID is silently consumed, and the protections are unchanged.
- Root cause: `NightSession.ensure()` protects an unavailable/invalid manifest by retaining only the
  active job and setting `read_only`. Pending intake still forces the counter through `resume_path()`.
  `opening_cards()` returns no cards when any pending ID has no matching job; if only the recovered
  active job is pending a card appears, but `accept_opening_customer()` still refuses protected mode.
  Counter hotspots/navigation, PC switching and end-night retain their intake gates. Clearing only the
  queue is insufficient: shared `RoomView._navigate()` also requires a successful checkpoint, which
  refuses protected mode. That shared navigation barrier already existed before 0.57.0.
- Trigger qualification: `SaveStore.read()` falls back to .bak then .tmp for missing/unparseable files.
  A valid matching fallback recovers normally; the primary's absence alone does not imply this bug.
  However, a parsable dictionary with the wrong run is returned before semantic validation, so even a
  valid matching backup can be hidden by that primary. Both fallback and wrong-run cases were run.
- Reproduction (run): official Godot 4.7.2.stable.official.ed1daf0bf headless, Linux x86_64,
  `godot --headless --path . --script res://tools/reproduce_b59.gd`. The versioned diagnostic creates
  unique disposable saves, starts the existing two-customer opening, removes all three manifest
  candidates (or writes a wrong-run primary plus a good backup), resets the session binding, loads
  the main save and enters current counter.tscn. With both IDs pending: ensure false, read_only true,
  cards 0, visiting false, BackDoor disabled, accept/switch/end-night/workshop navigation all false.
  Other cases and exact results: [REVIEW_CONSOLIDATION.md](REVIEW_CONSOLIDATION.md).
- Expected / actual: preserve missing-ticket/ownership protections while exposing a safe recovery or
  continuation route / these protected intake fixtures provide no in-game continuation. The original
  “stuck for good / only New game” wording is too strong: restoring the matching manifest and cold
  reloading recovered both cards. A warm ensure remained false because protection is cached.
- Fix constraints (proposed, not implemented): address both intake and checkpoint-gated navigation;
  preserve the original files and every unrecovered job. Do not manufacture jobs, silently consume
  missing pending IDs, or accept only the front ID while a later job is absent (PR #78 proposal 2).
  Recovery behavior remains for a separate gameplay change and human review.
- Regression / evidence: (0.57.11) `tools/test_save_safety.gd`: the wrong-run primary with a valid backup
  now ensures and shows both opening cards; with the manifest gone the counter shows the recovery slip,
  the restore brings back both waiting customers, the counter starts again from that morning, the damaged
  files are kept aside and both customers can be accepted; ending the night backs up the new morning; a
  useless backup is refused and the player's own save is put back; only the newest three mornings are
  kept. Automated evidence: `tools/test_save_safety.gd` passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46033946684 on
  `d0472fe` (all suites); not checked in game by a person.
  Earlier evidence: automated reproduction, not fixed-bug verification. Ten disposable fixtures
  plus restoration check at 842d0c2; four healthy controls accepted normally, damaged queues stayed
  unchanged, and money/inventory/active job were preserved (zero setup/ownership failures). The
  diagnostic reports observations and is not a required CI test asserting that a lock should persist.

### B60 — Storage pull-up checks ran before the slide finished

- Found: 0.57.8 development (then numbered 0.57.7), GitHub Actions run 45702481532 on `e8eea57` (push to `feat/art-integration-0577`, not a PR)
- Reported by: CI log: `FAIL: hovering the edge pulls the storage up over the counter`, `FAIL: moving the mouse up slides the storage back down` (Rooms) and `FAIL: moving the mouse up slides the storage away, back at the same counter` (Counter art)
- Fixed in: 0.57.8 (before release; developed as 0.57.7, renumbered after #82 took 0.57.7)
- Root cause: the tests waited a fixed 30 frames for the 0.22-second tween. Headless Godot runs frames with tiny deltas, so 30 frames were not 0.22 s and the drawer was still sliding (later checks that needed it open passed once it arrived). Test defect, not game behaviour.
- Reproduction: run the Rooms suite at WIP `e8eea57` headless.
- Expected / actual: the checks see the drawer fully open / closed / the checks see it mid-slide.
- Regression / evidence: both suites wait (real time, at most 3 s) until the slide tween has finished (`settle_storage`). Automated evidence: `tools/test_rooms.gd` and `tools/test_counter_art.gd` passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/45703005341 on `c3bdaf1` (all suites); no user verification claimed.

### B61 — The magnifying glass hides clues it has already revealed

- Found: 0.57.8, scheduled Code checker change review of main `df5c03f` (PR #83 merged), 26 November 2026
- Reported by: Claude (Opus 5.5, model id claude-opus-5-5), Code checker (scheduled), by reading the code
- Fixed in: 0.58.1 (developed as 0.57.10), by Claude (Opus 5.5, model id claude-opus-5-5): the panel and the glass now draw the same stack, `picture_layers(kind)` (the close-up, then every revealed clue); the glass is `lens_glass(c)`, the lens circle cut to where both the glass and the point it magnifies lie on the picture, so nothing past the edge is smeared, and it shows nothing once it is off the panel.
- Root cause: `scripts/night/testing_bay_view.gd` `_draw()` (lines 281-286) draws the approved inspection picture and then each revealed clue overlay (`clue_texture(i)`) over `PART_RECT`. `_draw_lens()` (lines 330-339) then draws the glass as a polygon textured with `ItemArt.inspect(kind)` only, the healthy base picture, at 2x. The clue overlays are never sampled, so inside the glass the revealed scorch mark, domed capacitors or red herring is covered by a clean part. Near the panel edge (`PART_RECT.grow(LENS_RADIUS)`) the UVs also fall outside 0..1 and the border pixels of the picture are smeared into the glass.
- Reproduction (expected from the code; Godot was not run): a GPU with a visible broken tell; look at "Power connector" with the lens until the clue is revealed; move the lens back over the power connector.
- Expected / actual: the glass shows the revealed clue magnified / the glass shows a healthy connector, and the clue is only visible outside the glass.
- Fix direction (for the bay's owner, not done by the checker): draw each revealed clue overlay into the glass with the same UVs after the base picture, and clamp or mask the glass to `PART_RECT`. A headless test can check that `_draw_lens` samples every non-null `clue_texture(i)`; how it looks needs a graphical check.
- Regression / evidence: `tools/test_testing_bay.gd` (B61 checks): before looking, the stack is only the close-up; after the power connector is inspected on a dead GPU, the stack is the close-up then that scorch-mark overlay; the glass stays on the picture with every UV in 0..1 at the spot, half off the panel and in the corner; off the panel it magnifies nothing. Automated evidence: `tools/test_testing_bay.gd` passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46021841002 on `1ae3133` (all suites); how it looks is not yet checked in game.
### B62 — The B59 manifest check skipped a newer-format ticket book

- Found: 0.58.2 development (then numbered 0.57.11), GitHub Actions run 46033437449 on `2db0a5c` (push to `fix/b59-save-safety-05711`, not merged)
- Reported by: CI log: `FAIL: future manifest is protected against overwrite` (Night workshop)
- Fixed in: 0.58.2 (before release; developed as 0.57.11), by Claude (Opus 5.5, model id claude-opus-5-5)
- Root cause: the accept check first given to `SaveStore.read()` in `NightSession.ensure()` refused every
  manifest that was not version 1 of this run. A version-999 manifest (written by a newer build) was
  therefore skipped like damage, its version-1 `.bak` was read, the session was not protected, and the next
  checkpoint would have overwritten the newer file. B59 only needed one case skipped: a version-1 manifest
  from another run.
- Reproduction: Night workshop suite at `2db0a5c`: write the manifest with `"version": 999` while a valid
  `.bak` exists, cold-start the session, `ensure()`.
- Expected / actual: protected (read-only, checkpoint refused) / not protected, the older backup was used.
- Regression / evidence: the check now skips only a version-1 manifest whose run differs; anything else is
  read and validated (and protected) as before. Automated evidence: `tools/test_night_workshop.gd` passed in
  GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46033946684 on `d0472fe` (all suites).

### B63 — New-game recovery can restore the previous playthrough (PR #88)

- Found: PR #88 head a8667b7, 27 November 2026; not merged in this 0.58.0 baseline.
- Reported by: Codex, bounded user-requested PR review. B62 is allocated by the separate PR #88.
- Fixed in: 0.58.2 (in PR #88 before merge), by Claude (Opus 5.5, model id claude-opus-5-5): backups are kept per playthrough (`backups/<save>/run_<run id>/morning_<night>/`); the newest 3 mornings are kept within a playthrough and only the newest earlier playthrough stays archived (ordered by a sub-second stamp); `restore_morning` only tries the mornings of the run the main save belongs to and accepts a restored set only if it belongs to that run. Following the review's recommendation, a failed move or copy during a restore now puts the original files back (`set_aside` rolls back, `put_back`).
- Root cause: backup folders/retention and restoration are scoped by save filename/night number, without canonical run identity.
- Reproduction: retain morning 20/21/22 of a $777 shop, start a new $100 shop in the same slot, remove its manifest/fallbacks and restore. Its morning 1 was pruned; restore returns old run/night 22/$777.
- Expected / actual: recover a current-run morning / silently replace it with the previous playthrough.
- Regression / evidence: Automated Godot 4.7.2 reproduction on a8667b7; PR_87_88_REVIEW.md preserves output. Optional tools/reproduce_b63.gd observes the case on a tree containing the backup module. Supplied suites passed but omit this cross-run case. No user saves changed; no fix or graphical verification claimed.
  Fix evidence (0.58.2): `tools/test_save_safety.gd` repeats the review's case (an earlier $777 playthrough with mornings 20–22, a new game in the same slot): the new game keeps its morning 1 next to the archived playthrough, and with its manifest removed the restore returns the new run, night 1 and the new cash with both opening customers; a further new game keeps only the newest earlier playthrough. Automated evidence: `tools/test_save_safety.gd` passed in GitHub
  Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46042764485 on `57c6485` (all suites). `tools/reproduce_b63.gd` updated to the per-run API.

### B64 — Pause help points to the retired Activities screen

- Found: 0.57.9 source and earlier preserved first-day reports.
- Reported by: prior playtests; corrected during the 0.58.0 shared Settings work.
- Fixed in: 0.58.0.
- Root cause: shared pause copy was not updated when room navigation replaced Activities.
- Reproduction: F10 on any night station; read the pause help.
- Expected / actual: workshop/room instructions / instructions to use Activities.
- Regression / evidence: source now refers to workshop stations; shared Pause opens in the Antivirus suite. Graphical Codex [observation](ANTIVIRUS_0580_VALIDATION.md): F10 during the isolated adware cleanup displayed the corrected workshop-station text. The executable Pause journey is in `tools/test_antivirus.gd`; this is verified presentation, not human feel acceptance.

### B65 — Initial popup-setting fixture used the wrong input surface

- Found: 0.58.0 local test development, before delivery.
- Reported by: failed Antivirus fixture under Godot 4.7.2.
- Fixed in: 0.58.0 before release.
- Root cause: the fixture treated a native AcceptDialog Window as the root viewport; the toggle never fired, then bool() on the untouched malformed string aborted the test coroutine. No product toggle failure was established.
- Reproduction: send root-style pointer coordinates into the title Settings dialog, then cast its still-string fixture value to bool.
- Expected / actual: a control change with a normal test summary / unchanged setting and an invalid-constructor error.
- Regression / evidence: Automated `tools/test_antivirus.gd`: Antivirus 67 checks, zero failures/script errors. The headless fixture uses the actual CheckButton state/signal and guarded comparison; native OS-window pointer routing is reserved for graphical verification.


### B66 — Adware reaction names the wrong app after a case variation

- Found: graphical 0.58.0 development check, before delivery.
- Reported by: Codex, isolated adware cleanup with BonusSmiles.exe.
- Fixed in: 0.58.0 before release.
- Root cause: the source-stopped joke still hardcoded FreeCursors although D163 allows different initial adware names.
- Reproduction: start a case whose source has a different name, then stop that app.
- Expected / actual: the reaction names the stopped app / it says FreeCursors instead.
- Regression / evidence: graphical observation reproduced the mismatch; the reaction now reads the source label. Automated alias-specific assertion in `tools/test_antivirus.gd` passes on Godot 4.7.2 (68 checks, zero failures).


### B67 — Typing prompt lets the scan clues show through

- Found: graphical 0.58.0 miner cleanup, before delivery.
- Reported by: Codex, the word input over the scan-clue area.
- Fixed in: 0.58.0 before release.
- Root cause: the default panel style did not provide an opaque backdrop for the overlaid typing prompt.
- Reproduction: Read scan clues, stop the miner, inspect the word input: the clue text remains visible behind it.
- Expected / actual: an unobstructed typing prompt / overlapping background text.
- Regression / evidence: direct graphical observation; explicit opaque StyleBoxFlat now covers the prompt. The final graphical launch confirmed the unobstructed opaque prompt; see the [graphical record](ANTIVIRUS_0580_VALIDATION.md). The protected-process journey is in `tools/test_antivirus.gd`; no implementation-mirroring assertion was added for a colour/style change.

### B68 — Stopped miner keeps changing its alias

- Found: graphical 0.58.0 miner cleanup, before delivery; inherited from the previous alias logic.
- Reported by: Codex, the stopped source row changes from SystemHeater to CoolCoin and back while working on its helper.
- Fixed in: 0.58.0 before release.
- Root cause: Round.label calculated aliases from elapsed time even for an ended process.
- Reproduction: stop a protected miner, complete the word, leave its helper running for more than eight seconds.
- Expected / actual: all source interference stops / the stopped row still changes name.
- Regression / evidence: graphical observation; the final visible alias is now stored at stop. Automated clock-advance assertion in `tools/test_antivirus.gd` passes on Godot 4.7.2 (69 checks, zero failures).

### B69 — The brush covered the whole PC in an unmovable dust film

- Found: 0.58.3 playtest by the user, 27 November 2026; introduced in 0.57.8 (the approved dust film art).
- Reported by: the user: "when you use the brush, the pc instantly becomes full of unmovable /vacuumable(smaller) dust particles".
- Fixed in: 0.58.4, by Claude (Opus 5.5, model id claude-opus-5-5).
- Root cause: `CleaningRenderer.draw_dust_films` drew each zone's dust film (ART-17 heavy film, which looks like a mass of small specks) at a strength of "share of the zone's dust not yet removed". The case floor (`case_interior`) starts with no dust, so the first bundle the brush flicked onto it made that share 100%, and the film covered the whole case interior at full strength. A film is a texture, so nothing could move or vacuum it.
- Reproduction: open a dusty PC on the repair bench, brush a bundle until it is flicked onto the case floor.
- Expected / actual: the flicked bundle lies on the floor and can be vacuumed / the whole case turns into a speckled film.
- Regression / evidence: `DustSim.film_share` measures the dust still in a zone against what the zone started with (`zone_start`), so a zone that started clean never gets a film and the film fades where dust leaves. `tools/test_dust_flow.gd` (`test_film`): the floor starts clean, a tossed bundle lands on it (where the old rule read 100%), and the floor film stays 0 while the source zone's film drops. Automated evidence: `tools/test_dust_flow.gd` passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46053534084 on `7d8c8d4` (all suites); not yet checked in game by a person.

### B70 — A stray dash above the pick's bend

- Found: 0.58.3 playtest by the user, 27 November 2026.
- Reported by: the user: "The pick has a stray pixel left/top to the bend when picked up".
- Fixed in: 0.58.4, by Claude (Opus 5.5, model id claude-opus-5-5). Not an art change: the pick sprite has no stray pixel in any frame (checked).
- Root cause: with the pick in hand the bench draws a progress ring around its tip for the scraping stroke; it drew at least 1% of the circle (`maxf(0.01, ...)`) even with no stroke, a short dash 12 px above the tip, just at the bend.
- Reproduction: select the pick (4) on the repair bench and hold it still away from dust.
- Expected / actual: only the pick / the pick plus a small dash above its bend.
- Regression / evidence: the ring is drawn only while a stroke is in progress (`pick_progress() > 0`). `tools/test_bench_feedback.gd` checks that with the pick in hand and no stroke the progress is zero. Automated evidence: `tools/test_bench_feedback.gd` passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46053534084 on `7d8c8d4`.


### B71 — The collection slip called a kept old part "working"

- Found: roadmap phase p06 ("stop calling an untested retained GPU working", from ChatGPT's playtest records); confirmed by Claude from code on main 0.58.6, 27 November 2026.
- Reported by: ChatGPT playtest summary (the user's roadmap); root cause found by Claude (Opus 5.5, model id claude-opus-5-5).
- Fixed in: 0.58.7, by Claude (Opus 5.5, model id claude-opus-5-5).
- Root cause: since 0.50.0 (D158) every original the shop replaced is kept as UNTESTED stock with its real condition hidden, broken or not (`GameState.settle_custody`). The morning card text in `scripts/night/morning_text.gd` still said "Kept in your stock: their working %s", from D150 when only working originals were kept. So the slip claimed a test result nobody had, and for a broken part it was simply false.
- Reproduction: replace a customer's GPU with a shop part, call them, end the night; the collection card names the old GPU as "working" whatever its real condition.
- Expected / actual: the slip says the old part is kept and untested / it says "their working GPU".
- Regression / evidence: the card now reads "their old <part>, untested (you fitted a replacement, so the old part stays with the shop). The testing bay can tell you what it is worth." `tools/test_morning.gd` checks the text says untested and never "working" or "broken". Automated evidence: `Morning report` suite passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46062635008 on `cd204ef`.

### B72 — The B56 storage check did not parse

- Found: GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46062181908 on PR #94 (0.58.7 development), 27 November 2026.
- Reported by: CI; fixed by Claude (Opus 5.5, model id claude-opus-5-5).
- Fixed in: 0.58.7, before merge.
- Root cause: the new check in `tools/test_storage.gd` looped with `for uid: String in ...` inside `run_checks()`, which already declares `var uid` earlier; GDScript refuses a second variable of the same name in one scope ("There is already a variable named "uid" declared in this scope"). Godot is not run locally, so the parse error first showed in CI.
- Reproduction: run the Storage suite at the first 0.58.7 commit (`fix/trust-0587`, first push).
- Expected / actual: the Storage suite runs, including the B56 check / the script fails to load and the suite prints no summary.
- Regression / evidence: the loop variables are named `kept_uid`. Automated evidence: `Storage` suite passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46062635008 on `cd204ef`.

### B73 — The vacuum switch showed while mounting the cooler

- Found: 0.58.8 playtest by the user, 27 November 2026.
- Reported by: the user: "when you are mounting the cooler, the vacuum button appears".
- Fixed in: 0.58.9, by Claude (Opus 5.5, model id claude-opus-5-5).
- Root cause: 0.58.4 added the `VacuumSwitch` button in `scripts/view/bench_ui.gd` but not to `bv.clean_controls`, the list of cleaning-only controls the bench hides at the thermal paste stage, so it stayed visible over the cooler mount. (The V key was already limited to cleaning.)
- Reproduction: repair bench, switch to the thermal paste stage (or mount the cooler); the "Vacuum: OFF" button is still on the panel.
- Expected / actual: no vacuum controls at the paste stage / the switch shows.
- Regression / evidence: the switch is in `clean_controls`. `tools/test_audio_and_vacuum.gd` checks it is hidden at the paste stage and back when cleaning. Automated evidence: `Audio and vacuum` suite passed in GitHub Actions run https://github.com/123rearearcode/nighshift_real/actions/runs/46071704212.

### B74 — Returning to the counter reloads its large art set

- Found: user report on current main 0.58.8 / d0710c04c5181b007e0bbe21b3d4639d7b19a134, 27 November 2026; user confirmed it happens every return.
- Reported by: the user; reproduced and investigated by Codex (GPT-6, model id not exposed by this session), ChatGPT Work.
- Allocation: the earlier unmerged PR #97 used B73, already claimed by #96 for the vacuum switch; its counter-loading record is now B74.
- Fixed in: 0.58.10, by Codex (GPT-6, model id not exposed by this session).
- Root cause: CounterArt constructs dictionaries of 14 Batch A and 9 termopan textures per holder; the scene and its drawer own their references. Leaving the counter frees the last holders, so subsequent visits load new texture objects (about 138 MiB RGBA dimensions). Imported textures already share while alive; this is not a claim of two imported copies within one counter.
- Reproduction: after import, run tools/measure_counter_loading.gd from main 0.58.8; counter-to-workshop-to-counter creates a new shell texture instance on each visit. Four following returns took 297.850, 299.489, 295.435 and 302.138 ms in this workspace. The user observes a noticeable pause on each return.
- Expected / actual: room returns reuse unchanged artwork with minimal setup / the counter reconstructs its large texture set every time.
- Correction: keep a bounded process-local cache of successful counter-art loads, shared across presentation holders; source timestamp changes invalidate it, missing art remains uncached. No nodes or mutable gameplay state are cached and no artwork bytes change.
- Regression / evidence: `tools/test_counter_art.gd` tests room disposal/re-entry texture identity without a strong test reference, separate holders, unchanged intake/cash/time and missing/new/revised/removed unimported art. Automated: the final Counter art suite passed 40 checks under Godot 4.7.2; the original 39 required suites passed 2,610 checks locally before integrating #96. The #96 + #97 integration then passed all 41 required suites / 2,648 checks under local Godot 4.7.2; details are in CHANGELOG.md. `tools/measure_counter_loading.gd` passed 15 checks on each measurement run; docs/COUNTER_LOADING.md preserves same-workspace before/after samples and limits. Not target-PC GPU/frame-present or human feel evidence.
