# Cooler install technique (0.38.0, D130)

Claude (Sonnet 5.5, model id claude-sonnet-5-5), 15 November 2026. Requested by the user after
watching an install video: "feel true to it", and mistakes "dont come to bite you until the customer checks".

## What the player does
1. Thermal service tab: squeeze paste, press Mount cooler (unchanged).
2. Optional but real: click **Cooler base** to peel the clear plastic film off the contact plate.
   Nothing tells the player it is required.
3. While the cooler is pressed down, click the four corner screws. Each takes two turns (snug, tight).
   The first click shows a manual line: opposite corners in turn, two passes.
4. Click the lever (unchanged, D57). The mount is graded and the hidden mistakes are recorded.

## What goes wrong (pure rule: scripts/rules/install_faults.gd)
| Mistake | Cause | Customer heat | Pickup score |
| --- | --- | --- | --- |
| film_left | film never peeled | +30 C | -30 |
| uneven_mount | two or more screw pairs not on opposite corners | +10 C | -12 |
| loose_screws | fewer than 8 turns | +15 C | -25 |

All numbers are trial proposals. Clicks are read in pairs; a pair is right when the corners are
opposite (0-3, 1-2). One wrong pair is forgiven.

## Where it surfaces
Only in `PickupScore.score` (the customer's check): heat feeds the same temperature, fps and
"loud" rules as everything else, plus a flat annoyance and a complaint line in the pickup misses and
customer history. `run_final_check` (the shop's own test) never includes it, by design.

## Not built
Seating the CPU (bent pins), paste patterns by CPU type, cooler variety (tower, all-in-one), a
"tech notebook" that fills in as the player learns, prior-repairer mistakes on arriving PCs.
