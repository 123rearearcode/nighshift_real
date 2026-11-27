# Counter room: termopan set (D174, approved 27 November 2026)

Loaded by `scripts/rooms/counter_art.gd` when all nine files are present (otherwise the 0.57.9 flat layout of
Batch A is drawn). Full-canvas layers on the Batch A source canvas (1672 x 941), drawn to the 1280 x 720 screen.

- `termopan-front-frame.png`: white PVC frame of the glass door + shop window block, two window sashes (one with
  its handle) and the sill.
- `termopan-front-door-closed.png` / `termopan-front-door-open.png`: the glass front door (clear glass over a
  white panel, lever handle with lock), closed and swung open.
- `termopan-workshop-closed.png` / `termopan-workshop-open.png`: the workshop door in the same style, keyhole on
  the left, hinges on the right.
- `pvc-shutter-up.png` / `pvc-shutter-down.png`: the white PVC roller-shutter box, and the shutter down over the
  glass at night.
- `radiator.png`: a cream cast-iron radiator under the window. `floor-linoleum.png`: brown checked linoleum.

User approval: "aight go on with the PVC" (27 November 2026), after the review sheets in `art/drafts/termopan/`.
Hashes: `manifest.json`. Created by Claude (Opus 5.5, model id claude-opus-5-5), code-drawn with Python/PIL;
`tools/art_batch_d/termopan.py <folder>` regenerates the same files.
