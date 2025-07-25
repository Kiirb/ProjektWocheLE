extends Node3D

@onready var sky_anim = $WorldEnvironment/sky_animation_player
@onready var light_anim = $DirectionalLight3D/light_animation_player
@onready var night_timer = $night_timer

var is_day := true

func _ready():
	_set_to_day_end_state()
	night_timer.connect("timeout", Callable(self, "_on_night_ended"))

func skip_day():
	if is_day:
		_to_night()
	else:
		print("Du kannst die Nacht nicht skippen")

func _set_to_day_end_state():
	sky_anim.play("ToDay")
	sky_anim.seek(sky_anim.current_animation_length, true)
	light_anim.play("ToDay")
	light_anim.seek(light_anim.current_animation_length, true)
	is_day = true
	print("Starte im Tageszustand (Ende von ToDay)")

func _to_night():
	is_day = false
	print("Wechsle zu Nacht")
	sky_anim.play("ToNight")
	light_anim.play("ToNight")
	night_timer.start()  

func _to_day():
	is_day = true
	print("Wechsle zu Tag")
	sky_anim.play("ToDay")
	light_anim.play("ToDay")
	night_timer.stop()

func _on_night_ended():
	print("nacht vorbei, tag beginnt")
	_to_day()
