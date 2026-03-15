extends CharacterBody2D

@export var follow_distance: float = 150.0
@export var min_speed: float = 120.0
@export var max_speed: float = 500.0
@export var time_to_sit: float = 4.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")

var player: Node2D
var idle_timer: float = 0.0
var random_timer: float = 0.0
var is_resting: bool = false

func _ready() -> void:
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		if not player:
			return

	var distance_to_player: float = global_position.distance_to(player.global_position)
	var direction: Vector2 = global_position.direction_to(player.global_position)

	if distance_to_player > follow_distance:
		var dynamic_speed: float = clamp(distance_to_player * 1.5, min_speed, max_speed)
		velocity = velocity.lerp(direction * dynamic_speed, 6.0 * delta)

		idle_timer = 0.0
		random_timer = 0.0
		is_resting = false

		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Run/blend_position", direction)
		animation_tree.set("parameters/HeadDown/blend_position", direction)
		animation_tree.set("parameters/Sit/blend_position", direction)

		anim_state.travel("Run")

	else:
		velocity = velocity.lerp(Vector2.ZERO, 15.0 * delta)

		if velocity.length() < 5.0:
			velocity = Vector2.ZERO

		idle_timer += delta
		random_timer -= delta

		if idle_timer >= time_to_sit:
			if not is_resting:
				anim_state.travel("Sit")
				is_resting = true
				random_timer = 2.0
			else:
				if random_timer <= 0.0:
					random_timer = 2.0
					if randf() < 0.2:
						anim_state.travel("Moan")
					else:
						anim_state.travel("Sit")
		else:
			if random_timer <= 0.0:
				random_timer = 1.0
				if randf() < 0.2:
					anim_state.travel("HeadDown")
				else:
					anim_state.travel("Idle")

	move_and_slide()
