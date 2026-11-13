# Nightshift — scam direction, dust purpose and updated project plan

**Design review, revision 2 · 13 November 2026 · gameplay baseline 0.15.1; documentation patch 0.15.2.**

**Approval update:** the user accepted scam concepts **A, B, D, E, F, G and H**, rejected **C (filter face-lift)**, and requested updated minigame rules plus clear information about customer promises. The seven concepts are approved design scope, not seven implemented systems. Numerical balance, exact delays/odds/remedies and unselected dust options remain PROPOSALS. No game code changes accompany this document. “Sand” means the existing dust activity.

**Companion specification:** `docs/MINIGAME_RULES.md` defines the intended dust/paste rules, the player-visible work order and the completion checklist. It supersedes earlier generic minigame descriptions where explicitly stated.

**Author:** Codex (GPT-6; exact model id is not exposed in this session), in ChatGPT Work. I cannot truthfully supply an exact deployment/model identifier. This disclosure does not satisfy D51's exact-id requirement; the integrator should retain it rather than invent an id or copy another model's signature.

## 1. Where the project actually is

The repair bench is a substantial playable foundation. The complete shop-management game is still ahead of it. “The bench is nearly finished” is a feature assessment, not a claim that the game is nearly ready for Steam.

### Implemented in the supplied source

| Area | Present now | Still missing or awaiting a decision |
| --- | --- | --- |
| Physical bench | Turning tools, bounded work areas, tabletop motion, rotated-box knocks, movable cooler/GPU, risky pick | Your acceptance of the latest feel; broader removable-part support |
| Dust | Brush loosens/tosses/chips; vacuum removes; persistent progress; protected dust; harder clogged filter | Promise-versus-work purpose now selected through B/D58–D60 but not coded; other twists and D56 fans remain queued |
| Dust management | Hose with length/tug, obstacle handling, manual repositioning, visible dust transit, fillable/emptyable bin, longer-hose upgrade | Final balancing and human testing |
| Repaste | Physical paste, pressing, retention lever, completion gate, paid proper paste, free toothpaste | Human playtest of 0.15.0/0.15.1; delayed degradation and consequences |
| Parts/storage | Shared owned sample stock, shaped grids, compatibility, budget replacements, customer-owned removed-part records | Full persistent PCs, all parts, complete assembly, release catalogue |
| Economy | Practice-ticket payout, a few purchases/upgrades, replacement consumption | Customers, quotes, deadlines, suppliers, online sales, running costs and night scheduling |
| Scams | Toothpaste is recorded; lower-spec substitutions are mechanically possible | A return/claims layer, reading scam records, complaints, discovery, refunds, relationships and reputation |
| Technical base | Save recovery, renderer/session extraction, schema/regression scripts, Actions workflow | Current summaries reconciled in docs patch 0.15.2; release builds/settings/QA are not finished |

**Verification:** I ran the supplied Python checker: PASS; 37 GDScript files, 121 resource references, 57 mapped files, five required core documents. This does not run Godot. The 0.15.1 changelog reports GitHub Actions on Godot 4.7.2: **179 schema checks and 442 regression checks**, zero failures. I did not independently open that live Actions run. You have not tested this uploaded version; automated checks cannot establish whether the lever, dust or tools feel good.

**History, as recorded:** 0.11.0 established shared stock and tactile handling; 0.11.1–0.11.3 added save recovery and bench separation; 0.12.x added brush/tool/paste fixes and CI; 0.13.0 added the toss-and-vacuum dust loop, hose and bin; 0.14.x added collisions, hose handling and rotation/input fixes; 0.15.0 added completion/toothpaste; 0.15.1 added the physical retention lever. These releases span 12–13 November; their speed is not a basis for forecasting the remaining game.

### Corrections to carry into the tracking documents

- Current baseline is **0.15.1**, not the older 0.15.0/0.11.0 paragraphs in CURRENT_STATE.md.
- Current repository is **123rearearcode/nighshift_real**. PROJECT_BRIEF.md still names the old repository and ZIP-only workflow.
- Safe saving, extracted renderers, collisions and CI are already implemented; older “missing” lists must not reopen those tasks.
- D45 supersedes any earlier description of the brush removing dust. Keep **vacuum-only removal**.
- D57 supersedes Secure/Enter/automatic securing. Keep the **retention lever**.
- The old browser prototype is a separate codebase; its features do not count as implemented Godot systems.
- Earlier requested heat/airflow and liquid-tube routing are not implemented in this ZIP. Keep them as requested backlog, separate from D56's dust-moving fan idea; confirm their priority rather than marking them completed or cancelled.

## 2. Accepted direction and implementation recommendation

Make the player choose **what to promise, what work to perform, and what to claim afterwards**. The hands-on action should remain the same whether the player is honest or cheating. A cheaper service honestly described is not a scam; a hidden substitution or a false claim is.

Start with consequences for the toothpaste already present. Then give cleaning different promised scopes. Avoid adding eight new minigames before the first customer can return with a complaint.

## 3. Seven accepted scam concepts (stable original letter IDs)

### A. Toothpaste instead of thermal paste — first priority

**Physical action:** select toothpaste, apply it with the existing syringe, press, lock the lever and complete the repaste. **Gain:** today it saves the $3 consumable charge; further value might be avoiding a stock shortage later. **Failure:** the material can become less effective after delivery, creating a comeback. **Discovery:** the customer notices overheating/noise, or says another repairer raised concerns; attribution is still a persona-based roll, not an inspection/evidence minigame.

**Build cost:** action/material/record already exist. Retuning current material values is data/config work; delayed symptoms, customer follow-up and discovery require a new consequences system. The $3 saving is small against a $60 practice payout: test whether this is a tempting option rather than assuming it is balanced.

### B. Visible-only clean sold as a full clean

**Physical action:** vacuum the easy visible surfaces, leave the protected zones dirty, refit everything and claim a complete internal clean. **Gain:** saves disassembly and cleaning time. **Failure:** the PC may still run hot or develop a repeat symptom. **Discovery:** a detail-conscious persona questions the job or returns after symptoms; expertise influences the chance of spotting the deception.

**Build cost:** existing tools/access geometry, but **new service-scope and claims rules**. Today every zone must pass the cleanliness gate, so this scam cannot simply be switched on through data. Do not make the hidden dust disappear or count as cleaned when it was merely concealed.

**Excluded C:** filter face-lift is rejected. Do not implement or reintroduce it as a separate filter scam. Normal filter cleaning, the harder clogged-filter mechanic (D50), and general visible-only cleaning B remain. B must not be used to smuggle C back in as a filter-specific shortcut.

### D. Budget replacement presented as the quoted original specification

**Physical action:** take the cheaper compatible GPU/cooler from owned stock and fit it, while returning an invoice that claims the better specification. **Gain:** retains the price difference or preserves better stock for another sale. **Failure:** lower performance or weaker cooling. **Discovery:** a performance-sensitive or knowledgeable customer questions the result; narrative examples explain the complaint without building a hardware-proof system.

**Build cost:** fitting, stock consumption and quality differences already exist. A **new quote/claim comparison and scam record** are needed. A disclosed budget repair must remain an honest, useful option. Do not automatically flag every budget part as fraud.

### E. Used part sold as new

**Physical action:** clean a player-owned reclaimed cooler/GPU and install it as the “new” part on the quote. **Gain:** charges for new stock while using a cheaper owned item. **Failure:** shorter life or another failure, if condition simulation is later added. **Discovery:** persona-based suspicion/complaint; visible wear is explanation, not a required evidence-collection system.

**Build cost:** **new condition/provenance and claim fields**, plus sources of used owned stock. The current small tier catalogue does not establish new-versus-used history. Do not use customer-owned removed parts as free stock.

### F. Pick damage blamed on the original fault

**Physical action:** use the risky pick, damage a component, fit a working replacement, and describe that replacement as necessary because of the original fault. **Gain:** shifts the cost of the player's mistake onto the customer. **Failure:** the customer disputes the extra charge or refuses the revised price. **Discovery:** a persona-based attribution roll at collection/comeback; no automatic NPC access to the private damage log.

**Build cost:** pick damage and replacements exist. **New attribution/disclosure, revised-quote and billing rules** are needed. The PC still needs a working replacement; this must not bypass the current broken/missing-part gates. Damaging a part accidentally is not itself fraud—concealing the cause and charging dishonestly is.

### G. Old paste retained, fresh repaste billed

**Physical action:** lift/reseat the cooler with residual old paste instead of using a new syringe charge, then claim fresh material. **Gain:** saves consumable cost and work. **Failure:** an unreliable thermal result. **Discovery:** later symptoms prompt the same persona-based process.

**Build cost:** **new residual-paste state and a reseat path**. Current cooler removal clears the paste result; old paste is not a persistent material layer. Do not implement this by silently granting a fresh GOOD ENOUGH grade. Defer until the toothpaste loop proves fun.

### H. Unnecessary but functional component replacement

**Physical action:** replace a working compatible GPU/cooler while presenting it as the cause of the repair. Return the original or hold it for the customer. **Gain:** an unnecessary parts sale and labour charge. **Failure:** the real fault remains unless it is separately repaired, or the customer resists the quote. **Discovery:** a knowledgeable persona disputes the claimed diagnosis.

**Build cost:** physical swaps partly exist; **new fault diagnosis, quote and claim systems** are required. This belongs after intake/diagnosis, not in the next bench patch.

**What is truly data-only today?** Only retuning the existing toothpaste material among these ideas. New scams can reuse existing gestures, but they still need records, claims or consequences. Adding another material also needs its selectable ID and save validation supported; calling that “only data” would hide work.

**Not recommended for this slice:** unauthorised sale of a customer's original part. D19 preserves their ownership. Any deliberate theft feature needs an explicitly approved gameplay exception and a clear stolen/customer-owned record, never an ordinary stock transfer that quietly changes the owner.

## 4. Discovery and consequences: a small first version

### Keep four different things separate

1. **Actual work/material:** what the player really did.
2. **Promise/claim:** what the customer was told or charged for.
3. **Physical problem:** whether the returned PC develops a symptom.
4. **Discovery:** whether this customer attributes a problem to deception.

A functional check passing today is not a guarantee of a good long-term repair. A customer having a problem does not automatically mean they know the player cheated. Honest budget work is not secretly placed in the fraud pool.

### Exactly what reads `job.scams`, and when

| Moment | Proposed reader/writer | Result |
| --- | --- | --- |
| During repaste | Existing `GameState.complete_repaste` writes the toothpaste flag; wiping clears it | No discovery roll while practising or before delivery |
| First paid completion / trial handoff | New completion-record step in GameState reads the final `job.scams` once | Archives ticket id, customer id/persona, actual material, charged work, payout and active scam flags |
| Starting another ticket | GameState preserves the completed record outside the active `job` | New dirty PC cannot erase the previous customer's pending comeback |
| First eligible simulated day | New follow-up processor reads the archived flags | Creates one persistent due symptom/complaint event, using its saved delay |
| Complaint/collection encounter | New customer-resolution step reads that event plus persona/deception modifiers | One saved discovery result and one response event |
| Resolution | Relationship/reputation updater reads the resolved outcome | Applies money, trust, closeness and reputation effects once |

In the current trial, first paid final-check completion can stand in for delivery. In the full game, move the same handoff hook to actual daytime collection; diagnostic checks must not count as customer delivery. Do not pay the job again when archiving or resolving a comeback.

Keep `job.scams` as its current list of string IDs initially. Store delays, refunds and resolution state beside the archived completion record, not by putting incompatible dictionaries into that list. The current save loader only accepts `toothpaste`; additional IDs require an explicit migration/validation update.

### Delay and persona-based chance

Schedule a toothpaste symptom after a saved example delay of **2–4 game days**; those values are proposals. Before then it may pass normally. At the eligible encounter, use a persona/knowledge-based chance adjusted by the approved deception modifier system—for illustration, 10% low knowledge, 30% ordinary, 60% expert. These are balancing examples, not selected rates or a real-world material model.

Keep physical deterioration and discovery separate. A missed discovery roll may leave an ordinary overheating complaint that the player can handle; it does not prove the material is good. Do not roll every frame, on every check, or whenever a save reloads. Save the due date, sampled outcome and resolved flag. Use one combined encounter per ticket when several scam flags are due, rather than repeated penalties for the same incident.

V1 has no evidence inventory, NPC proof chain, mandatory serial-number inspection or automatic comparison of private logs. “A friend noticed poor performance” can explain an event; it does not create a new evidence system. Describe risk qualitatively; whether exact odds are shown is a separate choice.

### Comebacks, money and relationships

On a comeback, offer a short choice: **redo the work at your cost**, **refund the affected service**, or **refuse**. Redo uses proper material/parts and bench time, with no new repair fee; refund is recorded against the original payment and cannot be collected twice. For v1, cap service refunds at that ticket's service charge; compensation for a damaged original component needs a separate later rule, not an invented unlimited debt.

**Trust:** falls when deception is discovered; grows gradually through reliable delivery and fair resolution. A corrected repair can repair some trust but does not erase the past.

**Closeness:** changes through how the player treats that person and their shared history. Being friendly does not make a cheated customer trust the repair, and a refund should not buy instant friendship.

**Shop reputation:** poor technical outcomes affect workmanship; broken promises affect reliability; misleading charges affect value. A public review is a possible event/persona response, not an automatic separate fine for every flag. Do not penalise all three reputation qualities for every small fault.

Keep the last ten meaningful customer events visible, with major facts retained after older entries leave the list (D15). One discovered incident may update the customer and shop, but it should have one readable summary explaining the combined result. Avoid a new universal morality meter.

### Fairness and exploits

- No scam event for toothpaste wiped off and replaced honestly before handoff.
- No discovery for private experimentation on an undelivered PC.
- No accusations generated from an honest budget quote.
- No disappearing complaint because the practice ticket was replaced.
- No extra payouts, repeat refunds or rerolls through reload/rechecking.
- An already discovered lie is not re-rolled by clicking Deny repeatedly.
- Generic hardware faults and customer deception can come later; do not initially punish honest players with unexplained random false accusations.

## 5. Keeping honest work worth doing

**Immediate value:** a correctly priced routine job must pay enough to cover proper paste, expected labour/time and ordinary stock use. Make the honest workflow pleasant and repeatable; do not turn every honest clean into compulsory microscopic polishing.

**Predictable value:** fewer comebacks protect tomorrow's night time and cash. A successful honest budget repair should be competitive with an expensive full service; the promise is what makes the difference.

**Long-term value:** trustworthy workmanship/reliability/value can attract repeat customers, larger orders and online buyers, eventually supporting the approved B2B direction. Closeness brings customer-specific flexibility and history; it is not a blanket discount or immunity from discovery.

**A real temptation:** scams can save scarce time or preserve scarce stock, not merely pennies. Example only: two quick dishonest jobs might fit into a night where one careful job fits, but a comeback can consume the following night's opportunity. Do not award identical guaranteed bonuses for every scam or require scams to progress.

**Repairing a mistake is different from fraud:** breaking a part, disclosing it and fixing it at your cost should preserve an honest route. A free correction may still hurt the wallet, but it should not automatically carry the same trust penalty as a deliberate lie.

## 6. Dust purpose after approval

These four options preserve D45: the brush moves/loosens dust and the vacuum removes it. None adds a separate sand game.

### Direction selected for the rules — match the service you promised

Offer a clearly described limited airway service and a more expensive full internal clean. The player decides how much dismantling and time the promised job deserves, or deliberately sells the shallow clean as the full one. A customer can notice visible dirt or later symptoms, while detection of hidden short-changing remains persona-based in v1.

### Other option, still proposed — contain the mess

Use the existing hose, bin and brush tossing to reward controlling where dust lands before vacuuming. The queued fan idea could later make careless brushing move dirt into awkward areas, but impose a limit so completed sections do not become an endless re-cleaning chore. This can support corner-cutting, but dust merely hidden elsewhere must never count as removed.

### Other option, still proposed — restore used stock before an honest sale

Cleaning player-owned reclaimed parts improves their presentation and possibly the sale recommendation; it never changes “used” into “new.” That turns cleaning into a choice about whether a salvage item is worth the night's work. It needs condition/provenance and sale systems, so it is a later connection rather than a quick bench tweak.

### Other option, still proposed — diagnose whether cleaning is enough

A before/after game test helps the player decide whether to clean, repaste or replace, rather than automatically doing everything on every machine. Some future jobs might be solved by clearing a clogged filter; others need further work. This makes dust useful to diagnosis, but requires varied faults and the technician-PC loop, so it should not hold up the first scam experiment.

**Recommendation:** choose Option 1 first, using Option 2's mechanics already present for texture. It connects manual skill, night time, pricing and deception without adding another activity. Keep cosmetic condition, functional performance and promised service as separate results.

**Intended rule update:** the accepted visible-only/full-clean scam B needs physical results to be separate from the customer's promised service and the player's claim. Keep a full-clean quality standard, but do not use an omniscient all-zones-clean completion gate to prevent a lie. Functional safety/readiness still requires working/refitted components and acceptable readings; concealed skipped work remains physically dirty and may trigger consequences. Honest limited cleaning, honestly described, is not fraud. The exact limited-service zones and numerical thresholds remain proposals. See MINIGAME_RULES.md; the current 0.15.1 code still has its old gate.

## 7. Smallest fun version for Claude to build later

First, you playtest 0.15.1 and implement the work-order/claim separation in MINIGAME_RULES.md. Then implement these **three bounded items**, each as its own feature change rather than calling gameplay work a docs-only 0.15.2 patch.

| Order | Small item | Existing files it would touch | New file/system proposed | Done when |
| --- | --- | --- | --- | --- |
| 1 | Persist a delivered-job record and one delayed toothpaste comeback | `scripts/state/game_state.gd`, `scripts/view/shop_view.gd`, `tools/test_regressions.gd`, `tools/test_data_schemas.gd`; update `DEVELOPMENT.md` | A small follow-up rule module under `scripts/rules/` | Two consecutive tickets retain the first outcome; advancing a practice day triggers the due complaint once; reload never rerolls or repays |
| 2 | Resolve that comeback: redo/refund/refuse, trust/closeness/reputation stub | `scripts/state/game_state.gd`, `scripts/view/shop_view.gd`, both test suites, `DEVELOPMENT.md` | A small customer-outcome rule module and saved customer/shop records | Proper redo consumes material without a new fee; refund happens once; the two relationship dimensions stay separate and the consequence is readable |
| 3 | One honest limited clean versus one falsely claimed full clean | `scripts/data/dust_zones.gd`, `scripts/state/game_state.gd`, `scripts/view/bench_view.gd`, `scripts/view/cleaning_renderer.gd`, `scripts/view/shop_view.gd`, both test suites, `DEVELOPMENT.md` | Minimal service-scope/claim data; reuse the follow-up system | An honest limited job and a deceptive superficial job have visibly different promises but the same physical tools; dirt is never credited as removed |

The existing `scripts/data/paste_materials.gd` supplies material properties; `scripts/bench/paste_sim.gd`, `scripts/bench/mount_session.gd` and `scripts/view/paste_renderer.gd` should not need a rewrite for items 1–2. Reuse `scripts/state/save_store.gd` for persistence; do not put customer logic into a renderer. Any new module name must be added to the file map. File lists are planning scopes, not permission to edit every listed file in this design task.

A temporary **Advance practice day** control may exercise delayed consequences before the campaign clock exists. Label it as a trial control; do not turn it into a replacement for the confirmed continuous night clock or untimed daytime flow.

Defer further paste variants, part theft, complex invoices, evidence collection and fan-driven redistribution until this slice produces a fun choice. Budget misrepresentation is the next low-gesture-cost scam after a quote/claims layer exists.

## 8. Updated timeline: work gates, not a promised launch date

| Gate | Work and order | Exit condition |
| --- | --- | --- |
| Now — human acceptance | Play 0.15.1: proper paste, toothpaste, lever, hose/bin, turning and save/reopen | You can finish both paste routes without guessing, get paid once, and report what still feels wrong |
| Next — one consequence loop | Set remaining delay/remedy details; build items 1–2 above | A delivered scam causes one legible delayed customer outcome; honest work remains profitable |
| Then — meaningful cleaning | Define exact service scopes/thresholds and build item 3 | Limited honest service versus dishonest full-clean claim is a meaningful physical/time choice |
| First complete shop cycle | Open/close, one-at-a-time visitors, intake quote/date, collections, continuous night/manual pause, unfinished-job persistence and ownership | One complete tutorial-like day plus following collection works without practice shortcuts |
| Build and sell a PC | Persistent full PC data, a small representative compatible catalogue, complete assembly, simple power/stability test, suppliers and one sales path | One PC is obtained/built/tested/sold with correct cash and ownership |
| Repeatable campaign | Several days, salvage, asynchronous online sales, generated suppliers/prices, relationships/reputation, customer memory and lore | Repairs/building/salvage compete for time; consequences matter across days |
| Release breadth and Steam | Dozens of models per major category, meaningful early/mid/late progression, B2B placement decision, art/audio/access/settings, release QA and Steam work | Representative players enjoy a complete build; content, saves, economics and release requirements are checked |

Do not assign a completion percentage from version numbers or test counts. A launch month is not defensible yet. After two or three measured integration/playtest cycles, estimate calendar time from actual throughput, review delays and your available hours. The next useful time unit is a small reviewed change followed by your playtest, not another dozen speculative systems.

### How the rest of the game can support the new direction

**Daytime:** the same quote and collection conversation can support an honest bargain or an exaggerated repair. Keep the known true budget hidden; computer knowledge and budget are separate persona qualities.

**Night:** prioritise commitments, stock and tools under the confirmed clock. Choosing a shortcut should free time the player can actually spend elsewhere; delays and comebacks reclaim that scarce resource later.

**Suppliers and salvage:** the player sometimes gets deceived too, and decides how to describe questionable stock to customers. Keep D25's bulk lots simple price reductions; do not add an inspection/evidence subsystem through this proposal.

**Online sales:** advertised specs/condition become the promise used by the same claim/outcome machinery. Reputation affects traffic and sales; do not create an unrelated second morality system for online customers.

**Relationships and endgame:** familiar customers remember incidents, while larger/B2B orders increase the cost of unreliable work. Let honest specialists and risky opportunists both have interesting decisions; detailed lore, characters and endgame events remain yours to define.

**Cooling/liquid routing:** preserve the earlier request in the backlog. Later, actual heat/airflow and routed tube quality could make a visibly impressive but poorly configured build a meaningful scam. Do not fake a completed airflow system now or make it a prerequisite for the first toothpaste complaint.

## 9. Remaining questions, most important first

1. Which areas must an honest **limited airway clean** cover? Proposed starting point: accessible fan/filter paths plus the customer's stated cooling/noise problem; the final zone list and thresholds are not yet approved. This is ordinary filter service, not rejected scam C.
2. On a comeback, should redo at your cost and refund be alternatives, and what should refusal cost? Exact trust/reputation/money effects remain open.
3. How soon should a toothpaste problem normally return, and should discovery risk be qualitative or numeric? Example odds/delays in this document are not approved balance.
4. Should the customer explicitly approve every paid scope/part/date change? Proposed: yes; the player can lie in the completion claim, but cannot silently rewrite the accepted agreement.
5. After the first complaint loop, should implementation prioritise the first complete shop day, or the remaining bench scams such as old-paste reuse? The seven accepted concepts do not all have to be built before testing the first slice.

## 10. Integration record — documentation patch 0.15.2

GitHub access is now working. The documentation work is based on main commit `c3dd9224f4a32d8fe04dcb5d07eb3e80c1877b93` (0.15.1), on branch `design/scam-direction`, for a pull request without merge. Gameplay scripts/scenes are unchanged. Version metadata changes to0.15.2 describe a documentation patch, not implemented minigame changes.

Read DESIGN.md sections19–20, DECISIONS.md D58–D60 and MINIGAME_RULES.md for the accepted-versus-proposed boundary. The exact deployment model id is not exposed; keep the truthful author disclosure, rather than borrowing another AI's id. The checker only checks that a signature contains “model id”, which is not proof of exact-id compliance.

**Next action:** human test the physical 0.15.1 bench, then implement the agreement/work-order contract and the first delayed toothpaste consequence. Do not implement C, an evidence system, or automatic ownership changes. Keep new balancing and unrelated dust options proposed.

**Sources:** supplied0.15.1 ZIP and handoff; live0.15.1 repository documents; earlier proposal; user's13 November approval excluding C and requiring promise information. Earlier reported CI results are historical, not a human acceptance claim. Check results for this documentation patch belong in CHANGELOG.md.
