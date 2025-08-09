extends State

@onready var test_enemy = $"../.."

const ATTACK_RANGE = 8.0

func Enter():
	pass
	
func Exit():
	pass
	
func Update(delta):
	var base = get_tree().get_first_node_in_group("base")
	if base == null:
		return

	var enemy_pos = test_enemy.global_transform.origin
	var base_pos = base.global_transform.origin

	var dir = (base_pos - enemy_pos)
	dir.y = 0  
	dir = dir.normalized()

	var dist = enemy_pos.distance_to(base_pos)

	var move_speed = 5.0
	test_enemy.global_translate(dir * test_enemy.speed * delta)

	if dist <= ATTACK_RANGE:
		Transitioned.emit(self, "attack")
