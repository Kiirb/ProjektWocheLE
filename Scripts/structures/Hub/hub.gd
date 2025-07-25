extends CharacterBody3D
class_name Hub

@export var stats: StatsData
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	stats.armor = 1
	stats.max_health = 100
	stats.hp = 100

func death():
	GameState.die()
	print("the hub died")

func get_stats():
	return stats
