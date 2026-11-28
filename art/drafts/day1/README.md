# Day 1 drafts (0.59.2, D186) — not loaded by the game

Drawn from scratch by `tools/art_batch_f/day1.py` (Claude, Opus 5.5, model id claude-opus-5-5), 28 November 2026,
in the style of the approved counter and rooms (user: "Draft from scratch but keep in line w the art design so far.
Should have some tiles in it (part w the common wall w the hallway)"; "Floor looks bad, it's supposed to be
linoleum"):

1. `1_counter_linoleum.png`: the counter with a sheet-linoleum floor (parquet print) in place of the current floor.
2. `2_stock_room_front.png`: the stock room seen from the front: green oil paint below, whitewash above, white
   tiles on the quarter of the wall shared with the hallway, a concrete floor, the steel rack, PCs front-on (each
   one shelf row high), laptops piled.
3. `3_bench_closed_case_and_laptop_cover.png`: a tower's side panel with its two thumbscrews and a laptop's bottom
   cover with eight screws, on the repair mat.
4. `4_linoleum_alone.png`: the floor tile by itself.

The pieces under `pieces/` install under `art/` at the same relative paths only after the user approves this exact
revision (`python3 -I tools/art_batch_f/day1.py --runtime art`); the stock room and the bench case overlay already
look for them there and draw plain shapes until then. Installing `floor-linoleum.png` replaces the approved
0.58.5 counter floor of the same name. Hashes: `manifest.json` (revision 1) and docs/ART_ASSET_LOG.md.
Approval: **pending**.
