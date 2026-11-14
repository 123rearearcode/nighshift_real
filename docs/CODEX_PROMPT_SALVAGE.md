# Prompt for Codex — street salvage minigame, DESIGN FIRST (copy everything below the line)

Written 2026-11-14 by Claude (Fable 5, model id claude-fable-5), approved task from the user.

---

Hi Codex. New parallel assignment from the user (it fits our split: gameplay is yours, and it touches
none of the hot files): design, and after the user approves, build the **street / dumpster salvage
minigame** — going outside the shop at night to scavenge parts.

**Read first:** `docs/WORK_PLAN.md` (the split and hot-file rules), `docs/DECISIONS.md` D45 onwards
(especially D76 loose items, D79 graphics power, D88 customers and the new D89: picking things up takes
time, because the night is about managing limited time), `docs/SCAM_DESIGN_PROPOSAL.md` and
`docs/MINIGAME_RULES.md` if present, and the newest `CHANGELOG.md` entry.

**Step 1 — design proposal only** (`docs/SALVAGE_DESIGN_PROPOSAL.md`, a PROPOSAL for the user):
1. The loop: when during the night you go out, what a salvage run costs (TIME above all), what you find
   (parts with conditions and power levels that feed the existing part/replacement systems; maybe loose
   items like the coins of D76), and the risks (junk, broken finds, wasted night time).
2. How finds enter the shop: the hardware bench drawer and the replacement stock are the natural
   landing places; say exactly what records a find needs (kind, tier, condition, power).
3. How it feeds the scam direction (a dumpster GPU sold as new...) and honest play (cheap stock for
   budget repairs).
4. The minigame itself on one screen: physical, tactile interactions in the spirit of the bench (hold
   to pry, drag to dig); simple coloured shapes; parody brands only.
5. Smallest fun version first; open questions for the user, in priority order.

**Step 2 — build it only after the user approves**, under these rules:
- Own scene + own scripts (`scripts/salvage/...`), own test suite, wired into the CI workflow list.
- Do NOT edit `scripts/view/bench_view.gd`, `scripts/bench/tool_rig.gd` or `scripts/state/game_state.gd`.
  If the minigame needs saved state or money movement, write the exact fields you need in the proposal;
  Claude wires them into the save and hands you a reviewed interface.
- Version bump, changelog entry with the template, `python3 -I tools/check_project.py` green, sign with
  name, model name and exact model id, pull request, no self-merge; Claude cross-reviews.
