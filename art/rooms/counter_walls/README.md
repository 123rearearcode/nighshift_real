# Counter wall finishes

Four walls for the counter room, drawn 1:1 (1280 x 505, down to the floor line) over the room's flat teal tiles:

- `wall_oil_paint.png`: B, two-tone oil paint (whitewash over glossy green). The shop starts with this one.
- `wall_cream_tiles.png`: A, cream faience tiles with a brown band.
- `wall_pine_wallpaper.png`: C, pine panelling under 70s wallpaper.
- `wall_blue_plaster.png`: D, pale blue plaster, cracked, with a dark skirting.

The teal tiles (the shell's own wall) stay a fifth choice. The lamp, the pipe and the workshop doorway are
transparent holes, so they show through.

Shown to the user as `art/drafts/walls/wall_options_sheet.png`; approved 27 November 2026: "i kinda f with all
of them. Later on in the game, you can change wallpaper, so you start w the second one but all should be
included". `tools/art_batch_d/walls_export.py` made these layers from the same drawing code and checked that
they rebuild each approved picture with no pixel difference. Hashes: `manifest.json`. Finishes are bought at
the store (`scripts/data/wall_finishes.gd`); new or changed walls need the user's approval first (D167).
