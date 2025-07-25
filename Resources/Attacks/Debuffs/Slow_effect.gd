extends DebuffData
class_name SlowEffect

@export var slow_percent: float = 0.4

func do_effect(target: CharacterBody3D, source: CharacterBody3D) -> void:
	if target.has_method("apply_slow"):
		target.apply_slow(slow_percent * 100.0, duration)
