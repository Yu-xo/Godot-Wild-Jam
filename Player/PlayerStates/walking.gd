extends State
@onready var player = $"../.."
var target_speed: float = 0.0
var rotation_speed: float = 25.0
var target_rotation: float
var horizontal_velocity

func Enter():
	print("walking")
	target_rotation = player.rotation.y
	
func Exit():
	pass
	
func Update(delta):
	var input_vector = Input.get_vector("left", "right", "forward", "backward")
	var input_strength = input_vector.length()

	if input_strength > 0.1:
		var input_dir = input_vector.normalized()
		var move_dir = Vector3(input_dir.x, 0.0, input_dir.y)
		target_rotation = atan2(move_dir.x, move_dir.z)
		player.velocity.x = lerp(player.velocity.x, move_dir.x * player.speed, delta * 10.0)
		player.velocity.z = lerp(player.velocity.z, move_dir.z * player.speed, delta * 10.0)
	else:
		# decelerate
		player.velocity.x = lerp(player.velocity.x, 0.0, delta * 6.0)
		player.velocity.z = lerp(player.velocity.z, 0.0, delta * 6.0)

	#player.rotation.y = lerp_angle(player.rotation.y, target_rotation, rotation_speed * delta)

	if input_strength == 0:
		#var rotation_diff = abs(angle_difference(player.rotation.y, target_rotation))
		#if rotation_diff < 0.1:
		Transitioned.emit(self, "idle")
