extends Control

@onready var interactive_label: Label = $InteractiveLabel


func _ready() -> void:
	interactive_label.visible = false

func _update_interact(prompt: String) -> void:
	interactive_label.visible
	interactive_label.text = prompt


func _process(delta: float) -> void:
	pass
