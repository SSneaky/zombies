extends CharacterBody3D

@export var damage: int = 10
@export var attack_cooldown: float = 1.0
@export var speed: float = 3.0

@onready var attack_area: Area3D = $AttackArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var health: Health = $Health
@onready var mesh: MeshInstance3D = $MeshInstance3D


var player_in_range: Node3D = null
var cooldown_left: float = 0.0
var hurt_material := StandardMaterial3D.new()

func _ready() -> void:
	health.died.connect(_on_died)
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_on_body_excited)
	hurt_material.albedo_color = Color.WHITE
	health.health_changed.connect(_on_hurt)

func _on_hurt(_current: int, _maximum: int) -> void:
	mesh.material_overlay = hurt_material
	await get_tree().create_timer(0.1).timeout
	mesh.material_overlay = null 

#attack logic
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		#print("entered: ", body.name, " in player group: ", body.is_in_group("player"))
func _on_body_excited(body: Node3D) -> void:
	if body == player_in_range:
		player_in_range = null

func _on_died() -> void:
	if player:
		player.add_kill()
	queue_free()

func _physics_process(delta: float) -> void:
	cooldown_left -= delta
	
	if player == null:
		return
	
	if player_in_range and cooldown_left <= 0.0:
		player_in_range.get_node("Health").take_damage(damage) 
		cooldown_left = attack_cooldown
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	nav_agent.target_position = player.global_position
	var next_pos := nav_agent.get_next_path_position()
	var dir := next_pos - global_position
	dir.y = 0
	dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
	
	move_and_slide()
