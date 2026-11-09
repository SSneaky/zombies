extends Node3D

const PLAYER = preload("uid://brfankd6hskx1")

var players: Array[CharacterBody3D]

func _ready() -> void:
	NetworkManger.host_created.connect(_on_host_created)

func _on_host_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(peer_id: int) -> void:
	var new_player := PLAYER.instantiate() as CharacterBody3D
	new_player.name = str(peer_id)
	add_child(new_player)
	initialize_player(new_player)

func initialize_player(player: CharacterBody3D) -> void:
	player.position = $SpawnPoint.position
	for other in players:
		player.add_collision_exception_with(other)
	players.append(player)

#multiplayer logic, idk where to put it
func _on_multiplayer_spawned(node: Node) -> void:
	if node is CharacterBody3D:
		initialize_player(node)
