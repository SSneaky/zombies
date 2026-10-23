extends Node3D


@export var zombie_scene: PackedScene
@export var max_zombies: int = 10
@export var min_spawn_distance: float = 8.0

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_spawn_zombie)

func _spawn_zombie() -> void:
	if get_tree().get_nodes_in_group("opps").size() >= max_zombies:
		return
	var player := get_tree().get_first_node_in_group('player') as Node3D
	var points := get_children().filter(func(n): 
		return n is Marker3D and (player == null or n.global_position.distance_to(player.global_position) > min_spawn_distance))
	if points.is_empty():
		return
	var point: Marker3D = points.pick_random()
	#prints new zombie vs player pos print("spawning at ", point.global_position, " | player at ", get_tree().get_first_node_in_group("player").global_position)
	var zombie: Node3D = zombie_scene.instantiate()
	get_parent().add_child(zombie)
	zombie.global_position = point.global_position



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
