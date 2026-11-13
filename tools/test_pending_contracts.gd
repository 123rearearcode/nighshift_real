# Known defects, not passing coverage: a non-blocking CI lane (docs/TESTING.md). EMPTY since 0.21.0:
# the D57 stage-switch bypass and the refused-selection highlight were fixed and their checks promoted
# into tools/test_regressions.gd (test_promoted_contracts). Add new known defects here when found.
extends "res://tools/test_support.gd"

func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
    finish("Pending contracts")
