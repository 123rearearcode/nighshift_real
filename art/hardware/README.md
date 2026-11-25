# Hardware pictures (comic-book, semi-realistic)

Close-up hardware, approved by the user on 25 November 2026 (Batch C; credits and hashes in
docs/ART_ASSET_LOG.md). Every scene takes these through scripts/view/item_art.gd, so a part looks the
same everywhere.

- `case_tower_interior.png`, `board_demo_l.png` (ART-14): the tower case lying open on its side and the
  demo L board, 64 px per cell (master); the game scales them to its cell size.
- `parts/<name>_r<turn>.png` (ART-15): the parts from on top at 64 px per cell, four quarter turns each
  (the same drawings as the storage pictures; the CPU appears bare, out of its tray).
- `inspect/inspect_<kind>.png` (ART-15): the testing-bay close-ups (900 x 600, shown at 450 x 300). The lens
  spots for each are in `ItemArt.INSPECT_SPOTS`.
- `clues/<kind>_<broken|degraded|herring>.png` (ART-17): clue overlays on the inspection canvas, shown only
  after the lens has revealed that clue.

New or changed pictures need the user's approval first.
