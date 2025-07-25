extends Control

@onready var item_list = $ItemList
@export var test_buildings : Array[PackedScene]

var camera: Camera3D
var instance: Node3D
var placing = false
var range = 1000
var can_place

func _ready() -> void:
	camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	if placing:
		var global_mouse_pos = AlignSystem.get_mouse_world_position()
		if global_mouse_pos:
			if not instance.visible:
				instance.visible = true
			instance.transform.origin = AlignSystem.get_cell_world_position(global_mouse_pos)
			can_place = instance.check_and_recolor_placement()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_rigth"):
		delete_object()
			
	if placing:
		if event.is_action_pressed("mouse_left") && can_place:
			stop_placement()
			instance.placed()
		if event.is_action_pressed("escape"):
			stop_placement()
			instance.queue_free()
		#if event.is_action_pressed("mousewheel_down"):
			#instance.rotation_degrees += Vector3(0, 45, 0)
		#if event.is_action_pressed("mousewheel_up"):
			#instance.rotation_degrees -= Vector3(0, 45, 0)

func delete_object() -> void:
	var object = AlignSystem.get_raycast_hit_object(true)
	if not object:
		return
	
	var owner_node = object.get_owner()
	if not owner:
		return
		
	if owner_node == instance and placing:
		return

	if owner_node.has_method("check_and_recolor_placement"):
		owner_node.queue_free()

func stop_placement():
		placing = false
		can_place = false
		item_list.deselect_all()

func _on_item_list_item_selected(index: int) -> void:
	if placing:
		instance.queue_free()
	if test_buildings[index]:
		instance = test_buildings[index].instantiate()
		instance.visible = false
	placing = true
	add_sibling(instance)
