extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed():
	# Your button logic here
	print("HELP Clicked! 🍦")
	
	# This stops the input from reaching the game world
	get_viewport().set_input_as_handled()
