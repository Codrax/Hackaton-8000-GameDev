extends CharacterBody2D
@onready var animated_idle_lr: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0

func _physics_process(_delta: float) -> void:
	# Am înlocuit "ui_left", etc. cu noile tale acțiuni personalizate
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	

	print(direction)
	
	#get the direction the player is moving
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
	
	var direction_X = Input.get_axis("move_left","move_right");
	var direction_Y = Input.get_axis("move_down","move_up");
	
	#flip the sprite
	if direction_X > 0:
		animated_idle_lr.flip_h = false
	elif direction_X < 0:
		animated_idle_lr.flip_h = true
