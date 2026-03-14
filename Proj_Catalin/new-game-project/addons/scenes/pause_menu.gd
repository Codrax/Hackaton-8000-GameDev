extends CanvasLayer

@onready var dim: ColorRect = $Dim
@onready var main_panel: NinePatchRect = $MainPanel
@onready var settings_panel: NinePatchRect = $SettingsPanel

@onready var resume_button: TextureButton = $MainPanel/MainButtons/ResumeButton
@onready var settings_button: TextureButton = $MainPanel/MainButtons/SettingsButton
@onready var quit_button: TextureButton = $MainPanel/MainButtons/QuitButton
@onready var close_button: TextureButton = $MainPanel/CloseButton

@onready var audio_tab_button: TextureButton = $SettingsPanel/TabButtons/AudioTabButton
@onready var graphics_tab_button: TextureButton = $SettingsPanel/TabButtons/GraphicsTabButton
@onready var keybinds_tab_button: TextureButton = $SettingsPanel/TabButtons/KeybindsTabButton
@onready var back_button: TextureButton = $SettingsPanel/BackButton

@onready var audio_page: Control = $SettingsPanel/Pages/AudioPage
@onready var graphics_page: Control = $SettingsPanel/Pages/GraphicsPage
@onready var keybinds_page: Control = $SettingsPanel/Pages/KeybindsPage

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	# Panoul de setări începe ascuns
	main_panel.visible = true
	settings_panel.visible = false
	
	# Conectare semnale butoane principale
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_button.pressed.connect(_on_resume_pressed)
	
	# Conectare tab-uri setări
	audio_tab_button.pressed.connect(func(): _show_settings_page("audio"))
	graphics_tab_button.pressed.connect(func(): _show_settings_page("graphics"))
	keybinds_tab_button.pressed.connect(func(): _show_settings_page("keybinds"))
	back_button.pressed.connect(_on_back_pressed)
	
	_show_settings_page("audio")

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
	# Variante posibile:
	# 1. inchizi jocul:
	get_tree().quit()
	
	# 2. sau te intorci in main menu:
	# get_tree().paused = false
	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _show_settings_page(page_name: String) -> void:
	audio_page.visible = page_name == "audio"
	graphics_page.visible = page_name == "graphics"
	keybinds_page.visible = page_name == "keybinds"
