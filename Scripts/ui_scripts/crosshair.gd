extends Control

@export var color: Color = Color.WHITE
@export var length: float = 8.0
@export var thickness: float = 2.0
@export var show_dot: bool = true
@export var gap: float = 5.0:
	set(value):
		gap = value
		queue_redraw()

func _ready() -> void:
	show()
	pass
func _draw() -> void:
	draw_line(Vector2(-gap - length, 0), Vector2(-gap, 0), color, thickness)
	draw_line(Vector2(gap, 0), Vector2(gap + length, 0), color, thickness)
	draw_line(Vector2(0, -gap - length), Vector2(0, -gap), color, thickness)
	draw_line(Vector2(0, gap), Vector2(0, gap + length), color, thickness)
	if show_dot:
		draw_circle(Vector2.ZERO, thickness, color)
