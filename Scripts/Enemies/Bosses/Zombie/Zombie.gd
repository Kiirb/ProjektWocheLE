extends Enemy
class_name Zombie

@onready var animation_player: AnimationPlayer = $Zombie_mesh/AnimationPlayer
@onready var timer: Timer = $Timer
var attacking: bool = false
var lives := 2
 

#should work
func death():
	if lives <= 0:
		lives -= 1
		return
	emit_signal("died")
	queue_free()

func attack():
	attacking = true
	animation_player.play("Attack")
	timer.start(0.3)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !attacking:
		animation_player.play("Walk")


func _on_timer_timeout() -> void:
	attacking = false
