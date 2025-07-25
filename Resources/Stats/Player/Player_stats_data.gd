extends StatsData
class_name PlayerStatsData

@export var lvl: int
@export var exp: float
@export var exp_required: float

@export var respawn_cd: float

@export var cooldown: float 			#Modifies the duration of the CD between attackts (base 1)
@export var luck: float 				#modifies the chances of extra exp / resources
@export var exp_groth: float 			#Modifies the amount of exp gained from collecting 
@export var pickup_radius: int			#Determines the radius inside wich exp orbs are collected (30 - ..)
@export var duration: float 			#Modifies the duration of area effects (100%-500%)
@export var proj_amout: int 			#Modifies the amount of extra projectiles a weapon can have (0-10)
@export var difficulty: float = 1
