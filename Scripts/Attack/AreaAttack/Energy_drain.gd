extends Attack
class_name Energy_drain


@onready var area:Area3D = $Area3D

@onready var attack_data = load("res://Config/Attacks/Attack_data.gd").active_power_ups.get("drain")
var att_name = attack_data.get("name")
var cd = attack_data.get("cool_down")
var target = attack_data.get("target")
var range = attack_data.get("amount")

func do_attack(from : CharacterBody3D):
	pass
	
