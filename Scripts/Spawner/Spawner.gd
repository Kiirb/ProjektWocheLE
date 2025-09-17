extends Node3D
class_name Spawner

#signal day_cleared(enemies_spawned: int)

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
@export var boss_pool: PoolData = null
var boss_i: int = 0
var is_boss_alive: bool = false
var boss_spawned:bool = false

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
	if Input.is_action_just_pressed("debug_kill_all"):
		for enemy in spawned_enemies:
			if is_instance_valid(enemy):
				Attack.new().do_dmg(player_ref, enemy, 999999) # big enough to kill anything
		spawned_enemies.clear()

func _ready():
	day_nmr = 0
	week_nmr = 1
	is_boss_alive = false
	boss_spawned = false
	current_week = load("res://Resources/Wave/Weeks/Week1.tres")

func conf_new_wave():
	days_total += 1
	day_nmr += 1
	
	#reset flags
	boss_spawned = false
	is_boss_alive = false
	
	#reset counts
	total_to_spawn = 0
	enemies_spawned = 0
	enemies_alive = 0
	spawned_enemies.clear()
	
	#load weeks
	if week_nmr > 1 and week_nmr < 7:
		current_week = load("res://Resources/Wave/Weeks/Week"+ str(week_nmr) +".tres")
	elif weeks_total > 6:
		current_week = load("res://Resources/Wave/Weeks/Weeki.tres")
		#current_day = current_week.days.get(0)
	
	if current_week == null:
		push_error("week is empty")
		return
		
	var days_in_week := current_week.days.size() if current_week.days != null else 0
	#if current_week != null and current_week.days != null:
		#days_in_week = current_week.size()
	
	if day_nmr <= days_in_week:
		#normal Day, uses dayData
		current_day = current_week.days[day_nmr-1]
		if current_day == null:
			push_error("current day is null, nmr " + str(day_nmr-1))
			return
		
		enemy_pool = current_day.normal_enemies_pool
		if enemy_pool == null:
			push_error("enemy pool is empty for day" + str(day_nmr-1))
			return
		
		time_between_spawns = current_day.normal_enemies_spawn_interval
		total_to_spawn = calc_total_to_spawn()
		start_wave()
	else:
		if boss_pool == null:
			push_error("boss pool is null bro... cant spawn boss")
			return
		print("Boss DAY!! it will spawn after all enemies are dead")
		#if week_nmr != 1:
			#dificulty_up_week()
			#week_nmr += 1
			#day_nmr = 0
		
	#else:
		#current_day = current_week.days[day_nmr-1]
		#time_between_spawns = current_day.normal_enemies_spawn_interval
		#
	#
	##var is_boss_pool_empty: bool = current_day.boss_pool == null
	#var is_normal_pool_empty: bool = current_day.normal_enemies_pool == null
#
	#if is_normal_pool_empty and boss_pool == null:
		#push_error("Day doesn't have any pool")
		#return
	#
	#if not is_norm
		#
	#if not is_normal_pool_empty:
		#enemy_pool = current_day.normal_enemies_pool
		#
	#is_boss_alive = false
	#boss_spawned = false
	#start_wave()


func weighted_pick(weight_pool: PoolData) -> EnemyData:
	if weight_pool == null or weight_pool.pool.is_empty():
		return null
	var total_weight := 0.0
	for enemy in weight_pool.pool:
		total_weight += enemy.weight
	var r = randf() * total_weight
	for enemy in weight_pool.pool:
		if r < enemy.weight:
			return enemy
		r -= enemy.weight
	print("fallback enemy spawned")
	return weight_pool.pool[0]
	#var total_weight = 0
	#for entry in weight_pool.pool:
		#total_weight += entry.weight
		#
	#var rand = randf() * total_weight
	#
	#for entry in weight_pool.pool:
		#if rand < entry.weight:
			#return entry
		#rand -= entry.weight
#
	#return enemy_pool.pool[0]  #fallback

	
func start_wave():
	enemies_spawned = 0 #just to know
	enemies_alive = 0

	spawn_timer.wait_time = time_between_spawns
	spawn_timer.start()
	enemies_spawn = true
	

func scale_enemy_stats(enemy: Enemy) -> void:
	if player_ref == null:
		player_ref = get_node_or_null("/root/MainGame/Player")
	if player_ref == null:
		return
	enemy.stats.max_health = (enemy.stats.max_health * player_ref.stats.difficulty) + (enemy.stats.max_health * 0.2)
	enemy.stats.armor = (enemy.stats.armor * player_ref.stats.difficulty) + (enemy.stats.armor * 0.2)
	enemy.stats.dmg_multiplyer += 0.2


func spawn_enemy(enemyData: EnemyData):
	if player_ref == null:
		player_ref = get_node("/root/MainGame/Player")
	if hub_ref == null:
		hub_ref = get_node("/root/MainGame/Hub")
	
	if enemyData == null or enemyData.scene == null:
		push_error("Spawn_enemy called with no enemy data")
		return
	
	var enemy: Enemy = enemyData.scene.instantiate()
	enemy.set_player_ref(player_ref)
	enemy.set_hub_ref(hub_ref)
	
	scale_enemy_stats(enemy)

	get_parent().add_child(enemy)
	spawned_enemies.append(enemy)
	# spawn Position
	var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * randf_range(min_distance, max_distance)
	enemy.global_position = global_position + offset
	enemy.global_position.y = 10

	enemy.connect("died", Callable(self, "_on_enemy_died").bind(enemyData))

	enemies_alive += 1
	if not enemyData.is_boss:
		enemies_spawned += 1
	#if enemies_spawned >= total_to_spawn and enemies_spawn:
		#if spawn_timer.is_stopped() == false:
			#spawn_timer.stop()
		#enemies_spawn = false
	
	
#SPAWNS the enemies / bossf
func _on_timer_timeout():
	#guard if not enemy pool then stop
	if enemy_pool == null:
		spawn_timer.stop()
		enemies_spawn = false
		return
	
	if enemies_spawned >= total_to_spawn:
		spawn_timer.stop()
		enemies_spawn = false
		return
	
	var enemy_data: EnemyData = weighted_pick(enemy_pool)
	if enemy_data == null or enemy_data.scene == null:
		push_error("Enemy scene is Empty")
		return
	spawn_enemy(enemy_data)
	#var enemy_data: EnemyData
	#if enemies_spawned < current_day.normal_enemies_amount:
		#enemy_data = weighted_pick(enemy_pool)
	#else:
		#enemy_data = weighted_pick(boss_pool)
	#if enemy_data == null || enemy_data.scene == null:
		#push_error("Enemy/Enemy Scene is empty")
		#return
		#
		#
	#if enemy_data.is_boss && boss_data == null:
		#boss_data = enemy_data
		#is_boss_alive = true
	#
	#var enemy: Enemy = enemy_data.scene.instantiate()
	#spawned_enemies.append(enemy)
	#
	#var new_max_hp: float = (
		#(enemy.stats.max_health * player_ref.stats.difficulty) + 
		#(enemy.stats.max_health * 0.2))
	#enemy.stats.max_health = new_max_hp
	#
	#var new_armor = (
		#(enemy.stats.armor * player_ref.stats.difficulty) + 
		#(enemy.stats.armor * 0.2))
	#enemy.stats.armor = new_armor
	#
	#enemy.stats.dmg_multiplyer += 0.2
	#
	#if player_ref == null:
		#player_ref = get_node("/root/MainGame/Player")
	#enemy.set_player_ref(player_ref)
	#
	#if hub_ref == null:
		#hub_ref = get_node("/root/MainGame/Hub")
	#enemy.set_hub_ref(hub_ref)
	#
	## Add enemy to scene
	#get_parent().add_child(enemy)
	#
	## Set spawn position
	#var offset = Vector3(
		#randf_range(-1.0,1.0),
		#0,
		#randf_range(-1.0,1.0)		
	#).normalized() * randf_range(min_distance, max_distance)
	#enemy.global_position = global_position + offset
	#
	##Connect the death signal (in enemy when dead)
	#enemy.connect("died",Callable(self, "_on_enemy_died").bind(enemy_data))
	#
	#enemies_spawned += 1
	#enemies_alive +=1
	#print("Spawned enemy: ", enemies_spawned, "/", total_to_spawn)
	#
func spawn_boss() -> void:
	if boss_pool == null or boss_pool.pool.is_empty():
		push_error("no boss pool")
		print("aaaaaaaaaaaaaaaa")
		player_ref.exp_manager._on_day_cleared(enemies_spawned)
		user_interface.advance_time()
		return
	if boss_i >= boss_pool.pool.size():
		boss_i = 0
	var boss_data_to_spawn: EnemyData = boss_pool.pool[boss_i]
	boss_i += 1
	
	if boss_data_to_spawn == null or boss_data_to_spawn.scene == null:
		push_error("Boss data or scene not found")
		print("aaaaaaaaaaaaaaaa")
		player_ref.exp_manager._on_day_cleared(enemies_spawned)
		user_interface.advance_time()
		return
	boss_spawned = true
	is_boss_alive = true
	print("Enemy spawned")
	spawn_enemy(boss_data_to_spawn)

func _on_enemy_died(enemy_data : EnemyData):
	
	if player_ref != null and player_ref.exp_manager != null:
		player_ref.exp_manager.exp_collected_in_round += enemy_data.exp_on_dead
	
	enemies_alive -= 1
	print("enemy died. still alive: " + str(enemies_alive))
	
	#if boss dies -> day ends when no other enemy is alive
	if enemy_data.is_boss:
		is_boss_alive = false
		if enemies_alive <= 0:
			print("aaaaaaaaaaaaaaaa")
			player_ref.exp_manager._on_day_cleared(enemies_spawned)
			user_interface.advance_time()
		return
	
	
	#if all normal enemies are dead and boss has not been spawned then spawn boss
	if enemies_alive <= 0 and not boss_spawned:
		spawn_boss()
		return
	
	#if nothing left and no boss and no spawns then end day
	if enemies_alive <= 0 and not enemies_spawn and not is_boss_alive and not boss_spawned:
		user_interface.advance_time()
		print("aaaaaaaaaaaaaaaa")
		player_ref.exp_manager._on_day_cleared(enemies_spawned)
	
	#player_ref.exp_manager.exp_collected_in_round += enemy_data.exp_on_dead
	#print(player_ref.exp_manager.exp_collected_in_round)
	#enemies_alive -= 1
	#print("Enemy died. Remaining alive:", enemies_alive)
	#if enemy_data.is_boss:
		#is_boss_alive = false
	##Check after day is over
	#if enemies_alive <= 0 && !enemies_spawn && is_boss_alive == false:
		##Wave Cleared
		###conf_new_wave()
		#user_interface.advance_time()
##		emit_signal("day_cleared",total_to_spawn)
		#enemies_spawn = true
	#


func calc_total_to_spawn() -> float:
	var base = 0
	if current_day != null:
		base = current_day.normal_enemies_amount
	if week_nmr == 1:
		return base
	var scale = pow(days_total + 1, 0.9) + log(days_total + 2)
	var extra = clamp(scale,1.0,3.5)
	return round(base*extra)
	
	#var base = current_day.normal_enemies_amount
	#if week_nmr == 1:
		#return base
	#var scale = pow(days_total + 1, 0.9) + log(days_total + 2)
	#var extra = clamp(scale, 1.0, 3.5)
#
	#var total = round(base * extra)
#
	#return total
		

func dificulty_up_week():
	player_ref.stats.difficulty += 0.1
	
	
#For Bosses that spawns enemies
func spawn_custom_enemies(count: int,minion_pool: PoolData) -> void:
	if minion_pool == null or minion_pool.pool.is_empty():
		push_error("custom spawn pool is empty")
		return
	for i in range(count):
		var enemyData: EnemyData = weighted_pick(minion_pool)
		if enemyData == null or enemyData.scene == null:
			push_error("enemy is empty")
			return
		spawn_enemy(enemyData)
	 
	#if minion_pool == null or minion_pool.pool.is_empty():
		#push_error("Enemy/Enemy pool is empty")
		#return
	#for i in range(count):
		#var enemy_data: EnemyData = weighted_pick(minion_pool)
		#if enemy_data == null or enemy_data.scene == null:
			#push_error("Enemy/Enemy Scene is empty")
			#continue
#
		#var enemy: Enemy = enemy_data.scene.instantiate()
		#spawned_enemies.append(enemy)
		#
		## Scale stats
		#var new_max_hp: float = (enemy.stats.max_health * player_ref.stats.difficulty) + (enemy.stats.max_health * 0.2)
		#enemy.stats.max_health = new_max_hp
		#var new_armor = (enemy.stats.armor * player_ref.stats.difficulty) + (enemy.stats.armor * 0.2)
		#enemy.stats.armor = new_armor
		#enemy.stats.dmg_multiplyer += 0.2
		#
		#if player_ref == null:
			#player_ref = get_node("/root/MainGame/Player")
		#enemy.set_player_ref(player_ref)
		#
		#if hub_ref == null:
			#hub_ref = get_node("/root/MainGame/Hub")
		#enemy.set_hub_ref(hub_ref)
#
		#get_parent().add_child(enemy)
#
		## Position near boss
		#var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * randf_range(min_distance, max_distance)
		#enemy.global_position = self.global_position + offset
#
		#enemy.connect("died", Callable(self, "_on_enemy_died").bind(enemy_data))
#
		#enemies_alive += 1
		#print("Boss spawned extra minion")
