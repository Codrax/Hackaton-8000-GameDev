extends Node2D

var json_file_path: String = "res://Data/intrebari_npc.json"

@onready var question_label = $QuestionLabel
@onready var btn1 = $AnswersContainer/Button1
@onready var btn2 = $AnswersContainer/Button2
@onready var btn3 = $AnswersContainer/Button3
@onready var btn4 = $AnswersContainer/Button4

@onready var player_hp_label = $PlayerHP
@onready var enemy_hp_label = $EnemyHP

@onready var player_anim = $Player/AnimationTree.get("parameters/playback")
@onready var enemy_anim = $GoblinBase/AnimationPlayer

var player_hp: int = 3
var enemy_hp: int = 2

var questions: Array = []
var current_question: Dictionary = {}

func _ready():
	btn1.pressed.connect(func(): _check_answer(btn1.text))
	btn2.pressed.connect(func(): _check_answer(btn2.text))
	btn3.pressed.connect(func(): _check_answer(btn3.text))
	btn4.pressed.connect(func(): _check_answer(btn4.text))

	update_ui()
	load_json_data()
	next_question()

func load_json_data():
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			questions = json.data["intrebari"]
		else:
			print("Eroare la parsarea JSON-ului. Verifică formatul fișierului.")
	else:
		print("Nu s-a putut deschide fișierul JSON la calea: ", json_file_path)

func next_question():
	if questions.size() == 0:
		print("Nu mai sunt întrebări disponibile!")
		return

	current_question = questions.pick_random()
	question_label.text = current_question["intrebare"]

	var variants = current_question["variante"]
	
	btn1.text = variants[0]
	btn2.text = variants[1]
	btn3.text = variants[2]
	btn4.text = variants[3]

func _check_answer(selected_text: String):
	_set_buttons_disabled(true)

	if selected_text == current_question["raspuns_corect"]:
		# Răspuns Corect
		player_anim.travel("Attack")
		
		# Așteptăm să se termine animația de atac (ajustează timpul dacă e nevoie)
		await get_tree().create_timer(0.5).timeout
		
		# --- AICI E MODIFICAREA ---
		player_anim.travel("Idle") # Îl trimitem înapoi la Idle 🏃‍♂️
		# --------------------------
		
		enemy_anim.play("hit")
		enemy_hp -= 1
		update_ui()

		if enemy_hp <= 0:
			enemy_anim.play("death")
			await get_tree().create_timer(1.0).timeout 
			BattleManager.end_battle(true) 
			return
	else:
		# Răspuns Greșit
		enemy_anim.play("attack") 
		await get_tree().create_timer(0.5).timeout
		
		player_hp -= 1
		update_ui()

		if player_hp <= 0:
			await get_tree().create_timer(1.0).timeout
			BattleManager.end_battle(false) 
			return

	await get_tree().create_timer(1.0).timeout
	_set_buttons_disabled(false)
	next_question()

func update_ui():
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)

func _set_buttons_disabled(is_disabled: bool):
	btn1.disabled = is_disabled
	btn2.disabled = is_disabled
	btn3.disabled = is_disabled
	btn4.disabled = is_disabled
