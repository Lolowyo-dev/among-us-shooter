class_name Medkit
extends Pickup

func _apply_pickup(player: Player) -> bool:
	return player.heal(amount)
