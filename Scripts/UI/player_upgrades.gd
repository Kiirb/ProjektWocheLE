extends Control
class_name Upgrade

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Labels
@onready var item_name_labels := [
	$Window/Item_picker/Item1/Item_name_1,
	$Window/Item_picker/Item2/Item_name_2,
	$Window/Item_picker/Item3/Item_name_3
]

# Buttons
@onready var item_buttons := [
	$Window/Item_picker/Item1/Button_item_1,
	$Window/Item_picker/Item2/Button_item_2,
	$Window/Item_picker/Item3/Button_item_3
]

# Pictures
@onready var item_pictures := [
	$Window/Item_picker/Item1/Item_frame/item_picture_1,
	$Window/Item_picker/Item2/Item_frame/item_picture_2,
	$Window/Item_picker/Item3/Item_frame/item_picture_3
]

# Item scene paths
var item_scenes: Array[PackedScene] = [
	preload("res://Scenes/Player/LevelUp/Items/arrow.tscn"),
	preload("res://Scenes/Player/LevelUp/Items/attack_speed.tscn"),
	preload("res://Scenes/Player/LevelUp/Items/leben.tscn"),
	preload("res://Scenes/Player/LevelUp/Items/shield.tscn"),
	preload("res://Scenes/Player/LevelUp/Items/SonicShoe.tscn"),
	preload("res://Scenes/Player/LevelUp/Items/strenght.tscn")
]

const STANDARD_ICON_SIZE := Vector2(30, 30)
# Holds the current chosen item instances
var current_items: Array = [null, null, null]

func _ready():
	_connect_buttons()

func _connect_buttons():
	item_buttons[0].pressed.connect(_on_button_item_1_pressed)
	item_buttons[1].pressed.connect(_on_button_item_2_pressed)
	item_buttons[2].pressed.connect(_on_button_item_3_pressed)
	$Window/reroll/NinePatchRect/Button.pressed.connect(_on_button_reroll_pressed)

func _on_button_item_1_pressed() -> void:
	_apply_item(0)

func _on_button_item_2_pressed() -> void:
	_apply_item(1)

func _on_button_item_3_pressed() -> void:
	_apply_item(2)

func _apply_item(index: int) -> void:
	if current_items[index]:
		current_items[index].apply()
		get_tree().paused = false
		animation_player.play("close")  # Plays close animation
		await animation_player.animation_finished
		hide()

func _on_button_reroll_pressed() -> void:
	_pick_items()
	$Window/reroll/NinePatchRect/Button.disabled = true
	$Window/reroll/NinePatchRect/Button.visible = false

func _pick_items():
	var shuffled = item_scenes.duplicate()
	shuffled.shuffle()
	var selected = shuffled.slice(0, 3)

	for i in range(3):
		var item_instance = selected[i].instantiate()
		current_items[i] = item_instance
		item_name_labels[i].text = item_instance.name
		item_pictures[i].texture = item_instance.sprite
		item_pictures[i].custom_minimum_size = STANDARD_ICON_SIZE
		item_pictures[i].stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_pictures[i].expand_mode = TextureRect.EXPAND_IGNORE_SIZE

func open():
	get_tree().paused = true
	$Window/reroll/NinePatchRect/Button.disabled = false
	$Window/reroll/NinePatchRect/Button.visible = true
	_pick_items()
	show()
	animation_player.play("open")
