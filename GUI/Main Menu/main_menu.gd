extends Control

@onready var canvas_layer = $".."
const MAIN_MENU_TEST = preload("res://Music/main_menu_test.ogg")

func _ready():
	AudioManager.play_music(MAIN_MENU_TEST, true, 0.0)
	
func _on_start_pressed():
	var gamecam = get_tree().get_first_node_in_group("gamecam")
	gamecam.priority = 2
	canvas_layer.visible = false
	AudioManager.stop_music(1.0)
	SceneManager.change_gui_scene("res://GUI/hud.tscn")
	await get_tree().create_timer(2.0).timeout
