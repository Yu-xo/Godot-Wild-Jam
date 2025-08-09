extends Node3D

@export var swivel_speed: float = 10.0

func _process(delta):
	if Input.is_action_just_pressed("camleft"):
		var target_rotation = rotation.y - deg_to_rad(90.0)
		var tween = create_tween()
		tween.tween_property(self, "rotation:y", target_rotation, 1.0/swivel_speed)
	elif Input.is_action_just_pressed("camright"):
		var target_rotation = rotation.y + deg_to_rad(90.0)
		var tween = create_tween()
		tween.tween_property(self, "rotation:y", target_rotation, 1.0/swivel_speed)
