extends Node

var arguments = {}
const PORT = 9999

var peer
var args = OS.get_cmdline_args()

func _ready() -> void:
	for arg in args:
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]

	if "server" in arguments:
		_setup_server()

func _setup_server():
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(PORT)
	if result != OK:
		print_verbose("Failed to create server on port ", PORT)
		return
	else:
		print_verbose("Server running on port: ", PORT)

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
func on_peer_connected(id: int):
	print_verbose("Peer ", id, " has connected to the server")

func on_peer_disconnected(id: int):
	print_verbose("Peer ", id, " has disconnected from the server")
	var character = get_node_or_null(str(id))
	if character:
		character.queue_free()
		remove_child(character) 
	
