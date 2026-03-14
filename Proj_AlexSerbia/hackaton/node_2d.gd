extends CharacterBody2D
class_name BaseNPC


signal start_trivia_mission(npc_data: Dictionary)



enum HubID {
	MAIN,
	SCIENCE,
	TECH,
	LITERATURE
}

enum TriviaType {
	GENERAL,
	GAME_MECHANICS,
	ECONOMY,
	EXPLORATION,

	CHEMISTRY,
	PHYSICS,
	BIOLOGY,
	EARTH_SCIENCE,

	MATERIALS,
	MECHANICS,
	ENGINEERING,
	RUNE_LOGIC,

	LITERATURE,
	POETRY,
	CLASSIC_AUTHORS,
	MYTHOLOGY
}



@export_group("Identity")

@export var npc_id : String = "npc_01"
@export var npc_name : String = "NPC"

@export_multiline var description : String = ""


@export_group("Hub Info")

@export var hub_id : HubID = HubID.MAIN
@export var trivia_type : TriviaType = TriviaType.GENERAL


@export_group("Mission")

@export var mission_id : String = "mission_01"

@export_multiline var dialog_text : String = "Hello traveler."

@export var has_mission_available : bool = true
@export var mission_completed : bool = false
@export var repeatable : bool = false


@export_group("Visual")

@export var show_name : bool = true
@export var facing_direction : String = "down"


@export_group("Interaction")

@export var player_group : StringName = &"player"
@export var interaction_action : StringName = &"interact"

@export var interaction_enabled : bool = true


@export_group("Dialog")

@export var dialog_zoom : float = 2.5
@export var zoom_duration : float = 0.4
@export var text_speed : float = 0.05



@onready var sprite : AnimatedSprite2D = $VisualRoot/AnimatedSprite2D
@onready var name_label : Label = $VisualRoot/NameLabel
@onready var quest_indicator : AnimatedSprite2D = $VisualRoot/QuestIndicator

@onready var interaction_area : Area2D = $InteractionArea
@onready var talk_point : Marker2D = $TalkPoint

var player_in_range : bool = false
var player_ref : Node2D = null
var is_talking : bool = false
var dialog_bubble : CanvasLayer = null
var camera_ref : Camera2D = null
var original_zoom : Vector2 = Vector2.ONE



func _ready():

	name_label.text = npc_name
	name_label.visible = show_name

	_update_animation()
	_update_quest_indicator()

	interaction_area.body_entered.connect(_on_player_enter)
	interaction_area.body_exited.connect(_on_player_exit)


func _process(delta):

	if not interaction_enabled:
		return

	if player_in_range:

		if Input.is_action_just_pressed(interaction_action):
			if is_talking:
				_close_dialog()
			else:
				_interact()


func _on_player_enter(body):

	if not body.is_in_group(player_group):
		return

	player_in_range = true
	player_ref = body


func _on_player_exit(body):

	if body != player_ref:
		return

	player_in_range = false
	player_ref = null

	if is_talking:
		_close_dialog()



func _interact():

	if not interaction_enabled:
		return

	if not has_mission_available and not repeatable:
		return

	if player_ref:
		_face_player(player_ref.global_position)

	_start_dialog()




func _start_dialog():

	is_talking = true

	camera_ref = _find_camera()
	if camera_ref:
		original_zoom = camera_ref.zoom
		_zoom_camera(Vector2(dialog_zoom, dialog_zoom))

	# Creează bubble-ul
	_create_dialog_bubble(dialog_text)



func _close_dialog():

	is_talking = false

	# Zoom out înapoi
	if camera_ref:
		_zoom_camera(original_zoom)
		camera_ref = null

	# Șterge bubble-ul
	if dialog_bubble:
		dialog_bubble.queue_free()
		dialog_bubble = null

	# Emit signal după ce se închide dialogul
	var data = _build_npc_data()
	emit_signal("start_trivia_mission", data)



func _find_camera() -> Camera2D:
	# Caută camera în player sau în scenă
	if player_ref:
		for child in player_ref.get_children():
			if child is Camera2D:
				return child
	# Fallback: caută în scenă
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		return cameras[0]
	return null



func _zoom_camera(target_zoom: Vector2):

	if not camera_ref:
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(camera_ref, "zoom", target_zoom, zoom_duration)



func _create_dialog_bubble(text: String):

	# CanvasLayer ca să apară peste tot
	dialog_bubble = CanvasLayer.new()
	dialog_bubble.layer = 10
	get_tree().root.add_child(dialog_bubble)

	# Container principal
	var panel = PanelContainer.new()
	panel.name = "DialogPanel"
	dialog_bubble.add_child(panel)

	# Stil Pokemon — alb cu bordură neagră groasă
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1)
	style.border_color = Color(0.1, 0.1, 0.1, 1)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)

	# Dimensiune și poziție — jos pe ecran ca în Pokemon
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -160
	panel.offset_bottom = -20
	panel.offset_left = 20
	panel.offset_right = -20

	# VBox pentru nume + text
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	# Label nume NPC
	var name_lbl = Label.new()
	name_lbl.text = npc_name
	name_lbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.6, 1))
	name_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_lbl)

	# Separator
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.1, 0.1, 0.1, 0.3))
	vbox.add_child(sep)

	# Label text dialog
	var text_lbl = Label.new()
	text_lbl.name = "TextLabel"
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05, 1))
	text_lbl.add_theme_font_size_override("font_size", 16)
	text_lbl.text = ""
	vbox.add_child(text_lbl)

	# Label "apasă interact"
	var hint_lbl = Label.new()
	hint_lbl.text = "[ Apasă " + String(interaction_action) + " pentru a continua ]"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
	hint_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(hint_lbl)

	# Animație apariție
	panel.modulate.a = 0
	panel.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(panel, "scale", Vector2(1, 1), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Typewriter effect
	_typewriter(text_lbl, text)



func _typewriter(label: Label, full_text: String):

	label.text = ""
	var i = 0
	while i < full_text.length():
		label.text += full_text[i]
		i += 1
		await get_tree().create_timer(text_speed).timeout



func _build_npc_data() -> Dictionary:

	return {

		"npc_id": npc_id,
		"npc_name": npc_name,

		"hub_id": hub_id,
		"trivia_type": trivia_type,

		"mission_id": mission_id,

		"dialog": dialog_text,

		"mission_available": has_mission_available,
		"mission_completed": mission_completed,

		"talk_point": talk_point.global_position
	}



func _update_animation():

	var anim = "idle_" + facing_direction

	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)



func _update_quest_indicator():

	if has_mission_available and not mission_completed:
		quest_indicator.visible = true
	else:
		quest_indicator.visible = false


func _face_player(player_pos):

	var dir = player_pos - global_position

	if abs(dir.x) > abs(dir.y):

		if dir.x > 0:
			facing_direction = "right"
		else:
			facing_direction = "left"

	else:

		if dir.y > 0:
			facing_direction = "down"
		else:
			facing_direction = "up"

	_update_animation()



func set_mission_state(available : bool, completed : bool):

	has_mission_available = available
	mission_completed = completed

	_update_quest_indicator()
	
	
