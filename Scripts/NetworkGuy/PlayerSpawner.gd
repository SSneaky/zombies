extends Node

const PLAYER = preload("uid://brfankd6hskx1")

var players: Array[CharacterBody3D]

func _ready() -> void:
	NetworkGuy.host_created.connect(_on_host_created)
	UIGuy.map_changed.connect(_on_map_changed)

func _on_map_changed(path: String) -> void:
	if path != UIGuy.start_path:
		for p in NetworkGuy.get_party():
			spawn_player(1)

func _on_host_created() -> void:
	#spawn_player(multiplayer.get_unique_id())
	#multiplayer.peer_connected.connect(spawn_player)
	pass

func spawn_player(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	var new_player := PLAYER.instantiate() as CharacterBody3D
	new_player.name = str(peer_id)
	new_player.position = Vector3.ZERO
	$SpawnPoint.add_child(new_player)
	initialize_player(new_player)

func initialize_player(player: CharacterBody3D) -> void:
	for other in players:
		player.add_collision_exception_with(other)
		other.add_collision_exception_with(player)
	players.append(player)

#multiplayer logic, idk where to put it
func _on_multiplayer_spawned(node: Node) -> void:
	if node is CharacterBody3D:
		initialize_player(node)
