# RULES ONLY: the night's clock (D133). Pure. The shift starts at 22:00; some monitor tests take night
# minutes. There is NO end-of-night consequence yet: the clock only shows what the time would be.
# Durations are trial proposals.
extends RefCounted

const START_MINUTE: int = 22 * 60
const SHIFT_MINUTES: int = 8 * 60      # 22:00 -> 06:00
const GAME_TEST_MINUTES: int = 30
const LONG_STRESS_MINUTES: int = 20


static func label(elapsed: int) -> String:
    var now: int = (START_MINUTE + maxi(0, elapsed)) % (24 * 60)
    return "%02d:%02d" % [now / 60, now % 60]


static func over(elapsed: int) -> bool:
    return elapsed >= SHIFT_MINUTES


static func line(elapsed: int) -> String:
    return "Night clock %s" % label(elapsed) + (" · past 06:00" if over(elapsed) else "")


# 0.47.0 (D150): a timed test may only start when it ends by 06:00. No result is made up past it.
static func fits(elapsed: int, minutes: int) -> bool:
    return elapsed + maxi(0, minutes) <= SHIFT_MINUTES
