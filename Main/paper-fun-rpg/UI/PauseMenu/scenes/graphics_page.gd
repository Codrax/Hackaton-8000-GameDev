extends Control

@onready var fullscreen_button = $FullscreenButton
@onready var windowed_button = $WindowedButton
@onready var local_llm_button = $LocalLLMButton
@onready var local_llm_edit = $LocalLLMEdit

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	local_llm_button.button_pressed = SettingsManager.local_llm
	local_llm_edit.text = SettingsManager.local_llm_server

	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	windowed_button.pressed.connect(_on_windowed_pressed)
	local_llm_button.pressed.connect(_on_local_llm_pressed)

func _on_fullscreen_pressed() -> void:
	SettingsManager.set_window_mode("fullscreen")

func _on_windowed_pressed() -> void:
	SettingsManager.set_window_mode("windowed")
	
func _on_local_llm_pressed() -> void:
	SettingsManager.local_llm = local_llm_button.button_pressed
	SettingsManager.local_llm_server = local_llm_edit.text
	
	AI.useLocalLLM = SettingsManager.local_llm
	AI.localLLMServer = SettingsManager.local_llm_server
	
	SettingsManager.save_settings()


func _on_fullscreen_button_2_pressed() -> void:
	local_llm_edit.text = "http://localhost:8010"
	_on_local_llm_pressed()


func _on_local_llm_edit_text_changed(new_text: String) -> void:
	_on_local_llm_pressed()
