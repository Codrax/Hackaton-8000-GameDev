# QuestUI.gd — atașează la un CanvasLayer > PanelContainer (colț dreapta-jos)
extends PanelContainer

@onready var label_titlu = $VBox/LabelTitlu
@onready var label_desc = $VBox/LabelDesc
@onready var label_progress = $VBox/LabelProgress
@onready var progress_bar = $VBox/ProgressBar

func _ready() -> void:
	visible = false
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_progress_updated.connect(_on_quest_progress)
	QuestManager.quest_completed.connect(_on_quest_completed)

func _on_quest_started(quest: Dictionary) -> void:
	print("[QuestUI] Quest primit: ", quest["title"])
	label_titlu.text = "📜 " + quest["title"]
	label_desc.text = quest["description"]
	progress_bar.max_value = quest["target_count"]
	progress_bar.value = 0
	label_progress.text = "0 / %d" % quest["target_count"]
	visible = true

func _on_quest_progress(_quest_id: String, current: int, target: int) -> void:
	progress_bar.value = current
	label_progress.text = "%d / %d" % [current, target]

func _on_quest_completed(quest: Dictionary) -> void:
	label_titlu.text = "✅ " + quest["title"] + " — COMPLETAT!"
	label_desc.text = ""
	label_progress.text = ""
	await get_tree().create_timer(3.0).timeout
	visible = false
