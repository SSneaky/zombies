extends Control

@onready var back_button: Button = $BackButton
@onready var ui_manager: UIManager = $"../.."




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)



func _on_back_pressed() -> void: ui_manager.pop()
