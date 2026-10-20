extends CharacterBody3D


const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6.0
const MAX_AMMO: int = 12
const RELOAD_TIME: float = 1.5
const FIRE_COOLDOWN: float = 0.25
const GUN_DAMAGE: int = 50
const MOUSE_SENS:float = 0.01

var ammo: int = MAX_AMMO
var reloading: bool = false
var fire_cooldown_left: float = 0.0


@onready var neck: Node3D = $neck
@onready var health: Health = $Health
@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var camera: Camera3D = $neck/POV
@onready var ray: RayCast3D = $neck/RayCast3D
@onready var ammo_label: Label = $HUD/AmmoLabel
@onready var gun: Node3D = $neck/GunMesh
@onready var muzzle_light: OmniLight3D = $neck/GunMesh/MuzzleFlash
@onready var gun_rest_pos: Vector3 = gun.position
@onready var shot_sound: AudioStreamPlayer = $ShotSound
@onready var empty_sound: AudioStreamPlayer = $EmptySound
@onready var reload_sound: AudioStreamPlayer = $ReloadSound



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	_on_health_changed(health.current_health, health.max_health)
	_update_ammo_label()

func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func _on_died() -> void:
	get_tree().reload_current_scene()
#mouse cursor logic
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit") && Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_motion:Vector2 = event.relative
		rotate_y(-(mouse_motion.x * MOUSE_SENS))
		neck.rotate_x(-(mouse_motion.y * MOUSE_SENS))
		neck.rotation.x = deg_to_rad(clamp(rad_to_deg(neck.rotation.x), -90, 90))

func _shoot() -> void:
	ammo -= 1
	fire_cooldown_left = FIRE_COOLDOWN
	_update_ammo_label()
	_shot_feedback()
	
	if ray.is_colliding():
		var target = ray.get_collider()
		if target.is_in_group('opps'):
			target.get_node('Health').take_damage(GUN_DAMAGE)

func _reload() -> void:
	if reloading or ammo == MAX_AMMO:
		return
	reloading = true
	ammo_label.text = "Reloading..."
	reload_sound.play()
	await get_tree().create_timer(RELOAD_TIME).timeout
	ammo = MAX_AMMO
	reloading = false
	_update_ammo_label()

func _update_ammo_label() -> void:
	ammo_label.text = "%d / %d" % [ammo, MAX_AMMO]

func _shot_feedback() -> void:
	shot_sound.pitch_scale = randf_range(0.9, 1.1)
	shot_sound.play()
	
	var tween := create_tween()
	tween.tween_property(gun, "position", gun_rest_pos + Vector3(0, 0, 0.06), 0.04)
	tween.tween_property(gun, "position", gun_rest_pos, 0.12)
	
	muzzle_light.visible = true
	await get_tree().create_timer(0.05).timeout
	muzzle_light.visible = false

func _physics_process(delta: float) -> void:
#gun logic
	fire_cooldown_left -= delta
	
	if Input.is_action_just_pressed('fire') and not reloading and fire_cooldown_left <= 0.0:
		if ammo > 0:
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
