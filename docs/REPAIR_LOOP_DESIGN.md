# Repair loop design: tickets, pickup, morning report, diagnosis (D134 to D139)

Recorded from a design conversation with the creative director (the user) on 16 November 2026.
Written by Claude (Fable 5.2, model id claude-fable-5-2). **Nothing in this document is built.**
The user said "no coding yet": do not implement any of it until the user asks.

Status key used below:
- **DECIDED** = the user said this, in their words or by a direct yes.
- **PROPOSED** = Claude's suggestion from the same conversation; the user has not confirmed it.
- **OPEN** = to be discussed before coding.

## 1. Why (the gaps in the 0.41 loop)

The night loop today is: pick a PC, repair bench, hardware bench, monitor. It never closes: there is no
hand-back, no payment and no next customer in the night flow, nothing ends the night, the ticket tells you
the fault outright, and there are only two fixed customers. The pickup score, hidden faults and trust exist
in the rules but are never reached from the night flow.

## 2. Pickup: right-click a PC (D134)

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

## 4. Night end and morning report (D136)

- DECIDED: the night ends (at 06:00) and a **morning report** follows.
- DECIDED: the morning report includes the state of the player's PCs; hovering a PC for its details
  would be nice.
- PROPOSED: one card per PC. Collected: the customer's reaction in their words, pay, trust change. Not
  called: days waiting against the deadline.
- OPEN: which hidden faults surface at pickup and which come back days later.

## 5. Diagnosis (D137)

- DECIDED: the customer gives **symptoms**; the ticket hides the **faults**; the player finds the cause.
- DECIDED: the user likes this symptom-to-fault table (first cut, contents still adjustable):

| Symptom the customer reports | Possible faults |
| --- | --- |
| "It won't turn on" | dead GPU, dead RAM stick, a part that is only loose |
| "It shuts off or gets loud in games" | clogged dust, dried paste, hidden miner, overclock left on by the customer |
| "It's slow" | adware or miner, heat throttling, too little RAM for what they run |
| "Games crash at random" | unstable overclock, failing RAM, overheating |
| "Weird lines on the screen" | dying GPU |

- DECIDED, engineering requirement: **the puzzle must stay solvable from the information the player can
  currently get.** There are **several difficulty levels, based on how evident the issue is.**
- DECIDED: the ticket has a **Findings** section. It logs **observations only** ("Boot failed", "Boots with
  the shop's test GPU", "71°C under load", "Scan clean"). The game never writes the conclusion; the
  morning report shows whether the player was right.
- DECIDED: the **long stress test is an app on the diagnostic computer** in its own right (today it is a
  button inside the overclocker controls).
- DECIDED: a known-good swap needs a test part the player **owns** (no free shop set).
- DECIDED: when the player replaces a part that was not broken, **the owner (player) pays** for the
  mistake, and the customer's original part goes **into the player's stock**. Certain later upgrades will
  let the player put that cost on the customer.
- PROPOSED evidence sources: looking inside the case, boot check, temperature under load, anti-virus scan,
  long stress test (intermittent faults, costs night minutes), known-good swap at the hardware bench.
- PROPOSED: one or two faults per ticket, sometimes with a misleading symptom; fixing one of two faults
  comes back in a later morning report.

### What "solvable" has to mean in code (Claude's engineering note, to design before coding)

1. Every fault must have at least one observation that separates it from every other fault sharing its
   symptom, using only tests and parts the player can have at that point.
2. Because test parts must be owned, the generator must not deal a ticket whose only separating
   observation needs a part the player cannot have. Either it checks what the player owns, or every such
   fault also has a second evidence path. OPEN: which of the two.
3. Difficulty is a property of the ticket, measured by how evident the cause is: for example how many
   tests are needed, whether a symptom misleads, whether there are two faults.
4. An automated test should generate many tickets and prove, with a simple solver, that each one is
   solvable at its stated difficulty. This is the guard against unsolvable puzzles.

## 6. Events and variety (D138)

- DECIDED: tickets are randomly generated, and variety comes from **events applied to tickets** (a pool
  of faults, infections and requests, including the customer whose stated need is wrong).

## 7. Money and upgrades (D139)

- DECIDED: upgrades are discussed later. The only fixed point so far is in section 5: an upgrade can
  shift the cost of a wrongly replaced part to the customer.
