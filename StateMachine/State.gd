extends Node
class_name State

signal Transitioned

# on State entered
func Enter():
	pass
	
	
# on State exited
func Exit():
	pass
	
# variable updates
func Update(_delta: float):
	pass
	
# physics updates
func Physics_Update(_delta: float):
	pass
