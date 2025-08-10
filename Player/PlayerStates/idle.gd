extends State

@onready var player = $"../.."
@onready var animation_player = $"../../hamster/AnimationPlayer"

func Enter():
	animation_player.play("Idle", 0.1)
	player.velocity = Vector3.ZERO
	
func Exit():
	pass
	
func Update(delta):
	var move_vector = Input.get_vector("backward", "forward", "left", "right")
	if player.canMove:
		if move_vector.length() > 0:
			Transitioned.emit(self, "walking")
