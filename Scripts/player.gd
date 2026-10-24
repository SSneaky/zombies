extends CharacterBody3D


const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6.0
const MOUSE_SENS:float = 0.01


@export var weapons: Array[WeaponData] = []
@export var third_person: bool = false
@export var third_person_dist: float = 3.0
@export var third_person_shoulder: float = 0.7
@export var third_person_height: float = 0.4

var current_index: int = 0
var current: WeaponData
var ammo: Array[int] = []
var reloading: bool = false
var fire_cooldown_left: float = 0.0
var last_pos: Vector3
var kills: int = 0


@onready var gun_holder: Node3D = $neck/GunHolder
@onready var model_slot : Node3D = $neck/GunHolder/ModelSlot


@onready var neck: Node3D = $neck
@onready var health: Health = $Health
@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var spring_arm: SpringArm3D = $neck/SpringArm3D
@onready var camera: Camera3D = $neck/SpringArm3D/POV
@onready var body_mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $neck/RayCast3D
@onready var ammo_label: Label = $HUD/AmmoLabel
@onready var muzzle_light: OmniLight3D = $neck/GunHolder/MuzzleFlash
@onready var gun_rest_pos: Vector3 = gun_holder.position
@onready var shot_sound: AudioStreamPlayer = $ShotSound
@onready var empty_sound: AudioStreamPlayer = $EmptySound
@onready var reload_sound: AudioStreamPlayer = $ReloadSound
@onready var kills_label: Label = $HUD/KillsLabel
@onready var game_over_screen: GameOverScreen = $HUD/GameOverScreen
@onready var crosshair: Control = $HUD/Control





func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	_on_health_changed(health.current_health, health.max_health)
	spring_arm.add_excluded_object(get_rid())
	body_mesh.visible = false
	for w in weapons:
		ammo.append(w.mag_size)
	_equip(0)
	_update_kills_label()


func _on_health_changed(ahora: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = ahora

func _on_died() -> void:
	game_over_screen.show_screen(kills)

#mouse cursor logic
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("exit") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_motion:Vector2 = event.relative
		rotate_y(-(mouse_motion.x * MOUSE_SENS))
		neck.rotate_x(-(mouse_motion.y * MOUSE_SENS))
		neck.rotation.x = deg_to_rad(clamp(rad_to_deg(neck.rotation.x), -90, 90))
	if event.is_action_pressed('weapon_next'):
		_equip((current_index + 1) % weapons.size())
	if event.is_action_pressed("weapon_prev"):
		_equip((current_index - 1 + weapons.size()) % weapons.size())
	for i in weapons.size():
		var action := "weapon_%d" % (i+1)
		if InputMap.has_action(action) and event.is_action_pressed(action):
			_equip(i)
	if event.is_action_pressed("toggle_view"):
		_toggle_view()

func _toggle_view() -> void:
	third_person = not third_person
	body_mesh.visible = third_person
	var tween := create_tween().set_parallel(true)
	tween.tween_property(spring_arm, "spring_length", third_person_dist if third_person else 0.0, 0.25)
	tween.tween_property(camera, "h_offset", third_person_shoulder if third_person else 0.0, 0.25)
	tween.tween_property(camera, "v_offset", third_person_height if third_person else 0.0, 0.25)

func _equip(index: int) -> void:
	if reloading or index == current_index and current != null:
		return
	current_index = index
	current = weapons[index]
	print("Equipping ", current.weapon_name, " -> ", current.model_scene.resource_path if current.model_scene else "NO MODEL SCENE")
	
	for child in model_slot.get_children():
		child.queue_free()
	if current.model_scene:
		model_slot.add_child(current.model_scene.instantiate())
	shot_sound.stream = current.shot_sound
	reload_sound.stream = current.reload_sound
	empty_sound.stream = current.empty_sound
	ray.target_position = Vector3(0, 0, -current.max_range)
	_update_ammo_label()
	if current.model_scene:
		var model := current.model_scene.instantiate()
		model_slot.add_child(model)
		if model.has_method('set_spread'):
			model.set_spread(current.spread_degrees)
		crosshair.gap = 5.0 + current.spread_degrees * 4

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
	if reloading or ammo[current_index] == current.mag_size:
		return
	reloading = true
	ammo_label.text = "Reloading..."
	reload_sound.play()
	await get_tree().create_timer(current.reload_time).timeout
	ammo[current_index] = current.mag_size
	reloading = false
	_update_ammo_label()

func _update_ammo_label() -> void:
	ammo_label.text = "%s %d / %d" % [current.weapon_name, ammo[current_index], current.mag_size]

func _shot_feedback() -> void:
	shot_sound.pitch_scale = randf_range(0.9, 1.1)
	shot_sound.play()
	
	var tween := create_tween()
	tween.tween_property(gun_holder, "position", gun_rest_pos + Vector3(0, current.recoil_kick * 0.5,current.recoil_kick), 0.04)
	tween.tween_property(gun_holder, "position", gun_rest_pos, 0.12)
	
	muzzle_light.visible = true
	await get_tree().create_timer(0.05).timeout
	muzzle_light.visible = false

func add_kill() -> void:
	kills += 1
	_update_kills_label()
func _update_kills_label() -> void:
	kills_label.text = "Kills %d" % kills

func _physics_process(delta: float) -> void:
#	if global_position.distance_to(last_pos) > 1.0:
#		print('player jumped: ', last_pos, ' -> ', global_position, " at ", Time.get_ticks_msec(), " ms")
	last_pos = global_position
#gun logic
	fire_cooldown_left -= delta
	
	var wants_fire: bool = Input.is_action_pressed("fire") if current.automatic else Input.is_action_just_pressed("fire")
	if wants_fire and not reloading and fire_cooldown_left <= 0.0:
		if ammo[current_index] > 0:
			_shoot()
		else:
			empty_sound.play()
	
	if Input.is_action_just_pressed('reload'):
		_reload()
	
	
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	
	#sprint fov logic
	var target_fov := 85.0 if speed == SPRINT_SPEED else 75.0
	camera.fov = lerpf(camera.fov, target_fov, 10.0 * delta)
