extends CanvasLayer

@onready var ui_overlay = $"../UI_Overlay"
@onready var pause_menu = $"../Pause_Menu" # Replace with the exact node name
#Why does rain fall from the sky? Please tell me
@onready var help_input = $"Contailer_Help/CenterContainer/CenterContainer2/Help_Input"
@onready var help_response = $"Contailer_Help/CenterContainer/CenterContainer8/Help_Response"
@onready var http_request = $"HTTPRequest"

const API_URL = "https://devsocket.025555.xyz/"
const AUTH_TOKEN = "b8d4de9d-4c35-4143-b0c4-61c3776c0586"

@onready var ui_container = $Contailer_Help

func _ready() -> void:
	if ui_overlay == null:
		push_error("Pause_Menu nu a fost gasit.")
		return
	ui_overlay.visible = true

func _on_pressed() -> void:
	if pause_menu == null:
		push_error("Pause_Menu nu a fost gasit.")
		return

	pause_menu.open_pause_menu()


var is_open = false
var tween: Tween

func _on_button_help_pressed() -> void:
	print("HELP Clicked! 🍦")
	get_viewport().set_input_as_handled()
	
	# Toggle the state
	is_open = !is_open
	
	if not is_open:
		# If we are CLOSING the menu, release the keyboard focus
		var current_focus = get_viewport().gui_get_focus_owner()
		if current_focus:
			current_focus.release_focus()
	
	# Determine target position
	var target_y = 3400 if is_open else 5000
	
	# Kill existing tween to "switch destination" instantly if mid-animation
	if tween:
		tween.kill()
	
	# Create a new tween
	tween = create_tween()
	
	# Slide property, target value, and duration (0.3 seconds for 'fast')
	# We use TRANS_QUART and EASE_OUT for a "snappy" professional feel
	tween.tween_property(ui_container, "position:x", target_y, 0.4)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)

func _on_button_pause_pressed() -> void:
	if pause_menu == null:
		print("ERROR NOT FOUND")
		push_error("Pause_Menu nu a fost gasit.")
		return
	print("OPENING")
	pause_menu.open_pause_menu()
	
	# This stops the input from reaching the game world
	get_viewport().set_input_as_handled()

var is_requesting = false
func _on_texture_button_pressed() -> void:
	# 0. Check if a request is already running
	if is_requesting:
		return 
		
	var user_message = help_input.text
	if user_message.is_empty():
		return

	# 1. Lock the request and set loading state
	is_requesting = true
	help_response.text = "Loading..."
	
	# 2. Visual "Gray out" effect (0.5 opacity, grayish)
	var gray_tween = create_tween()
	gray_tween.tween_property(ui_container, "modulate", Color(0.5, 0.5, 0.5, 0.75), 0.2)
	
	# 3. Prepare Headers and Body
	var headers = ["Content-Type: application/json", "Authorization: Bearer " + AUTH_TOKEN]
	var body = JSON.stringify({"message": user_message})
	
	# 4. Send request
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		is_requesting = false # Unlock if we couldn't even send it
		help_response.text = "Network error"
		ui_container.modulate = Color.WHITE # Reset color instantly on error

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# ALWAYS unlock the request when finished
	is_requesting = false
	
	# Reset the visual filter back to normal (White is default)
	var reset_tween = create_tween()
	reset_tween.tween_property(ui_container, "modulate", Color.WHITE, 0.2)

	# ... keep your existing JSON parsing logic below ...
	if result != HTTPRequest.RESULT_SUCCESS:
		help_response.text = "Eroare retea"
		return

	var json = JSON.new()
	var parse_err = json.parse(body.get_string_from_utf8())
	if parse_err != OK:
		help_response.text = "Eroare retea"
		return

	var response_data = json.get_data()
	if response_data.has("message"):
		help_response.text = response_data["message"]
	else:
		help_response.text = "Unexpected response format"
