extends Node

const SETTINGS_PATH := "user://settings.cfg"

var master_volume: float = 1.0
var master_muted: bool = false
var window_mode: String = "windowed"

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)

	if err != OK:
		save_settings()
		return

	master_volume = float(config.get_value("audio", "master_volume", 1.0))
	master_muted = bool(config.get_value("audio", "master_muted", false))
	window_mode = str(config.get_value("graphics", "window_mode", "windowed"))

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "master_muted", master_muted)
	config.set_value("graphics", "window_mode", window_mode)
	config.save(SETTINGS_PATH)

func apply_settings() -> void:
	var master_bus_index := AudioServer.get_bus_index("Master")

	var db := linear_to_db(master_volume)
	if master_volume <= 0.001:
		db = -80.0

	AudioServer.set_bus_volume_db(master_bus_index, db)
	AudioServer.set_bus_mute(master_bus_index, master_muted)

	if window_mode == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	if master_volume > 0.001:
		master_muted = false
	apply_settings()
	save_settings()

func set_master_muted(value: bool) -> void:
	master_muted = value
	apply_settings()
	save_settings()

func set_window_mode(mode: String) -> void:
	window_mode = mode
	apply_settings()
	save_settings()

func toggle_fullscreen() -> void:
	if window_mode == "fullscreen":
		set_window_mode("windowed")
	else:
		set_window_mode("fullscreen")
