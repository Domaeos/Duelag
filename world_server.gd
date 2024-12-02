extends Node3D

const PORT = 9999
var peer = ENetMultiplayerPeer.new()

var authenticated_players = {}

func _ready() -> void:
	# Create the server
	var result = peer.create_server(PORT)
	if result != OK:
		print("Failed to create server on port ", PORT)
		return
	
	multiplayer.multiplayer_peer = peer
	print("SERVER CREATED ON PORT ", PORT)
	print("SERVER ID IS: ", multiplayer.get_unique_id())
	
	# Connect to peer connection signals
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(id: int):
	print("Peer ", id, " has connected to the server")

func on_peer_disconnected(id: int):
	print("Peer ", id, " has disconnected from the server")

@rpc("any_peer", "call_local")
func _authenticate_game_enter(name, token):
	print("ZZZZZZSSSSSSSSSSSSSSSSSSSSSSSSSSsZZ")
	print("Authentication rpc called in server")
	if name in authenticated_players:
		if authenticated_players[name] == token:
			rpc_id(multiplayer.get_remote_sender_id(), "spawn_player", name)
		else:
			print("No token match")
	else:
		print("Name not in authenticated users")	
		
@rpc	
func spawn_player(name):
	pass

@rpc
func sync_world():
	pass
