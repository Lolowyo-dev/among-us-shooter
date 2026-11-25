class_name ProjectileData
extends Resource

@export_group("Wygląd i Scena")
@export var scene: PackedScene
@export_range(0.1, 10.0, 0.1, "suffix:×") var scale: float = 1.0
@export var scale_by_damage: bool = false

@export_group("Parametry strzału")
@export_range(1, 1000, 1) var damage: int = 20
@export_range(10.0, 2000.0, 10.0, "suffix:px/s") var speed: float = 200.0
@export_range(50.0, 5000.0, 25.0, "suffix:px") var max_distance: float = 300.0
