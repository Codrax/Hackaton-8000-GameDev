extends CharacterBody2D

@export var speed: float = 300.0
@export var sprint_multiplier: float = 1.5
@onready var animation_tree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")

func _physics_process(_delta):		
	# 1. Get Input Vector (if not doing attack animation)
	var input_vector = Vector2.ZERO
	if anim_state.get_current_node() != "Attack":
		input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	# 2. Apply Speed Multiplier if Shift is held
	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier  # run faster

	# 3. Apply Movement
	if input_vector.length() > 0.1:  # small deadzone
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		anim_state.travel("Run")
		velocity = input_vector * current_speed
	else:
		anim_state.travel("Idle")
		velocity = Vector2.ZERO

	# 4. Handle Attack
	if Input.is_action_just_pressed("attack"):
		anim_state.travel("Attack")

	move_and_slide()
