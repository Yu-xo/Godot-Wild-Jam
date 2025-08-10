extends CharacterBody3D

@onready var collision_shape = $CollisionShape3D
@onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
@onready var marker_3d = $Marker3D

@export var speed: float
var rotation_speed = 10.0
var canMove = false
var menu_camera
var just_swapped_cams = false
var allow_marker_move = false

func _ready(): 
	canMove = false
	menu_camera = get_tree().get_first_node_in_group("menucam")

func _process(delta):
	var mouse_world_pos = get_mouse_world_position_on_plane(1.0)

	if mouse_world_pos != null and mouse_world_pos != Vector3.ZERO:
		if menu_camera and not menu_camera.is_active():
			# Detect first time swap happens
			if not just_swapped_cams:
				just_swapped_cams = true
				allow_marker_move = false
				start_marker_delay()

			# Only move marker after delay
			if allow_marker_move:
				marker_3d.global_transform.origin = mouse_world_pos

				var look_dir = mouse_world_pos - global_transform.origin
				look_dir.y = 0
				if look_dir.length() > 0.01:
					var target_yaw = atan2(look_dir.x, look_dir.z)
					rotation.y = lerp_angle(rotation.y, target_yaw, rotation_speed * delta)
	velocity.y -= gravity * delta
	move_and_slide()

func start_marker_delay() -> void:
	await get_tree().create_timer(0.5).timeout
	allow_marker_move = true

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
