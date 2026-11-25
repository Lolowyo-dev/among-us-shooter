class_name MainMenu
extends Control

@onready var play_button: Button = $CenterContainer/PanelContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()

func _on_play_pressed() -> void:
	GameState.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
