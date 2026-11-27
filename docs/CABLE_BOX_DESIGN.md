# Cable box — design notes (proposal for building; decisions recorded in D173)

Status: the user's decisions of 27 November 2026 are recorded here. Nothing is built yet. Written by Claude
(Opus 5.5, model id claude-opus-5-5). Gameplay features are Codex's lane in `docs/WORK_PLAN.md`; whoever
builds this follows the decisions below and brings anything still open back to the user.

## What the user decided (27 November 2026)

- The cables are kept in a **cable box** (user: "The drawer is going to be called a ''cable box''").
- The box **can be moved from room to room**. It is the first piece of **multi-room inventory management**,
  which the player can **automate later** (user: "I kinda want multi-room inventory management to be a
  thing, which the player can later automatize").
- The box is **openable** and shows the cables **in their real state** (loose, tied, tangled).
- **Tangles happen when the box is moved with loose cables inside.** Tied cables never tangle.
- The untangling minigame should be **physics-based**, if possible.
- The shop sells things that help (from Claude's proposal, not each confirmed: zip ties, velcro straps,
  labels, an organiser box with slots, later a pegboard).
- Scams/deception: **only customers who claim the shop lost their cable** (user: "I dont wanna go too into
  techincal detail"). No counterfeit-cable or wire-gauge scams.
- Cables for now: the two power cables already drawn for review (24-pin motherboard, 8-pin graphics card;
  `art/drafts/connectors/`, review sheet c9). They are reused as the cables inside the box.

## Proposed rules (to confirm while building)

- The box is an item with a place: it sits in one room (workshop, counter, under the counter, the van) and
  is carried to another by the player. Carrying it is one move; every move shakes it.
- Each loose cable in a moved box gains tangle with the cables it touches; a tied cable (zip tie, velcro) is
  a closed bundle that cannot tangle. Opening the box costs nothing; untangling costs night minutes, like
  the testing bay.
- To take a cable out, it must come free: pull one end out of the knot without dragging the others along.
- Automation (later): a shelf or a helper keeps boxes where they are needed, or a sorted organiser box
  never tangles. Not designed yet.
- The "you lost my cable" customer: a customer insists a cable came in with their PC. The intake slip (or the
  box's own contents and labels) is the evidence; paying them off, arguing or checking the box are choices.
  Follows the existing trust and review rules (D160); no new hidden truth beyond whether the cable came in.

## Physics (feasibility)

Godot 4.7 has no built-in rope. A small **verlet rope** (a chain of points with distance constraints,
gravity, and collision against the box walls and the other cables) is cheap in 2D for a handful of cables of
~20–40 points each, and draws with the cable texture along a Line2D. Knots are approximated by crossing
order: where two cables cross, which one is on top is stored, so pulling a cable that is under others drags
them. This keeps the feel physical while the "is it free?" test stays a simple, testable rule (no crossings
that hold it). Headless tests check the rule and the save state; the feel needs a person playing it.

## Open questions for the user

1. Which rooms can the box go to, and is there one box or several?
2. What does automating it mean to you: a helper who carries boxes, shelves that sort, or something else?
3. Do cables ever wear out or break (left knotted too long, pulled too hard)?
