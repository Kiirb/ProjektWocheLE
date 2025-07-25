extends CharacterBody3D
class_name Enemy

signal died
signal hit_player(from: CharacterBody3D)
var player: Player = null
var hub : Hub = null

@onready var auto_att_manager: AutoAttackManager = $AutoAttackManager
@onready var melee_area := $AutoAttackManager/MeleeRangeArea
@onready var nav_agent := $NavigationAgent3D
@onready var hub_radius: float
var target: CharacterBody3D

@export var stats: StatsData
var base_speed: float
var slow_timer: Timer
var base_dmg: float


func attack():
	pass

func _ready():
	await get_tree().process_frame
		
	#For Player Detection
	collision_layer = 3
	collision_mask = 1
	
	auto_att_manager.conf_auto_attack()
	auto_att_manager.set_melee_area_size(melee_area)
	if not player:
		player = get_tree().current_scene.get_node("Player")
	base_speed = stats.move_speed
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	slow_timer.connect("timeout", self._on_slow_timeout)
	add_child(slow_timer)

func _on_slow_timeout():
	stats.move_speed = base_speed

func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	
	if global_position.distance_to(player.global_position) < auto_att_manager.attack_data.prj_range && player.alive:
		target = player
		hub_radius = 0.0
	else:
		target = hub
		hub_radius = float(hub.collision_shape.shape.radius)
		
	#print(auto_att_manager.attack_scene)
	
	nav_agent.set_target_position(target.global_transform.origin)
	
	var target_distance = global_position.distance_to(target.global_position) - hub_radius
	if target_distance < 0:
		target_distance = 0
	
	if target_distance < auto_att_manager.attack_data.prj_range:
		if auto_att_manager.attack_cd_timer.is_stopped():
			auto_att_manager.attack_cd_timer.start()
	else:
		auto_att_manager.attack_cd_timer.stop()
			
	var next_nav_point = nav_agent.get_next_path_position()
	#print(next_nav_point)
	var direction = (next_nav_point - global_transform.origin)
	
	#if direction.length() > 0.01:
	# Calculate the Y rotation angle (yaw)s
	var target_yaw = atan2(direction.x, direction.z)
	
	# Set rotation only on Y axis
	rotation.y = lerp_angle(rotation.y, target_yaw, 0.1)


	velocity = direction.normalized() * stats.move_speed
	
	if auto_att_manager.attack_data.is_range:
		if target == hub:
			if target_distance <= 5:
				velocity = Vector3.ZERO
			
	move_and_slide()
	
func get_target_ref() -> CharacterBody3D:
	return target
	
func get_player_ref() -> Player:
	return player

func set_player_ref(p):
	player = p
	
func set_hub_ref(h):
	hub = h
	
func get_stats():
	return stats
	
func death():
	emit_signal("died")
	queue_free()

func apply_slow(percent: float, duration: float):
	var final_slow = clamp(percent / 100.0, 0, 1)
	stats.move_speed = base_speed * (1.0 - final_slow)
	slow_timer.start(duration)
