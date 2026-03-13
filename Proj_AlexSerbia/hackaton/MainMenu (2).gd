extends Control

# ── Schimbă cu path-ul scenei tale de joc ──
const GAME_SCENE := "res://Game.tscn"

func _ready() -> void:
	$VBox/PlayButton.pressed.connect(_on_play_pressed)
	$VBox/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
