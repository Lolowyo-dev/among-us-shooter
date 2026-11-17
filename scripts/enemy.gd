class_name Enemy
extends Character

@export var max_patrol_distance: float = 100.0

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	update_animations(velocity)
	move_and_slide()
	
	if global_position.x > start_position.x + max_patrol_distance:
		direction = Vector2.LEFT
	elif global_position.x < start_position.x - max_patrol_distance:
		direction = Vector2.RIGHT

func die() -> void:
	GameState.add_score(1)
	print("Punkty: ", GameState.score)
	super.die()

func _on_timer_timeout() -> void:
	shoot(direction)
