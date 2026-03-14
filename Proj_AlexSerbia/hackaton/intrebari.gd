extends VBoxContainer

var intrebari: Array = []
var intrebare_curenta: Dictionary = {}
var scor: int = 0
var total: int = 0
var index_curent: int = 0

@onready var label_intrebare = $LabelIntrebare
@onready var btn_a = $HBoxContainer/BtnA
@onready var btn_b = $HBoxContainer/BtnB
@onready var btn_c = $HBoxContainer/BtnC
@onready var btn_d = $HBoxContainer/BtnD
@onready var label_feedback = $LabelFeedback
@onready var label_scor = $LabelScor

func _ready() -> void:
	incarca_intrebari()
	btn_a.pressed.connect(func(): verifica_raspuns(0))
	btn_b.pressed.connect(func(): verifica_raspuns(1))
	btn_c.pressed.connect(func(): verifica_raspuns(2))
	btn_d.pressed.connect(func(): verifica_raspuns(3))

func incarca_intrebari() -> void:
	var file = FileAccess.open("res://intrebari_npc.json", FileAccess.READ)
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
	print("Intrebare curenta: ", intrebare_curenta)  # debug
	
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
		
	if raspuns_ales == raspuns_corect:
		scor += 1
		label_feedback.text = "✓ Corect!"
		label_feedback.modulate = Color.GREEN
	else:
		label_feedback.text = "✗ Gresit! Raspuns corect: " + raspuns_corect
		label_feedback.modulate = Color.RED
		
	index_curent += 1
	await get_tree().create_timer(2.0).timeout
	arata_intrebare()
func sfarsit_quiz() -> void:
	label_intrebare.text = "Quiz terminat!"
	label_feedback.text = ""
	var procent = round(float(scor) / float(total) * 100)
	label_scor.text = "Scor final: %d/%d (%d%%)" % [scor, total, procent]
	for btn in [btn_a, btn_b, btn_c, btn_d]:
		btn.hide()

func start_quiz() -> void:
	scor = 0
	index_curent = 0
	intrebari.shuffle()
	for btn in [btn_a, btn_b, btn_c, btn_d]:
		btn.show()
	arata_intrebare()
