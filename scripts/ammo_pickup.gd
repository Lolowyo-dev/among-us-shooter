class_name AmmoPickup
extends Area2D

@export var max_ammo_amount: int = 20
var min_amount: int = int(max_ammo_amount / 3.0)
var ammo_amount: int = max_ammo_amount

func _ready() -> void:
	min_amount = int(max_ammo_amount / 3.0)
	ammo_amount = randi_range(min_amount, max_ammo_amount)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.add_ammo(ammo_amount):
			queue_free()
