class_name Attack
extends Node3D

#porwerups (modular)
func do_effect():
	pass

func do_dmg(from: CharacterBody3D, to: CharacterBody3D, raw_dmg: float):
	var from_is_valid: bool = from is Player || from is Enemy
	var to_is_valid: bool = to is Player || to is Enemy #|| to is Hub
	var player_to_hub: bool = from is Player && to is Hub || from is Hub && to is Player
	#var stats_valid: bool = to.stats != null
	
	if  to_is_valid && from_is_valid && !player_to_hub:
		var dmg_done = calc_dmg(to,raw_dmg)
		to.stats.hp = max(to.stats.hp - dmg_done, 0) #ensure no less than 0
		print("DMG Done: %s | Remaining HP: %s" % [dmg_done, to.stats.hp])
		if to.stats.hp <= 0:
			to.death()
		
func calc_dmg(to: CharacterBody3D, raw_dmg: float) -> float:
	var dmg: float = raw_dmg * (100/(100 + to.stats.armor))
	return dmg
