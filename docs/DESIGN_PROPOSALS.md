# Nightshift - Design proposals (NOT built, NOT approved unless marked)

Written 2026-11-12 by Claude (Sonnet 5.5) from a design chat with the creative director (the user).
Reconciled in trial 0.7.2; authoritative scope now lives in the five adjacent documents, especially DESIGN.md and DECISIONS.md.
Status key: **AGREED** = the supplied Claude notes report the user said yes in chat; **PROPOSED** = my suggestion, awaiting a decision;
**OPEN** = a question nobody has answered. Nothing here exists in code yet. These notes do not change
decisions D01 to D33 in the handoff documents; if they conflict, ask the user.

## 1. Screen hierarchy (screens are one scene each)

```
Main menu (Continue / New game / Settings)                      PROPOSED
  Night hub                                                      AGREED (it is the hub)
    Repairs  -> Ticket board -> Job screen (one customer PC)     AGREED
                  Job checklist: Clean the PC, Hardware bench,
                  Paste and mount, Final check, Deliver          PROPOSED order; the user wants the
                                                                 hardware bench BEFORE the final check
    Go out   -> Map -> Location (each has its own mechanic)      AGREED idea, locations OPEN
    Shop     -> Upgrades, tools, parts stock                     AGREED as a hub option
    End night -> Summary (earnings, bills, reputation)           PROPOSED
```

- Every screen except the hub has a "Back to hub" button. The hub has no gameplay of its own.
- **Nights have limited time** (AGREED). Going out and repairing compete for it. The model is a continuously running night clock with manual pause (D10); exact duration is OPEN.
- **Unfinished tickets carry over to the next night** (AGREED). The ticket board therefore needs
  deadlines and a way to show age. Details OPEN.
- The current `shop.tscn` is a stand-in for the hub plus the job screen. Replace it, do not extend it.
- The square cloth is bought in the placeholder shop screen for now. It moves to the real Shop later
  (AGREED by the user).
- Go-out location ideas (PROPOSED placeholders, mechanics OPEN): scrapyard, parts market, estate sale.
- Daytime phase is CONFIRMED: manually open, serve individual untimed visitors, then close. The night hub follows it (D07–D10).

## 2. Grid inventory and PC building (AGREED in principle)

Three nested grids, all using the same data idea as the existing shaped board (`#` = usable cell,
`.` = blocked):

| Grid | Holds | Limited by |
| --- | --- | --- |
| Stash / backpack | everything the player owns | space, item shapes, rotation |
| Case | the motherboard, PSU, drives, fans (all are grid items - AGREED) | the case's grid size and shape |
| Motherboard | CPU, RAM, GPU, M.2 and so on | the board's own irregular layout and its connectors |

- A tiny case gives a cyberdeck, a huge one a gigantic tower. Same rules for both.
- Board layouts are rarely regular, so each board model needs its own hand-authored layout.
- Customer PCs arrive pre-built; taking one apart moves parts into storage while preserving customer ownership (D19).
- The backpack size limits what can be carried back from Go out locations (PROPOSED link).
- Heat and airflow: a cramped build runs hotter, feeding the final-check temperature (PROPOSED).
- Custom builds commissioned by customers: **AGREED, a mid-game feature to expand on later.**

### The height number (AGREED - "keep it in")
Every part has a flat footprint on the grid plus one integer `height`: how far it sticks up from the
board. A case has a depth limit. A part taller than the case depth does not fit, and the game says so
("too tall for this case, 6 allowed"). The grid stays flat and readable, and `height` also becomes a
sorting and categorising key for items later. The existing 1 x 4 RAM stick would get `height` 1.

### Connectors between case and board (OPEN)
Idea: risers, extensions and cables placed in the case grid so a part can sit away from its slot.
Proposal: start with fixed-shape connectors; variable-length cables come later.

## 3. Parts catalogue (data fields AGREED; format and contents NOT started)

The user will work on the catalogue himself first (Monday after this note). Do **not** build it until the
user says so. The agreed fields per item:

- Category, name, brand, price, rarity, condition.
- Grid info (footprint, height).
- Compatibility.
- Performance and heat.

Agreed rules:
- **Brands are parodies**, as the recorded naming direction; this is not a legal conclusion or automatic permission to copy real marks. Never put a real brand or product
  name in game data.
- The list should mimic real-life options "and more": an extensive catalogue.
- Everything is data-driven so parts and boards can be added by editing data files, not code. Board
  layouts are authored the way `ComponentData.demo_board()` does it (rows of `#` and `.`, plus a
  connector list), so a contributor can hand over a new board as a small data file.

Questions for the user (OPEN): whether `condition` belongs on the catalogue entry or on each owned item
(my suggestion: on the owned item, since two copies of the same part can be in different states); the
file format (my suggestion: JSON files under a `data/` folder); real-world specs versus invented ones.

## 4. Gameplay tweaks requested but not built yet (all PROPOSED designs)

1. **Loose specks:** individual dust specks that drift around, in addition to the bundles. Dust physics
   should feel looser overall. Touch `scripts/bench/dust_sim.gd` and the dust drawing in `bench_view.gd`.
2. **Mount minigame readability:** the right moment must be obvious. Proposed: draw two squares, a
   target square and a pressure square that grows with pressure. Release when they visually match.
   Remove the need to read percentages. The physics in `paste_sim.gd` stays; only the feedback and the
   definition of the target change. The numbers were tuned for the old bars, so retune them.
3. **Square cloth to the shop:** see section 1.

## Reference footage notes (added 2026-11-12, v0.11.2)
Source: a 17-second screen recording the user supplied of the game that inspired Nightshift (a pixel-art
shop game with a grid inventory). Observations only; status PROPOSED. Do not copy its art, names or
layout; take the ideas, not the assets.
- **The hub is a room, not a menu list.** The shop is one scene where objects are the menus: a shutter
  button opens or closes the shop, a telephone, a negotiation counter, a display case, a reputation
  terminal, and a sleeping bag that ends the day (the game autosaves on sleeping). A wall sign shows the
  day and a rent countdown; a small display shows currency.
- **The grid inventory is a panel inside the room**, under the counter. Items are small pixel sprites.
  A dragged item highlights the cells it would use in green. Extra containers (a "storage bay") open as
  small popup windows with a close button.
- **Item handling keys:** Q and E rotate, F flips; Ctrl+click, Shift+click and Alt+click quick-transfer an
  item to the inventory, the display case or the counter.
- **Hint overlay:** one key toggles labels on every interactable plus a list of keyboard shortcuts, and a
  button closes it. Tooltips are small speech-bubble labels that name the action ("Open the Shutter Door").
- **For Nightshift (PROPOSED):** build the night hub as a room whose objects lead to Repairs, Go out and
  the Shop; reuse one grid component for stash, case and board; add quick-transfer modifiers and a hint
  overlay (useful for a beginner audience). The user said Nightshift does not have to be a single view
  as the reference is: separate scenes for hub, bench and map, with popups as overlays, are fine.

## 5. Queued after 0.15.0 (PROPOSED; added 2026-11-13 by Claude Opus 5.5, model id claude-opus-5-5)
1. **Fans move loose dust** (planned as 0.15.0 before the user redirected it): spinning fans swirl unsettled dust (brush-tossed or blown) and blow it across to other parts; there is a chance per second, scaled by fan speed, that it slips under the cooler or GPU, where only removing the part or using the pick gets it out. Purpose: careless brushing creates extra work. The GPU fan needs its own speed.
2. **Mount readability** (section 4 item 2) is still open; 0.15.0 only retuned the lines.
3. **Scam direction:** see DESIGN.md section 19. Nothing beyond toothpaste is designed yet.
4. **Dust minigame purpose:** the user is thinking about it (D55). Ideas are welcome as proposals only.
