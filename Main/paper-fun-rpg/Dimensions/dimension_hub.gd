extends Node2D

@onready var camera = $"Player/Camera2D"

func _ready() -> void:
	# 1. Ensure the camera exists
	if camera:
		# Store the original zoom value (e.g., Vector2(1, 1))
		var target_zoom = camera.zoom
		
		# 2. Set the starting "zoomed out" state
		# Smaller numbers = further away (e.g., 0.1 is very far, 1.0 is normal)
		camera.zoom = Vector2(0.1, 0.1)
		
		# 3. Create the animation,
		var tween = create_tween()
		
		# Animate the 'zoom' property to the original value
		# 1.5 seconds duration, adjust for speed! 🍦
		tween.tween_property(camera, "zoom", target_zoom, 15)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
			
		print("🎥 Camera zooming in...")
	
	# Connect signals for both areas
	$Area2D_1.body_entered.connect(_on_player_entered)
	$Area2D_2.body_entered.connect(_on_player_entered)
	
	# Optional: If you want it to disappear when leaving
	$Area2D_1.body_exited.connect(_on_player_exited)
	$Area2D_2.body_exited.connect(_on_player_exited)


@onready var my_vbox = $UI/UI_Unavalabile

# Configuration for the animation
var anim_duration: float = 0.4
var slide_distance: float = 100.0 # How many pixels it moves down from the top

func _on_player_entered(body):
	if body.name == "Player":
		show_menu()

func _on_player_exited(body):
	if body.name == "Player":
		hide_menu()

func show_menu():
	my_vbox.show()
	
	# Calculate target center position
	var viewport_size = get_viewport_rect().size
	var target_pos = (viewport_size / 2) - (my_vbox.size / 2)
	var start_pos = target_pos - Vector2(0, slide_distance) # Start higher up
	
	# Create Tween
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Animate Position (Slide Down)
	my_vbox.global_position = start_pos
	tween.tween_property(my_vbox, "global_position", target_pos, anim_duration)
	
	# Animate Opacity (Fade In)
	tween.tween_property(my_vbox, "modulate:a", 1.0, anim_duration)

func hide_menu():
	var viewport_size = get_viewport_rect().size
	var target_pos = (viewport_size / 2) - (my_vbox.size / 2) - Vector2(0, slide_distance)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# Animate Position (Slide Up)
	tween.tween_property(my_vbox, "global_position", target_pos, anim_duration)
	
	# Animate Opacity (Fade Out)
	tween.tween_property(my_vbox, "modulate:a", 0.0, anim_duration)
	
	# Hide the node entirely once the animation finishes
	tween.chain().tween_callback(my_vbox.hide)
