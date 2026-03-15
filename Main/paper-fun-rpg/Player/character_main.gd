extends CharacterBody2D

@export var speed: float = 300.0
@export var sprint_multiplier: float = 1.5

@onready var animation_tree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")

var interactable_target = null
var enemy_target = null

func _physics_process(_delta):
	# Oprește complet playerul când jocul este în pauză
	if get_tree().paused:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# If the user is typing in a TextEdit, don't move
	if get_viewport().gui_get_focus_owner() is Control:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Vector2.ZERO

	if anim_state.get_current_node() != "Attack":
		input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_vector = input_vector.normalized()

	var current_speed := speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier

	if input_vector.length() > 0.1:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		anim_state.travel("Run")
		velocity = input_vector * current_speed
	else:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	if Input.is_action_just_pressed("attack"):
		anim_state.travel("Attack")
		BattleManager.battle_start(1)

	move_and_slide()

func _input(event):
	# Blochează interacțiunea cât timp jocul este în pauză
	if get_tree().paused:
		return

	if event.is_action_pressed("interact") and interactable_target:
		interactable_target.interact()

func _on_interaction_area_area_entered(area):
	print("Area2D-ul meu a atins ceva: ", area.name) # Test general
	
	if area.has_method("interact"):
		interactable_target = area
		
	if area.is_in_group("enemy"):
		print("Am confirmat că are grupul enemy!") # Test specific
		enemy_target = area

func _on_interaction_area_area_exited(area):
	if interactable_target == area:
		interactable_target = null
		
	if enemy_target == area:
		enemy_target = null
