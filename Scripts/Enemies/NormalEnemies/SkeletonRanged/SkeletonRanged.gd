extends Enemy
class_name SkeletonRanged

@onready var timer: Timer = $Timer
@onready var animationplayer: AnimationPlayer = $Skeleton_Rogue/AnimationPlayer
var is_attacking: bool = false

func attack():
	is_attacking = true
	animationplayer.play("Spellcast_Shoot")
	timer.start(1)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !is_attacking:
		animationplayer.play("Running_A")

func _on_timer_timeout() -> void:
	is_attacking = false
