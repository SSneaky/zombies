extends StaticBody3D

class_name InteractiveThang

signal interacted

@export var message: String = "Press me"
@export var action_needed = "Interact"
@export var key: String = "E"

func push_prompt() -> String:
	return message + " - ["+key+"]"

func interact() -> void:
	print("yo")
	interacted.emit()
