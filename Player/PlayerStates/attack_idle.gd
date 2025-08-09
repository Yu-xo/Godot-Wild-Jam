extends State

func Enter():
	pass
	
func Exit(): 
	pass
	
func Update(delta):
	if Input.is_action_pressed("attack"):
		Transitioned.emit(self, "attacking")
