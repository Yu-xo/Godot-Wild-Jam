extends Node3D

@export var sway_amount: float = 0.1
@export var sway_speed: float = 5.0 
@export var sway_limit: float = 0.1
@onready var phantom_camera_host = $Camera3D/PhantomCameraHost
@onready var game_view_cam = $"../GameViewCam"

var target_offset := Vector3.ZERO
var default_position := Vector3.ZERO
var current_cam
var player
func _ready():
	player = get_tree().get_first_node_in_group("player")
	current_cam = phantom_camera_host.get_active_pcam()
	default_position = current_cam.position
	await get_tree().create_timer(4.0).timeout
	# below just for testing, change this to be when play is pressed
	game_view_cam.priority = 2
	

func _process(delta):
	var switched_cam := false

	if game_view_cam.is_active() && not player.canMove:
		current_cam = phantom_camera_host.get_active_pcam()
		default_position = current_cam.position
		target_offset = Vector3.ZERO
		switched_cam = true
		await get_tree().create_timer(game_view_cam.tween_duration).timeout
		player.canMove = true
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	mouse_pos.x = clamp(mouse_pos.x, 0.0, viewport_size.x)
	mouse_pos.y = clamp(mouse_pos.y, 0.0, viewport_size.y)

	var offset_x = ((mouse_pos.x / viewport_size.x) - 0.5) * 2
	var offset_y = ((mouse_pos.y / viewport_size.y) - 0.5) * 2

	target_offset.x = clamp(offset_x * sway_amount, -sway_limit, sway_limit)
	target_offset.y = clamp(-offset_y * sway_amount, -sway_limit, sway_limit)

	if not switched_cam:
		current_cam.position = current_cam.position.lerp(default_position + target_offset, delta * sway_speed)
	else:
		current_cam.position = default_position
