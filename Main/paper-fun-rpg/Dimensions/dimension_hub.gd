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
