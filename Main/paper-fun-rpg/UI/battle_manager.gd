extends Node

var player: Node2D
var camera: Camera2D
var battle_index: int = 0

const SCENE_BATTLE = "res://Scenes/scene_battle.tscn"

func fetchPlayerInstance():
	player = get_tree().get_first_node_in_group("Player")
	if player:
		camera = player.get_node("Camera2D")
	if camera:
		return true
	print("PLAYER/CAMERA not found")
	return false

func battle_start(index: int):
	if not fetchPlayerInstance():
		return
	
	battle_index = index
	print("Start lupta")
	
		# delete overlay
	var tmp = get_tree().root.get_node("Node2D/UI_Overlay")
	if tmp:
		tmp.hide()
	else:
		print("UI OVERLAY not found")

	# Store normal zoom
	var target_zoom = Vector2(0.5, 0.5)

	var tween = create_tween()
	tween.tween_property(camera, "zoom", target_zoom, 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

	tween.finished # do NOT use await, make this run sinchronously

	_screen_fill()

func _screen_fill():
	var viewport_size = get_viewport().get_visible_rect().size
	var box_size = 200

	var cols = int(viewport_size.x / box_size) + 1
	var rows = int(viewport_size.y / box_size) + 1

	var layer = CanvasLayer.new()
	add_child(layer)

	for y in range(rows):
		for x in range(cols):
			var rect = ColorRect.new()
			rect.color = Color.BLACK
			rect.size = Vector2(box_size, box_size)
			rect.position = Vector2(x * box_size, y * box_size)

			layer.add_child(rect)

			await get_tree().create_timer(0.001).timeout

	print("LOADING LEVEL")
	get_tree().change_scene_to_file(SCENE_BATTLE)
	layer.queue_free()  # remove the black layer
