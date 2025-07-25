extends Enemy
class_name Shooter

@onready var animation_player: AnimationPlayer = $Rogue/AnimationPlayer
@onready var timer: Timer = $Timer
var is_shooting: bool = false


func attack():
	is_shooting = true
	animation_player.play("2H_Ranged_Shoot")
	timer.start(1)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !is_shooting:
		animation_player.play("Running_A")

func _on_timer_timeout() -> void:
	is_shooting = false
