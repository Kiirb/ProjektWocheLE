extends Control

@export var main_game:PackedScene
  
func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(main_game)


func _on_quit_pressed() -> void:
	get_tree().quit()
	

func _on_settings_pressed() -> void:
	$CenterContainer.visible = false
	$SettingsPanal.visible = true


func _on_back_pressed() -> void:
	$SettingsPanal.visible = false
	$CenterContainer.visible = true


func _on_volume_slider_value_changed(value: float) -> void:
	Soundtrack2.volume_db = linear_to_db(value)


func _on_music_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Soundtrack2.volume_db = -80
		print("MUSIK AUS")
	else:
		Soundtrack2.volume_db = 0
		print("MUSIK AN")
