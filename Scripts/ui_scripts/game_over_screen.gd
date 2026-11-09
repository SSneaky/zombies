extends Control

@onready var kills_label: Label = $CenterContainer/VBoxContainer/FinalKillsLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var crosshair: Control = $"../PlayerHud/Crosshair"
@onready var ui_manager: UIManager = $"../.."

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_screen(kills: int) -> void:
	kills_label.text = "Kills: %d" % kills
	ui_manager.push(&"GameOverScreen")

func _on_restart_pressed() -> void: ui_manager.restart()
func _on_quit_pressed() -> void: ui_manager.push(&"StartMenu")
func _on_screen_changed(): pass
