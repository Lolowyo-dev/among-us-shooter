class_name HUD
extends CanvasLayer

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var ammo_label: Label = $MarginContainer/VBoxContainer/AmmoLabel

func _ready() -> void:
	GameState.score_changed.connect(update_score)
	update_score(GameState.score)
	
	var player = get_tree().get_first_node_in_group(Constants.GROUP_PLAYER)
	if player and player is Player:
		player.health_changed.connect(update_health)
		player.ammo_changed.connect(update_ammo)
		update_health(player.health, player.max_health)
		update_ammo(player.ammo, player.max_ammo)

func update_score(val: int) -> void:
	score_label.text = "Wynik: %d" % val

func update_health(current: int, max_hp: int) -> void:
	health_label.text = "Życie: %d / %d" % [current, max_hp]

func update_ammo(current: int, max_ammo: int) -> void:
	ammo_label.text = "Amunicja: %d / %d" % [current, max_ammo]
