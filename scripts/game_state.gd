extends Node

signal score_changed(new_score: int)

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const MENU_SCENE_PATH: String = "res://scenes/main_menu.tscn"
const DEFAULT_DIFFICULTY_PATH: String = "res://resources/normal.tres"

var is_game_ended: bool = false

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var current_difficulty: DifficultySettings = null

func get_difficulty() -> DifficultySettings:
	if current_difficulty == null:
		current_difficulty = load(DEFAULT_DIFFICULTY_PATH) as DifficultySettings
	return current_difficulty

func add_score(points: int = 1) -> void:
	score += points

func reset_game() -> void:
	score = 0
	is_game_ended = false

func restart_game() -> void:
	reset_game()
	get_tree().reload_current_scene()

func start_game() -> void:
	reset_game()
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func go_to_main_menu() -> void:
	reset_game()
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

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
