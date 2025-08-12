extends Node

@export var maxhp: float = 500.0
@export var currhp: float = 500.0
@export var water_feeder_turret: PackedScene
@onready var water_feeder_spawn = $WaterFeederSpawn

const DAMAGE_POPUP = preload("res://Enemies/damage_popup.tscn")
var turret_spawned = false

func take_dmg(amount: float):
	if currhp - amount <= 0.0:
		queue_free()
		pass #TODO: reset game on loss
	else:
		currhp -= amount


func _on_area_3d_body_entered(body):
	body.in_range = true

func _process(delta):
	if UpgradeState.has_upgrade("Water Feeder Turret") && not turret_spawned:
		var turret = water_feeder_turret.instantiate()
		water_feeder_spawn.add_child(turret)
		turret_spawned = true
