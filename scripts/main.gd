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

var enemies_remaining: int = 0
var is_game_ended: bool = false

func _ready() -> void:
	GameState.calculate_bounds(ground)
	GameState.reset_game()
	
	for child in get_children():
		if child is Pickup:
			child.add_to_group(Constants.GROUP_PICKUPS)
		elif child is Enemy:
			child.target = player
			enemies_remaining += 1
			child.tree_exited.connect(_on_enemy_removed)
	
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

func _on_player_died() -> void:
	if is_game_ended:
		return
	is_game_ended = true
	_start_end_screen_timer(false, 0.8)

func _on_enemy_removed() -> void:
	if is_game_ended or not is_inside_tree():
		return
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		is_game_ended = true
		_start_end_screen_timer(true, 0.6)

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
