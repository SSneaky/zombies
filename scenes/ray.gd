extends RayCast3D

@onready var hud: Control = UIGuy.get_node("CanvasLayer/PlayerHud")

func _process(delta: float) -> void:
	if not is_colliding():
		hud._push_prompt("")
		return
		
	else:
		var collider = get_collider()
		#print(collider.get_class())
		if collider is InteractiveThang:
			if collider.is_disabled:
				hud._clear_prompt()
				return
			hud._push_prompt(collider.get_prompt())
			if Input.is_action_just_pressed(collider.action_needed):
				collider.interact()
