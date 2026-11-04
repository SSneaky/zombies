extends Control

@onready var title_label: Label = $TitleLabel
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var ui_manager: UIManager = $"../.."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ui_manager.clear_screen()
	#ui_manager.show_screen(&"StartMenu")
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)



func _on_resume_pressed() -> void:
	ui_manager.clear_screen()
	ui_manager.show_screen(&"PlayerHud")
	ui_manager.toggle_pause(false, false)

func _on_settings_pressed() -> void:
	ui_manager.show_screen(&"OptionsMenu")

func _on_restart_pressed() -> void:
	ui_manager.clear_screen()
	ui_manager.show_screen(&"PlayerHud")
	ui_manager.toggle_pause(false, false)
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	ui_manager.toggle_pause(false, true)
	ui_manager.change_map("res://scenes/start.tscn")
	ui_manager.clear_screen()
	ui_manager.show_screen(&"StartMenu")
