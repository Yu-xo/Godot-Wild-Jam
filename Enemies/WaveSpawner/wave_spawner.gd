extends Node3D

@export var spawner_id: String = ""
@export var spawn_point: Node3D
@export var enemy_scenes: Dictionary

var spawning: bool = false

func _ready():
	call_deferred("_connect_wave_signal")

func _connect_wave_signal():
	WaveState.connect("wave_started", Callable(self, "_on_wave_started"))

func _on_wave_started(wave_number: int):
	print("=== WAVE STARTED: %d ===" % wave_number)
	print("Spawner ID: '%s', Already spawning: %s" % [spawner_id, spawning])
	
	# Prevent multiple spawn processes
	if spawning:
		print("Already spawning, ignoring duplicate wave_started signal")
		return
	
	var spawner_queue = WaveState.active_spawner_data.get(int(spawner_id), [])
	print("Queue size for spawner %s: %d" % [spawner_id, spawner_queue.size()])
	
	if spawner_queue.size() == 0:
		print("Spawner %s has no enemies to spawn this wave" % spawner_id)
		return
		
	spawning = true
	_spawn_next()

func _spawn_next():
	if not spawning:
		print("Spawning stopped for spawner %s" % spawner_id)
		return
		
	var spawn_info = WaveState.pop_enemy_for_spawner(spawner_id)
	print("Spawn info for spawner %s: %s" % [spawner_id, spawn_info])
	
	if spawn_info.size() == 0:
		print("No more enemies to spawn for spawner %s" % spawner_id)
		spawning = false
		return
	
	var enemy_type = spawn_info.get("type")
	var delay = spawn_info.get("delay")
	await get_tree().create_timer(delay).timeout
	
	if enemy_type in enemy_scenes:
		var enemy_instance = enemy_scenes[enemy_type].instantiate()
		
		var radius = 5.0
		var angle = randf() * TAU
		var offset = Vector3(cos(angle), 0, sin(angle)) * randf_range(0, radius)
		add_child(enemy_instance)
		
		if spawn_point:
			enemy_instance.global_transform.origin = spawn_point.global_transform.origin + offset
		else:
			enemy_instance.global_transform.origin = global_transform.origin + offset
		
	else:
		push_warning("Unknown enemy type: %s" % enemy_type)
	
	_spawn_next()
