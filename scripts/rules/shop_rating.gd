# RULES ONLY: the shop's online rating, its reputation and how many new customers they bring each
# morning (session 3.5 / 0.48.0; user, 18 November 2026: "tickets will come in in the morning based on how
# many new customers you will have, which is based on your reputation and online rating"). Pure.
# The elegance score of session 3.8 will feed the rating later. Numbers are trial proposals (D154).
extends RefCounted

const Reviews = preload("res://scripts/rules/reviews.gd")

const MAX_OPEN: int = 4              # customer PCs the shop holds at once (storage tie-in later)
const MAX_ARRIVALS: int = 3
const DEFAULT_RATING: float = 3.0    # stars before the first review
const REVIEWS_COUNTED: int = 10      # the online rating averages the latest reviews


# The online rating in stars (1..5) from the latest reviews. 0.52.0: one rule, in reviews.gd (review
# records with stars; plain pickup scores 0..100 still work for old saves).
static func rating(reviews: Array) -> float:
    return Reviews.rating(reviews)


# The shop's reputation: the average trust of the customers it has served (50 before any).
static func reputation(trusts: Array) -> int:
    if trusts.is_empty(): return 50
    var total: int = 0
    for t: Variant in trusts: total += clampi(int(t), 0, 100)
    return roundi(float(total) / trusts.size())


# New customers this morning. Never more than the shop can hold; an empty shop always gets one walk-in.
static func arrivals(stars: float, rep: int, open_count: int) -> int:
    var n: int = 1
    if stars >= 3.5: n += 1
    if stars >= 4.5: n += 1
    if rep >= 60: n += 1
    if stars < 2.5: n -= 1
    n = clampi(n, 0, MAX_ARRIVALS)
    n = mini(n, maxi(0, MAX_OPEN - open_count))
    if open_count == 0: n = maxi(n, 1)
    return n


static func summary(stars: float, review_count: int, rep: int, count: int) -> String:
    return "Online rating %.1f★ (%d review%s) · reputation %d/100 · %d new customer%s this morning." % [stars, review_count,
        "" if review_count == 1 else "s", rep, count, "" if count == 1 else "s"]
