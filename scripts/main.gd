extends Node2D

@export_group("Spawner Pickupów")
@export var medkit_scene: PackedScene
@export var ammo_scene: PackedScene
@export_range(0, 50, 1) var max_pickups: int = 8

@onready var ground: TileMapLayer = $Ground
@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var pause_menu: PauseMenu = $PauseMenu

var difficulty: DifficultySettings
var round_timer: Timer
var enemy_spawn_timer: Timer

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
	
	if game_over_screen != null:
		game_over_screen.restart_requested.connect(_on_restart_requested)
		game_over_screen.menu_requested.connect(_on_menu_requested)
	
	if pause_menu != null:
		pause_menu.restart_requested.connect(_on_restart_requested)
		pause_menu.menu_requested.connect(_on_menu_requested)
	
	difficulty = GameState.get_difficulty()
	_setup_timers()
	# przeciwnik od poczatku
	_on_enemy_spawn_timer_timeout()

func _setup_timers() -> void:
	round_timer = Timer.new()
	round_timer.one_shot = true
	round_timer.wait_time = difficulty.round_duration
	round_timer.timeout.connect(_on_round_timer_timeout)
	add_child(round_timer)
	round_timer.start()
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = difficulty.spawn_interval
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	add_child(enemy_spawn_timer)
	enemy_spawn_timer.start()
	if hud != null:
		hud.update_timer(difficulty.round_duration)

func _process(_delta: float) -> void:
	if not GameState.is_game_ended and round_timer != null and hud != null:
		hud.update_timer(round_timer.time_left)

func _on_round_timer_timeout() -> void:
	if GameState.is_game_ended:
		return
	GameState.is_game_ended = true
	if hud != null:
		hud.update_timer(0.0)
	_show_end_screen(true)

func _on_enemy_spawn_timer_timeout() -> void:
	if GameState.is_game_ended or difficulty == null or difficulty.enemy_scene == null:
		return
	if get_tree().get_node_count_in_group(Constants.GROUP_ENEMIES) >= difficulty.max_enemies:
		return
	
	var enemy := difficulty.enemy_scene.instantiate() as Enemy
	if enemy == null:
		return
	
	enemy.global_position = _get_safe_spawn_position(100.0, 140.0)
	enemy.target = player
	enemy.difficulty = difficulty
	add_child(enemy)

func _get_safe_spawn_position(margin: float, min_player_dist: float) -> Vector2:
	var spawn_pos: Vector2 = GameState.get_random_map_position(margin)
	if player != null:
		for attempt in 10:
			if spawn_pos.distance_to(player.global_position) >= min_player_dist:
				break
			spawn_pos = GameState.get_random_map_position(margin)
	return spawn_pos

func _on_player_died() -> void:
	if GameState.is_game_ended:
		return
	GameState.is_game_ended = true
	_start_end_screen_timer(false, 0.8)

func _start_end_screen_timer(is_victory: bool, delay: float) -> void:
	var end_timer := Timer.new()
	end_timer.one_shot = true
	end_timer.wait_time = delay
	end_timer.timeout.connect(_show_end_screen.bind(is_victory))
	add_child(end_timer)
	end_timer.start()

func _show_end_screen(is_victory: bool) -> void:
	if pause_menu != null:
		pause_menu.enabled = false
	get_tree().paused = true
	if game_over_screen != null:
		game_over_screen.show_screen(is_victory, GameState.score)

func _on_restart_requested() -> void:
	get_tree().paused = false
	GameState.restart_game()

func _on_menu_requested() -> void:
	get_tree().paused = false
	GameState.go_to_main_menu()

func spawn_pickup(scene: PackedScene) -> void:
	if scene == null:
		return
		
	var pickup := scene.instantiate() as Node2D
	pickup.add_to_group(Constants.GROUP_PICKUPS)
	
	pickup.global_position = _get_safe_spawn_position(64.0, 80.0)
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
