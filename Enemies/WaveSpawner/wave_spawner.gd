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
	print("=== WAVE STARTED: %d at Spawner %s ===" % [wave_number, spawner_id])
	
	if spawning:
		return
	
	spawning = true
	_spawn_wave_enemies()

func _spawn_wave_enemies():
	
	while true:
		var spawn_info = WaveState.pop_enemy_for_spawner(spawner_id)
		
		if spawn_info.size() == 0:
			break
		
		var enemy_type = spawn_info.get("type")
		var delay = spawn_info.get("delay")
		
		
		if delay > 0:
			await get_tree().create_timer(delay).timeout
		
		if enemy_type in enemy_scenes:
			var enemy_instance = enemy_scenes[enemy_type].instantiate()
			var radius = 20.0
			var angle = randf() * TAU
			var offset = Vector3(cos(angle), 0, sin(angle)) * randf_range(0, radius)
			
			add_child(enemy_instance)
			enemy_instance.in_range = false
			
			if spawn_point:
				enemy_instance.global_transform.origin = spawn_point.global_transform.origin + offset
			else:
				enemy_instance.global_transform.origin = global_transform.origin + offset
		else:
			push_warning("Spawner %s: Unknown enemy type: %s" % [spawner_id, enemy_type])
	spawning = false
