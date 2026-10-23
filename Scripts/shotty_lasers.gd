extends Node3D

@onready var left: Node3D = $LaserLeft
@onready var right: Node = $LaserRight

func set_spread(degrees: float) -> void:
	left.rotation_degrees.y = degrees
	right.rotation_degrees.y = -degrees
	left.visible = degrees > 0.0
	right.visible = degrees > 0.0
