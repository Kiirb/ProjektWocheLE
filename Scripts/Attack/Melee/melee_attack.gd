extends Area3D
class_name MeleeAttack


signal hit_target(target: CharacterBody3D)

var attacker: CharacterBody3D
var cd: float

@onready var shape_collision: CollisionShape3D = $hitbox

func _ready():
	#connect("body_entered",Callable(self,"_on_body_entered"))
	if shape_collision and shape_collision.shape:
		shape_collision.shape = shape_collision.shape.duplicate()
	
	
func init(_attacker: CharacterBody3D):
	attacker = _attacker
	set_area_size()	
	cd = attacker.get_stats().auto_cd_modifier
	
	collision_layer = 4
	if attacker is Player:
		collision_mask = 3 #to Detect enemies
	elif attacker is Enemy:
		collision_mask = 1 #to Detect the player

func set_area_size():
	var stats = attacker.stats
	if shape_collision.shape is SphereShape3D:
		shape_collision.shape.radius = stats.melee_range
