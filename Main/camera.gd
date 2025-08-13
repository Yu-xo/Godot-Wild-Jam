extends Node3D

@export var sway_amount: float = 0.1
@export var sway_speed: float = 5.0 
@export var sway_limit: float = 0.1
@onready var phantom_camera_host = $Camera3D/PhantomCameraHost
@onready var game_view_cam = %GameViewCam

const A_HAMSTERS_RESOLVE = preload("res://Music/a hamster's resolve.wav")
var target_offset := Vector3.ZERO
var default_position := Vector3.ZERO
var current_cam
var player

var has_switched := false
var shake_offset := Vector3.ZERO
var shake_time := 0.0
var shake_intensity := 0.0
var shake_decay := 0.0

func start_screenshake(intensity: float = 1.0, duration: float = 0.5):
	shake_intensity = intensity
	shake_decay = intensity / duration
	shake_time = duration


func _ready():
	player = get_tree().get_first_node_in_group("player")
	current_cam = phantom_camera_host.get_active_pcam()
	default_position = current_cam.position

func _process(delta):
	var switched_cam := false

	if game_view_cam && game_view_cam.is_active() and not player.canMove and not has_switched:
		has_switched = true
		current_cam = phantom_camera_host.get_active_pcam()
		default_position = current_cam.position
		target_offset = Vector3.ZERO
		switched_cam = true
		await get_tree().create_timer(game_view_cam.tween_duration).timeout
		player.canMove = true
		AudioManager.play_music(A_HAMSTERS_RESOLVE, true, 0.0, 65.0)

	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	mouse_pos.x = clamp(mouse_pos.x, 0.0, viewport_size.x)
	mouse_pos.y = clamp(mouse_pos.y, 0.0, viewport_size.y)

	var offset_x = ((mouse_pos.x / viewport_size.x) - 0.5) * 2
	var offset_y = ((mouse_pos.y / viewport_size.y) - 0.5) * 2

	target_offset.x = clamp(offset_x * sway_amount, -sway_limit, sway_limit)
	target_offset.y = clamp(-offset_y * sway_amount, -sway_limit, sway_limit)

	if shake_time > 0.0:
		shake_time -= delta
		shake_offset = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			0
		) * shake_intensity
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		shake_offset = Vector3.ZERO
		
	if not switched_cam:
		current_cam.position = current_cam.position.lerp(
			default_position + target_offset + shake_offset, 
			delta * sway_speed
		)
	else:
		current_cam.position = default_position
