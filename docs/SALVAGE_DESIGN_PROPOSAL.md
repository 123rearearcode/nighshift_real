# Night salvage — agreed direction and implementation proposal

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work, 14 November 2026.
Based on runtime 0.25.0 and the user's night-outing discussion; implemented standalone slice 0.26.0.
This reconciles the unmerged PR #31 design with Claude's newer D92–D97.

**Status:** direction approved; a standalone in-memory demo is IMPLEMENTED in 0.26.0. Campaign integration is NOT implemented. The filename follows Claude's
assignment prompt. Sections labelled PROPOSAL are recommendations, not additional confirmed rules.
Exact numbers, art, location names and final vehicle catalogue remain open. Parody brands only.

## Playable slice — 0.26.0

Launch F5 → Salvage demo. This has two test cars (fast/small hatchback, slow/roomy van), two sites,
night budget/round-trip preview, seeded layered piles, obstructed pickups, partial effort charges,
opening bags/boxes, stripping a PC into its real child parts, weighted following/wiggle, restrained
throws/edge bounce, sorting, rotated cargo packing and per-site refresh cycles. Status/hover hints and
silent handling cues are wired. Idle bodies sleep and unchanged UI controls are not rewritten.

Hold left on an accessible object until it lifts, then drag and release. Move cover before extracting
a mostly blocked target. Press E over a bag/box/PC (or select it and use Open / strip) to open it; Esc
cancels. While carrying, Q/E or wheel rotates. P pauses; focus loss restores unfinished handling and
pauses. Drive home reserves and charges its journey once. Next demo night advances only this sandbox's
day; Unload to demo shelf transfers once, without making campaign repair stock.

All numbers are prototype tuning: 180-minute demo night; hatch 8×5/speed 1.4, van 10×7/speed 0.85;
site base travel 8/14 minutes, refresh 3/4 days, hardware chances 0.24/0.58; holds 0.32–1.1 seconds,
lift effort 0.7–2 minutes, open/strip effort 3–6 minutes, drag 0.001 minute per pixel. These are samples,
not release balance or final catalogue. Minor neighbourhood nudges suggest tumbling; this is a layered
2D model, not stacked 3D rigid bodies, actual soft bags or a completed disassembly workbench.

Progress persists ONLY in memory while the app stays open, including menu/revisits; app exit or Reset
salvage demo clears it. Only hardware packs; unopened bags/boxes stay on site. No new save file/API or GameState/stock/customer write. Cars keep separate cargo.
Untested actual conditions remain hidden; whole PCs carry their hidden components between sites without
duplication. Site refresh never rerolls cargo or the demo shelf. The working-only inventory loader and
shared PC/clock contracts still block campaign integration. Claude owns those adapters. Tip events,
vehicle buying/unlocks and real diagnosis/sales remain future work.

## 1. Confirmed direction

- Go out at night by car. Car model determines journey time and trunk storage. Faster models travel
  faster; larger carrying space is a separate benefit. Repairs, building and outings compete for the night.
- Multiple locations have different probabilities of yielding different items. Salvage is not always
  profitable or advisable. A trip can waste time or return nothing useful.
- Each location is re-dumped every few in-game days. Exact intervals and whether they differ by location
  are open; no nightly/global reroll is implied.
- Spawn a layered pile in a dumpster: mostly bags, boxes and rubbish, sometimes whole PCs and hardware.
  The central pleasure is physically shifting things to uncover what you want; moving things takes time.
- Searching, recognising value and deciding whether to continue all matter, especially recognising
  valuable/useful hardware (the user's emphasis on the second of the three motivations).
- Handling should be tactile and satisfying: different weights, readable settling, restrained bounce,
  modest bag deformation, partially visible objects and some tumbling as support is removed. A bounded
  2D pile is the starting approach, not a requirement for full 3D or arbitrary soft-body simulation.
- A small sorting area beside the dumpster gives cleared objects somewhere to go. Pack actual finds
  into a size-aware, rotatable trunk grid. Do not force endless re-burying of an exposed target.
- Inspect visible clues on site; proper diagnosis remains at the bench. Taking a whole PC versus
  extracting selected parts trades time against carrying space.
- Before travelling, show general location tendencies, car-adjusted travel time and known recent
  activity. Exact contents remain hidden. Occasional tips can make a trip attractive; delivery of tips
  and their reliability remain to be designed with Claude's customer work.
- Normal shop-clock progression pauses during the outing. Travel and salvage actions deduct in-game
  time explicitly. Do not charge real elapsed minigame time on top of those costs.

These rules extend D12/D37 and are recorded as D98–D102. Existing customer ownership, honesty and
night-expiry rules still apply. Guards, stealth, injuries, rival scavengers, fuel costs and vehicle wear
are not included; adding them would need approval.

## 2. One visit, on one screen

1. From Go out, choose a site using its known tendencies, recent information and travel estimate.
2. Choose the available car; show trunk layout and existing cargo before committing to travel.
3. Arrive at that site's current pile. Objects overlap in layers; corners, grilles and brackets provide
   clues. Contents exist before discovery: reopening a box never rerolls it.
4. Shift rubbish into the sorting area. Open uncertain containers or spend effort moving obstructions.
5. Extract a find. Inspect visible characteristics, choose a whole PC or selected components, then pack.
6. Continue searching or return. Compare another promising shape with the jobs and night time waiting
   back at the shop.
7. Return with the same physical items. Diagnose, clean, repair, use or sell them through shared systems.

**PROPOSAL — layout:** pile on the left, sorting area beside it, trunk grid on the right. A compact top
strip shows remaining night budget, time reserved/needed for return and current action cost/progress.
Hover details distinguish visible model/specification clues from unknown condition. Controls should use
familiar pickup, drag, rotation and quiet rejected-placement feedback. Avoid a new wall of buttons.
Show a preview and explain an unavailable action before charging; essential information cannot require sound.

## 3. Objects and satisfying interaction

| Object | Physical interaction | Why investigate? |
| --- | --- | --- |
| Loose rubbish | Quick lift, slide or toss aside | Cheap access to a promising object below |
| Bag | Move intact or open and spill a limited number of contents | Uncertain reward; weight and shape offer imperfect clues |
| Box | Shift aside or open | Hardware-shaped packaging may be promising without guaranteeing hardware |
| Heavy obstruction | Hold to lift/pry, then drag clear | Reaching an exposed target may be worth the extra time |
| PC | Free it from the pile, load it whole or remove selected parts | Preserve an unknown build or save valuable trunk cells |
| Loose component | Extract, inspect visible details and pack | Recognise a useful model without knowing whether it works |

**PROPOSAL — physics limits:** use layers/support relationships plus a bounded number of colliding
objects. Covered objects cannot be grabbed through an opaque bag. Uncovering something exposes its
existing identity, not a fresh reward roll. Sleeping settled objects saves CPU; only affected neighbours
need waking. Bags can use a small animated outline rather than expensive cloth simulation.

**PROPOSAL — clarity:** highlight the object that will actually be grabbed; show how blocked it is and
whether an action is move, open or extract. Give heavy objects a short, readable effort hold. A failed
trunk drop returns quietly to the last safe place and never deletes or duplicates a find. More elaborate
prying tools are later possibilities, not required for the first version.

Physical settling sounds and material-specific pickup/impact feedback are design goals. Reuse the
existing silent AudioFeedback boundary; no sound assets or playback are authorised by this document.

## 4. Time, choices and returning

Travel consumes night time based on car and site. Moving/opening/extracting costs time. Looking at a
revealed item or rearranging a trunk must not also lose ordinary real-time clock seconds. Whether those
specific actions have their own explicit effort cost is still OPEN. Show costs/progress clearly.

**PROPOSAL — charge actual effort:** deduct time as an effort action progresses, including effort spent
before cancellation. A cancelled action cannot repeatedly loosen objects for free. Avoid pricing every
mouse pixel; use object/action categories and a short hold where useful. Moving an already cleared
object within the sorting area can be cheaper than freeing it from the pile. Exact costs need playtests.

**PROPOSAL — reserve the return:** show both journey legs before departure and ring-fence return travel
from usable search time. When only the return allowance remains, offer return rather than a new costly
action. This avoids an accidental impossible journey. Whether to permit starting/continuing via the
existing fatigue/money overtime system is an open decision for the user and Claude; no free teleport,
forced item loss or new overtime formula is approved here.

Night time lives in one shared authority. During an outing only explicit travel/action charges advance
it; pause must freeze effort progress too. Loading, reopening a panel or re-entering a site must not
repeat a charge. Exact transaction/cancellation behaviour is a proposed implementation contract.

## 5. Location identity, luck and re-dumping

Location tendencies provide informed odds, not guaranteed loot or an omniscient contents list. Cheap
common finds, incomplete PCs and unusable rubbish prevent the dump from replacing suppliers. A rare
valuable component should be exciting, but could be broken, unsuitable for current jobs or too bulky.

**PROPOSED examples, not selected locations/content:** household mixed waste favours older consumer
hardware; an office disposal site favours office PCs and matching small components; an electronics
recycling pile has more hardware but more damaged/incomplete finds. Do not assign exact drop rates yet.

**PROPOSAL — persistent cycles:** a site has an independent refresh cycle. Its contents, container
contents, revealed state, moved objects and removed finds persist across visits/reloads until its next
re-dump. Seed contents by site and cycle; never reroll on loading or opening a container. This makes
clearing a path and remembering an overlooked corner useful without infinite farming.

At refresh, replace the site's abandoned pile and clear sorting-area leftovers; anything packed into
the player's car or already returned remains owned and unchanged. **PROPOSAL:** freeze a current
visit's pile if a refresh boundary is crossed, applying the new dump on the next entry. An object in
hand must never disappear during a refresh. Exact schedule, advance warning and overnight boundary
handling need approval before implementation. No exact “every three days” rule has been chosen.

Tips describe known recent disposal or general opportunity, not guaranteed items or functioning
condition. Customer/reputation systems may later supply tips, but the first prototype can use static
map information without depending on Claude's unfinished systems. Whether a tip can be wrong or stale,
and whether the player sees the next refresh date, remain open.

## 6. Trunk, condition and ownership

A fast small car and a slower roomy car can both have uses. Exact grids, shapes, speeds, prices, unlocks
and starting vehicle are open. No fuel, damage, insurance or vehicle-maintenance economy is implied.

Revealed items retain size and identity. Pack only where their rotated footprint fits without overlap.
Whole PCs occupy a large footprint; extracting components produces separate footprints and removes
those components from that same PC. Do not grant a complete PC and another copy of its removed GPU.
General case opening/disassembly on site must use an agreed limited interaction, not silently introduce
the entire future PC-building system.

Visible condition, hidden working condition and tested specification are different. A dirty used GPU is
not automatically broken, and cleaning never turns it into a new one. A broken find may be worth repair,
parts or nothing. Scope of repairability and how much condition can be inferred on site are open.

**PROPOSAL — custody:** an item remains site-owned/unclaimed until a successful claim into the trunk;
claiming reserves its unique ID and removes its availability from the pile. It remains in car custody
until unloaded, then moves into shop storage. Dropping it back on site must preserve the same identity.
A trip return or reload cannot award the same item twice. Refresh never reclaims carried shop property.

**Important current limitation:** player_inventory currently retains supported working player-owned
stock; its loader filters out other conditions. It is not yet a container for arbitrary broken/untested
finds or complete PCs. Do not insert those records into it and hope they survive. Claude must provide
a reviewed persistence/inventory adapter; until then a standalone prototype keeps its own test manifest
and clearly says it does not award campaign stock. This is not a new production save API.

If the shop stash is full on return, **PROPOSAL:** keep goods in the trunk for later unloading. Never
discard them or create a duplicate shop record. Availability for a repair must follow actual location
and ownership; packing a find does not automatically make it usable in the bench drawer.

## 7. Proposed shared records and interfaces for Claude

Everything in this section is a requested contract, NOT existing code or an approved save migration.
Keep true condition separate from what the player/customer knows. Power values must follow the shared
component definitions (D79, now used by D94/D97 for FPS rather than a final-check threshold).

| Record | Fields needed | Purpose |
| --- | --- | --- |
| Vehicle definition | model_id, travel modifier, trunk grid shape/size | Travel estimate and packing; rates remain balance data |
| Vehicle instance | vehicle_id, model_id, cargo item IDs/placements | Preserve actual cargo, not copies of inventory items |
| Location definition | location_id, category loot weights, refresh rule, travel route/base time | Different odds and travel/refresh behaviour |
| Site cycle | location_id, cycle_id/seed, next_refresh_day, object IDs/poses/layers, container contents, reveal/removal state | Stable revisits and no reload reroll |
| Salvage item | uid, kind, model_id or existing tier, actual condition, known/tested condition, base/effective power reference, footprint/rotation, owner/custody, source location/cycle | Identity, compatibility, packing, testing and honest description |
| Whole PC | pc_id, case/model reference, installed part IDs, assembly/condition state | One PC and its real parts; schema coordinated with shared-PC design |
| Outing | run_id, location/cycle, vehicle_id, phase, time charged, current effort, claimed IDs, transfer receipts | Resume a trip and prevent repeat costs/rewards |
| Known information | site tendencies, timestamped recent activity/tips and known freshness | Player-visible map knowledge, separate from hidden loot |

Minimum integration operations to agree before code:

- Read/estimate available night time and round-trip travel for the selected vehicle/site.
- Begin/resume an outing and debit travel/effort once under the shared clock rules.
- Read/save the current site cycle and car manifest; apply refresh without erasing claimed items.
- Claim/release/move an item by identity, with validated footprints, ownership and available time.
- Return/unload once into shared inventory, leaving overflow in the car; expose only eligible stock
  to the drawer/replacement system. Failure must leave a recoverable item and a truthful message.

Persistent operations need save validation, old-save defaults and interrupted-write recovery through
Claude's existing state/save layer. No money movement, clock fields or customer data are written by
Codex's future scene. Stable operation names/signatures belong in a later reviewed engineering contract.

## 8. Honest use and deception

A repaired reclaimed component can support an honestly priced budget repair or an accurately described
used build. Testing and cleaning cost time but can turn an uncertain find into dependable stock.
Keeping a useful cheap part for tomorrow may be more valuable than selling it immediately.

Selling used salvage as new, hiding a cheaper substitution or concealing known damage connects to
existing D17/D18. Picking it up at a dump is not itself a scam. A disclosed used replacement is honest.
Source/condition and what the player claims must stay separate; do not create automatic refunds,
a new evidence system or omniscient customers. Claude owns persona/discovery/trust/reputation effects.
No customer system is changed in this delivery. D19 still protects any customer-owned components.

## 9. Smallest fun version and implementation boundaries

**Accepted direction, proposed build sequence:**

1. One dumpster, one test car/trunk and a small set of bags, boxes, obstructions and recognisable finds.
   Prove uncovering, weight, a sorting area and quiet grid packing with simple coloured shapes. Use
   existing generic parts/sample models; no dozens-of-parts catalogue or graphics expansion.
2. Add a second contrasting site's loot tendencies, stable cycle/refresh simulation and explicit effort/
   travel budget in the standalone harness. Demonstrate a disappointing trip as well as a useful one.
3. Integrate through Claude's reviewed clock/save/ownership adapters, then verify a returned working
   part becomes eligible stock without duplication and an untested/broken one is retained for diagnosis (not yet campaign-wired).
   Whole-PC campaign integration waits for the shared PC/owned-part contract; a prototype PC-shaped
   object is not proof that full-PC storage/disassembly already works.

**Proposed future file boundary:** own scene scenes/salvage.tscn; scripts/salvage/ for pile, loot/cycles,
packing and effort logic; a separate view script; tools/test_salvage.gd and an explicit CI suite entry.
Paths are illustrative future files, not files added by this PR. Reuse physics/grid helpers only via
public contracts; do not depend on repair bench input flags. Keep state/rules separate from drawing.

Codex owns this design, the future isolated minigame, its tests and feel tuning. Claude owns customers,
software mapping, shared state/save integration and hot files. bench_view.gd, tool_rig.gd and game_state.gd
remain untouched. WORK_PLAN.md is not changed. Coordinate shared component/PC identity before wiring;
no customer-writing, promise, satisfaction or reputation formula is introduced here.

## 10. Acceptance checks for a future implementation

Acceptance targets below span the full design. tools/test_salvage.gd runs the standalone identity,
clock, refresh, obstruction, grid and input cases; save/load recovery and campaign integration remain
untested/unimplemented. See CHANGELOG for actual results:

- Same site/cycle and save/reload preserve loot, reveal state, cleared paths and claimed IDs.
- Refresh changes the site once when due, not on every visit; cargo/shop items survive it.
- Covered targets need physical clearance; opening a container exposes its existing contents.
- Cancelled/partial effort cannot give unlimited progress for free; no double time charge from the
  normal clock, reload, scene transitions or repeated operation completion.
- Fast/roomy vehicle trade-offs work; footprint rotation/overlap/bounds are enforced quietly.
- Claim, release, return and unload preserve identity; replaying return cannot award stock twice.
- Untested/broken finds survive save/load without becoming automatically working or being discarded.
- A partly stripped PC cannot also keep its removed components installed or spawn duplicates.
- Low remaining time has a clear return path; pause and failed saves preserve recoverable progress.
- Human playtest finds revealing/recognising hardware satisfying; short CPU profiling catches pile
  collision spikes. No fixed performance target or final action timing is claimed yet.

## 11. Questions before implementation, most important first

1. What happens when only return travel fits: require return, or allow a deliberate overtime choice?
2. How much inspection/disassembly is possible at the dumpster, especially whole-PC stripping?
3. On average, how many few-day refresh intervals do we want, and can the player know a schedule?
4. Should quick sorting/trunk rearrangement be free, or have a small explicit effort charge?
5. What starting car/trunk size and first two site tendencies should the prototype use?
6. Can tips be wrong/stale, and what customer/other source supplies them later?

Numbers and unresolved details can be decided with a small playable prototype, but shared persistence,
time charging and the whole-PC boundary must be settled before campaign integration.
