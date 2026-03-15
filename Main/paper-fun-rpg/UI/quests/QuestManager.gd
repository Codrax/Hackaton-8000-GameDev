extends Node

signal quest_started(quest: Dictionary)
signal quest_progress_updated(quest_id: String, current: int, target: int)
signal quest_completed(quest: Dictionary)

var active_quests: Dictionary = {}

var quest_definitions: Array = [
	{
		"id": "kill_goblins",
		"npc_id": "goblin_npc",
		"title": "Vânătorul de goblini",
		"description": "Omoară 5 goblini din pădurea din est.",
		"type": "kill",
		"target_tag": "goblin",
		"target_count": 5,
		"progress": 0,
	},
	{
		"id": "alfred_questions",
		"npc_id": "npc_beginner",
		"title": "Testul lui Alfred",
		"description": "Răspunde corect la 3 întrebări ale lui Alfred.",
		"type": "quiz_correct",
		"target_count": 3,
		"progress": 0,
	},
]

func get_quest_for_npc(npc_id: String) -> Dictionary:
	for q in quest_definitions:
		if q["npc_id"] == npc_id:
			return q
	return {}

func has_active_quest_from(npc_id: String) -> bool:
	return active_quests.has(npc_id)

func start_quest(npc_id: String) -> Dictionary:
	if has_active_quest_from(npc_id):
		return active_quests[npc_id]
	
	var quest = get_quest_for_npc(npc_id)
	if quest.is_empty():
		return {}
	
	var quest_activ = quest.duplicate(true)
	quest_activ["progress"] = 0
	active_quests[npc_id] = quest_activ
	
	emit_signal("quest_started", quest_activ)
	print("[QuestManager] Quest pornit: ", quest_activ["title"])
	return quest_activ

func report_progress(quest_type: String, tag: String = "") -> void:
	print("[QuestManager] report_progress apelat: ", quest_type)
	for npc_id in active_quests:
		var q = active_quests[npc_id]
		if q["type"] != quest_type:
			continue
		if quest_type == "kill" and q.get("target_tag", "") != tag:
			continue
		
		q["progress"] = min(q["progress"] + 1, q["target_count"])
		emit_signal("quest_progress_updated", q["id"], q["progress"], q["target_count"])
		print("[QuestManager] Progress: %d/%d" % [q["progress"], q["target_count"]])
		
		if q["progress"] >= q["target_count"]:
			_complete_quest(npc_id)

func _complete_quest(npc_id: String) -> void:
	var q = active_quests[npc_id]
	emit_signal("quest_completed", q)
	active_quests.erase(npc_id)
	print("[QuestManager] Quest completat: ", q["title"])
