class_name AmmoPickup
extends Pickup

func _apply_pickup(player: Player) -> bool:
	return player.add_ammo(amount)
