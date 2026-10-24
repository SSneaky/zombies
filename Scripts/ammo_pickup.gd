extends Area3D

@export var ammo_type: String = "9mm"
@export var amount: int = 12

func _process(delta: float) -> void:
	rotate_y(delta * 2.0)

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("add_ammo"):
			if body.add_ammo(ammo_type, amount):
				queue_free()
				return
