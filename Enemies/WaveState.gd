extends Node

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)

var current_wave: int = 0
var active_spawner_data: Dictionary = {}
var total_enemies_in_wave: int = 0
var enemies_alive: int = 0
# wave data will be used to store information on what to spawn, which spawner, and in what intervals
#spawners will spawn enemies in descending order. for a batch spawn of enemies just make delay = 0.0
var wave_data := {
	1: {
		1: [
			{"type": "Squirrel", "delay": 4.0},
			{"type": "Squirrel", "delay": 4.0},
			{"type": "Squirrel", "delay": 4.0},
			{"type": "Squirrel", "delay": 1.0}
		],
		2: [
			{"type": "Squirrel", "delay": 4.0},
			{"type": "Squirrel", "delay": 4.0},
			{"type": "Squirrel", "delay": 4.0},
			{"type": "Squirrel", "delay": 1.0}
		]
	}
}

func start_wave(wave_number: int):
	if not wave_data.has(wave_number):
		push_warning("No data for wave %s" % wave_number)
		return

	current_wave = wave_number
	active_spawner_data = wave_data[wave_number].duplicate(true)

	# Count total enemies
	total_enemies_in_wave = 0
	for spawner_id in active_spawner_data.keys():
		total_enemies_in_wave += active_spawner_data[spawner_id].size()
	enemies_alive = total_enemies_in_wave

	emit_signal("wave_started", current_wave)

func get_spawner_data(spawner_id: String) -> Dictionary:
	if spawner_id in active_spawner_data:
		return active_spawner_data[spawner_id]
	return {}

func pop_enemy_for_spawner(spawner_id: String) -> Dictionary:
	var id_as_int = int(spawner_id)  # Convert to int
	if id_as_int in active_spawner_data:
		var enemies = active_spawner_data[id_as_int]
		if enemies.size() > 0:
			return enemies.pop_front()
	return {}

func enemy_killed():
	enemies_alive -= 1
	if enemies_alive <= 0:
		emit_signal("wave_ended", current_wave)
