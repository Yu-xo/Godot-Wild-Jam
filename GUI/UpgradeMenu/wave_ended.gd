extends CanvasLayer

@onready var label = $Control/MarginContainer/Panel/Label
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var sfx_path: String
@export var talk_sound_path: String
@export var pitch_range: Array[float]

func _ready():
	action()
	
func action() -> void:
	DialogueManager.talk_sfx = talk_sound_path
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start, [self, get_parent()])
	
func new_round():
	WaveState.start_wave(WaveState.current_wave+1)
	SceneManager.change_gui_scene("res://GUI/hud.tscn")
