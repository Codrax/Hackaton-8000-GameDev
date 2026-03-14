extends CanvasLayer

@onready var pause_menu = $"../Pause_Menu" # Replace with the exact node name

func _on_pressed() -> void:
	if pause_menu == null:
		push_error("Pause_Menu nu a fost gasit.")
		return

	pause_menu.open_pause_menu()


func _on_button_help_pressed() -> void:
	# Your button logic here
	print("HELP Clicked! 🍦")
	
	# This stops the input from reaching the game world
	get_viewport().set_input_as_handled()


func _on_button_pause_pressed() -> void:
	# Your button logic here
	if pause_menu == null:
		print("ERROR NOT FOUND")
		push_error("Pause_Menu nu a fost gasit.")
		return
	print("OPENING")
	pause_menu.open_pause_menu()
	
	# This stops the input from reaching the game world
	get_viewport().set_input_as_handled()
