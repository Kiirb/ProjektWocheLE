extends Node3D
class_name ExpManager

@export var player_ref: Player
var spawner_ref: Spawner
@onready var hub_ref: Hub
@export var exp_orb_data: ExpOrbData
var lvl: int = 1

var exp_collected_in_round: float

var exp :float = 0
var exp_total: float = 0
var ex_required: float = get_exp_required(lvl+1)

const EXP_CURVE = 1.8

func _ready():
	hub_ref = get_tree().current_scene.get_node("Hub")
	spawner_ref = get_parent().spawner_ref
#	spawner_ref.connect("day_cleared", Callable(self, "_on_day_cleared"))
	
func get_exp_required(level: int):
	return round(pow(level,EXP_CURVE) + lvl * 4)
	
func gain_exp(amount):
	exp_total += amount
	exp += amount
	while exp >= ex_required:
		exp -= ex_required
		lvl_up()
	print("Current exp: ", exp, " | of: ", ex_required)
		
func lvl_up():
	lvl += 1
	print("Level up from: ",lvl-1 ," -> ", lvl, "| total of: ",ex_required)
	ex_required = get_exp_required(lvl+1)
	player_ref.ui.player_upgrades.open()

func _on_day_cleared(enemies_spawned: int) -> void:
	var origin = hub_ref.global_position 
	var spawn_count = max(enemies_spawned,1) + 10
	for i in range(enemies_spawned):
		
		var exp_orb_scene = exp_orb_data.scene
		var orb = exp_orb_scene.instantiate()
		
		
		orb.xp_value = (exp_collected_in_round / spawn_count) * player_ref.stats.luck

		var a = 50.0
		var b = 70.0
		var angle = randf_range(0, TAU)
		var radius = randf_range(a, b)
		var offset = Vector3(cos(angle), 0, sin(angle)) * radius
		offset.y = 5.0
		orb.global_position = origin + offset

		# Add to scene first
		get_tree().current_scene.add_child(orb)

		# Launch it upwards and with a bit of random horizontal velocity
		var launch_velocity = Vector3(
			randf_range(-1.5, 1.5),
			randf_range(30, 45.0),  # Upward force
			randf_range(-1.5, 1.5)
		)
		orb.apply_impulse(Vector3.ZERO, launch_velocity)
	exp_collected_in_round = 0
