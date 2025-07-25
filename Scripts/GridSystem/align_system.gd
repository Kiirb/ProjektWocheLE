extends Node3D

const RAY_LENGTH := 1000

#func _ready() -> void:
	#grid_map.instantiate().get_node("GridMap")

func _do_raycast_on_mouse_position(collide_area: bool = false, collision_mask: int = 1):
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = collide_area
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_ray(query)
	return result

func get_mouse_world_position(collide_area: bool = false, collision_mask: int = 1):
	var raycast_result = _do_raycast_on_mouse_position(collide_area, collision_mask)
	if raycast_result:
		return raycast_result.position
	return null

func get_raycast_hit_object(collide_area: bool = false, collision_mask: int = 1):
	var raycast_result = _do_raycast_on_mouse_position(collide_area, collision_mask)
	if raycast_result:
		return raycast_result.collider
	return null
	
func get_cell_world_position(world_pos: Vector3) -> Vector3:
	var cell_size = Vector3(.5, 0 , .5)
	pass

	var cell_coords = Vector3i(
		floor(world_pos.x / cell_size.x),
		floor(world_pos.y / cell_size.y),
		floor(world_pos.z / cell_size.z)
	)

	var local_center = Vector3(
		(cell_coords.x + 0.5) * cell_size.x,
		(cell_coords.y + 0.5) * cell_size.y,
		(cell_coords.z + 0.5) * cell_size.z
	)
	
	return local_center
