# Nightshift — Sound design groundwork

Trial 0.19.0 · 13 November 2026

Author: Codex (GPT 6.1 Sol, model id gpt-6.1-sol) in ChatGPT Work.

## What exists now

The game is silent. There are no audio clips, AudioStreamPlayers or playback adapter. Implemented: semantic cue catalogue, six native mixer buses, a silent event service, action hooks and lifecycle tests. This lets later sound work follow real actions without rewriting the minigames. Everything about sound character, assets and mix below is a PROPOSAL, not a delivered sound effect.

AudioFeedback receives events from views only. It never tells physics what happened and never decides damage, cleanliness or repair success. Cue context describes observable action: tool, position, speed, material, load, RPM or pressure where available. The eventual playback adapter must consume that information rather than infer hidden job truth.

## The intended feel — proposed

Close, tactile workshop sounds should make small actions satisfying. A tool landing should have weight; brush contact should feel dry and scratchy; paste should feel viscous. Avoid constant exaggerated cartoon impacts or rewards that make long repair sessions tiring. Keep important actions distinct at low volume.

Handling should reflect the surface and object, not its price. A cheap part must not automatically sound broken; a dishonest repair must not trigger a secret moral sting. Use only original or properly licensed samples. No brand imitation, copyrighted game recordings or invented lore is needed.

## Action map

Implemented cue identifiers are exact. Descriptions in the final column are future sound direction.

| Player action / actual state | Silent cues | Proposed feedback |
| --- | --- | --- |
| Pick up, place, rotate or install hardware/tools | handling.pickup, handling.putdown, handling.rotate, handling.install | Small grip/contact sound, then weight-dependent table landing; socket seating distinct from a loose drop |
| Object hits a boundary or another object | handling.impact | Intensity from speed; several restrained variants, without a loud sound for every tiny bounce |
| Vacuum active with capacity | vacuum.motor | Continuous motor/air bed; fades in/out, slight load variation; stops when full |
| Dust entering/travelling in hose | vacuum.dust | Separate light granular layer from carried/swallowed load; no scraping when collecting nothing |
| Bristles actually contact dust | brush.contact | Friction from actual contacts and stroke speed, with individual ticks only for larger movement |
| Cloth contacts CPU while wiping | cloth.wipe | Short soft rubbing, later wet/dry variants if that state is explicitly modelled |
| Syringe dispenses on CPU | paste.squeeze | Soft viscous squeeze, material and dispense speed; no endless loop while merely holding syringe |
| Risky pick makes contact / extracts dirt | pick.scrape, pick.extract | Delicate scraping and short release; damage sound only after real damage is applied |
| A part is actually damaged | part.damage | Restrained mechanical event, plus visible explanation; never a false prediction |
| Bin becomes full / is emptied | bin.full, bin.empty | One clear obstruction cue, then disposal/granules; persistent text remains primary |
| Hose lifted/dragged; fixture moved | hose.grab, hose.drag, clamp.slide | Flexible rubber rub and a short grip sound; movement loop quietens when still |
| Hose clamped/released | clamp.lock, clamp.release | Distinct small mechanical snaps |
| Cooler pressing / lever / cancelled / completed | cooler.press, cooler.lever, cooler.cancel, cooler.complete | Low pressure/contact texture, crisp lever finish; UI confirmation distinct from physical securing |
| Fans physically spinning | pc.fan | Two parameterised fan layers using actual case/cooler RPM; avoid an unchanging loud drone |
| Buttons; final check result | ui.click, check.pass, check.fail | Consistent quiet selection and neutral diagnostic feedback, not omniscient scam detection |

Pickup/impact/install hooks cover the hardware bench too. UI selection hooks cover start, shop, hardware and repair screens. Not every later campaign interaction exists yet, so do not claim full game-wide sound coverage.

## Mixer and event contract — implemented

| Bus | Role |
| --- | --- |
| Master | Overall output |
| UI | Selection, cancellation and completion/check messages |
| Handling | Tools/parts, hose/clamp and cooler contact |
| Tools | Active vacuum, brush, cloth, syringe, pick and full-bin warning |
| Machines | Fans and future powered-PC layers |
| Ambience | Reserved for future room/environment bed; no current ambience source |

Cue metadata lives in scripts/data/audio_cues.gd: bus, loop flag and cooldown in milliseconds. AudioFeedback.request(owner, id, context) emits one-shots, returning false for unknown IDs, wrong event types or requests inside the owner/cue cooldown. The history holds at most 128 records and cooldown table at most 512 keys.

set_loop(owner, id, enabled, context) owns one loop per owner and cue. It starts once, updates parameters only when changed and stops idempotently. Context dictionaries are copied. stop_owner clears loops and cooldowns; freed owners are pruned via weak references. Repair stage changes and scene exit stop their loops. The adapter should map each loop key to one voice, never start another player on every physics frame.

The cleaning frame rebuilds active-loop flags from actual work. A full bin disables the motor and dust layer; emptying re-enables work. Release stops tool contact. Fan context includes both case and cooler RPM; a future adapter may layer two voices under that one semantic loop. Cooldown is event suppression, not a promised fade or voice cap.

## Future playback rules — proposals

- Add a separate adapter that loads a small sound bank and subscribes to the service. Keep missing/unassigned clips silent and log an asset issue once, without failing gameplay.
- Add per-cue sample variants and small controlled pitch variation. Match materials only to explicit physical data. Start with hard table, plastic handle, metal cooler and soft cloth rather than dozens of assets.
- Fade motor/air/contact loops over short intervals. Smooth speed/load parameters so rapid input does not create clicks or jittery pitch. Audio smoothing must not alter physics responsiveness.
- Limit impact voices and ignore tiny resting jitter. Give lever/full-bin/check messages priority over repetitive contact. Choose thresholds by listening, not by silently changing collision rules.
- Stop/fade on scene changes and application pause; define resume policy before playback ships. Add master/UI/tool/machine/ambience sliders and a mute test. Those settings, fades and voice limits are not implemented today.
- Use modest stereo placement from bench position; avoid extreme panning. Protect intelligibility on laptop speakers and headphones. Do not add compression/ducking until an actual mix needs it.

## Information and accessibility

Every blocked state must remain visible: full bin, inaccessible dust, mount not secured and bad coverage cannot rely on hearing. Sound should reinforce the same state, including a clear stop when an action ends. Leave an optional low-motion/text feedback path intact.

Future diagnostic sounds can matter: rough fan bearing, intermittent rattle or startup behaviour may provide clues when those faults exist. They should be reproducible from the simulated fault and available to inspection, not randomly assigned misleading noise. Any required clue needs a readable equivalent or accessibility setting. No diagnostic fault palette is implemented in this slice.

Toothpaste should use an appropriate material feel only if the player can already observe the chosen material. No hidden 'scam detected' tone. A legitimate poor result can sound unsuccessful only after the actual check/lever/result event, not from private job.scams records.

## Practical next steps

1. Agree on a restrained, close workshop palette and select the most important actions: vacuum start/stop + collection, brush contact, pickup/landing, paste, lever.
2. Create or license a small initial sample bank. Audition several minutes of repeated cleaning, not just isolated clips. This needs approval to start sound production.
3. Implement the playback adapter, fades, voice limits and volume settings, with silent fallback for unfinished cues.
4. Human-test complete repair sessions at low and normal volume. Check full-bin comprehension, contact timing, repetition fatigue, pause/resume and scene-change silence.
5. Expand to fault clues, room ambience and the day/night shop only when those systems exist.

## Verification boundary

Automated tests cover cue validation, deduplication, cooldowns, context updates, freed-owner cleanup, bounded history, silent service and actual bin/brush/paste/stage lifecycle. They cannot certify sound quality because no sounds exist. Human timing/mix evaluation follows the first playback slice.
