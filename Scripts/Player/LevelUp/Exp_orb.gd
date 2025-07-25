extends RigidBody3D
class_name ExpOrb

var xp_value: float = 10.0
@onready var pick_up_area: Area3D = $Area3D
@onready var col_shape: CollisionShape3D = $CollisionShape3D

@export var move_speed: float = 3.0
const ATT_DISTANCE: float = 2.0

var player : Player
var attrackted := false
func _ready():
	pick_up_area.body_entered.connect(_on_body_entered)
		
func _on_body_entered(body: Player):
	if body is Player:
		player = body
		attrackted = true

func _physics_process(delta: float) -> void:
	if attrackted and player:
		var dir = (player.global_position - global_position)
		var distance = dir.length()
		
		if distance >= ATT_DISTANCE:
			var step = dir.normalized() * move_speed * delta
			global_position += step
		else:
			player.exp_manager.gain_exp(xp_value)
			queue_free()
