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
@export var npc_id: String = "npc_01"
@export var npc_name: String = "NPC"
@export_multiline var description: String = ""

@export_group("Hub Info")
@export var hub_id: HubID = HubID.MAIN
@export var trivia_type: TriviaType = TriviaType.GENERAL

@export_group("Mission")
@export var mission_id: String = "mission_01"
@export_multiline var dialog_text: String = "Hello traveler."
@export var has_mission_available: bool = true
@export var mission_completed: bool = false
@export var repeatable: bool = false

@export_group("Visual")
@export var show_name: bool = true
@export var facing_direction: String = "down"

@export_group("Interaction")
@export var player_group: StringName = &"player"
@export var interaction_action: StringName = &"interact"
@export var interaction_enabled: bool = true


@onready var sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D
@onready var name_label: Label = $VisualRoot/NameLabel
@onready var quest_indicator: AnimatedSprite2D = $VisualRoot/QuestIndicator
@onready var interaction_area: Area2D = $InteractionArea
@onready var talk_point: Marker2D = $TalkPoint


var player_in_range: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	if not _validate_nodes():
		push_error("[BaseNPC] '%s' — noduri lipsă în scenă! Verifică structura." % npc_name)
		return

	name_label.text = npc_name
	name_label.visible = show_name

	_update_animation()
	_update_quest_indicator()

	interaction_area.body_entered.connect(_on_player_enter)
	interaction_area.body_exited.connect(_on_player_exit)


func _validate_nodes() -> bool:
	var ok := true
	if not is_instance_valid(sprite):
		push_error("[BaseNPC] Lipsă: VisualRoot/AnimatedSprite2D")
		ok = false
	if not is_instance_valid(name_label):
		push_error("[BaseNPC] Lipsă: VisualRoot/NameLabel")
		ok = false
	if not is_instance_valid(quest_indicator):
		push_error("[BaseNPC] Lipsă: VisualRoot/QuestIndicator")
		ok = false
	if not is_instance_valid(interaction_area):
		push_error("[BaseNPC] Lipsă: InteractionArea")
		ok = false
	if not is_instance_valid(talk_point):
		push_error("[BaseNPC] Lipsă: TalkPoint")
		ok = false
	return ok

func _process(_delta: float) -> void:
	if not interaction_enabled:
		return
	if player_in_range and Input.is_action_just_pressed(interaction_action):
		_interact()

func _on_player_enter(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group(player_group):
		return
	player_in_range = true
	player_ref = body


func _on_player_exit(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if not body.is_in_group(player_group):
		return
	player_in_range = false
	player_ref = null

func _interact() -> void:
	if not interaction_enabled:
		return
	if mission_completed and not repeatable:
		return
	if not has_mission_available and not repeatable:
		return

	if is_instance_valid(player_ref):
		_face_player(player_ref.global_position)

	var data := _build_npc_data()
	start_trivia_mission.emit(data)


func _build_npc_data() -> Dictionary:
	# CRASH FIX: talk_point poate fi null dacă _validate_nodes a trecut parțial
	var tp_pos := Vector2.ZERO
	if is_instance_valid(talk_point):
		tp_pos = talk_point.global_position

	return {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"hub_id": hub_id,
		"trivia_type": trivia_type,
		"mission_id": mission_id,
		"dialog": dialog_text,
		"mission_available": has_mission_available,
		"mission_completed": mission_completed,
		"talk_point": tp_pos
	}

func _update_animation() -> void:
	if not is_instance_valid(sprite):
		return

	if sprite.sprite_frames == null:
		push_warning("[BaseNPC] '%s' — AnimatedSprite2D nu are SpriteFrames asignat!" % npc_name)
		return

	var anim := "idle_" + facing_direction
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	elif sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	else:
		push_warning("[BaseNPC] '%s' — nicio animație 'idle_%s' sau 'idle' găsită." % [npc_name, facing_direction])

func _update_quest_indicator() -> void:
	if not is_instance_valid(quest_indicator):
		return
	quest_indicator.visible = has_mission_available and not mission_completed


func _face_player(player_pos: Vector2) -> void:
	var dir := player_pos - global_position
	var threshold := 5.0

	if abs(dir.x) > abs(dir.y) + threshold:
		facing_direction = "right" if dir.x > 0 else "left"
	elif abs(dir.y) > abs(dir.x) + threshold:
		facing_direction = "down" if dir.y > 0 else "up"
	

	_update_animation()

func set_mission_state(available: bool, completed: bool) -> void:
	has_mission_available = available
	mission_completed = completed
	_update_quest_indicator()


func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled
