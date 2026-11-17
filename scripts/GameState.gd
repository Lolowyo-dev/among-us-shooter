extends Node

signal score_changed(new_score: int)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

func add_score(points: int = 1) -> void:
	score += points

func reset_game() -> void:
	score = 0

var map_bounds: Rect2

func calculate_bounds(ground: TileMapLayer) -> void:
	if ground != null and ground.tile_set != null:
		var used_rect: Rect2i = ground.get_used_rect()
		var tile_size: Vector2i = ground.tile_set.tile_size
		map_bounds.position = Vector2(used_rect.position * tile_size) * ground.scale + ground.global_position
		map_bounds.size = Vector2(used_rect.size * tile_size) * ground.scale

func get_random_map_position(margin: float = 32.0) -> Vector2:
	var rand_x: float = randf_range(map_bounds.position.x + margin, map_bounds.end.x - margin)
	var rand_y: float = randf_range(map_bounds.position.y + margin, map_bounds.end.y - margin)
	return Vector2(rand_x, rand_y)
