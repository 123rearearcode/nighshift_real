# DATA ONLY: video games the shop can buy and install to test a customer's PC (D94). The shop must
# OWN a game to run its FPS test on the software screen: knowing exactly how a PC will run costs an
# investment. A game's demands are "the power that yields 60 fps" per component; scripts/rules/fps_sim.gd
# turns them into a simulated frame rate. Titles are parodies. Numbers are trial proposals.
extends RefCounted

const IDS: Array = ["counter_stroke_2"]
const BASE_FPS: float = 60.0          # a part exactly meeting a demand yields this many fps


static func game(id: String) -> Dictionary:
    if id == "counter_stroke_2":
        return {"id": "counter_stroke_2", "title": "Counter Stroke 2", "price": 12,
            "gpu_demand": 55, "cpu_demand": 60, "ram_min": 8}
    return {}
