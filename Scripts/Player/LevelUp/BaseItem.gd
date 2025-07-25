extends Node
class_name Item

@export var sprite: Texture 
@export var item_name: String = ""
@export var disc: String = ""
static var player: Player
@export var icrease_ammount: float = 1

func _ready() -> void:
	player = $"../Player"

func apply():
	pass
