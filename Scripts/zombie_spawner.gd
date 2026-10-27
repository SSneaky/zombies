extends Node3D

signal wave_started(wave: int)
signal remaining_changed(remaining: int)
signal break_tick(seconds: int)

@export var zombie_scene: PackedScene
@export var max_zombies: int = 10
@export var min_spawn_distance: float = 8.0
@export var first_wave_size: int = 5
@export var wave_growth: int = 3
@export var spawn_interval: float = 1.5
@export var break_seconds: int = 8
@export var health_growth: float = 0.1

@onready var timer: Timer = $Timer

var wave: int = 0
var to_spawn: int = 0
var remaining: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.one_shot = false
	timer.timeout.connect(_spawn_zombie)
	_start_break.call_deferred()

func _start_break() -> void:
	for t in range(break_seconds, 0, -1):
		break_tick.emit(t)
		await get_tree().create_timer(1.0, false).timeout
	_start_wave()

func _start_wave() -> void:
	wave += 1
	to_spawn = first_wave_size + (wave - 1) * wave_growth
	wave_started.emit(remaining)
	timer.start(spawn_interval) 

func _spawn_zombie() -> void:
	if to_spawn <= 0:
		timer.stop()
		return
	if get_tree().get_nodes_in_group("opps").size() >= max_zombies:
		return
	var player := get_tree().get_first_node_in_group('player') as Node3D
	var points := get_children().filter(func(n):
		return n is Marker3D and (player == null or n.global_position.distance_to(player.global_position) > min_spawn_distance))
	if points.is_empty():
		return
	var point: Marker3D = points.pick_random()
	var world := get_parent() as Node3D
	var zombie: Node3D = zombie_scene.instantiate()
	zombie.position = world.to_local(point.global_position)
	
	var zombie_health: Health = zombie.get_node("Health")
	zombie_health.max_health = int(zombie_health.max_health *(1.0 + health_growth * (wave - 1)))
	zombie_health.died.connect(_on_zombie_died)
	
	world.add_child(zombie)
	to_spawn -= 1
	if to_spawn <= 0:
		timer.stop()

func _on_zombie_died() -> void:
	remaining -= 1
	remaining_changed.emit(remaining)
	if remaining <= 0:
		_start_break()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
