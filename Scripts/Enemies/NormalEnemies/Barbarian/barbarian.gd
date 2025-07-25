extends Enemy
class_name Barbarian

@onready var timer: Timer = $Timer
@onready var animation: AnimationPlayer = $Barbarian_mesh/AnimationPlayer
var is_fighting: bool = false

func attack():
	is_fighting = true
	animation.play("1H_Melee_Attack_Chop")
	timer.start(1)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !is_fighting:
		animation.play("Running_A")

func _on_timer_timeout() -> void:
	is_fighting = false
	
