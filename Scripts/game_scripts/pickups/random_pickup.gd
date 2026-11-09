extends Area3D

@export var ammo_table: Dictionary[String, Vector2i] = {
	"9mm": Vector2i(4, 30),
	"slugs": Vector2i(2, 10),
	"7.62mm": Vector2i(10, 50),
}

func _process(delta: float) -> void:
	rotate_y(delta * 2.0)

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("add_ammo"):
			var types:= ammo_table.keys()
			types.shuffle()
			for t in types:
				var limits: Vector2i = ammo_table[t]
				var amount := randi_range(limits.x, limits.y)
				if body.add_ammo(t, amount):
					if body.has_method("show_pickup_message"):
						body.show_pickup_message("+%d %s" % [amount, t])
						queue_free()
						return
