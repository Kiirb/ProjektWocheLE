extends Attack
class_name AutoAttackManager

#change to resource aswell
@export var attack_pool: AttackPoolData
@export var melee_angle_treshhold: float = 0.0

var attack_data

var camera
var body_ref: CharacterBody3D
var attack_scene: PackedScene
var attack_dmg: float
var cd: float
var speed: float
var target_ref: CharacterBody3D
var spawn_height = 1.5

@onready var attack_cd_timer := $Timer
@onready var melee_area: Area3D = $MeleeRangeArea
@onready var ray := RayCast3D.new()

func _ready():
	ray.enabled = true
	add_child(ray)
	body_ref = get_parent()
	attack_data = attack_pool.auto_attack
	attack_cd_timer.connect("timeout",Callable(self,"_on_attack_cd_timeout"))
	
	if melee_area:
		set_melee_area_monitoring(true)

func do_effect():
	if not is_instance_valid(target_ref):
		return

	for effect in attack_data.effects:
		effect.do_effect(target_ref, body_ref)


func conf_auto_attack():
	if body_ref is Player:
		camera = get_viewport().get_camera_3d()
	
	attack_dmg = attack_data.basic_dmg * body_ref.stats.dmg_multiplyer
	
	if attack_data.scene != null:
		attack_scene = attack_data.scene
	
	cd = attack_data.cool_down / body_ref.stats.auto_cd_modifier
	speed = attack_data.prj_speed * body_ref.stats.speed_modifier
	attack_cd_timer.wait_time = cd
	
	if melee_area and melee_area.has_method("init"):
		melee_area.init(body_ref)
	if melee_area and not melee_area.hit_target.is_connected(Callable(self,"_on_projectile_hit")):
		melee_area.hit_target.connect(Callable(self,"_on_projectile_hit"))
	
	set_melee_area_monitoring(true)

func request_attack():
	if not attack_cd_timer.is_stopped():
		var bod_typ = "Player" if body_ref is Player else "Enemy" 
		return 
	attack_cd_timer.start()
	_on_attack_cd_timeout()
#
func _on_attack_cd_timeout():
	if body_ref is Player:
		if body_ref.shoot_held and attack_data.is_range:
			body_ref.attack()
			perform_range_attack()
		elif body_ref.shoot_held and not attack_data.is_range:
			body_ref.attack()
			perform_melee_attack()
	else:
		if attack_data.is_range:
			body_ref.attack()
			perform_range_attack()
		else:
			body_ref.attack()
			perform_melee_attack()
			
func perform_range_attack():
	if body_ref is Enemy:
		body_ref.stats.move_speed = 0
	if not attack_scene:
		push_error("No attack Scene")
		return
		
	var direction: Vector3
	if body_ref is Player:
		if not camera:
			push_error("No Camera in Player")
			return

		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_dir = camera.project_ray_normal(mouse_pos)	
		#Horizontal Plane -> y=0
		var plane = Plane(Vector3.UP, 0)
		var target_pos = plane.intersects_ray(ray_origin,ray_dir)

		if not target_pos:
			return
	
		direction = (target_pos - body_ref.global_position).normalized()
	else:
		if body_ref.has_method("get_target_ref"):
			var target = body_ref.get_target_ref()
			if target:
				ray.look_at(target.global_position, Vector3.UP)
				ray.target_position = Vector3(0, 1.5, -80)  # Local space forward
				if ray.is_colliding():
					var collider = ray.get_collider()
					if collider is not Player and collider is not Enemy and collider is not Hub:
						return
				direction = (target.global_position - body_ref.global_position).normalized()
			else:
				print("target no found")
		else:
			return
	direction.y = 0
	direction = direction.normalized()
	
	var att = attack_scene.instantiate()
	att.body_ref = body_ref
	att.speed = speed
	
	
	body_ref.get_tree().current_scene.add_child(att)
	att.global_position = body_ref.global_position + Vector3(0,spawn_height,0) + direction * 1.5
	att.look_at(body_ref.global_position + direction, Vector3.UP)
	att.manager = self
	att.direction = direction
	att.connect("hit_target",Callable(self,"_on_projectile_hit"))
	if body_ref is Enemy:
		await get_tree().create_timer(cd).timeout
		body_ref.stats.move_speed = body_ref.base_speed

func perform_melee_attack():
	if not melee_area:
		push_error("No Melee Area")
		return
	for body in melee_area.get_overlapping_bodies():
		if body == body_ref:
			continue
		var valid_target = false
		if body_ref is Player and body is Enemy:
			valid_target = true
		elif body_ref is Enemy and body is Player:
			valid_target = true
		if valid_target:
			var attack_forward = body_ref.transform.basis.z.normalized()
			var to_target = (body.global_transform.origin - body_ref.global_transform.origin).normalized()
			var dot = attack_forward.dot(to_target)
			if dot >= melee_angle_treshhold:
				do_dmg(body_ref,body,attack_dmg)
				if body.has_node("HealthBar"):
					body.get_node("HealthBar").update_bar()

func _on_projectile_hit(body: Node3D) -> void:
	if body is StaticBody3D:
		return
	if not body or not is_instance_valid(body):
		return
	if body is not CharacterBody3D:
		return
	do_dmg(body_ref, body, attack_dmg)
	if body and body.has_node("HealthBar"):
		body.get_node("HealthBar").update_bar()
	if body_ref.has_method("do_effect_dmg"):
		body_ref.do_effect_dmg()

func _set_melee_area_monitoring(enabled: bool):
	if melee_area:
		melee_area.set_deferred("monitoring", enabled)

func set_melee_area_size(melee_area: Area3D):
	if not body_ref or not body_ref.has_method("get_stats"):
		return
	var stats = body_ref.get_stats()
	var shape_collision = melee_area.get_node_or_null("hitbox")
	
	if shape_collision and shape_collision.shape is SphereShape3D:
		shape_collision.shape.radius = stats.melee_range
		
func _on_melee_cd_timeout():
	if not melee_area:
		return

	for body in melee_area.get_overlapping_bodies():
		if body == body_ref:
			continue

		var valid_target = false
		if body_ref is Player and body is Enemy:
			valid_target = true
		elif body_ref is Enemy and body is Player:
			valid_target = true

		if valid_target:
			var attacker_forward = body_ref.transform.basis.z.normalized()
			var to_target = (body.global_transform.origin - body_ref.global_transform.origin).normalized()
			var dot = attacker_forward.dot(to_target)

			if dot >= melee_angle_treshhold:
				do_dmg(body_ref, body, attack_dmg)
				if body.has_node("HealthBar"):
					body.get_node("HealthBar").update_bar()

func set_melee_area_monitoring(enabled: bool):
	if melee_area:
		melee_area.set_deferred("monitoring", enabled)
