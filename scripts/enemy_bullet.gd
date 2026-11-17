class_name EnemyBullet
extends Bullet

func _init() -> void:
	speed = 150.0
	max_distance = 800.0
	damage = 20
	target_group = "player"
