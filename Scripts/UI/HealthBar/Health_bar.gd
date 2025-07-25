extends Sprite3D

@onready var view_port: SubViewport =$SubViewport
@onready var panel: Panel =$SubViewport/Panel
@onready var health_bar: ProgressBar = $SubViewport/Panel/ProgressBar
var camera: Camera3D
var base_size: float# The default camera FOV
@onready var body_ref: CharacterBody3D

func _ready() -> void:
	body_ref = get_parent()
	camera = get_viewport().get_camera_3d()
	base_size = camera.size
	
func _physics_process(delta: float) -> void:
	var current_size = camera.size
	var size_ratio = tan(deg_to_rad(current_size) / 2.0) / tan(deg_to_rad(base_size) / 2.0)
	scale = Vector3(1.5,1.5,1.5) * size_ratio
	update_bar()
	
func update_bar():
	health_bar.max_value = body_ref.stats.max_health
	health_bar.value = body_ref.stats.hp
	return
