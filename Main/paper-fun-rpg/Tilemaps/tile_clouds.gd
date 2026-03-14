extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@export var speed: float = 30.0
@export var reset_x: float = 10000
@export var start_x: float = -10000

func _process(delta: float) -> void:
	position.x -= speed * delta
	
	if position.x < -reset_x:
		position.x = start_x
