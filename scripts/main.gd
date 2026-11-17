extends Node2D

@export var medkit_scene: PackedScene
@export var ammo_scene: PackedScene

@onready var ground: TileMapLayer = $Ground
@onready var player: Player = $Player
@onready var hud: HUD = $HUD

func _ready() -> void:
	GameState.calculate_bounds(ground)
	GameState.reset_game()
	
	if player != null:
		if hud != null:
			hud.setup(player)
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
