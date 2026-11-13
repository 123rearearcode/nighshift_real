# Nightshift — Decision Register

Version 1.13 · 13 November 2026

This is a consolidated baseline, not a verbatim or individually timestamped transcript. All entries were consolidated on 12 November 2026. IDs are stable references for future tasks. Changes require recording what superseded the previous rule.

| ID | Status | Decision |
| --- | --- | --- |
| D01 | Confirmed | Final product must be publishable on Steam; current browser game is a prototype |
| D02 | Confirmed | Pixel art, clear component colours, generic names with hover model details |
| D03 | Confirmed | Parts-size inventory grids, shaped model-specific motherboard grids, compatible connectors, cases determine interior space |
| D04 | Confirmed | Dozens of choices per major part category, low through high end; CPU replacement; repairable motherboard; complete assembly from an empty case |
| D05 | Confirmed | Physical drawer stock, drag/click handling, interactive cleaning and thermal pasting, separate technician-PC diagnosis view |
| D06 | Deferred | Cable visuals removed for clarity; reconsider later |
| D07 | Confirmed | First complete day teaches the loop; press Open/Close shop; untimed individual day customers |
| D08 | Confirmed | Visitors drop off/collect repairs, buy goods, sell parts/PCs/bulk; trade-ins wanted but conditions open |
| D09 | Confirmed | Questions and limited intake inspections determine night monitor information; budget/date negotiation |
| D10 | Confirmed | Continuous night clock, manual pause; routine inventory and monitor activity use time; upgrades can increase shop time |
| D11 | Confirmed | Incomplete work persists; overtime permitted with fatigue/money costs and possible social/reputation effects |
| D12 | Confirmed | Dump is a minigame; time cost depends on choices; details deferred |
| D13 | Confirmed | Hidden true budgets; free player prices with recommendation; customers may offer first or request a quote |
| D14 | Confirmed | Persona/relationship influence deadline flexibility, knowledge and other behaviour |
| D15 | Confirmed | Trust and closeness are separate; descriptive display; last ten meaningful events visible plus persistent major story facts |
| D16 | Confirmed | Overall shop reputation with workmanship/reliability/value influences clientele, traffic and online sales |
| D17 | Confirmed | Invented faults, exaggerated work, used-as-new, unperformed-work charges and cheaper substitutions are available scams |
| D18 | Confirmed | Deception through ordinary workflow; obtainable deception modifiers; initially persona-based random discovery, refined later |
| D19 | Confirmed | Removed parts remain customer property until returned, bought or disposal authorised; customer PCs occupy inventory |
| D20 | Confirmed | Finite daily visitor set; early closing permitted; no loaner PCs for now |
| D21 | Confirmed | Mostly generated suppliers; hidden dishonesty, ratings and different opening/closing availability |
| D22 | Confirmed | Common older consumer parts widely supplied; high-end scarce; some supplier-exclusive models; fluctuating prices |
| D23 | Confirmed | Market stock/prices update between days; occasional major events; delivery choices depend on supplier |
| D24 | Confirmed | Total supplier spending unlocks bulk; some offer immediate bulk and ~90% of that group are shady |
| D25 | Confirmed | Current bulk-lot mechanic is just price reduction; no elaborate inspection/ sealed-lot subsystem |
| D26 | Confirmed | Whole PC is one large storage footprint; internal grid revealed on bench; removed parts separate |
| D27 | Confirmed | Online listings for PCs, parts and lots; asking price/specs/condition/claims; offers/questions over days |
| D28 | Confirmed | Own build can serve as technician PC, be upgraded/sold/replaced, and have power tested |
| D29 | Confirmed | Personal PC: 1% daily failure chance, protected at least five days after obtaining a new PC; boundary/replacement details unresolved |
| D30 | Later update | Advanced diagnostic software with hardware requirements and buying games for performance testing |
| D31 | Long-term | B2B/bulk sales unlock by conditions; server builds have complex demands; exact release placement open |
| D32 | Confirmed | Lore and substantial enjoyable progression are release needs; setting and endgame not selected |
| D33 | Superseded workflow | Original coding pause; now replaced by D38 stabilisation task |

## Important distinctions
- The v0.9 prototype is deliberately untimed for testing. That does not cancel D10's final-game night clock.
- Prototype grid dimensions, socket names, jobs, prices and repair times are demonstration values, not approved production balance.
- ~90% shady refers to immediate-bulk suppliers, not all suppliers or every transaction.
- The five-day failure protection is approved; precise inclusive/exclusive day counting is not.
- Diagnostic fee credited to repair, exact budget-approval procedure and other earlier suggestions were not explicitly accepted as payment rules. They remain open.

## Proposals, not selected decisions
Full production migration; Windows-first release; benchmark breakdown into CPU/GPU/overall plus stability; exact tutorial/five-day job sequence; starting resources; time durations; overtime cost formula; tutorial-only safeguards; visible supplier rating evolution. See DESIGN.md and ROADMAP.md.

## Change procedure
Append a record: date, decision ID, old rule, approved replacement, reason, affected files/tasks. Update DESIGN.md and ROADMAP.md consistently. Mark abandoned proposals as superseded; avoid growing contradictory parallel rules. New AI output remains proposed until accepted by the user or explicitly delegated decision authority.

## Collaboration update — 12 November 2026, v1.1
- Fact: user downloaded Godot and reports creating a GitHub repository. Repository address/access/content and editor version are unverified.
- Working proposal: Godot/GDScript, local editor for testing, GitHub for shared history, one lead coding AI and bounded specialist contributors. The user requested the handoff documents reflect this approach.
- Final engine migration remains unconfirmed; no code or remote repository change accompanies this document update.
- Added file-access distinctions, shared data contracts, branch ownership, honest runtime-verification requirements and beginner repository onboarding to PROJECT_BRIEF.md. CURRENT_STATE.md and ROADMAP.md updated consistently.
- Existing gameplay decisions D01–D33 unchanged.


## Reconciliation update — 12 November 2026, document v1.2 / trial 0.7.2
D01–D32 are preserved. The following additions incorporate the supplied newer handoff at the user's request.

| ID | Status | Decision |
| --- | --- | --- |
| D34 | Recorded newer agreement | Stash, case and motherboard form nested grids; case fittings are grid items; customer ownership persists through dismantling |
| D35 | Recorded newer agreement | Part height and case-depth constraint; exact units and stacking rules remain open |
| D36 | Recorded newer agreement | Parody brands; catalogue fields include category/name/brand/price/rarity/condition/grid/compatibility/performance/heat; format and model-vs-instance condition remain open |
| D37 | Recorded newer agreement | Night hub routes to repairs/tickets, go-out/map and stock/tools/upgrades Shop; customer-commissioned builds are a mid-game direction |
| D38 | Current authorised task | Stabilise Godot trial, reconcile notes, update/include all five original documents in the handoff; explain large-view refactor before broad change |
| D39 | Current working facts | Manual ZIP exchange with Claude; GitHub repository provided and document upload user-confirmed; AI repository integration not established |

Conflict resolutions: daytime phase and continuous night clock are confirmed by D07/D10, not OPEN. Night hub does not replace daytime business. Removing customer parts does not grant ownership (D19). Cable placement remains deferred. Newer agreement records are sourced to docs/DESIGN_PROPOSALS.md in supplied 0.7.1; the raw Claude conversation was not provided.

This package changes documents and application version metadata only. Current implementation is not declared stable, target-verified or production-ready. Historic v1.1 collaboration notes above remain as history and are superseded by this section.


## Trial 0.8.0 update — 12 November 2026, docs v1.3
D40 (authorised): fix dust visibility/tool selection, shorten cleaning, correct shared case/motherboard geometry, begin bench-file cleanup, and check payments without altering established prices. Added shared layout and extracted PC renderer; persistence and payout regression checks run. Model dimensions, 36 bundles, suction 7.5 and display sizes are implementation tuning, not locked release balance. Full PC inventory/assembly is not claimed. Previous 0.7.2 no-gameplay-change statement applies to that historical patch only.


## Trial 0.9.0 update — 12 November 2026, docs v1.4
D41 (confirmed request): remove redundant syringe button; reduce base vacuum strength and add some dust plus independent specks; add blocked access and physical part removal; review interaction smoothness. Discuss broader physics representation afterwards, not during this change.
Scoped delivery: GPU and cooler can be dragged to a service tray and refitted. Their installed bodies protect hidden dust; payment requires reassembly. Additional model-specific disassembly and rigid-body/3D physics are not selected. Strong suction is a later-progression direction; no new vacuum-upgrade purchase is introduced. Recorded tuning is provisional.


## Trial 0.10.0 update — 12 November 2026, docs v1.5
D42 (confirmed request): add a pick to inspect/extract trapped dust beneath components without removing them, with risk of damage. Preserve a choice between correct repair and speed/money; allow replacement with similar or inferior parts. This develops the already confirmed cheaper-substitution/deception direction in D17/D18.
Scoped implementation covers GPU/cooler only. Equivalent and budget replacements are demo choices, not the release catalogue. Damage blocks final check; functional downgraded parts may pass and retain their lower specification. Customer discovery, honesty/disclosure choice and social consequences remain unimplemented, not rejected design. Exact prices, 12% risk, 0.8s stroke,65% specification and+8C penalty are proposals for playtesting, not approved final balance.


## Free arrangement update — same 0.10.0 delivery
D43 (confirmed follow-up): improve object handling based on user-supplied Probably Stolen recording; allow parts to be moved/rotated throughout storage, with forgiving feedback that encourages experiments. Storage location is independent of motherboard compatibility. Controlled motion and quarter-turn footprint placement are implementation choices for playtesting; no engine migration is authorised. The reference recording informs interaction goals, not permission to reuse assets/code.


## Trial0.11.0 — 12 November2026, docs1.6
D44 (confirmed request): include tabletop/edge bounce on throws; apply tactile/physical object handling to repair tools and movable pieces; replace circular brush with dynamic physical geometry; fix/check dust presence on opening; connect replacement tray to player inventory.
Scoped implementation uses a shared bounded2.5D tabletop model and bristle springs, not full3D/body-to-body simulation. All repair tools share follow/toss handling; service-removable GPU/cooler and hardware drawer pieces bounce/recover. One stock list and shared positions connect hardware drawer with purchase/fit actions. Unlike0.10.0's combined purchase/fitting, buying replenishes actual stock and fitting consumes owned stock without a second charge. Starting quantities, rebound, friction and thresholds are trial tuning. The existing replacement prices and payout values are preserved. The user still owns catalogue design; generic stock choices are not a catalogue expansion.
The missing dust report was checked against fresh and reopened tickets: fresh/partially dirty tickets show dust, cleaned saves correctly contain none. Root cause on the user's machine is not established. Added explicit fresh-ticket dust initialisation, brighter drawing, visible count/status, new dirty ticket action preserving economy, and stale-scene save protection. Do not silently erase cleaning progress on each bench entry.

## Bench physics, workflow and repaste — 12–13 November 2026, docs 1.7, trials 0.12–0.15
Recorded by Claude (Opus 5.5, model id claude-opus-5-5). Entries D45–D51 catch up user decisions made while building trials 0.12–0.14 (by Claude Sonnet 5.5, model id claude-sonnet-5-5); D52–D56 are new with 0.15.0. Numbers in the trials remain proposals.

D45 (confirmed): the brush never removes dust; it loosens, displaces and tosses it, and long chains shed small specks. Only the vacuum removes dust. Dust floats a little (cosmetic motes).
D46 (confirmed): no picked-up object may leave the area it belongs to; this applies to every moving-object logic.
D47 (confirmed): dust management is a mechanic. The vacuum has a fillable dust bin that must be emptied, and a physics hose anchored at the bin that has a limited length, lies around pieces, can be picked up and moved, and gives a soft tug when taut. A longer hose is a shop upgrade. The bin was enlarged after playtest (0.15.0: 90 -> 140 units, proposal).
D48 (confirmed): pieces on the bench (tools and loose parts) collide with each other as rotated boxes; knocks must stay gentle.
D49 (confirmed): tools can be rotated; the middle mouse (wheel or drag) is the default turning control, Q/E also work. With a tool in hand, a left click uses that tool.
D50 (confirmed): the clogged dust filter being hard to clean is a feature (its dust grips harder).
D51 (confirmed, workflow): every AI edit is signed with the model name and exact model id (changelog Author, HANDOFF signature, commit messages). Older versions are kept as `archive/vX.Y.Z` branches until the user's last confirmed human playtest. Claude may merge pull requests into main (user permission, 2026-11-13).

D52 (confirmed): the thermal paste minigame ends with a Complete repaste button, available only once the result is good. The repaste counts for the job only after completion. (Trial: PERFECT or GOOD ENOUGH; real thermal paste costs $3 per repaste — proposal.)
D53 (confirmed): the player can use toothpaste instead of thermal paste to scam the customer. This is a hands-on instance of D17/D18 (cheaper substitution through the ordinary workflow). Trial: toothpaste is free, stiffer to spread, +14 C, passes today's check and is recorded on the job as a scam; dry-out, discovery, complaints and reputation effects are NOT simulated yet (proposal numbers).
D54 (confirmed direction): after the current bench/servicing part of the project is complete, the game goes further in the scam direction: more ways to cut corners and cheat built into the hands-on repair actions, with consequences. Which scams, how they are discovered and what they cost the player are OPEN and are the next design task (see DESIGN.md section 19 and docs/DESIGN_AGENT_PROMPT.md).
D55 (open): the dust minigame needs a further purpose or twist; the user is thinking about it. Do not build changes to its goal until the user decides.
D57 (confirmed, 0.15.1): securing the cooler is a physical action: click the retention lever beside the socket. No Secure button, no Enter shortcut, no automatic securing.
D56 (superseded plan): fans swirling dust and blowing it under components were planned as 0.15.0; the user redirected 0.15.0 to the paste game. The fan idea stays queued (DESIGN_PROPOSALS.md section 5), not cancelled.

## Approved scam/minigame update — 13 November 2026, docs 1.8 / patch 0.15.2

D58 (confirmed concepts; supersedes D54's OPEN concept selection): the user accepts A toothpaste, B visible-only cleaning sold as full, D budget part presented as quoted spec, E used-as-new, F pick damage blamed on the original fault, G old paste billed as fresh, H unnecessary replacement presented as needed. C filter face-lift is rejected. Preserve stable letter IDs and ordinary filter cleaning D50. Details/numbers in the proposal are not blanket-approved; no gameplay implementation accompanies this entry.

D59 (confirmed requirement): make customer promises available to the player while working: agreed work, parts/material/condition where specified, price/spending authorisation, collection date and revisions, with customer/PC identity. Unknown terms stay unknown; the hidden true budget stays hidden. Exact UI is proposed.

D60 (intended rule consequence of accepted B and promise information): distinguish agreement, actual work, completion claim and functional result. Leave real dirt/material/specification unchanged when lying; do not auto-detect lies through private records. Full-clean grading and return eligibility must be separable, while functional assembly/damage checks remain. MINIGAME_RULES.md supplies the intended rules; exact service menus, thresholds and revision approval are proposals. Current 0.15.1 gates are unchanged by this docs patch.

D55 update: accepted B and customer promises give dust an agreed honesty-versus-speed purpose. Other dust twists remain proposals; D56 fans remain queued. D39 integration facts are superseded: GitHub is connected and this documentation change targets a PR in `123rearearcode/nighshift_real`, without merge.

Signed: Codex (GPT-6, model id not exposed by this session) in ChatGPT Work. Exact deployment id is unavailable, so D51 exact-id compliance cannot be claimed; do not fabricate an id.

## Start/menu and hose update — 13 November 2026, trial 0.16.0

D61 (confirmed request): a simple start screen has New game, Load game and Achievements; New game currently leads into the existing demo. Achievements is a clearly labelled placeholder, not a completed achievement system. Existing-save replacement confirmation and no-save Load disabling are protective implementation choices.
D62 (confirmed request): the hose routes around the cooler's outside housing rather than its round fan. Tools must not get trapped in it. The hose is grabbable and can optionally be parked in a desk clamp. Implementation: full rectangular component obstacles and link clearance, hose below tools/held parts, explicit Shift-right pickup, visible session-local clamp with release. Exact placement and controls remain playtest tuning.
D63 (workflow update): the user identifies Codex as GPT 6.1 Sol, and explicitly authorises merging all open PRs, including tested work by the other AI. This supersedes the previous task's no-merge instruction. At task start only #10 was open; it was merged. Future unrelated approvals are not inferred from this task.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## Dust transport and fixture update — trial 0.17.0, 13 November 2026

D64 (confirmed bug report/task): first-entry vacuum/brush must work without New dirty PC/reset. Preserve actual looseness/progress on reopen and cover all entry/reset paths with real bench-input regressions. The user's original failure was not reproduced from a clean 0.16.0 ticket, so no save-specific root cause is asserted.
D65 (confirmed): overbrushed real dust can move across the case instead of remaining locked to its original component; GPU/cooler and filter can trap it. Implementation transfers remaining mass between areas, adds a zero-spawn case_interior area, preserves locations/traps/looseness in saves and lets areas become dirty again. Brush movement never creates cleaning credit. This extends D45; D56 fan-driven transport remains queued. Collision/catch speeds, grip and thresholds remain trial tuning.
D66 (confirmed): the clamp is movable but cannot be placed inside the PC. Implementation keeps its whole footprint outside case/bin and on the table; parked hose reach is enforced. Right-drag moves; empty-hand left-click unclips. Position is session-local, not yet persisted.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## Recorded interaction correction — trial 0.17.1

D67 (confirmed repair request): tools must work after put-down/pickup and parts must remain removable for cleaning. Reproduced causes: a left pickup discarded its held stroke, and parts clicks were intercepted by resting-tool selection. Same-press pickup/use and parts-mode click priority restore the intended interaction. D64's earlier unresolved first-entry symptom is now reproduced for this concrete sequence. No balance or physics scope change. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## Trapped dust and reach/handling refinement — 0.18.0

D68 (confirmed request): when dirt catches under a part, show protruding dust chains which can be removed with difficulty. Implement representative partial threads/count and slow precision suction outside the housing; removing the part remains easier, pick remains risky. Tails are real existing mass, not cosmetic progress or an evidence system. Exact rate/visibility count are trial tuning.
D69 (confirmed requests): clamp must be movable outside the PC, and vacuum hose should only just reach the far-left case corner. Implement left/right drag, stationary left-click unclip, no UI overlap, and retuned base/upgrade lengths with actual corner-reach tests. Existing longer-hose ownership persists. Lengths and gesture threshold remain provisional.
D70 (confirmed bug report): a held tool must be put-down-able during cooler mounting without pulling the lever first. Mount start parks tools; right-drag put-down is available while pressing or waiting at zero time. It does not lock/grade/complete the cooler. The user confirms 0.17.1's previous fixes work.
D71 (discussion only): improve cooler visuals/satisfaction. Presentation directions in DESIGN_PROPOSALS section 6 are proposals, not blanket approval to implement a new pressure/screw/tilt mechanic. Preserve D52/D57.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## Interaction priorities and silent audio — 0.19.0

D72 (confirmed clarification, supersedes the emphasis of D71): the user wants cooler interaction design and better button organisation now, deferring graphics. Pressure build/release and deliberate lever finish are accepted directions; this is not approval of an exact replacement pressure puzzle or new art. Keep D52/D57.
D73 (confirmed): prepare detailed sound design and feedback hooks for handling, vacuuming, paste and other actions, with no sounds yet. Implement a silent event service/cue catalogue/native mixer layout; sonic palette and playback implementation remain future work.
D74 (recording-led repair): the observed suction stop coincides with bin capacity around 35 seconds. Capacity/manual emptying remains intentional; full-bin state must remain visible across tool changes. Correct hose self-crossing loops, including grabbing/clamping, without silently extending occupied hose reach.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
