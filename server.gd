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
	
	# Ensure this node persists across scene changes
	process_mode = Node.PROCESS_MODE_ALWAYS

	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(id: int):
	print("Peer ", id, " has connected to the server")

func on_peer_disconnected(id: int):
	print("Peer ", id, " has disconnected from the server")
	if id in authenticated_players:
		delete_authenticated_player(id)

@rpc("any_peer", "call_local")
func authenticate_player(player_name: String):
	var sender_id = multiplayer.get_remote_sender_id()
	print("Authentication request received from ", sender_id, " for name: ", player_name)
	
	# Basic authentication
	if player_name.strip_edges() != "":
		# Store player information
		authenticated_players[sender_id] = {
			"name": player_name,
			"id": sender_id
		}
		
		# Send authentication success back to client
		rpc_id(sender_id, "receive_authentication_result", true)
		print("Player authenticated: ", player_name)
	else:
		rpc_id(sender_id, "receive_authentication_result", false)

func delete_authenticated_player(id: int):
	if id in authenticated_players:
		print("Removing player: ", authenticated_players[id]["name"])
		authenticated_players.erase(id)
