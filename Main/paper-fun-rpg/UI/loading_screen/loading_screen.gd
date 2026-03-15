extends Control

const MIN_LOADING_TIME: float = 3.0
const MAX_LOADING_TIME: float = 7.0
const TIP_CHANGE_TIME: float = 2.0

@onready var progress_bar: ProgressBar = $BottomPanelButton/MarginContainer/VBoxContainer/TipPanel/ProgressBar
@onready var loading_label: Label = $LoadingLabel
@onready var tip_label: Label = $BottomPanelButton/MarginContainer/VBoxContainer/TipPanel/TipLabel
@onready var bottom_panel_button: Button = $BottomPanelButton

var progress_value: float = 0.0
var elapsed_time: float = 0.0
var tip_timer: float = 0.0
var current_tip_index: int = -1
var tips: Array[String] = []
var total_loading_time: float = 5.0

func _ready() -> void:
	print("READY")
	randomize()

	total_loading_time = randf_range(MIN_LOADING_TIME, MAX_LOADING_TIME)

	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0

	tips = preload("res://UI/loading_screen/tips_data.gd").TIPS

	loading_label.text = "Loading... 0%"
	_show_initial_tip()

	bottom_panel_button.pressed.connect(_on_bottom_panel_pressed)

func _process(delta: float) -> void:
	elapsed_time += delta
	tip_timer += delta

	progress_value = clamp((elapsed_time / total_loading_time) * 100.0, 0.0, 100.0)
	progress_bar.value = progress_value
	loading_label.text = "Loading... %d%%" % int(progress_value)

	if tip_timer >= TIP_CHANGE_TIME:
		tip_timer = 0.0
		_show_next_tip()

	if elapsed_time >= total_loading_time:
		progress_bar.value = 100
		loading_label.text = "Loading... 100%"

		if TransitionManager.target_scene_path != "":
			var next_scene: String = TransitionManager.target_scene_path
			TransitionManager.target_scene_path = ""
			get_tree().change_scene_to_file(next_scene)

func _show_initial_tip() -> void:
	if tips.is_empty():
		tip_label.text = ""
		return

	current_tip_index = _get_random_tip_index(-1)
	tip_label.text = tips[current_tip_index]

func _show_next_tip() -> void:
	if tips.is_empty():
		tip_label.text = ""
		return

	current_tip_index = _get_random_tip_index(current_tip_index)
	tip_label.text = tips[current_tip_index]

func _get_random_tip_index(previous_index: int) -> int:
	if tips.size() == 1:
		return 0

	var new_index: int = randi_range(0, tips.size() - 1)

	while new_index == previous_index:
		new_index = randi_range(0, tips.size() - 1)

	return new_index

func _on_bottom_panel_pressed() -> void:
	_show_next_tip()
	get_viewport().set_input_as_handled()
