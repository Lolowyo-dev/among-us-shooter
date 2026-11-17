class_name PlayerBullet
extends Bullet

func _init() -> void:
	speed = 400.0
	max_distance = 600.0
	damage = 10
	target_group = Constants.GROUP_ENEMIES
