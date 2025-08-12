extends Node

@export var starting_scene: String
@export var starting_gui_scene: String
@onready var fade_control = %FadeControl
@onready var world_space = %WorldSpace
@onready var gui = %GUI
var current_3d_scene: Node
var current_gui_scene: Node

func _ready():
	SceneManager.request_3d_scene_change.connect(_handle_3d_scene_change)
	SceneManager.request_gui_scene_change.connect(_handle_gui_scene_change)
	SceneManager.request_delete_current_gui_scene.connect(_handle_delete_current_gui_scene)
	await get_tree().process_frame
	SceneManager.change_3d_scene(starting_scene, true)
	SceneManager.change_gui_scene(starting_gui_scene)
	
func _handle_3d_scene_change(scene_path: String, skip_fade_out: bool = false) -> void:
	fade_control.visible = true
	var current_scene_path = current_3d_scene.scene_file_path if current_3d_scene else ""
	
	if not skip_fade_out:
		await get_tree().process_frame
		await fade_control.fade_out()
	
	if current_3d_scene:
		current_3d_scene.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	world_space.call_deferred("add_child", new_scene)
	current_3d_scene = new_scene
	
	await fade_control.fade_in()


func _handle_gui_scene_change(scene_path: String) -> void:
	if current_gui_scene:
		current_gui_scene.queue_free()
		
	var new_gui_scene = load(scene_path).instantiate()
	gui.add_child(new_gui_scene)
	current_gui_scene = new_gui_scene
	
func _handle_delete_current_gui_scene() -> void:
	for children in gui.get_children():
		children.queue_free()
