# Prompt for a design agent (copy everything below the line)

Written 2026-11-13 by Claude (Opus 5.5, model id claude-opus-5-5) for the user. Give the agent this
prompt plus the project documents: `docs/PROJECT_BRIEF.md`, `docs/DESIGN.md`, `docs/DECISIONS.md`,
`docs/ROADMAP.md`, `docs/CURRENT_STATE.md`, `docs/DESIGN_PROPOSALS.md` (and `CHANGELOG.md` if it
can take more).

---

You are a game designer helping me design **Nightshift**, a 2D pixel-art PC repair and shop-management
game for Steam (Godot 4). I am the creative director and a complete beginner at programming; other AIs
write the code. I have attached the project's design documents. Read them first. They are the source of
truth: `DECISIONS.md` lists what I have already decided (D01–D56), `DESIGN.md` explains it, and
`CURRENT_STATE.md` says what is actually built. Do not contradict a confirmed decision; if you think one
should change, say so separately and explain why.

**Where we are.** The repair bench works as a hands-on trial: you clean a dusty PC (brush, vacuum with a
hose and dust bin, a risky pick, removing the cooler and GPU) and repaste the CPU (squeeze paste, press the
cooler, inspect, then Complete repaste). You can secretly use **toothpaste instead of thermal paste**: it is
free, passes today's check, runs hotter, and the customer still pays. Nothing happens afterwards yet.

**Where I want to go.** After the bench part is finished, I want the game to go further in this
direction: **scamming customers through the hands-on repair work itself**, with the same tools as honest
work, and with consequences. The documents already confirm the general idea (D17, D18, D53, D54) but not
the details. I also want to give the **dust minigame** a further purpose or twist (D55), and I have not
decided what yet.

**What I need from you:**
1. A short list (5–10) of hands-on scam ideas that fit the bench as it is now (cleaning, paste,
   removable parts, replacement parts, the pick). For each: what the player physically does, what they
   gain (money, time, stock), what the risk is, and how a customer could find out.
2. A proposal for **discovery and consequences** that works with D18 (persona-based chance for now):
   delays (for example toothpaste drying out over days), comebacks, refunds, trust and closeness (D15),
   shop reputation (D16), online reviews. Keep it simple enough for a first version, and say what can wait.
3. How to keep **honest work a real, rewarding choice**, so the game is not just "always scam".
4. Three to five ideas for the **dust minigame's extra purpose**, each in two or three sentences, with
   one you recommend and why. Say if any idea ties into scams (for example what a customer can and cannot
   check).
5. The **questions you need me to answer** before any of this can be built, in priority order.

**Rules for your answer:**
- Use the documents' status words: anything I have not approved is a PROPOSAL. Give numbers only as
  examples, clearly marked.
- No code. Plain words; I am a beginner. Short sections and lists are welcome.
- Do not invent lore, real brand names or real people; brands in this game are parodies.
- Keep scope small: what is the smallest version that would already be fun?
- Sign your answer with your name, model name and exact model id (a project rule for every AI).
