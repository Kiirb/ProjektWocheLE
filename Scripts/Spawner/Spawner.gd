extends Node3D
class_name Spawner

signal day_cleared(enemies_spawned: int)

@export var min_distance:float 
@export var max_distance: float
@export var user_interface: HUD

#references
@onready var spawn_timer: Timer = $Timer

#Wave data and enemy pools
var current_week: WeekData
var week_nmr: int

var current_day: DaysData
var weeks_total: int
var days_total: int = 0
var day_nmr: int

var enemy_pool: PoolData
var boss_pool: PoolData
var is_boss_alive: bool
var boss_data: EnemyData

var enemies_spawned: int = 0
var total_to_spawn: int = 0
var enemies_alive = 0
var enemies_spawn:bool = false

@export var player_ref: Player = null
var hub_ref: Hub = null
var time_between_spawns: float = 0.0

#debug
var spawned_enemies: Array

var stats_up: int = 0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		for enemy in spawned_enemies:
			Attack.new().do_dmg(player_ref, enemy, 100)
		spawned_enemies.clear()
			

func _ready():
	day_nmr = 0
	week_nmr = 1
	is_boss_alive = false
	current_week = load("res://Resources/Wave/Weeks/Week1.tres")

func conf_new_wave():
	days_total += 1
	#reset
	total_to_spawn = 0
	if week_nmr > 1:
		current_week = load("res://Resources/Wave/Weeks/Weeki.tres")
	day_nmr += 1
	
	if day_nmr > 6:
		current_day = current_week.boss_day
		boss_pool = current_day.boss_pool
		time_between_spawns = current_day.boss_spawn_delay
	else:
		current_day = current_week.days[day_nmr-1]
		time_between_spawns = current_day.normal_enemies_spawn_interval
		
	var is_boss_pool_empty: bool = current_day.boss_pool == null
	var is_normal_pool_empty: bool = current_day.normal_enemies_pool == null

	if is_normal_pool_empty and is_boss_pool_empty:
		push_error("Day doesn't have any pool")
		return
	else:
		total_to_spawn = calc_total_to_spawn()
		
	if not is_normal_pool_empty:
		enemy_pool = current_day.normal_enemies_pool
	if not is_boss_pool_empty:
		boss_pool = current_day.boss_pool
	start_wave()


func weighted_pick(weight_pool: PoolData) -> EnemyData:
	var total_weight = 0
	for entry in weight_pool.pool:
		total_weight += entry.weight
		
	var rand = randf() * total_weight
	
	for entry in weight_pool.pool:
		if rand < entry.weight:
			return entry
		rand -= entry.weight

	return enemy_pool.pool[0]  #fallback

	
func start_wave():
	enemies_spawned = 0 #just to know
	enemies_alive = 0

	spawn_timer.wait_time = time_between_spawns
	spawn_timer.start()
	enemies_spawn = true

#SPAWNS the enemies / bossf
func _on_timer_timeout():
	if enemies_spawned >= total_to_spawn:
		spawn_timer.stop()
		enemies_spawn = false
		return
	
	var enemy_data: EnemyData
	if enemies_spawned < current_day.normal_enemies_amount:
		enemy_data = weighted_pick(enemy_pool)
	else:
		enemy_data = weighted_pick(boss_pool)
	if enemy_data == null || enemy_data.scene == null:
		push_error("Enemy/Enemy Scene is empty")
		return
		
		
	if enemy_data.is_boss && boss_data == null:
		boss_data = enemy_data
		is_boss_alive = true
	
	var enemy: Enemy = enemy_data.scene.instantiate()
	spawned_enemies.append(enemy)
	
	var new_max_hp: float = (
		(enemy.stats.max_health * player_ref.stats.difficulty) + 
		(enemy.stats.max_health * 0.2))
	enemy.stats.max_health = new_max_hp
	
	var new_armor = (
		(enemy.stats.armor * player_ref.stats.difficulty) + 
		(enemy.stats.armor * 0.2))
	enemy.stats.armor = new_armor
	
	enemy.stats.dmg_multiplyer += 0.2
	
	if player_ref == null:
		player_ref = get_node("/root/MainGame/Player")
	enemy.set_player_ref(player_ref)
	
	if hub_ref == null:
		hub_ref = get_node("/root/MainGame/Hub")
	enemy.set_hub_ref(hub_ref)
	
	# Add enemy to scene
	get_parent().add_child(enemy)
	
	# Set spawn position
	var offset = Vector3(
		randf_range(-1.0,1.0),
		0,
		randf_range(-1.0,1.0)		
	).normalized() * randf_range(min_distance, max_distance)
	enemy.global_position = global_position + offset
	
	#Connect the death signal (in enemy when dead)
	enemy.connect("died",Callable(self, "_on_enemy_died").bind(enemy_data))
	
	enemies_spawned += 1
	enemies_alive +=1
	print("Spawned enemy: ", enemies_spawned, "/", total_to_spawn)

func _on_enemy_died(enemy_data : EnemyData):
	player_ref.exp_manager.exp_collected_in_round += enemy_data.exp_on_dead
	print(player_ref.exp_manager.exp_collected_in_round)
	enemies_alive -= 1
	print("Enemy died. Remaining alive:", enemies_alive)
	if enemy_data.is_boss:
		is_boss_alive = false
	#Check after day is over
	if enemies_alive <= 0 && !enemies_spawn:
		#Wave Cleared
		if day_nmr >= 7:
			#Boss defeated
			if week_nmr != 1:
				dificulty_up_week()
			week_nmr += 1
			day_nmr = 0
		
		
		user_interface.advance_time()
		emit_signal("day_cleared",total_to_spawn)
		enemies_spawn = true


func calc_total_to_spawn() -> float:
	var base = current_day.normal_enemies_amount + current_day.boss_enemies_amount
	if week_nmr == 1:
		return base
	var scale = pow(days_total + 1, 0.9) + log(days_total + 2)
	var extra = clamp(scale, 1.0, 3.5)

	var total = round(base * extra)

	return total
		

func dificulty_up_week():
	player_ref.stats.difficulty += 0.1
	
	
#For Bosses that spawns enemies
func spawn_custom_enemies(count: int,minion_pool: PoolData) -> void:
	if minion_pool == null or minion_pool.pool.is_empty():
		push_error("Enemy/Enemy pool is empty")
		return
	for i in range(count):
		var enemy_data: EnemyData = weighted_pick(minion_pool)
		if enemy_data == null or enemy_data.scene == null:
			push_error("Enemy/Enemy Scene is empty")
			continue

		var enemy: Enemy = enemy_data.scene.instantiate()
		spawned_enemies.append(enemy)
		
		# Scale stats
		var new_max_hp: float = (enemy.stats.max_health * player_ref.stats.difficulty) + (enemy.stats.max_health * 0.2)
		enemy.stats.max_health = new_max_hp
		var new_armor = (enemy.stats.armor * player_ref.stats.difficulty) + (enemy.stats.armor * 0.2)
		enemy.stats.armor = new_armor
		enemy.stats.dmg_multiplyer += 0.2
		
		if player_ref == null:
			player_ref = get_node("/root/MainGame/Player")
		enemy.set_player_ref(player_ref)
		
		if hub_ref == null:
			hub_ref = get_node("/root/MainGame/Hub")
		enemy.set_hub_ref(hub_ref)

		get_parent().add_child(enemy)

		# Position near boss
		var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * randf_range(min_distance, max_distance)
		enemy.global_position = self.global_position + offset

		enemy.connect("died", Callable(self, "_on_enemy_died").bind(enemy_data))

		enemies_alive += 1
		print("Boss spawned extra minion")
