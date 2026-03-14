extends CharacterBody2D
class_name BaseNPC

signal start_trivia_mission(npc_data: Dictionary)
signal interaction_available(npc: BaseNPC)
signal interaction_unavailable(npc: BaseNPC)

enum HubId {
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
	PHYSICS_SPACE,
	BIOLOGY_ANATOMY,
	EARTH_SCIENCE,
	MATERIALS_TOOLS,
	FINE_MECHANICS,
	SIEGE_ENGINEERING,
	RUNE_LOGIC,
	LITERATURE_HISTORY,
	POETRY_THEATER,
	CLASSIC_AUTHORS,
	MYTHOLOGY_CONCEPTS
}

@export_group("Identitate")
@export var npc_id: String = "main_mayor_01"
@export var npc_name: String = "Primarul"
@export_multiline var short_description: String = "Ghidul principal al satului."

@export_group("Clasificare")
@export var hub_id: HubId = HubId.MAIN
@export var trivia_type: TriviaType = TriviaType.GENERAL
@export var is_tutorial_npc: bool = false

@export_group("Dialog și Misiuni")
@export_multiline var current_dialog: String = "Bine ai venit, călătorule!"
@export_multiline var mission_intro_dialog: String = "Am o întrebare pentru tine."
@export var mission_id: String = "tutorial_001"
@export var has_mission_available: bool = true
@export var mission_completed: bool = false
@export var can_repeat_mission: bool = false
@export var required_player_level: int = 1

@export_group("Vizual")
@export var facing_direction: String = "down" # up / down / left / right
@export var show_name_label: bool = false
@export var auto_face_player_on_interact: bool = true

@export_group("Interacțiune")
@export var interaction_action: StringName = &"interact"
@export var player_group_name: StringName = &"player"
@export var interaction_enabled: bool = true
@export var one_shot_interaction_lock: bool = false

@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D
@onready var name_label: Label = $VisualRoot/NameLabel
@onready var quest_indicator: Node2D = $VisualRoot/QuestIndicator
@onready var interaction_area: Area2D = $InteractionArea
@onready var talk_point: Marker2D = $TalkPoint

var player_in_range: bool = false
var player_ref: Node2D = null
var interaction_locked: bool = false

func _ready() -> void:
	name_label.text = npc_name
	name_label.visible = show_name_label
	
	_update_idle_animation()
	_update_quest_indicator()
	
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta: float) -> void:
	if not interaction_enabled:
		return
	
	if player_in_range and Input.is_action_just_pressed(interaction_action):
		_interact()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(player_group_name):
		return
	
	player_in_range = true
	player_ref = body
	emit_signal("interaction_available", self)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body != player_ref:
		return
	
	player_in_range = false
	player_ref = null
	emit_signal("interaction_unavailable", self)

func _interact() -> void:
	if not interaction_enabled:
		return
	
	if interaction_locked:
		return
	
	if auto_face_player_on_interact and player_ref:
		_face_player(player_ref.global_position)
	
	var npc_data := build_npc_data()
	emit_signal("start_trivia_mission", npc_data)
	
	if one_shot_interaction_lock:
		interaction_locked = true

func build_npc_data() -> Dictionary:
	return {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"hub_id": hub_id,
		"trivia_type": trivia_type,
		"current_dialog": current_dialog,
		"mission_intro_dialog": mission_intro_dialog,
		"mission_id": mission_id,
		"has_mission_available": has_mission_available,
		"mission_completed": mission_completed,
		"can_repeat_mission": can_repeat_mission,
		"required_player_level": required_player_level,
		"talk_point_global_position": talk_point.global_position,
		"short_description": short_description
	}

func set_mission_state(available: bool, completed: bool) -> void:
	has_mission_available = available
	mission_completed = completed
	_update_quest_indicator()

func _update_quest_indicator() -> void:
	if has_mission_available and not mission_completed:
		quest_indicator.visible = true
	else:
		quest_indicator.visible = false

func _update_idle_animation() -> void:
	var anim_name := "idle_%s" % facing_direction
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)

func _face_player(player_global_pos: Vector2) -> void:
	var dir := player_global_pos - global_position
	
	if abs(dir.x) > abs(dir.y):
		facing_direction = "right" if dir.x > 0.0 else "left"
	else:
		facing_direction = "down" if dir.y > 0.0 else "up"
	
	_update_idle_animation()
