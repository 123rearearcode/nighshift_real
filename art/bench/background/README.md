# Repair bench background

`bench_background.png` (1280 x 720, shown 1:1 behind the repair bench) was made from the user's own desk painting
(worn boards, a teal work mat, a dark tool tray), supplied on 27 November 2026 with "can you integrate this into
the game for the repair bench? Maybe pixelate the mat a bit more".

`tools/art_batch_d/bench_mat.py` rebuilt it for the bench's layout: the mat nine-sliced under the PC and the
service tray (40..660 x 105..650), the dark tray material behind the controls panel (from x 700), the boards
continued where the mat and tray were, the mat pixelated in 4-pixel blocks and the wood in 2-pixel blocks.

The user picked layout A, pixel 4 and lightly pixelated wood, then approved this exact file ("Approve, put it in");
the hash is in `manifest.json` and `docs/ART_ASSET_LOG.md`. Drafts and the other options stay in
`art/drafts/bench_mat/` (not loaded). New or changed versions need the user's approval first (D167).
