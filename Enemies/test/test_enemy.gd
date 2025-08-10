extends CharacterBody3D

const DAMAGE_POPUP = preload("res://Enemies/damage_popup.tscn")
@export var damage: float = 5.0
@export var speed: float = 5.0
@export var maxhp: float = 15
var currhp
var base
var in_range = false

func _ready():
	currhp = maxhp
	await get_tree().process_frame
	base = get_tree().get_first_node_in_group("base")

func _process(delta):
	velocity.y -= ProjectSettings.get("physics/2d/default_gravity")
	move_and_slide()

func take_dmg(amount):
	spawn_damage_popup(amount)
	if currhp - amount <= 0.0:
		#TODO switch with death anim then queue free
		queue_free()
	else:
		currhp -= amount

func spawn_damage_popup(amount):
	var popup = DAMAGE_POPUP.instantiate()
	popup.global_transform.origin = global_transform.origin + Vector3(0, 3, 0)
	popup.set_damage(amount)
	get_tree().current_scene.add_child(popup)
