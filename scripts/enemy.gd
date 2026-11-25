class_name Enemy
extends Character

@export_group("Patrol")
@export var max_patrol_distance: float = 100.0

@export_group("AI / Chase")
@export var detection_range: float = 220.0
@export var chase_speed: float = 110.0

@export_group("Losowość / Wariancja")
@export_range(0.0, 100.0, 1.0, "suffix:%") var general_variation_percent: float = 0.0
@export_subgroup("Szczegółowe")
@export_range(0.0, 100.0, 1.0, "suffix:%") var size_variation_percent: float = 0.0
@export_range(0.0, 100.0, 1.0, "suffix:%") var speed_variation_percent: float = 0.0
@export_range(0.0, 100.0, 1.0, "suffix:%") var health_variation_percent: float = 0.0
@export_range(0.0, 100.0, 1.0, "suffix:%") var patrol_variation_percent: float = 0.0
@export_range(0.0, 100.0, 1.0, "suffix:%") var detection_variation_percent: float = 0.0
@export_range(0.0, 100.0, 1.0, "suffix:%") var bullet_damage_variation_percent: float = 0.0
@export_range(0.0, 100.0, 1.0, "suffix:%") var bullet_speed_variation_percent: float = 0.0

var target: Node2D = null
var is_chasing: bool = false

func _ready() -> void:
	super._ready()
	apply_random_variations()

func apply_random_variations() -> void:
	# Wielkość (skala):
	scale *= _apply_variation(1.0, _get_variation(size_variation_percent))
	
	# Prędkość poruszania się:
	var speed_pct: float = _get_variation(speed_variation_percent)
	speed = _apply_variation(speed, speed_pct)
	chase_speed = _apply_variation(chase_speed, speed_pct)
	
	# Maksymalne zdrowie i aktualne życie:
	max_health = int(_apply_variation(max_health, _get_variation(health_variation_percent)))
	health = max_health
	
	# Zasięg patrolu i wzroku:
	max_patrol_distance = _apply_variation(max_patrol_distance, _get_variation(patrol_variation_percent))
	detection_range = _apply_variation(detection_range, _get_variation(detection_variation_percent))
	
	# Statystyki pocisku (obrażenia i prędkość):
	var dmg_pct: float = _get_variation(bullet_damage_variation_percent)
	var b_speed_pct: float = _get_variation(bullet_speed_variation_percent)
	if projectile_data != null and (dmg_pct > 0.0 or b_speed_pct > 0.0):
		# klon aby nie nadpisac innych
		projectile_data = projectile_data.duplicate()
		projectile_data.damage = int(_apply_variation(projectile_data.damage, dmg_pct))
		projectile_data.speed = _apply_variation(projectile_data.speed, b_speed_pct)

func _get_variation(specific_percent: float) -> float:
	return specific_percent if specific_percent > 0.0 else general_variation_percent

func _apply_variation(base_value: float, percent: float) -> float:
	if percent <= 0.0:
		return base_value
	var ratio: float = percent / 100.0
	return base_value * randf_range(1.0 - ratio, 1.0 + ratio)

func _physics_process(_delta: float) -> void:
	var should_chase: bool = false
	var current_speed: float = speed
	
	if target != null and is_instance_valid(target):
		var is_target_alive: bool = not (target is Character and target.is_dying)
		var to_target: Vector2 = target.global_position - global_position
		
		if is_target_alive and to_target.length() <= detection_range:
			should_chase = true
			direction = to_target.normalized()
			current_speed = chase_speed
	
	if should_chase:
		is_chasing = true
	else:
		if is_chasing:
			is_chasing = false
			update_patrol_center()
			direction = Vector2.RIGHT if direction.x >= 0.0 else Vector2.LEFT
		
		current_speed = speed
		if direction.y != 0.0 or direction.x == 0.0:
			direction = Vector2.RIGHT
		
		var radius: float = get_sprite_radius()
		if global_position.x <= GameState.map_bounds.position.x + radius:
			direction = Vector2.RIGHT
		elif global_position.x >= GameState.map_bounds.end.x - radius:
			direction = Vector2.LEFT
		elif global_position.x > start_position.x + max_patrol_distance:
			direction = Vector2.LEFT
		elif global_position.x < start_position.x - max_patrol_distance:
			direction = Vector2.RIGHT
	
	velocity = direction * current_speed
	update_animations(velocity)
	move_and_slide()
	clamp_to_map_bounds()
	
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider is Player:
			collider.take_damage(collider.health)
			break
		if not is_chasing:
			var normal := col.get_normal()
			if direction.x > 0.0 and normal.x < -0.3:
				direction = Vector2.LEFT
				break
			elif direction.x < 0.0 and normal.x > 0.3:
				direction = Vector2.RIGHT
				break

func update_patrol_center() -> void:
	if not GameState.map_bounds.has_area():
		start_position = global_position
		return
	
	var radius: float = get_sprite_radius()
	var min_x: float = GameState.map_bounds.position.x + radius
	var max_x: float = GameState.map_bounds.end.x - radius
	var min_y: float = GameState.map_bounds.position.y + radius
	var max_y: float = GameState.map_bounds.end.y - radius
	
	start_position.x = clampf(global_position.x, min_x, max_x)
	start_position.y = clampf(global_position.y, min_y, max_y)

func die() -> void:
	GameState.add_score(1)
	super.die()

func _on_timer_timeout() -> void:
	if is_chasing and target != null and is_instance_valid(target):
		var shoot_dir: Vector2 = (target.global_position - global_position).normalized()
		shoot(shoot_dir)
	else:
		shoot(direction)
