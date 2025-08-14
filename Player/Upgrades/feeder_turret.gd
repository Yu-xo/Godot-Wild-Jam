extends Node3D

@export var shooting_range := 20.0
@export var rotation_speed := 5.0
@export var fire_rate := 1.0
@export var bullet_scene: PackedScene
@export var scrap_popup: PackedScene
@export var build_cost := 100
@export var scrap_feed_rate := 0.2
var build_progress := 0
var is_built := false

@onready var mesh = $mesh
@onready var nearby = $mesh/nearby

var current_target: Node3D = null
var enemies := []
var fire_timer := 0.0
var player
var scrap_timer := 0.0

# Pellet shooting vars
@export var pellet_speed := 20.0
@export var pellet_damage := 3.0
@export var angle_step := 45.0

var pellet_rotation_angle := 0.0

# SFX
var tick_sfx = "res://Player/Upgrades/barley_talksfx.wav"
var deposit_pitch := 1.0
var pitch_step := 0.05

func _ready():
	_update_transparency()

func _process(delta):
	if player and not is_built:
		scrap_timer -= delta
		if Input.is_action_pressed("Interact") and scrap_timer <= 0.0:
			deposit_scrap(1, player)
			scrap_timer = scrap_feed_rate
		if Input.is_action_just_released("Interact"):
			deposit_pitch = 1.0

	if not is_built:
		return

	_update_enemies()
	_select_target()
	
	if current_target:
		_aim_at_target(delta)
		_try_shoot(delta)
		
	pellet_rotation_angle += deg_to_rad(rotation_speed) * delta
	
# ---------------------
# Scrap/building logic
# ---------------------
func deposit_scrap(amount: int, player_in_range):
	if is_built:
		player.hide_interact_button()
		nearby.hide()
		return
	if player.scrap <= 0:
		return

	var give_amount = min(amount, player_in_range.scrap, build_cost - build_progress)
	player_in_range.scrap -= give_amount
	build_progress += give_amount
	player.toggle_interact_button()
	if scrap_popup:
		var popup_instance = scrap_popup.instantiate()
		add_child(popup_instance)

		popup_instance.global_transform.origin = global_transform.origin + Vector3(-5, 2, 0)
		var random_offset = Vector3(
			randf_range(-4, 4), 
			0, 
			randf_range(-4, 4)
		)
		popup_instance.global_position = global_position + Vector3(0, 2, 0) + random_offset
		
		var label = popup_instance.get_node("Label3D") if popup_instance.has_node("Label3D") else null
		if label:
			label.text = str(build_progress) + " / " + str(build_cost)
	
	if AudioManager.has_method("play_sound"):
		AudioManager.play_sound(tick_sfx, "SFX", 100.0, deposit_pitch)
	deposit_pitch += pitch_step

	_update_transparency()

	if build_progress >= build_cost:
		_finish_build()

func _update_transparency():
	if mesh.material_override and mesh.material_override is BaseMaterial3D:
		var mat := mesh.material_override as BaseMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.flags_transparent = true
		mat.albedo_color.a = clamp(float(build_progress) / float(build_cost), 0.0, 1.0)

func _finish_build():
	is_built = true
	build_progress = build_cost
	mesh.get_surface_override_material(0).albedo_color.a = 1.0
	_update_transparency()

# ---------------------
# Targeting/shooting
# ---------------------
func _update_enemies():
	enemies = get_tree().get_nodes_in_group("enemy")

func _select_target():
	if current_target and (not current_target.is_inside_tree() or current_target.currhp <= 0):
		current_target = null

	if current_target == null and enemies.size() > 0:
		var closest_dist = shooting_range + 1.0
		var closest_enemy = null
		for enemy in enemies:
			if not enemy.is_inside_tree():
				continue
			if enemy.currhp <= 0:
				continue
			var dist = global_transform.origin.distance_to(enemy.global_transform.origin)
			if dist < closest_dist and dist <= shooting_range:
				closest_dist = dist
				closest_enemy = enemy
		
		current_target = closest_enemy

func _aim_at_target(delta):
	if not current_target:
		return
	var to_target = current_target.global_transform.origin - global_transform.origin
	to_target.y = 0  # horizontal rotation only
	to_target = to_target.normalized()
	
	var target_rotation_y = atan2(to_target.x, to_target.z)
	var current_rotation_y = rotation.y
	rotation.y = lerp_angle(current_rotation_y, target_rotation_y, rotation_speed * delta)

func _try_shoot(delta):
	fire_timer -= delta
	if fire_timer <= 0.0:
		fire_timer = 1.0 / fire_rate
		_shoot_pellets()
		
func _shoot_pellets():
	if bullet_scene == null:
		print("No bullet scene assigned!")
		return
	var rotation_offset = randf_range(0.0, 360.0)
	for i in range(0, 15):
		var pellet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(pellet)
		pellet.global_transform.origin = mesh.global_transform.origin

		var angle_rad = deg_to_rad(rotation_offset + (i * angle_step))
		var local_dir = Vector3(sin(angle_rad), 0, cos(angle_rad)).normalized()
		var world_dir = mesh.global_transform.basis * local_dir

		if pellet.has_method("set_velocity"):
			pellet.set_velocity(world_dir * pellet_speed)
		if pellet.has_method("set_damage"):
			pellet.set_damage(pellet_damage)
		pellet.look_at(pellet.global_transform.origin + world_dir, Vector3.UP)
		await get_tree().create_timer(0.05).timeout


func _reset_turret():
	pass

# ---------------------
# Player interaction
# ---------------------
func _on_area_3d_body_entered(body):
	if body.is_in_group("player") and not is_built:
		player = body
		player.show_interact_button()
		nearby.show()

func _on_area_3d_body_exited(body):
	if body == player:
		player.hide_interact_button()
		if not is_built:
			nearby.hide()
		player = null
