extends State

@onready var enemy = $"../.."

var can_dodge := true
var dodge_cooldown := 3.5
var dodge_distance := 3.0
var dodge_time := 0.3

func Enter():
	enemy.in_range = false

func Exit():
	pass

func Update(delta):
	if not is_instance_valid(enemy.base):
		return

	var enemy_pos = enemy.global_transform.origin
	var base_pos = enemy.base.global_transform.origin

	var dir = (base_pos - enemy_pos)
	dir.y = 0
	var dist = dir.length()

	if dist > 0.5:
		dir = dir.normalized()
		enemy.look_at(Vector3(base_pos.x, enemy_pos.y, base_pos.z), Vector3.UP)
		var move_speed = enemy.speed if enemy.speed != null else 2.0
		enemy.global_translate(dir * move_speed * delta)
	if enemy.has_meta("dodging") and enemy.get_meta("dodging"):
		var elapsed = enemy.get_meta("dodge_elapsed") + delta
		var start_pos = enemy.get_meta("dodge_start")
		var target_pos = enemy.get_meta("dodge_target")
		var t = min(elapsed / dodge_time, 1.0)
		enemy.global_transform.origin = start_pos.lerp(target_pos, t)
		enemy.set_meta("dodge_elapsed", elapsed)
		if t >= 1.0:
			enemy.set_meta("dodging", false)
			
	if enemy.in_range:
		Transitioned.emit(self, "attack")


func _on_pellet_entered_area_entered(area):
	if area.is_in_group("pellet") and can_dodge:
		can_dodge = false
		start_dodge()
		start_dodge_cooldown()


func start_dodge():
	var forward = (enemy.base.global_transform.origin - enemy.global_transform.origin).normalized()
	var dodge_dir = forward.cross(Vector3.UP).normalized()
	if randi() % 2 == 0:
		dodge_dir = -dodge_dir
		
	enemy.set_meta("dodge_start", enemy.global_transform.origin)
	enemy.set_meta("dodge_target", enemy.global_transform.origin + dodge_dir * dodge_distance)
	enemy.set_meta("dodge_elapsed", 0.0)
	enemy.set_meta("dodging", true)


func start_dodge_cooldown():
	var timer = get_tree().create_timer(dodge_cooldown)
	timer.timeout.connect(_on_dodge_cooldown_timeout)


func _on_dodge_cooldown_timeout():
	can_dodge = true
