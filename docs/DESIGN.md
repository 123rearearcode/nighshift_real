# Nightshift — Working Design

Version 1.11 · 13 November 2026

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

Entering the dump starts a dedicated minigame; choices determine whether and how much time it costs. Minigame rules are OPEN. Do not assume an unconditional entry fee or that the shop clock also runs during the minigame: that could double-charge time.

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
