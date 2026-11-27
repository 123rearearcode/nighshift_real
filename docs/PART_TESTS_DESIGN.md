# Part tests — brief for Codex (0.58.0, D162)

> **Dropped, 28 November 2026 (D182).** The user: "i wont be doing the parts thing anymore". The 0.59.0 slot is
> now the Windough 98 desktop on NightBoot USB (Claude). This brief is kept for history; do not build it.

Written by Claude (Opus 5.5, model id claude-opus-5-5), 21 November 2026, from the user's answers. This is
an approved direction with proposed details: the user approved the ideas list and the rules in the first
section; everything marked "proposal" is open for Codex to tune or change.

## What the user decided (D162)

- Each part type gets **its own test**, a **goofy version of what you really do** to test that part.
- These tests **replace the quick and long tests** in the testing bay.
- They are **short**, but **failing one loses you time** (night minutes).
- Whether skill changes what a test reveals (a sloppy memory test missing errors) is a **balance question
  for later**: build the tests so that hook exists, but do not tune it now.
- Scam hook (approved): the label stays the player's call, so a part can be marked "working" without being
  tested. `known.tests` records what was actually done (PART_LIFECYCLE invariant 7), so a later system can
  tell a tested part from one merely sold as tested. Later in the game a **relabeler tool** can relabel
  parts, **restricted to similar ones** (not part of this task).

## The tests (ideas the user liked; mechanics are proposals)

| Part | Real test it parodies | Goofy test |
| --- | --- | --- |
| PSU | Paperclip jump-start, multimeter on the rails | Bend a paperclip into the right two pins (green and black) to wake it, then keep a wobbling multimeter needle in the green band for a few seconds |
| RAM | MemTest passes | A stream of digits scrolls by; click the moment a wrong one flickers. Errors in a degraded stick show as wrong digits |
| CPU | Load test, watch the temperature | The load climbs; keep the temperature needle out of the red by fanning (rapid clicks). A "hot" CPU climbs faster |
| GPU | A furry-donut stress test | "FurBall": a spinning furry donut; click the coloured artifacts as they pop up. A card with artifacts shows them |
| Storage | Listening for the click of death; a copy test | A hard drive: hold it to your ear and catch the rhythm of the clicks. An SSD: watch a copy bar for stalls |
| Cooler | Spin the fan, watch for wobble | Spin the fan with a finger, catch the wobble, then blow the dust out |

## Rules (proposals unless stated above)

- One test per part replaces both buttons. It reveals what the old **long** test revealed: the existing
  observation texts (`PartCondition.RESULTS`, long column) stay the source of truth for what was seen, and
  the minigame decides only whether the player got a reading at all.
- Success: the reading is recorded (note + `known.tests` entry), costing a base time (proposal: 5 night
  minutes, the old quick-test cost). **Failure**: no reading, a penalty in night minutes (proposal: +5 per
  failed try), and the player may retry. Respect `NightClock.fits`; refuse to start past 06:00.
- Short: about 8–20 seconds of play each. Pause and focus loss pause the test. Input must work by mouse
  (native clicks in tests, as the Testing bay suite already does).
- What the test shows must come from the hidden condition through `PartCondition` (pure rules), never from
  the view guessing. The view never shows the real condition (invariant 7).
- Keep a hook for later skill effects: a function that turns "how well the player did" into "how complete
  the reading is", which returns "complete" for every result today.

## Code map and coordination

- `scripts/night/testing_bay_view.gd` (the bay; Claude's 0.56.0 magnifying glass lands here first),
  `scripts/rules/part_condition.gd` (results, tells, minutes), `GameState.test_part(uid, long_test)` (the
  current entry point; replace or extend it), `tools/test_testing_bay.gd` (keep its native-input checks).
- Put each minigame in its own script (e.g. `scripts/night/part_tests/psu_test.gd`) so they can be built
  and tested one by one.
- Start from main **after 0.56.0 (the lens) is merged**. Version 0.58.0 is reserved for this; 0.57.0 is the
  anti-virus work (also Codex). Next free decision id after D162: ask the integrator or take D163/D164.
