extends Control  # oder NinePatchRect

var label_day: Label
var label_name: Label
var label_week: Label
var label_level: Label
var label_max_hp: Label
var label_cooldown: Label
var label_basic_dmg: Label
var label_auto_attack: Label
var label_recovery: Label
var label_luck: Label
var label_armor: Label
var label_exp_growth: Label
var label_movement_speed: Label
var label_pick_up_radius: Label
var label_attack_area: Label
var label_area_duration: Label
var label_attack_speed: Label
var label_pjocetile_amount: Label

func _ready():
	pass

func _on_menu_opened():
	get_labels()
	var main_game = get_tree().current_scene.get_node("MainGame")
	var player = main_game.get_node("Player")
	if player:
		update_stats(player.stats, player.name)
	else:
		print("Player nicht gefunden!")

func get_labels():
	label_day = $NinePatchRect/VBoxContainer/GridContainer/Label_Day
	label_name = $NinePatchRect/VBoxContainer/GridContainer/Label_Name
	label_week = $NinePatchRect/VBoxContainer/GridContainer/Label_Week
	label_level = $NinePatchRect/VBoxContainer/GridContainer/Label_Level
	label_max_hp = $NinePatchRect/VBoxContainer/GridContainer2/Label_MaxHP
	label_cooldown = $NinePatchRect/VBoxContainer/GridContainer2/Label_Cooldown
	label_basic_dmg = $NinePatchRect/VBoxContainer/GridContainer2/Label_BasicDMG
	label_auto_attack = $NinePatchRect/VBoxContainer/GridContainer2/Label_AutoAttack
	label_recovery = $NinePatchRect/VBoxContainer/GridContainer2/Label_Recovery
	label_luck = $NinePatchRect/VBoxContainer/GridContainer2/Label_Luck
	label_armor = $NinePatchRect/VBoxContainer/GridContainer2/Label_Armor
	label_exp_growth = $NinePatchRect/VBoxContainer/GridContainer2/Label_EXPGrowth
	label_movement_speed = $NinePatchRect/VBoxContainer/GridContainer2/Label_MovementSpeed
	label_pick_up_radius = $NinePatchRect/VBoxContainer/GridContainer2/Label_pickUpRadius
	label_attack_area = $NinePatchRect/VBoxContainer/GridContainer2/Label_AttackArea
	label_area_duration = $NinePatchRect/VBoxContainer/GridContainer2/Label_AreaDuration
	label_attack_speed = $NinePatchRect/VBoxContainer/GridContainer2/Label_AttackSpeed
	label_pjocetile_amount = $NinePatchRect/VBoxContainer/GridContainer2/Label_PjocetileAmount

func update_stats(stats: PlayerStatsData, player_name: String) -> void:
	#if label_day: label_day.text = "Tag: " + str(stats.day)
	#if label_name: label_name.text = "Name: " + player_name
	#if label_week: label_week.text = "Woche: " + str(stats.week)
	if label_level: label_level.text = "Level: " + str(stats.lvl)
	if label_max_hp: label_max_hp.text = "HP: " + str(stats.hp) + " / " + str(stats.max_health)
	if label_cooldown: label_cooldown.text = "Cooldown: " + str(stats.cooldown)
	if label_basic_dmg: label_basic_dmg.text = "Basic Dmg: " + str(stats.dmg_multiplyer)
	#if label_auto_attack: label_auto_attack.text = "Auto Attack Speed: " + str(stats.attack_speed)
	if label_recovery: label_recovery.text = "Recovery: " + str(stats.recovery)
	if label_luck: label_luck.text = "Luck: " + str(stats.luck)
	if label_armor: label_armor.text = "Armor: " + str(stats.armor)
	if label_exp_growth: label_exp_growth.text = "EXP Growth: " + str(stats.exp_groth)
	if label_movement_speed: label_movement_speed.text = "Move Speed: " + str(stats.move_speed)
	if label_pick_up_radius: label_pick_up_radius.text = "Pick-Up Radius: " + str(stats.pickup_radius)
	if label_attack_area: label_attack_area.text = "Attack Area: " + str(stats.area_modifier)
	if label_area_duration: label_area_duration.text = "Area Duration: " + str(stats.duration)
	if label_attack_speed: label_attack_speed.text = "Projectile Speed Multiplier: " + str(stats.speed_modifier)
	if label_pjocetile_amount: label_pjocetile_amount.text = "Projectile Amount: " + str(stats.proj_amout)
