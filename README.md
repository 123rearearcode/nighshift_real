# Nightshift - Godot Foundation Trial (v0.46.1)

0.46.1 is a documentation-only handoff correction against merged 0.46.0; no gameplay changes.

New in 0.46.0: **every part comes out at the hardware bench.** CPU, RAM, drives and the PSU can be
dragged into the drawer and back (the cooler comes off before the CPU, as in a real PC). The board has a
second PCIe slot for a second graphics card, two drive slots and a PSU connector. **Order parts** (bottom
right) buys any part from the catalogue into the drawer; drag it into an empty slot to fit it. A bought
card or cooler can also upgrade a working one you took out: the customer's old part stays in the drawer
as theirs, and you can swap it back. A PC with no CPU, RAM, drive or PSU will not start. Parts you fit are
a gift for now (charging the customer is for later).

New in 0.45.0: **real hardware.** Every PC is now made of named parts (close parodies: Intol, AMB,
Nvidya, Corsare...) with six stats: processing, graphics, RAM, storage, PSU and cooler. Too small a PSU
and the PC will not start; too small a cooler and it runs hot. 100 is a soft ceiling (the best single
GPU is 98); several GPUs add up. The ticket, the monitor's Work tab and the hardware bench show every
part by name. Today's two customers run exactly as before. The full list is in docs/HARDWARE_CATALOG.md.

New in 0.44.1 (your playtest of the thermal service): a **guide** under the paste panel always shows
the steps (Film > Paste > Press + screws > Lever > Wipe extra > Done) and one line saying what to do NOW.
You can now **screw while holding Space**: right-click the screwdriver during the press and tighten the
corner screws while Space keeps the cooler down. After the lever the **cooler stays visible** (locked
frame with its tight screws, the paste seen through it) and a verdict shows the grade. Wiping the
squeezed-out paste now updates the figure live and says **"Clean"** when it is done, then
**"Thermal service DONE"** and what comes next.

New in 0.44.0: **the night ends and the morning comes.** On Activities, **End the night** (at 06:00
it is the only choice left; the monitor's timed tests stop). Every customer you called collects their
PC exactly as it is: they pay if it starts, react to what they notice (film left on, pop-ups, loud fans),
and trust moves. Loose GPU screws and an unstable overclock are not noticed at pickup: they bring the
customer back two mornings later. The **morning report** has one card per PC (collected, came back,
still waiting, new ticket); hover a card to see the PC's state. Each collected PC makes room for a new
customer. Then start the next night.

New in 0.43.0: **tickets and pickup.** Right-click a customer PC in the workshop room, or right-click
the ticket (the customer and ticket name at the top of the workbench), to **Mark ready for pickup** (a
yellow READY sticker: your own note, it changes nothing) or **Call the customer** (a green CALLED tag:
they collect the PC next morning, exactly as you leave it). Both can be undone. Click the ticket to read
it in full: customer, what they say, what they want, pay and the machine. The morning itself (collection,
pay, the report) comes in the next release.

New in 0.42.0: **Activities → Workshop room → PC slot → workbench**, with no extra service menu.
Use Repair / Hardware / Diagnostic monitor tabs for the SAME customer's PC. ← Room returns directly
to storage; Activities stays top-right. Arrange room reveals furniture editing; normal mode stays
focused on parts and PCs. Layouts autosave; Retry appears only after a failed write.
Continue resumes your last activity/PC/view. Pause offers Resume, sound Settings and Title screen;
F10 toggles Pause, Escape closes it. Finish/cancel running monitor tests before changing views.
All 0.38–0.41 hardware, installation, malware, overclock, Shop and monitor features are retained.
Rules for future menu work: docs/MENU_NAVIGATION.md. Use a fresh v0.42.0 source folder to playtest.

New in 0.41.2: nothing to see. The repair bench's code was split into smaller pieces so the next
releases (tickets, pickup, the morning report) can be built safely. The bench should behave exactly as before.

New in 0.41.0: **the monitor measures, and measuring takes time.** Running a game now takes 30 minutes of
the night (a few real seconds, with a progress bar); the long stress test takes 20. A night clock shows
the time (there is no end-of-night rule yet). "Final / thermal check" is now **Hardware check**: it only
says whether every part is in place, working and the cooler locked. Beside the monitor there are two tabs:
**Work + match** (the main one: what you have done to this PC, and how what you have MEASURED matches the
customer's request) and **Client**. Temperatures now come from game and stress tests.

New in 0.40.0: **the diagnostic monitor's last two apps work.** Anti-virus: some PCs arrive infected
(the customer only hints: pop-ups, fans spinning up). Scan, then Remove threat; if you never scan, the
customer finds it at pickup. Overclocker: raise the CPU multiplier for more FPS; voltage keeps it stable
but heats it. The heat shows in every check; instability does not: a quick stress test only catches a
crashing setting, the long test ($2) catches a marginal one, and a marginal one left on crashes at the
customer's home. All numbers are trial proposals.

New in 0.39.0: **the hardware bench now shows the PC of the ticket you are working on** (its CPU, RAM, GPU
and cooler; anything you removed or broke at the repair bench is in the drawer, and what you move there
is what the repair bench sees). A new **screwdriver** is needed for every screw: at the repair bench
the four cooler screws come AFTER the press has finished and BEFORE the lever; at the hardware bench the
GPU's two bracket screws are tightened with the screwdriver from the tray. Skipped GPU screws are a hidden
pickup fault. The third Activities button is now the **Shop**, where all tool upgrades are sold.

New in 0.38.0: **installing the cooler now has technique.** On the Thermal service tab the "Cooler base"
button peels the clear plastic film off the cooler's contact plate (people forget it). While the
cooler is pressed down, click the four corner screws: tighten opposite corners in turn, two passes
each, then click the lever. The bench never tells you if you did it right. Mistakes are invisible to
your own final check and only show when the customer uses the PC (their pickup score and complaint).
See docs/INSTALL_TECHNIQUE.md. This is stacked on Codex's unmerged PR #41 (0.37.0).

New in 0.37.0: Cleaning is teal and Thermal service purple. Pick up the syringe/cloth physically;
the redundant tool-toggle button is gone. Choose Normal thermal paste, Super-paste or Toothpaste
from the Paste menu (wipe/reset before changing a layer). Super-paste has a subtle blue-purple hue
and improves cooling; trial cost $6 / benefit −4°C at equal contact, versus normal $3.
Mount cooler appears below the socket only when there is paste and the cooler is not already
being mounted/graded. The vacuum bin now has a RETRACT push-button; the separate spool is gone.
Extract/import the fresh v0.37.0 folder and confirm that title version. See docs/THERMAL_SERVICE.md.

New in 0.36.0: **New Game → Activities → Workshop room → drag a customer PC into the right-hand
workshop slot.** The selected PC opens its workshop. To change PCs, return to the room and drag
another in. A marked rack reservation remains for the PC on the bench; it is the same PC.
All six night work screens have Activities in the same top-right position. No rack-list buttons,
PC dropdown or duplicate Storage shortcut on the title/activity menus.

**Use the new build:** close the old demo, extract the v0.37.0 ZIP into a fresh folder, then in
Godot Project Manager choose Import and select that folder's project.godot. Confirm **v0.37.0**
on the title/room screen before testing. The attached 02:05 recording shows v0.32.0 and its old
self-freeing rack-selector implementation; the direct room fix was introduced in v0.33.0.
Do not delete your saves or overwrite an old project folder to install this source package.
See docs/ROOM_WORKSHOP.md for controls and persistence limits.

New in 0.35.0: New Game → Workshop → Diagnostic monitor. PCs start OFF: use Switch PC ON,
then Boot check, thermal/final report, or Vapor → buy/run Counter Stroke 2. Tests do not complete
or pay night jobs. Anti-virus/overclocker are marked upcoming. Cloth pickup/wipe edge tightened.
See docs/SOFTWARE_WAVE_2.md. Existing explicit saved power state is retained.

**0.34.0 bench feel:** Brush starts equipped (1); Vacuum is 2. The spool really shortens deployed
hose and keeps it short until the nozzle/hose is pulled out. Heavy salvage can be nudged while
remaining too heavy to lift casually. Room update 0.33.0 was approved and merged as PR #40.
See docs/BENCH_FEEL_0_34.md for details and limits.


**Local 0.33.0 room update:** F5 → Storage rack. Furniture is shown together in a 4×2 floor grid;
there are no per-rack selector buttons. Add furniture, drag its title bar to an empty bay, and use
wheel zoom / middle-drag pan or Fit furniture / Entire room. Storage v1 layouts migrate automatically.
Based on integrated main 0.32.0. Code remains local under the user's no-push instruction; use the
0.33.0 ZIP to playtest. See docs/STORAGE_ROOM.md and docs/REVIEW_0_32.md.


**Salvage variety (0.31.0):** each Salvage arrival is a fresh random pile with fourteen collectible kinds,
varied containers and heavy obstacles; cargo stays yours. See docs/SALVAGE_VARIETY.md.

**Night workshop (0.30.0):** F5 → New game → Activities. Workshop lets you switch between two
customer repair PCs, clean/repaste them and run a diagnosis without ending the job. Salvage is now
under Activities. Storage has three-shelf racks. Good cooler mounts commit with the lever.
Both this branch and the previous rack PR are intentionally unmerged. See
[night-workshop controls and limits](docs/NIGHT_WORKSHOP.md). Existing saves retain their real ticket;
start a New Game to try the two-PC setup.


**Previous rack feature:** F5 → **Storage rack** (right side of the menu). Arrange real PCs, kit tools
and stock on shelves; rotate with R/E or Q, expand with racks/cabinets/tool boards. Layout autosaves.
Furniture is free in this prototype. Capacity integration with buying/intake remains a follow-up;
see [storage controls and boundaries](docs/STORAGE.md). Branch is intentionally unmerged.



**Try salvage:** F5 → **Salvage demo**. Pick a car/site; hold left to lift, drag cover into the sorting
area, E to open/strip, Q/E or wheel to turn carried finds. Lift the whole object over the dumpster rim,
then release over free trunk cells to pack. This trial uses real 2D gravity, collisions and a force-based mouse grip.
Drive home, unload to the demo shelf, or advance the demo night to see site refreshes. P pauses;
Esc cancels. This isolated demo lasts only until app exit/Reset; it does not replace your repair save,
advance the campaign day or grant repair stock. Cars, timings, loot and refresh rates are prototype tuning.

**0.18.0 adds trapped-dust threads and clearer bench controls.** Short tails protrude from under parts: precise vacuuming pulls them free slowly; removing the part is easier. Drag the clamp with either mouse button; a stationary left click unclips. The standard hose now only just reaches the far-left corner with careful rotation. Tools can be put down throughout cooler mounting, including after the pressing timer expires. Cooler visual redesign is proposed in `docs/DESIGN_PROPOSALS.md` section 6.


A small playable foundation for the PC repair/shop game. Placeholder shapes and text, one overheating repair ticket, shared player parts storage, tabletop handling and thermal-paste activity. This is not the complete game.

## Open this build
1. Close any running older copy of the game/editor.
2. Unzip `nightshift_godot_trial_v0.24.0.zip` into a new folder. Keep the previous version as a fallback.
3. In Godot Project Manager choose **Import**, select `nightshift_godot_trial/project.godot`, then **Import & Edit**.
4. Press **F5** for the start screen. Choose **New game** to open the demo, or **Load game** to resume. Starting over asks before replacing an existing save. The shop has a **Main menu** button that saves before returning.

Engine: **Godot 4.7.2** is the user's real version (confirmed by the user on 2026-11-12; a brief 4.6.3 claim in 0.11.1 and 0.11.2 was a mistake). Codex's automated checks ran in Godot 4.6.3, so they are close but are not a run on 4.7.2. **Since 0.12.3 the automated checks also run on Godot 4.7.2 itself** (GitHub Actions, headless): 172 data schema checks and 344 regression checks, 0 failures on version 0.12.2. That does not cover looks, feel or mouse and keyboard play. See CHANGELOG.md for exact checks.

## Repair bench: tools and dust
Open **Repair bench** from the shop.

- **1 Vacuum**, **2 Brush**, **3 Move parts**, **4 Dust pick**. The buttons are colour-coded (blue, amber, green, red).
- Left-hold uses a selected tool. The nozzle/bristles follow with gentle lag; their actual contact point acts on dust.
- Right-drag/release tosses a tool. It hops, spins, rebounds off the worktable edges and settles. Click a resting tool or press its hotkey to equip again.
- The brush has bending bristles. Moving it loosens dust and, once loose enough, tosses it: the dust slides and spins across the case, catches under installed GPU/cooler or in the filter, and settles on another surface. The case walls contain it. Extracted-part surface dirt stays on its service tray. Light contact loosens gradually; fast strokes flick dirt. A new Case interior progress row tracks scattered dirt; affected areas can become dirty again. Long chains also chip off small specks. The brush never removes dust; only the vacuum does. With a tool in hand, a left click always uses it; to swap, press 1/2/4, use the buttons, or click a resting tool with empty hands. Turn the held tool with the middle mouse (spin the wheel, or hold the middle button and drag sideways) or Q/E. The dust filter is clogged: its dust grips 1.5 times harder, so it takes longer to clear (intended). The hose also lies around parts still fitted in the PC.
- A held tool follows the cursor but can never leave the bench, even when the cursor does. Dragged parts are kept on the bench too, and held drawer parts stay inside the window.
- Tools and loose parts on the bench are solid rotated boxes: a held tool or dragged part shoves the others aside, thrown pieces bounce off each other, and heavier pieces (the vacuum, the GPU) push lighter ones (the cloth) more than the other way round. Pieces hopping through the air pass over others.
- The vacuum has a physics hose that runs to the dust bin (bottom right of the bench). It lies around component housings, and tools pass above it. It is only 560 px long: when it is taut it tugs the vacuum back (it can stretch at most 4% past its length). The "longer vacuum hose" upgrade in the shop makes it 760 px. The base hose is calibrated to reach the far-left case corner when turned and routed carefully; an owned longer-hose upgrade still increases reach. The hose is see-through: swallowed dust rides it to the bin and fills the bin when it arrives (with the suction off, it waits in the hose). Shift + right-drag the hose to move it (the held tool is put down); with empty hands, right-drag also works. Drop the carried section in HOSE CLAMP to park it; left-click the clamp with empty hands or grab the hose again to release it. Left- or right-drag the clamp to move it around the desk; a stationary left click releases the hose. Its whole footprint stays outside the PC and clear of the bin; a parked section must remain within reach. Blocked placement turns the clamp red. A too-short bin-side section cannot reach it. The hose follows complete rectangular component housings and slides beneath tools; a right-drag of a held tool cannot accidentally grab the hose underneath. The clamp and hose arrangement are session-local, like tool positions. The clamp can be turned while carried (wheel or Q/E). Dropping the hose on the clamp always clips a section that can stay stretched there. A spool sits beside the bin: click it and it reels the hose in, dragging the vacuum back to it (pick the vacuum up to stop the reel). The hose end is always attached to the vacuum; a hose clipped in the clamp near its nozzle keeps the vacuum on a short leash. The PC case has a power button (top-right): while off, the fans wind down; the state is saved. A trash can sits on the tray: with empty hands, left-press a loose item (nothing spawns them yet; they are coming) to carry it, and drop it on the can to throw it away. Everything that reaches the bin fills it (it holds 140 units, about half a dirty PC); when it is full the vacuum stops pulling until you click the bin to empty it. The bin is not saved yet. Faint floating dust drifts over dusty parts and bursts up when the brush kicks dust (cosmetic only).
- In Move parts mode, HOLD on a fitted cooler/GPU to unscrew it (1.2 s, a progress ring at the cursor; letting go or slipping off cancels), then drag it to the service tray to expose protected dust underneath, then refit. A part lying in the tray lifts instantly. A fast release away from its mount throws the component over the worktable; pick it up at its physical position to recover it.
- The pick inspects trapped dust beneath installed cooler/GPU on hover. Hold for a provisional 0.8-second extraction attempt with 12% damage risk. Hovering alone is safe. Safe removal avoids this risk.
- Removing the cooler clears its paste result. Refit all parts, apply fresh paste and pass the shop's final check. Dust is not a blocker: it only adds temperature, so the PC passes while it stays under the limit with every part working. The shop's lower card has a **Customer** tab with what you know about the customer.

**Dust on entry:** fresh tickets explicitly begin dirty. The bottom line shows ticket id and visible dust-group count. Partially cleaned work resumes; a fully cleaned saved PC deliberately has no dust. Continue to paste, or choose **New dirty PC** to replace the current practice ticket/work while keeping cash, upgrades and owned stock. This is not a full customer queue. The user's original missing-dust issue was not reproduced on a fresh ticket; fresh, partial-reload and new-ticket transitions are checked. A stale departing scene cannot overwrite a newly created ticket's dust.

## Thermal paste
Click **2. Apply thermal paste** to select the syringe. Left-hold on the CPU to squeeze a blob or draw a line. Watch the amount gauge.

**Wipe with cloth** toggles the physical cloth. Press the paste tab again to return to syringe. The cloth and syringe also use right-drag toss/recovery. **Clear all paste** is a practice reset.

**Mount cooler** starts the existing 10-second pressure activity. Hold mouse over the socket or Space to press; release to ease off. Watch coverage and overflow. After locking, light cloth touch-ups are safe anywhere: the result is only cleared when wiping takes the CPU below 95% of the paste it was graded with. Switching stage mid-mount lifts the cooler off again WITHOUT grading; only the lever secures it. The final check also reports graphics output: a dead GPU outputs 0 and fails the PC, a replacement outputs its tier power (budget 65), and this PC needs 60. To lock the cooler down, click the **lever** beside the socket (it glows while it can be pulled). Nothing secures it for you: when the 10 seconds of pressing are up, the paste has set and the lever is waiting. Aim for about a pea (the green zone on the gauge, 100-160 units) and a press of roughly 2.5-4 seconds. Starting a new deposit or effective wipe clears the previous grade. The paste picture itself is not saved, only its result.

**Complete repaste** appears after mounting. It only works on a PERFECT or GOOD ENOUGH result; otherwise wipe the paste off and try again. Completing with thermal paste costs $3. The final check only counts the paste once the repaste is completed.

**Toothpaste (a scam):** while the CPU is bare, the **Paste:** button switches the syringe to toothpaste. It is free and looks the part, but it is stiffer (press harder) and runs 14 C hotter. The PC still passes today's check and the customer still pays; the job records the scam. What happens later (it dries out, the customer finds out) is not built yet.

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


### Physical cleaning saves (0.17.0)
Dust snapshots preserve real particle locations, areas, hidden traps and looseness, not just completion percentages. Old saves without a snapshot restore their old percentages and begin saving full physical state on the next save. Invalid snapshots fall back to percentages without silently discarding dirt. Relocating dirt does not count as removal; the brush cannot delete dust, and a vacuum switched off cannot erase loose dust on a timeout. No automatic 95% shake-off deletes the final particles. The existing 95% acceptance threshold remains trial tuning. Clamp placement is still session-local.


### Trapped dirt and cooler hands (0.18.0)
Hidden clumps show up to three representative chains at a housing edge, with a trapped-count label. Hold the nozzle close to a protruding thread, outside the housing, to pull slowly. The brush cannot erase pinned dirt; removing the part or using the risky pick remains available. These tails represent existing dirt, not extra decorative mass or a full reveal through the part. Small specks show shorter tails after chains are removed.

Starting cooler mounting puts down the held tool. Right-drag put-down also works while mounting or waiting for the lever; it does not lock the cooler or complete a repaste. Replacement stock is below the desk, clear of the clamp. The proposed cooler art/animation changes are not part of this implementation.

## Bench feedback in 0.19.0
The vacuum stops collecting when its bin reaches 100%. A permanent status line now explains this, and **Empty bin** stays beside the tool controls with the current fill percentage. Switching tools does not dismiss the full-bin warning. Cleaning tools, maintenance, thermal materials and completion have separate rows. Hose self-crossings are untangled, including clamp transitions; occupied clamps correctly consume hose length.

The game is still silent: audio cue hooks and six mixer buses are ready for future sound work, but there are no sound clips or playback. See docs/AUDIO_DESIGN.md for the detailed plan. Cooler artwork is deferred. Leaving an unfinished cooler mount cancels it; navigation cannot replace physically locking the lever.

## Test cleanup in 0.20.1
Gameplay is unchanged. See docs/TESTING.md for required suites, short/full diagnostics and the visible non-blocking report of the existing lever/highlight defects. Documentation-only changes skip the game run; bench/physics changes retain the full matrix.
