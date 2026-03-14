extends Control

@onready var fullscreen_button: Button = $FullscreenButton
@onready var windowed_button: Button = $WindowedButton

func _ready() -> void:
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	windowed_button.pressed.connect(_on_windowed_pressed)

func _on_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_windowed_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
