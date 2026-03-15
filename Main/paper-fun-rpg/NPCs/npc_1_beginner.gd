extends Area2D

func interact() -> void:
	var quiz = get_tree().get_root().find_child("VBoxContainer", true, false)
	if quiz:
		quiz.visible = true
		quiz.start_quiz()
