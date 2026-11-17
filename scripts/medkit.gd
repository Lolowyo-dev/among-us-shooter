class_name Medkit
extends Area2D

@export var heal_amount: int = 25

func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(heal_amount)
		queue_free()
