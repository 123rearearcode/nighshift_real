# Counter return loading — 0.58.10 (B74)

27 November 2026. Codex (GPT-6, model id not exposed by this session), ChatGPT Work.

This is a bounded fix for the user's report that **every return to the counter** noticeably pauses,
not the scheduled performance review. Baseline: main 0.58.8 / d0710c04c5181b007e0bbe21b3d4639d7b19a134.

## Cause and correction

`CounterArt._init` asks for 14 Batch A and 9 termopan textures on each instance. Together their image
dimensions represent about 138 MiB of RGBA pixels (not an exact GPU or process-memory measurement).
The counter and its embedded drawer each create a presentation holder. Imported textures are reused
while live references exist, but the last holders leave when their scene is freed. The next return
loads new texture objects; the baseline measurement records different shell instance IDs each time.

`CounterArt` now keeps a bounded, process-local cache of successful texture loads. New scene and drawer
holders share the immutable pictures. No scene/node, inventory, visit, time, save or customer state is
cached. Missing pictures remain uncached and still fall back; source-file modification timestamps
invalidate our cache entries. Imported revisions continue to follow Godot's import/reimport mechanism.
Timestamp precision is one second; restart the running game when repeatedly overwriting an existing
artist file within that interval. No raster is changed, resized, re-encoded or newly approved.

## Targeted measurements

These measurements were taken before integrating #96, on the original isolated cache patch. The
0.58.10 correction preserves them as historical evidence; it does not claim they benchmark the new
wall/dialogue release. #96 retains 0.58.9 / B73 / p06-15; this fix uses 0.58.10 / B74 / p06-17.

Godot **4.7.2.stable.official.ed1daf0bf**, same Linux workspace, imported project, headless. The same
`tools/measure_counter_loading.gd` ran sequentially before and after the runtime change, without another
Godot process competing. It constructs/frees the art holders four times, then takes five trips between
the counter and workshop. All progress uses a disposable save. The art phase runs before the scene
phase; **the first scene sample is therefore not a cold application launch**. File-system caches are
not forcibly cleared. These numbers are scene/setup observations, not FPS or GPU frame-present latency.

| Work | 0.58.8 baseline | Cached implementation |
| --- | --- | --- |
| Initial art construction | 676.866 ms | 629.972 ms |
| Following three art constructions | 460.179, 318.922, 310.268 ms | 0.251, 0.226, 0.257 ms |
| First scene sample, after art phase | 469.424 ms | 152.309 ms |
| Following four counter returns | 297.850, 299.489, 295.435, 302.138 ms | 17.324, 17.148, 21.300, 20.752 ms |
| Median of those four returns | 298.670 ms | 19.038 ms |
| Shell texture instance ID across five visits | different on every visit | same on every visit |

The return-path median fell about 94% in this targeted run. Initial asset loading is still necessary.
The cache deliberately retains the art while in another room; it does not accumulate a new copy on
each visit. The sampled counter process-static memory stays around 172 MiB in both builds, with
negligible difference. The retained set increases memory use while away from the counter compared
with releasing all its art. Measure the perceived delay and memory on the user's machine as well.

## Regression results

The original isolated cache patch passed all **39 required suites / 2,610 checks** locally; its GitHub
Actions run [46071831524](https://github.com/123rearearcode/nighshift_real/actions/runs/46071831524) also
succeeded. Those results predate #96 integration.

After reconciling #96 and renumbering #97 to **0.58.10 / B74 / p06-17**, all **41 required Godot suites
passed: 2,648 checks, 0 failures**, in a sequential 123.4-second local Godot 4.7.2 run. The Counter art
suite passed **40 checks**, alongside the added Dialogue and Wall finishes suites. No SCRIPT ERROR,
Parse Error or FAIL lines occurred. Project hygiene passed with 0 problems; CI-scope tests passed 9;
bug-register checker passed with 0 problems and its 12 tests passed; diff whitespace checks passed.
These are automated/headless checks, not human graphical acceptance.

## Reproduce

Use an isolated XDG data/config/cache directory or a disposable test profile. After the normal editor
import, run:

```sh
godot --headless --path . --script res://tools/measure_counter_loading.gd
godot --headless --path . --script res://tools/test_counter_art.gd
```

The measurement prints raw samples as `COUNTER_LOADING` JSON and has no host-speed pass threshold.
The existing required Counter art suite checks actual room transitions with no strong test-held art
reference: the pictures survive scene disposal, the return uses the same objects, presentation
holders remain separate, and intake/cash/time do not change. It also checks missing/new/revised/removed
unimported PNG behavior. Existing checks retain exact approved file hashes, door/shutter mouse input,
customer/PC layering and the complete under-counter grid.

This does not add a loading screen, move the pause to a different menu, change approved artwork, run
a general performance audit, or claim target-PC graphical acceptance. Further first-entry threading
or reducing unused legacy art is separate work if the first visit is also a problem.
