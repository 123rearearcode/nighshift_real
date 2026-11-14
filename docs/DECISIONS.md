# Nightshift — Decision Register

Version 1.15 · 14 November 2026

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

## Bench furniture and paste fix — 13 November 2026, trial 0.20.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's playtest of 0.19.7.

D75 (confirmed): the hose has a spool beside the dust bin; clicking it retrieves the hose (it unclips from the clamp and re-lays itself neatly from the bin to the nozzle). Placement and look are proposals.
D76 (confirmed): the game gets loose items (random finds such as coins inside a PC, later). Now: the carrying infrastructure (hand state CARRYING_ITEM, entered with empty hands only; a tool in hand uses the tool), a trash can on the bench that destroys a dropped item, and test-only spawning. What spawns, where, and what items are worth is OPEN. The user left the pickup design to Claude: tools stay USING_TOOL; only loose items use CARRYING_ITEM.
D77 (confirmed, already built by Codex in 0.16.0): the menu screen shows the version number.
D78 (bug-fix rule from the 0.19.7 playtest): wiping the paste that squeezed out BESIDE the CPU never clears a mounted result or a completed repaste; only wiping the CPU itself does. (The user tidied the overflow after pulling the lever and lost the ability to press Complete repaste.)

## Power requirement, clamp and paste thresholds — 13 November 2026, trial 0.21.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's 0.20.x playtest.

D79 (confirmed): graphics cards get a power level (name to be revisited) and a PC needs at least its required output: a dead GPU outputs 0, a replacement outputs its tier's power (similar 100, budget 65 — proposals), the trial job requires 60 (proposal), and the final check fails and says the numbers when output is short. The hardware bench remains the shop's own spare-parts bench (its status line now says so); the customer's parts are replaced from the repair bench. Connecting the customer's PC itself to the hardware bench is still open.
D80 (confirmed): the hose clamp can be turned while carried (wheel or Q/E, like a tool); a turn that would push it into the PC, the bin or off the table is refused. Dropping the hose onto the clamp always clips: if the grabbed section cannot stay stretched there, the nearest section that reaches is clipped instead of refusing (0.20.0 refused, which read as "the hose does not attach").
D81 (confirmed, amends D78): a graded CPU keeps its result until wiping takes the paste below 95% of what was there at grading; above that, touch-ups on the CPU are safe too. Wiping beside the CPU still never clears.
D82 (restores D57, supersedes the 0.19.7 stage-switch behaviour): a stage switch mid-mount lifts the cooler off WITHOUT securing or grading (the paste keeps its pressed shape; mounting can be restarted). Nothing but the lever ever secures. Codex's cross-review flagged the violation; its pending-defect checks are promoted into the regression suite and the pending lane is empty.

## Attached hose, spool reel-in and PC power — 14 November 2026, trial 0.22.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's 0.21.0 playtest video.

D83 (confirmed bug): the hose end is physically ATTACHED to the vacuum, always. The video showed it hanging loose near the clamp while the vacuum rested elsewhere (a hose clipped near its nozzle leaves too few segments past the clip, and nothing pulled the vacuum within reach). Now a clipped hose acts as a short leash (the vacuum is tugged to stay within the remaining length, capped per step), and the drawn hose always ends on the vacuum, bridging the simulation's small lag. The simulation itself keeps Codex's zero-self-crossing behaviour.
D84 (confirmed): clicking the spool REELS THE HOSE IN: the vacuum is dragged back to the spool and rests beside it (520 px/s, proposal). Taking the vacuum or grabbing the hose stops the reel. Replaces 0.20.0's instant re-lay.
D85 (confirmed): the PC case has a power button (top-right). While off, the fans wind down and the fan loop is silent; the state is saved per job. Nothing else reacts to power yet (fan-dust and "other components" come with the fan mechanic, D56/D76). Position and look are proposals.
D86 (reported, not reproduced): "on collision without enough space, items disappear". A 12-throw stress test into the crowded tray corner keeps every tool on the table; part collisions are now clamped into the table as well (belt and braces). If it happens again, the user should note which object vanished and what was around it.

## Final-check rule and the customer — 14 November 2026, trial 0.23.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's 0.22.x playtest.

D87 (confirmed): leftover dust never blocks the final check. It matters only through the temperature it adds (and the notes still say where it is). The check passes while the PC is under the limit and every part is functional: nothing broken, nothing left out, enough graphics output. The ticket keeps the full-clean checkbox as guidance only.
D88 (confirmed): the shop's lower card has tabs: the final-check result and a Customer tab with what the shop knows about the customer (who they are, what the PC is used for and must output, habits, time, payment). Customer records live in `scripts/data/customers.gd`; the trial customer is Mara V. (fictional). Habits are written to feed the scam direction (D17/D18: persona-based discovery). Which habits actually do anything is still open.

## Time, tool colours and the salvage assignment — 14 November 2026, trial 0.24.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's direction.

D89 (confirmed): picking things up takes time, because the night is about managing limited time. First cut: unscrewing a FITTED cooler or GPU takes 1.2 s of holding on it (progress ring at the cursor; slipping off or letting go cancels; a part lying in the tray lifts instantly). The duration is a proposal; more pickup timings will follow the same rule.
D90 (confirmed): the four cleaning-tool buttons are colour-coded (vacuum blue, brush amber, move parts green, pick red). First pass colours the button text; tying the same colours into the tool drawings is open.
D91 (confirmed): Codex is assigned the street/dumpster salvage minigame in parallel: design proposal first (docs/CODEX_PROMPT_SALVAGE.md), own scene and scripts, no hot files, state fields through Claude. The customer model rework (name, persona, trust, budget, portrait, profession with FPS needs, history, return and satisfaction) and the software-checks screen (monitor with anti-virus, game store with bought games and simulated FPS, overclocker) are MAPPED FIRST before any code, per the user; nothing of them is built yet.


## The customer model, first wave — 14 November 2026, trial 0.25.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's point-by-point approval of
docs/CUSTOMER_MODEL_MAP.md (their answers are quoted there).

D92 (confirmed): trust is ONE number per customer, 0–100, starting at the record's trust_start and moving at pickup (±(score−70)/10 per visit, proposal). Earned trust, history and comeback live in the save under `customer_state` and survive new_game — like owned games, they are the shop's property.
D93 (confirmed): no quoting flow for now; each ticket has a fixed payout and each customer a budget cap for later charging. Professions first cut: regular, gamer, clueless; a clueless customer's needs hold `stated` (a decoy) and `real` (what actually scores).
D94 (confirmed): games have gpu/cpu demands and a RAM minimum; the shop must BUY a game ($, an investment) to test with it. One test game: Counter Stroke 2 ($12; demands 55/60/8 GB — proposals). fps = 60 × min(gpu×thermal/gpu_demand, cpu/cpu_demand); heat throttles the GPU linearly 60→90 C down to half; RAM under the minimum keeps 35% (stutter). The job carries pc_specs (cpu_power, ram_gb).
D95 (confirmed): on the FIRST passing final check the pickup is scored 0–100 against the customer's REAL needs (temperature, named games at minimum fps, quiet). ≥70 leaves happy; unhappy customers come back about it, angrier sooner (<40 → 1 day, <60 → 2, else 3 — proposals). Scams are NOT scored at pickup; delayed discovery adjusts trust later (open).
D96 (confirmed): the overclocker app is second wave. The software-checks screen (customer's monitor with boot test, anti-virus, Vapor game store, overclocker) is mapped in docs/CUSTOMER_MODEL_MAP.md; 0.25.0 builds only the rules behind it.
D97 (confirmed, supersedes D79's threshold): the boot test replaces the required-power threshold. The PC can be handed back with ANY output as long as it boots (nothing broken, nothing left out); the final check runs and reports the boot test. GPU power levels stay — they now feed the fps simulation.


## Night salvage approval and first isolated demo — 14 November 2026, trial 0.26.0
Recorded by Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work. The user approved the direction,
then requested code. These IDs reconcile unmerged design PR #31 with Claude's newer D92–D97 above;
the customer rules are preserved. Full specification: SALVAGE_DESIGN_PROPOSAL.md.

D98 (confirmed): car model determines travel time and trunk capacity. Faster cars travel faster;
pack finds using a size-aware trunk grid and rotation. Catalogue/unlocks/prices/exact values remain open.
D99 (confirmed): multiple locations have different item odds and are re-dumped every few in-game days.
Exact intervals/visibility are open. The demo uses deterministic per-site cycles and shows its sample
schedule; cargo/shelf survive refresh. No live campaign save/refresh interface exists yet.
D100 (confirmed direction): physically clear layered bags/boxes/rubbish to uncover hardware/whole PCs.
Moving takes time. Searching, recognising value and deciding whether to continue all matter. Use clues,
a sorting area, whole-PC versus stripped-part choices and satisfying bounded 2D handling. Contents are
not rerolled on opening. The demo's geometry/weights/hold durations are tuning, not final realism/art.
D101 (confirmed): ordinary night-clock progression pauses during outings; explicit travel/action costs
consume time instead, without double charging. Return reserves, proportional partial-effort charging
and refusal of unaffordable actions are the demo's provisional implementation, not a final overtime policy.
D102 (confirmed direction): show tendencies, car-adjusted travel time and known activity, hiding exact
contents/true condition. Tips can attract visits, but their delivery/reliability remain open with Claude.
Junk, damage, irrelevant finds, space and time can make salvage unwise. The demo uses static information;
no customer tip, reputation, sale, claim or automatic diagnosis system was added.

D91 boundary retained: Codex's separate scene/salvage scripts/tests; Claude's shared clock/save/stock/
customer adapters. The first demo is session-only, does not award campaign stock or write GameState, and
leaves every hot file untouched. See the handoff for exact limitations and proposed interfaces.


## Native 2D dumpster physics trial — 14 November 2026, trial 0.27.0
Recorded by Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work.
D103 (confirmed prototype request): try the side-view 2D dumpster format with real gravity, object-object
collisions and force-based grabbing. Items must support/displace each other; removing support allows
collapse, and containers must open into actual accessible contents. The user found 0.26.0's top-down
layer/nudge movement unsatisfying. Implemented with native RigidBody2D; opened boxes/PC frames have
three wall colliders, opened bags flatten and spill pre-existing contents. Springs/torque/force caps,
friction, damping, spawn layout and rim/sorting geometry are provisional feel tuning. No final format,
soft-body simulation, new economy or target hardware performance is approved by this trial. Grid/time/
identity rules remain; world release is physical, cargo rollback stays logical. Existing ownership and
no-hot-file/shared-state boundary remain in force. Updated in the existing salvage PR; no self-merge.

## Cross-review round, rotation, settings and rim containment — 14 November 2026, trial 0.28.0
Recorded by Claude (Fable 5, model id claude-fable-5), from the user's direction and both cross-reviews.

D104 (confirmed): customers ROTATE per COMPLETED ticket: finish a ticket and the next customer in `customers.gd` brings the next one; abandoning a ticket (New game without completing) keeps the same customer waiting. The counter (`tickets_taken`) is the shop's property: saved, kept across new games. Open (Codex): ticket IDs restart at T001 per run, so history entries from different runs can share an ID; real comeback/scam resolution will need unambiguous visit identity.
D105 (confirmed, fixes Codex finding 2 on 0.25.0): trust moves at least ±1 at every pickup — a happy visit (score ≥ 70) gains max(1, round((score−70)/10)), an unhappy one loses at least 1. Integer division used to swallow scores 61–79 entirely.
D106 (confirmed, fixes Codex finding 3 on 0.25.0): loaded customer history is rebuilt field by field; anything that is not a visit Dictionary is dropped instead of crashing the shop, a missing trust defaults to THAT customer's trust_start, and each customer keeps only the last 10 visits (proposal). The dossier showing the exact budget stays for the prototype (noted open by Codex; later pricing may hide it).
D107 (confirmed): the main menu gets a Settings option — for now one sound slider (master volume, applied live, muted at zero). Settings live in their own `user://nightshift_settings.json`, never in the game save, and survive new games.
D108 (confirmed, user playtest of the salvage demo): the find you HOLD must be lifted over the dumpster rim, but it cannot be used as a bulldozer: a rim barrier (layer 256, rim up to the ceiling) stops every body except the held one, so only the carried find can cross. Pile physics inside the dumpster stay fully interactive.


## General inventory — 14 November 2026, trial 0.29.0
Recorded by Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

D109 (confirmed user request): general inventory contains PCs, owned tools and parts; it is
visually a rack, expandable with several furniture types. Implement code on a separate branch
and leave it unmerged while Claude works. First implementation and boundaries: docs/STORAGE.md.
Free furniture, eight units, shelf sizes and installed-part shelf reservations are provisional
prototype choices, not approved economy or final storage rules. Current purchases still use
the old drawer capacity checks until a coordinated shared-capacity hook is approved.
