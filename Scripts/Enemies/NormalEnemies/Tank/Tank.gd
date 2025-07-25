extends Enemy
class_name Tank

@onready var timer: Timer = $Timer
@onready var animationplayer: AnimationPlayer = $Knight/AnimationPlayer
var is_attacking: bool = false


func attack():
	is_attacking = true
	animationplayer.play("1H_Melee_Attack_Chop")
	timer.start(1)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !is_attacking:
		animationplayer.play("Running_A")

func _on_timer_timeout() -> void:
	is_attacking = false
