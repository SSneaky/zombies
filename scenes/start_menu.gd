extends Control


@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var option_button: OptionButton = $VBoxContainer/OptionButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton

var map = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show()
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_screen() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_settings_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
