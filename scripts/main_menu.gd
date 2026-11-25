class_name MainMenu
extends Control

@export var difficulties: Array[DifficultySettings] = []

@onready var play_button: Button = $CenterContainer/PanelContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitButton
@onready var difficulty_slider: HSlider = %DifficultySlider
@onready var difficulty_value_label: Label = %DifficultyValueLabel
@onready var difficulty_label: Label = %DifficultyLabel

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_setup_difficulty_slider()
	play_button.grab_focus()

func _on_play_pressed() -> void:
	GameState.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _setup_difficulty_slider() -> void:
	if difficulties.is_empty():
		difficulty_slider.hide()
		difficulty_label.hide()
		return
	
	difficulty_slider.min_value = 0
	difficulty_slider.max_value = difficulties.size() - 1
	difficulty_slider.step = 1
	difficulty_slider.tick_count = difficulties.size()
	
	var start_index: int = mini(1, difficulties.size() - 1)
	if GameState.current_difficulty != null:
		var found: int = difficulties.find(GameState.current_difficulty)
		if found != -1:
			start_index = found
	
	difficulty_slider.value = start_index
	difficulty_slider.value_changed.connect(_on_difficulty_changed)
	_on_difficulty_changed(start_index)
	_update_slider_value_position.call_deferred()

func _on_difficulty_changed(value: float) -> void:
	var idx: int = clampi(int(value), 0, difficulties.size() - 1)
	var selected: DifficultySettings = difficulties[idx]
	GameState.current_difficulty = selected
	difficulty_value_label.text = selected.display_name
	difficulty_value_label.reset_size()
	_update_slider_value_position()

func _update_slider_value_position() -> void:
	var ratio: float = 0.0
	if difficulty_slider.max_value > difficulty_slider.min_value:
		ratio = (difficulty_slider.value - difficulty_slider.min_value) / (difficulty_slider.max_value - difficulty_slider.min_value)
	var grabber_width: float = difficulty_slider.get_theme_icon("grabber").get_width()
	var center_x: float = (grabber_width * 0.5) + ratio * (difficulty_slider.size.x - grabber_width)
	difficulty_value_label.position.x = center_x - (difficulty_value_label.size.x * 0.5)
