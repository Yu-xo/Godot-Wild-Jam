extends Node

var master_bus
var music_bus
var sfx_bus

func init_sound_system():
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	set_master_volume()
	set_music_volume()
	
func set_master_volume(value = 1):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
func set_music_volume(value = 1):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func set_sfxc_volume(value = 1):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func play_sound(sound_path: String, bus: String = "SFX") -> AudioStreamPlayer:
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_path)
	sound.bus = bus
	add_child(sound)
	sound.play()
	sound.connect("finished", Callable(sound, "queue_free"))
	return sound
