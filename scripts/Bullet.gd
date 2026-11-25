class_name Bullet
extends Area2D

@export_group("Wartości Bazowe")
@export_range(10.0, 2000.0, 10.0, "suffix:px/s") var BASE_SPEED: float = 150.0
@export_range(50.0, 5000.0, 25.0, "suffix:px") var BASE_DISTANCE: float = 500.0
@export_range(1.0, 1000.0, 1.0) var BASE_DAMAGE: float = 20.0

@export_group("Kolizje")
@export var target_group: StringName = Constants.GROUP_ENEMIES

var speed: float = BASE_SPEED
var max_distance: float = BASE_DISTANCE
var damage: int = int(BASE_DAMAGE)

var direction: Vector2 = Vector2.RIGHT
var traveled_distance: float = 0.0

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	var move_step: float = speed * delta
	global_position += direction * move_step
	
	traveled_distance += move_step
	if traveled_distance >= max_distance:
		queue_free()

func setup(data: ProjectileData, shoot_direction: Vector2) -> void:
	direction = shoot_direction
	damage = data.damage
	speed = data.speed
	max_distance = data.max_distance
	
	var final_scale: float = data.scale
	if data.scale_by_damage and data.damage > 0:
		final_scale *= ((float(data.damage) / BASE_DAMAGE))
	scale = Vector2.ONE * final_scale

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body is TileMapLayer:
		queue_free()
