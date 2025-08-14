extends Node

@export var maxhp: float = 500.0
@export var currhp: float = 500.0
@export var water_feeder_turret: PackedScene
@export var pellet_feeder_turret: PackedScene
@export var rocket_scene: PackedScene
@onready var water_feeder_spawn = $WaterFeederSpawn
@onready var pellet_feeder_spawn = $FeederSpawn
@onready var rocket_spawn = $RocketSpawn

const DAMAGE_POPUP = preload("res://Enemies/damage_popup.tscn")
var water_turret_spawned = false
var feeder_turret_spawned = false
var rocket_spawned = false

func take_dmg(amount: float):
	if currhp - amount <= 0.0:
		queue_free()
		get_tree().reload_current_scene()
		pass #TODO: reset game on loss
	else:
		currhp -= amount

func _process(delta):
	if UpgradeState.has_upgrade("Water Feeder Turret") && not water_turret_spawned:
		var turret = water_feeder_turret.instantiate()
		water_feeder_spawn.add_child(turret)
		water_turret_spawned = true
	if UpgradeState.has_upgrade("Pellet Feeder Turret") && not feeder_turret_spawned:
		var turret = pellet_feeder_turret.instantiate()
		pellet_feeder_spawn.add_child(turret)
		feeder_turret_spawned = true
	if UpgradeState.has_upgrade("Firework Rocket") && not rocket_spawned:
		var rocket = rocket_scene.instantiate()
		rocket_spawn.add_child(rocket)
		rocket_spawned = true


func _on_area_3d_body_entered(body):
	if body.is_in_group("enemy"):
		body.in_range = true
