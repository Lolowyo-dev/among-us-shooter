extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4).set_delay(0.15)
	
	if audio_player:
		audio_player.finished.connect(queue_free)
	else:
		var timer := get_tree().create_timer(0.6)
		timer.timeout.connect(queue_free)
