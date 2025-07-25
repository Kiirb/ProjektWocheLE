extends Resource
class_name AttackPoolData

@export var auto_attack: AttackData
@export var pool: Array[AttackData]



#var active_power_ups = {
	#"drain": {
		##"scene" : preload()
		#"name" : "Energy Drain",
		#"basic_damage" : 2.0,
		#"cool_down" : 1.0, #scnds
		#"basic_range" : 10.0,
		#"target": Enemy,
		#"amount": 1
	#},
	#"magic_projectile": {
			##"scene" : preload()	
		#"name" : "Fire Ball",
		#"basic_damage" : 10,
		#"cool_down" : 2.5, #scnds
		#"basic_range" : 50.0,
		#"target": Enemy,
		#"amount":1
	#},
	#"sword_melee": {
		##"scene" : preload()
		#"name" : "Magic Sword",
		#"basic_damage" : 8,
		#"cool_down" : 2.5, #scnds
		#"basic_range" : 50.0,
		#"target": Enemy,
		#"amount" : 1
	#}
#};
