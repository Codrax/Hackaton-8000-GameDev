extends CharacterBody2D
class_name BaseNPC


signal start_trivia_mission(npc_data: Dictionary)



# ================================
# ENUMS
# ================================

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



# ================================
# EXPORT VARIABLES
# ================================

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



# ================================
# NODE REFERENCES
# ================================

@onready var sprite : AnimatedSprite2D = $VisualRoot/AnimatedSprite2D
@onready var name_label : Label = $VisualRoot/NameLabel
@onready var quest_indicator : AnimatedSprite2D = $VisualRoot/QuestIndicator

@onready var interaction_area : Area2D = $InteractionArea
@onready var talk_point : Marker2D = $TalkPoint



# ================================
# STATE
# ================================

var player_in_range : bool = false
var player_ref : Node2D = null



# ================================
# READY
# ================================

func _ready():

	name_label.text = npc_name
	name_label.visible = show_name

	_update_animation()
	_update_quest_indicator()

	interaction_area.body_entered.connect(_on_player_enter)
	interaction_area.body_exited.connect(_on_player_exit)



# ================================
# PROCESS
# ================================

func _process(delta):

	if not interaction_enabled:
		return

	if player_in_range:

		if Input.is_action_just_pressed(interaction_action):
			_interact()



# ================================
# PLAYER DETECTION
# ================================

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



# ================================
# INTERACTION
# ================================

func _interact():

	if not interaction_enabled:
		return

	if not has_mission_available and not repeatable:
		return

	if player_ref:
		_face_player(player_ref.global_position)

	var data = _build_npc_data()

	emit_signal("start_trivia_mission", data)



# ================================
# DATA PACKET
# ================================

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



# ================================
# VISUAL
# ================================

func _update_animation():

	var anim = "idle_" + facing_direction

	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)



func _update_quest_indicator():

	if has_mission_available and not mission_completed:
		quest_indicator.visible = true
	else:
		quest_indicator.visible = false



# ================================
# FACE PLAYER
# ================================

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



# ================================
# EXTERNAL MISSION UPDATE
# ================================

func set_mission_state(available : bool, completed : bool):

	has_mission_available = available
	mission_completed = completed

	_update_quest_indicator()
