extends CanvasLayer

@export var pause_menu_path: NodePath

@onready var pause_menu = get_node(pause_menu_path)

func _ready() -> void:
	pressed.connect(_on_pressed)

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
	print("PAUSE Clicked! 🍦")
	
	# This stops the input from reaching the game world
	get_viewport().set_input_as_handled()
