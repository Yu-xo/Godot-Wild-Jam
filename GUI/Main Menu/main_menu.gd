extends Control

@onready var canvas_layer = $".."
const MAIN_MENU_TEST = preload("res://Music/main_menu_test.ogg")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var sfx_path: String
@export var talk_sound_path: String
@export var pitch_range: Array[float]

func _ready():
	AudioManager.play_music(MAIN_MENU_TEST, true, 0.0)
	
func _on_start_pressed():
	canvas_layer.visible = false
	AudioManager.stop_music(1.0)
	canvas_layer.hide()
	action()

func action() -> void:
	DialogueManager.talk_sfx = talk_sound_path
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start, [self, get_parent()])
	
func switch_scene():
	var gamecam = get_tree().get_first_node_in_group("gamecam")
	gamecam.priority = 2
	SceneManager.change_gui_scene("res://GUI/hud.tscn")
