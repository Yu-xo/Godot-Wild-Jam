extends Node

var master_bus
var music_bus
var sfx_bus
var muffle_bus

var fade_tween: Tween = null
var current_music_player: AudioStreamPlayer = null
var is_fading := false
var is_fading_out := false

func init_sound_system():
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	muffle_bus = AudioServer.get_bus_index("Muffle")
	set_master_volume()
	set_music_volume()
	set_sfx_volume()
	
func set_master_volume(value = 1):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
func set_music_volume(value = 1):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func set_sfx_volume(value = 1):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func play_sound(sound_path: String, bus: String = "SFX", volume_percent: float = 100.0, pitch: float = 1.0) -> AudioStreamPlayer:
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_path)
	sound.bus = bus
	
	volume_percent = clamp(volume_percent, 0.0, 100.0)
	if volume_percent <= 0.0:
		sound.volume_db = -80.0
	else:
		var scale = volume_percent / 100.0
		sound.volume_db = 20.0 * log(scale)
	sound.pitch_scale = pitch
	add_child(sound)
	sound.play()
	sound.connect("finished", Callable(sound, "queue_free"))
	return sound
	
func play_music(stream: AudioStream, loop: bool = true, fade_duration: float = 1.0, volume_percent: float = 100.0):
	# Clamp and convert volume to dB
	volume_percent = clamp(volume_percent, 0.0, 100.0)
	var target_volume_db: float
	if volume_percent <= 0.0:
		target_volume_db = -80.0
	else:
		var scale = volume_percent / 100.0
		target_volume_db = 20.0 * log(scale)

	# If same music is already playing at same target volume, do nothing
	if current_music_player and current_music_player.stream == stream and current_music_player.playing and abs(current_music_player.volume_db - target_volume_db) < 0.1 and not is_fading:
		return
	
	# If the same music is fading out, simply fade it back up
	if is_fading and is_fading_out and current_music_player and current_music_player.stream == stream:
		if fade_tween:
			fade_tween.kill()
		fade_tween = create_tween()
		fade_tween.tween_property(current_music_player, "volume_db", target_volume_db, fade_duration * 0.5)
		fade_tween.tween_callback(func(): 
			is_fading = false
			is_fading_out = false
		)
		return
	
	# Stop any existing fade
	if fade_tween:
		fade_tween.kill()
		is_fading = false
		is_fading_out = false
	
	# Fade out current music if it exists and is different from new music
	if current_music_player and current_music_player.playing and (current_music_player.stream != stream or abs(current_music_player.volume_db - target_volume_db) >= 0.1):
		is_fading = true
		is_fading_out = true
		fade_tween = create_tween()
		fade_tween.tween_property(current_music_player, "volume_db", -80.0, fade_duration)
		fade_tween.tween_callback(current_music_player.stop)
		fade_tween.tween_callback(current_music_player.queue_free)
		fade_tween.tween_callback(func(): 
			is_fading = false
			is_fading_out = false
			if current_music_player and current_music_player.stream == stream:
				return
			_create_new_music_player(stream, fade_duration, target_volume_db)
		)
	else:
		# No music playing or same music needs volume adjustment
		_create_new_music_player(stream, fade_duration, target_volume_db)
		
func remove_low_pass_filter_from_music():
	var effect := AudioServer.get_bus_effect(muffle_bus, 0) 
	if effect is AudioEffectLowPassFilter:
		var t = create_tween()
		t.tween_property(effect, "cutoff_hz", 20500.0, 1.0)
		
func add_low_pass_filter_to_music():
	var effect := AudioServer.get_bus_effect(muffle_bus, 0.0) 
	if effect is AudioEffectLowPassFilter:
		var t = create_tween()
		t.tween_property(effect, "cutoff_hz", 1000.0, 0.0)
	
func stop_music(fade_duration: float = 1.0):
	if current_music_player:
		if fade_duration > 0:
			if fade_tween:
				fade_tween.kill()
			is_fading = true
			is_fading_out = true
			fade_tween = create_tween()
			fade_tween.tween_property(current_music_player, "volume_db", -80.0, fade_duration)
			fade_tween.tween_callback(current_music_player.stop)
			fade_tween.tween_callback(current_music_player.queue_free)
			fade_tween.tween_callback(func(): 
				current_music_player = null
				is_fading = false
				is_fading_out = false
			)
		else:
			current_music_player.stop()
			current_music_player.queue_free()
			current_music_player = null
			is_fading = false
			is_fading_out = false


func _create_new_music_player(stream: AudioStream, fade_duration: float, target_volume_db: float):
	# Create new player
	current_music_player = AudioStreamPlayer.new()
	current_music_player.stream = stream
	current_music_player.bus = "Music"
	current_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	current_music_player.volume_db = -80.0 if fade_duration > 0 else target_volume_db
	
	add_child(current_music_player)
	current_music_player.play()
	
	# Fade in new music if fade duration specified
	if fade_duration > 0:
		is_fading = true
		fade_tween = create_tween()
		fade_tween.tween_property(current_music_player, "volume_db", target_volume_db, fade_duration)
		fade_tween.tween_callback(func(): is_fading = false)
