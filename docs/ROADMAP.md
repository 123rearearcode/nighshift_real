# Nightshift — Roadmap

Version 1.9 · 13 November 2026

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
