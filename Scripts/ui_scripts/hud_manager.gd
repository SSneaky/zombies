extends Control

@onready var interactive_label: Label = $InteractiveLabel


func _ready() -> void:
	_clear_prompt()

func _push_prompt(prompt: String) -> void:
	interactive_label.visible = true
	interactive_label.text = prompt

func _clear_prompt() -> void:
	interactive_label.text = ""
