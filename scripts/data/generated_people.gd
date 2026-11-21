# DATA ONLY: the pools generated customers are drawn from (session 3.5 / 0.48.0, user 18 November 2026:
# "random parody names with a type are fine"; personas and lore come later). Every person is fictional:
# a first name plus an initial, never a real person. Professions are the first-cut three (D96).
# The texts describe how the person uses and treats a PC, never what is wrong with it.
extends RefCounted

const FIRST_NAMES: Array = ["Ana", "Bogdan", "Cristi", "Dana", "Elena", "Florin", "Gabi", "Ioana", "Irina", "Matei",
    "Nicu", "Oana", "Paul", "Radu", "Sorin", "Tudor", "Vlad", "Lavinia", "Costel", "Mihaela", "Sanda", "Petru",
    "Corina", "Dorin", "Raluca", "Toma", "Viorica", "Emil", "Bianca", "Ovidiu"]
const INITIALS: String = "ABCDEFGHIJKLMNOPRSTUVZ"

const PROFESSIONS: Array = ["regular", "gamer", "clueless"]
const PROFESSION_WEIGHTS: Dictionary = {"regular": 5, "gamer": 4, "clueless": 2}

# Per profession: personas, background lines, how they use the PC, habits, patience.
const TEXTS: Dictionary = {
    "regular": {
        "persona": ["Polite and practical; wants it fixed, not explained.", "Friendly, a little rushed, pays on time.", "Careful with money; asks what everything costs."],
        "about": ["Works in an office across the street.", "Runs a small bakery's books from home.", "Teacher; prepares lessons on this PC every night."],
        "uses": ["Office work, browsing and video calls.", "Spreadsheets, email and the odd film.", "Online banking, photos and school work for the kids."],
        "habits": ["Never opens the case.", "Keeps the PC under the desk, next to the radiator.", "Would notice loud fans straight away."],
        "patience": ["Needs it back within two days.", "Can wait a few days.", "Needs it back tomorrow."],
    },
    "gamer": {
        "persona": ["Talks benchmark numbers; hates stutter.", "Competitive and impatient; streams on weekends.", "Quiet, but checks every frame-rate counter."],
        "about": ["Student; plays ranked matches every evening.", "Night-shift worker who games after work.", "Saved up for this PC for a year."],
        "uses": ["Counter Stroke 2 most evenings.", "Ranked Counter Stroke 2 and streaming.", "Counter Stroke 2 with friends on weekends."],
        "habits": ["Opens the case and watches temperatures.", "Tweaks settings for more speed.", "Would spot a swapped part within a week."],
        "patience": ["Can wait two days, not three.", "Wants it back before the weekend.", "Needs it back tomorrow."],
    },
    "clueless": {
        "persona": ["Kind and chatty; repeats what the salesman told them.", "Proud of the PC, unsure what is inside.", "Trusts whatever the shop says."],
        "about": ["Retired; the grandchildren set the PC up.", "Bought the PC second-hand from a neighbour.", "Uses the PC for the family business's emails."],
        "uses": ["Email, recipes and photos of the grandchildren.", "Video calls with family abroad.", "Reading the news and online crosswords."],
        "habits": ["Never opens the case.", "Leaves it switched on all day.", "Calls the shop to ask how it is going."],
        "patience": ["Can wait as long as needed.", "Can wait a few days.", "Would like it back by the weekend."],
    },
}

# What a clueless customer SAYS they need (D93: the decoy). The real need decides their pickup.
const DECOY_NEED: Dictionary = {"boots": true, "games": [{"game_id": "counter_stroke_2", "min_fps": 120}]}
