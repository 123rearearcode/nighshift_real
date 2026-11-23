# Nightshift — Working Design

## First-day opening — 0.57.0 branch, 23 November 2026

User-authorized separate gameplay follow-up after #74's 0.56.3 art-credit/checklist push: New game now
presents the existing repair customers at the counter before night-one work. Intake is untimed; pending
ticket IDs survive save/Continue, existing saves skip it, no duplicate PCs/payment or artwork is added.
Main remains unchanged until this stacked PR merges after #74. Current code/ownership and revised
future version slots (anti-virus 0.58.0, part tests 0.59.0) are in HANDOFF; D166 records the user decision.
Art agents still update FIRST_DAY_ART_CHECKLIST and ART_ASSET_LOG; runtime is not art creation.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Current art brief — 0.56.2, 23 November 2026

The user's first-day art task is documented in ART_DIRECTION.md and FIRST_DAY_ART_CHECKLIST.md
(D165), with existing PNG references under art/references/. Read them before creating/integrating art.
Preserve layered scenes, latest readable dusk/Balkan direction, clipboard-only initial tabletop and one
20 x 10 under-counter grid (visible or proposed look-under). No art/runtime/save change is implemented
by this documentation pass. Existing repair screens may remain placeholders for the first playable
counter slice. Opening-day intake is not falsely claimed built; current new game starts at night 1.
Earlier release/branch status below is historical; HANDOFF's newest section controls the current task.
Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Current audit follow-up — 0.54.0, 21 November 2026

Codex's user-authorized follow-up preserves individual delivered shop parts through collection,
reload, removal/refitting, return to stock and immutable comeback receipts. Actual health/defect,
UID and known evidence survive ownership transfer; hidden condition stays out of hover text.
Unreplaced loose components leave in the customer's bag with their records intact. The existing
comeback remains a report, not an automatically spawned repair ticket. See PART_LIFECYCLE's 0.54.0
stage and HANDOFF for the integration boundaries.

This patch is stacked after open #64 builds, #65 trust/reviews and #66 Rooms. L3 is fixed for future
handovers (B53); old lost state is not guessed. L1 legacy originals/bench aliases and L2 orphan
custody remain open. L4 now tracks clock integration, L5 drawer overflow independently. No new time
charging rules or UI routes are added. Claude resumes the current Rooms/art/playtest work after
cross-review/user-controlled integration. The scheduled next structural review stays at 0.60.0.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Current anti-virus contract — D157, 19 November 2026

The user approved the standard in-chat Task Manajer and requested game integration. The chaotic
disappearing/reordering version is rejected as normal play; a future boss is only an idea. Fixed rows,
readable process evidence, one occasional advert, slow miner aliases, uppercase funny-word overrides
and no typing countdown define this slice. Cure requires stopping the actual source and watchdog,
disabling auto-start and a verified reboot; closing the activity cannot finish/pay a repair ticket.
See ANTIVIRUS_MINIGAME_DESIGN.md for the current implemented contract and trial timing. The diagnosis
contract below remains in force; its baseline-status paragraph is historical (diagnosis is merged).
The manual stays deferred. Next planned session is still 3.6 Testing bay, talk first.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.

## Diagnosis design update — approved 17–18 November 2026 (D150)

Design contract, **not an implementation claim**. Verified main is 0.46.0 with 3.3b merged;
diagnosis is next. Detailed current rules: REPAIR_LOOP_DESIGN.md section 5. Resume instructions and
file ownership: HANDOFF.md and WORK_PLAN.md. Older status paragraphs below describe their versions.

- Start from the customer's complaint, potentially with multiple aspects. Hidden faults and actual
  state remain separate from what the player knows. No diagnosis quiz or new completion button.
- Findings distinguishes physical **Observations**, test **Measurements** and **Work history**;
  it never writes the conclusion. Log only evidence actually exposed, with relevant part/configuration
  context. Keep historical results and mark them outdated after relevant changes.
- Timestamps use the actual shared night clock and night identity, including midnight/save/load/PC
  switching. No separate diagnostic clock. Existing clock mechanics are not rewritten by this design.
- Story-case facts/faults stay fixed. Optional explanations and progressively more specific guidance
  come through a **manual** chosen by the user. No automatic difficulty scaling, mentor, new customer
  follow-up questions, hidden-fault-driven answers or automatic hints. Manual chapter/UI details remain
  proposals; this approves the format, not an extra case-specific hint engine.
- Test outputs have defined limits; Hardware check, hover text and fitting/refitting permissions
  cannot expose hidden health. Meaningful comparisons can narrow possibilities without claiming proof
  beyond what changed. Ambiguity classification is requested; its exact categories remain proposed.
- Preserve D130/D133/D146 hidden installation and delayed pickup/comeback behaviour.
- Temporary substitutions require suitable parts actually owned by the player; those stay shop-owned
  and removed customer parts stay theirs. Settle permanent replacement at collection. An unnecessary
  replacement of a working part costs the player and its original enters player stock; no double charge
  for a purchased test part or charge merely for an experiment.
- Use existing test time/cost trade-offs; trial numbers stay provisional. Refused/incomplete tests
  cannot claim a completed result. Reading notes/manual adds no separate time charge.
- Cases remain solvable using available capabilities. Mandatory story jobs do not vanish or change
  truth when equipment is absent; their particular alternate/acquisition path still needs design.
- Rich visual component inspection and the proposed example-case pack are **later**. Generation,
  testing bay and builds remain their separate Wave 3 sessions.

**Split and delivery:** Codex owns diagnosis design/manual content and cross-review. Claude owns
runtime diagnosis/manual integration and its tests. Claude audits existing/unpublished code FIRST;
if it conflicts with the approved contract, deliver a separate compatibility patch before continuing
new features. Preserve unpublished work, coordinate hot files and retain user-controlled merges.

Signed: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work,
18 November 2026, Europe/Bucharest. No runtime implementation or Godot run by this documentation update.

**Current 0.42.0 navigation update (approved 16 November 2026):** based on main 0.41.0, preserving
Claude's connected customer hardware, install technique, Shop, malware/overclock and timed monitor
measurements. Earlier progress/branch-status notes below are historical. Only older MENU/PATH rules
are superseded; other confirmed design remains. Canonical menu rules: MENU_NAVIGATION.md.

Activities chooses Workshop room / Salvage / Shop. Drop a customer PC into the room slot to open
work directly. Persistent Repair / Hardware / Monitor tabs view that same PC; Repair has Cleaning
and Thermal secondary tabs. Named parent at top-left, selected PC identity centrally, Activities
and Pause at top-right. No intermediate service chooser, duplicate navigation actions or direct
Title button in an activity. Title's Continue resumes the last valid activity, PC and subview.
Pause actually pauses; it contains Resume, existing Settings and Title screen. Room furniture
edits belong to Arrange room mode; ordinary inventory/PC handling stays uncluttered, with autosave
status and an error-only retry. Safe exits preserve owned work and reject failed saves/running tests.
Navigation preferences are separate/run-bound and never own PC state. Salvage remains session-only.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 16 November 2026.

Current review build: **0.34.0 spool, brush-first controls and movable heavy waste**. Room 0.33.0
was approved/published/merged in PR #40; its older local-only notes below are historical.
See BENCH_FEEL_0_34.md. Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.


Current local delivery: **0.33.0 room storage**, based on integrated main 0.32.0. Prior branch-status
notes are historical. Room has direct furniture, eight floor bays and zoom/pan; no rack-selector list.
See STORAGE_ROOM.md and REVIEW_0_32.md. Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.


Latest merged: **0.31.0 salvage variety** — fresh random pile per arrival, fourteen collectible kinds,
heavy obstacles (docs/SALVAGE_VARIETY.md, D113). Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.

Current delivery: **0.30.0 night workshop / activities**, pending review, stacked on unmerged 0.29.0.
New Game → Activities → Workshop or Salvage; two real customer PCs, three-shelf racks,
non-completing diagnostics and free switching. Full scope/boundaries: NIGHT_WORKSHOP.md.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.


Previous delivery: **0.29.0 general storage rack**, pending review/unmerged. Signed: Codex
(GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 14 November 2026.
F5 → Storage rack; PCs/tools/parts share expandable furniture grids. See the final section and
STORAGE.md for controls, save boundaries and capacity integration still to coordinate with Claude.

Earlier milestone notes follow.


Version 1.15 · 14 November 2026

## Status vocabulary
CONFIRMED = explicit user decision. PROPOSED = recommended but not approved in detail. OPEN = unresolved. IMPLEMENTED = prototype behaviour only; it does not prove release completeness. See CURRENT_STATE.md for implementation.

## 1. Day and night — CONFIRMED
The first complete day is tutorial-like. The player presses Open shop. Customers appear one by one; daytime interaction is untimed. Visits include repair drop-offs, selling old components/whole PCs (sometimes bulk), occasional purchases, and collections. Intake may include questions, brief power-on checks and inspection. Information gathered defines the job information shown on the technician monitor at night. Inspection permissions and symptom accuracy vary by persona.

Players negotiate repair price and estimated collection date. Some customers open with an offer; others request a quote. Some impose deadlines. Persona, urgency and relationships affect flexibility. Prices are freely set with a recommended price; the customer's actual maximum budget is hidden. Their offer reflects component costs as they understand them, capped by affordability.

The player manually closes after business, or closes early and turns away remaining visitors. There is a finite daily set influenced by reputation, events and collection appointments. Night begins: repair, service, build, or go salvaging. Normal work, monitor reading and inventory interaction use a continuous clock. Manual pause stops it. Upgrades can increase shop time. Exact duration, time multipliers and upgrade effects are OPEN.

Night expiry preserves unfinished work and advances toward morning. Overtime is possible. It costs fatigue and money; events/customer circumstances can also affect relationships or reputation. Exact costs and social-event rules are OPEN. A reduction to the following night's time is a PROPOSED fatigue implementation, not a fixed formula.

## 2. Spatial hardware and assembly — CONFIRMED
Cases define interior space and supported layouts. Each motherboard model is a unique playable grid with specific connectors and capacity; its shape is not merely a rectangle. Parts require compatible connections and enough physical space. Inventory uses size-aware grids and rotation. Complete PCs occupy one large inventory footprint. Opening a PC on the bench exposes its internal layout; extracted parts become separate inventory items. Customer PCs also occupy inventory and remain customer-owned.

CPU, motherboard, RAM, GPU, PSU, storage, cooler and other components can require replacement or servicing. Motherboards can break and be repaired. Additional parts include Wi-Fi, Bluetooth and sound hardware. Final catalogue: dozens of choices per major component category, spanning obsolete/low-end to premium. Exact counts, footprints, connector families, thermal rules and performance formulas are OPEN. Parody brands and original product naming are the recorded direction from the supplied handoff. This is an artistic choice, not a legal guarantee; exact names/specifications remain open.

Build complete machines from empty cases. Keep a personal machine, upgrade it, sell/replace it, or sell builds to customers online/in-store. Workload-specific needs should make combinations meaningful; precise scoring and compatibility tables require design.

## 3. Repair and tools — CONFIRMED
Separate technician-PC view holds diagnosis information and tools. Bench views explore inside/outside and laid-flat/upright presentation. Drag physical stock from a drawer onto appropriate mounts. Use familiar generic component labels and consistent colours; smoothly reveal model details on hover.

Cleaning and thermal paste must be hands-on activities, with interactive dust behaviour and player-applied paste. Cooler and airflow presentation should help machines feel like PCs. Cable visuals are deferred because they reduced clarity. Sound clues are desired later; details and accessibility alternatives are OPEN. Repair outcomes need verification. Customer satisfaction mechanics must connect to the wider relationships and reputation rules.

## 4. Customers, lore and reputation — CONFIRMED
Recurring people plus other visitors; relationships change through play. Track professional trust separately from personal closeness. Display descriptive labels rather than exact numbers. Show the last ten meaningful interaction events per customer; retain important story facts beyond that rolling history. Lore is a release requirement; setting, cast and story arcs remain OPEN.

Shop reputation is separate from individual relationships. Overall standing with workmanship, reliability and value qualities influences customer types, visitor numbers, opportunities and especially online sales. Exact aggregation and visibility rules are OPEN. Some customers have greater computer knowledge. Knowledge, budget and flexibility vary by persona.

## 5. Deception — CONFIRMED
Player options include inventing faults, exaggerating work, misrepresenting used parts as new, invoicing work not performed and secretly fitting cheaper parts. Deception occurs through ordinary diagnosis reports, installation and invoices. Obtainable modifiers can improve deception ability. Sources, stacking, caps and balance are OPEN.

For now discovery is probabilistic based on customer persona, modified by deception ability as designed. Exact equation and consequences are OPEN; a future evidence-based detection system is not approved for current implementation. Scams can affect reputation and relationships. Do not silently equate transparent premium pricing with false claims.

## 6. Ownership and trading — CONFIRMED
Removed components remain customer property until returned, sold to the player, or authorised for disposal. Trade-ins of broken components against new replacements are wanted, under conditions still OPEN. Customers may sell whole PCs or parts, including bulk. Current bulk-lot scope is a price reduction only. No loaner PCs for now. Early collection of unfinished work may be resolved by an extension, discount or return; precise rules are OPEN.

## 7. Suppliers and markets — CONFIRMED
Supplier market is mostly randomly generated. Older consumer components are easy to obtain from multiple suppliers at different prices. Higher-end models become scarcer; some are exclusive to one supplier. Prices fluctuate. Stock/prices update between days; occasional events create larger changes. Delivery speed and cost depend on supplier, requiring player choice; exact delay events are OPEN.

Suppliers have reputation ratings, differing availability/opening times, and hidden trustworthiness; some intentionally deceive the player. Appearance and seller claims are visible; functionality needs testing, with possible seller test results. Newly encountered suppliers can be risky. Exact visible-rating logic is OPEN.

Total spending unlocks bulk access. Some suppliers allow bulk immediately; about 90% of that group are shady. This is a supplier-group design probability, not a confirmed 90% failure rate on every order. Unlock thresholds, discounts and fraud outcomes are OPEN. Supplier relationships do not yet have an approved full social simulation.

## 8. Online sales — CONFIRMED
List whole builds, individual parts and bulk lots. Choose asking prices, specifications, condition and claims. Offers and buyer questions arrive over subsequent days. Reputation affects buyer interest/confidence. Exact payments, shipping, returns, listing fees and sale timing are OPEN.

## 9. Personal PC and salvage — CONFIRMED
The personal PC serves as technician terminal; it can be built, upgraded, kept, sold and replaced. Test its power level through a mechanism still OPEN. It can break with a 1% daily probability after at least five days of protection following acquisition of a new PC. Precise day-boundary, what qualifies as a new PC, repair failure handling and anti-reset exploits are OPEN.

Confirmed night salvage direction (D98–D102): cars determine travel time and trunk space; multiple sites have different loot odds and are re-dumped every few days. Physically move layered bags/boxes/rubbish to uncover useful parts/PCs, with a sorting area and rotatable trunk grid. Site tendencies, travel estimates and known activity inform an uncertain gamble; proper diagnosis is back at the bench. Ordinary clock progression pauses during outings; explicit travel/action costs consume night time. Salvage can be a bad choice compared with repairs or buying stock.

IMPLEMENTED 0.26.0: isolated in-memory demo, two sample cars/sites, explicit effort/travel budget with return reserved, pre-generated container contents, obstructed extraction, sorting/packing, same-session revisits and few-day cycles. No campaign inventory, saving or real night hub integration. Exact numbers, return/overtime rules, inspection, tips and physics remain tuning/proposals as labelled in SALVAGE_DESIGN_PROPOSAL.md. No fuel/wear/stealth system implied. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.

### 0.27.0 authorised physics experiment

D103: try the dumpster as a side-on cutaway using native 2D gravity/collisions and a force-based mouse
grip. Objects support each other; removing a support changes the pile. Boxes/PCs open into solid wall
frames, while bags collapse and their pre-generated parts become physical. No invisible percentage
blocking gate remains. Players must physically clear the rim before transferring an item to the trunk.
Cargo cancellation restores its committed grid; releasing/cancelling a world grip lets the body drop
where it actually is, rather than teleporting it back through the pile. This is a playable trial, not
approval of final art, perfect soft-body bags or a guaranteed frame-rate budget. See the specification
and measured 20/50/100-body stress profiles. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work.

## 10. Later and unresolved scope
LATER UPDATE: diagnostic software requiring particular hardware; buying games and testing customer-requested performance. LONG-TERM: B2B/bulk sales unlock under conditions; more complex server demands. Whether servers are initial release or an update is OPEN. Advanced endgame must remain enjoyable and change the experience substantially, but its systems are not selected.

## 11. Explicit proposals awaiting validation
The tutorial plus five ordinary days in ROADMAP.md is a proposed test campaign, not approved lore or a fixed progression schedule. Overall/CPU/graphics benchmark scores plus stability are proposed; only the ability to test power is confirmed. Tutorial failure protection beyond the five-day personal-PC rule, starting cash, roster and exact job sequence are proposals. No time balance, economy balance or external-player validation has been completed.


## 12. Reconciled additions from the Godot handoff — 12 November 2026
The user asked to incorporate the newer design notes. Items explicitly marked AGREED in the supplied notes are carried forward as recorded decisions; proposals stay proposals. Earlier confirmed rules prevail over an accidental OPEN label.

- Three nested spatial levels: stash/inventory, PC case, motherboard. Case fittings (board, PSU, drives, fans) are grid items. Whole PCs still occupy one large storage footprint. Taking apart a customer machine does not transfer ownership of its parts to the player.
- Every part has a flat footprint plus an integer height; a case has a depth limit. Reject parts that are too tall with a clear explanation. Units, reference point, overlapping layers and cooler/CPU stacking are not defined yet.
- Catalogue fields: category, name, parody brand, price, rarity, grid footprint/height, compatibility, performance and heat. Condition is required information; whether it belongs on a model or individual item is not yet approved. Suggested separation into model data and owned-instance condition remains a proposal. File format and actual catalogue contents remain open; the user is preparing the catalogue.
- Customer-commissioned custom builds are a mid-game direction, with unlock details open.
- Night hub navigation includes repairs/tickets, go-out/map and a Shop option for stock/tools/upgrades. The hub is navigation, not a replacement for daytime customer business. Always call the latter Daytime shop when ambiguity matters. The existing shop.tscn is a trial job/menu stand-in.
- Time model is already decided: untimed daytime visits and a continuous night clock with manual pause. Do not reopen it as action points/energy without a new user decision. Whether hub navigation itself pauses is unresolved; do not silently implement a pause exemption.
- Main menu, end-night summary, particular salvage destinations, matching-square mounting feedback and loose dust specks remain proposals/queued requests whose exact implementation needs a task.
- Cable/riser/extension placement remains a later proposal; it does not reinstate removed cable visuals.

## 13. Trial behaviour is not release design
Godot trial 0.7.1/0.7.2 has one job, one RAM model/board, demo temperatures/prices, six cleaning zones, vacuum bundles, a square-cloth upgrade and timed mounting. These are implemented experiments, not final content counts or balance approvals. A timed mounting activity does not establish the final night duration. Read CURRENT_STATE.md for actual persistence limits and verification.


## 14. Current servicing/layout direction — trial 0.8.0
The user requested immediately visible dust on dirty PCs, explicit paste/cloth switching, shorter cleaning, correct component mounting, case/board layouts that adapt to model requirements, and continuing review of Claude's code. Implementation choices: shared cell geometry used by cleaning and hardware views; uniform display fitting; tower and compact demo profiles; case-depth checks; reduced dust density/faster suction; independent syringe selection. A model has explicit usable cells and connectors; display scaling must never create compatibility or silently enlarge a physical board. Arbitrary new models/catalogue assembly remain future work. Valid saved cleaned PCs stay clean on resume; new repairs begin dirty. All trial density, speed, layout and depth numbers remain provisional.


## 15. Servicing challenge update — trial 0.9.0
User confirmed: one syringe control, weaker initial vacuum than the previous 0.8.0 tuning, a little more dust including independent specks, and components blocking access so parts must be physically removed to clean underneath. Stronger vacuum behaviour can belong to later progression; an upgrade system for it is not implemented here. Broader physics redesign must be discussed after these changes.
Current scoped implementation: two removable service components (GPU/cooler), drag with Move parts to an on-screen service tray, clean their top surfaces on the tray and the newly exposed regions on the board, then refit. Installed parts block both tools from hidden dust and obstruct relevant tool-to-dust paths. This is a 2D access model, not a full 3D or rigid-body collision simulation. Removing a cooler invalidates the previous paste grade; finishing cooler mounting refits it. Final check requires refitting the GPU too. Parts remain customer-owned and their removed state persists; the tray is not saleable inventory.
Demo tuning: 51 bundles + 34 independent one-node specks over eight zones; suction 4.0 (was 7.5), radius 50 (was 72), ramp 0.2s. Counts/times remain provisional. Specks are separate particles, not nodes visually attached to a bundle; a full airborne dust model is deferred.


## 16. Risk, damage and substitution — trial 0.10.0
CONFIRMED direction: give the player a choice between correct/careful repair and money/speed. A service pick checks for trapped dust and can extract it without removing components, at risk of damaging them. Broken components can be replaced with equivalent or worse parts. This extends D17/D18; consequences ultimately connect to customer knowledge, discovery, relationships and shop reputation.
IMPLEMENTED trial: pick (key4) inspects installed GPU/cooler on hover; holding performs an extraction attempt. Hover alone is safe. Success removes one trapped bundle/speck; failure damages that part, stops picking and prevents final-check payment. Moving a component to the tray remains the safe access path. Remove the damaged part, open Replacements, buy/fit one of two options. Equivalent retains original specification; budget saves cash but records a downgrade. Damage, removal, replacement tier and cash persist. Replacing the cooler clears paste; new paste is required. A successful functional check can pay for an inferior replacement and reports the downgrade rather than automatically rejecting the scam.
PROVISIONAL tuning: 0.8 seconds per attempt, 12% damage chance per completed attempt; equivalent/budget GPU $40/$18, cooler $16/$7. Budget specification65% of original; budget cooler+8C in thermal check. Risk rolls occur per attempt, never per frame. No GPU performance benchmark, wear damage physics, component repair minigame, stock catalogue, disclosure choice or customer detection/reputation simulation is implemented. Trial parts are generic abstract choices; user still owns final catalogue design.


## Free arrangement update — same 0.10.0 delivery
CONFIRMED user follow-up: storage should invite picking up, rotating and rearranging parts without motherboard-placement errors. IMPLEMENTED: a12x8 drawer supports any free position/orientation that fits, footprint bounds and overlap checks; compatible vacant motherboard sockets highlight before release. Ordinary storage drops succeed quietly. Unsupported/out-of-space drops return to last committed position with a nonmodal amber hint; Esc cancels. Parts have animated spring following, pickup lift/shadow/sway and smooth quarter-turn rotation; logical grid placement stays deterministic. Two RAM instances plus a generic GPU exercise different footprints. Hovered drawer parts rotate in place when room permits. Per-profile sandbox positions/rotations/installations persist through re-entry/save/load. This is controlled interaction motion, not unconstrained rigid-body collisions, gravity, throwing or arbitrary-angle occupied footprints. Complete shop inventory/ownership integration remains future work.


## 17. Shared stock and tabletop handling — trial0.11.0
CONFIRMED: thrown objects should bounce at edges/on tables; repair tools should have tactile handling, the brush should have a dynamic physical shape, replacement tray must connect to player inventory, and dust should appear on first entry without Reset.
IMPLEMENTED: a bounded tabletop simulation with in-plane velocity/spin, reflected edge impulses, separate vertical hop/gravity/floor rebound, friction and eventual rest. Hardware fast release throws unless dropping on a board target; Shift-release forces precise placement. Flight uses reserved committed inventory cells; settled pieces snap to the nearest available position, retaining selected quarter-turn orientation or returning safely if it no longer fits. Esc cancels ordinary carrying. Repair tools follow with damped motion and shadows; left hold uses, right-drag/release tosses, click a resting tool or hotkey equips. All five tools (vacuum, brush, pick, cloth, syringe) share the rig. Move parts mode supports tactile GPU/cooler movement and flick throws over the repair worktable, with re-pickup/refit and saved resting poses. Dust on a moving component transforms with its body. Mounting still uses the existing pressure activity.
Brush: handle/ferrule/13 independent bristles; tips trail velocity, spread/compress on contact and relax on lift. Tip positions determine dust loosening; no circular brush footprint. This is a spring bristle approximation, not deformable-body collision simulation. Pick risk and protected dust rules remain intact.
Owned stock: one persisted player_inventory list with unique uid,kind,tier,owner,condition and a shared inventory_layout snapshot. Initial trial stock: two existing RAM instances, equivalent/budget GPU and equivalent/budget cooler. Buying a service item charges once and adds it only if money and grid space suffice. Fitting uses an available working owned item in the drawer; consumes its uid, assigns it to the customer PC and keeps the broken original customer-owned in a separate per-ticket record. A part installed on the hardware board cannot simultaneously serve as loose repair stock. Both screens read the same list; empty stock never regenerates free samples. Reset arrangement never replenishes stock. Full ownership/storage for every customer PC, part-type compatibility catalogue and supplier purchasing remain future work.
Dust: fresh tickets explicitly start with zero removal in all eight zones; visible dust is brighter and a ticket/visible-group status is always shown. Cleaned saved work is preserved rather than re-dirtied automatically. New dirty PC starts a new practice ticket, keeping money/upgrades/stock and clearing work on the prior practice ticket. Ticket-id guard prevents the departing scene from overwriting fresh dust. This is not the final intake/customer queue.
OPEN/LIMITS: no body-to-body collision response, rigid-body 3D scene, throwing damage, material-dependent masses/sounds or persistent flight velocities. Free tools return to their rack on re-entry; service component resting poses persist, and inventory throws settle safely on exit. Customer detection/reputation/disclosure remain deferred. Restitution0.60, floor bounce0.33, gravity950 and throw thresholds are provisional feel values.

## 18. Bench servicing since 0.12 — trials 0.12–0.15 (IMPLEMENTED unless marked)
Written by Claude (Opus 5.5, model id claude-opus-5-5). Decisions D45–D56 in DECISIONS.md.
- Dust: bundles and specks; the brush loosens, tosses (dust slides and settles elsewhere on its part) and chips specks; only the vacuum removes dust; floating motes are cosmetic. The front filter's dust grips 1.5x harder (clogged filter, intended).
- Dust management: swallowed dust rides a see-through hose to a dust bin (140 units, proposal) and the vacuum stops when the bin is full until the player clicks it to empty it. The hose is a rope with a length limit, curves round pieces, can be right-dragged out of the way, and tugs the vacuum back when taut; a longer hose is a $40 shop upgrade (proposal).
- Handling: tools and loose parts collide gently as rotated boxes; nothing leaves its area; tools turn with the middle mouse (wheel/drag) or Q/E.
- Thermal paste (0.15.0): squeeze, mount and press, inspect, then Complete repaste. Only PERFECT or GOOD ENOUGH can be completed; a bad result must be wiped and redone. Real thermal paste costs $3 per repaste (proposal); the final check counts the paste only when completed. Gauge and grade lines were retuned from a scripted playtest: about 100–160 units on the CPU and a 2.5–4 s press give a good result (proposal).
- Securing (0.15.1, D57): the cooler is locked by clicking a retention lever beside the socket; when the 10 s of pressing are over, the paste has set and the lever waits.
- Toothpaste (0.15.0, D53): selectable instead of thermal paste while the CPU is bare. Free; stiffer, so it needs more pressure; +14 C in the final check; the customer still pays; recorded in `job.scams`. Nothing happens afterwards yet.
- Verification: automated suites and a scripted playtest run on Godot 4.7.2 in GitHub Actions; the user playtests by hand. Feel numbers remain proposals.

## 19. Hands-on scams — approved concepts, not implemented systems

Approval update, 13 November 2026 (D58): A toothpaste; B visible-only cleaning claimed as full; D budget replacement claimed as quoted specification; E used part sold as new; F pick damage blamed on the original fault; G old paste billed as fresh; H unnecessary replacement presented as necessary. Original letter IDs remain stable. **C, filter face-lift, is rejected.** Normal difficult filter cleaning remains D50; do not reintroduce C as a separate filter shortcut.

Use ordinary tools for honest work and shortcuts. Disclosed budget parts/limited work are honest options. Preserve customer ownership of removed parts (D19). Scams do not bypass broken/missing component checks. D18's first discovery model is persona-based probability, not an evidence system. Trust and closeness remain separate (D15); shop reputation remains D16. Exact delays, odds, prices, remedies and new-condition/old-paste models still need design and implementation.

See SCAM_DESIGN_PROPOSAL.md for each accepted concept's physical action, gain, risk, discovery and dependencies. Toothpaste action/record exists in 0.15.1; the other concepts and customer consequences are not declared implemented.

## 20. Dust/paste rules and customer promises — intended behaviour

D59: the player can consult what they promised from the bench. The work order includes customer/PC, symptom, agreed work and exclusions, parts/specification/condition and material if specified, price/authorised spending, collection date/revisions and removed-part arrangements. Unknown terms remain unknown. The agreed spending ceiling must never expose the persona's hidden real budget.

D60: agreement, actual work, completion claim and functional result are distinct. Show the agreement beside private actual-work information; a lie can change the completion claim, never physical dirt, material, ownership or the accepted agreement. Detailed panel layout and quote-revision flow are proposals. A record of the agreement is not an NPC evidence system.

Dust retains vacuum-only removal, blocked dirt, safe disassembly/risky pick, hose/bin and bounded tools. To support B, full-clean quality must be separate from return eligibility: a functional PC may be falsely claimed clean while its hidden dirt persists. This is intended policy; 0.15.1 still uses its all-zones cleanliness gate. Exact limited-service scopes and functional acceptance thresholds are open.

Paste retains the good-result Complete repaste gate and physical retention lever. Workmanship and material are separate: well-spread toothpaste is still toothpaste. Old-paste reuse needs genuine residual-material/reseat state, not a false fresh-paste grade. Required fresh paste must follow the agreement or actual authorised work; the fixed trial ticket currently requires it.

MINIGAME_RULES.md is the detailed rule specification and completion checklist. Finish the coherent promise/work/claim/handoff/one-consequence loop, including saved progress, no duplicate payments and a human playtest, before describing the minigames as complete. Full campaign, all seven scams and airflow/liquid cooling are separate milestones. D56's fan redistribution remains queued.

Documentation revision signed by Codex (GPT-6, model id not exposed by this session) in ChatGPT Work. No gameplay code changed.

## 21. Start screen and hose refinement — trial 0.16.0

F5 opens New game / Load game / Achievements. New game resets and enters the current shop demo; Load restores a readable save. Achievements is an unavailable placeholder. Starting over confirms replacement of existing progress; normal startup without a save does not create one. Main menu in the shop saves and returns.

The hose follows full cooler/GPU rectangular housings, not fan circles; links must also clear housing corners. Held tools and carried parts pass above it. Shift + right-drag lifts a section (or right-drag with empty hands); dropping it in the desk clamp parks that section. Empty-hand clamp click or re-grabbing releases it. A held-tool throw has priority so the hose cannot steal pickup/throw input. Clamp/hose arrangements are session-local. Other approved dust/paste/scam rules remain unchanged; promises/claims/consequences are still not implemented by this feature.

Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## 22. Physical dust state and transport — trial 0.17.0

D64–D66: all entry/reset paths share initialization. Saved physical state retains looseness and the current location of real dirt; legacy saves keep their fractional progress. Light brush contact gradually loosens and visibly brightens dirt; vigorous strokes toss it across the case. Dirt can catch under installed GPU/cooler or in the harder-gripping filter. Removal exposes trapped dirt; risky pick remains an alternative. Vacuum can collect moving dust without waiting for it to settle.

A Case interior progress area receives scattered dirt. Area totals move with dirt, so a cleaned area can be contaminated again and moving dirt never counts as vacuuming. Dirt remains inside case walls; surface dirt on extracted parts stays on the service tray. Saved dust snapshots preserve this distribution. Automatic threshold shake-off is removed; stopping suction never erases dust on a timeout. The trial's 95% quality threshold remains provisional. Fan-powered redistribution is still queued.

The desk clamp can be right-dragged, with its entire footprint outside the PC and bin. Empty-hand left-click releases parked hose; current clamp pose is used for hose reach and rendering. Placement is session-local. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## 23. Physical pickup and explicit parts mode — correction 0.17.1

Picking up a resting tool with left press begins the same held stroke; the player does not need to release and click again before it works. This includes picking cloth/syringe from the rack and moving onto the CPU. Left release still stops work. Move parts (3) gives component dragging priority over resting tools, so a tool over a GPU/cooler does not prevent disassembly. Explicit mode choices remain respected. This corrects input handling, not the dust/paste rules. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## 24. Trapped-dust feedback and bench handling — trial 0.18.0

Hidden dirt shows representative chains protruding at component edges plus a trapped count. Precise suction on a tail, outside the housing, slowly pulls actual dirt free; cleaning the covered center remains blocked. Removing the component is easier, and the risky pick remains an alternative. The brush cannot erase trapped dirt. Tail indication is derived from saved physical dirt and disappears after extraction, without adding dust mass.

Clamp left/right drag is available outside the PC; stationary left click unclips. Its full footprint and occupied reach restrictions remain. The standard hose (560 px, provisional) is calibrated to just reach the far-left case corner with careful rotation/routing. Longer-hose upgrade (760 px) retains its benefit. Replacement stock is below the desk, clear of the fixture.

During cooler mounting, start parks tools and put-down remains possible before locking the lever, including after time expires. Put-down never secures the cooler or grants a grade. Cooler art/animation improvements are discussion proposals in DESIGN_PROPOSALS section 6, with current rules retained. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## 20. Bench feedback and sound — 0.19.0
CONFIRMED: current cooler iteration prioritises interaction design, button organisation and pressure/release/lever feedback, not artwork. A replacement pressure puzzle and lever gesture are not yet selected. Existing pressure simulation, physical lever and Complete repaste stay. Leaving an unfinished mount cancels it, without grading.

IMPLEMENTED: cleaning tool row and maintenance row; permanent bin state with explicit Empty bin; thermal material/tool row followed by mount/complete. A full bin pauses suction by design. Hose crossing recovery prevents persistent loop artefacts in tested rapid drags and clamp transitions.

CONFIRMED/IMPLEMENTED foundation: pickup, impacts, vacuuming, brushing, wiping, dispensing, pressing, lever and UI actions emit silent audio events. Six buses and managed per-owner loops prepare later sound work; no audio assets/playback exist. See AUDIO_DESIGN.md. Future samples, mix, tonal palette and exact feedback tuning are PROPOSALS. Critical state must stay visible and sound must not expose secret scam or diagnosis data.


Latest merged: **0.31.0 salvage variety** — fresh random pile per arrival, fourteen collectible kinds,
heavy obstacles (docs/SALVAGE_VARIETY.md, D113). Codex (GPT 6.1 Sol, model id gpt-6.1-sol), 15 November 2026.

## General storage rack — trial 0.29.0, 14 November 2026
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

The user approved a general inventory occupied by PCs, owned tools and parts, shown as a rack
and expandable with more furniture. The first implementation is `scenes/storage.tscn`, available
from the start menu's **Storage rack** button. Steel racks, shallow parts cabinets and tool boards
provide distinct grid capacity. Drag, rotate, move between shelves/furniture and add units; invalid
drops return safely. A visible waiting area retains everything that cannot fit.

The rack reads current player stock, the included five-tool kit and the one active customer PC.
It stores only furniture and allocations in `user://nightshift_storage.json`; ownership stays in
GameState. Installed shop parts retain marked shelf reservations; a whole customer PC includes
its fitted customer parts. No duplication or ownership transfer occurs by moving a tile.

Prototype choices, not final balance: furniture is free, at most eight units, example shelf sizes
and storage footprints. Furniture/layout survives New game independently of demo progress.
This is not the final shared-PC/owned-part model: multiple waiting PCs, owned built PCs and a
purchasable tool catalogue need canonical source records first. The current old hardware drawer
and buying/intake capacity checks are unchanged. The rack enforces its own allocation space and
shows overflow, but does not yet reject purchases, intake or salvage on capacity grounds.

Claude owns current concurrent engineering work. No changes to bench_view.gd, tool_rig.gd,
game_state.gd, shop_view.gd or WORK_PLAN.md in this delivery. Coordinate capacity hooks after
review; do not merge automatically. Contract, file map and playtest steps: docs/STORAGE.md.


## Night workshop and three-shelf rack — trial 0.30.0
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
14 November 2026, Europe/Bucharest. User-approved follow-up to the unmerged 0.29.0 rack.

New Game → Activities: Workshop, Salvage dump, Storage rack and a disabled future-activity space.
Salvage moves out of the initial menu. Workshop groups customer-PC selection, repair bench,
hardware stock sandbox and Final Check. New games have two actual repair tickets using the existing
customers, with separate dirty PCs and per-PC repair progress. Existing saves migrate only their
actual current ticket; they do not gain fictional client PCs. Every rack now has a third shelf.

A ticket does not imply a customer PC: the manifest explicitly stores an optional physical PC ID;
build orders without supplied hardware occupy no PC space. Night checks only diagnose boot/heat/
parts and owned game tests. They do not pay, complete jobs, advance customer rotation or record a
pickup. Switch PCs whenever desired. A good paste mount commits through the cooler lever, without
another completion button; existing thermal-paste costs/scam recording remain. Physical paste fields
also survive leaving the bench, alongside each PC's dust, removed parts, damage and replacements.

The daytime pickup/shop screen is future work. Hardware bench still manipulates SHOP STOCK, not a
full customer assembly model. Salvage time/cargo still belongs to its isolated prototype. No shared
campaign clock, shop economy or full owned-PC/part schema is claimed here. A temporary NightSession
bridge stores inactive jobs and references the active GameState.job; it does not clone stock or money.
Main-save active markers and a versioned sidecar allow interrupted-switch recovery; see NIGHT_WORKSHOP.md.
No edits to Claude's hot files or WORK_PLAN.md. This delivery is stacked on the rack branch; both PRs
must stay unmerged until reviewed. Claude goes next on shared-state integration review.


## Storage room — local trial 0.33.0
Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026, Europe/Bucharest.
The user replaces rack-selector buttons with direct room furniture. A 4×2 floor grid holds up to
eight units. All units coexist on one clipped room canvas; zoom/pan and Fit furniture/Entire room
replace paging. Drag furniture by its title bar to another free bay; its contents stay with it.
Parts still pack into each unit's shelves, with rotation, reservations, overflow and safe cancellation.

This removes the signal-emitter deletion path behind B16. The add-furniture popup uses proper
margin/VBox layout, fixing overlapping choices (B20). Native viewport mouse events now exercise
sort/save/add/model selection and repeated room selections in tests. No claim of universal crash
freedom or graphical playtest: the tested flows pass without script/locked-object errors.

Storage layout version 2 stores unit room_cell in addition to unchanged shelf allocations. Version 1
assigns distinct room bays on load; duplicate/malformed/out-of-range cells are rehomed safely. Item
ownership remains in the canonical GameState projection. Furniture remains free prototype tuning;
no room purchase/expansion economy or shared capacity hook introduced. Full controls: STORAGE_ROOM.md.

Main 0.32.0 already integrates the prior PRs. Earlier pending/independent-branch notes below are
historical. Review of Claude PR #39: canonical CPU/part-state fixes retained; night ticket overflow
B19 remains open with measured evidence, reported to Claude. Code is local; no pushes or merges.


## Bench feel — trial 0.34.0
Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026, Europe/Bucharest.
Room 0.33.0 is published and merged (PR #40, user authorized). This new review branch keeps that
room and adds requested feel fixes. Spool winds in deployed hose instead of restoring a full coil;
idle hose stays short, and pulling the nozzle/hose/clipped moving clamp feeds out only needed length,
up to base/upgrade capacity. Spooling releases a held rope point and removes the clamp constraint.

Repair benches (legacy and night) start with Brush, key 1. Vacuum is key 2; Parts 3 and Pick 4 stay.
Internal physics slots remain vacuum=0/brush=1. Tool highlights explicitly follow actual selection,
including hotkeys and refused hand-state transitions. Heavy concrete/appliances retain dynamic mass
and cannot be packed; lower mass/friction and strong damping allow controlled nudging without flight.
All weight/force/length tuning is provisional. Deployed hose length remains local to a bench instance,
like existing tool poses; cross-scene tool arrangement persistence is later engineering work.

No shared save/ownership changes. User-requested narrow edits touch ToolRig spool and BenchView
initial-tool/keys/labels/highlights; no competing bench PR was open. Hand-state rules are unchanged.
Claude cross-reviews next; the new feel changes are not automatically merged with the approved room.


## 0.35.0 — Wave 2 first playable monitor slice

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
User approved starting Wave 2 after cloth and power fixes. New repair tickets and saves lacking
an explicit switch begin powered OFF; an explicit saved on/off value remains respected. Repair
bench initializes fans still when off. Power is per customer PC; live boot/game/thermal tests
require switching on. Cleaning/repasting do not require power. Legacy final check now also
respects the power flag, while its historical one-time payment behavior remains unchanged.

Workshop → Diagnostic monitor offers boot, non-paying final/thermal report, Vapor purchase and
Counter Stroke 2 simulated FPS using existing Wave 1 rules and shop-owned licences. Customer
complaint, uses and collection request remain visible in a bounded sidebar. Reports clear on
power-down; no money/trust/pickup/completion side effect except explicit game purchases.
Anti-virus and overclocker are labeled upcoming; neither runs a pretend scan nor alters hardware.
Their exact mechanics, later campaign time and master-PC requirements remain future design work.
Cloth pickup follows rendered skew/rotation with a one-pixel inset; wiping reach is 35 world
pixels rather than 36 (not one whole 8px paste cell). See SOFTWARE_WAVE_2.md for limits.


## 0.36.0 — Physical room selection and common night exit

User requested room-based workshop selection: Activity Workshop now enters the room. Drag a real
customer PC into its workshop slot to select/open that PC. The old PC dropdown is removed. The
active PC's rack footprint is retained as a marked reservation; the slot references the same
GameState/NightSession record, with no clone or new ownership/save schema. Parts, tools, build
orders with no PC, stale IDs and protected manifests cannot act as customer PCs. Selection and
exits preserve repair progress. Existing hardware bench still operates shop stock (not a second
copy of the selected customer's installed hardware). Shared PC-model integration remains future work.

Activities uses one top-right control on room, service hub, repair, hardware, diagnostic monitor
and salvage. Duplicate title/activity Storage shortcuts are removed. Ticket details in the service
hub are now scrolled/bounded. The uploaded recording displays v0.32.0 and the removed rack-list
implementation; fresh v0.36.0 installation instructions avoid confusing project copies. No universal
crash-freedom claim: real native input regression tests cover the reported sequence and navigation.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.


## 0.37.0 — Thermal controls and bin retraction

User approved: distinct teal Cleaning / purple Thermal tabs; remove redundant cloth/syringe
button in favor of physical tools. Mount cooler moves below the socket, visible only after
paste is present and before mounting/graded completion. This does not force a good-size blob:
poor paste work remains possible. The lever still locks/grades; mounting never auto-completes.
One material menu offers normal thermal paste, super-paste and toothpaste. Wipe/reset a layer
before changing material. Super-paste is honest, uses normal flow/contact rules with a subtle
blue-purple tint, and improves cooling at equal grade. Trial numbers: $6 and −4°C versus normal
$3/0°C and toothpaste free/+14°C. Both thermal reports and saved/per-PC physical fields honor it.
The reel is inside the vacuum bin: RETRACT on the bin replaces the separate spool. It does not
empty the bin; hose stays shortened until pulled. No new campaign system or save-shape change.
Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 15 November 2026.
