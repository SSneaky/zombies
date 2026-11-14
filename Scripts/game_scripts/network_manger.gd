extends Node

signal host_created
signal party_changed
signal part_left

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer = SteamMultiplayerPeer
var lobby_id = 0

func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_join_requested)

func _process(delta: float) -> void:
	Steam.run_callbacks()

func _on_lobby_created(connect: int, lobby_id: int):
	if connect == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()

func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer

func _on_join_requested(lobby_id: int, steam_id: int) -> void:
	Steam.joinLobby(lobby_id)
	
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
	part_left.emit()
