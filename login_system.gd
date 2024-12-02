# LoginSystem.gd
extends Control

@onready var peer = ENetMultiplayerPeer.new()
@export_file("*.tscn") var game_scene
@onready var name_input: TextEdit = $Name

func _ready() -> void:
	# Verify the correct node path for the name input
	if not name_input:
		print("ERROR: Name input node not found!")
		return

	# Create a client and attempt to connect
	var result = peer.create_client("127.0.0.1", 9999)
	if result != OK:
		print("Failed to create client connection: ", result)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Attempting to connect to seremotever...")
	
	# Connect to connection status signals
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)

func on_connected_to_server():
	print("Successfully connected to server!")
	print("CLIENT ID IS: ", multiplayer.get_unique_id())

func on_connection_failed():
	print("Failed to connect to server")

func _on_enter_pressed() -> void:
	print("ENTER PRESSED, sending RPC")
	print("Entered Name: ", name_input.text)
	
	# Verify connection and send RPC
	if multiplayer.get_multiplayer_peer() == peer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		# Ensure the name is not empty
		print("Connected and sending")
		if name_input.text.strip_edges() != "":
			rpc_id(1, "receive_name", name_input.text)
		else:
			print("Name input is empty!")
	else:
		print("Not connected to server!")
		
@rpc("call_remote")
func receive_name():
	pass

@rpc("authority", "call_local")
func authentication_status(result, token):
	if result == 200:
		print("Successful login with token: ", token)
		Authentication.user["name"] = name_input.text
		Authentication.user["token"] = token
		
		get_tree().change_scene_to_file(game_scene)
	elif result == 400:
		print("Name taken")
	else:
		print("Something went wrong")
