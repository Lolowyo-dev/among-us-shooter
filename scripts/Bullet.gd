class_name Bullet
extends Area2D

@export var speed: float = 300.0
@export var max_distance: float = 600.0
@export var damage: int = 10
@export var target_group: String = "enemies"

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation = direction.angle()
	
	if global_position.distance_to(start_position) > max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body is TileMapLayer:
		queue_free()
