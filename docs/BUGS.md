# Nightshift — Bug register

Current ledger reconciliation: **0.47.1**, 18 November 2026. This ledger distinguishes a recorded fix
from verification. It is not a claim that every historical fix has been replayed on the current build.
Next structural review: **0.50.0**. An early focused review is recorded below for the 0.47.1 work.

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
| B50 | Verified | Medium | Anti-virus input | Review prototype SEND did not complete a mainframe override; native port must support actual click and Enter | 0.49.0 | Automated: native SEND/Enter and uppercase regression |

## Known limitations and design debt (not closed bugs)

| ID | Status | Priority | Limitation | Next action |
| --- | --- | --- | --- | --- |
| L1 | Investigating | High | Customer part identity is slot/order-derived; identical parts lack a complete stable physical record | Stage the per-part model described in PART_LIFECYCLE.md; reproduce swaps of identical customer components before migrating |
| L2 | Investigating | High | Orphan fitted_in custody marks have no recovery UI | Establish a safe reproduction/recovery policy; never clear an unknown mark just to make stock available |

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

## Reviews (newest first)

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
