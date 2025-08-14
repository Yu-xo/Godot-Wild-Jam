extends CanvasLayer

@onready var progress_bar = %ProgressBar
@onready var control = $Control
@onready var scrap_count = %ScrapCount
@onready var wave_count =%WaveCount
@onready var exiting = %Exiting
var cage
var player
var fading_in := true
var exit_hold_time := 0.0
var exit_duration := 2.5

func _ready():
	cage = get_tree().get_first_node_in_group("base")
	player = get_tree().get_first_node_in_group("player")
	control.modulate = Color(1, 1, 1, 0)
	if WaveState.current_wave < 1:
		WaveState.start_wave(1)

func _process(delta):
	if cage:
		progress_bar.max_value = cage.maxhp
		progress_bar.value = cage.currhp
	if player:
		scrap_count.text = str(player.scrap)
	wave_count.text = str("Wave ", WaveState.current_wave)
	if fading_in:
		control.modulate = control.modulate.lerp(Color(1, 1, 1, 1), delta * 2)
		if control.modulate.a > 0.99:
			control.modulate = Color(1, 1, 1, 1)
			fading_in = false
	if Input.is_action_pressed("Quit"):
		exit_hold_time += delta
		var alpha = clamp(exit_hold_time / exit_duration, 0.0, 1.0)
		exiting.modulate = exiting.modulate.lerp(Color(1, 1, 1, alpha), delta * 8)
		if exit_hold_time >= exit_duration:
			get_tree().quit()
	else:
		exit_hold_time = 0.0
		exiting.modulate = exiting.modulate.lerp(Color(1, 1, 1, 0), delta * 8)
