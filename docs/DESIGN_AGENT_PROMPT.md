# Prompt for Codex (design pass) — copy everything below the line

**Historical prompt:** its first design pass is complete. For new tasks read D58–D60, SCAM_DESIGN_PROPOSAL.md and MINIGAME_RULES.md first; do not reopen seven accepted concepts or rejected C.

Written 2026-11-13 by Claude (Opus 5.5, model id claude-opus-5-5) for the user. Give Codex this prompt
together with the project (repository access or the v0.15.1 ZIP). Codex worked on this project up to
0.11.0; `docs/HANDOFF_FOR_CODEX.md` tells it what changed since.

---

Hi Codex. You worked on Nightshift before: your last version was 0.11.0 (tabletop throws, flexible brush,
shared replacement stock). The project is now at **0.15.1** and lives in the GitHub repository
`123rearearcode/nighshift_real`. Claude built 0.11.1 to 0.15.1 since then.

**Read first, in this order:** `docs/HANDOFF_FOR_CODEX.md` (what changed since your 0.11.0 and how the
project is run now), `docs/DECISIONS.md` (D45–D56 are new), `docs/DESIGN.md` sections 18–19,
`docs/ROADMAP.md` (the "Position after trial 0.15.0" section), `docs/DESIGN_PROPOSALS.md` section 5, then
the 0.15.0 and 0.15.1 entries in `CHANGELOG.md`. If you have the code, `scripts/data/paste_materials.gd`
and `GameState.complete_repaste` show how the toothpaste scam works today.

**This time I need design help, not code.** The repair bench is almost finished. Next I want the game
to go further in the **scam direction**: cheating customers through the hands-on repair work itself, with
the same tools as honest work, and with consequences. The first example is already in: you can secretly
use toothpaste instead of thermal paste (free, passes today's check, runs hotter, the customer still pays;
the job records it in `job.scams`, but nothing reads that yet). I also want to give the **dust minigame**
a further purpose or twist, and I have not decided what.

**Please deliver one proposal document** with these parts:
1. **Hands-on scams (5–10 ideas)** that fit the bench as it is now: cleaning (dust under parts, the
   filter), paste, removable cooler/GPU, budget replacements, the risky pick. For each: what the player
   physically does, what they gain (money, time, stock), what could go wrong, and how a customer could
   find out. Mark which ones need nothing new except data, and which need a new system.
2. **Discovery and consequences, first version:** consistent with D18 (persona-based chance for now; no
   evidence system). Cover delay (for example toothpaste drying out over days), comebacks, refunds, trust
   versus closeness (D15), shop reputation (D16). Say exactly what reads `job.scams` and when.
3. **Keeping honesty worth it:** how honest work stays a real, rewarding choice.
4. **Dust minigame purpose:** 3–5 ideas in two or three sentences each, one recommendation with reasons,
   and whether it ties into scams (for example what a customer can and cannot check).
5. **Smallest fun version:** which 2–3 items you would build first in the trial, in what order, and which
   files they would touch (from `DEVELOPMENT.md`'s file map), so Claude can implement them later.
6. **Questions for me**, most important first.

**Rules:**
- Do not contradict a confirmed decision; if you think one should change, say so separately with reasons.
- Anything I have not approved is a PROPOSAL; numbers are examples only.
- Plain words, short sections; I am a beginner. No code in the document.
- Parody brands only; no invented lore, real brands or real people.
- **Sign the document and its changelog entry with your name, model name and exact model id** (project
  rule D51), e.g. `Codex (<model name>, model id <id>) in <where you ran>`.
- **Delivery:** with repository access, create branch `design/scam-direction`, add
  `docs/SCAM_DESIGN_PROPOSAL.md`, list it in `DEVELOPMENT.md`'s file map, add a patch-version changelog
  entry (0.15.2, docs only; follow the template and run `python3 -I tools/check_project.py`), and open a
  pull request. Do not change game code and do not merge. Without repository access, return the document
  as a file and I will pass it on.
