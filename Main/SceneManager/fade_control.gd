extends CanvasLayer

@onready var anim_player = $AnimationPlayer

func fade_out() -> void:
	anim_player.play("fade_out")
	await anim_player.animation_finished

func fade_in() -> void:
	anim_player.play("fade_in")
	await anim_player.animation_finished
