extends TileMapLayer

@export var player: CharacterBody2D
@export var offset: int = -5

func _process(_delta):
	if not player:
		return

	# 1. Get the player's current tile position
	var player_cell = local_to_map(to_local(player.global_position))
	
	# 2. Check if there is actually a tile there
	var source_id = get_cell_source_id(player_cell)
	
	var new_z = 0
	if source_id != -1:
		var tile_world_pos = to_global(map_to_local(player_cell))
		if player.global_position.y < (tile_world_pos.y + offset):
			new_z = 1


	if z_index != new_z:
		z_index = new_z
