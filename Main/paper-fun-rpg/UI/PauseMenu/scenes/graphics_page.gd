extends Control

@onready var fullscreen_button = $FullscreenButton
@onready var windowed_button = $WindowedButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	windowed_button.pressed.connect(_on_windowed_pressed)

func _on_fullscreen_pressed() -> void:
	SettingsManager.set_window_mode("fullscreen")

func _on_windowed_pressed() -> void:
	SettingsManager.set_window_mode("windowed")
