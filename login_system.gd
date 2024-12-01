extends Control

signal player_authenticated(player_name)

@onready var peer = ENetMultiplayerPeer.new()
@onready var name_input: TextEdit = $Name

func _ready() -> void:
	# Restore the connection signals
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)

	# Create client connection
	var result = peer.create_client("127.0.0.1", 9999)
	if result != OK:
		print("Failed to create client connection: ", result)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Client attempting to connect...")

func on_connected_to_server():
	print("Successfully connected to server!")

func on_connection_failed():
	print("Failed to connect to server")

func _on_enter_pressed() -> void:
	print("Enter pressed")
	
	# Verify connection status
	if multiplayer.get_multiplayer_peer() == peer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if name_input.text.strip_edges() != "":
			print("Sending authentication request")
			rpc_id(1, "authenticate_player", name_input.text)
		else:
			print("Name input is empty!")
	else:
		print("Not connected to server")

@rpc
func authenticate_player():
	pass
# This RPC must be defined to receive the server's response
@rpc("any_peer", "call_local")
func receive_authentication_result(success: bool):
	print("Authentication result received: ", success)
	if success:
		# Transition to multiplayer scene
		get_tree().change_scene_to_file("res://multiplayer_test.tscn")
