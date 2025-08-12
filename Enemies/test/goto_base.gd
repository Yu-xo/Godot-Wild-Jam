extends State

@onready var test_enemy = $"../.."


func Enter():
	pass
	
func Exit():
	pass
	
func Update(delta):
	if not is_instance_valid(test_enemy.base):
		return
	
	var enemy_pos = test_enemy.global_transform.origin
	var base_pos = test_enemy.base.global_transform.origin

	var dir = (base_pos - enemy_pos)
	dir.y = 0
	var dist = dir.length()

	if dist > 0.1:
		dir = dir.normalized()
		
		test_enemy.look_at(Vector3(base_pos.x, enemy_pos.y, base_pos.z), Vector3.UP)
		
		var move_speed = test_enemy.speed if test_enemy.speed != null else 2.0
		test_enemy.global_translate(dir * move_speed * delta)

	if test_enemy.in_range:
		Transitioned.emit(self, "attack")
