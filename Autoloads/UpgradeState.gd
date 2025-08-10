extends Node

var current_upgrades: Array = []

var available_upgrades: Array = [
	{"name": "Twig Slingshot", "type": "weapon", "description": "Blueprints for a makeshift slingshot, made of a rubber band and a sturdy twig."},
	{"name": "Water Feeder Turret", "type": "defense", "description": "Blueprints to turn Bipster's water feeder into a high pressure turret!"}
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

func list_available_upgrades() -> Array:
	return available_upgrades.duplicate(true)
