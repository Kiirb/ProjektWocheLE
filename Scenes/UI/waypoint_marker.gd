extends Sprite2D

@export var on_screen_offset: Vector2 = Vector2(0.5,-5.0)
@export var screen_margin: float= 4.0
@export var smoothing_speed: float = 8.0

var camera_node: Camera3D

func _ready() -> void:
	camera_node = get_viewport().get_camera_3d()
	
func _process(delta: float) -> void:
	if not camera_node:
		camera_node = get_viewport().get_camera_3d()
		return
	var target_global_position: Vector2 = get_parent().global_position
	var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
	var screen_coordinates: Vector2 = (target_global_position - camera_node.global_position) * camera_node.zoom + viewport_dimensions * 0.5
	var screen_inset_rectangle: Vector2 = Rect2(Vector2.ZERO,viewport_dimensions).grow(-screen_margin)
	
	var target_display_position: Vector2
	var target_display_rotation: float
	
	if screen_inset_rectangle.has_point(screen_coordinates):
		target_display_position = target_global_position + on_screen_offset
		target_display_rotation = 0.0
	else: 
		var clamped_x = clamp(screen_coordinates.x,screen_margin,viewport_dimensions)
	
