extends Node3D
# Explicitly register RPC function

@rpc("any_peer", "call_local")
func receive_name(user_name: String):
	print("SERVER: Received name - ", user_name)
	print("Sender ID: ", multiplayer.get_remote_sender_id())
	authenticate_player(user_name, multiplayer.get_remote_sender_id())
	
func authenticate_player(name, id):
	var token = randi()
	get_parent().authenticated_players[name] = token
	rpc_id(id, "authentication_status", 200, token)
	
@rpc("call_remote")
func authentication_status():
	pass
