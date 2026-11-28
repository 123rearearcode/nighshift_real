# RULES ONLY: online reviews, the shop's trustworthiness and its level, and customers finding out
# (Wave 3 session 3.8 / 0.52.0, D160). Pure functions; every random roll is seeded from the save's world
# seed, so the same save always gets the same reviews.
#
# User, 20 November 2026 (D160): no elegance score ("it doesn't work well with the scamminess of the
# game"). Instead a TRUSTWORTHINESS that feeds the SHOP LEVEL; it rises with good work and only falls when
# customers FIND OUT what happened (they go online and write about it). Honest mistakes found out and scams
# found out both hurt. Every pickup leaves a review, and customers are not always fair: some knock a star
# off for petty reasons, which gives the player a reason to feel justified in scamming. Reviews are stars
# with comments, read on the player's phone, where fake reviews can be bought (with a risk of being caught).
#
# Scam hooks this file closes or keeps open: the hidden deceptions found out later are toothpaste under the
# cooler, second-hand parts handed over as if new, a build sold far above what its parts are worth, and a
# customer's working part kept by the shop. Fake reviews are themselves a scam the review site can catch.
# LATER (user): replying to reviews and paying an angry customer to take a review down (design doc).
# All numbers and texts are trial proposals.
extends RefCounted

const People = preload("res://scripts/data/generated_people.gd")

const SITE := "FixFindr"            # parody review site, shown in the phone app
const KEEP: int = 40                # reviews kept (the phone lists them; the rating counts the latest)
const COUNTED: int = 10             # the online rating averages the latest reviews (as in 0.48.0)
const PICKUP := "pickup"
const FOUND := "found_out"
const FAKE := "fake"
const NOTICE := "notice"            # the review site's own notice (not a review; never counted)
const KINDS: Array = [PICKUP, FOUND, FAKE, NOTICE]

# ---- stars from a pickup ----

const PETTY_CHANCE: float = 0.3     # a customer knocks a star off for a reason that has nothing to do with the work
const PETTY: Array = ["Took ALL night. Who works at night anyway?", "The guy at the counter didn't even look up from his phone.",
    "Shop smells like old coffee and solder.", "Expected more for the money, honestly.", "They wouldn't give me a discount for paying cash.",
    "Parking is a nightmare around there.", "Fine I guess. My nephew could have done it.", "Nobody offered me a coffee while I waited."]
const PRAISE: Array = ["Fixed overnight and runs like new. Recommended!", "Honest, fast, cheap. What more do you want.",
    "Explained nothing but it works perfectly now.", "Quiet and fast again. Will come back."]
const OKAY: Array = ["Works, mostly.", "It does the job.", "Better than before, not perfect."]
const BAD: Array = ["Paid and it's still not right.", "Not impressed.", "Waste of a night."]
const NO_BOOT: String = "They handed it back and it doesn't even turn on."
const BUILD_PRAISE: Array = ["Built exactly what I needed. Love it.", "Great little PC for the price.", "Runs everything I throw at it."]


static func stars_for(score: int) -> int:
    if score >= 90: return 5
    if score >= 70: return 4
    if score >= 50: return 3
    if score >= 30: return 2
    return 1


static func _rng(seed: int, key: String) -> RandomNumberGenerator:
    var r := RandomNumberGenerator.new()
    r.seed = hash("review:%d:%s" % [seed, key])
    return r


static func _pick(r: RandomNumberGenerator, list: Array) -> String:
    return str(list[r.randi_range(0, list.size() - 1)])


static func record(stars: int, text: String, kind: String, night: int, ticket: String, author: String) -> Dictionary:
    return {"stars": clampi(stars, 1, 5), "text": text.strip_edges().left(240), "kind": kind if kind in KINDS else PICKUP,
        "night": maxi(1, night), "ticket": ticket.left(16), "author": author.strip_edges().left(40)}


# The review a customer writes when they collect. `score` 0..100 (pickup_score.gd), `misses` what they
# noticed, `boots` whether it starts. Deterministic per save and ticket.
static func pickup_review(seed: int, ticket: String, author: String, night: int, score: int, misses: Array, boots: bool, build: bool) -> Dictionary:
    var r: RandomNumberGenerator = _rng(seed, "pickup:" + ticket)
    if not boots: return record(1, NO_BOOT, PICKUP, night, ticket, author)
    var stars: int = stars_for(score)
    var text: String
    if stars >= 4: text = _pick(r, BUILD_PRAISE if build else PRAISE)
    elif stars == 3: text = _pick(r, OKAY)
    else: text = _pick(r, BAD)
    if not misses.is_empty() and stars < 5:
        var miss: String = str(misses[0])
        text += " " + miss.left(1).to_upper() + miss.substr(1) + "."
    if r.randf() < PETTY_CHANCE:
        stars = maxi(1, stars - 1)
        text += " " + _pick(r, PETTY)
    return record(stars, text, PICKUP, night, ticket, author)


# ---- the online rating ----

# Stars (1..5) from the latest reviews. Accepts review records and, for old saves and the 0.48.0 tests,
# plain pickup scores (0..100). Notices never count. 3.0 before the first review.
static func rating(reviews: Array) -> float:
    var values: Array = []
    for item: Variant in reviews:
        if item is Dictionary:
            if str((item as Dictionary).get("kind", PICKUP)) == NOTICE: continue
            values.append(float(clampi(int((item as Dictionary).get("stars", 3)), 1, 5)))
        elif typeof(item) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(item)):
            values.append(1.0 + 4.0 * clampf(float(item), 0.0, 100.0) / 100.0)
    var recent: Array = values.slice(maxi(0, values.size() - COUNTED))
    if recent.is_empty(): return 3.0
    var total: float = 0.0
    for v: Variant in recent: total += float(v)
    return snappedf(total / recent.size(), 0.1)


static func counted(reviews: Array) -> int:
    return reviews.filter(func(item: Variant) -> bool: return not (item is Dictionary and str((item as Dictionary).get("kind", "")) == NOTICE)).size()


# Rebuilds saved reviews: records from known fields; an old plain score becomes a pickup review.
static func sanitize(raw: Variant) -> Array:
    var out: Array = []
    if not raw is Array: return out
    for item: Variant in raw:
        if item is Dictionary:
            var d: Dictionary = item
            if not typeof(d.get("stars", null)) in [TYPE_INT, TYPE_FLOAT]: continue
            var kind: String = str(d.get("kind", PICKUP))
            var night: Variant = d.get("night", 1)
            out.append(record(int(d["stars"]), str(d.get("text", "")), kind, int(night) if typeof(night) in [TYPE_INT, TYPE_FLOAT] else 1, str(d.get("ticket", "")), str(d.get("author", ""))))
        elif typeof(item) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(item)):
            out.append(record(stars_for(clampi(int(item), 0, 100)), "(an older review)", PICKUP, 1, "", "A customer"))
    return out.slice(maxi(0, out.size() - KEEP))


static func stars_text(stars: int) -> String:
    var n: int = clampi(stars, 1, 5)
    return "★".repeat(n) + "☆".repeat(5 - n)


# ---- trustworthiness and the shop level ----

# Trust points: earned by good pickups, lost only when customers find something out. Never below 0.
const PICKUP_POINTS: Dictionary = {5: 3, 4: 2, 3: 1}     # by the work's own stars (before pettiness)
const HONEST_MISTAKE_POINTS: int = 5                      # per hidden mistake a customer comes back about
const CAUGHT_FAKES_POINTS: int = 25
const LEVELS: Array = [0, 15, 40, 80, 140, 220]           # trust points needed for levels 1..6


static func pickup_points(score: int, boots: bool) -> int:
    return int(PICKUP_POINTS.get(stars_for(score), 0)) if boots else 0


static func level(points: int) -> int:
    var lv: int = 1
    for i in range(LEVELS.size()):
        if points >= int(LEVELS[i]): lv = i + 1
    return lv


# Points still needed for the next level (-1 at the top).
static func to_next(points: int) -> int:
    var lv: int = level(points)
    return -1 if lv >= LEVELS.size() else int(LEVELS[lv]) - points


static func standing_text(points: int) -> String:
    var next: int = to_next(points)
    return "Trustworthiness %d · shop level %d%s" % [points, level(points), (" (next level in %d)" % next) if next > 0 else " (top level)"]


# ---- customers finding out (hidden deceptions, D160) ----

const DECEPTIONS: Dictionary = {
    "toothpaste": {"chance": 0.5, "points": 12, "nights": [2, 4], "say": "they found toothpaste under the CPU cooler",
        "review": "Found TOOTHPASTE under my CPU cooler. Toothpaste. Avoid this place."},
    "used_parts": {"chance": 0.3, "points": 10, "nights": [3, 5], "say": "the 'new' part they paid for turned out to be second-hand",
        "review": "The part they put in is second-hand. Scratches, old dust, the lot. Charged me like it was new."},
    "overpriced": {"chance": 0.35, "points": 10, "nights": [2, 5], "say": "a friend priced the parts of their build: they paid far more than it is worth",
        "review": "My friend priced every part. I paid almost double what this PC is worth. Rip-off."},
    "kept_part": {"chance": 0.2, "points": 8, "nights": [2, 4], "say": "the part the shop 'replaced' was working fine, and the shop kept it",
        "review": "They swapped a part that was fine and KEPT my old one. Wonder how many times they do that."},
}
const FOUND_PREFIX := "found:"
const OVERPRICED_SHARE: float = 0.6   # a build worth less than this share of its budget is "overpriced"
# Habits that make a customer more or less likely to find out (generated_people.gd and customers.gd texts).
# 0.59.1: "the laptop" reads like "the case" (Mara's habit now says laptop; her odds are unchanged).
const NOSY: Array = ["opens the case", "opens the laptop", "watches temperatures", "spot a swapped part", "reads and writes online reviews", "tweaks settings"]
const TRUSTING: Array = ["never opens the case", "never opens the laptop", "trusts whatever the shop says"]


static func is_found(fault: String) -> bool:
    return fault.begins_with(FOUND_PREFIX) and DECEPTIONS.has(fault.trim_prefix(FOUND_PREFIX))


# Chance this customer finds out about one deception.
static func find_chance(kind: String, person: Dictionary) -> float:
    var chance: float = float(DECEPTIONS.get(kind, {}).get("chance", 0.0))
    var about: String = ("%s %s" % [str(person.get("habits", "")), str(person.get("persona", ""))]).to_lower()
    if NOSY.any(func(h: String) -> bool: return about.contains(h)): chance *= 1.5
    if TRUSTING.any(func(h: String) -> bool: return about.contains(h)): chance *= 0.5
    return clampf(chance, 0.0, 0.95)


# Which of `hidden` deceptions this customer will find out, and after how many mornings:
# [{fault: "found:<kind>", nights}]. Deterministic per save, ticket and deception.
static func discoveries(seed: int, ticket: String, person: Dictionary, hidden: Array) -> Array:
    var out: Array = []
    for kind: Variant in hidden:
        if not DECEPTIONS.has(str(kind)): continue
        var r: RandomNumberGenerator = _rng(seed, "found:%s:%s" % [ticket, kind])
        if r.randf() >= find_chance(str(kind), person): continue
        var span: Array = DECEPTIONS[kind]["nights"]
        out.append({"fault": FOUND_PREFIX + str(kind), "nights": r.randi_range(int(span[0]), int(span[1]))})
    return out


static func complaint(fault: String) -> String:
    return str(DECEPTIONS[fault.trim_prefix(FOUND_PREFIX)]["say"]) if is_found(fault) else ""


static func annoyance(faults: Array) -> float:
    return 40.0 * faults.filter(func(f: Variant) -> bool: return is_found(str(f))).size()


# Trust points lost when a comeback arrives: each found-out deception, and each honest mistake.
static func found_points(faults: Array) -> int:
    var lost: int = 0
    for f: Variant in faults:
        lost += int(DECEPTIONS[str(f).trim_prefix(FOUND_PREFIX)]["points"]) if is_found(str(f)) else HONEST_MISTAKE_POINTS
    return lost


# The review a customer writes when they come back having found something out. `complaints` = the
# customer-facing texts of the honest faults (morning.gd).
static func found_review(faults: Array, complaints: Array, night: int, ticket: String, author: String) -> Dictionary:
    for f: Variant in faults:
        if is_found(str(f)): return record(1, str(DECEPTIONS[str(f).trim_prefix(FOUND_PREFIX)]["review"]), FOUND, night, ticket, author)
    var why: String = str(complaints[0]) if not complaints.is_empty() else "it broke again"
    return record(2, "Two days after I got it back, %s. Had to bring it back." % why, FOUND, night, ticket, author)


# ---- fake reviews (ReviewBoost, on the phone) ----

const FAKE_PACK: int = 3
const FAKE_PRICE: int = 45
const FAKE_TEXTS: Array = ["Best PC shop in town!!! 10/10", "Amazing service, super professional, fixed in minutes!",
    "These guys are geniuses. Highly recommend!!!", "Five stars. Honest and fast. Will be back!", "Saved my PC AND my day. Thank you!!"]
const CATCH_BASE: float = 0.12        # each night the review site checks the shop's new reviews
const CATCH_PER_RECENT_ORDER: float = 0.08
const CATCH_IF_MOSTLY_FAKE: float = 0.2


static func fake_reviews(seed: int, night: int, order: int) -> Array:
    var r: RandomNumberGenerator = _rng(seed, "fake:%d:%d" % [night, order])
    var out: Array = []
    for i in range(FAKE_PACK):
        var author: String = "%s %s." % [_pick(r, People.FIRST_NAMES), People.INITIALS[r.randi_range(0, People.INITIALS.length() - 1)]]
        out.append(record(5, _pick(r, FAKE_TEXTS), FAKE, night, "", author))
    return out


# The chance the review site catches the shop's fake reviews this morning. `orders` = nights of recent
# purchases; `reviews` = the shop's reviews now.
static func catch_chance(orders: Array, night: int, reviews: Array) -> float:
    var recent: int = orders.filter(func(n: Variant) -> bool: return int(n) >= night - 2).size()
    if recent == 0: return 0.0
    var latest: Array = reviews.filter(func(v: Variant) -> bool: return v is Dictionary and str(v.get("kind", "")) != NOTICE)
    latest = latest.slice(maxi(0, latest.size() - COUNTED))
    var fakes: int = latest.filter(func(v: Variant) -> bool: return str(v.get("kind", "")) == FAKE).size()
    var chance: float = CATCH_BASE + CATCH_PER_RECENT_ORDER * float(recent - 1)
    if fakes * 2 > latest.size(): chance += CATCH_IF_MOSTLY_FAKE
    return clampf(chance, 0.0, 0.9)


static func caught(seed: int, night: int, chance: float) -> bool:
    return _rng(seed, "catch:%d" % night).randf() < chance
