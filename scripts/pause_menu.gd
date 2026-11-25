class_name PauseMenu
extends CanvasLayer

signal restart_requested
signal menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton

var enabled: bool = true

func _ready() -> void:
	hide()
	resume_button.pressed.connect(toggle_pause)
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())

func _unhandled_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var is_paused: bool = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	if is_paused:
		resume_button.grab_focus()
