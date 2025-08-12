extends Node3D

@export var shooting_range := 20.0
@export var rotation_speed := 5.0
@export var fire_rate := 1.0
@export var bullet_scene: PackedScene

@onready var base = $base

var current_target : Node3D = null
var enemies := []
var fire_timer := 0.0

func _process(delta):
	_update_enemies()
	_select_target()
	
	if current_target:
		_aim_at_target(delta)
		_try_shoot(delta)
	else:
		_reset_turret()

func _update_enemies():
	enemies = get_tree().get_nodes_in_group("enemy")

func _select_target():
	if current_target and (not current_target.is_inside_tree() or current_target.currhp <= 0):
		current_target = null

	if current_target == null and enemies.size() > 0:
		var closest_dist = shooting_range + 1.0
		var closest_enemy = null
		for enemy in enemies:
			if not enemy.is_inside_tree():
				continue
			if enemy.currhp <= 0:
				continue
			var dist = global_transform.origin.distance_to(enemy.global_transform.origin)
			if dist < closest_dist and dist <= shooting_range:
				closest_dist = dist
				closest_enemy = enemy
		
		current_target = closest_enemy

func _aim_at_target(delta):
	var to_target = (current_target.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = global_transform.basis.looking_at(to_target, Vector3.UP).get_euler()
	var current_rotation = rotation

	current_rotation.y = lerp_angle(current_rotation.y, target_rotation.y, rotation_speed * delta)
	rotation = current_rotation

func _try_shoot(delta):
	fire_timer -= delta
	if fire_timer <= 0.0:
		fire_timer = 1.0 / fire_rate
		_shoot()

func _shoot():
	if bullet_scene == null:
		print("No bullet scene assigned!")
		return

	var bullet_instance = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_transform.origin = global_transform.origin

	var target_pos = current_target.global_transform.origin
	var direction: Vector3

	if current_target.has_method("get_velocity"):
		var target_velocity = current_target.get_velocity()
		var predicted_pos = calculate_lead_position(global_transform.origin, target_pos, target_velocity, bullet_instance.speed)

		var speed = target_velocity.length()
		if speed > 0.1:
			var to_predicted = (predicted_pos - global_transform.origin).normalized()
			var random_angle = randf_range(-0.05, 0.05)
			var axis = to_predicted.cross(Vector3.UP)
			if axis.length() < 0.01:
				axis = Vector3.RIGHT
			axis = axis.normalized()

			var offset = axis.rotated(Vector3.UP, random_angle) * 1.0
			var aim_point = predicted_pos + offset
			direction = (aim_point - global_transform.origin).normalized()
		else:
			direction = (target_pos - global_transform.origin).normalized()
	else:
		direction = (target_pos - global_transform.origin).normalized()

	bullet_instance.look_at(global_transform.origin + direction, Vector3.UP)

	if bullet_instance.has_method("set_velocity"):
		bullet_instance.set_velocity(direction * bullet_instance.speed)


func calculate_lead_position(shooter_pos: Vector3, target_pos: Vector3, target_vel: Vector3, bullet_speed: float) -> Vector3:
	var to_target = target_pos - shooter_pos
	var a = target_vel.length_squared() - bullet_speed * bullet_speed
	var b = 2.0 * to_target.dot(target_vel)
	var c = to_target.length_squared()
	var discriminant = b * b - 4 * a * c

	if discriminant < 0 or abs(a) < 0.001:
		return target_pos

	var sqrt_disc = sqrt(discriminant)
	var t1 = (-b + sqrt_disc) / (2 * a)
	var t2 = (-b - sqrt_disc) / (2 * a)

	var t = min(t1, t2)
	if t < 0:
		t = max(t1, t2)
	if t < 0:
		return target_pos

	t = max(t, 0.1)

	var adjusted_bullet_speed = bullet_speed * 1.1

	return target_pos + target_vel * t



func _reset_turret():
	pass
