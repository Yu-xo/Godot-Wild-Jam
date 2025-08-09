extends State

@onready var player = $"../.."

func Enter():
	print("idle entered")
	player.velocity = Vector3.ZERO
	
func Exit():
	pass
	
func Update(delta):
	var move_vector = Input.get_vector("backward", "forward", "left", "right")
	if move_vector.length() > 0:
		Transitioned.emit(self, "walking")
	
