# Customer model map — agreed before code (0.25.0)

Mapped with the user on 14 November 2026, then approved point by point (their answers are quoted
under "Agreed answers"). Recorded by Claude (Fable 5, model id claude-fable-5). This is the shape
of the whole customer/software system; **the first wave (0.25.0) builds only the parts marked
[wave 1]**. Numbers are trial proposals throughout.

## The pieces and how they interact

```
customers.gd (static: who they are)     games.gd (static: what games demand)
        |                                        |
        v                                        v
 job.customer_id ----> pickup_score.gd <---- fps_sim.gd <---- the PC as handed back
        |                     |                                (gpu power, pc_specs, temp)
        v                     v
 customer_state (save) <-- run_final_check first pass
 (trust, history,             |
  comeback_days)              v
        |              shop result + Customer tab
        v
 future nights: the same customer returns, trust gates payouts/complaints (later wave)
```

## 1. The customer record [wave 1: data file]
Static data in `scripts/data/customers.gd`: id, name, portrait (blank for now — when portraits
come they must derive from the character's actual look), scripted flag, profession, persona,
about, complaint, uses, habits (feed the scam-discovery direction, D17/D18), patience,
trust_start, budget, payout, needs. What the shop EARNS (trust changes, history, scores,
comeback) lives in the save under `customer_state` and survives `new_game` — it is the shop's
property, like owned games.

## 2. Trust [wave 1: one number]
One number, 0–100, per customer. Starts at `trust_start`, moves at pickup: happy visits raise it,
unhappy ones lower it (±(score−70)/10 per visit, proposal). Later waves: trust gates what
customers accept without checking, what they pay up front, and how loudly they complain (reviews).

## 3. Money: budget caps, no quoting [wave 1: data only]
No quoting flow for now. Each ticket has a fixed `payout` and the customer a `budget` cap — the
ceiling later waves will charge against for parts and extras. No price negotiation UI.

## 4. Professions and needs [wave 1: regular + gamer defined; clueless schema only]
First cut: **regular**, **gamer**, **clueless** (video editors, sysadmins, data analysts later).
Needs per profession:
- regular: boots, often "quiet" (fans give away a hot PC: loud when final temp > 65 C).
- gamer: boots + named games at minimum fps (`{game_id, min_fps}`).
- clueless: needs hold `stated` (a decoy — what they SAY) and `real` (what actually scores).
Boot test [wave 1]: the PC can be handed back with ANY power output as long as it boots —
it boots when nothing is broken and nothing is left out. This replaces the 0.21.0 required-power
threshold (D79) and is checked and said in the final check.

## 5. Games and the FPS simulation [wave 1: rules + one game]
`scripts/data/games.gd`: games the shop can BUY (an investment) to test a customer's PC exactly.
One test game: **Counter Stroke 2** ($12; gpu_demand 55, cpu_demand 60, ram_min 8 — proposals).
`scripts/rules/fps_sim.gd`: fps = 60 × min(gpu_power×thermal/gpu_demand, cpu_power/cpu_demand);
heat throttles the GPU linearly from 60 C (none) to 90 C (half); RAM under the game's minimum
keeps 35% of the frames (stutter). The job carries `pc_specs` (cpu_power, ram_gb) [wave 1];
CPU/RAM replacements come later.

## 6. Pickup score and comeback [wave 1]
On the FIRST passing final check, `scripts/rules/pickup_score.gd` scores the pickup 0–100 against
the customer's REAL needs: temperature (full marks ≤55 C, scaling off toward the pass limit),
each named game at its minimum fps on the PC as handed back, quiet. ≥70 = happy, no comeback.
Unhappy customers come back about it — angrier is sooner: score <40 → 1 day, <60 → 2, else 3.
Scams are NOT scored at pickup (nobody has discovered anything yet); delayed discovery adjusts
trust later (habits decide how fast — later wave). The shop result and Customer tab show the
score and comeback [wave 1]; the actual return visit needs the night loop (later).

## 7. The software-checks screen [wave 2+]
A separate tab/screen styled as the customer's MONITOR (their PC visible in the background),
with apps to click: **boot test**, **anti-virus**, **Vapor** (parody game store: buy games, run
the fps test), **overclocker** (a minigame in itself — tune parameters; second wave, per the
user). Suggested extras to consider: a "benchmark" app (free rough fps estimate vs. Vapor's
exact one), a disk-health scan, a parody browser with the customer's review visible after
pickup. Wave 1 builds the RULES behind this screen (boot, fps, bought games); the screen itself
is the next step.

## Agreed answers (user, 14 November 2026, 12:53)
1. One trust number 0–100 — "agreed".
2. "No quoting for now" — budget caps only.
3. "also add cpu/ram demand for now and create one test game Counter Stroke 2."
4. "yes, have a pickup score and a variable time for customers to come back if they aint happy
   with their repairs."
5. Professions first cut (regular + gamer + clueless) — "Agreed".
6. "Second wave overclocker is fine."
7. Split: Claude handles this entire customer/software part; Codex works at the same time on the
   dumpster/salvage minigame; when both are done, the user will have Claude review Codex's work.
