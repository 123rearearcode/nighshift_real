# Cable box — design and what is built (D173)

Status: **built in 0.58.3** (rules, file, physics view, rooms, store supplies), with placeholder drawings
until the box and cable art is approved (D167). Written by Claude (Opus 5.5, model id claude-opus-5-5) from
the user's decisions of 27 November 2026; the user asked Claude to build it ("you can go ahead and create
the cable box").

## What the user decided (27 November 2026)

- The cables are kept in a **cable box** (user: "The drawer is going to be called a ''cable box''").
- There is **one** box (user, answering: "There is one").
- The box **can be moved from room to room**. It is the first piece of **multi-room inventory management**,
  which the player can **automate later** (user: "I kinda want multi-room inventory management to be a
  thing, which the player can later automatize"); that automation will be tied to **the van's trunk and the
  outside** (user: "Well into this system I would tie the whole trunk/outside thing"). Not built yet.
- The box is **openable** and shows the cables **in their real state** (loose, tied, knotted, broken).
- **Tangles happen when the box is moved with loose cables inside.** Tied cables never tangle.
- The untangling minigame is **physics-based**.
- **Cables can break** (user: "Yes, they can break").
- The shop sells things that help.
- Scams/deception: **only customers who claim the shop lost their cable** (user: "I dont wanna go too into
  techincal detail"). No counterfeit-cable or wire-gauge scams. Not built yet.
- Cables for now: the 24-pin motherboard cable and the 8-pin graphics card cable (the connector drafts in
  `art/drafts/connectors/`, review sheet c9, are still awaiting approval).

## What is built (0.58.3)

- **Rules** (`scripts/rules/cable_box.gd`): a new box holds five loose cables (two 24-pin, three 8-pin) in
  the workshop. Putting it down in **another** room gives every pair of loose cables a chance to knot
  (higher with more loose cables, at most two knots per pair; the same move always tangles the same way).
  Each knot has, for each of its two cables, one **open plug**: pulled by that plug, the cable comes out;
  pulled by the other, the knot strains, and at full strain the cable **snaps** (broken, its knots fall
  apart). Tied cables cannot be knotted; a knotted or broken cable cannot be tied.
- **Ties** from the store down the street: **zip ties** (pack of 10, $4; cut off when untied, used up) and
  **velcro straps** (pack of 4, $12; returned to the box when untied). Broken cables can be thrown away.
- **The file** (`scripts/state/cable_store.gd`): `<save>.cables.json`, per playthrough (a new game gets a
  fresh box), and part of the morning backups (D172).
- **The rooms**: the box stands in the counter (on the worktop, left), the workshop (on the floor under the
  hardware board) or outside (next to the van). Click it to open it; "Carry the box" takes it with you; in
  another of those rooms "Put the cable box down here" sets it down (and the loose cables shift).
- **The open box** (`scripts/view/cable_box_view.gd`): each loose cable is a verlet rope (points held a
  fixed distance apart, floor friction, box walls). Grab a plug and pull. Pulled by its open plug, the cable
  is drawn through the knot until its far end slips out (well under a second at a full pull); pulled by the
  other plug the knot ring turns red and the cable snaps after about three seconds of full pull. A cable
  goes taut rather than stretching. Tied cables lie coiled on the left (black band: zip tie; blue: velcro).
- **Tests**: `tools/test_cable_box.gd` (rules, file, physics both ways, carrying between rooms, store).

## Not built yet

- Using a cable from the box in a repair (the bench's cable routing waits for the connector art).
- The "you lost my cable" customer.
- Automating the box through the van's trunk / outside.
- Untangling costing night minutes (the testing bay does; left out until it can go through the night clock
  rules in GameState).
- The box and cable art (placeholders now).
