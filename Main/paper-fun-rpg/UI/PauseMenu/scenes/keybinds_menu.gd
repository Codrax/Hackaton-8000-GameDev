extends Control

@onready var keybind_list = $ScrollContainer/KeybindList

var actions_to_show := [
	{"action": "move_left", "label": "Move Left"},
	{"action": "move_right", "label": "Move Right"},
	{"action": "move_up", "label": "Move Up"},
	{"action": "move_down", "label": "Move Down"},
	{"action": "attack", "label": "Attack"},
	{"action": "interact", "label": "Interact"},
	{"action": "ui_cancel", "label": "Pause / Back"},
	{"action": "toggle_fullscreen", "label": "Toggle Fullscreen"}
]

func _ready() -> void:
	build_keybind_list()

func build_keybind_list() -> void:
	for child in keybind_list.get_children():
		child.queue_free()

	for entry in actions_to_show:
		var action_name: String = entry["action"]
		var display_name: String = entry["label"]
		var key_text: String = get_action_keys_as_text(action_name)

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var action_label := Label.new()
		action_label.text = display_name
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var key_label := Label.new()
		key_label.text = key_text

		row.add_child(action_label)
		row.add_child(key_label)
		keybind_list.add_child(row)

func get_action_keys_as_text(action_name: String) -> String:
	var events := InputMap.action_get_events(action_name)

	if events.is_empty():
		return "Unassigned"

	var parts: Array[String] = []

	for event in events:
		if event is InputEventKey:
			parts.append(OS.get_keycode_string(event.physical_keycode))
		elif event is InputEventMouseButton:
			parts.append("Mouse %d" % event.button_index)
		elif event is InputEventJoypadButton:
			parts.append("Joy Button %d" % event.button_index)
		elif event is InputEventJoypadMotion:
			parts.append("Joy Axis")

	return ", ".join(parts)
