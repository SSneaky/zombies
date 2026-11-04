extends Control

@onready var back_button: Button = $BackButton
@onready var map_button: Button = $HBoxContainer/MapButton
@onready var ui_manager: UIManager = $"../.."


var map = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_button.pressed.connect(_on_map_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _on_map_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ui_manager.change_map("res://scenes/node_3d.tscn")


func _on_back_pressed() -> void:
	ui_manager.go_back()
