extends Control

@onready var back_button: Button = $BackButton

var map_name = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	back_button.pressed.connect(_on_back_pressed)

func show_screen() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



func _on_back_pressed() -> void:
	map_name = get_tree().get_current_scene().name
	if map_name == "Start":
		$"../StartMenu".show()
		hide()
	else:
		hide()
