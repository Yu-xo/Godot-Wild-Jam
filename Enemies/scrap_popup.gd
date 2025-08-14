extends Area3D

@export var speed := 10.0
@export var collect_distance := 1.5
@export var arc_height := 3.0
@export var homing_strength := 8.0

@onready var scrap_popup = $".."

var amount = 1
var player: Node3D
var velocity := Vector3.ZERO

func _ready():
	player = get_tree().get_first_node_in_group("player")
	velocity.y = arc_height

func _process(delta):
	if not is_instance_valid(player):
		return

	var to_player = player.global_transform.origin - global_transform.origin
	var distance = to_player.length()

	if distance < collect_distance:
		_collect()
		return

	var dir = to_player.normalized()

	var target_velocity = dir * speed
	velocity.x = lerp(velocity.x, target_velocity.x, homing_strength * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, homing_strength * delta)

	velocity.y -= ProjectSettings.get("physics/3d/default_gravity") * delta

	global_translate(velocity * delta)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_collect()

func _collect():
	if is_instance_valid(player):
		AudioManager.play_sound("res://Enemies/scrap_collect.wav")
		player.scrap += amount
	queue_free()
