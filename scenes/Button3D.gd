extends StaticBody3D

class_name InteractiveThang

signal interacted

@export var message: String = "Press me"
@export var action_needed = "interact"
@export var key: String = "E"
@export var uses: int   #how many uses before it kills itself, set 0 for toggle mode
@export var is_toggled: bool
@export var is_disabled: bool

func _ready() -> void:
	pass

func get_prompt() -> String:
	if is_disabled:
		message = ""
	return message + " - ["+key+"]"

func interact() -> void:
	if is_disabled:
		return
	print(uses)
	if uses == 0:
		is_toggled = not is_toggled
		print(is_toggled)
	else:
		if uses == 1:
			is_disabled = true
		else:
			uses -= 1
		print(uses if uses == 1 else uses, " left", is_disabled)
	interacted.emit()
