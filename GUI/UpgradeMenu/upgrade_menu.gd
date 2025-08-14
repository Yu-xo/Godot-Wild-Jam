extends CanvasLayer

var option_1: Dictionary
var option_2: Dictionary
@onready var option_1_button = $Control/PanelContainer/MarginContainer/HBoxContainer/Option1
@onready var option_2_button = $Control/PanelContainer/MarginContainer/HBoxContainer/Option2
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	AudioManager.add_low_pass_filter_to_music()
	_select_two_unique_types()

func _select_two_unique_types():
	# special case for wave 25
	if WaveState.current_wave == 20:
		option_1 = {
			"name": "Firework Rocket",
			"description": "The ticket out of here",
			"cost": 2000
		}
		option_1_button.visible = true
		option_1_button.disabled = false
		option_1_button.text = option_1["name"]

		option_2_button.visible = false
		option_2_button.disabled = true
		return

	# normal upgrade selection
	var upgrades = UpgradeState.list_available_upgrades().filter(
		func(upgrade): return upgrade["type"] != "stat"
	)

	if upgrades.size() == 0:
		push_warning("No upgrades available!")
		option_1_button.visible = false
		option_2_button.visible = false
		option_1_button.disabled = true
		option_2_button.disabled = true
		return
	
	if upgrades.size() == 1:
		option_1 = upgrades[0]
		option_1_button.visible = true
		option_1_button.disabled = false
		option_1_button.text = option_1["name"]
		
		option_2_button.visible = false
		option_2_button.disabled = true
		return
	
	option_1_button.visible = true
	option_2_button.visible = true
	option_1_button.disabled = false
	option_2_button.disabled = false

	option_1 = upgrades.pick_random()

	var different_type_upgrades = upgrades.filter(
		func(upgrade): return upgrade["type"] != option_1["type"]
	)

	if different_type_upgrades.is_empty():
		option_2_button.visible = false
		option_2_button.disabled = true
		option_1_button.text = option_1["name"]
		return

	option_2 = different_type_upgrades.pick_random()

	option_1_button.text = option_1["name"]
	option_2_button.text = option_2["name"]

	
func _on_option_1_pressed():
	UpgradeState.add_upgrade(option_1["name"] if option_1.has("name") else option_1["name"])
	player.canMove = true
	AudioManager.remove_low_pass_filter_from_music()
	SceneManager.change_gui_scene("res://GUI/hud.tscn")

func _on_option_2_pressed():
	UpgradeState.add_upgrade(option_2["name"] if option_2.has("name") else option_2["name"])
	player.canMove = true
	AudioManager.remove_low_pass_filter_from_music()
	SceneManager.change_gui_scene("res://GUI/hud.tscn")

func _on_option_1_mouse_entered():
	if option_1 and option_1.has("description"):
		option_1_button.text = option_1["description"]

func _on_option_2_mouse_entered():
	if option_2 and option_2.has("description"):
		option_2_button.text = option_2["description"]

func _on_option_1_mouse_exited():
	option_1_button.text = option_1["name"]
	
func _on_option_2_mouse_exited():
	option_2_button.text = option_2["name"]

func _on_tree_exited():
	WaveState.start_wave(WaveState.current_wave+1)
