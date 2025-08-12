extends CanvasLayer

@onready var progress_bar = %ProgressBar
@onready var control = $Control
var cage

var fading_in := true

func _ready():
	cage = get_tree().get_first_node_in_group("base")
	control.modulate = Color(1, 1, 1, 0)
	if WaveState.current_wave < 1:
		WaveState.start_wave(1)

func _process(delta):
	if cage:
		progress_bar.max_value = cage.maxhp
		progress_bar.value = cage.currhp

	if fading_in:
		control.modulate = control.modulate.lerp(Color(1, 1, 1, 1), delta * 2)
		if control.modulate.a > 0.99:
			control.modulate = Color(1, 1, 1, 1)
			fading_in = false
