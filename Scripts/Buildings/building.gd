extends Node3D

class_name Building

@onready var raycasts: Array[RayCast3D] = [$Ray1, $Ray2, $Ray3, $Ray4]
@onready var mesh: MeshInstance3D = $mesh
@onready var area: Area3D = $Area3D

@onready var green_mat = preload("res://Assets/Buildings/Textures/green_mat.tres")
@onready var red_mat = preload("res://Assets/Buildings/Textures/red_mat.tres")

func check_and_recolor_placement() -> bool:
	for ray in raycasts:
		if !ray.is_colliding():
			placment_red()
			return false
			
	#if area.has_overlapping_areas():
		#for a in area.get_overlapping_areas():
			#if a.get_owner() is not Building:
				#print("area")
				#placment_red()
				#return false
			
	if area.has_overlapping_bodies():
		placment_red()
		return false
	
	placment_green()
	return true	
	
func placed() -> void:
	mesh.material_override = null
	
	var body: StaticBody3D = StaticBody3D.new()
	#body.collision_layer = 1
	var collision: CollisionShape3D = area.get_node("CollisionShape3D").duplicate()

	body.add_child(collision)
	mesh.add_child(body)
	
	for ray in raycasts:
		ray.queue_free()

func placment_red() -> void:
	mesh.material_override = red_mat
		
func placment_green() -> void:
	mesh.material_override = green_mat
