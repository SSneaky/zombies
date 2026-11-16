extends Node

const PLAYER = preload("uid://brfankd6hskx1")

var players: Array[CharacterBody3D]
var loaded: Array[int] = []
var host_loaded := false

func _ready() -> void:
	UIGuy.map_changed.connect(_on_map_changed)

func _on_map_changed(path: String) -> void:
	players.clear()
	loaded.clear()
	host_loaded = false
	if path == UIGuy.start_path:
		return
	var spawner: MultiplayerSpawner = await _get_spawner(path)
	if spawner == null:
		push_error("map has no spawner, dickhead")
		return
	spawner.spawned.connect(_on_multiplayer_spawned)
	if multiplayer.is_server():
		host_loaded = true
		_check_all_loaded()
	else:
		_report_loaded.rpc_id(1)

func _get_spawner(path: String) -> MultiplayerSpawner:
	for i in 120:
		await get_tree().process_frame
		var scene := get_tree().current_scene
		if scene and scene.scene_file_path == path:
			return get_tree().get_first_node_in_group(&"MPspawner") as MultiplayerSpawner
	return null
	

@rpc("any_peer", "call_remote", "reliable")
func _report_loaded() -> void:
	if not multiplayer.is_server():
		return
	loaded.append(multiplayer.get_remote_sender_id())
	_check_all_loaded()

func _check_all_loaded() -> void:
	if not host_loaded:
		return
	for id in multiplayer.get_peers():
		if id not in loaded:
			return
	host_loaded = false
	spawn_player(multiplayer.get_unique_id())
	for id in multiplayer.get_peers():
		spawn_player(id)

func spawn_player(peer_id: int) -> void:
	var spawner := get_tree().get_first_node_in_group(&"MPspawner") as MultiplayerSpawner
	var new_player := PLAYER.instantiate() as CharacterBody3D
	new_player.name = str(peer_id)
	new_player.position = Vector3.ZERO
	spawner.get_node(spawner.spawn_path).add_child(new_player, true)
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
