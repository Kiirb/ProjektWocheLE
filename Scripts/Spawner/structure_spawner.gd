extends Node3D
class_name StructureSpawner

@export var inner_spawn_radius: float = 0.0
@export var outer_spawn_radius: float = 5.0

@export var spawn_amount: float = 50
@export var structure: PackedScene
var once_a_day: bool = true

func _process(delta: float) -> void:
	if !GameState.night && once_a_day:
		for i in range(spawn_amount):
			spawn_object()
		once_a_day = false
		
	elif GameState.night && !once_a_day:
		once_a_day = true
	
func spawn_object():
	var angle = randf() * TAU # random angle between 0 and 2π
	var radius = lerp(inner_spawn_radius, outer_spawn_radius, sqrt(randf())) # square root to keep uniform distribution in area
	var x = radius * cos(angle)
	var z = radius * sin(angle)
	var y = 0 # Adjust if you want height variation
	var position = Vector3(x, y, z)
	
	var instance = structure.instantiate()
	add_child(instance)
	instance.position = position
