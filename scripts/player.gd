class_name Player
extends Character

signal health_changed(current_hp: int, max_hp: int)
signal ammo_changed(current_ammo: int, max_ammo: int)

@export var max_ammo: int = 20
var ammo: int = max_ammo

@onready var hit_box: CollisionShape2D = $HitBox
@onready var camera_2d: Camera2D = get_node_or_null("Camera2D")

func _ready() -> void:
	super._ready()
	ammo = max_ammo
	health_changed.emit(health, max_health)
	ammo_changed.emit(ammo, max_ammo)
	set_camera_limits()

func set_camera_limits() -> void:
	if camera_2d != null and GameState.map_bounds.has_area():
		camera_2d.limit_top = int(GameState.map_bounds.position.y)
		camera_2d.limit_left = int(GameState.map_bounds.position.x)
		camera_2d.limit_right = int(GameState.map_bounds.end.x)
		camera_2d.limit_bottom = int(GameState.map_bounds.end.y)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	
	update_animations(input_dir)
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider.is_in_group(Constants.GROUP_ENEMIES):
			take_damage(health)
			break
	
	var half_size := Vector2.ZERO
	if hit_box and hit_box.shape is RectangleShape2D:
		half_size = hit_box.shape.size / 2.0
	global_position.x = clamp(global_position.x, GameState.map_bounds.position.x + half_size.x, GameState.map_bounds.end.x - half_size.x)
	global_position.y = clamp(global_position.y, GameState.map_bounds.position.y + half_size.y, GameState.map_bounds.end.y - half_size.y)
	
	var shoot_dir = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	if shoot_dir != Vector2.ZERO:
		shoot(shoot_dir)

func shoot(shoot_dir: Vector2) -> void:
	if ammo <= 0 or is_shooting:
		return
	ammo -= 1
	ammo_changed.emit(ammo, max_ammo)
	super.shoot(shoot_dir)

func take_damage(amount: int) -> void:
	super.take_damage(amount)
	health_changed.emit(health, max_health)

func heal(amount: int) -> void:
	if is_dying:
		return
	health = min(max_health, health + amount)
	show_glow(Color.GREEN)
	health_changed.emit(health, max_health)

func add_ammo(amount: int) -> void:
	ammo = min(max_ammo, ammo + amount)
	ammo_changed.emit(ammo, max_ammo)

func die() -> void:
	if is_dying:
		return
	is_dying = true
	set_physics_process(false)
	sprite_upper.hide()
	sprite_bottom.hide()
	if hit_box:
		hit_box.set_deferred("disabled", true)
	
	if explosion_scene != null:
		var radius: float = get_sprite_radius()
		var effect := explosion_scene.instantiate()
		effect.global_position = global_position
		if radius:
			effect.scale = Vector2(1, 1) * (radius / 32.0)
		get_tree().current_scene.add_child(effect)
	
	if hit_sound:
		hit_sound.play()
	
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()
