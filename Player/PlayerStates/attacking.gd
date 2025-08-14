extends State
@onready var player = $"../.."

# Weapon progression system
enum WeaponType { THROWING, SLINGSHOT, BOW }
@export var current_weapon: WeaponType = WeaponType.THROWING

# Base weapon stats
@export var base_throw_force: float = 15.0
@export var base_throw_height: float = 2.0
@export var base_attack_cooldown: float = 0.5

# Projectile scenes for different weapon types
@export var pellet_scene: PackedScene
@export var slingshot_pellet_scene: PackedScene
@export var toothpick_arrow_scene: PackedScene

var cooldown_timer: float = 0.0
var is_attacking: bool = false

# Weapon stats and progression
var weapon_stats = {
	WeaponType.THROWING: {
		"name": "Thrown Pellets",
		"cooldown_multiplier": 1.0,
		"force_multiplier": 1.0,
		"height_multiplier": 1.0,
		"damage": 5.0,
		"projectile_scene": "pellet"
	},
	WeaponType.SLINGSHOT: {
		"name": "Pellet Slingshot",
		"cooldown_multiplier": 0.9,
		"force_multiplier": 1.1,
		"height_multiplier": 0.9,
		"damage": 8.0,
		"projectile_scene": "slingshot_pellet"
	},
	WeaponType.BOW: {
		"name": "Toothpick Bow",
		"cooldown_multiplier": 0.8,
		"force_multiplier": 3.0,
		"height_multiplier": 0.7,
		"damage": 6.0,
		"projectile_scene": "toothpick"
	}
}

func Enter():
	is_attacking = true
	
func Exit():
	is_attacking = false
	
func Update(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
		
	current_weapon = get_weapon_from_upgrades()
	
	if Input.is_action_pressed("attack") and cooldown_timer <= 0 and is_attacking && player.canMove:
		fire_projectile()
		var stats = weapon_stats[current_weapon]
		cooldown_timer = base_attack_cooldown * stats["cooldown_multiplier"]

func get_weapon_from_upgrades() -> WeaponType:
	if UpgradeState.has_upgrade("Toothpick Bow"):
		return WeaponType.BOW
	elif UpgradeState.has_upgrade("Twig Slingshot"):
		return WeaponType.SLINGSHOT
	else:
		return WeaponType.THROWING
		
func fire_projectile():
	var stats = weapon_stats[current_weapon]
	
	var projectile = get_projectile_scene().instantiate()
	if not projectile:
		print("No projectile scene available for ", stats["name"])
		return
		
	get_tree().current_scene.add_child(projectile)
	
	var fire_origin = get_fire_origin()
	projectile.global_position = fire_origin
	
	var marker = player.marker_3d
	if marker:
		var direction = (marker.global_position - fire_origin).normalized()
		apply_projectile_physics(projectile, direction, stats)
	
	play_weapon_effects()

func get_fire_origin() -> Vector3:
	var base_pos = player.global_position + Vector3(0, 1.0, 0)
	
	match current_weapon:
		WeaponType.THROWING:
			return base_pos + Vector3(0, 3.0, 0)  # Slightly higher for throwing
		WeaponType.SLINGSHOT:
			return base_pos + Vector3(0, 2.5, 0.3)
		WeaponType.BOW:
			return base_pos + Vector3(0, 1.0, 0.5)
	
	return base_pos

func get_projectile_scene() -> PackedScene:
	match current_weapon:
		WeaponType.THROWING:
			return pellet_scene
		WeaponType.SLINGSHOT:
			return slingshot_pellet_scene if slingshot_pellet_scene else pellet_scene
		WeaponType.BOW:
			return toothpick_arrow_scene if toothpick_arrow_scene else pellet_scene
	
	return pellet_scene

func apply_projectile_physics(projectile, direction: Vector3, stats: Dictionary):
	if projectile.has_method("set_velocity"):
		var force = base_throw_force * stats["force_multiplier"]
		projectile.set_velocity(direction * force)

func play_weapon_effects():
	match current_weapon:
		WeaponType.THROWING:
			pass
			#AudioManager.play_sound("res://Player/SFX/throw_pellet.wav")
		
		WeaponType.SLINGSHOT:
			pass
			#AudioManager.play_sound("res://Player/SFX/slingshot_fire.wav")
			# slingshot anim
		
		WeaponType.BOW:
			pass
			#AudioManager.play_sound("res://Player/SFX/bow_release.wav")
			# bow anim

# weapon upgrades
func upgrade_to_slingshot():
	if current_weapon == WeaponType.THROWING:
		current_weapon = WeaponType.SLINGSHOT
		print("Upgraded to Pellet Slingshot!")
		return true
	return false

func upgrade_to_bow():
	if current_weapon == WeaponType.SLINGSHOT:
		current_weapon = WeaponType.BOW
		print("Upgraded to Toothpick Bow!")
		return true
	return false

func get_current_weapon_info() -> Dictionary:
	var stats = weapon_stats[current_weapon]
	return {
		"name": stats["name"],
		"damage": stats["damage"],
		"fire_rate": 1.0 / (base_attack_cooldown * stats["cooldown_multiplier"])
	}

func get_next_upgrade() -> String:
	match current_weapon:
		WeaponType.THROWING:
			return "Pellet Slingshot - Higher damage and faster firing!"
		WeaponType.SLINGSHOT:
			return "Toothpick Bow - Maximum damage and fire rate!"
		WeaponType.BOW:
			return "Maximum upgrade reached!"
	return ""

func can_upgrade() -> bool:
	return current_weapon != WeaponType.BOW # last weapon for now?

func get_weapon_level() -> int:
	return int(current_weapon) + 1
