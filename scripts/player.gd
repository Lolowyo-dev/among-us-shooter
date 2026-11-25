class_name Player
extends Character

signal health_changed(current_hp: int, max_hp: int)
signal ammo_changed(current_ammo: int, max_ammo: int)
signal died()

@export var max_ammo: int = 20
var ammo: int = max_ammo

@onready var hit_box: CollisionShape2D = $HitBox
@onready var camera_2d: Camera2D = get_node_or_null("Camera2D")

func _ready() -> void:
	super._ready()
	ammo = max_ammo
	health_changed.emit(health, max_health)
	ammo_changed.emit(ammo, max_ammo)

func set_camera_limits() -> void:
	if camera_2d != null and GameState.map_bounds.has_area():
		camera_2d.limit_top = int(GameState.map_bounds.position.y)
		camera_2d.limit_left = int(GameState.map_bounds.position.x)
		camera_2d.limit_right = int(GameState.map_bounds.end.x)
		camera_2d.limit_bottom = int(GameState.map_bounds.end.y)

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var shoot_dir := Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	velocity = input_dir * speed
	
	update_animations(input_dir, shoot_dir)
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider.is_in_group(Constants.GROUP_ENEMIES):
			take_damage(health)
			break
	
	clamp_to_map_bounds()

	if shoot_dir != Vector2.ZERO:
		shoot(shoot_dir)

func shoot(shoot_dir: Vector2) -> void:
	if ammo <= 0 or not can_shoot():
		return
	ammo -= 1
	ammo_changed.emit(ammo, max_ammo)
	super.shoot(shoot_dir)

func take_damage(amount: int) -> void:
	var prev_health: int = health
	super.take_damage(amount)
	if health != prev_health:
		health_changed.emit(health, max_health)

func heal(amount: int) -> bool:
	if health >= max_health:
		return false
	health = min(max_health, health + amount)
	show_glow(Color.GREEN)
	health_changed.emit(health, max_health)
	return true

func add_ammo(amount: int) -> bool:
	if ammo >= max_ammo:
		return false
	ammo = min(max_ammo, ammo + amount)
	ammo_changed.emit(ammo, max_ammo)
	return true

func die() -> void:
	super.die()
	
	died.emit()
