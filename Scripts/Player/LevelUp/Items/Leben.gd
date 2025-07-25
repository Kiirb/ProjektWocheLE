extends Item

func apply():
	var player_hp_per = player.stats.hp / player.stats.max_health
	player.stats.max_health += icrease_ammount
	player.stats.hp = player.stats.max_health * player_hp_per
