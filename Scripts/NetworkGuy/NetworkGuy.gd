extends Node

signal host_created
signal party_changed
signal party_left

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer = SteamMultiplayerPeer
var lobby_id = 0

func _ready() -> void	:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_join_requested)
	Steam.lobby_chat_update.connect(func(_l, _c, _m, _s): party_changed.emit())
	Steam.lobby_data_update.connect(func(_s, _l, _m): party_changed.emit())

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func _on_lobby_created(result: int, new_lobby_id: int):
	if result == Steam.RESULT_OK:
		lobby_id = new_lobby_id
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()
		party_changed.emit()

func _on_lobby_joined(joined_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = joined_id
		party_changed.emit()
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(joined_id))
		multiplayer.multiplayer_peer = peer

func _on_join_requested(requested_id: int, _steam_id: int) -> void:
	if lobby_id != 0:
		leave_party()
	Steam.joinLobby(requested_id)
	
func host_lobby() -> void:
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS)

func get_party() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in Steam.getNumLobbyMembers(lobby_id):
		var id := Steam.getLobbyMemberByIndex(lobby_id, i)
		out.append({
			"steam_id": id,
			"name": Steam.getFriendPersonaName(id),
			"ready": Steam.getLobbyMemberData(lobby_id, id, "ready") == "1",
			"is_host": id == Steam.getLobbyOwner(lobby_id)
		})
	return out

func set_ready(value: bool) -> void:
	Steam.setLobbyMemberData(lobby_id,"ready", "1" if value else "0")

func leave_party() -> void:
	if lobby_id == 0:
		return
	Steam.leaveLobby(lobby_id)
	lobby_id = 0
	multiplayer.multiplayer_peer = null
	party_left.emit()

func start_game(path: String) -> void:
	if not multiplayer.is_server():
		return
	Steam.setLobbyJoinable(lobby_id, false)
	_load_map.rpc(path)

@rpc("authority", "call_local", "reliable")
func _load_map(path: String) -> void:
	UIGuy.change_map(path)
