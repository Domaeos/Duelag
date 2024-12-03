extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner

func _ready():
	if not multiplayer.is_server():
		var server_connection = multiplayer.multiplayer_peer.get_peer(1)
		var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
		await get_tree().create_timer(latency).timeout
		rpc_id(1, "_authenticate_game_enter", Authentication.user.name, Authentication.user.token)
		rpc_id(1, "spawn_player")

@rpc 
func spawn_player():
	pass
	
@rpc("any_peer", "call_local")
func sync_world():
	pass

@rpc
func _authenticate_game_enter(name, token):
	pass


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("A PLAYER HAS SPAWNED: ", node.name)
