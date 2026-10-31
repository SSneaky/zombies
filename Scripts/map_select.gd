extends Control

@onready var back_button: Button = $BackButton
@onready var map_button: Button = $HBoxContainer/MapButton


var map = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	map_button.pressed.connect(_on_map_pressed)
	back_button.pressed.connect(_on_back_pressed)

func show_screen() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_map_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
	hide()


func _on_back_pressed() -> void:
	$"../StartMenu".show()
	hide()
