extends Node

enum status {FIGHTING, FARMING, RESPAWN, GAMEOVER}
static var current_state: status
static var night: bool = false
static  var temp_state_save: status

#sets the state to the standart value on day 1
func _ready() -> void:
	current_state = status.FARMING

#checks if you want to switch the curren mode
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_state") and night:
		print("cannot switch, cause its night")


#proceeds from day to night and the other way arround
func proceed_time():
	night = !night
	if night == true:
		current_state = status.FIGHTING
	else :
		current_state = status.FARMING

func is_farming() -> bool:
	if current_state == status.FARMING:
		return true
	else:
		return false

func is_fighting() -> bool:
	if current_state == status.FIGHTING:
		return true
	else:
		return false


func is_respawn() -> bool:
	if current_state == status.RESPAWN:
		return true
	else:
		return false

func is_game_over() -> bool:
	if current_state == status.GAMEOVER:
		return true
	else:
		return false

func respawn_begin():
	temp_state_save = current_state
	current_state = status.RESPAWN

func respawn_end():
	current_state = temp_state_save

func die():
	current_state = status.GAMEOVER
