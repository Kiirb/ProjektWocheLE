extends Node

var default_cursor: Texture2D
var grab_cursor: Texture2D
var rotate_cursor: Texture2D

func _ready():
	var default_ = load("res://Assets/Cursor/Tiles/tile_0026.png") as Texture2D
	var grab_ = load("res://Assets/Cursor/Tiles/tile_0136.png") as Texture2D
	var rotate_ = load("res://Assets/Cursor/Tiles/tile_0212.png") as Texture2D
	
	var size = 24
	
	default_cursor = resize_texture(default_, Vector2(size, size)) 
	grab_cursor = resize_texture(grab_, Vector2(size, size))
	rotate_cursor = resize_texture(rotate_, Vector2(size, size))
	
	Input.set_custom_mouse_cursor(default_cursor)
	
	
func resize_texture(texture: Texture2D, new_size: Vector2) -> Texture2D:
	var image = texture.get_image()
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	var new_texture = ImageTexture.create_from_image(image)
	return new_texture
	
func _input(event):
	if event is InputEventMouseButton:
		var ev := event as InputEventMouseButton
		if ev.pressed:
			if ev.button_index == MOUSE_BUTTON_MIDDLE:
				Input.set_custom_mouse_cursor(grab_cursor)
			if ev.button_index == MOUSE_BUTTON_RIGHT:
				Input.set_custom_mouse_cursor(rotate_cursor)
		else:
			Input.set_custom_mouse_cursor(default_cursor)
