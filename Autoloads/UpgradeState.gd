extends Node

var current_upgrades: Array = []
var upgrade_counts: Dictionary = {}

var available_upgrades: Array = [
	{"name": "Twig Slingshot", "type": "weapon", "description": "Blueprints for a makeshift slingshot, made of a rubber band and a sturdy twig."},
	{"name": "Toothpick Bow", "type": "weapon", "description": "Blueprints for a twig bow tied together with floss!"},
	{"name": "Water Feeder Turret", "type": "defense", "description": "Blueprints to turn Bipster's water feeder into a high pressure turret!"},
	{"name": "Pellet Feeder Turret", "type": "defense", "description": "Blueprints to turn Bipster's pellet feeder into an omni-directional turret!"},
	{"name": "Crit Chance Boost", "type": "stat", "stat": "crit_chance", "value": 0.05, "description": "Increase your crit chance by 5%!"},
	{"name": "Move Speed Boost", "type": "stat", "stat": "move_speed", "value": 0.2, "description": "Increase your movement speed!"},
	{"name": "Repair Cage", "type": "stat", "stat": "repair_cage_hp", "value": 50, "description": "Repair cage's HP by 50!"}
]

func has_upgrade(upgrade_name: String) -> bool:
	return upgrade_name in current_upgrades
	
func add_upgrade(upgrade_name: String) -> bool:
	if not has_upgrade(upgrade_name):
		current_upgrades.append(upgrade_name)
		# Remove from available upgrades
		available_upgrades = available_upgrades.filter(
			func(upgrade): return upgrade["name"] != upgrade_name
		)
		return true
	return false

func add_stat_upgrade(upgrade_name: String) -> bool:
		for upgrade in available_upgrades:
			if upgrade["name"] == upgrade_name && upgrade["type"] == "stat":
				if upgrade_name in upgrade_counts:
					upgrade_counts[upgrade_name] += 1
				else:
					upgrade_counts[upgrade_name] = 1
				return true
		return false

func list_available_upgrades() -> Array:
	return available_upgrades.duplicate(true)
