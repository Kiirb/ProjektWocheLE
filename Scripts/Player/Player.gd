extends CharacterBody3D
class_name Player

@onready var mage_mesh: Node3D = $Mage_mesh
var animation_player: AnimationPlayer 

@onready var camera_scene: Camera = get_parent().get_node("Camera")
@onready var camera_anchor = camera_scene.get_node("CameraAnchor")

@onready var interaction_area: Area3D = $Interaction_area
@onready var interaction_collision: CollisionShape3D = $Interaction_area/CollisionShape3D
@export var interaction_area_size: float = 1.5
@onready var inventory: Inventory = $Inventory
@export var ui: HUD
@export var stats: PlayerStatsData
@export var spawn_point: SpawnPoint
@export var spawner_ref: Spawner
var attacks: Array[Attack] = []
@onready var att: Timer = $att

@onready var auto_att_manager: AutoAttackManager = $AutoAttackManager
@onready var melee:= $AutoAttackManager/MeleeRangeArea
@onready var exp_manager: ExpManager  = $ExpManager

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var respawn: Timer = $respawn
var health_bar: Sprite3D

var base_speed: float = 100.0
var slow_timer: Timer



var shoot_held: bool = false
var harvest_lvl: int = 1
var alive: bool = true
var blue_mat = preload("res://assets/Textures/blue_mat.tres")
var is_attacking: bool = false

func _ready():
	animation_player = mage_mesh.get_node("AnimationPlayer")
	interaction_collision.shape.radius = interaction_area_size;
	auto_att_manager.conf_auto_attack()
	health_bar = $HealthBar
	health_bar.update_bar()
	camera_scene.player_ref = self
	camera_scene.conf_camera()
	melee.monitoring = false
	melee.monitorable = false
	
	collision_layer = 1 #Player layer
	collision_mask = 3 #Detect enemies
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	base_speed = stats.move_speed
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	slow_timer.connect("timeout", self._on_slow_timeout)
	add_child(slow_timer)

func _on_slow_timeout():
	stats.move_speed = base_speed
# Handles the panning / normal Camera Mode
func _input(_event : InputEvent):
	if _event.is_action_pressed("interact") && !GameState.night:
		harvets_structures()
	if Input.is_action_just_pressed("reset_camera"): 
		reset_camera()
	if _event.is_action_pressed("shoot") && !GameState.is_respawn() && GameState.is_fighting():
		shoot_held = true
	if _event.is_action_released("shoot") && !GameState.is_respawn() && GameState.is_fighting():
		shoot_held = false

func attack():
	is_attacking = true
	animation_player.play("2H_Ranged_Shoot")
	att.start(1)

func apply_slow(percent: float, duration: float):
	var final_slow = clamp(percent / 100.0, 0, 1)
	stats.move_speed = base_speed * (1.0 - final_slow)
	slow_timer.start(duration)

func reset_camera():
	camera_scene.global_position = global_position
	camera_scene.rotation_degrees = Vector3.ZERO

func _deferred_attack():
	auto_att_manager.request_attack()

func death():
	if stats.hp <= 0 and alive:
		collision_shape.disabled = true
		alive = false
		GameState.respawn_begin()
		ghost_texture_override(blue_mat)
		respawn.start(stats.respawn_cd)

func ghost_texture_override(material):
	var meshes: Array[MeshInstance3D] = get_all_mesh_materials(mage_mesh)
	for mesh in meshes:
		mesh.material_override = material
	
func get_all_mesh_materials(node: Node) -> Array[MeshInstance3D]:
	var materials: Array[MeshInstance3D] = []
	
	if node is MeshInstance3D:
		materials.append(node)

	for child in node.get_children():
		materials += get_all_mesh_materials(child)

	return materials

func  harvets_structures():
	if interaction_area.has_overlapping_areas():
		var overlapping_areas = interaction_area.get_overlapping_areas()
		for area in overlapping_areas:
			if area.get_owner() is Structures:
				var resource_type: Resource = area.get_owner().harvest()
				inventory.add_resources(resource_type, harvest_lvl)
				break

# Movement
func _physics_process(delta) -> void:
	var input_dir = Vector3.ZERO
		
	# AUTO ATTACK CHECK (Cooldown + Target) NO INPUT NEEDED 
	#if not auto_att_manager.attack_data.is_range:
		#auto_att_manager.request_attack()

	# FOR PLAYER SHOOTING
	if shoot_held and auto_att_manager.attack_data.is_range:
		auto_att_manager.request_attack()
	if Input.is_action_pressed("move_forward",false):
		input_dir.z -= 1
		if!is_attacking: animation_player.play("Walking_Backwards")
		
	if Input.is_action_pressed("move_back",false):
		input_dir.z +=1
		if!is_attacking: animation_player.play("Walking_A")

	if Input.is_action_pressed("move_left",false):
		input_dir.x -= 1
		if!is_attacking: animation_player.play("Walking_A")

	if Input.is_action_pressed("move_right",false):
		input_dir.x += 1
		if!is_attacking: animation_player.play("Walking_A")
	if velocity == Vector3.ZERO:
		if!is_attacking: animation_player.play("Idle")
		
		
	var target_pos = AlignSystem.get_mouse_world_position()
	if target_pos:
		target_pos.y = global_position.y
		print(target_pos)
		look_at(target_pos, Vector3.UP)
	
	input_dir = input_dir.normalized()

	var camera_basis = camera_anchor.global_transform.basis

	var cam_forward = -camera_basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	var cam_right = camera_basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()

	var move_dir = (cam_forward * -input_dir.z) + (cam_right * input_dir.x)
	velocity = move_dir * stats.move_speed

	#For the camera larping
	if camera_scene != null:
		camera_scene.player_input_dir = move_dir.normalized()

	move_and_slide()
	
func get_stats():
	return stats
	

func _on_respawn_timeout() -> void:
	if not spawn_point:
		push_error("No Spawnpoint assigned")
	collision_shape.disabled = false
	var user_interface: HUD = $"../UserInterface"
	user_interface.animation_player.play("Farming")
	global_position = spawn_point.global_position
	ghost_texture_override(null)
	alive = true
	stats.hp = stats.max_health
	health_bar.update_bar()
	GameState.respawn_end()


func _on_att_timeout() -> void:
	is_attacking = false
