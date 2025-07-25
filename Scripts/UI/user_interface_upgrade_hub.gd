extends Control
#Name section
@onready var lvl: Label = $Base/name/lvl_bg/lvl

#heal section
@onready var hp_progress_bar: TextureProgressBar = $Base/heal/hp_bg/hp
@onready var hp_value: Label = $Base/heal/hp_bg/hp/hp_value
@onready var label_heal: Label = $Base/heal/heal_button_bg/Label

#hub level section
@onready var hp: Label = $Base/st_fr_lvl/stats/Info/stats/hp
@onready var armor: Label = $Base/st_fr_lvl/stats/Info/stats/armor
@onready var recovery: Label = $Base/st_fr_lvl/stats/Info/stats/recovery
@onready var lvl_hub: Label = $Base/st_fr_lvl/stats/Upgrade/lvl_combat
@onready var button_label_hub: Label = $Base/st_fr_lvl/stats/Upgrade/upgrade_button_combat/button_label

#farm level section
@onready var wood_gain: Label = $Base/st_fr_lvl/farming/Info/stats/Wood
@onready var tree: Label = $Base/st_fr_lvl/farming/Info/stats/tree
@onready var lvl_farming: Label = $Base/st_fr_lvl/farming/Upgrade/lvl_farming
@onready var button_label_farming: Label = $Base/st_fr_lvl/farming/Upgrade/upgrade_button_farming/button_label

@export var main_ui: HUD
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var hp_per_lvl: float = 1
@export var armor_per_lvl: float = 1
@export var recovery_per_lvl: float = 1

@export var wood_spawn_per_lvl: int = 1
@export var wood_gain_per_lvl: int = 1

var open: bool = false
var current_farm_lvl: int = 0
var current_hub_lvl: int = 0
var hub_hp_percent: float = 1

#prices
@export var farm_lvl_price: int = 1
@export var hub_lvl_price: int = 1
@export var full_heal_price: int = 1
@export var price_increace_per_upgrade: int = 1

#entities
var hub: Hub
var player: Player

#resources
var wood = load("res://Assets/resource_files/wood_resource.tres")

func _ready() -> void:
	player = main_ui.player
	hub = main_ui.hub
	reload()

#when hub healed
func _on_heal_button_pressed() -> void:
	if player.inventory.get_ammount(wood) >= full_heal_price:
		player.inventory.add_resources(wood, -full_heal_price)
		hub.stats.hp = hub.stats.max_health
		reload()

#when combat level up
func _on_lvl_combat_button_pressed() -> void:
	if player.inventory.get_ammount(wood) >= hub_lvl_price:
		player.inventory.add_resources(wood, -hub_lvl_price)
		hub_hp_percent = hub.stats.hp / hub.stats.max_health
		hub.stats.max_health += hp_per_lvl
		hub.stats.hp = hub_hp_percent * hub.stats.max_health
		hub.stats.armor += armor_per_lvl
		hub.stats.recovery += recovery_per_lvl
		current_hub_lvl += 1
		hub_lvl_price += price_increace_per_upgrade
		reload()

#when farming level up
func _on_lvl_farming_button_pressed() -> void:
	if player.inventory.get_ammount(wood) >= farm_lvl_price:
		player.inventory.add_resources(wood, -farm_lvl_price)
		main_ui.structure_spawner.spawn_amount += wood_spawn_per_lvl
		main_ui.player.harvest_lvl += 1
		current_farm_lvl += 1
		farm_lvl_price += price_increace_per_upgrade
		reload()

func _input(event: InputEvent) -> void:
	if near_hub():
		if !GameState.night && event.is_action_pressed("interact") && !open:
			get_tree().paused = true
			animation_player.play("open")
			open = true
			reload()
		elif event.is_action_pressed("escape") || event.is_action_pressed("interact") && open:
			get_tree().paused = false
			animation_player.play("close")
			open = false

func near_hub() -> bool:
	var bodies = player.interaction_area.get_overlapping_bodies()
	for body in bodies:
		if body is Hub:
			return true
	return false

func reload():
	lvl.text = "LvL: " + str(current_farm_lvl + current_hub_lvl)
	
	hp_value.text = str(int(hub.stats.hp)) + " / " + str(int(hub.stats.max_health))
	label_heal.text = "Heal: " + str(full_heal_price)
	hp_progress_bar.max_value = hub.stats.max_health 
	hp_progress_bar.value = hub.stats.hp
	
	button_label_farming.text = str(farm_lvl_price)
	wood_gain.text = str(main_ui.player.harvest_lvl)
	tree.text = str(main_ui.structure_spawner.spawn_amount)
	lvl_farming.text = "LvL " + str(current_farm_lvl) +  " -> " + str(current_farm_lvl + 1)
	
	button_label_hub.text = str(hub_lvl_price)
	hp.text = str(int(hub.stats.max_health))
	armor.text = str(hub.stats.armor)
	recovery.text = str(hub.stats.recovery)
	lvl_hub.text = "LvL " + str(current_hub_lvl) +  " -> " + str(current_hub_lvl + 1)
