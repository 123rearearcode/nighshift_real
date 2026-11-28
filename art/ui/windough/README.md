# Windough 98 on NightBoot USB

The customer PC's screen on the diagnostic monitor (0.59.0, D182): pixel art at 423 x 258, drawn at exactly 2x
inside the monitor bezel by `scripts/night/windough.gd`.

- `bios.png`: the Nightshift BIOS (nothing about the parts; the user: "make sure the info of the bios doesnt give
  anything away"). `no_signal.png`: the monitor's message when the PC does not start.
- `nightboot_base.png`: the NightBoot USB boot menu; the game writes the countdown. `splash_windough_base.png`: the
  Windough 98 splash with an empty baking tray; the game fills it with rising dough.
- `wallpaper.png`, `taskbar.png`, `begin_button*.png`, `icon_*.png` (24 x 24), `logo_dough.png`, `cursor.png`.
- `font5x7.png` + `font5x7.json`: the 5 x 7 pixel font (6 x 8 cells, 16 a row; `chars` gives the order).

Made by `tools/art_batch_e/windough.py --runtime art/ui/windough` from the approved revision 2 drafts
(`art/drafts/windough/mock_*.png`); approved 28 November 2026: "approved, create PR". Hashes: `manifest.json`.
Window frames, menus and text are drawn in code by the same rules as the drafts. Changes need the user's approval.
