extends Control

@onready var label: RichTextLabel = $Label
@onready var background: NinePatchRect = $Background
@onready var container: Control = $"../Control"
@onready var container_loading: Sprite2D = $"../ControlLoading"


func _ready():
	# label.autowrap = true
	call_deferred("_update_bubble_size")
	
	update_text_loop()

func set_text(text: String) -> void:
	label.text = text.strip_edges()
	call_deferred("_update_bubble_size")

func _update_bubble_size():
	return

# Main AI loop
func update_text_loop() -> void:
	while true:
		container_loading.visible = true
		container.visible = false
		
		# Reset AI
		# await AI.reset_model()
		
		# Call AI API (replace AI.send_message with your function)
		const prompt = "You are a cat. Always speak like a clever, mischievous cat. Include meows, purrs, or playful cat behavior in every reply"
		var response_text = await AI.send_message(prompt)
		container_loading.visible = false
		
		if response_text.strip_edges() != "":
			set_text(response_text)
			container.visible = true
			await get_tree().create_timer(10.0).timeout
			container.visible = false
		else:
			print("Response is empty!!")
		
		# Wait random 30-300 seconds
		var wait_time = randi() % 100 + 30  # 30..300
		await get_tree().create_timer(wait_time).timeout
