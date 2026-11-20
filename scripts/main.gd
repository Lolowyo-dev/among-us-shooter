extends Node2D

@export var medkit_scene: PackedScene
@export var ammo_scene: PackedScene
@export var max_pickups: int = 8

@onready var ground: TileMapLayer = $Ground
@onready var player: Player = $Player
@onready var hud: HUD = $HUD

func _ready() -> void:
	GameState.calculate_bounds(ground)
	GameState.reset_game()
	
	for child in get_children():
		if child is Medkit or child is AmmoPickup:
			child.add_to_group(Constants.GROUP_PICKUPS)
		elif child is Enemy:
			child.target = player
	
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
		
	var pickup := scene.instantiate() as Node2D
	pickup.add_to_group(Constants.GROUP_PICKUPS)
	
	var spawn_pos := GameState.get_random_map_position(64.0)
	if player != null and spawn_pos.distance_to(player.global_position) < 80.0:
		spawn_pos = GameState.get_random_map_position(64.0)
	
	pickup.global_position = GameState.get_random_map_position()
	add_child(pickup)
	
	pickup.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(pickup, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_spawn_timer_timeout() -> void:
	if randf() < 0.4:
		spawn_pickup(medkit_scene)
	else:
		spawn_pickup(ammo_scene)
