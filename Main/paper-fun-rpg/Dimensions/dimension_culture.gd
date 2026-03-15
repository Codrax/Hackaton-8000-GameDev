extends Node2D

func _ready():
	if has_node("/root/BattleManager"):
		get_node("/root/BattleManager").cleanup_defeated_enemies()
