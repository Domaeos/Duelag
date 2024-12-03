extends Node

var arguments = {}
@onready var player_spawner = $World/PlayerSpawn
const PORT = 9999

func _ready() -> void:
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]

	if "server" in arguments:
		_setup_server()
	else:
		_setup_client()

func _setup_client():
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client("127.0.0.1", PORT)
	if result != OK:
		print("Failed to create client connection: ", result)
		return
	
	multiplayer.multiplayer_peer = peer

func _setup_server():
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(PORT)
	if result != OK:
		print("Failed to create server on port ", PORT)
		return
	else:
		print("Server running on port: ", PORT)

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
func on_peer_connected(id: int):
	print("Peer ", id, " has connected to the server")
	var player = preload("res://player.tscn").instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	player_spawner.add_child(player)
	rpc_id(id, "spawn_player", id)

@rpc("call_local")
func spawn_player(player_id):
	var player = preload("res://player.tscn").instantiate()
	player.name = str(player_id)
	player_spawner.add_child(player)
	player.rpc("client_setup_player", player_id)
	rpc_id(1, "_sync_world", player_id)

@rpc("authority", "call_local")
func _sync_world(id):
	get_tree().call_group("Sync", "set_visibility_for", id, true)

func on_peer_disconnected(id: int):
	print("Peer ", id, " has disconnected from the server")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
