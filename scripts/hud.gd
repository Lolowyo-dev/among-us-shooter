class_name HUD
extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var health_label: Label = %HealthLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var ammo_label: Label = %AmmoLabel
@onready var ammo_bar: ProgressBar = %AmmoBar
@onready var timer_label: Label = %TimerLabel

func _ready() -> void:
	GameState.score_changed.connect(update_score)
	update_score(GameState.score)

func setup(player: Player) -> void:
	if player == null:
		return
	player.health_changed.connect(update_health)
	player.ammo_changed.connect(update_ammo)
	update_health(player.health, player.max_health)
	update_ammo(player.ammo, player.max_ammo)

func update_score(val: int) -> void:
	score_label.text = "Wynik: %d" % val

func update_health(current: int, max_hp: int) -> void:
	health_label.text = "%d / %d" % [current, max_hp]
	health_bar.max_value = max_hp
	health_bar.value = current

func update_ammo(current: int, max_ammo: int) -> void:
	ammo_label.text = "%d / %d" % [current, max_ammo]
	ammo_bar.max_value = max_ammo
	ammo_bar.value = current

func update_timer(seconds_left: float) -> void:
	var total_seconds: int = ceili(maxf(0.0, seconds_left))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]
