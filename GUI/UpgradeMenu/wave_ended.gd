extends CanvasLayer

@onready var label = $Control/MarginContainer/Panel/Label

func _ready():
	await get_tree().create_timer(3.0).timeout
	WaveState.start_wave(WaveState.current_wave+1)
	SceneManager.change_gui_scene("res://GUI/hud.tscn")
