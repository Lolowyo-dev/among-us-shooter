class_name Bullet
extends Area2D

@export var speed: float = 300.0
@export var max_distance: float = 600.0
@export var damage: int = 10
@export var target_group: String = Constants.GROUP_ENEMIES

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

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body is TileMapLayer:
		queue_free()
