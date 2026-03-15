extends Sprite2D

var frame_index: int = 0
var time_accum: float = 0.0

func _process(delta: float) -> void:
	time_accum += delta
	
	if time_accum >= 0.01:
		time_accum = 0.0
		
		frame_index += 1
		if frame_index > 99:
			frame_index = 0
		
		frame = frame_index
