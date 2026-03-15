extends CanvasLayer

signal battle_finished

@onready var hp_panel = $HPPanel
@onready var hp_label = $HPPanel/HPLabel
@onready var hp_bar = $HPPanel/HPBar

@onready var question_panel = $QuestionPanel
@onready var question_label = $QuestionPanel/QuestionLabel
@onready var answers_container = $QuestionPanel/AnswersContainer

@onready var answer_button_1 = $QuestionPanel/AnswersContainer/AnswerButton1
@onready var answer_button_2 = $QuestionPanel/AnswersContainer/AnswerButton2
@onready var answer_button_3 = $QuestionPanel/AnswersContainer/AnswerButton3
@onready var answer_button_4 = $QuestionPanel/AnswersContainer/AnswerButton4

@onready var ask_ai_popup = $AskAIPopup
@onready var popup_label = $AskAIPopup/PopupLabel

var current_goblin = null
var current_question_index: int = 0

var questions = [
	{
		"question": "Care este capitala Franței?",
		"answers": ["Paris", "Roma", "Berlin", "Madrid"],
		"correct": "Paris"
	},
	{
		"question": "Ce planetă este cunoscută ca Planeta Roșie?",
		"answers": ["Venus", "Marte", "Jupiter", "Mercur"],
		"correct": "Marte"
	},
	{
		"question": "Cât face 7 x 8?",
		"answers": ["54", "56", "64", "48"],
		"correct": "56"
	}
]

func _ready() -> void:
	visible = false
	ask_ai_popup.visible = false

	answer_button_1.pressed.connect(func(): _on_answer_pressed(answer_button_1))
	answer_button_2.pressed.connect(func(): _on_answer_pressed(answer_button_2))
	answer_button_3.pressed.connect(func(): _on_answer_pressed(answer_button_3))
	answer_button_4.pressed.connect(func(): _on_answer_pressed(answer_button_4))

func start_battle(goblin) -> void:
	current_goblin = goblin
	current_question_index = 0

	visible = true
	hp_panel.visible = true
	question_panel.visible = true
	ask_ai_popup.visible = false

	hp_label.text = "Goblin HP"
	hp_bar.max_value = goblin.max_hp
	hp_bar.value = goblin.current_hp

	show_question()

func show_question() -> void:
	if current_question_index >= questions.size():
		end_battle()
		return

	var q = questions[current_question_index]
	question_label.text = q["question"]

	var buttons = [
		answer_button_1,
		answer_button_2,
		answer_button_3,
		answer_button_4
	]

	for i in range(buttons.size()):
		buttons[i].text = q["answers"][i]
		buttons[i].visible = true
		buttons[i].disabled = false

	ask_ai_popup.visible = false

func _on_answer_pressed(button: Button) -> void:
	if current_goblin == null:
		return

	var q = questions[current_question_index]
	var selected_answer = button.text
	var correct_answer = q["correct"]

	if selected_answer == correct_answer:
		current_goblin.take_damage(1)
		hp_bar.value = current_goblin.current_hp

		if current_goblin.current_hp <= 0:
			end_battle()
			return

		current_question_index += 1
		show_question()
	else:
		button.visible = false
		ask_ai_popup.visible = true
		popup_label.text = "Răspuns greșit! Poți folosi butonul „Întreabă AI-ul”."
		check_if_no_answers_left()

func check_if_no_answers_left() -> void:
	var visible_count := 0

	for child in answers_container.get_children():
		if child is Button and child.visible:
			visible_count += 1

	if visible_count == 0:
		end_battle()

func end_battle() -> void:
	visible = false
	ask_ai_popup.visible = false

	if current_goblin != null and current_goblin.current_hp > 0:
		current_goblin.reset_battle_state()

	current_goblin = null
	emit_signal("battle_finished")
