extends State
@onready var player = $"../.."
@onready var animation_player = $"../../hamster/AnimationPlayer"
var target_speed: float = 0.0
var rotation_speed: float = 25.0
var target_rotation: float
var horizontal_velocity
var step_timer := 0.0
var step_interval := 0.4

var walk_sounds = [
	"res://Player/SFX/walk1.wav",
	"res://Player/SFX/walk2.wav", 
	"res://Player/SFX/walk3.wav"
]

func Enter():
	animation_player.play("Walk", 0.1, 2.0)
	target_rotation = player.rotation.y
	step_timer = 0.0
	
func Exit():
	pass
	
func Update(delta):
	if not player.canMove:
		Transitioned.emit(self, "idle")
		
	var input_vector = Input.get_vector("left", "right", "forward", "backward")
	var input_strength = input_vector.length()
	if input_strength > 0.1:
		var input_dir = input_vector.normalized()
		var cam_basis = get_tree().get_first_node_in_group("gamecam").global_transform.basis
		var forward = cam_basis.z
		var right = cam_basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		var move_dir = (right * input_dir.x + forward * input_dir.y).normalized()
		target_rotation = atan2(move_dir.x, move_dir.z)
		player.velocity.x = lerp(player.velocity.x, move_dir.x * player.speed, delta * 10.0)
		player.velocity.z = lerp(player.velocity.z, move_dir.z * player.speed, delta * 10.0)
		
		step_timer -= delta
		if step_timer <= 0.0:
			var random_sound = walk_sounds[randi() % walk_sounds.size()]
			AudioManager.play_sound(random_sound)
			step_timer = step_interval
	else:
		# decelerate
		player.velocity.x = lerp(player.velocity.x, 0.0, delta * 6.0)
		player.velocity.z = lerp(player.velocity.z, 0.0, delta * 6.0)
	if input_strength == 0:
		Transitioned.emit(self, "idle")
