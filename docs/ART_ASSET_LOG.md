# Art asset credits and creation log

23 November 2026. Author: Codex (GPT-6; exact deployment model id not exposed by this session), ChatGPT Work.
Permanent credits/approval record. Read ART_PRODUCTION_PROGRESS.md for the active creation list; every creator updates this log and the ACTIVE checkboxes.
This documentation pass creates no art. Do not replace verified file paths with claims of completion.

## Production tasks

| Task | Creation status | Assigned owner / creator | Delivered files / revision | Created / edited date | Human approval (exact revision) | Integration status |
| --- | --- | --- | --- | --- | --- | --- |
| ART-01 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-02 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-03 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-04 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-05 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-06 | Created | Claude (Batch B, assigned by the user 23 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/props/clipboard_resting.png`, `art/props/clipboard_upright.png` (rev 2) | 23 Nov 2026 (rev 1 + rev 2) | **Approved** by the user, 25 Nov 2026, rev 2 (hashes below) | Integrated 0.57.3 (`feat/batch-b-art-0573`); visual acceptance pending a human playtest |
| ART-07 | Created | Claude (Batch B, assigned by the user 23 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/ui/ticket_clipboard.png` (rev 2) | 23 Nov 2026 (rev 1 + rev 2) | **Approved** by the user, 25 Nov 2026, rev 2 (hashes below) | Integrated 0.57.3 (`feat/batch-b-art-0573`); visual acceptance pending a human playtest |
| ART-08 | Created | Claude (Batch B, assigned by the user 23 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/customers/t001_mara.png`, `art/customers/t002_relu.png` (rev 2) | 23 Nov 2026 (rev 1 + rev 2) | **Approved** by the user, 25 Nov 2026, rev 2 (hashes below) | Integrated 0.57.3 (`feat/batch-b-art-0573`); visual acceptance pending a human playtest |
| ART-09 | Created | Claude (Batch B, assigned by the user 23 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/props/pc_tower_closed.png` (rev 2) | 23 Nov 2026 (rev 1 + rev 2) | **Approved** by the user, 25 Nov 2026, rev 2 (hashes below) | Integrated 0.57.3 (`feat/batch-b-art-0573`); visual acceptance pending a human playtest |
| ART-10 | Created | Claude (Batch B, assigned by the user 23 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/storage/` (56 files: 14 items x 4 turns) (rev 2) | 23 Nov 2026 (rev 1 + rev 2) | **Approved** by the user, 25 Nov 2026, rev 2 (hashes below) | Integrated 0.57.3 (`feat/batch-b-art-0573`); visual acceptance pending a human playtest |
| ART-11 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-12 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-13 | Not created | Unassigned | — | — | Not requested | Not integrated |
| ART-14 | Created (draft) | Claude (Batch C, assigned by the user 25 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/drafts/ART-14/` (case interior, board), rev 1; hashes in `art/drafts/batch_c_manifest.json` | 25 Nov 2026 | **Pending**: shown in chat 25 Nov 2026; not approved for the game | Not integrated (drafts are not loaded) |
| ART-15 | Created (draft) | Claude (Batch C, assigned by the user 25 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/drafts/ART-15/` (28 board-scale parts, 6 inspection pictures, spot positions), rev 1; hashes in `art/drafts/batch_c_manifest.json` | 25 Nov 2026 | **Pending**: shown in chat 25 Nov 2026; not approved for the game | Not integrated (drafts are not loaded) |
| ART-16 | Created (draft) | Claude (Batch C, assigned by the user 25 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/drafts/ART-16/` (5 tool skins, textures, clamp, bin, 2 effects), rev 1; hashes in `art/drafts/batch_c_manifest.json` | 25 Nov 2026 | **Pending**: shown in chat 25 Nov 2026; not approved for the game | Not integrated (drafts are not loaded) |
| ART-17 | Created (draft) | Claude (Batch C, assigned by the user 25 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/drafts/ART-17/` (dust, paste, fan, 17 damage overlays), rev 1; hashes in `art/drafts/batch_c_manifest.json` | 25 Nov 2026 | **Pending**: shown in chat 25 Nov 2026; not approved for the game | Not integrated (drafts are not loaded) |
| ART-18 | Created (draft) | Claude (Batch C, assigned by the user 25 Nov 2026) / Claude (Opus 5.5, model id claude-opus-5-5), drawn with code | `art/drafts/ART-18/` (monitor, phone frames), rev 1; hashes in `art/drafts/batch_c_manifest.json` | 25 Nov 2026 | **Pending**: shown in chat 25 Nov 2026; not approved for the game | Not integrated (drafts are not loaded) |

Use Not created / In progress / Created for creation; keep creation separate from Human approved, Integrated and
Visually accepted. A reference-only or partly delivered task does not get a checked Created box. Owner
is an assignment, not a credit for producing a file. Replace Unassigned when claimed; record the actual
creator when delivered. Record each file separately if several people/tools contribute.

## Human approval before runtime installation

No art may be pushed into the playable game before a HUMAN approves the exact file revision and use.
Record approver, date, evidence and covered hashes; invalidate approval for changed artwork. A creator,
AI reviewer, checkbox or CI result cannot supply human approval. Draft/reference files stay non-loaded.
Existing references have no recorded runtime-installation approval; their visual-direction acceptance
does not promote them to approved game assets. Preserve approvals/history when the first-day list retires.

## Existing reference credits (not completed production tasks)

| Reference | Original creation attribution | Source / date | Status |
| --- | --- | --- | --- |
| art/references/look-reference.png | OpenAI image-generation tool; directed/edited by Codex (GPT-6; exact deployment and image-model IDs not exposed) | Existing chat output, 23 November 2026; manifest.json records source and hash | Reviewed-for-now visual reference, not production scene |
| art/references/counter-room-draft.png | OpenAI image-generation tool; directed by Codex (GPT-6; exact deployment and image-model IDs not exposed) | Existing chat output, 23 November 2026; manifest.json | Room draft; layering/alignment pending |
| art/references/counter-foreground-draft.png | OpenAI image-generation tool; directed by Codex (GPT-6; exact deployment and image-model IDs not exposed) | Existing chat output, 23 November 2026; manifest.json | Foreground draft; storage geometry pending |
| art/references/clipboard-draft.png | OpenAI image-generation tool; directed by Codex (GPT-6; exact deployment and image-model IDs not exposed) | Existing chat output, 23 November 2026; manifest.json | Clipboard draft; production alignment pending |

Codex copied these PNGs unchanged into the reference folder in 0.56.2; copying is not new artwork.
Do not claim Claude or Gemini made these reference files. Future derivatives retain these references
in their source notes while crediting the actual new creator/editor.

## Per-delivery record (append, do not erase earlier credits)

- ART ID / asset name:
- Creation status; corresponding checklist checkbox:
- Files and branch/commit or content hash:
- Original creator (human or assistant/model/tool; exact IDs when exposed, otherwise unknown):
- Date created:
- Method (drawn, generated, rendered, edited); reference/source filenames:
- Each subsequent editor + date + what changed:
- Canvas / dimensions / alpha / anchors / states / lighting manifest:
- Human approval status (Not requested / Pending / Approved / Revisions requested):
- Human approver, date, evidence and exact covered file hashes/revision/use:
- Subsequent changes needing renewed human approval:
- Integration status, integration commit and any actual in-game/visual check:
- Remaining work:


## Delivery — Batch B counter items, ART-06 to ART-10 (0.57.3)

- **ART IDs / assets:** ART-06 clipboard (lying on the counter + picked up), ART-07 ticket clipboard close-up skin,
  ART-08 Mara V. (`t001_mara`) and Relu D. (`t002_relu`) neutral sprites, ART-09 closed customer tower PC,
  ART-10 storage pictures (PC tower, compact PC, GPU, RAM, CPU, cooler, PSU, HDD, SSD, vacuum, brush, pick,
  cloth, syringe; four quarter turns each).
- **Creation status:** Created; checklist boxes ART-06 to ART-10 ticked in 0.57.3.
- **Assignment:** the user, 23 November 2026, chose "Batch B: counter items" for Claude ("chat will be working on
  the other one": Batch A goes to ChatGPT).
- **Original creator:** Claude (Opus 5.5, model id claude-opus-5-5), drawn with code. No image-generation model was used: every pixel is drawn by Python/PIL code
  (aliased shapes, hand-placed details, an outline pass and a fixed top-left light pass; the parts are drawn at
  4x and reduced). Editable source: `tools/art_batch_b/` (`px.py`, `storage_items.py`, `parts_comic.py`,
  `props.py`, `people.py`; `sheets.py` rebuilds the review sheets). The sources regenerate these exact bytes
  (checked 25 November 2026: 90 regenerated PNGs identical to the reviewed outputs).
- **References:** character data in `scripts/data/customers.gd`; footprints in `storage_data.gd`,
  `hardware_catalog.gd`, `storage_sources.gd`; scale was judged on a mockup over the user's room draft and Codex's
  `art/references/counter-foreground-draft.png` (backdrops only; nothing copied from them into these files).
- **Revision history:**
  - rev 1, 23 November 2026 20:26 (Bucharest): all five tasks shown to the user as four review sheets.
    User feedback, 20:33: "soo you need to refine the tools, and the vase/clipboard. Parts are supposed to be in a
    completely different style; comic book but semi-realistic. for the customer, the headphones are the wrong
    way around." Status: revisions requested.
  - rev 2, 23 November 2026 20:38, by the same creator: parts redrawn as illustrated comic-book, semi-realistic
    pictures (inked, gradients, glints, hatching, 1:1 at 44 px per cell; the GPU tilted to show its fans); the
    five tools redrawn in refined pixel art; the lying clipboard redrawn flat and turned, clip lever lying down;
    the picked-up clipboard given a lever; Relu's headphone band moved behind the neck with the cups resting
    on his collarbones. PCs stayed pixel art (offered to the user; not asked to change).
- **Manifest:** pixel art is native 640 x 360 scale shown at exactly 2x with nearest filtering; light from the
  window (left/top-left); transparent backgrounds; no text, logos or fault labels in any pixel.
  - Customers 120 x 172: bottom edge = waist, placed on the counter-top line (y 410), centred on the window.
  - Clipboard lying 54 x 36 (centred in the TicketClipboard hotspot); picked up 36 x 48 (hover).
  - Ticket skin 300 x 350 shown 600 x 700; writable paper `CLIPBOARD_PAPER` = Rect2(56, 136, 488, 492) of the panel.
  - Customer PC 64 x 98; anchor = bottom centre on the counter top (456, 440).
  - Storage: parts 44 px per cell at 1:1; PCs and tools 22 px per cell at 2x; `_r1` = a quarter turn clockwise of
    `_r0`; the light stays top-left in every turn; each file exactly fills its footprint.
- **Human approval:** **Approved.** Approver: the user (creative director), 25 November 2026 19:53 (Bucharest), in
  the Claude Code session that produced the art, replying to the rev 2 sheets and the question whether Mara and
  Relu were heading the right way and whether customers should be bigger: "they are heading the right way, and
  you can add this art to the game. I think they are big enough". Covered: every rev 2 file listed below, for the
  uses in the manifest above (counter, ticket close-up, under-counter storage).
- **Subsequent changes needing renewed approval:** none. Any pixel change to these files needs new approval.
- **Integration:** 0.57.3 on branch `feat/batch-b-art-0573` (commit and PR in CHANGELOG 0.57.3). Automated checks
  only (Godot 4.7.2 headless CI); no human in-game visual acceptance yet.
- **Remaining work:** human playtest/visual acceptance; the stock room still draws plain boxes; NVMe drives have no
  storage picture yet (they keep the box); room placement will move to Batch A's anchors when ART-01 lands.

| File | Size | Mode | SHA-256 (approved rev 2) |
| --- | --- | --- | --- |
| `art/customers/t001_mara.png` | 120 x 172 | RGBA | `7cd9d76dc256b6cbe0aafc7a87d70776e45879c6c530a99b01e284ca85bbba03` |
| `art/customers/t002_relu.png` | 120 x 172 | RGBA | `8f2230b615b9f1f692d1ea366b5fbf45c7cdc4533f1e0999cba31fa9fe7a02b8` |
| `art/props/clipboard_resting.png` | 54 x 36 | RGBA | `9794227e42f05a669b804eaa3c5b15a907726125b653a1da2b6ae5a8f63fcc1d` |
| `art/props/clipboard_upright.png` | 36 x 48 | RGBA | `5fa0a71762a53a81082a0354bc6efc9ad1801c2736495a5d9b320e8373e0aacf` |
| `art/props/pc_tower_closed.png` | 64 x 98 | RGBA | `f77421a54654928b642b9c0596bb75b5af6cd805ba3c11a3f16eeacb0fd4e057` |
| `art/ui/ticket_clipboard.png` | 300 x 350 | RGBA | `2003729796b9ace818a2a150323355e37e7b07d804292a1a8f157caefdf6a649` |
| `art/storage/brush_r0.png` | 66 x 22 | RGBA | `1f06ba06d34926041194417fb0b8209c499967062c9c5781e594294403746052` |
| `art/storage/brush_r1.png` | 22 x 66 | RGBA | `fb2c7d2eea44904e470c9bff9423fa35145b8e257d439ad2955f616876768ded` |
| `art/storage/brush_r2.png` | 66 x 22 | RGBA | `fbb8ae0e1c3b0d7962bd485d11fa1198c9f77da05d619161f98a4b6553b0f830` |
| `art/storage/brush_r3.png` | 22 x 66 | RGBA | `6d288c309e3f245ea8327877114e49aeede232fbe8871a8abf26777e878dada7` |
| `art/storage/cloth_r0.png` | 44 x 44 | RGBA | `ff131c5fd1f4640a50d41c9116b5f385f724f018c3e113d0f5d0f37c3d4a3512` |
| `art/storage/cloth_r1.png` | 44 x 44 | RGBA | `405741800cd2cc1b77a6ce0bf74d8f45c39dcf5001466f8e552c1c8ff945bd5c` |
| `art/storage/cloth_r2.png` | 44 x 44 | RGBA | `768e6ba23db34d75a6c7888eb9609cb94a290c0bc84a60d82ddebf92ee9ddc07` |
| `art/storage/cloth_r3.png` | 44 x 44 | RGBA | `1633a87f62de1e9ab9ac91c52daf221350d9ea038e9fd7a048c07010fbf63658` |
| `art/storage/cooler_r0.png` | 88 x 88 | RGBA | `dbcf0a961460d2c70f9c0c6d9d879ee10ba5a8bc12d341fb5054de5309ce82ca` |
| `art/storage/cooler_r1.png` | 88 x 88 | RGBA | `6265a67a94247fb0581130103378c5f0a9d0ed19a25be223b07ddfe0a2e9ffbc` |
| `art/storage/cooler_r2.png` | 88 x 88 | RGBA | `db61788f31053c49057deb0e6757725273e12b71875444260046f7947ed12f61` |
| `art/storage/cooler_r3.png` | 88 x 88 | RGBA | `a757c84a3b7003869f3b8e953d4ce29455e9329b6e4489594c0868363065b598` |
| `art/storage/cpu_r0.png` | 132 x 132 | RGBA | `11074722f355ed053c6a1c9910b2c3453c9ceaec5a2af5d61c2a89bbee49e92d` |
| `art/storage/cpu_r1.png` | 132 x 132 | RGBA | `794c5b588d8980c8835d1b76b718c5d82150ed6578a4896c1bd560fbaf606876` |
| `art/storage/cpu_r2.png` | 132 x 132 | RGBA | `4b6637e780bd5e28ae7a21ba8ba0c5b41e8975d6b0532d508e974c01e530d63b` |
| `art/storage/cpu_r3.png` | 132 x 132 | RGBA | `fb2e194fce7feb015114dc722a5a500fbb4cc1b1337164aafae1a3c372ea9bf6` |
| `art/storage/gpu_r0.png` | 352 x 44 | RGBA | `f3802d5a3574994154bf8e6bba3e5da6e9bbf3a09623fe377ae5b207ee118877` |
| `art/storage/gpu_r1.png` | 44 x 352 | RGBA | `a862a9d1ed31c54932c162d5c0f7d769aa5e2c58bd4808a57b27ad12c5bd08b4` |
| `art/storage/gpu_r2.png` | 352 x 44 | RGBA | `39a314a51741e7861f8d7f384284f4ce3986c98ac6ed9fe17559cda9b3ee217b` |
| `art/storage/gpu_r3.png` | 44 x 352 | RGBA | `e1d1944431e377041a179457b07c39967279b42975023b6503468a46b7724264` |
| `art/storage/pc_compact_r0.png` | 154 x 110 | RGBA | `0406250f523a41a25cdc29c393493a2b25f691bf55176d6fdeec4100147b4d6b` |
| `art/storage/pc_compact_r1.png` | 110 x 154 | RGBA | `7f7c956b08c5157a429894330aec5657530c538ac747a25da4ec1ed8c9554f03` |
| `art/storage/pc_compact_r2.png` | 154 x 110 | RGBA | `2b5db3b30c51a31c2664be8cbb3e1a9df03a0d93e3ef06f06a35de662609883e` |
| `art/storage/pc_compact_r3.png` | 110 x 154 | RGBA | `b2d7ac1d75bcc0351bb9091693c016d1f10518bfa575275f4062f9e54538ba8e` |
| `art/storage/pc_tower_r0.png` | 176 x 132 | RGBA | `bbedc2eeb5779659e99a181a450adb9ac5f7ff7415400ae241afde19706c531d` |
| `art/storage/pc_tower_r1.png` | 132 x 176 | RGBA | `da1bab2c60d9df54e70fe804c06a8e4329c62c8744b57845e0632c23fb0ff79f` |
| `art/storage/pc_tower_r2.png` | 176 x 132 | RGBA | `056905239180c661aed521e067a97ede6ccea9e0490dcfa4873270783f5b1e6d` |
| `art/storage/pc_tower_r3.png` | 132 x 176 | RGBA | `3652f59b031feb3707e807ff58c378d02714d03d484941b7a8e5af2d8e043b7e` |
| `art/storage/pick_r0.png` | 44 x 22 | RGBA | `9284589b092238aecb95127e3a725e01f0c6c13cf21f60012b72ed75b41aa5d8` |
| `art/storage/pick_r1.png` | 22 x 44 | RGBA | `c8667d73bd52a34c96a3ca4debce6aa2d55d0aacdca6a0de56036fe1d05a0fa5` |
| `art/storage/pick_r2.png` | 44 x 22 | RGBA | `e1880f4fb473f823b87c762fdc3adb200eb9aa0acd8a92291d999ee5654f0c97` |
| `art/storage/pick_r3.png` | 22 x 44 | RGBA | `1e1cf93862d3a93053a1acef394af9fb0401a57ff955ee31e6ae741ae20972fd` |
| `art/storage/psu_r0.png` | 132 x 88 | RGBA | `0dd7a8f2ec004155b4174b9f3462ed5df5795f5675d10993e37bb35dd4e517cc` |
| `art/storage/psu_r1.png` | 88 x 132 | RGBA | `a0da349ff454c15b5b1a4293d2663f76ba86898f9925dca0093e063e397ed48f` |
| `art/storage/psu_r2.png` | 132 x 88 | RGBA | `b0ed7b14b247ee97da92dfee6fb840bdf90c2e57e1fe705f7dc650c9cc123a61` |
| `art/storage/psu_r3.png` | 88 x 132 | RGBA | `85b7c75ba27b8b922be7e0de317c428378709891486af3df76b3fd471ff3df9b` |
| `art/storage/ram_r0.png` | 44 x 176 | RGBA | `009d923974c0afc7ceef65f9d6db5b6c805973200f2c2b838fe52bbe1034d706` |
| `art/storage/ram_r1.png` | 176 x 44 | RGBA | `8872c217bbdbbf97384d9f65f9a8dcfc5faf93bb420eb268c81e1e0a7c8bd64a` |
| `art/storage/ram_r2.png` | 44 x 176 | RGBA | `941f248862127262e24d0211cb4542e36a093a79199df5afac196e49a19cc49c` |
| `art/storage/ram_r3.png` | 176 x 44 | RGBA | `8a779a8b450312ff90a30369be30f0ed456e48c4cb78643985eea76955285cc6` |
| `art/storage/storage_hdd_r0.png` | 88 x 44 | RGBA | `ca89c9c7d94b7575ae76dda19f2618c0fca641cd97c1eea6e5665cd05a53fc77` |
| `art/storage/storage_hdd_r1.png` | 44 x 88 | RGBA | `26a1abc1ae8a8881758b3944c5f4993cf22e3c8fd2e28a6855a6ab0d0b471d1b` |
| `art/storage/storage_hdd_r2.png` | 88 x 44 | RGBA | `eca8553db5d65408a58157e32862e1b3aa4043afceb87cad4af052008f640554` |
| `art/storage/storage_hdd_r3.png` | 44 x 88 | RGBA | `4cd4bce3ef9157cb6ebd49b20b2a6a28c68957fb7b6f4d214cd9e73a45600fed` |
| `art/storage/storage_ssd_r0.png` | 88 x 44 | RGBA | `1680aa1795649ceeb40f710ebe0a38ded38041bff262b14209d3eab49d294bb7` |
| `art/storage/storage_ssd_r1.png` | 44 x 88 | RGBA | `6d8f3f7ccd26f897e2c0f50bd92fe808c09d8c46942efc5cdf0deff5d719dbb7` |
| `art/storage/storage_ssd_r2.png` | 88 x 44 | RGBA | `4b99a12d4d9713dadf64aee9eb76486e9f2f798887d16b43a7dcbfd33ac3a684` |
| `art/storage/storage_ssd_r3.png` | 44 x 88 | RGBA | `50af284d60c0acf70a890e431fe815b14ce5a30dee9b021aa936afb7f47eaa9a` |
| `art/storage/syringe_r0.png` | 22 x 44 | RGBA | `4624bfd482c5a8dc0d97218c886cba56eac8e85cd1f86483cea22b427c5ac4e5` |
| `art/storage/syringe_r1.png` | 44 x 22 | RGBA | `dc1c06c234d9f095ee7bd2c1e2827e6e2a2237fd7ecc489797f4a28fa1acde87` |
| `art/storage/syringe_r2.png` | 22 x 44 | RGBA | `bda8dea3d13896e52038cde3770eb79285c908ef5c97ded582a27b554aacd80a` |
| `art/storage/syringe_r3.png` | 44 x 22 | RGBA | `b26374a2f4984f27deffc4a591b08f46f262ccc9a14aadde1474389deb19c065` |
| `art/storage/vacuum_r0.png` | 88 x 44 | RGBA | `e23dd3103944f7cafc1a61b29619e66f415de39d24abe08a9b43b784d5477b95` |
| `art/storage/vacuum_r1.png` | 44 x 88 | RGBA | `76c72773af498c08e42458304e34b2555409e38276fdca65646415dd83833f38` |
| `art/storage/vacuum_r2.png` | 88 x 44 | RGBA | `a34c87ecafa820b7e7380a8190ab5ec41a56b8e3172b3e384c16c1106e10f9a5` |
| `art/storage/vacuum_r3.png` | 44 x 88 | RGBA | `25f22fc0fde76e8e27308cfbf5d8c672f24cff2a0319e0581b7b5c89c6ef0cb6` |

## Delivery — Batch C drafts, ART-14 to ART-18 (0.57.6, pending approval)

- **Assignment:** the user, 25 November 2026, chose Batch C = ART-14 to ART-18 for Claude ("ART-14 to
  ART-18 (Recommended)"; ART-13 stays with the room work), then asked for a PR with all the new graphics.
- **Creator:** Claude (Opus 5.5, model id claude-opus-5-5). Drawn with Python/PIL code, no image model.
  Source: `tools/art_batch_c/` (shares helpers with `tools/art_batch_b/`); it regenerates all 81 files
  byte-identically (checked 25 November 2026). The shared helper gained tuple colours only; the approved
  ART-10 bytes were regenerated and are unchanged.
- **Style:** comic-book, semi-realistic for hardware, the case/board, tools and layers (D168); the monitor
  and phone frames are pixel art at 2x. Tools are illustrated because the bench turns them in 15-degree
  steps (proposal; the user has not decided yet).
- **Files:** `art/drafts/ART-14/` to `ART-18/`, 81 files; exact sizes and SHA-256 in
  `art/drafts/batch_c_manifest.json`. Review sheets: `art/drafts/batch_c_review/` (mockups only).
- **Manifest:** case 18 x 16 cells and board 10 x 10 at 64 px per cell (master; the game scales to its cell);
  board parts the same; inspection pictures 900 x 600 for the 450 x 300 bay panel with lens spot fractions in
  `inspect_spots.json` (names match PartCondition.SPOTS); tool sprites 160 x 200 at 2x, origin (80, 100), tip
  (44, 148) = Rig.TIP; damage overlays share the inspection canvas and sit on their spot; PSU "smell" has no
  picture; phone 200 x 300 and monitor 439 x 287 native at 2x with transparent screens.
- **Revision history:** rev 1 only (round 1 shown 25 Nov 2026 ~20:55, round 2 ~21:10 Bucharest).
- **Human approval:** Pending. Open questions put to the user: tools illustrated on the bench; the drive's
  label clue drawn as an illegible scribble ending in "??"; the small crack on the phone frame.
- **Integration:** none. Needs the user's approval first; then code in the repair bench / tool files
  (single-owner hot files per WORK_PLAN) and per-kind lens spot positions in the testing bay.
