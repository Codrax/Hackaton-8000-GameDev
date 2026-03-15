extends VBoxContainer
var intrebari: Array = []
var intrebare_curenta: Dictionary = {}
var scor: int = 0
var total: int = 0
var index_curent: int = 0
@onready var player = $"../Player"
@onready var camera = $"../Player/Camera2D"
@onready var label_intrebare = $LabelIntrebare
@onready var btn_a = $HBoxContainer/BtnA
@onready var btn_b = $HBoxContainer/BtnB
@onready var btn_c = $HBoxContainer/BtnC
@onready var btn_d = $HBoxContainer/BtnD
@onready var label_feedback = $LabelFeedback
@onready var label_scor = $LabelScor
func _ready() -> void:
	visible=false
	incarca_intrebari()
	btn_a.pressed.connect(func(): verifica_raspuns(0))
	btn_b.pressed.connect(func(): verifica_raspuns(1))
	btn_c.pressed.connect(func(): verifica_raspuns(2))
	btn_d.pressed.connect(func(): verifica_raspuns(3))
	
func _process(_delta):
	if player:
		global_position = player.global_position + Vector2(0, 100)
func incarca_intrebari() -> void:
	var file = FileAccess.open("res://NPCs/intrebari_npc.json", FileAccess.READ)
	if file == null:
		print("Fisierul nu a fost gasit!")
		return
	var continut = file.get_as_text()
	file.close()
	var json = JSON.new()
	var eroare = json.parse(continut)
	if eroare != OK:
		print("Eroare la parsarea JSON!")
		return
	intrebari = json.get_data()["intrebari"]
	intrebari.shuffle()
	total = intrebari.size()
	arata_intrebare()
func arata_intrebare() -> void:
	if index_curent >= total:
		sfarsit_quiz()
		return
	intrebare_curenta = intrebari[index_curent]
	label_intrebare.text = "(%d/%d)  %s" % [index_curent + 1, total, intrebare_curenta["intrebare"]]
	var variante = intrebare_curenta["variante"]
	btn_a.text = "A)  " + variante[0]
	btn_b.text = "B)  " + variante[1]
	btn_c.text = "C)  " + variante[2]
	btn_d.text = "D)  " + variante[3]
	for btn in [btn_a, btn_b, btn_c, btn_d]:
		btn.disabled = false
		btn.modulate = Color.WHITE
		btn.show()
	label_feedback.text = ""
	label_scor.text = "Scor:  %d / %d" % [scor, index_curent]
func verifica_raspuns(index: int) -> void:
	if intrebare_curenta.is_empty():
		return
	if not intrebare_curenta.has("variante"):
		return
	var variante = intrebare_curenta["variante"]
	var raspuns_ales = variante[index]
	var raspuns_corect = intrebare_curenta["raspuns_corect"]
	for btn in [btn_a, btn_b, btn_c, btn_d]:
		btn.disabled = true
	var butoane = [btn_a, btn_b, btn_c, btn_d]
	var index_corect = variante.find(raspuns_corect)
	if raspuns_ales == raspuns_corect:
		butoane[index].modulate = Color.GREEN
		scor += 1
		QuestManager.report_progress("quiz_correct")
		label_feedback.text = "✓ Corect!"
		label_feedback.modulate = Color.GREEN
	else:
		butoane[index].modulate = Color.RED
		if index_corect != -1:
			butoane[index_corect].modulate = Color.GREEN
		label_feedback.text = "✗ Greșit! Răspuns corect: " + raspuns_corect
		label_feedback.modulate = Color.RED
	label_scor.text = "Scor:  %d / %d" % [scor, index_curent + 1]
	index_curent += 1
	await get_tree().create_timer(2.0).timeout
	arata_intrebare()
func sfarsit_quiz() -> void:
	label_intrebare.text = "Quiz terminat! 🎉"
	label_feedback.text = ""
	var procent = round(float(scor) / float(total) * 100)
	label_scor.text = "Scor final: %d/%d (%d%%)" % [scor, total, procent]
	for btn in [btn_a, btn_b, btn_c, btn_d]:
		btn.hide()
func start_quiz() -> void:
	scor = 0
	index_curent = 0
	intrebari.shuffle()
	label_feedback.text = ""
	for btn in [btn_a, btn_b, btn_c, btn_d]:
		btn.show()
		btn.modulate = Color.WHITE
	arata_intrebare()
