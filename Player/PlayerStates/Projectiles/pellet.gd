extends Node3D
@export var damage = 5.0
@export var speed = 15.0
@export var lifetime = 5.0  # How long before pellet disappears

var velocity = Vector3.ZERO
var life_timer = 0.0

func _ready():
	life_timer = lifetime

func _process(delta):
	# Move the pellet
	if velocity != Vector3.ZERO:
		global_position += velocity * delta
	velocity.y -= ProjectSettings.get("physics/3d/default_gravity") * delta
	# Handle lifetime
	life_timer -= delta
	if life_timer <= 0:
		queue_free()

func set_velocity(new_velocity: Vector3):
	velocity = new_velocity

func set_damage(new_damage: float):
	damage = new_damage

func _on_area_3d_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_dmg(damage)
		queue_free()


func _on_area_3d_area_entered(area):
	if area.is_in_group("floor"):
		queue_free()
