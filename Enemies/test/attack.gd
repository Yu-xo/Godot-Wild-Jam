extends State

@onready var test_enemy = $"../.."
@onready var attack_timer = $AttackTimer

var base

func Enter():
	base = get_tree().get_first_node_in_group("base")
	base.take_dmg(test_enemy.damage)
	attack_timer.start()
	
func Exit():
	pass
	

func _on_attack_timer_timeout():
	base.take_dmg(test_enemy.damage)
	attack_timer.start()
