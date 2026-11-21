# Room navigation rules — approved 0.53.0 (D161)

User, 21 November 2026: "I want to get rid of the menus ... everything ties together visually instead of
with menus. The main screen is the shop till, and you see the customers coming in. If you press on the
door on the left, you could go outside." Answers: all customers walk in at the beginning of the day (you
see how many came in; no clock on it, it is about their stories); the counter, workshop, stock room and
outside are the places; small windows (a paper ticket, the phone, a screen) may open over the scene;
every place is art plus replaceable clickable spots; done all at once, with room left for the scam hooks.
These rules replace the 0.42.0 menu-path rules (Activities hub, workbench tabs, morning report screen).
Everything else from 0.42.0 that is not about the hub still applies (saving, Pause, Continue, preferences).
Recorded by Claude (Opus 5.5, model id claude-opus-5-5).

## The places

| Place | Scene | Reached from | Leads to |
| --- | --- | --- | --- |
| **Counter** (main screen) | `scenes/rooms/counter.tscn` | New game, Continue fallback, morning | front door → Outside; back door → Workshop; under the window → Under the counter; shutter → end of night |
| **Workshop** | `scenes/rooms/workshop.tscn` | Counter back door | repair bench, hardware board, monitor (the PC on the bench), testing bay, stock room door, door to Counter |
| **Outside** | `scenes/rooms/outside.tscn` | Counter front door | van → Salvage dump; the store → Store; shop door → Counter; parts supplier (later, a separate place) |
| Stock room (close-up) | `scenes/storage.tscn` | Workshop | ← Workshop; Resume work → a bench |
| Repair bench / Hardware board / Diagnostic monitor (close-ups) | `night_bench` / `night_hardware` / `software` | Workshop stations | ← Workshop |
| Testing bay (close-up) | `scenes/night_bay.tscn` | Workshop | ← Workshop |
| Salvage dump (close-up) | `scenes/night_salvage.tscn` | Outside (the van) | ← Outside (Drive home keeps its time cost) |
| Store (close-up, 0.55.0) | `scenes/night_shop.tscn` | Outside (the store down the street) | ← Outside |
| Under the counter (close-up, 0.55.0) | `scenes/under_counter.tscn` | Counter | ← Counter |

There is no hub screen, no workbench tab row and no morning report screen. `scenes/activities.tscn` and
`scenes/morning.tscn` only redirect old links and preferences to the counter.

## Rooms

- A room is one picture (`art/rooms/<room>.png`) and hotspots (`scripts/rooms/hotspot.gd`) placed in its
  scene. The artist replaces art and moves hotspots without code: `docs/ROOM_ART_GUIDE.md`.
- Without art a room draws placeholders: labelled boxes, so the game is fully playable.
- Hotspot actions: `go:<place>`, `open:<thing>`, `end_night`, `later:<idea>`. Unknown places say so;
  `later:` spots say "coming later". Rooms never decide game rules; they call GameState/NightSession.
- Hovering lights a hotspot and names it; F3 shows every outline. Pause sits top-right on every place;
  the place's name top-left; messages along the bottom.
- At 06:00 hotspots marked "closed at dawn" (doors to work, the van, the store) close; the shutter,
  phone, till, clipboard, board and the storage under the counter stay.
- Workbench stations need a PC on the bench; without one they say "bring one from the stock room".
  A build's repair-bench click opens the hardware board (D159).

## Close-ups

- One exit, top-left, named after the place it belongs to (`← Workshop`, `← Outside`, `← Counter`), in the
  shared rectangle `Navigation.BACK_RECT`, plus Pause. No hub button.
- The workbench close-ups keep the PC identity in the centre; it is still the ticket (click: ticket window;
  right-click: pickup menu). Repair's Cleaning/Thermal secondary tabs stay: they are service subviews.
- Each scene cancels uncommitted hand actions, saves its owned progress and checkpoints before leaving
  (its `_navigate`). A running monitor test must finish or be cancelled first. A failed checkpoint keeps
  the player where they are with a visible message.

## The shift

1. The night starts at the counter. Work happens through the doors.
2. The shutter (counter) ends the night, after a confirmation that names who comes to collect.
3. The morning: the shutter goes up and every customer walks in to the counter, one at a time: collections,
   comebacks, new tickets (the old report cards, as their words on a paper slip; customer portraits from
   `art/customers/`, else a silhouette). The slip says how many came in. While customers are at the
   counter the rest of the shop waits. Afterwards the counter sums up: who is still waiting, the review
   site's notice, the shop's standing. No clock runs during the visits.

## Small windows over a place

Allowed (user): the ticket window and clipboard, the phone, the confirmation of the shutter, the paper
slip of a visiting customer, the monitor's screens. They open over the scene and close back to it; they
are not destinations.

## Saving, Pause, Continue (unchanged from 0.42.0 except the fallback)

Pause has Resume, Settings and Title screen and pauses the SceneTree; F10 toggles; Esc closes it. Continue
loads the save, then resumes the last place and ticket; missing, unknown or old preferences fall back to
the **counter** (a 0.52.0 preference for the retired hub resumes at the counter). The
`<save>.navigation.json` sidecar owns no inventory, PCs, money or clock; newer formats are never
overwritten; a new run ignores old preferences. Never execute a non-whitelisted scene path from a file.

## Scam hooks left room for (user: "yes leave room for all this")

The counter is where customers are faced: what you tell them, the till (overcharging, fees), the bin
(where "disposed" parts go: a `later:` spot), nosy customers who open the case at the counter.

## Requirements for future contributors

1. Read this file before any place, door or navigation change. Ask the user before adding a hub, a tab
   row or a screen whose only job is to send the player somewhere else.
2. New places are rooms (`room_view.gd` + a scene with Background and hotspots) with an art guide entry.
3. Register resumable scene paths in `navigation_state.gd`; keep `Navigation.PLACES` in step.
4. Run the Rooms, Menu navigation and affected scene suites; transitions use native input.
5. Update this file, DECISIONS, HANDOFF, the art guide and the changelog when places change.
