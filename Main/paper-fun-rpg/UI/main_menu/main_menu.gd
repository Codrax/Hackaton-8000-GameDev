extends Control

const GAME_SCENE = "res://Dimensions/dimension_hub.tscn"

var buttons: Array[Button] = []

func _ready() -> void:
	await get_tree().process_frame

	$CenterContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$CenterContainer/SiteButton.pressed.connect(_on_site_pressed)

func _on_play_pressed() -> void:
	TransitionManager.go_to_scene(GAME_SCENE)

func _on_site_pressed() -> void:
	OS.shell_open("https://hoodie-research.025555.xyz/")

func _on_quit_pressed() -> void:
	get_tree().quit()
