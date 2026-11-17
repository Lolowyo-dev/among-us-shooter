extends Node2D

@export var medkit_scene: PackedScene
@export var ammo_scene: PackedScene

@onready var ground: TileMapLayer = $Ground

func _ready() -> void:
	GameState.calculate_bounds(ground)
	GameState.reset_game()
	
	var player = get_tree().get_first_node_in_group(Constants.GROUP_PLAYER)
	if player and player is Player:
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	await get_tree().create_timer(0.8).timeout
	GameState.restart_game()

func spawn_pickup(scene: PackedScene) -> void:
	if scene == null:
		return
	var pickup = scene.instantiate()
	pickup.global_position = GameState.get_random_map_position()
	add_child(pickup)

func _on_spawn_timer_timeout() -> void:
	if randf() < 0.4:
		spawn_pickup(medkit_scene)
	else:
		spawn_pickup(ammo_scene)
