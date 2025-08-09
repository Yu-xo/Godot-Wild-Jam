extends State

@onready var test_enemy = $"../.."
@onready var attack_timer = $AttackTimer

func Enter():
	test_enemy.base.take_dmg(test_enemy.damage)
	attack_timer.start()
	
func Exit():
	pass
	

func _on_attack_timer_timeout():
	if test_enemy.base:
		test_enemy.base.take_dmg(test_enemy.damage)
		attack_timer.start()
