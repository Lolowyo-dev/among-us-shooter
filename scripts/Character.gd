class_name Character
extends CharacterBody2D

@export_group("Ruch i Animacja")
@export_range(0.0, 1000.0, 5.0, "suffix:px/s") var speed: float = 175.0
@export_range(0.05, 2.0, 0.05, "suffix:s") var walk_cycle_time: float = 0.3

@export_group("Zdrowie i Efekty")
@export_range(1, 10000, 1) var max_health: int = 100
@export var explosion_scene: PackedScene

@export_group("Walka / Pocisk")
@export_range(0.05, 5.0, 0.05, "suffix:s") var shoot_cooldown: float = 0.35
@export var projectile_data: ProjectileData

const BASE_SPEED: float = 175.0

@onready var sprite_upper: AnimatedSprite2D = $SpriteUpper
@onready var sprite_bottom: AnimatedSprite2D = $SpriteBottom
@onready var fire_point: Marker2D = $SpriteUpper/FirePoint

@onready var shoot_sound: AudioStreamPlayer2D = get_node_or_null("ShootSound")
@onready var hit_sound: AudioStreamPlayer2D = get_node_or_null("HitSound")
@onready var glow: Sprite2D = get_node_or_null("Glow")
var glow_tween: Tween
var shoot_timer: Timer
enum ShootPhase { IDLE, CLOSING_EYE, OPENING_EYE }
var shoot_phase: ShootPhase = ShootPhase.IDLE
var current_shoot_anim: String = ""

var health: int = 100
var direction: Vector2 = Vector2.RIGHT
var look_direction: Vector2 = Vector2.RIGHT
var current_dir_name: String = "side"
var is_shooting: bool = false
var is_dying: bool = false
var start_position: Vector2

func _ready() -> void:
	start_position = global_position
	health = max_health
	
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	add_child(shoot_timer)
	
	if sprite_upper:
		sprite_upper.animation_finished.connect(_on_sprite_upper_animation_finished)

func update_animations(move_dir: Vector2, aiming_dir: Vector2 = Vector2.ZERO) -> void:
	var is_aiming: bool = (aiming_dir != Vector2.ZERO)
	var active_dir: Vector2 = aiming_dir if is_aiming else move_dir
	
	# Ustalenie strony gdy nie strzela
	if active_dir != Vector2.ZERO and not is_shooting:
		if abs(active_dir.y) > abs(active_dir.x):
			current_dir_name = "up" if active_dir.y < 0 else "down"
			sprite_bottom.flip_h = false
			sprite_upper.flip_h = false
		else:
			current_dir_name = "side"
			var is_left: bool = active_dir.x < 0
			sprite_bottom.flip_h = is_left
			sprite_upper.flip_h = is_left
	
	# Animacja ruchu
	if move_dir != Vector2.ZERO:
		var anim_name: String = "walking_" + current_dir_name
		var frames: int = sprite_bottom.sprite_frames.get_frame_count(anim_name)
		var fps: float = sprite_bottom.sprite_frames.get_animation_speed(anim_name)
		if fps > 0.0 and walk_cycle_time > 0.0:
			var default_duration: float = frames / fps
			var speed_ratio: float = velocity.length() / BASE_SPEED
			sprite_bottom.speed_scale = (default_duration / walk_cycle_time) * speed_ratio
		else:
			sprite_bottom.speed_scale = 1.0
		sprite_bottom.play(anim_name)
	else:
		sprite_bottom.speed_scale = 1.0
		sprite_bottom.play("idle_" + current_dir_name)
	
	if shoot_phase == ShootPhase.IDLE:
		sprite_upper.play("idle_" + current_dir_name)

func can_shoot() -> bool:
	return not is_dying and projectile_data != null and projectile_data.scene != null and shoot_timer.is_stopped()

func shoot(shoot_dir: Vector2) -> void:
	if not can_shoot():
		return
	
	shoot_timer.start(shoot_cooldown)
	is_shooting = true
	
	# kierunek strzalu
	current_shoot_anim = "shoot_side"
	if shoot_dir != Vector2.ZERO:
		look_direction = shoot_dir
		if abs(shoot_dir.y) > abs(shoot_dir.x):
			current_shoot_anim = "shoot_up" if shoot_dir.y < 0 else "shoot_down"
			current_dir_name = "up" if shoot_dir.y < 0 else "down"
			sprite_upper.flip_h = false
			sprite_bottom.flip_h = false
			fire_point.position = Vector2(0, -11) if shoot_dir.y < 0 else Vector2(0, 11)
		else:
			current_shoot_anim = "shoot_side"
			current_dir_name = "side"
			var is_left: bool = shoot_dir.x < 0
			sprite_upper.flip_h = is_left
			sprite_bottom.flip_h = is_left
			fire_point.position = Vector2(11 * sign(shoot_dir.x), -4) 
	
	var frames: int = sprite_upper.sprite_frames.get_frame_count(current_shoot_anim)
	
	var half_time: float = minf(shoot_cooldown * 0.45, 0.25)
	var fps: float = sprite_upper.sprite_frames.get_animation_speed(current_shoot_anim)
	if fps > 0.0 and half_time > 0.0:
		sprite_upper.speed_scale = (frames / fps) / half_time
	else:
		sprite_upper.speed_scale = 1.0
	
	shoot_phase = ShootPhase.CLOSING_EYE
	sprite_upper.play(current_shoot_anim)

func spawn_bullet() -> void:
	if projectile_data == null or projectile_data.scene == null:
		return
	
	var bullet := projectile_data.scene.instantiate() as Bullet
	if bullet == null:
		push_error("Błąd: Scena w ProjectileData musi dziedziczyć po Bullet!")
		return
	
	bullet.global_position = fire_point.global_position
	bullet.setup(projectile_data, look_direction)
	get_tree().current_scene.add_child(bullet)
	
	if shoot_sound:
		shoot_sound.play()

func _on_sprite_upper_animation_finished() -> void:
	match shoot_phase:
		ShootPhase.CLOSING_EYE:
			spawn_bullet()
			shoot_phase = ShootPhase.OPENING_EYE
			sprite_upper.play_backwards(current_shoot_anim)
		
		ShootPhase.OPENING_EYE:
			shoot_phase = ShootPhase.IDLE
			is_shooting = false
			sprite_upper.speed_scale = 1.0
			sprite_upper.play("idle_" + current_dir_name)

func show_glow(color: Color) -> void:
	if glow == null:
		return
	if glow_tween and glow_tween.is_valid():
		glow_tween.kill()
	
	glow.modulate = Color(color.r, color.g, color.b, 0.75)
	glow_tween = create_tween()
	glow_tween.tween_property(glow, "modulate:a", 0.0, 0.4)

func take_damage(amount: int) -> void:
	if is_dying:
		return
	health = max(0, health - amount)
	show_glow(Color.RED)
	if hit_sound:
		hit_sound.play()
	if health <= 0:
		die()

func get_sprite_radius() -> float:
	return Constants.BASE_SPRITE_RADIUS * scale.x

func clamp_to_map_bounds() -> void:
	if not GameState.map_bounds.has_area():
		return
	var radius: float = get_sprite_radius()
	global_position.x = clampf(global_position.x, GameState.map_bounds.position.x + radius, GameState.map_bounds.end.x - radius)
	global_position.y = clampf(global_position.y, GameState.map_bounds.position.y + radius, GameState.map_bounds.end.y - radius)

func die() -> void:
	if is_dying:
		return
	is_dying = true
	shoot_phase = ShootPhase.IDLE
	is_shooting = false
	
	if glow_tween and glow_tween.is_valid():
		glow_tween.kill()
	
	# Wyłączenie fizyki i kolizji
	set_physics_process(false)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	
	sprite_upper.stop()
	sprite_bottom.stop()
	shoot_timer.stop()
	sprite_upper.hide()
	sprite_bottom.hide()
	
	if explosion_scene != null:
		var radius: float = get_sprite_radius()
		var effect := explosion_scene.instantiate()
		effect.global_position = global_position
		if radius:
			effect.scale = Vector2(1, 1) * (radius / Constants.BASE_EXPLOSION_RADIUS)
		get_tree().current_scene.add_child(effect)
	
	if hit_sound:
		hit_sound.play()
	
	if not is_in_group(Constants.GROUP_PLAYER):
		queue_free()
