extends Node

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)

var current_wave: int = 0
var active_spawner_data: Dictionary = {}
var total_enemies_in_wave: int = 0
var enemies_alive: int = 0

var wave_config := {
	"base_total_enemies": 2,        # total enemies for wave 1
	"enemies_increase_per_wave": 2, # add this many total enemies per wavee
	"base_spawn_delay": 2.5,
	"min_spawn_delay": 1.5,
	"delay_reduction_per_wave": 0.1,
	"spawners_per_wave": {
		1: 2,
		2: 2,
		3: 2,
		4: 3,
		5: 3,
		6: 4,
		7: 4,
		8: 4,
		9: 5,
		10: 5
	}
}

var enemy_types := {
	"Squirrel": {"weight": 10, "min_wave": 1}
	#"Rabbit": {"weight": 8, "min_wave": 2},
}

func generate_wave_data(wave_number: int) -> Dictionary:
	var wave_data = {}
	var num_spawners = wave_config.spawners_per_wave.get(wave_number, 2)
	
	# calculate total enemies for this wave
	var total_enemies = wave_config.base_total_enemies + (wave_number - 1) * wave_config.enemies_increase_per_wave
	
	# distribute enemies across spawners
	var enemies_per_spawner = distribute_enemies_across_spawners(total_enemies, num_spawners)
	
	for spawner_id in range(1, num_spawners + 1):
		var enemy_count = enemies_per_spawner[spawner_id - 1] # array is 0-indexed
		wave_data[spawner_id] = generate_spawner_enemies_with_count(wave_number, spawner_id, enemy_count)
	
	print("Wave %d: %d total enemies across %d spawners" % [wave_number, total_enemies, num_spawners])
	return wave_data

func distribute_enemies_across_spawners(total_enemies: int, num_spawners: int) -> Array:
	var distribution = []
	var base_per_spawner = total_enemies / num_spawners
	var remainder = total_enemies % num_spawners
	
	# give each spawner the base amount
	for i in range(num_spawners):
		distribution.append(base_per_spawner)
	
	# distribute the remainder randomly
	for i in range(remainder):
		var random_spawner = randi() % num_spawners
		distribution[random_spawner] += 1
	
	# ensure minimum of 1 enemy per spawner (if total allows)
	if total_enemies >= num_spawners:
		for i in range(num_spawners):
			if distribution[i] < 1:
				distribution[i] = 1
	
	return distribution

func generate_spawner_enemies_with_count(wave_number: int, spawner_id: int, enemy_count: int) -> Array:
	var enemies = []
	var spawner_start_delay = (spawner_id - 1) * 2.0
	var cumulative_delay = 1.0 + spawner_start_delay
	
	for i in range(enemy_count):
		var enemy_type = choose_enemy_type(wave_number)
		var spawn_delay = calculate_spawn_delay(wave_number, i)
		
		enemies.append({
			"type": enemy_type,
			"delay": cumulative_delay
		})
		
		# add this spawn delay to the cumulative time for the next enemy
		cumulative_delay += spawn_delay
	
	print("  Spawner %d: %d enemies starting at %.1fs, ending at %.1fs" % [spawner_id, enemy_count, spawner_start_delay + 1.0, cumulative_delay])
	return enemies

func choose_enemy_type(wave_number: int) -> String:
	var available_types = []
	var total_weight = 0
	
	for enemy_type in enemy_types.keys():
		var enemy_data = enemy_types[enemy_type]
		if wave_number >= enemy_data.min_wave:
			available_types.append({
				"type": enemy_type,
				"weight": enemy_data.weight
			})
			total_weight += enemy_data.weight
	
	if available_types.is_empty():
		push_warning("No enemies available for wave %s, using Squirrel" % wave_number)
		return "Squirrel"
	
	var random_value = randf() * total_weight
	var current_weight = 0
	
	for enemy in available_types:
		current_weight += enemy.weight
		if random_value <= current_weight:
			return enemy.type
	
	return available_types[0].type

func calculate_spawn_delay(wave_number: int, enemy_index: int) -> float:
	var base_delay = wave_config.base_spawn_delay
	var reduced_delay = base_delay - (wave_number - 1) * wave_config.delay_reduction_per_wave
	var final_delay = max(reduced_delay, wave_config.min_spawn_delay)
	
	return final_delay + randf() * 1.0

func start_wave(wave_number: int):
	current_wave = wave_number
	
	announce_new_enemies(wave_number)
	
	active_spawner_data = generate_wave_data(wave_number)
	
	total_enemies_in_wave = 0
	for spawner_id in active_spawner_data.keys():
		total_enemies_in_wave += active_spawner_data[spawner_id].size()
	
	enemies_alive = total_enemies_in_wave
	
	print("=== WAVE %d STARTED ===" % current_wave)
	print("Total enemies in wave: %d" % total_enemies_in_wave)
	print("Enemies alive: %d" % enemies_alive)
	
	emit_signal("wave_started", current_wave)

func announce_new_enemies(wave_number: int):
	for enemy_type in enemy_types.keys():
		var enemy_data = enemy_types[enemy_type]
		if enemy_data.min_wave == wave_number:
			print("New enemy type available: %s!" % enemy_type)

func get_available_enemies(wave_number: int) -> Array:
	var available = []
	for enemy_type in enemy_types.keys():
		var enemy_data = enemy_types[enemy_type]
		if wave_number >= enemy_data.min_wave:
			available.append(enemy_type)
	return available

func get_spawner_data(spawner_id: String) -> Dictionary:
	var id_as_int = int(spawner_id)
	if id_as_int in active_spawner_data:
		return active_spawner_data[id_as_int]
	return {}

func pop_enemy_for_spawner(spawner_id: String) -> Dictionary:
	var id_as_int = int(spawner_id)
	if id_as_int in active_spawner_data:
		var enemies = active_spawner_data[id_as_int]
		if enemies.size() > 0:
			return enemies.pop_front()
	return {}

func enemy_killed():
	enemies_alive -= 1
	print("Enemy killed! Enemies remaining: %d" % enemies_alive)
	if enemies_alive <= 0:
		print("=== WAVE %d ENDED ===" % current_wave)
		emit_signal("wave_ended", current_wave)
		var cycle_position = (current_wave - 1) % 5 + 1
		print("cycle: ", cycle_position)
		if cycle_position == 3:
			SceneManager.change_gui_scene("res://GUI/UpgradeMenu/StatsUpgradeMenu.tscn")
			get_tree().get_first_node_in_group("player").canMove = false
		elif cycle_position == 5:
			SceneManager.change_gui_scene("res://GUI/UpgradeMenu/UpgradeMenu.tscn")
			get_tree().get_first_node_in_group("player").canMove = false
		else:
			SceneManager.change_gui_scene("res://GUI/UpgradeMenu/WaveEnded.tscn")
			get_tree().get_first_node_in_group("player").canMove = true
