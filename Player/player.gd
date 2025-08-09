extends CharacterBody3D

@onready var collision_shape = $CollisionShape3D
@onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
@export var speed: float

var canMove = true

func _ready(): 
	canMove = false # player starts of not able to move because it's in the main menu screen
	#TODO: make it so the player can start moving once the play button is pressed
	
func _process(delta):
	velocity.y -= gravity * delta
	move_and_slide()
