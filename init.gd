extends Node3D

@export_file("*.tscn") var server_scene
@export_file("*.tscn") var client_scene

var arguments = {}
var peer
const PORT = 9999

func setup_client_with_retry():
	var max_attempts = 10
	var attempt = 0
	
	while attempt < max_attempts:
		var result
		if OS.has_feature("web"):
			peer = WebSocketMultiplayerPeer.new()
			result = peer.create_client("ws://0.0.0.0:" + str(PORT))
		else:
			peer = ENetMultiplayerPeer.new()
			result = peer.create_client("127.0.0.1", PORT)
		
		if result == OK:
			multiplayer.multiplayer_peer = peer
			print("Connected to server, id: ", multiplayer.get_unique_id())
			return
		
		attempt += 1
		print("Connection attempt failed. Retrying...")
		await get_tree().create_timer(2.0).timeout  # Wait 2 seconds before retry
	
	print("Failed to connect to server after ", max_attempts, " attempts")
	
func _ready() -> void:
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	if "server" in arguments:
		call_deferred("_change_scene", server_scene)
	else:
		setup_client_with_retry()
		call_deferred("_change_scene", client_scene)
	
func _change_scene(scene_file: String):
	get_tree().change_scene_to_file(scene_file)
