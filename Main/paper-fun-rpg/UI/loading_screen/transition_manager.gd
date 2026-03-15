extends Node

const LOADING_SCENE: String = "res://UI/loading_screen/loading_screen.tscn"

var target_scene_path: String = ""

func go_to_scene(scene_path: String) -> void:
	target_scene_path = scene_path
	print("Transitioning to:", scene_path)
	get_tree().change_scene_to_file(LOADING_SCENE)
