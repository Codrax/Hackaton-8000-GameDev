extends CharacterBody2D

@export var speed: float = 300.0
@onready var animation_tree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	# 1. Get Input Vector
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	# 2. Apply Movement
	# Inside _physics_process
	if input_vector.length() > 0.1: # Use a small deadzone
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		anim_state.travel("Run")
		velocity = input_vector * speed
	else:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO
	# 3. Handle Attack
	if Input.is_action_just_pressed("attack"):
		anim_state.travel("Attack")
	move_and_slide()
