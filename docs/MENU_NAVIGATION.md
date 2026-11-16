# Menu and navigation rules — approved 0.42.0

Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work,
16 November 2026, Europe/Bucharest. User approved the menu-path proposal and requested code/docs/push.
These rules supersede older MENU/PATH instructions only; other approved game decisions remain.

## The player path

| Screen | Job | Destination |
| --- | --- | --- |
| Title | Start/resume | Continue, New game, Settings, Achievements |
| Activities | Choose tonight's activity | Workshop room, Salvage dump, Shop |
| Workshop room | Storage and PC selection | Drag a real PC into the slot, or Resume work |
| Workbench | Work on the same selected PC | Repair, Hardware, Diagnostic monitor tabs |
| Repair | Hands-on service | Cleaning / Thermal service secondary tabs |
| Salvage | Locations, searching, car storage | Existing outing/Drive home actions, Activities exit |
| Shop | Existing tool upgrades | Activities exit |

No extra service-selection menu between PC selection and work. `night_workshop.tscn` is only a
compatibility redirect for old links. New visible links must target room or a workbench view.
Hardware is now the customer's actual PC (0.39.0/D131), not the old shop-stock sandbox. Any future
sandbox must be explicitly named as such; never imply that unrelated hardware modifies a ticket.

## Header and action hierarchy

- Top-left: a named parent destination. Workbench says **← Room**. Room/Shop/Salvage say
  **← Activities**. A destination label replaces vague Back/Workshop-room buttons.
- Centre: customer, ticket and case identity throughout all three workbench views.
- Top-right: **Activities** at the shared rectangle; **Pause** beside it. The Activities hub itself
  needs no self-link. No direct Title/Main menu button in the activity body.
- Workbench tabs stay in the same header positions. Repair's Cleaning/Thermal tabs remain a
  secondary row. Do not mix navigation with service actions such as Mount, reset or emptying bins.
- Actions stay near their object. Existing cooler Mount/lever, physical tools, bin button and
  monitor apps remain; this change does not redesign their mechanics or prices.

Switching tabs changes the VIEW of one canonical PC. It cannot create another PC, charge parts,
finish a ticket or reset physical work. Each scene cancels uncommitted hand actions, saves its
owned progress and checkpoints before leaving. An unlocked cooler mount is cancelled under the
existing lever rule; tab tooltips state that. Completed contact/physical paste and hardware state
survive. A running monitor test must finish, or be cancelled using its existing power button,
before leaving: navigation must not silently discard a paid/measured result.

## Room modes and saving

Normal mode: inventory, inspection, PC slot, Resume work, camera controls. Furniture cannot be
dragged accidentally. **Arrange room** reveals Add furniture, Remove empty and Auto-pack shelves;
Done arranging cancels temporary hands and returns to normal. Zoom/pan remain in both modes.
The workshop slot cannot select a PC while arranging. No numbered rack-selector menu.

Real edits autosave. Show Layout saved/status instead of a routine Save layout button. Reconcile
contents when entering the room; no player-facing Refresh button. A real write failure reveals
Retry saving layout and blocks leaving/selecting another view until repaired. Protected/newer
layouts remain read-only. Do not recreate controls while a Button is emitting its own signal.

## Pause, Continue and preferences

Pause has Resume, Settings and Title screen. It actually pauses SceneTree (including monitor wait
progress), not only an overlay. Resume restores the prior pause state; repair use is released and
salvage's existing local pause/hand state is handled by its scene. F10 opens/closes Pause. Escape
closes the pause/settings layer; outside it Escape retains existing part/tool cancellation rules.
Sound Settings uses the existing GameState setting. Title exit uses the scene's same safe save/
cleanup path and may fail with a visible explanation; it cannot bypass a running monitor test.

Continue loads the regular game first, then resumes the last known activity and selected ticket.
Remember the last workbench view and repair subview per ticket. Missing/corrupt/unknown preferences
fall back to Activities; a new run ignores old preferences. A ticket without a PC cannot resume a
PC bench. Never execute a non-whitelisted scene path from a file.

`<game save>.navigation.json` is a separate UI preference sidecar (version 1, run id, scene,
bounded workbench-view/repair-stage maps). It owns NO inventory, PCs, money or clock. Newer formats
are protected against writes. Failure to save a UI preference does not overwrite repair data;
Pause warns that Continue may fall back. The existing main save and ticket manifest stay canonical.
Salvage remains session-only: resuming its activity after app restart opens the salvage view with
its existing session rules, not a newly implemented persistent dumpster save. Drive home still
costs its existing time; it is an outing action, not a free navigation shortcut.

## Requirements for future contributors

1. Read this file before any menu/path change. These approved rules are mandatory unless the user
   changes them; request approval before introducing an extra navigation layer or changing a role.
2. Reuse `night_navigation.gd` and its named controls/rectangles. Each new night screen supplies
   `_navigate(path)` with its own guarded cleanup/checkpoint. Keep model/simulation rules out of it.
3. Register resumable scene paths in `navigation_state.gd`; validate preferences and preserve
   run/ticket ownership. Do not make UI preferences the authority for PC identity.
4. Keep service/action controls out of the navigation header and avoid duplicate destination buttons.
5. Update this document, DECISIONS, CURRENT_STATE, HANDOFF and changelog when approved paths change.
6. Run the menu/navigation suite and affected scene suites. Tests must use native input for at
   least the actual transitions, not only call route methods. Cover no progress/custody loss, save
   refusal, pause/unpause, Continue/new-run fallback and unexpected preference data.
7. Preserve hidden-install faults, games, timed tests, malware, overclock and Shop behavior. This
   is menu work, not permission to rewrite those systems.

No manual visual acceptance is claimed. Exact engine/check results are in CHANGELOG.
