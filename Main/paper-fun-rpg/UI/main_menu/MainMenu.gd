extends Control

const GAME_SCENE = "res://Game.tscn"

func _ready() -> void:
	await get_tree().process_frame
	
	$CenterContainer/PlayButton.text = "▶  Play"
	$CenterContainer/QuitButton.text = "✕  Quit"
	
	$CenterContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	$CenterContainer/PlayButton.mouse_entered.connect(_on_play_hover)
	$CenterContainer/QuitButton.mouse_entered.connect(_on_quit_hover)
	$CenterContainer/PlayButton.mouse_exited.connect(_on_play_unhover)
	$CenterContainer/QuitButton.mouse_exited.connect(_on_quit_unhover)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_hover() -> void:
	$CenterContainer/PlayButton.text = "▶  Play  →"

func _on_play_unhover() -> void:
	$CenterContainer/PlayButton.text = "▶  Play"

func _on_quit_hover() -> void:
	$CenterContainer/QuitButton.text = "✕  Quit  →"

func _on_quit_unhover() -> void:
	$CenterContainer/QuitButton.text = "✕  Quit"
