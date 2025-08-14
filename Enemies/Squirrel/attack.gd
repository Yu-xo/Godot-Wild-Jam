extends State

@onready var test_enemy = $"../.."
@onready var attack_timer = $AttackTimer

const DAMAGE_POPUP = preload("res://Enemies/damage_popup_red.tscn")

func Enter():
	await get_tree().create_timer(1.0).timeout
	get_tree().get_first_node_in_group("cameramount").start_screenshake()
	spawn_damage_popup(test_enemy.damage)
	test_enemy.base.take_dmg(test_enemy.damage)
	attack_timer.start()
	
func Exit():
	pass
	

func _on_attack_timer_timeout():
	if test_enemy.base:
		get_tree().get_first_node_in_group("cameramount").start_screenshake()
		spawn_damage_popup(test_enemy.damage)
		test_enemy.base.take_dmg(test_enemy.damage)
		attack_timer.start()

func spawn_damage_popup(amount):
	var popup = DAMAGE_POPUP.instantiate()
	popup.set_damage(amount)
	get_tree().current_scene.add_child(popup)
	popup.global_transform.origin = test_enemy.global_transform.origin + Vector3(0, 3, 0)
