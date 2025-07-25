extends Enemy
class_name Yeti

@onready var animation_player: AnimationPlayer = $Yeti2/AnimationPlayer
@onready var timer: Timer = $Timer
var attacking: bool = false

func _ready():
	auto_att_manager.spawn_height = 2

func attack():
	attacking = true
	animation_player.play("Attack")
	timer.start(0.3) 

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !attacking:
		animation_player.play("Walk")


func _on_timer_timeout() -> void:
	attacking = false
