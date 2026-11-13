# Nightshift — dust and paste minigame rules

Design specification revision 1 · 13 November 2026 · docs patch 0.15.2.

**Author:** Codex (GPT-6, model id not exposed by this session), ChatGPT Work. Exact deployment id unavailable; do not invent one. See D51 disclosure in the changelog.

**Status:** the user accepted scam concepts A/B/D/E/F/G/H, excluded C, requested matching minigame rules and information about promises. This file specifies intended behaviour; the gameplay baseline is still 0.15.1. Detailed UI layout, limited-service menu, thresholds, prices, delays and consequences below remain proposals where labelled. Do not report them as coded features.

## 1. One shared rule: agreement, actual work and completion claim differ

- **Agreement:** what the customer accepted, including work, quoted parts/material, price and collection date.
- **Actual work:** what was physically cleaned, fitted or applied, including damage and unperformed work.
- **Claim:** what the player says was done when handing back the PC.
- **Functional result:** what the machine can actually do, including temperature/stability and required assembly.

Honest work matches the agreement or a customer-approved revision. A disclosed cheaper part or limited service is not a scam. A false full-clean claim, concealed substitution or false fault attribution can be a scam even when today's functional check passes.

A quality grade describes physical workmanship, not honesty: perfectly spread toothpaste is still toothpaste. A customer does not automatically know private measurements or scam flags.

## 2. Player-visible work order — required design

The player must be able to see what they promised without remembering an earlier conversation. Make the work order available from cleaning, paste, parts handling, diagnosis and handoff, and preserve it across save/reopen and scene changes.

### Agreement information

| Show to the player | Why |
| --- | --- |
| Ticket/customer/PC identity and the reported symptom | Avoid working against the wrong machine or complaint |
| Promised services and explicit inclusions/exclusions | Show whether this job requires full internal cleaning, selected cleaning, fresh paste or another agreed action |
| Agreed replacement category/specification and new/used condition, if agreed | Makes equivalent, budget and used substitutions understandable |
| Promised paste material, if specified | Distinguishes proper repaste from the toothpaste shortcut |
| Agreed price, authorised spending ceiling and any approval needed for extra work | The spending ceiling is not the persona's hidden true budget |
| Promised collection day and agreed deadline revisions | Keeps daytime promises visible during night work |
| Removed-part return/disposal agreement | Preserves D19 ownership |

Unknown terms show **Not agreed** or **Not inspected**. Never invent a customer's promise from whichever part/material the player happens to install. Never reveal the customer's hidden true budget through this card.

### Private work information

Alongside the agreement, the player can inspect the actual cleaning coverage, installed items/condition, chosen material, work status and functional check. Important mismatches should be readable: for example, **Promised: fresh thermal paste / Actual syringe: toothpaste**. This is player information, not information automatically sent to the customer.

**Proposed presentation:** a compact persistent “Promised work” strip with a detail drawer. Keep the accepted agreement visually separate from “Actual work” and the editable completion claim. This avoids a large panel covering the PC or an extra confirmation after every brush stroke.

**Revision rule proposed for implementation:** changing the accepted scope, price, parts or date requires customer approval and saves a revised agreement. A dishonest completion claim may be edited; it must not rewrite the original agreement. This stores transaction history, not an NPC evidence-collection system.

## 3. Dust: actual cleaning and promised depth

### Physical rules retained

1. The brush loosens, tosses and chips dust; **only the vacuum removes dust** (D45). Hidden/relocated dust never becomes credited as removed.
2. Cosmetic motes are separate from real dirt/progress. Do not make players chase cosmetic particles.
3. Installed components block access to protected dirt. Removing the cooler/GPU is the safe access path; the pick remains the quicker risky path.
4. The hose/bin, area boundaries, gentle collisions and harder clogged filter remain. Rejecting scam C does not remove ordinary filter cleaning or its difficulty.
5. Tools/parts stay within their assigned areas; moving a component does not transfer ownership. Pick damage persists until properly resolved.

### Service completion rule

A global “all zones95% clean” requirement on every returned PC would make accepted scam B impossible. The intended design therefore separates **full-clean quality**, **functional testing** and **the player's claim**.

- For an honestly completed full internal clean, all promised zones meet the full-clean standard. Keep95% as the existing trial example until balanced; do not approve it as a release constant.
- A genuinely agreed limited service only promises its listed work. The exact limited-service names/zone lists are still proposals, not a selected final menu.
- A player may deliberately leave hidden dirt and claim the full clean was done. Save the actual dirty zones and a false-service flag at handoff; do not set their progress to100%, grant an honest full-clean grade or erase dirt to make the lie possible.
- Functional readiness still matters. Missing/broken parts or unacceptable functional results are not repaired by an invoice claim. Future rules must say what the actual promised functional test measures.
- Cosmetic or contract non-compliance must not itself trigger omniscient customer detection. D18 still uses persona-based probability for the first version.
- No filter-specific face-lift scam, special edge-cleaning bonus or filter scam flag is added: **C is excluded**. Ordinary promised filter work may be done honestly; general B must not disguise C as a separate mechanic.

**Current code difference:** 0.15.1 still requires its all-zones cleanliness gate for completion/payment. Changing that belongs in a later gameplay feature, not this docs patch. Preserve actual dirt and physical safety checks when it is changed.

## 4. Paste: workmanship, material and truthfulness

### Honest route retained

1. Follow the work order: a repaste should only be compulsory when promised or physically necessary after authorised cooler work. Trial0.15.1's fixed ticket still requires it.
2. Wipe old material where necessary, choose the promised material, squeeze it onto the CPU and mount/press the cooler.
3. Inspect coverage/overflow, then **physically click the retention lever**. No Secure button, Enter shortcut or automatic lock on timeout (D57).
4. For a newly applied acceptable material/result, use **Complete repaste**. D52's good-result gate remains; the trial currently accepts PERFECT/GOOD ENOUGH.
5. Record completion/material/cost once. A repeat click cannot charge, pay or duplicate anything. Wiping/replacing before delivery invalidates the old completion and re-evaluates the final work.

### Accepted dishonest routes

- **A — Toothpaste:** use the same syringe, pressure activity and lever. It may pass today's test but does not become real thermal paste because coverage is good. Record the final delivered material/claim mismatch for delayed consequences. Current free toothpaste/+14C and proper paste$3 remain trial tuning.
- **G — Old paste billed as fresh:** add residual old-material state and a reseating path before implementing this. Reusing old material does not create fresh-paste completion or a fresh-paste quality grade. The player can falsely claim a new repaste at handoff while actual material remains old; functional behaviour must be modelled honestly.
- **F — Concealed pick damage:** the repair still needs a working component; charging the customer as if it were the original fault is the lie. Disclosing an accident and correcting it at the player's cost remains an honest route.

D/E/H interact with parts and billing: a cheaper specification, used-as-new item or unnecessary replacement must retain its actual identity, condition and ownership. These are approved concepts, not reasons to invent unsupported new/used or diagnosis fields in the current code.

Do not mix toothpaste and proper paste without a separately approved mixing rule. Do not erase a delivered scam when the customer later receives a redo: close its physical problem, but retain the delivered-job history and any already resolved social effect.

## 5. Verification, reporting and handoff

**Intended sequence:** perform work -> functional check -> state completed work/hand back PC. The quality of an action, machine readiness and truthfulness of the claim are separate outcomes; avoid three redundant “success” buttons for the same action.

- An honest claim must match the final work and agreement.
- A dishonest claim must be possible for approved scams; the customer is not omniscient.
- The player must see deviations before committing to handoff. Showing them is information, not an extra permission dialog for every interaction.
- Only delivered work creates customer discovery risk. Toothpaste tried then wiped away before handoff does not create that delivered scam.
- Archive the final agreement, actual work, claim, price and scam IDs once, outside the replaceable active practice ticket.
- Read that archived record to schedule a delayed issue/complaint and one persona-based discovery event. Refunds, redos, relationship changes and reputation effects apply once and survive reload.
- In the eventual day/night loop, the real delivery event is customer collection. A trial final-check payout may stand in for delivery only if labelled as such; checking a machine is not inherently delivery.

Exact delays, odds, redo/refund alternatives and social penalties remain proposals in SCAM_DESIGN_PROPOSAL.md. This document does not silently approve every example number or require an evidence system.

## 6. What is still needed to finish these minigames?

“Core minigame complete” and “all seven scam systems complete” are different milestones. Complete the first coherent work-order/bench/handoff/one-consequence loop before implementing every later scam, market and campaign system.

| Priority | Remaining work | Completion test |
| --- | --- | --- |
| 1 | Your human acceptance test of0.15.1 | Complete proper-paste and toothpaste paths; use lever, hose/bin and rotated tools; save/reopen; no unclear control or input loss |
| 2 | Persistent work order and promise information | The same agreement is visible in cleaning, paste and handoff after save/reopen; agreed spending cap does not reveal hidden budget |
| 3 | Separate functional result, actual work and claim | Honest full work, honest agreed limited work and dishonest visible-only work can each finish with the correct distinct records; dirty zones never get false cleaning credit |
| 4 | One delivered-job consequence loop | Toothpaste can produce one delayed complaint; proper work does not receive a fraud flag; redo/refund/refuse and saved outcomes never duplicate |
| 5 | Robust progress/ownership/economy | No lost parts or double payout/charge; delivered records survive a new practice ticket; material, lever/completion state and cleaning resume clearly |
| 6 | Readability and pacing | Players understand remaining promised work, tool limits, dirty-versus-cosmetic dust and current material; cleaning and pressing are enjoyable without excessive repetition |
| 7 | Accepted later material/part/diagnosis extensions | Old-paste reuse has real residual state; used-as-new has condition/provenance; budget/fault claims have an agreement to compare against; original parts remain customer-owned |

**Must resolve for implementation:** the limited-service zone list; functional acceptance conditions per service; how quote revisions are approved; what a redo/refund costs; complaint delay and probability tuning. These are narrower decisions, not a reason to reopen the seven accepted concepts.

**Useful polish proposals:** brief material/tool sound cues, clear lever hover/lock feedback, gentle dust-bin-full feedback and accessible non-audio cues. Add them after a player can follow the whole route.

**Not prerequisites for core dust/paste completion:** the full shop campaign, release catalogue, liquid-cooling tube simulation, general airflow engineering, a new evidence system or new filter scam C. D56's fan-driven dust redistribution remains queued, not approved by this update and not silently cancelled; decide whether it improves this loop before scheduling it as mandatory bench work.

## 7. First implementation scopes (not code in0.15.2)

- **Agreement/work order:** GameState, shop/bench views, shared PC/ticket persistence and schema/regression tests. Keep UI presentation separate from agreement rules. Add service/claim data through the data/rules layers.
- **Dust completion split:** GameState final-check/handback policy and cleaning renderer feedback; keep DustSim/BrushShape's approved vacuum-only removal intact. Existing95% tests must remain for a true full-clean grade, rather than simply deleting coverage tests.
- **Paste consistency:** GameState.complete_repaste, paste/material contracts, mount session, paste renderer and bench coordinator. Preserve lever and good-result completion. Old-paste support is a later distinct state/model task.
- **Consequences:** a small rule processor plus archived delivery/customer/shop state, using SaveStore; do not place discovery rules inside renderers or require a full day/night implementation just to test one comeback.

Add exact files/new modules to DEVELOPMENT.md when each later feature is scoped. Test both honest and dishonest flows; do not claim “approved design” means “implemented”.


## Implementation update 0.17.0 — dust state/travel and movable clamp

The user approved brush-driven cross-case transport and a movable clamp outside the PC. Dust can now settle in another area or trap under GPU/cooler and in the filter, with conserved physical mass and saved positions/looseness. The new Case interior row tracks scattered dirt; previously cleaned areas can become dirty again. No automatic quality-threshold shake-off deletes remaining dirt, and a stopped vacuum does not delete loose dirt on a timer. These changes do not implement promises, false handoff claims or consequences. D56 fan transport remains queued.

Clamp controls: right-drag moves the fixture, with its full footprint outside PC/bin and inside desk bounds. Empty-hand left-click unclips. Occupied-hose reach is respected; fixture position remains session-local. Initial/reopened/reset tool response is tested in Godot; human acceptance of the user's original first-entry symptom remains necessary. Signed: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.
