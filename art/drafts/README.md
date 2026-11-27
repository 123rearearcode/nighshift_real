# Art drafts (not in the game)

Review material only. Nothing here is loaded by a scene or script, and the `.gdignore` file keeps Godot
from importing it. A draft goes into the game only after the user approves its exact revision for that
use (D167); the approval and file hashes are then recorded in docs/ART_ASSET_LOG.md.

- `ART-14/` to `ART-18/` (Batch C, 25 November 2026, Claude): open case and board kit, close-up hardware
  (board-scale parts, testing-bay inspection pictures + spot positions), repair-tool skins and textures,
  dust/paste/fan/damage layers, monitor and phone frames. Approved by the user 25 November 2026 except the tools: `ART-16/rev2/` holds the pixel-art tools that
  replace the comic ones (approval pending). Per-file status and hashes: `batch_c_manifest.json`.
  Source that regenerates the same bytes: tools/art_batch_c/.
- `batch_c_review/`: the review sheets shown to the user (mockups, not game art).
- `connectors/`, `case_walls/`, `outside/` (0.57.8, Claude): the two power connectors (24-pin, 8-pin), the
  case's inner walls for the PC lying open, and the Outside room at street level. Pending review.
- `termopan/` (0.58.5, Claude): the review sheets of the termopan doors, PVC shutter, radiator and linoleum
  (D174). Approved ("aight go on with the PVC") and installed in `art/rooms/counter_termopan/`.
- `walls/` (0.58.5, Claude): four alternatives to the counter's teal tiles (A cream faience tiles with a brown
  band, B two-tone oil paint, C pine panelling under 70s wallpaper, D pale blue plaster), shown in the termopan
  room with the name sign. Pending the user's choice.
