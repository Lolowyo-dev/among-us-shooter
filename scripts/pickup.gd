class_name Pickup
extends Area2D

@export_group("Wartość")
@export var base_amount: int = 20
@export_range(0.0, 100.0, 1.0, "suffix:%") var variation_percent: float = 0.0

var amount: int = 20

func _ready() -> void:
	amount = _calculate_amount()
	
func _calculate_amount() -> int:
	if variation_percent <= 0.0:
		return base_amount
	var ratio: float = variation_percent / 100.0
	var varied: float = base_amount * randf_range(1.0 - ratio, 1.0 + ratio)
	return maxi(1, roundi(varied))
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player and _apply_pickup(body):
		queue_free()

func _apply_pickup(_player: Player) -> bool:
	return false
