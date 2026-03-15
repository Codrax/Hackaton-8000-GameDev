extends StaticBody2D

const NEXT_LEVEL_PATH = "res://Dimensions/dimension_culture.tscn"

var fade_tween: Tween
var player_in_contact: CharacterBody2D = null

const player_teleport_duration = 3.0
const TARGET_ZOOM = Vector2(2.5, 2.5) # Zooming out

@onready var tint_layer = $"../CanvasModulate" 
@onready var camera = $"../Player/Camera2D" # Adjust path to your camera

var original_zoom: Vector2

func _ready() -> void:
	if camera:
		original_zoom = camera.zoom

func _physics_process(_delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = $CollisionShape2D.shape
	query.transform = global_transform
	query.collision_mask = 1 

	var results = space_state.intersect_shape(query)
	
	var found_player = null
	for res in results:
		if res.collider.name == "Player":
			found_player = res.collider
			break

	if found_player and not player_in_contact:
		_start_fade(found_player)
	elif not found_player and player_in_contact:
		_reset_fade()

func _start_fade(player: CharacterBody2D) -> void:
	player_in_contact = player
	if camera:
		original_zoom = camera.zoom # Store current zoom in case it changed
	
	print("🌀 Portal contact! Fading, Tinting, and Zooming...")
	
	if fade_tween: 
		fade_tween.kill()
	
	fade_tween = create_tween().set_parallel(true)
	
	# 1. Fade player
	fade_tween.tween_property(player_in_contact, "modulate:a", 0.0, player_teleport_duration)
	
	# 2. Tint screen purple
	fade_tween.tween_property(tint_layer, "color", Color(0.7, 0.3, 1.0), player_teleport_duration)
	
	# 3. Zoom Camera
	if camera:
		fade_tween.tween_property(camera, "zoom", TARGET_ZOOM, player_teleport_duration)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	fade_tween.chain().finished.connect(_change_map)

func _reset_fade() -> void:
	print("❌ Contact lost. Resetting all visuals.")
	if fade_tween: 
		fade_tween.kill()
	
	var reset_tween = create_tween().set_parallel(true)
	
	# Reset everything fast (0.5s for a smoother bounce back)
	reset_tween.tween_property(player_in_contact, "modulate:a", 1.0, 0.5)
	reset_tween.tween_property(tint_layer, "color", Color.WHITE, 0.5)
	
	if camera:
		reset_tween.tween_property(camera, "zoom", original_zoom, 0.5)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	player_in_contact = null

func _change_map() -> void:
	if player_in_contact:
		get_tree().change_scene_to_file(NEXT_LEVEL_PATH)
