extends Control

@onready var canvas_layer = $".."

func _on_start_pressed():
	var gamecam = get_tree().get_first_node_in_group("gamecam")
	gamecam.priority = 2
	canvas_layer.visible = false
	await get_tree().create_timer(5.0).timeout
	WaveState.start_wave(1)
	SceneManager.delete_current_gui_scene()
