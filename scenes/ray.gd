extends RayCast3D

@onready var hud: Control = UIGuy.get_node("CanvasLayer/PlayerHud")

func _process(delta: float) -> void:
	if not is_colliding():
		print("wya")
		hud._update_interact("")
		return
		
	else:
		var collider = get_collider()
		print(collider)
		if collider == InteractiveThang:
			print("hey")
			hud._update_interact(collider.push_prompt())
			if Input.is_action_just_pressed(collider.action_needed):
				collider.interact
