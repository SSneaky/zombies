class_name GameOverScreen
extends Control

@onready var kills_label: Label = $CenterContainer/VBoxContainer/FinalKillsLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var crosshair: Control = $"../PlayerHud/Crosshair"
@onready var ui_manager: UIManager = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_screen(kills: int) -> void:
	kills_label.text = "Kills: %d" % kills
	ui_manager.show_screen(&"GameOverScreen")
	ui_manager.toggle_pause(true, true)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	hide()

func _on_quit_pressed() -> void:
	get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
