extends Node3D

@export var weapons: Array[WeaponData] = []

var current_index: int = 0
var current: WeaponData
var ammo: Array[int] = []
var reserve: Dictionary = {}
var reloading: bool = false
var fire_cooldown_left: float = 0.0

@onready var model_slot : Node3D = $ModelSlot
@onready var ray: RayCast3D = $"../RayCast3D"
@onready var muzzle_light: OmniLight3D = $MuzzleFlash
@onready var gun_rest_pos: Vector3 = position
@onready var shot_sound: AudioStreamPlayer = $"../../ShotSound"
@onready var empty_sound: AudioStreamPlayer = $"../../EmptySound"
@onready var reload_sound: AudioStreamPlayer = $"../../ReloadSound"
@onready var pickup_sound: AudioStreamPlayer = $"../../PickupSound"
@onready var ammo_label: Label = UI.get_node("$CanvasLayer/PlayerHud/AmmoLabel")
@onready var pickup_label: Label = UI.get_node("$CanvasLayer/PlayerHud/PickupLabel")
@onready var crosshair: Control = UI.get_node("$CanvasLayer/PlayerHud/Crosshair")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for w in weapons:
		ammo.append(w.mag_size)
	for w in weapons:
		if not reserve.has(w.ammo_type):
			reserve[w.ammo_type] = w.starting_reserve


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fire_cooldown_left -= delta
	
	var wants_fire: bool = Input.is_action_pressed("fire") if current.automatic else Input.is_action_just_pressed("fire")
	if wants_fire and not reloading and fire_cooldown_left <= 0.0:
		if ammo[current_index] > 0:
			_shoot()
		else:
			empty_sound.play()

func _equip(index: int) -> void:
	if reloading or index == current_index and current != null:
		return
	current_index = index
	current = weapons[index]
	for child in model_slot.get_children():
		child.queue_free()
	if current.model_scene:
		var model := current.model_scene.instantiate()
		model_slot.add_child(model)
		if model.has_method("set_spread"):
			model.set_spread(current.spread_degrees)
	shot_sound.stream = current.shot_sound
	reload_sound.stream = current.reload_sound
	empty_sound.stream = current.empty_sound
	ray.target_position = Vector3(0, 0, -current.max_range)
	crosshair.gap = 5.0 + current.spread_degrees * 4.0
	_update_ammo_label()


func _shoot() -> void:
	ammo[current_index] -= 1
	fire_cooldown_left = current.fire_cooldown
	_update_ammo_label()
	_shot_feedback()
	for i in current.pellets:
		_fire_pellet()

func _fire_pellet() -> void:
	var spread := deg_to_rad(current.spread_degrees)
	ray.rotation = Vector3(randf_range(-spread, spread), randf_range(-spread, spread), 0)
	ray.force_raycast_update()
	if ray.is_colliding():
		var target = ray.get_collider()
		if target.is_in_group('opps'):
			target.get_node('Health').take_damage(current.damage)
	ray.rotation = Vector3.ZERO
	
func _reload() -> void:
	var ammo_type := current.ammo_type
	if reloading or ammo[current_index] == current.mag_size or reserve.get(ammo_type, 0) <= 0:
		return
	reloading = true
	ammo_label.text = "Reloading..."
	reload_sound.play()
	await get_tree().create_timer(current.reload_time).timeout
	var needed := current.mag_size - ammo[current_index]
	var taken := mini(needed, reserve[ammo_type])
	ammo[current_index] += taken
	reserve[ammo_type] -= taken
	reloading = false
	_update_ammo_label()
	
func add_ammo(ammo_type: String, amount: int) -> bool:
	var cap:= _max_reserve_for(ammo_type)
	var have: int = reserve.get(ammo_type, 0)
	
	if have >= cap:
		return false
	reserve[ammo_type] = mini(have + amount, cap)
	pickup_sound.play()
	_update_ammo_label()
	return true

func _max_reserve_for(ammo_type: String) -> int:
	var most := 0
	for w in weapons:
		if w.ammo_type == ammo_type:
			most = maxi(most, w.max_reserve)
	return most

func _update_ammo_label() -> void:
	ammo_label.text = "%s %d / %d" % [current.weapon_name, ammo[current_index], reserve.get(current.ammo_type, 0)]

func show_pickup_message(text: String) -> void:
	pickup_label.text = text
	pickup_label.modulate.a = 1.0
	create_tween().tween_property(pickup_label, "modulate:a", 0.0, 1.5).set_delay(0.5)

func _shot_feedback() -> void:
	shot_sound.pitch_scale = randf_range(0.9, 1.1)
	shot_sound.play()
	
	var tween := create_tween()
	tween.tween_property(self, "position", gun_rest_pos + Vector3(0, current.recoil_kick * 0.5,current.recoil_kick), 0.04)
	tween.tween_property(self, "position", gun_rest_pos, 0.12)
	
	muzzle_light.visible = true
	await get_tree().create_timer(0.05).timeout
	muzzle_light.visible = false
