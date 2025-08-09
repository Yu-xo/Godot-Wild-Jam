extends CharacterBody3D

@onready var collision_shape = $CollisionShape3D
@onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
@export var speed: float
@onready var marker_3d = $Marker3D
var rotation_speed = 10.0
var canMove = false

func _ready(): 
	canMove = false # player starts of not able to move because it's in the main menu screen
	#TODO: make it so the player can start moving once the play button is pressed
	
func _process(delta):
	var mouse_world_pos = get_mouse_world_position_on_plane(1.0)
	if mouse_world_pos != null and mouse_world_pos != Vector3.ZERO:
		# Make marker3d follow mouse position on the plane
		marker_3d.global_transform.origin = mouse_world_pos

		var look_dir = mouse_world_pos - global_transform.origin
		look_dir.y = 0
		if look_dir.length() > 0.01:
			var target_yaw = atan2(look_dir.x, look_dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, rotation_speed * delta)
	velocity.y -= gravity * delta
	move_and_slide()

func get_mouse_world_position_on_plane(y: float) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return Vector3.ZERO

	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)

	if abs(ray_dir.y) < 0.001:
		return Vector3.ZERO

	var t = (y - ray_origin.y) / ray_dir.y
	if t < 0:
		return Vector3.ZERO
	return ray_origin + ray_dir * t

	
