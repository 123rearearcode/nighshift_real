# Nightshift — Roadmap

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


Current 0.27.0 physics trial — Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
User requested trying a 2D side-view dumpster with real physics (D103). F5 → Salvage demo now uses
native gravity, inter-object collisions, supporting stacks/collapse, bounded spring pulling and open
containers with physical contents. Pull objects over the rim before trunk packing. This supersedes the
0.26.0 top-down overlap/nudge movement; whether the format is fun still needs the user's playtest.
Session-only cargo/time/site rules and campaign isolation remain. Bench/customer/shared saves are
unchanged. Exact physics/performance evidence and limitations are in the newest CHANGELOG entry.

Current 0.26.0 update — Codex (GPT 6.1 Sol, model id gpt-6.1-sol), ChatGPT Work, 14 November 2026.
F5 → Salvage demo opens the separate playable dumpster slice: car/site selection, physical searching,
opening/stripping, effort/travel time, sorting, trunk packing and periodically refreshed piles.
Two test cars/sites; all values are tuning. Progress lasts only within the running app; return/menu and
revisits preserve it, app exit/Reset does not. No shared campaign clock/save/inventory/customer changes.
Claude's merged 0.25.0 customer work is preserved. Shared adapters/whole-PC identity precede campaign
integration. Design and proposed contracts: SALVAGE_DESIGN_PROPOSAL.md (D98–D102). Unmerged design PR #31
is superseded by this reconciled delivery. Older baseline paragraphs below are historical snapshots.

Version 1.15 · 14 November 2026

## Position after 0.19.0

Current slice is feedback and reliability: full-bin visibility/emptying, hose loop recovery, grouped controls and silent sound infrastructure. Human acceptance: fill the bin, switch tools, empty and resume; rapidly move/rotate the nozzle with and without clamping; inspect tool/thermal rows. Automated checks are in CHANGELOG.

Next cooler design decision: make pressure buildup, release and deliberate lever securing readable without adding art now. Decide the pressure gesture and inspection flow before replacing the existing rules. Sound work can proceed separately: choose sonic palette, then approve a small original/licensed sample set and implement a playback adapter. No sounds in this release. Preserve the larger promise/work/claim/consequence milestone below; this does not complete the campaign.

## Position after 0.18.0

0.17.1 was human-tested and accepted by the user. Next acceptance: visible threads under GPU/cooler, slow tail suction versus safe disassembly, clamp left drag/click, standard hose reaching the far-left corner with rotation, and putting tools down while pressing/waiting for the lever. An owned longer-hose upgrade intentionally retains extra reach.

Discuss/select cooler presentation before implementation: physical cooler body, compression/contact shadows, cutaway paste view and lever/inspection feedback (DESIGN_PROPOSALS section 6). These do not yet change the pressure rules. Then continue the established promise/claim/consequence slice.

## Position after 0.17.1

The recorded put-down/pickup failure and overlapping-tool component selection are reproduced and fixed. Next human acceptance: put the vacuum/brush down, pick it up with left hold and keep using it; use Move parts (3) to remove, clean under and refit GPU/cooler when tools overlap them. Continue the existing promise/work/claim/one-consequence sequence after acceptance.

## Position after 0.17.0

The user-requested dust transport and movable clamp are implemented. Next human acceptance: try both tools immediately after opening an existing save, then after New dirty PC; inspect brighter loosening, scattered case dirt, GPU/filter capture and moving an occupied clamp outside the PC. Reopen after scattering and verify position/progress. If the user's first-entry stall remains, preserve that save for reproduction.

After acceptance, continue promise/work/claim/handoff/one-consequence design sequence below. This does not complete the shop campaign or enable fan-driven dust movement.

## Position after 0.16.0

The requested start/menu and hose refinement are implemented and covered by headless checks. Next human test: New/Load/main-menu flow, hose routing at cooler corners, brush/other tool pickup over hose, clamp/release and taut-hose reach. Achievements remains a placeholder. No new scam/campaign systems were added.

After acceptance, continue the promises/work/claim/one-consequence sequence below. Its previous 0.15.2 gameplay baseline note is historical; the ordering still applies. No release date/completion percentage is inferred from these changes.

## Current position

Documentation patch 0.15.2 records approvals on the unchanged gameplay baseline 0.15.1. The bench is a substantial trial, not a complete shop game. Seven scam concepts are accepted, C is rejected, and the next connected slice needs visible promises, separate actual work/claims and consequences. No completion percentage or release date is justified yet.

## Immediate sequence and exit gates

| Order | Work | Exit condition |
| --- | --- | --- |
| 1 | Human acceptance of the 0.15.1 physical bench | Honest paste and toothpaste paths, dust tools, lever, save/reopen are understandable and enjoyable |
| 2 | Persistent customer agreement and work-order display | Promises stay visible across views/reload; hidden real budget stays private |
| 3 | Separate quality/function/claim/handoff | Honest and dishonest cleaning remain physically distinct; no false dirt credit or broken-part bypass |
| 4 | Archive delivery and one toothpaste consequence | Delayed complaint and chosen remedy happen once, survive a new ticket/reload and affect the correct social records |
| 5 | Review pacing, ownership and economy | No lost customer parts, duplicate charges/payouts or unclear remaining work; see MINIGAME_RULES section 6 |
| 6 | Expand the shop cycle and remaining accepted scams in bounded tasks | Quotes/diagnosis/condition/residual paste exist before their dependent scams; preserve the broader milestones below |

This sequence is an implementation recommendation, not a claim that its code exists or that its example consequence balance is approved. D56 fan redistribution stays queued. Finish the core bench loop before requiring every accepted scam or full airflow simulation.

## Milestones and exit conditions
| Stage | Work | Exit condition |
| --- | --- | --- |
| A — Design foundation (current) | Consolidate decisions, define first complete day, resolve essential timing/economy ambiguities, choose production path | Explain the complete daily cycle and its state transitions without conflicting rules |
| B — Production foundation | Organise source/data, save/load, desktop build, settings; evaluate current web path against a small Godot experiment before migration | Reliable desktop session can save/reopen; parts can be added through data |
| C — Complete shop cycle | Day visitors, agreements, collections; night work; suppliers, storage, complete building, benchmark, sale, progression | Several connected days work, including one assembled and sold PC |
| D — Polished sample | Tutorial, clear feedback, representative jobs, art/audio direction, usable salvage sample | Fresh players independently understand and enjoy a 20–30 minute target session; measure rather than assume |
| E — Release content/progression | Dozens of models per major category, customer lore, dynamic markets/relationships, B2B opportunities and meaningful later challenges | Early/mid/late play offer different decisions; content and economy tested |
| F — Steam preparation | Windows packaging, persistence/performance QA, access/readability, store page/trailer, licensing and AI-content records, Steam onboarding/build review | Tested releasable build and truthful store materials; current Steam requirements verified |

Godot/GDScript is the active trial path; a complete production migration is not finished. The trial now contains shaped-board dragging, cleaning, paste and partial persistence. Verify and stabilise those before broadening scope. Preserve the browser prototype as historical reference.

## Proposed tutorial + five ordinary days
These are test scenarios and teaching goals, not guaranteed encounters, approved characters or final prices.

| Day | Scenario | Decision / learning |
| --- | --- | --- |
| Tutorial / 1 | Open shop; recurring customer has an overheating PC; inspect, quote, promise next-day collection; optional used-part seller; close, diagnose, clean/repaste and verify | Learn the day/night loop, pause and promises using available tools |
| 2 | First collection/payment, another repair, supplier browsing | Stock purchase versus cash reserve |
| 3 | Discounted bundle offered while customer PCs occupy storage | Bargain versus storage and backlog |
| 4 | Build a basic PC; optional dump trip | Repairs versus salvage versus assembly |
| 5 | List a build online and handle an offer/question; recurring visitor | Honest claims, asking price and possible deception |
| 6 | Overlapping commitments plus supplier opportunity | Decline jobs, negotiate dates, close early or work overtime |

Proposed safeguards: generous teaching time, explain pause, no mandatory supplier gamble, several viable hardware solutions. Failure-free tutorial beyond confirmed protection is not yet a settled rule.

## Minimum systems for this campaign test
Persistent day/money/inventory/jobs; opening and closing; individual visitor flow; intake notes and prices/deadlines; continuous night clock/manual pause/overtime; saved unfinished assemblies; small daily supplier market; customer-owned PC storage; complete building and power testing; basic asynchronous online sales; basic trust/closeness/reputation/history; one compact salvage minigame.

Use a small representative catalogue first; the final release catalogue requirement remains. Deception can initially use persona-based probability; bulk is a discount. Do not build advanced diagnostic software, loaners or full server systems as prerequisites.

## Next design questions in priority order
1. Night duration, action timing, fatigue/overtime formulas, and ending a night voluntarily.
2. Delivery/collection ordering at day boundaries; payment, deposit and diagnostic-fee policy.
3. Exact five-day protection boundary and personal-PC failure when the terminal is needed.
4. Whole-PC storage sizes and incomplete-build persistence.
5. Minimal power/stability benchmark and component data definitions.
6. Reputation/relationship update rules and persona/deception probabilities.
7. Small salvage minigame specification; supplier generation bounds that preserve viable supply.

Resolve only what the next milestone needs. Optional refinements remain open.

## Validation targets
- Players understand whom a machine belongs to and when it is due.
- No inventory duplication or sale of customer property through ordinary actions.
- Cash, stock and work progress survive closing/reopening.
- A player repairs a machine, assembles/tests a build and lists it for sale.
- Compatibility and spatial rejection explain the reason.
- Players can describe a meaningful trade-off between night activities.
- Customer/reputation consequences are legible.

## Release planning
Windows-first/offline is a recommended target, not an approved platform exclusion. Steam publication is confirmed. Pricing, marketing dates, SDK features, achievements/cloud, controller support and other platforms are undecided. Recheck official Steamworks requirements when scheduling; avoid copying stale fees/waiting periods into commitments.

## Current sequence — supersedes the old setup checklist
1. Reconcile documents and include all five in every handoff (0.7.2).
2. Run the existing checker, engine import and scene-start checks; record actual engine version.
3. Complete target-editor manual tests in STABILISATION.md: dragging, tool input, scene transitions, save/reload and payout.
4. Exact dust restore and saved-paste-grade invalidation are implemented in 0.8.0. Run the delivered regressions and user playtest before further expansion.
5. PC drawing was extracted to pc_renderer.gd in 0.8.0. Cleaning/paste UI and mount-session extraction remain future bounded refactors; do not rewrite everything at once.
6. Define shared PC/part state, then connect the hardware bench to it, including ownership and saved installation. This is a new feature/data-contract task, not part of the docs patch.
7. Resume the complete shop cycle and opening-campaign milestones. The user's catalogue work can proceed as data design without immediately implementing all models.

See STABILISATION.md for pass conditions and unresolved issues. Runtime smoke checks alone do not complete stabilisation.


## Immediate follow-up after 0.9.0
New scoped service-access layer is implemented and tested: GPU/cooler removal, hidden dust, tool blockers and refitting, with moderate vacuum and independent specks. User playtests the new pace/challenge. Next discuss physical representation (particle motion, collisions, depth and feedback) before a larger simulation rewrite. General inventory/assembly and persistent installed RAM remain separate tasks. Do not silently add vacuum progression purchases or catalogue entries during tuning.


## Immediate follow-up after 0.10.0
Risky pick plus bounded damage/replacement choices are implemented for the two service-removable components. Playtest whether safe disassembly versus risky quick access creates an interesting choice. Inspect risk, timing, budget prices and whether degradation is communicated clearly. Full part stock, compatibility, performance benchmarking, customer detection/disclosure, trust/reputation consequences and repair history belong to the shared persistent-PC/shop milestones; this trial does not complete them. Broader dust physics representation still needs discussion before a rewrite. Maintain the five documents and change log; do not auto-generate the user's catalogue.


## Free arrangement update — same 0.10.0 delivery
Also playtest the new hardware sandbox: free drawer placement, rotations and fit previews, spring pickup/settle, slot highlights and persistence. Next resolve whether to add click-to-carry, throw momentum, audio/haptics or more inventory surfaces after user feedback. General PC/stock ownership still needs shared state; do not treat the separate sandbox as connected repair inventory.


## Immediate follow-up after0.11.0
Playtest throws versus precise placement on hardware stock, then use/toss/recover all repair tools and service-removable pieces. Check the flexible brush's actual contact feel and the fresh/partial/clean ticket states. Verify inventory purchase->drawer->fit consumes exactly one item and customer originals never become player stock. Shared stock is implemented for the trial's bounded part kinds, not a complete shop inventory milestone. Next choose interaction refinements, body-to-body collision/audio/mass behaviours and general shared PC/owned storage; preserve prior diagnosis/economy/reputation roadmap. A complete target-editor human repair/payment walkthrough remains pending.

## Position after trial 0.15.0 (13 November 2026)
Written by Claude (Opus 5.5, model id claude-opus-5-5). The project lives in the user's GitHub repository with automated checks on Godot 4.7.2; versions 0.12–0.15 rebuilt the repair bench's feel (dust physics, hose and bin, piece collisions, tool turning) and finished the thermal paste flow (Complete repaste, toothpaste scam). Next, in order:
1. User playtest of 0.15.0: the paste game, Complete repaste and toothpaste.
2. Design pass on the scam direction (DESIGN.md section 19, D54) with a design agent; the user decides. Prompt: docs/DESIGN_AGENT_PROMPT.md.
3. Decide the dust minigame's extra purpose (D55).
4. Finish the bench part: whatever the user still finds missing, then queued items (fans moving dust, DESIGN_PROPOSALS.md section 5).
5. Only then expand scams into systems (discovery, consequences), followed by the shared persistent-PC and shop-cycle milestones above.

## Code-health plan and work split (13 November 2026)
Added by Claude (Opus 5.5, model id claude-opus-5-5). The user approved `docs/WORK_PLAN.md`: Codex owns design and gameplay features, Claude owns engineering and code health (tests/CI, measurement, constants, a hand-state machine for bench input, save gaps, the `bench_view.gd` split, a typed job, later exported-build checks). Gameplay milestones above keep their order; plan steps run alongside them under the plan's hot-file rules.



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
