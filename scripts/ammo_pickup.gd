class_name AmmoPickup
extends Area2D

@export var max_ammo_amount: int = 20
var min_amount: int = max_ammo_amount / 3
var ammo_amount: int = max_ammo_amount

func _ready() -> void:
	ammo_amount = randi_range(min_amount, max_ammo_amount)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.add_ammo(ammo_amount):
			queue_free()
