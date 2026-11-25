class_name GameOverScreen
extends CanvasLayer

signal restart_requested
signal menu_requested

@onready var title_label: Label = %TitleLabel
@onready var score_label: Label = %ScoreLabel
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	hide()
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())

func show_screen(is_victory: bool, final_score: int) -> void:
	if is_victory:
		title_label.text = "ZWYCIĘSTWO!"
		title_label.label_settings.font_color = Color.GOLD
	else:
		title_label.text = "KONIEC GRY"
		title_label.label_settings.font_color = Color.INDIAN_RED
	
	score_label.text = "Wynik: %d" % final_score
	show()
	restart_button.grab_focus()
