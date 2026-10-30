extends Control
class_name PauseMenu

signal paused

@onready var title_label: Label = $TitleLabel
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

var map_name = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	if Input.is_action_just_pressed("exit") and self.visible == true:
		_on_resume_pressed()

func show_screen() -> void:
	paused.emit()
	map_name = get_tree().get_current_scene().name
	print(map_name)
	title_label.text = "PAUSED - " + map_name
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_settings_pressed() -> void:
	pass

func _on_restart_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		UI.get_node("CanvasLayer/PauseMenu").show_screen()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("exit") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		_on_resume_pressed()
		get_viewport().set_input_as_handled()
