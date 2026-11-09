extends Node

signal host_created

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer = SteamMultiplayerPeer

func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_join_requested)

func _process(delta: float) -> void:
	Steam.run_callbacks()

func host_lobby() -> void:
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS)

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
