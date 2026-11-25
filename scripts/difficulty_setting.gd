class_name DifficultySettings
extends Resource

@export_group("Ogólne")
@export var display_name: String = "Normalny"
@export_range(10.0, 600.0, 5.0, "suffix:s") var round_duration: float = 60.0

@export_group("Spawning Wrogów")
@export var enemy_scene: PackedScene
@export_range(1, 50, 1) var max_enemies: int = 6
@export_range(0.5, 30.0, 0.5, "suffix:s") var spawn_interval: float = 3.0

@export_group("Mnożniki Statystyk Wroga")
@export_range(0.2, 5.0, 0.1, "suffix:×") var health_multiplier: float = 1.0
@export_range(0.2, 5.0, 0.1, "suffix:×") var speed_multiplier: float = 1.0
@export_range(0.2, 5.0, 0.1, "suffix:×") var damage_multiplier: float = 1.0
@export_range(0.2, 5.0, 0.1, "suffix:×") var fire_rate_multiplier: float = 1.0
