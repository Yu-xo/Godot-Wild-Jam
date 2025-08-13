extends Node3D

@export var swivel_speed: float = 10.0
@export var follow_distance: float = 3.0  # reduced to bring camera closer
@export var height_offset: float = 2.0
@export var follow_smooth: float = 5.0    # higher = faster, lower = more delay

@onready var player: Node3D = get_tree().get_first_node_in_group("player")

var target_rotation_y: float = 0.0

func _ready():
	target_rotation_y = round(rotation.y / deg_to_rad(90.0)) * deg_to_rad(90.0)

func _process(delta):
	if not player.canMove:
		return

	if Input.is_action_just_pressed("camleft"):
		AudioManager.play_sound("res://Main/camleft.wav", "SFX", 75.0)
		target_rotation_y -= deg_to_rad(90.0)
	elif Input.is_action_just_pressed("camright"):
		AudioManager.play_sound("res://Main/camright.wav", "SFX", 75.0)
		target_rotation_y += deg_to_rad(90.0)

	# Smoothly rotate the pivot
	rotation.y = lerp_angle(rotation.y, target_rotation_y, swivel_speed * delta)

	# Calculate desired camera position
	var offset = Vector3(0, height_offset, follow_distance)
	var desired_position = player.global_transform.origin + offset.rotated(Vector3.UP, rotation.y)

	# Smoothly move the camera toward the desired position
	global_transform.origin = global_transform.origin.lerp(desired_position, follow_smooth * delta)
