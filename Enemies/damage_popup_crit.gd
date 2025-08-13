extends Node3D
@export var lifetime := 0.8
@export var float_speed := 1.0
@export var fade_in_time := 0.15
@export var horizontal_drift := 0.5 
@export var start_font_size := 200
@export var max_font_size := 450
@onready var label = $Label3D
var velocity := Vector3.ZERO
var elapsed := 0.0

func _ready():
	label.modulate.a = 0.0
	label.font_size = start_font_size
	var random_x = randf_range(-horizontal_drift, horizontal_drift)
	var random_z = randf_range(-horizontal_drift, horizontal_drift)
	velocity = Vector3(random_x, float_speed, random_z)

func _process(delta):
	elapsed += delta
	translate(velocity * delta)
	velocity.y -= delta
	
	var t = min(1.0, (elapsed / lifetime) * 2.0)
	var size_progress = 1.0 - pow(2.0, -10.0 * t)
	label.font_size = lerp(start_font_size, max_font_size, size_progress)
	
	if elapsed < fade_in_time:
		label.modulate.a = elapsed / fade_in_time
	else:
		var fade_out_start = lifetime - fade_in_time
		if elapsed > fade_out_start:
			label.modulate.a = max(0.0, (lifetime - elapsed) / fade_in_time)
	
	if elapsed >= lifetime:
		queue_free()

func set_damage(amount: float, is_crit: bool = false):
	if label == null:
		label = $Label3D
	label.text = str(int(amount))
