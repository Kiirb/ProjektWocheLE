extends Node3D
class_name Camera

@onready var camera_anchor = $CameraAnchor
@onready var camera_node = $CameraAnchor/Camera3D

var player_ref: Player
var target_position: Vector3
var offset: Vector3 = Vector3.ZERO
# Reference to player input direction (to be updated externally)
var player_input_dir: Vector3 = Vector3.ZERO	

var lerp_speed:float = 5.0
#The speed at which offset returns to zero when player stops moving
var offset_return_speed: float = 2.0	
#how far camera shifts from player movement direction	
var max_offset_distance: float = 1.5	


@export var zoom_intensity = 2

@export var max_zoom_in = 8

@export var max_zoom_out = 70


#Dragging and rotating
@export var drag_speed: float = 0.02
@export var screen_ratio: float
var dragging: bool = false
var rotating: bool = false
var right_vector: Vector3
var forward_vector: Vector3
var initial_position: Vector3
var initial_rotation: Vector3


func _ready() -> void:
	initial_rotation = camera_anchor.rotation_degrees
	camera_anchor.rotation_degrees = initial_rotation
	
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	screen_ratio = screen_size.y / screen_size.x
	get_move_vectors()
#
func conf_camera():
	target_position = player_ref.global_position + offset
	initial_position = global_position
	#initial_rotation = rotation_degrees
	
func _physics_process(delta: float) -> void:
	if player_ref and not dragging:
		update_offset(delta)
		target_position = player_ref.global_position + offset
		global_position = global_position.lerp(target_position,lerp_speed*delta)


func update_offset(delta):
#If player is moving -> offset moves toward that directionscaled by max_offset_distance
	if player_input_dir.length() > 0.1:
		var desired_offset = -player_input_dir.normalized() * max_offset_distance
		offset = offset.lerp(desired_offset, lerp_speed * delta)
	else:
		#Player stopped -> smoothly return offset to zero
		offset = offset.lerp(Vector3.ZERO, offset_return_speed * delta)
		
func get_move_vectors():
	right_vector = camera_node.global_transform.basis.x
	forward_vector = -camera_node.global_transform.basis.z
	forward_vector.y = 0
	forward_vector = forward_vector.normalized()
	
func reset_camera():
	global_position = player_ref.global_position
	rotation_degrees = initial_rotation
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var ev := event as InputEventMouseButton
		
		#to ZOOM-IN or ZOOM-OUT
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP and camera_node.size - zoom_intensity > max_zoom_in:
				camera_node.size -= zoom_intensity
		if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN and camera_node.size + zoom_intensity < max_zoom_out:
				camera_node.size += zoom_intensity
			
		#To ROTATE or to DRAG
		if ev.button_index == MOUSE_BUTTON_RIGHT:
			rotating = ev.pressed
		if ev.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = ev.pressed
	elif event is InputEventMouseMotion:
		var m := event as InputEventMouseMotion
		
		#always rotate camera horizontally (Z)
		if rotating:
			camera_anchor.rotate_y(-m.relative.x * 0.5 * drag_speed)
			get_move_vectors()
			# Keep pitch fixed
			camera_anchor.rotation_degrees.z = 0
		
		#only pan if dragging and allowed
		if dragging:
			get_move_vectors()
			var x = -m.relative.x
			var y = m.relative.y
			global_position += (
				right_vector * x * drag_speed +
				forward_vector * y * drag_speed / screen_ratio
			)
			
