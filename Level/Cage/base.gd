extends Node

@export var maxhp: float = 500.0
@export var currhp: float = 500.0

func take_dmg(amount: float):
	if currhp - amount <= 0.0:
		queue_free()
		pass #TODO: reset game on loss
	else:
		currhp -= amount


func _on_area_3d_body_entered(body):
	body.in_range = true
