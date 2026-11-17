class_name Medkit
extends Area2D

@export var heal_amount: int = 25

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.heal(heal_amount):
			queue_free()
