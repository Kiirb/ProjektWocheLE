extends NinePatchRect
@onready var music_toggle = $VBoxContainer/musicToggle 
@onready var in_game_menu: Control = $".."


func _on_music_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Soundtrack2.volume_db = -80
		print("Musik AUS (ingame)")
	else:
		Soundtrack2.volume_db = 0
		print("Musik AN (ingame)")


func _on_quit_pressed() -> void:
	get_tree().paused = false  #  pausiertes Spiel wieder freigeben
	get_tree().change_scene_to_file("res://Scenes/UI/StartMenu.tscn")

func _on_resume_pressed() -> void:
	get_tree().paused = false
	in_game_menu.visible = false
	print ("menu closed")	


func _on_pause_pressed() -> void:
	pass
