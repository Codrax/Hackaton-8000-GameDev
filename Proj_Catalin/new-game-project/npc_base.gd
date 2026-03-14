extends CharacterBody2D

# === EXPORT VARIABLES ===
@export var npc_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Salut!", "Ce mai faci?"]
@export var interaction_key: String = "ui_accept"
@export var idle_animation: String = "idle"
@export var talk_animation: String = "talk"
@export var face_player_on_talk: bool = true
@export var interaction_cooldown: float = 0.3
@export var typewriter_speed: float = 0.04   # secunde per literă (mai mic = mai rapid)

# === SEMNALE ===
signal dialogue_started(npc_name: String)
signal dialogue_finished(npc_name: String)
signal line_shown(npc_name: String, line: String, index: int)

# === NODURI ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_label: Label = $InteractionLabel

# === STARE ===
var player_nearby: bool = false
var player_ref: Node2D = null
var current_line: int = 0
var is_talking: bool = false
var can_interact: bool = true
var is_typing: bool = false        # typewriter activ?
var full_current_text: String = "" # textul complet al liniei curente

# === REFERINȚE UI (populate după _create_dialogue_ui) ===
var _ui_name_label: Label = null
var _ui_text_label: Label = null
var _ui_continue_label: Label = null

# ================================================
# READY
# ================================================
func _ready() -> void:
	animated_sprite.play(idle_animation)
	interaction_label.visible = false
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)
	_create_dialogue_ui()

# ================================================
# DIALOGUE UI — creat o singură dată, shared
# ================================================
func _create_dialogue_ui() -> void:
	if get_tree().get_first_node_in_group("dialogue_box"):
		return

	var canvas := CanvasLayer.new()
	canvas.add_to_group("dialogue_box")
	get_tree().root.call_deferred("add_child", canvas)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top    = -160
	panel.offset_bottom = -10
	panel.offset_left   = 20
	panel.offset_right  = -20
	canvas.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	vbox.add_child(name_lbl)

	var text_lbl := Label.new()
	text_lbl.name = "TextLabel"
	text_lbl.add_theme_font_size_override("font_size", 14)
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(text_lbl)

	var continue_lbl := Label.new()
	continue_lbl.name = "ContinueLabel"
	continue_lbl.text = "[ Apasă E pentru a continua ]"
	continue_lbl.add_theme_font_size_override("font_size", 11)
	continue_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	continue_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(continue_lbl)

	canvas.visible = false

# ================================================
# HELPER — returnează CanvasLayer-ul UI
# ================================================
func _get_ui() -> CanvasLayer:
	return get_tree().get_first_node_in_group("dialogue_box") as CanvasLayer

func _cache_ui_refs() -> void:
	var canvas := _get_ui()
	if canvas == null:
		return
	var vbox: VBoxContainer = canvas.get_child(0).get_child(0)
	_ui_name_label     = vbox.get_node("NameLabel")
	_ui_text_label     = vbox.get_node("TextLabel")
	_ui_continue_label = vbox.get_node("ContinueLabel")

# ================================================
# INPUT
# ================================================
func _process(_delta: float) -> void:
	if not player_nearby or not can_interact:
		return

	if Input.is_action_just_pressed(interaction_key):
		# Dacă typewriter-ul rulează → skip direct la textul complet
		if is_typing:
			_skip_typewriter()
		else:
			interact()

# ================================================
# INTERACȚIUNE
# ================================================
func interact() -> void:
	if not is_talking:
		is_talking = true
		current_line = 0
		_cache_ui_refs()
		emit_signal("dialogue_started", npc_name)

	if current_line < dialogue_lines.size():
		var line := dialogue_lines[current_line]
		emit_signal("line_shown", npc_name, line, current_line)
		current_line += 1
		_show_line(line)
		_play_talk_animation()
		_face_player()
	else:
		end_dialogue()

	# Cooldown anti-spam
	can_interact = false
	await get_tree().create_timer(interaction_cooldown).timeout
	can_interact = true

# ================================================
# AFIȘARE LINIE + TYPEWRITER
# ================================================
func _show_line(line: String) -> void:
	var canvas := _get_ui()
	if canvas == null:
		return

	canvas.visible = true
	_ui_name_label.text = npc_name
	_ui_text_label.text = ""
	_ui_continue_label.visible = false

	full_current_text = line
	_run_typewriter(line)

func _run_typewriter(line: String) -> void:
	is_typing = true
	_ui_text_label.text = ""

	for i in range(line.length()):
		if not is_typing:
			# skip_typewriter() a fost apelat
			break
		_ui_text_label.text = line.substr(0, i + 1)
		await get_tree().create_timer(typewriter_speed).timeout

	# Asigură textul complet indiferent de skip
	_ui_text_label.text = full_current_text
	is_typing = false
	_ui_continue_label.visible = true

func _skip_typewriter() -> void:
	is_typing = false  # oprește loop-ul din _run_typewriter
	# textul complet e setat în _run_typewriter după break

# ================================================
# ÎNCHIDE DIALOGUL
# ================================================
func end_dialogue() -> void:
	is_talking = false
	is_typing  = false
	current_line = 0
	animated_sprite.play(idle_animation)
	emit_signal("dialogue_finished", npc_name)

	var canvas := _get_ui()
	if canvas:
		canvas.visible = false

# ================================================
# ANIMAȚII
# ================================================
func _play_talk_animation() -> void:
	if not animated_sprite.sprite_frames.has_animation(talk_animation):
		return
	animated_sprite.play(talk_animation)
	if not animated_sprite.sprite_frames.get_animation_loop(talk_animation):
		await animated_sprite.animation_finished
		if is_talking:
			animated_sprite.play(idle_animation)

# ================================================
# FAȚĂ SPRE PLAYER
# ================================================
func _face_player() -> void:
	if not face_player_on_talk or player_ref == null:
		return
	animated_sprite.flip_h = player_ref.global_position.x < global_position.x

# ================================================
# ZONA DE INTERACȚIUNE
# ================================================
func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		player_ref    = body
		interaction_label.visible = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		player_ref    = null
		interaction_label.visible = false
		if is_talking:
			end_dialogue()
