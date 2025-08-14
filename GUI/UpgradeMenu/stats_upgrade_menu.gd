extends CanvasLayer

@onready var option_1_button = $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Option1
@onready var option_2_button = $Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Option2
var option_1: Dictionary
var option_2: Dictionary
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	AudioManager.add_low_pass_filter_to_music()
	_select_two_unique_types()

func _select_two_unique_types():
	var upgrades = UpgradeState.list_available_upgrades().filter(
		func(upgrade): return upgrade["type"] == "stat"
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

	option_1 = upgrades.pick_random()

	var other_upgrades = upgrades.filter(
		func(upgrade): return upgrade["name"] != option_1["name"]
	)

	option_2 = other_upgrades.pick_random()

	option_1_button.visible = true
	option_2_button.visible = true
	option_1_button.disabled = false
	option_2_button.disabled = false

	option_1_button.text = option_1["name"]
	option_2_button.text = option_2["name"]

func _apply_upgrade(upgrade: Dictionary):
	player = get_tree().get_first_node_in_group("player")
	const BASE_COST := 35
	var times_bought: int = UpgradeState.upgrade_counts.get(upgrade["name"], 0)
	var cost: int = BASE_COST + (10 * times_bought)

	if player.scrap < cost:
		print("Not enough scrap to buy upgrade!")
		return

	player.scrap -= cost
	print(player.scrap)

	if upgrade["type"] == "stat":
		match upgrade["stat"]:
			"crit_chance":
				if not player.crit_chance >= 1.0:
					player.crit_chance += upgrade["value"]
			"move_speed":
				var multiplier : float = upgrade["value"] * pow(0.8, times_bought)
				player.speed *= 1 + multiplier
			"repair_cage_hp":
				var cage = get_tree().get_first_node_in_group("base")
				cage.currhp = min(cage.currhp + upgrade["value"], cage.maxhp)
	else:
		UpgradeState.add_upgrade(upgrade["name"])

	UpgradeState.upgrade_counts[upgrade["name"]] = times_bought + 1

		
func _on_option_1_pressed():
	UpgradeState.add_upgrade(option_1["name"] if option_1.has("name") else option_1["name"])
	player.canMove = true
	_apply_upgrade(option_1)
	AudioManager.remove_low_pass_filter_from_music()
	SceneManager.change_gui_scene("res://GUI/hud.tscn")

func _on_option_2_pressed():
	UpgradeState.add_upgrade(option_2["name"] if option_2.has("name") else option_2["name"])
	player.canMove = true
	_apply_upgrade(option_2)
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

func _on_skip_pressed():
	player.canMove = true
	AudioManager.remove_low_pass_filter_from_music()
	SceneManager.change_gui_scene("res://GUI/hud.tscn")
