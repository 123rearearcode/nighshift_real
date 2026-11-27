# 0.58.0 antivirus validation — 27 November 2026

Codex (GPT-6; model id not exposed by this session), ChatGPT Work.
Engine: **4.7.2.stable.official.ed1daf0bf**. Feature base: merged main dfbf5aa / 0.57.9.

## Automated checks

The existing required 36-suite workflow was run locally under the target engine. The first complete
pass was 2,508 checks, zero failures or script/parse errors. Subsequent graphical findings added the
alias-specific adware reaction and stopped-miner-alias regressions; Antivirus now passes **69 checks**.
The complete final run passed **36 suites / 2,510 checks**, zero failures or script/parse errors, after the final runtime edits; CHANGELOG.md records the release checks. No required suite was removed,
weakened or moved into a non-blocking lane. Malware/overclock and Software were also rerun after the
plain-language scan report change. The short scripted bench smoke completed; it is not a human playtest
or a performance audit.

Antivirus coverage retains the actual monitor/scan/entry-cost/cure/save journey, native SEND and Enter,
uppercase input, wrong-word retry, typing/shared pause, abort/power-off, 06:00 and stale-ticket refusal.
New checks cover scan leads without exact-target tags, per-PC initial variation/retry stability,
inspection that remains readable while names change, both row and Stop-button rectangles, reduced
effects/paused animation, setting round-trip/old optional fields, both real Settings controls, and
stopped-process feedback. Headless popup checks use the CheckButton's real state/signal; the native
pointer path is covered by the graphical observations below.

## Graphical observations through real mouse/keyboard input

Used the actual 1280×720 game window with isolated XDG data. A disposable prepared customer PC resumed
at the real monitor, once with adware and twice with a miner. These are **UI fixtures, not ordinary
first-day playthroughs**: faults, power and scene-resume were prepared before launch. No user save,
customer settlement or collection was used to claim a first-day outcome.

- Title displayed v0.58.0. Opened Settings, switched Reduce flashing and movement on with the mouse,
  closed it and continued. The pause Settings later showed the same enabled value; a real mouse click
  there switched it off. The label, slider, toggle and Done control fit their dialogs.
- Adware: ran the public scan, opened cleanup, read scan clues, inspected an ordinary invoice app and
  the source, stopped the source and observed the advert disappear. Selected the returning helper,
  turned off Start with PC, stopped it and rebooted. The real monitor recorded removal; cash stayed
  $100, the ticket stayed open and the canonical night clock advanced only the paid ten minutes.
- F10 during cleanup paused the game. The pause help correctly referred to workshop stations (B64).
  Resume returned to the same work. Reduced-effects presentation kept a steady accent and no shake.
- Miner: the normal mode rendered mixed-script corrupted names and varying high CPU values while the
  selected explanation stayed readable. No advert or moving button was introduced.
- Stopping the protected source opened the uppercase word prompt. Lowercase `ba` appeared as `BA`;
  wrong SEND showed a recoverable error; `banana` plus a real SEND click stopped the source. Effects
  and pressure stayed frozen during typing. In a separate final launch, `banana` plus real Enter worked.
- Rebooting with the helper's Start with PC still enabled returned it to its same row with the back-again
  reaction. Turning startup off, stopping it and rebooting produced a clean result on the real PC.
- The graphical pass caught B66 (hardcoded adware reaction), B67 (clues showing through the typing
  panel) and B68 (a stopped miner still changing aliases). All were corrected before delivery. The
  final miner launch visibly showed an opaque, unobstructed prompt, working Enter and successful
  reboot. B66/B68 also have target-engine regressions.

All game processes used for this pass were stopped; the desktop inventory confirmed their windows
were gone. The temporary fixture script and disposable data are removed before delivery. Screenshots
were internal observations, not new artwork or requested deliverables.

## Limits and companion PR review

This host uses Mesa llvmpipe and dummy audio after ALSA initialization fails. Script/parse logs were
clear, but audible feedback, target-PC rendering performance and human comfort/readability acceptance
are not established. No additional art was generated or installed. The UI code uses existing fonts and
controls; no new asset approval is implied.

The separate user-requested #87/#88 review is in [PR_87_88_REVIEW.md](PR_87_88_REVIEW.md). Their affected
suites passed, but B63 independently reproduces on #88. Those unmerged runtime changes were not included
in this feature, and their passing fixtures do not verify safe cross-new-game recovery.
