extends Control

@onready var mute_button = $MuteButton
@onready var master_slider = $MasterSlider
@onready var volume_label = $VolumeLabel

var master_bus_index: int
var is_muted: bool = false
var previous_volume_linear: float = 1.0

func _ready() -> void:
	master_bus_index = AudioServer.get_bus_index("Master")

	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step = 0.01

	var current_db := AudioServer.get_bus_volume_db(master_bus_index)
	var current_linear := db_to_linear(current_db)

	master_slider.value = current_linear
	_update_volume_label(current_linear)

	mute_button.pressed.connect(_on_mute_pressed)
	master_slider.value_changed.connect(_on_master_slider_changed)

func _on_master_slider_changed(value: float) -> void:
	var db := linear_to_db(value)

	if value <= 0.001:
		db = -80.0

	AudioServer.set_bus_volume_db(master_bus_index, db)

	if value > 0.001:
		AudioServer.set_bus_mute(master_bus_index, false)
		is_muted = false
		previous_volume_linear = value

	_update_volume_label(value)

func _on_mute_pressed() -> void:
	is_muted = !is_muted
	AudioServer.set_bus_mute(master_bus_index, is_muted)

	if is_muted:
		previous_volume_linear = master_slider.value
		volume_label.text = "Master Volume: Muted"
	else:
		volume_label.text = "Master Volume: %d%%" % int(master_slider.value * 100)

func _update_volume_label(value: float) -> void:
	volume_label.text = "Master Volume: %d%%" % int(value * 100)
