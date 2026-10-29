extends CharacterBody3D


const WALK_SPEED = 6.0
const SPRINT_SPEED = 10.0
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
var reserve: Dictionary = {}
var reloading: bool = false
var fire_cooldown_left: float = 0.0
var last_pos: Vector3
var kills: int = 0
var wave_num: int = 0


@onready var gun: Node3D = $neck/Gun
@onready var neck: Node3D = $neck
@onready var health: Health = $Health
@onready var health_bar: ProgressBar = $"../UI/PlayerHud/HealthBar"
@onready var spring_arm: SpringArm3D = $neck/SpringArm3D
@onready var camera: Camera3D = $neck/SpringArm3D/POV
@onready var body_mesh: MeshInstance3D = $MeshInstance3D
@onready var kills_label: Label = $"../UI/KillsLabel"
@onready var game_over_screen: GameOverScreen = $"../UI/GameOverScreen"
@onready var wave_label: Label = $"../UI/WaveLabel"






func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	_on_health_changed(health.current_health, health.max_health)
	spring_arm.add_excluded_object(get_rid())
	body_mesh.visible = false
	gun._equip(0)
	_update_kills_label()
	var spawner := get_tree().get_first_node_in_group("spawner")
	if spawner:
		spawner.wave_started.connect(_on_wave_started)
		spawner.remaining_changed.connect(_on_remaining_changed)
		spawner.break_tick.connect(_on_break_tick)

func _on_wave_started(wave: int) -> void:
	wave_num = wave
	wave_label.text = "Wave %d" % wave

func _on_remaining_changed(remaining: int) -> void:
	wave_label.text = "Wave %d - %d left" % [wave_num, remaining]

func _on_break_tick(seconds: int) -> void:
	wave_label.text = "Wave %d in %d" % [wave_num + 1, seconds]

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
		gun._equip((current_index + 1) % weapons.size())
	if event.is_action_pressed("weapon_prev"):
		gun._equip((current_index - 1 + weapons.size()) % weapons.size())
	for i in weapons.size():
		var action := "weapon_%d" % (i+1)
		if InputMap.has_action(action) and event.is_action_pressed(action):
			gun._equip(i)
	if event.is_action_pressed("toggle_view"):
		_toggle_view()

func _toggle_view() -> void:
	third_person = not third_person
	body_mesh.visible = third_person
	var tween := create_tween().set_parallel(true)
	tween.tween_property(spring_arm, "spring_length", third_person_dist if third_person else 0.0, 0.25)
	tween.tween_property(camera, "h_offset", third_person_shoulder if third_person else 0.0, 0.25)
	tween.tween_property(camera, "v_offset", third_person_height if third_person else 0.0, 0.25)


func add_kill() -> void:
	kills += 1
	_update_kills_label()
func _update_kills_label() -> void:
	kills_label.text = "Kills %d" % kills

func _physics_process(delta: float) -> void:
#	if global_position.distance_to(last_pos) > 1.0:
#		print('player jumped: ', last_pos, ' -> ', global_position, " at ", Time.get_ticks_msec(), " ms")
	last_pos = global_position
	
	if Input.is_action_just_pressed('reload'):
		gun._reload()
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
