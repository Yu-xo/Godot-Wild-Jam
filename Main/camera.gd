extends Camera3D

@export var sway_amount: float = 0.1 
@export var sway_speed: float = 5.0 

var target_offset := Vector3.ZERO
var default_position := Vector3.ZERO

func _ready():
	default_position = position

func _process(delta):
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	var offset_x = ((mouse_pos.x / viewport_size.x) - 0.5) * 2
	var offset_y = ((mouse_pos.y / viewport_size.y) - 0.5) * 2

	target_offset.x = -offset_x * sway_amount
	target_offset.y = offset_y * sway_amount

	position = position.lerp(default_position + target_offset, delta * sway_speed)
