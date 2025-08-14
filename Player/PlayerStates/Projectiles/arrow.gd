extends Node3D

@export var damage = 5.0
@export var speed = 15.0
@export var lifetime = 5.0
@export var projectile_sfx: String
@export var volume = 100.0

var velocity = Vector3.ZERO
var life_timer = 0.0
var enemies_hit = 0
var player_marker: Node3D
var player

func _ready():
	AudioManager.play_sound(projectile_sfx, "SFX", volume)
	life_timer = lifetime
	var original_scale = scale
	player = get_tree().get_first_node_in_group("player")
	var forward = player.global_transform.basis.z.normalized()
	look_at(global_position + forward, Vector3.UP)
	rotate_y(deg_to_rad(90))

func _process(delta):
	if velocity != Vector3.ZERO:
		global_position += velocity * delta
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
		enemies_hit += 1
		if enemies_hit >= 3:
			queue_free()

func _on_area_3d_area_entered(area):
	if area.is_in_group("floor"):
		queue_free()
