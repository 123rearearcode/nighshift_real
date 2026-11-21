# Repair loop design: tickets, pickup, morning report, diagnosis (D134 to D139)

Recorded from a design conversation with the creative director (the user) on 16 November 2026.
Original design by Claude (Fable 5.2, model id claude-fable-5-2). **Implementation status varies by
section:** pickup/night end and hardware are shipped through 0.46.0; section 5 is the approved
diagnosis design, not an implementation claim. The original conversation said "no coding yet";
subsequent explicit assignments and the current HANDOFF/WORK_PLAN govern what happens next.
Diagnosis refinements and manual/work split recorded by Codex (GPT-6; exact deployment model id not
exposed by this session), ChatGPT Work, 18 November 2026, Europe/Bucharest (D150).

Status key used below:
- **DECIDED** = the user said this, in their words or by a direct yes.
- **PROPOSED** = Claude's suggestion from the same conversation; the user has not confirmed it.
- **OPEN** = to be discussed before coding.

## 1. Historical motivation (the gaps in the 0.41 loop; not current implementation status)

The night loop today is: pick a PC, repair bench, hardware bench, monitor. It never closes: there is no
hand-back, no payment and no next customer in the night flow, nothing ends the night, the ticket tells you
the fault outright, and there are only two fixed customers. The pickup score, hidden faults and trust exist
in the rules but are never reached from the night flow.

## 2. Pickup: right-click a PC (D134) — BUILT in 0.43.0

Built: the room's right-click on a PC and the workbench ticket (the header identity: click opens the
ticket, right-click the menu) share one menu. Ready = yellow READY sticker, a note only. Called = green
CALLED tag; both undo. Stored in job["ticket"] {request, ready, called}; the record is derived
(`scripts/rules/ticket.gd`). Nothing happens in the morning yet (session 3.2).

- DECIDED: PCs can be right-clicked, both in the storage room and somewhere on the ticket.
- DECIDED: one option labels the PC as **ready for pickup**. It is an internal note for the player and
  visually slaps a sticker on the PC. It changes no rule.
- DECIDED: the other option **calls the customer** to pick the PC up.
- DECIDED: a called customer collects **the next morning**.
- PROPOSED: a call can be cancelled until 06:00; a PC that is never called stays, and the customer's
  patience runs down each day.

## 3. Tickets (D135)

- DECIDED: a ticket is opened whenever a customer makes a request.
- DECIDED: request types are **PC repair** and **PC build**. The build request must be discussed with the
  user before any coding.
- DECIDED: a ticket carries a list of **objects** (types of things) so tickets can be generated
  dynamically. The exact list is still being defined.
- DECIDED (builds): the customer pays **half up front, half on collection**.
- PROPOSED object list (the user has seen it, not confirmed it):

| Object | What it holds | Who sees it |
| --- | --- | --- |
| Customer | name, profession, trust, patience | player |
| Request | type (repair or build) and the wording | player |
| Machine | the PC: every part and its state | player, by inspecting |
| Symptoms | what the customer noticed | player |
| Faults | the truth behind the symptoms | hidden |
| Requirements | what "done" means: boots, quiet, a game at N FPS | player |
| Terms | price or budget, deadline | player |
| Events | modifiers dealt onto the ticket | hidden or hinted |
| Work log | what the player did and measured (the Work + match tab) | player |
| Status | open, marked ready, called, collected | player |
| Outcome | pickup reaction, pay, trust change | morning report |

- PROPOSED (builds): no machine and no faults; the player assembles a PC at the hardware bench from stock,
  salvage and bought parts; profit is the budget minus parts cost. Needs CPU and RAM unlocked at the
  hardware bench, a priced parts catalogue and simple compatibility rules. The upfront half is working
  money; the second half is what an unhappy customer can hold back; an unfinished build owes the deposit
  back. An "upgrade request" (existing PC, build-style requirements) could come first. Plain repairs would
  stay pay-on-collection.
- OPEN: everything about builds beyond the half-and-half payment.

## 4. Night end and morning report (D136) — BUILT in 0.44.0 (choices in D146)

- DECIDED: the night ends (at 06:00) and a **morning report** follows.
- DECIDED: the morning report includes the state of the player's PCs; hovering a PC for its details
  would be nice.
- PROPOSED: one card per PC. Collected: the customer's reaction in their words, pay, trust change. Not
  called: days waiting against the deadline.
- DECIDED (user, 16 November 2026): film left on, pop-ups and loud fans show at pickup; loose GPU screws and
  an unstable overclock come back after a few days (built: two mornings later).

## 5. Diagnosis (D137, refined by D150) — APPROVED DESIGN, not built by this update

### 5.1 The player's task and information layers — DECIDED

Diagnosis begins with the customer's description. The player chooses useful inspections/tests,
compares evidence, works on the PC and decides when to call the customer. There is no diagnosis
submission quiz, new completion button or automatic conclusion in Findings.

| Information | Meaning | Example (illustrative, not a new playable case) |
| --- | --- | --- |
| Complaint | The customer's experience, potentially with several aspects | Games become slow after a while and fans become loud |
| Observations | Primarily what the player sees inside the machine | Dust visibly obstructing cooler fins |
| Measurements | Results obtained from instruments/tests | Temperature rising while measured FPS falls |
| Work history | What the player changed, with relevant part identity | Customer GPU removed; owned test GPU fitted |
| Findings | The notebook collecting those records without a conclusion | Timestamped inspection, work and test records |

Only log physical evidence the current inspection actually exposes. Richer component visuals are
LATER with graphics; do not invent unseen physical clues as if the player inspected them.
Complaint wording/layout is still adjustable. A complaint may include behaviour, trigger, associated
symptoms, history and requirements; those field names and mandatory structure are PROPOSED.
Customers do not answer follow-up questions in the current scope: initial description plus inspection
and tests provide the evidence. Wrong customer self-diagnosis remains later work.

The original approved symptom families remain a first cut, not a promise to add every listed fault:

| Complaint family | Candidate explanations |
| --- | --- |
| PC does not start properly | Missing/loose or failed part; insufficient power support |
| Shuts off, gets loud or slows during games | Dust, poor thermal contact, inadequate cooler, miner, overclock |
| Slow ordinary use | Adware/miner, heat throttling, insufficient resources for the workload |
| Games crash | Unstable overclock, memory/GPU trouble, overheating |
| Strange screen output | GPU trouble |

Exact wording and mapping to observable startup stages are PROPOSED. Do not equate no image with
no power in every case. Future internal fault states must be supported before using them in tickets.

### 5.2 Story difficulty and the manual — DECIDED

Story-case facts/faults remain consistent. Player knowledge and optional assistance are separate
from case complexity. Do not reroll a story PC or change its true fault because the player asks for
help, plays slowly or reads the manual. No automatic difficulty scaling is approved.

An optional **manual** provides explanations and progressively more specific investigative guidance.
The user chose a manual rather than a mentor; exact chapters, layout and levels of guidance remain
PROPOSED. Explain components, symptoms, tests and how to compare evidence without reading hidden
fault flags to write the answer. No separate case-specific hint engine or new dialogue mechanic is
approved. Assistance is consulted deliberately, never automatically inserted as a diagnosis.

Case difficulty comes from how evident the issue is, plausible explanations and relevant test paths.
Authored story progression can introduce these gradually. The six proposed example cases and any
case pack/two-fault schedule were accepted **for later**, not for immediate implementation.

### 5.3 Test scope, evidence and ambiguity — DECIDED principles

Tests report what they observe, within their scope. No universal broken-part detector. In particular,
inspection/hover, Hardware check and fitting/refitting permissions must not reveal hidden health.
Known physical absence, visible condition, model labels and established evidence may be shown.
Unknown salvaged-part condition is not made known merely by opening its inventory card.

| Test/action | Can establish | Cannot automatically establish |
| --- | --- | --- |
| Physical inspection | Visible dust, empty slots, exposed seating, labels | Hidden internal health |
| Boot attempt | Observed startup/display/OS behaviour | Sustained stability |
| Hardware check | Observable detection/configuration results | Every hidden faulty part and technique flag |
| Vapor game test | Measured FPS, temperature and failures during that run | Every workload or future stability |
| Anti-virus scan | Supported infections the scan detects | Hardware health |
| Standalone long stress app | Sustained behaviour under tested conditions | The unique faulty part in every case |
| Reseat or owned-part substitution | Behaviour after that controlled change | Universal proof that the removed part was bad |
| Restore stock clock settings | Behaviour without the old overclock | Absence of other faults |

Compare like conditions. A lower-power GPU making a PC boot also changes power demand, so the
comparison alone need not isolate GPU health. Early cases can avoid this ambiguity; harder cases
must provide a way to resolve it. Fault triggers should be reproducible from state/load/duration,
not a random roll that eventually reveals the answer after identical tests.

The user requested classification of ambiguities. This candidate taxonomy is **PROPOSED**, not
an approved player-facing menu: shared symptoms; several variables changed; test coverage limits;
one fault masking another; capacity versus condition; installation versus component health.

### 5.4 Findings, time and result validity — DECIDED

Findings record observations/measurements/work, never the causal conclusion. Keep relevant
configuration/part identity and before/after context. Old evidence remains readable after changes,
but is marked historical/outdated for the current configuration when the change matters.

**All timestamps come from the existing shared night clock.** Include night identity so midnight,
multiple nights, save/load and switching PCs do not confuse ordering. Record actual event times;
a completed timed test can retain start/end from that same clock. Do not use real wall time, a
separate diagnostic timer or fabricated timestamps. Existing clock charges remain authoritative;
this design does not silently convert every bench action to a new continuous-time system.

Test durations/prices remain trial tuning (currently game 30 night minutes, long stress 20 and its
existing electricity fee). Repeated runs cost time again. Refused tests explain their prerequisites
without charging a full completed run; interrupted tests retain only observations actually obtained
and are labelled incomplete. Reading notes/manual adds no separate diagnostic-time charge. Preserve
existing pause/busy-test/night-end guards; do not fabricate results past the permitted clock boundary.

### 5.5 Hidden technique and pickup — DECIDED

Preserve D130/D133/D146. Hardware check and Findings must not announce hidden film/screw technique
flags. Do not silently move pickup-only or delayed-comeback discoveries into diagnostics. Permitted
measurements may be recorded without naming a hidden installation mistake. If a new measurement
would contradict an existing delayed-discovery rule, resolve that boundary before implementing it.

### 5.6 Owned test parts versus permanent replacement — DECIDED

- A known-good substitution requires a suitable part the player actually owns. No phantom free kit.
- A temporary fitted test part remains shop-owned; the customer's removed part remains theirs.
  Swapping and restoring is not an unnecessary-replacement charge or an ownership transfer.
- Preserve individual identity even for identical models. Make shop test-part custody visible.
- Permanent handover at collection settles replacement/cost consequences. If the player needlessly
  replaces a working part, the player bears the cost and the original enters player stock (D137).
  A later upgrade allowing charges to the customer is not part of this task.
- Do not double-charge an already purchased part or charge just for fitting it experimentally.
- Refitting restrictions must not become a hidden-health oracle. The 0.46.0 auto-transfer-on-fitting
  and health-based refusal need comparison against this contract, not blind reuse as diagnosis rules.
- Keep normal save/load, PC switching, inventory capacity and rollback safe; do not duplicate, lose or
  silently sell parts. Actual implementation contracts belong in Claude's patch/feature PR.

### 5.7 Solvability — DECIDED principle, case-specific solutions OPEN

Every offered case needs an achievable evidence path with available tests and suitable owned parts.
Test suitability includes capacity/compatibility, not just a matching broad component type.
An optional generator may consider available capabilities. A mandatory story case must not disappear
or change its hidden fault because a test part is missing. Design an alternate path, progression
prerequisite or reachable acquisition opportunity; the choice for each story case is still OPEN.
Voluntarily losing equipment may require obtaining it again; no new automatic subsidy is approved.

Generation/events and an automated solver belong to 3.5, not this design push. When implemented,
solvability checks must use only player-accessible evidence and actual capabilities, including
reachable follow-up tests after a masking fault is addressed. No hidden-truth shortcut in the solver.

### 5.8 Delivery order and ownership — user-requested split, 18 November 2026

Codex owns diagnosis design, manual content/design and ambiguity/acceptance specifications, plus
cross-review. Claude owns the runtime audit, necessary compatibility patch, 3.4 implementation,
manual reader integration and regression tests. See WORK_PLAN and HANDOFF for file boundaries.

**Patch first:** Claude compares merged code and his unpublished work with sections 5.1–5.7. Any
conflicting existing behaviour gets a separate versioned compatibility patch/PR BEFORE new diagnosis
features. Do not bundle the new manual, case pack or generator into that patch. If there is no delta,
report that finding rather than inventing a patch. Preserve unpublished work and adapt it after the
patch is integrated under the existing cross-review/user-controlled merge process.

Manual content/design can progress in parallel with that audit. Agree its small content format before
runtime integration. This document update implements no runtime feature, case or manual content pack.

## 6. Events and variety (D138)

- DECIDED: tickets are randomly generated, and variety comes from **events applied to tickets** (a pool
  of faults, infections and requests, including the customer whose stated need is wrong).

## 7a. Build requests in detail (D140, 16 November 2026)

- DECIDED: customers come with a **budget** and **needs**: play certain games, light / medium / heavy office
  work, video editing, crypto mining, maybe more later. Some customers also need more storage or RAM.
- DECIDED: every PC has six stats: **processing score, graphics score, RAM available, storage available,
  PSU, cooler**. Each use has a minimum for each stat that such a customer normally needs.
- DECIDED: **needs versus wants**: needs are hard minimums, wants are soft extras that move the reaction.
- DECIDED: **budget pressure** (some budgets too tight for new parts). Customer **personas** will affect it,
  with lore woven in: designed later.
- DECIDED: PSU and cooler are **support** stats (they must cover what the other parts draw and produce),
  but customers **can also ask for quietness**.
- DECIDED: parts are named **like real hardware** (names and brands the player learns).
- ~~DECIDED: builds get an elegance score that ties into the shop level and gives good online reviews.~~
  SUPERSEDED by D160 (20 November 2026): no elegance score; trustworthiness feeds the shop level (7c).
- DECIDED: salvaged parts need a **testing bay** to learn their real condition.
- DECIDED: **mining customers** will be a persona.
- LATER (user): the upsell temptation; the wrong self-diagnosis (may be added later); new uses (not yet).
- DECIDED (D159, 20 November 2026): the uses table on the catalogue scale. Built in 0.51.0
  (`scripts/rules/build_request.gd`). The old-scale table (before the 0.45.0 catalogue) is superseded.

| Use | Processing | Graphics | RAM GB | Storage GB |
| --- | --- | --- | --- | --- |
| Light office | 10 | 0 | 8 | 250 |
| Medium office | 20 | 0 | 16 | 500 |
| Heavy office | 30 | 10 | 32 | 1000 |
| School / kid's PC | 15 | 10 | 8 | 500 |
| Music production | 30 | 0 | 32 | 1000 |
| Video editing | 40 | 30 | 32 | 2000 |
| Crypto mining | 10 | 60 | 8 | 250 |
| Gaming | from the game and the customer's FPS | | | the game's size |
| Streaming | game + 15 | game | game + 16 | game + 500 |

- DECIDED (D159): wants are quiet, headroom, a favourite brand and extra storage; cases are swappable
  parts; the customer pays the budget (half up front, half on collection), profit = budget − parts, never
  more than the budget; assembly costs night time; build requests start on nights 4–5; scam hooks
  (untested parts at new prices, a cheaper part than asked, full budget for a much cheaper PC) are left
  open. Implementation numbers: D159 proposals.

## 7a-bis. Real hardware (D148) — model BUILT in 0.45.0
The six stats, support rules, several GPUs and the catalogue: docs/HARDWARE_CATALOG.md. The build request
(7a) will choose parts from that catalogue.

## 7c. Trustworthiness, the shop level and reviews (D160, 20 November 2026)

- DECIDED: **no elegance mechanic** ("it doesn't work well with the scamminess of the game").
- DECIDED: a **trustworthiness** level that ties into the **shop level**. It rises with good work. It
  falls only when customers **find out** what happened (they go online and write a review). Honest
  mistakes found out and scams found out **both** hurt it.
- DECIDED: the shop level gives **upgrades**, defined later.
- DECIDED: finding out is a delayed discovery a few mornings after pickup; how likely depends on the
  customer (one who opens the case finds more than one who never does).
- DECIDED: **every pickup leaves a review**, and customers are not always fair: some reviews are petty.
  This gives the player a reason to feel justified in scamming.
- DECIDED: reviews are a **star rating with comments**, seen on the player's **phone** (an app). The phone
  also has a button to **buy fake reviews**.
- LATER (user): **more interactive reviews**. Respond to reviews instead of only reading them: reply
  publicly to an angry review to calm it down (or make it worse), or pay an angry customer to take their
  review down (a bribe, with its own risk of being found out). Both build on the written reviews; not
  built yet.
- Built in 0.52.0 (`scripts/rules/reviews.gd`, `scripts/night/phone_panel.gd`); numbers in D160's
  implementation proposals.

## 7b. The Wave 3 plan (D141)
The user approved a plan of coding sessions 3.0 to 3.8 (one release each). It lives in docs/WORK_PLAN.md.

## 7. Money and upgrades (D139)

- DECIDED: upgrades are discussed later. The only fixed point so far is in section 5: an upgrade can
  shift the cost of a wrongly replaced part to the customer.
