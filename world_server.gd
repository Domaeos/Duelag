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
	# Connect to peer connection signals
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(id: int):
	print("Peer ", id, " has connected to the server")

func on_peer_disconnected(id: int):
	print("Peer ", id, " has disconnected from the server")

@rpc("any_peer", "call_local")
func _authenticate_game_enter(name, token):
	if name in authenticated_players:
		if authenticated_players[name] == token:
			rpc_id(multiplayer.get_remote_sender_id(), "spawn_player", name)
		else:
			print("No token match")
	else:
		print("Name not in authenticated users")
		
@rpc("any_peer", "call_remote")
func spawn_player():
	var player_id = multiplayer.get_remote_sender_id()
	var player = preload("res://player.tscn").instantiate()
	player.name = str(player_id)
	$PlayerSpawn.add_child(player)
	player.set_multiplayer_authority(player_id)

	#player.rpc("client_setup_player", player_id)
	#player.camera.current = true
	#player.set_multiplayer_authority(id)


@rpc("any_peer", "call_local")
func sync_world():
	var player_id = multiplayer.get_remote_sender_id()
	get_tree().call_group("Sync", "set_visibility_for", player_id, true)


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("A PLAYER HAS SPAWNED")
