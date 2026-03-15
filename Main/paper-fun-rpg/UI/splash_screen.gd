extends CanvasLayer

const GAME_SCENE = "res://UI/main_menu/main_menu.tscn"

@onready var splash_1 = $splash_1
@onready var splash_2 = $splash_2
@onready var splash_3 = $splash_3

func _ready() -> void:
	splash_1.modulate.a = 0
	splash_2.modulate.a = 0
	splash_3.modulate.a = 0
	
	splash_1.visible = true
	splash_2.visible = true
	splash_3.visible = true
	
	await play_splash(splash_1)
	await play_splash(splash_2)
	await play_splash(splash_3)

	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file(GAME_SCENE)


func play_splash(node: CanvasItem) -> void:
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.5) # fade in
	tween.tween_interval(3.0)                          # stay visible
	tween.tween_property(node, "modulate:a", 0.0, 0.5) # fade out
	await tween.finished
