extends Control
class_name PauseMenu

signal paused

@onready var title_label: Label = $TitleLabel
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var death_screen: Control = $"../GameOverScreen"
@onready var ui_manager: UIManager = $"../.."


var map_name = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)



func _on_resume_pressed() -> void:
	ui_manager.clear_screen()

func _on_settings_pressed() -> void:
	$"../OptionsMenu".show_screen()

func _on_restart_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start.tscn")
	$"../StartMenu".show_screen()
	hide()
