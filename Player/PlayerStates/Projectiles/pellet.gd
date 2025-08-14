extends Node3D
@export var damage = 5.0
@export var speed = 15.0
@export var lifetime = 5.0
@export var projectile_sfx: String
@export var volume = 100.0
@export var spin_speed = 360.0
var velocity = Vector3.ZERO
var life_timer = 0.0

func _ready():
	AudioManager.play_sound(projectile_sfx, "SFX", volume)
	life_timer = lifetime

func _process(delta):
	if velocity != Vector3.ZERO:
		global_position += velocity * delta
	life_timer -= delta
	rotate_z(-deg_to_rad(spin_speed) * delta)
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
