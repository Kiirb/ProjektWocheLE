extends Enemy
class_name SkeletonBoss

@onready var animation_player: AnimationPlayer = $SkeletonBoss_mesh/AnimationPlayer
@onready var timer: Timer = $Timer
@onready var spawner_timer = $Spawn_minions_timer
var attacking: bool = false

var spawner: Spawner
@export var minions_per_spawn: int = 3
@export var minion_pool: PoolData

func _ready():
	super._ready()
	if spawner == null or not spawner:
		get_node("/root/MainGame/Player")
	
	timer.wait_time = 120  # change
	timer.connect("timeout", Callable(self, "_on_spawn_minions"))
	timer.start()
	
func _on_spawn_minions():
	if !is_inside_tree() or !is_instance_valid(spawner):
		return

	# Only spawn if boss is alive
	if self.is_queued_for_deletion():
		return

	spawner.spawn_custom_enemies(minions_per_spawn,minion_pool)
	timer.start()  # restart timer for the next spawn

func attack():
	attacking = true
	animation_player.play("Attack")
	timer.start(0.3)

func _process(delta: float) -> void:
	if velocity != Vector3.ZERO && !attacking:
		animation_player.play("Walk")


func _on_timer_timeout() -> void:
	attacking = false
