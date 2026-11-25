extends Node2D

@export_group("Spawner Pickupów")
@export var medkit_scene: PackedScene
@export var ammo_scene: PackedScene
@export_range(0, 50, 1) var max_pickups: int = 8

@onready var ground: TileMapLayer = $Ground
@onready var player: Player = $Player
@onready var hud: HUD = $HUD

func _ready() -> void:
	GameState.calculate_bounds(ground)
	GameState.reset_game()
	
	for child in get_children():
		if child is Pickup:
			child.add_to_group(Constants.GROUP_PICKUPS)
		elif child is Enemy:
			child.target = player
	
	if player != null:
		if hud != null:
			hud.setup(player)
		player.died.connect(_on_player_died)
		player.set_camera_limits()

func _on_player_died() -> void:
	var restart_timer := Timer.new()
	restart_timer.one_shot = true
	restart_timer.wait_time = 0.8
	restart_timer.timeout.connect(GameState.restart_game)
	add_child(restart_timer)
	restart_timer.start()

func spawn_pickup(scene: PackedScene) -> void:
	if scene == null:
		return
		
	var pickup := scene.instantiate() as Node2D
	pickup.add_to_group(Constants.GROUP_PICKUPS)
	
	var spawn_pos: Vector2 = GameState.get_random_map_position(64.0)
	if player != null:
		for attempt in 10:
			if spawn_pos.distance_to(player.global_position) >= 80.0:
				break
			spawn_pos = GameState.get_random_map_position(64.0)
	
	pickup.global_position = spawn_pos
	add_child(pickup)
	
	pickup.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(pickup, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_pickup_spawn_timer_timeout() -> void:
	if get_tree().get_node_count_in_group(Constants.GROUP_PICKUPS) >= max_pickups:
		return
	
	if randf() < 0.4:
		spawn_pickup(medkit_scene)
	else:
		spawn_pickup(ammo_scene)
