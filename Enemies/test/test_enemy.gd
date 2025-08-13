extends CharacterBody3D

const DAMAGE_POPUP_CRIT = preload("res://Enemies/damage_popup_crit.tscn")
const DAMAGE_POPUP = preload("res://Enemies/damage_popup.tscn")
@export var damage: float = 5.0
@export var speed: float = 5.0
@export var maxhp: float = 15
var currhp
var base
var player
var in_range = false

func _ready():
	currhp = maxhp
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	base = get_tree().get_first_node_in_group("base")

func _process(delta):
	velocity.y -= ProjectSettings.get("physics/2d/default_gravity") * delta
	move_and_slide()

func take_dmg(amount):
	var final_damage = amount
	var is_crit = false
	
	if randf() <= player.crit_chance:
		is_crit = true
		final_damage *= 1.5
	spawn_damage_popup(final_damage, is_crit)
	AudioManager.play_sound("res://Enemies/test/enemyhit_sfx.wav", "SFX", 75.0)
	if currhp - amount <= 0.0:
		#TODO switch with death anim then queue free
		WaveState.enemy_killed()
		queue_free()
		player.scrap += randi_range(2, 4)
	else:
		currhp -= amount

func spawn_damage_popup(amount, crit_hit):
	if crit_hit:
		var popup = DAMAGE_POPUP_CRIT.instantiate()
		get_tree().current_scene.add_child(popup)
		popup.set_damage(amount)
		popup.global_transform.origin = global_transform.origin + Vector3(0, 2, 0)
	else:
		var popup = DAMAGE_POPUP.instantiate()
		get_tree().current_scene.add_child(popup)
		popup.set_damage(amount)
		popup.global_transform.origin = global_transform.origin + Vector3(0, 2, 0)
