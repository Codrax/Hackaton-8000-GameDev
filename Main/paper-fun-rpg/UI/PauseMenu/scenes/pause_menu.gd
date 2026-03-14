extends CanvasLayer

@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsPanel

@onready var resume_button = $MainPanel/Mainbuttons/ResumeButton
@onready var settings_button = $MainPanel/Mainbuttons/SettingsButton
@onready var quit_button = $MainPanel/Mainbuttons/QuitButton

@onready var audio_tab_button = $SettingsPanel/TabButtons/AudioTabButton
@onready var graphics_tab_button = $SettingsPanel/TabButtons/GraphicsTabButton
@onready var keybinds_tab_button = $SettingsPanel/TabButtons/KeybindsTabButton
@onready var back_button = $SettingsPanel/BackButton

@onready var audio_page = $SettingsPanel/Pages/AudioPage
@onready var graphics_page = $SettingsPanel/Pages/GraphicsPage
@onready var keybinds_page = $SettingsPanel/Pages/KeybindsPage

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	main_panel.visible = true
	settings_panel.visible = false

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	audio_tab_button.pressed.connect(func(): _show_page("audio"))
	graphics_tab_button.pressed.connect(func(): _show_page("graphics"))
	keybinds_tab_button.pressed.connect(func(): _show_page("keybinds"))
	back_button.pressed.connect(_on_back_pressed)

	_show_page("audio")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	visible = true
	main_panel.visible = true
	settings_panel.visible = false

func resume_game() -> void:
	get_tree().paused = false
	visible = false

func _on_resume_pressed() -> void:
	resume_game()

func _on_settings_pressed() -> void:
	main_panel.visible = false
	settings_panel.visible = true

func _on_back_pressed() -> void:
	settings_panel.visible = false
	main_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _show_page(page_name: String) -> void:
	audio_page.visible = page_name == "audio"
	graphics_page.visible = page_name == "graphics"
	keybinds_page.visible = page_name == "keybinds"
	
func open_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	main_panel.visible = true
	settings_panel.visible = false
