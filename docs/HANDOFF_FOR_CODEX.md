# Handoff to Codex — what happened since your 0.11.0

Written 2026-11-13 by Claude (Opus 5.5, model id claude-opus-5-5), for the user to give to Codex.
Version at handoff: **0.15.1** (main branch). Your last version was **0.11.0** ("Tabletop throws, flexible
brush and shared replacement stock", 2026-11-12, Codex in ChatGPT workspace, source ZIP). Between
0.11.1 and 0.14.1 the work was done by Claude (Sonnet 5.5, model id claude-sonnet-5-5), and from 0.14.2
by Claude (Opus 5.5, model id claude-opus-5-5). Every version has a full entry in `CHANGELOG.md`.

## 1. How the project is run now (changed since you left)
- **Repository:** `https://github.com/123rearearcode/nighshift_real` (not the older `Nightshift` repo named in
  PROJECT_BRIEF.md). `main` is the integrated baseline. Work happens on a branch and arrives by pull
  request; Claude may merge into main (user permission, D51). The user also still gets a ZIP per version.
- **Godot 4.7.2 is the real engine** (your 4.6.3 runs were close but not the target). GitHub Actions now runs
  on every push, on Godot 4.7.2 headless: `tools/check_project.py`, `tools/test_data_schemas.gd` (179
  checks), `tools/test_regressions.gd` (about 440 checks) and `tools/playtest_bench.gd`, a scripted playtest
  that drives the real bench with a scripted pointer and real mouse events and prints tables (it never
  fails the build). The user playtests by hand; that is still the only check of feel and looks.
- **Old versions** stay as `archive/vX.Y.Z` branches until the user confirms a later playtest.
- **New rule (D51, 0.14.3):** every AI edit is signed with name, model name and exact model id: changelog
  Author line, HANDOFF signature, commit messages. Example: `Codex (<model name>, model id <id>) in ...`.
  `tools/check_project.py` fails the newest changelog entry without it. Please give your exact model id.
- Unchanged: version bump per delivery, changelog template, file map in DEVELOPMENT.md, no claims of
  testing that did not happen, parody brands only, proposals marked as proposals.

## 2. What changed in the game (0.11.1 – 0.15.1), in short
- 0.11.1–0.11.3: `bench_view.gd` split step 1 (paste drawing to `paste_renderer.gd`, cleaning drawing to
  `cleaning_renderer.gd`, mount state to `mount_session.gd`), safe save writing with .bak/.tmp recovery,
  engine version corrected back to 4.7.2.
- 0.12.x: brush fixed and turned into a sweeping tool; paste gauge counts the CPU only; tools rotate;
  automated tests and data-schema checks; GitHub Actions.
- 0.13.0: the brush **tosses** dust (slides, settles elsewhere on its part) and chips specks; only the
  vacuum removes dust; nothing can be carried out of its area; floating dust motes (cosmetic); a physics
  **vacuum hose** to a **dust bin** that fills and must be emptied by clicking it.
- 0.14.0–0.14.2: tools and loose parts **collide** as rotated boxes (gentle knocks); hose lies round pieces,
  has a length limit with a soft tug, can be right-dragged out of the way, is see-through and shows dust
  riding to the bin; "longer hose" shop upgrade ($40); turning tools with the **middle mouse** (wheel or
  drag) or Q/E; the clogged filter's dust grips 1.5x harder (a feature); a bug where a left click picked
  up the tool next to the held one was found by the scripted playtest and fixed.
- 0.15.0: **Complete repaste** button (only after a PERFECT or GOOD ENOUGH mount; thermal paste costs $3;
  the final check counts the paste only once completed); **toothpaste** as a free scam option (stiffer,
  +14 C, passes today's check, the customer still pays, recorded in `job.scams`); paste gauge and grade
  lines retuned from the playtest table; dust bin 90 -> 140 units; design documents updated.
- 0.15.1: the cooler is secured by physically clicking a **retention lever** beside the socket (the
  Secure button and the Enter shortcut were removed; running out of time no longer secures it).
- All numbers are proposals. Fans moving dust under parts were planned and are postponed (D56).

## 3. Where the design stands
Read `docs/DECISIONS.md` (new D45–D56), `docs/DESIGN.md` sections 18–19, `docs/ROADMAP.md` (position
after 0.15.0) and `docs/DESIGN_PROPOSALS.md` section 5. In one line: the bench is close to finished; next the
user wants to push the **scam direction** (cheating customers through the hands-on work itself, with
consequences) and give the **dust minigame** a further purpose. Neither is designed yet.

## 4. What the user will ask you
A design pass, not code: see `docs/DESIGN_AGENT_PROMPT.md` (the user pastes it to you). Expected output is a
proposal document the user can decide on. If you have repository access, put it on a branch
(`design/scam-direction`) as `docs/SCAM_DESIGN_PROPOSAL.md` with a changelog entry and open a pull request;
do not change game code or merge. Without repository access, return the document as a file.

## 5. Things to know before proposing
- The scam must be performed with the same tools as honest work (toothpaste uses the same syringe and the
  same minigame). The user likes physical, hands-on interactions (lever instead of a button).
- D18: discovery is persona-based probability for now; evidence-based detection is not approved.
- Customer-owned parts stay the customer's (D19); the pick can damage parts; budget replacements exist.
- Day/night structure (D07/D10) is decided; the trial only has one practice ticket and a stand-in shop.
- `job.scams` exists as a record but nothing reads it yet: a good place for consequences to start.
