extends Control

@onready var back_button: Button = $BackButton
@onready var map_button: Button = $HBoxContainer/MapButton
@onready var ui_manager: UIManager = $"../.."


func _ready() -> void:
	map_button.pressed.connect(_on_map_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_map_pressed() -> void:
	ui_manager.change_map("res://scenes/node_3d.tscn")
	ui_manager.set_base(&"PlayerHud")
	NetworkManger.host_lobby()

func _on_back_pressed() -> void: ui_manager.pop()
