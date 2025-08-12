extends Node3D
@export var swivel_speed: float = 10.0

func _process(delta):
	if get_tree().get_first_node_in_group("player").canMove:
		if Input.is_action_just_pressed("camleft"):
			AudioManager.play_sound("res://Main/camleft.wav", "SFX", 75.0)
			var current_snapped = round(rotation.y / deg_to_rad(90.0)) * deg_to_rad(90.0)
			var target_rotation = current_snapped - deg_to_rad(90.0)
			var tween = create_tween()
			tween.tween_property(self, "rotation:y", target_rotation, 1.0/swivel_speed)
		elif Input.is_action_just_pressed("camright"):
			AudioManager.play_sound("res://Main/camright.wav", "SFX", 75.0)
			var current_snapped = round(rotation.y / deg_to_rad(90.0)) * deg_to_rad(90.0)
			var target_rotation = current_snapped + deg_to_rad(90.0)
			var tween = create_tween()
			tween.tween_property(self, "rotation:y", target_rotation, 1.0/swivel_speed)
