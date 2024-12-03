extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#print("READY HERE: ", multiplayer.get_unique_id())
	#if not multiplayer.is_server():
		#print("READY FOR: ", get_multiplayer_authority())
		#var server_connection = multiplayer.multiplayer_peer.get_peer(1)
		#var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
		#await get_tree().create_timer(latency).timeout
		#rpc_id(1, "create_player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
