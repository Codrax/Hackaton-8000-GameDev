extends Node

const SETTINGS_PATH := "user://settings.cfg"

var master_volume: float = 1.0
var master_muted: bool = false
var window_mode: String = "fullscreen"
var local_llm: bool = false
var local_llm_server: String = "http://localhost:8010"

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)

	if err != OK:
		save_settings()
		return

	master_volume = float(config.get_value("audio", "master_volume", master_volume))
	master_muted = bool(config.get_value("audio", "master_muted", master_muted))
	window_mode = str(config.get_value("graphics", "window_mode", window_mode))
	local_llm = bool(config.get_value("gameplay", "local_llm", local_llm))
	local_llm_server = String(config.get_value("gameplay", "local_llm_server", local_llm_server))
	AI.useLocalLLM = local_llm
	AI.localLLMServer = String(local_llm_server)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "master_muted", master_muted)
	config.set_value("graphics", "window_mode", window_mode)
	config.set_value("gameplay", "local_llm", local_llm)
	config.set_value("gameplay", "local_llm_server", local_llm_server)
	config.save(SETTINGS_PATH)

func apply_settings() -> void:
	_apply_audio_settings()
	_apply_window_mode()

func _apply_audio_settings() -> void:
	var master_bus_index := AudioServer.get_bus_index("Master")

	var db := linear_to_db(master_volume)
	if master_volume <= 0.001:
		db = -80.0

	AudioServer.set_bus_volume_db(master_bus_index, db)
	AudioServer.set_bus_mute(master_bus_index, master_muted)

func _apply_window_mode() -> void:
	match window_mode:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280, 720))
		_:
			set_window_mode("fullscreen")

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)

	if master_volume > 0.001:
		master_muted = false

	_apply_audio_settings()
	save_settings()

func set_master_muted(value: bool) -> void:
	master_muted = value
	_apply_audio_settings()
	save_settings()

func set_window_mode(mode: String) -> void:
	if mode != "fullscreen" and mode != "windowed":
		return

	window_mode = mode
	_apply_window_mode()
	save_settings()

func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		set_window_mode("windowed")
	else:
		set_window_mode("fullscreen")
