# The morning's words (D136, 0.44.0; 0.53.0, D161: shown by the customers at the counter instead of a
# report screen). Pure text from NightSession.last_report cards; changes nothing.
extends RefCounted
const WorkReport = preload("res://scripts/rules/work_report.gd")
const PartStates = preload("res://scripts/rules/part_states.gd")
const Reviews = preload("res://scripts/rules/reviews.gd")
const COLORS: Dictionary = {"collected":Color("6fcf97"),"comeback":Color("eb5757"),"waiting":Color("f2c94c"),"new":Color("8eafc3"),"notice":Color("bb6bd9")}
const TITLES: Dictionary = {"collected":"COLLECTED","comeback":"CAME BACK","waiting":"STILL HERE","new":"NEW TICKET","notice":"REVIEW SITE"}

# First-day introduction: only what the customer says and the existing agreed repair fee. In
# particular, don't turn actual broken parts, infection, condition or true budget into dialogue.
static func opening_text(card: Dictionary, person: Dictionary) -> String:
    var lines: Array = ["%s · %s" % [str(card.get("customer", "")), str(card.get("ticket", ""))],
        "Reported problem: %s" % str(card.get("complaint", ""))]
    if str(person.get("uses", "")) != "": lines.append("Used for: %s" % str(person["uses"]))
    if str(person.get("patience", "")) != "": lines.append("Customer's timing: %s" % str(person["patience"]))
    lines.append("Repair fee: $%d, paid when collected." % int(card.get("payout", 0)))
    lines.append("Accept the PC and put its ticket on the clipboard. No money changes hands now.")
    return "\n\n".join(lines)

# 0.58.9 (D181): what a new customer SAYS at the counter, line by line (dialogue_box.gd). Only what they would
# say themselves: greeting, the problem in their words, what they use it for, their timing. Story customers
# can have their own `greeting` and `patience_line` (data/customers.gd); others get plain lines. Never the
# hidden faults, infection, condition or true budget.
static func opening_lines(card: Dictionary, person: Dictionary) -> Array:
    var out: Array = [str(person.get("greeting", "Good morning. Is this the computer repair shop?"))]
    var complaint: String = str(card.get("complaint", person.get("complaint", "")))
    if complaint != "": out.append(complaint)
    var uses: String = str(person.get("uses", ""))
    if uses != "": out.append("I use it for " + uses.left(1).to_lower() + uses.substr(1))
    if str(person.get("patience_line", "")) != "": out.append(str(person["patience_line"]))
    return out


# What someone walking in on a morning says: a new customer as above, a collection by how it went, a comeback.
static func visit_lines(card: Dictionary, person: Dictionary) -> Array:
    match str(card.get("kind", "")):
        "new": return opening_lines(card, person)
        "comeback": return ["It's acting up again. I'm bringing it back."]
        "collected":
            var reaction: String = str(card.get("reaction", ""))
            if reaction.begins_with("Furious"): return ["It doesn't even turn on! I'm not paying for this."]
            if reaction.begins_with("Happy"): return ["Thank you! It runs like new."]
            if reaction.begins_with("Disappointed"): return ["Hm. I expected better, to be honest."]
            if reaction.begins_with("Angry"): return ["This is not what I paid for."]
            return ["I'm here for my PC."]
    return []


static func card_text(card: Dictionary) -> String:
    var kind: String = str(card.get("kind","new"))
    var lines: Array = ["%s · %s · %s"%[TITLES.get(kind,""),str(card.get("customer","")),str(card.get("ticket",""))],str(card.get("reaction",""))]
    if kind == "collected": lines.append("Paid $%d · trust %+d (now %d)"%[int(card.get("paid",0)),int(card.get("trust_change",0)),int(card.get("trust",0))])
    # D150; B71 (0.58.7): the old part is kept as UNTESTED stock whatever its real condition, so the slip must not
    # call it working (it used to, even for a broken one) and must not hint at the hidden condition.
    for name: Variant in card.get("kept",[]): lines.append("Kept in your stock: their old %s, untested (you fitted a replacement, so the old part stays with the shop). The testing bay can tell you what it is worth."%str(name))
    if kind == "comeback": lines.append("Trust %+d (now %d)"%[int(card.get("trust_change",0)),int(card.get("trust",0))])
    var review: Variant = card.get("review",{})   # 0.52.0: what they wrote online
    if review is Dictionary and not (review as Dictionary).is_empty():
        lines.append("Review: %s “%s”"%[Reviews.stars_text(int(review.get("stars",3))),str(review.get("text",""))])
    if int(card.get("points",0)) != 0: lines.append("Trustworthiness %+d"%int(card.get("points",0)))
    for miss: Variant in card.get("misses",[]): lines.append("· "+str(miss))
    return "\n".join(lines)

# What hovering shows: the PC's state (as collected, or as it stands), never hidden faults.
static func detail_text(card: Dictionary) -> String:
    var job: Dictionary = card.get("job",{})
    if job.is_empty(): return card_text(card)
    var lines: Array = ["%s · %s · %s"%[str(job.get("customer","")),str(job.get("id","")),"Laptop" if str(job.get("layout","")) == "laptop" else str(job.get("layout","tower")).capitalize()+" PC"]]   # 0.59.1
    if card.get("kind","") == "collected": lines.append("As it left the shop (%.0f°C in the shop's own check)."%float(card.get("temp",0.0)))
    else: lines.append("As it stands in your shop.")
    lines.append("")
    lines.append_array(WorkReport.work_lines(job))
    lines.append("")
    lines.append("Parts: "+PartStates.summary(job))
    return "\n".join(lines)
