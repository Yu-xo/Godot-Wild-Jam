extends CharacterBody3D

@export var damage: float = 5.0
@export var speed: float = 5.0
var base
var in_range = false

func _ready():
	base = get_tree().get_first_node_in_group("base")
	
func _process(delta):
	velocity.y -= ProjectSettings.get("physics/2d/default_gravity")
