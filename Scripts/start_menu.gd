extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var ui_manager: UIManager = $"../.."



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void: ui_manager.push(&"MapSelect")

func _on_settings_pressed() -> void: ui_manager.push(&"OptionsMenu")

func _on_quit_pressed() -> void: get_tree().quit()
