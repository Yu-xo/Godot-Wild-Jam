extends Node3D

@export var sway_amount: float = 0.1
@export var sway_speed: float = 5.0 
@export var sway_limit: float = 0.1
@onready var phantom_camera_host = $Camera3D/PhantomCameraHost

var target_offset := Vector3.ZERO
var default_position := Vector3.ZERO
var current_cam
func _ready():
	current_cam = phantom_camera_host.get_active_pcam()
	default_position = current_cam.position

func _process(delta):
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	var offset_x = ((mouse_pos.x / viewport_size.x) - 0.5) * 2
	var offset_y = ((mouse_pos.y / viewport_size.y) - 0.5) * 2

	target_offset.x = clamp(offset_x * sway_amount, -sway_limit, sway_limit)
	target_offset.y = clamp(-offset_y * sway_amount, -sway_limit, sway_limit)
	current_cam.position = current_cam.position.lerp(default_position + target_offset, delta * sway_speed)
