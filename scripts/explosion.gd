extends Node2D

@export var speed: float = 150.0
@export var max_patrol_distance: float = 200.0

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
