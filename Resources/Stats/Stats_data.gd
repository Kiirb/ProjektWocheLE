extends Resource
class_name StatsData


@export var hp: float
@export var max_health:float				#Determines the maximum amount of HP for the character 
@export var basic_dmg: float
@export var recovery:int 				#Determines how much HP is generated for the character per second (0hp/scnd)
@export var armor:float  					#Determines the amount of reduced incoming damage
@export var dmg_multiplyer:float    	#Increaces the damage done by an attack (base_dmg * dmg_multiplyer)
@export var move_speed: float  			#Modifies the movement speed of the character. 
@export var melee_range: float
@export var area_modifier: float 		#Modifies the area of all attacks (100%-1000%)
@export var speed_modifier: float		#Modifier for bullet speed
@export var auto_cd_modifier: float 		#Modifies the duration of each Auto attack
