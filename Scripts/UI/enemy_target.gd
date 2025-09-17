extends Node3D

@export var offscreen_texture: Texture2D
@export var color: Color = Color.WHITE

@onready var target_reticle: TextureRect = $TargetReticle
@onready var off_screen_reticle: TextureRect = $OffScreenReticle

var camera: Camera3D
var reticle_offset := Vector2(32, 32)    # move the control so the icon is centered better
var border_offset := Vector2(32, 32)     # margin from the viewport edges
var viewport_size := Vector2.ZERO
var viewport_center := Vector2.ZERO
var max_reticle_position := Vector2.ZERO

func _ready() -> void:
	# sanity checks
	if not off_screen_reticle:
		push_error("TargetReticle or OffScreenReticle not found. Check node paths.")
	# apply visuals
	off_screen_reticle.modulate = color
	if offscreen_texture:
		off_screen_reticle.texture = offscreen_texture

	camera = get_viewport().get_camera_3d()
	viewport_size = get_viewport().size
	viewport_center = viewport_size * 0.5
	max_reticle_position = viewport_center - border_offset

func _process(_delta: float) -> void:
	if not camera:
		return

	# convert 3D world position -> 2D screen pos
	var screen_pos: Vector2 = camera.unproject_position(global_position)

	# check visibility / behind-camera
	var behind := camera.is_position_behind(global_position)
	var in_frustum := camera.is_position_in_frustum(global_position)

	if in_frustum and not behind:
		# on-screen
		off_screen_reticle.hide()

		# clamp inside the viewport (so the whole icon remains visible)
		var clamped := screen_pos.clamp(border_offset, viewport_size - border_offset)
	else:
		# off-screen
		off_screen_reticle.show()

		# direction from screen center to projected point
		var dir := screen_pos - viewport_center
		if dir == Vector2.ZERO:
			# avoid division by zero; arbitrary fallback
			dir = Vector2(0, -1)

		# compute scale to hit the viewport rectangle border centered on screen
		var rx :float = 1e9 if abs(dir.x) < 0.0001 else max_reticle_position.x / abs(dir.x)
		var ry :float = 1e9 if abs(dir.y) < 0.0001 else max_reticle_position.y / abs(dir.y)
		var scale :float = min(rx, ry)
		var clamped_dir := dir * scale

		off_screen_reticle.global_position = viewport_center + clamped_dir - reticle_offset

		# rotate the off-screen icon to point toward the enemy
		var angle := Vector2.UP.angle_to(clamped_dir)
		off_screen_reticle.rotation = angle
