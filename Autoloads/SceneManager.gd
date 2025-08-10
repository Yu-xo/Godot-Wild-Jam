extends Node
 
signal request_3d_scene_change(scene_path: String, skip_fade_out)
signal request_gui_scene_change(scene_path: String)
signal request_delete_current_gui_scene()
signal request_add_gui_scene(scene_path: String)

# Just forwards requests via signals
func change_3d_scene(scene_path: String, skip_fade_out: bool = false) -> void:
	emit_signal("request_3d_scene_change", scene_path, skip_fade_out)

func change_gui_scene(scene_path: String) -> void:
	emit_signal("request_gui_scene_change", scene_path)

func delete_current_gui_scene() -> void:
	emit_signal("request_delete_current_gui_scene")

func add_gui_scene(scene_path: String) -> void:
	emit_signal("request_add_gui_scene")
