extends Enemy
class_name Demon

@onready var animation_player: AnimationPlayer = $Demon2/AnimationPlayer

@onready var timer: Timer = $Timer
var attacking: bool = false


func attack():
	attacking = true
	animation_player.play("Attack")
	timer.start(0.3)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !attacking:
		animation_player.play("Walk")


func _on_timer_timeout() -> void:
	attacking = false
