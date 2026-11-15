# Salvage variety — 0.31.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
15 November 2026, Europe/Bucharest. User-approved D113; independent unmerged PR.

## What changes

Enter Salvage demo from the start screen in this main-based branch. Choose a car/site and travel.
Every arrival creates a new random pile: count, root positions, small tilts, container dimensions,
parts, condition/tier rolls and concealed contents vary. Office disposal still favors computer
hardware; household waste has more rubbish. The old fixed four-column pattern and site/cycle seed
are gone. When merged with the separate night-flow PR, its activity wrapper reuses this same code.

Fourteen collectible types: PC, GPU, RAM, PSU, drive, CPU, motherboard, cooler, fan, SSD, HDD,
Wi-Fi adapter, sound card, network card. Their footprints/rotation work in the trunk; known condition
stays untested. New salvage types do not automatically become usable repair parts or supplier stock.
That bridge and the full part catalogue remain separate work. Names are generic, no real brands/lore.

Concrete blocks and heavy appliances are obstructions, not loot. They have HEAVY markings and
hover hints. They use ordinary gravity/collisions, can settle or fall when support moves, but the
player's bounded grip cannot lift their weight; it can at most nudge or slowly tip them. Work around
them. They cannot be packed, flattened by opening or changed into lightweight container shells.
Grip preparation cost (3 demo minutes), dimensions, masses and all odds are provisional tuning.

## Exactly when the dump changes

- Successful departure/arrival at a site: new pile and new unique IDs, even on the same night.
- A second departure click while already there: rejected, no reroll or extra travel charge.
- Open a box/bag/PC: reveal its actual pre-generated children, no new random rewards.
- Return to menu while on site, then reopen salvage: resume that active visit, no reroll.
- Drive home, then return: pay existing travel again; unclaimed leftovers/sorting items are abandoned.
- Cargo and demo shelf keep their existing records across arrivals, including a packed PC's children.
- App exit still ends this standalone demo session; campaign save/inventory integration is unchanged.

This changes the earlier approved/proposed few-day persistent-pile rule at the user's request.
Refresh-period fields remain only as legacy/debug metadata; UI no longer advertises a schedule.

## Implementation and performance boundaries

Generation uses its own randomized RNG. Explicit seed_override + visit + identity_prefix can reproduce
a report; `pile.spawn_seed` records the seed. Normal IDs also include a random session nonce and
monotonic visit serial, so cargo cannot accidentally match a freshly generated find.

Root kinds/counts are randomized and shuffled using that RNG. A bounded candidate search drops
rotated bounding hulls onto available skyline spaces, with margins. It skips a root if no safe slot
exists. Up to 64 total root/hidden records, with reserved slots for remaining roots: new variety cannot
create an unbounded physics population. Only exposed contents become native bodies. The cap applies to generated records; unpacked car
cargo can add further bodies within the separate trunk-capacity bound. Opening stacks
box/PC contents upward and clamps revealed shapes to the appropriate bin/sorting side of the rim.

Heavy bodies use mass/friction and weaker bounded force/torque, not freezes. Ordinary parts keep the
existing mouse grip, collisions, sleep and rim protection. New thin parts use continuous collision
checks. No frame-time or target-hardware performance claim; the record cap is a structural bound.

No new runtime files: Data, Pile, Body, Session and View stay in scripts/salvage. Tests extend the two
existing salvage suites. No edits to bench_view.gd, tool_rig.gd, game_state.gd, customer code or saves.

## Handoff

Based on main 0.29.0. The independent inventory/night branches and their local patches belong to pending
PRs; they are not included or pushed here. This new PR is separate and must not be auto-merged.
Claude cross-reviews generation bounds, identity/cargo and heavy-body feel next. Reconcile version
metadata if other PRs land first. A release balance pass and user graphical playtest remain required.
