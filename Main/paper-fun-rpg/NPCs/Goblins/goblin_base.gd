extends CharacterBody2D # Sau Area2D, depinde cum e structurat la tine

@export var min_flip_time: float = 1.0
@export var max_flip_time: float = 4.0

@onready var anim_player = $AnimationPlayer
@onready var state_timer = $Timer
@onready var sprite = $Sprite2D
@onready var label = $InteractionLabel # Asigură-te că ai acest nod!

var current_state: String = "idle"

func _ready():
	add_to_group("enemies") # Important pentru logica de attack
	if label: label.hide()
	anim_player.play("idle")
	schedule_next_flip()

func _physics_process(delta):
	if current_state == "dead":
		return
	move_and_slide()

func schedule_next_flip():
	if current_state == "dead": return
	state_timer.wait_time = randf_range(min_flip_time, max_flip_time)
	state_timer.start()

func _on_timer_timeout():
	if current_state == "idle":
		sprite.flip_h = !sprite.flip_h
		schedule_next_flip()

func die():
	current_state = "dead"
	if label: label.hide() # Ascundem textul la moarte
	velocity = Vector2.ZERO
	state_timer.stop()
	anim_player.play("death")
