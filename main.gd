extends Node

var arguments = {}
const PORT = 9999

var peer = ENetMultiplayerPeer.new()

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
	var result = peer.create_client("127.0.0.1", PORT)
	if result != OK:
		print("Failed to create client connection: ", result)
		return
	
	multiplayer.multiplayer_peer = peer

func _setup_server():
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

func on_peer_disconnected(id: int):
	print("Peer ", id, " has disconnected from the server")
	var character = get_node_or_null(str(id))
	if character:
		character.queue_free()
