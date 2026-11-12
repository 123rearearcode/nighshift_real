# Nightshift - Godot Foundation Trial (v0.14.2)

A small playable foundation for the PC repair/shop game. Placeholder shapes and text, one overheating repair ticket, shared player parts storage, tabletop handling and thermal-paste activity. This is not the complete game.

## Open this build
1. Close any running older copy of the game/editor.
2. Unzip `nightshift_godot_trial_v0.14.2.zip` into a new folder. Keep the previous version as a fallback.
3. In Godot Project Manager choose **Import**, select `nightshift_godot_trial/project.godot`, then **Import & Edit**.
4. Press **F5** to open the shop.

Engine: **Godot 4.7.2** is the user's real version (confirmed by the user on 2026-11-12; a brief 4.6.3 claim in 0.11.1 and 0.11.2 was a mistake). Codex's automated checks ran in Godot 4.6.3, so they are close but are not a run on 4.7.2. **Since 0.12.3 the automated checks also run on Godot 4.7.2 itself** (GitHub Actions, headless): 172 data schema checks and 344 regression checks, 0 failures on version 0.12.2. That does not cover looks, feel or mouse and keyboard play. See CHANGELOG.md for exact checks.

## Repair bench: tools and dust
Open **Repair bench** from the shop.

- **1 Vacuum**, **2 Brush**, **3 Move parts**, **4 Dust pick**.
- Left-hold uses a selected tool. The nozzle/bristles follow with gentle lag; their actual contact point acts on dust.
- Right-drag/release tosses a tool. It hops, spins, rebounds off the worktable edges and settles. Click a resting tool or press its hotkey to equip again.
- The brush has bending bristles. Moving it loosens dust and, once loose enough, tosses it: the dust slides and spins across its own part, bounces off the part's edges and settles somewhere else. Long chains also chip off small specks. The brush never removes dust; only the vacuum does. With a tool in hand, a left click always uses it; to swap, press 1/2/4, use the buttons, or click a resting tool with empty hands. Turn the held tool with the middle mouse (spin the wheel, or hold the middle button and drag sideways) or Q/E. The dust filter is clogged: its dust grips 1.5 times harder, so it takes longer to clear (intended). The hose also lies around parts still fitted in the PC.
- A held tool follows the cursor but can never leave the bench, even when the cursor does. Dragged parts are kept on the bench too, and held drawer parts stay inside the window.
- Tools and loose parts on the bench are solid rotated boxes: a held tool or dragged part shoves the others aside, thrown pieces bounce off each other, and heavier pieces (the vacuum, the GPU) push lighter ones (the cloth) more than the other way round. Pieces hopping through the air pass over others.
- The vacuum has a physics hose that runs to the dust bin (bottom right of the bench). It lies around pieces, not through them. It is only 640 px long: when it is taut it tugs the vacuum back (it can stretch at most 4% past its length). The "longer vacuum hose" upgrade in the shop makes it 860 px. The hose is see-through: swallowed dust rides it to the bin and fills the bin when it arrives (with the suction off, it waits in the hose). Right-drag the hose to move it out of the way (a tool in your hand is put down first); it curves round pieces instead of folding sharply. Everything that reaches the bin fills it; when it is full the vacuum stops pulling until you click the bin to empty it. The bin is not saved yet. Faint floating dust drifts over dusty parts and bursts up when the brush kicks dust (cosmetic only).
- In Move parts mode, drag cooler/GPU to the service tray to expose protected dust underneath, then refit. A fast release away from its mount throws the component over the worktable; pick it up at its physical position to recover it.
- The pick inspects trapped dust beneath installed cooler/GPU on hover. Hold for a provisional 0.8-second extraction attempt with 12% damage risk. Hovering alone is safe. Safe removal avoids this risk.
- Removing the cooler clears its paste result. Refit all parts, clean all eight zones to at least 95%, apply fresh paste and pass the shop's final check.

**Dust on entry:** fresh tickets explicitly begin dirty. The bottom line shows ticket id and visible dust-group count. Partially cleaned work resumes; a fully cleaned saved PC deliberately has no dust. Continue to paste, or choose **New dirty PC** to replace the current practice ticket/work while keeping cash, upgrades and owned stock. This is not a full customer queue. The user's original missing-dust issue was not reproduced on a fresh ticket; fresh, partial-reload and new-ticket transitions are checked. A stale departing scene cannot overwrite a newly created ticket's dust.

## Thermal paste
Click **2. Apply thermal paste** to select the syringe. Left-hold on the CPU to squeeze a blob or draw a line. Watch the amount gauge.

**Wipe with cloth** toggles the physical cloth. Press the paste tab again to return to syringe. The cloth and syringe also use right-drag toss/recovery. **Clear all paste** is a practice reset.

**Mount cooler** starts the existing 10-second pressure activity. Hold mouse over the socket or Space to press; release to ease off. Watch coverage and overflow. Enter/**Secure cooler** finishes early. Starting a new deposit or effective wipe clears the previous grade. The paste picture itself is not saved, only its result.

## Shared player inventory / hardware bench
The hardware drawer and repair replacement window now use **one shared stock list**.

- Drag pieces into any free footprint in the 12 x 8 drawer. R/right-click/wheel rotates a held piece; Shift+R reverses. R also rotates a hovered stored part if room allows.
- Fast release flicks it around the drawer. **Shift-release** places precisely. Thrown items reserve a safe committed position, then snap to a nearby free grid spot on settling. Esc cancels ordinary carrying. Closing/changing the scene settles flights safely.
- Green highlights compatible empty motherboard sockets; storage does not require a socket. Bounds, overlap, size, facing and compatibility are checked. Unsupported drops return safely with a calm hint.
- Both case previews share owned stock/positions. **Reset sandbox** only rearranges existing stock; it never replenishes consumed items.
- Initial trial allowance: two RAM sticks, equivalent/budget GPU and equivalent/budget cooler. These are generic samples, not the final catalogue.

## Damaged parts / replacement stock
Open **Replacements** on the repair bench. Remove the damaged cooler/GPU first.

**Buy +1** charges the shown price and adds one uniquely identified part to the shared hardware drawer, only if there is money and grid space. **Fit** consumes one available owned part with **no second charge**. A part installed on the hardware board must be returned to the drawer before it is available for fitting. The window also links directly to player inventory.

Equivalent/budget GPU cost $40/$18; cooler $16/$7. Budget specification is 65% of original. Budget cooler adds 8 C to the final thermal estimate; GPU downgrade is recorded/reported but has no performance benchmark yet. Broken original parts remain customer-owned in a separate per-ticket record. Customer discovery, disclosure and reputation consequences are not simulated yet.

## Shop, saves and payment
Final check combines dust, paste, missing/damaged part gates and cooler quality. A functional downgraded repair can pass and reports its lower specification. Passing pays $60 exactly once per ticket. Square cloth upgrade costs $40 and is bought once. All balance values are provisional.

Progress, cash, upgrades, stock, committed inventory placements and service-part resting positions save automatically to `user://nightshift_save.json`. Old saves migrate without duplicating stock; empty stock stays empty. **New game** resets everything. **New dirty PC** preserves the economy but replaces the current practice work. Free tools return to their rack on scene re-entry; in-flight velocity is not saved.

## Scope and verification
Tabletop motion is a bounded custom 2.5D model with edge/floor bounce and friction. It does not yet include inter-object collisions, throw damage, material-specific mass or sound. The brush uses spring bristles, not a full deformable-body solver. These numbers/shapes need playtesting.

Automated checks: `python3 -I tools/check_project.py` (hygiene only), then `godot --headless --path . --script res://tools/test_data_schemas.gd`, then `godot --headless --path . --script res://tools/test_regressions.gd`. On GitHub the same checks run automatically (see `.github/workflows/tests.yml`). The suite uses a dedicated test save. See CHANGELOG.md for actual results and limitations. Full target-editor human repair/payment playthrough remains pending.

For another AI: read AGENTS.md, HANDOFF.md, DEVELOPMENT.md, latest CHANGELOG entry and the five core documents in docs/. They are PROJECT_BRIEF.md, DESIGN.md, ROADMAP.md, DECISIONS.md and CURRENT_STATE.md (document version 1.6). Keep every future ZIP versioned and include all five. No GitHub push was made.
