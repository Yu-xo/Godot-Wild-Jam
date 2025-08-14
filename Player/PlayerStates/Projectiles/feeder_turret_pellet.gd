extends Node3D

@export var damage = 5.0
@export var speed = 15.0
@export var lifetime = 5.0
@export var projectile_sfx: String
@export var volume = 100.0
@export var spin_speed = 360.0
@export var spread_angle := 5.0 
var velocity = Vector3.ZERO
var life_timer = 0.0

func _ready():
	AudioManager.play_sound(projectile_sfx, "SFX", volume)		
	life_timer = lifetime

func _process(delta):
	if velocity != Vector3.ZERO:
		global_position += velocity * delta
		
		var right_dir = velocity.normalized().cross(Vector3.UP).normalized()
		global_position += right_dir * 0.5 * delta
		
		rotate_y(deg_to_rad(spin_speed) * delta)
	
	life_timer -= delta
	if life_timer <= 0:
		queue_free()

func set_velocity(new_velocity: Vector3):
	var random_yaw = deg_to_rad(randf_range(-spread_angle, spread_angle))
	var random_pitch = deg_to_rad(randf_range(-spread_angle, spread_angle))
	
	var basis = Basis()
	basis = basis.rotated(Vector3.UP, random_yaw)
	basis = basis.rotated(Vector3.RIGHT, random_pitch)

	velocity = basis * new_velocity
func set_damage(new_damage: float):
	damage = new_damage

func _on_area_3d_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_dmg(damage)
		queue_free()

func _on_area_3d_area_entered(area):
	if area.is_in_group("floor"):
		queue_free()
