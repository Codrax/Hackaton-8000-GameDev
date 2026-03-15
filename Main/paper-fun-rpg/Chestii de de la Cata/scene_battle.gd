extends Node2D

@onready var player = $Player
@onready var goblin = $GoblinBase
@onready var battle_ui = $BattleUI

func _ready() -> void:
	goblin.battle_started.connect(_on_goblin_battle_started)
	goblin.goblin_died.connect(_on_goblin_died)
	battle_ui.battle_finished.connect(_on_battle_finished)

func _on_goblin_battle_started(goblin_ref) -> void:
	if "can_move" in player:
		player.can_move = false
	battle_ui.start_battle(goblin_ref)

func _on_goblin_died(_goblin_ref) -> void:
	print("Goblin defeated!")

func _on_battle_finished() -> void:
	if "can_move" in player:
		player.can_move = true
