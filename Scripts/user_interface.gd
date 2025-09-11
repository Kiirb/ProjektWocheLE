extends Control
class_name HUD

@onready var in_game_menu: Control = $"../InGameMenu"
@export var light_anim:AnimationPlayer
@onready var night_label: Label = $night
@onready var wave_delay: Timer = $wave_delay
@export var day_night_cycle_node: DirectionalLight3D
@onready var hp_bar: TextureProgressBar = $hubHPBar/Progress
@onready var exp_bar: TextureProgressBar = $expBar/ProgressBar2
@export var player: Player
@export var hub: Hub
#@onready var day_week: Label = $showDay/DayWeek
#@onready var day_night: Label = $showDayNight/DayNight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wood_label: Label = $wood/Wood_label
@onready var respawn: Label = $Respawn/Label
@export var spawner: Spawner
@export var structure_spawner: StructureSpawner
@onready var exp_amount: Label = $expBar/ProgressBar2/exp_amount

@onready var player_upgrades: Upgrade = $player_upgrades

@onready var day_night_sprite = $DayAndNight

var inventory: Inventory

var day: int = 1
var week: int = 1
var wave_start_security_check: bool = true

func _ready():
	in_game_menu.visible = false
	inventory = player.get_node("Inventory")
	var skip_button = get_node("skipDay/SkipDayButton")
	if skip_button:
		skip_button.pressed.connect(_on_skip_day_pressed)
	else:
		print("SkipDayButton nicht gefunden")

func _on_skip_day_pressed():
	if !GameState.night:
		print("SkipDayButton gedrückt – rufe skip_day() auf")
		GameState.proceed_time()
		to_night()
		wave_delay.start(5)
	else:
		print("not day")

func _process(delta: float) -> void:
	if !GameState.night:
		if GameState.is_farming():
			animation_player.play("Farming")
		
		
	if GameState.is_game_over():
		animation_player.play("Game over")
		get_tree().paused = true
	if GameState.is_respawn():
		animation_player.play("Respawn")
		respawn.text = "Respawn in: " + str(round(player.respawn.time_left))

	
	#manage exp
	exp_bar.value = player.exp_manager.exp
	exp_bar.max_value = player.exp_manager.ex_required
	exp_amount.text = str(int(player.exp_manager.exp)) + " / " + str(int(player.exp_manager.ex_required))
	
	#manage hub hp
	hp_bar.max_value = hub.stats.max_health
	hp_bar.value = hub.stats.hp 
	
	#manage wood
	wood_label.text = str(inventory.get_ammount(load("res://Assets/resource_files/wood_resource.tres")))

func set_in_game_menu(menu: Control) -> void:
	in_game_menu = menu

func advance_time():
	wave_start_security_check = true
	day += 1
	if day > 7:
		week += 1
		day = 1
#	day_week.text = "Day: " + str(day) + " Week: " + str(week)
	to_day()

func to_night():
	night_label.text = "Night: " + str(day) + " Week: " + str(week)
	GameState.night = true
	day_night_sprite.play("Night")
	
		
	#day_night.text = "night"
	light_anim.play("to_dark")
	animation_player.play("fighting")
	

func to_day():
	GameState.night = false
	#day_night.text = "day"
	day_night_sprite.play("Day")
	night_label.text = "Day: " + str(day) + " Week: " + str(week)
	light_anim.play("to_day")
	animation_player.play("wake up")
	

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/StartMenu.tscn")


func _on_retry_pressed() -> void:
	animation_player.play("RESET")
	get_tree().reload_current_scene()


func _on_wave_delay_timeout() -> void:
	if wave_start_security_check && GameState.night:
		print("the next wave will start now")
		spawner.conf_new_wave()
		wave_start_security_check = false


func _on_button_pressed() -> void:
	get_tree().paused = true
	in_game_menu.visible = true
	if in_game_menu:
		in_game_menu.get_labels()
		var main_game = get_tree().current_scene
		var player = main_game.get_node("Player")
		if player:
			in_game_menu.update_stats(player.stats, player.name)
		else:
			print("Player nicht gefunden!")
	else:
		print("Stats UI Node nicht gefunden!")
		print("Menu offen")
