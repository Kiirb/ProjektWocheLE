extends Enemy
class_name Giant

@onready var animation_player: AnimationPlayer = $Giant_mesh/AnimationPlayer

@onready var timer: Timer = $Timer
var attacking: bool = false

@export var hub_dmg_multiplier:float = 1.0
var base_multiplier: float

func _ready() -> void:
	super._ready()
	base_multiplier = stats.dmg_multiplyer
	
func attack():
	attacking = true
	animation_player.play("Attack")
	timer.start(0.3)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !attacking:
		animation_player.play("Walk")
	if target is Hub:
		stats.dmg_multiplyer += 1.5
	else:
		stats.dmg_multiplyer = base_multiplier
func _on_timer_timeout() -> void:
	attacking = false
