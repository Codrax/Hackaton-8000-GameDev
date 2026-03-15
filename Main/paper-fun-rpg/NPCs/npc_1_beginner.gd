extends Area2D

@export var npc_id: String = "npc_beginner"
@onready var label = $InteractionLabel

func _ready():
	if label: label.hide()

func interact() -> void:
	print("[NPC] interact() apelat!")
	if QuestManager.has_active_quest_from(npc_id):
		_deschide_quiz()
		return
	
	var quest = QuestManager.start_quest(npc_id)
	if not quest.is_empty():
		print("[NPC] Quest oferit: ", quest["title"])
	
	_deschide_quiz()

func _deschide_quiz() -> void:
	var quiz = get_tree().get_root().find_child("VBoxContainer", true, false)
	if quiz:
		quiz.visible = true
		quiz.start_quiz()
