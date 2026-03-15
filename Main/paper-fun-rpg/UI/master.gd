extends Node

const SCENE_TEST1 = "res://Dimensions/dimension_culture.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_f2"):
		get_tree().change_scene_to_file(SCENE_TEST1)

func toggle_fullscreen() -> void:
	var current_mode := DisplayServer.window_get_mode()

	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
