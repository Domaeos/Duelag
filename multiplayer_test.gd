extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner

func _ready():
	if not multiplayer.is_server():
		multiplayer_spawner.spawn_function = spawn_player
		var server_connection = multiplayer.multiplayer_peer.get_peer(1)
		var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
		await get_tree().create_timer(latency).timeout
		rpc_id(1, "_authenticate_game_enter", Authentication.user.name, Authentication.user.token)
		#rpc_id(1, "sync_world")
		rpc_id(1, "spawn_player")
		
#@rpc("any_peer", "call_local")
#func sync_world():
	#var player_id = multiplayer.get_remote_sender_id()
	#get_tree().call_group("Sync", "set_visibility_for", player_id, true)

@rpc("authority", "call_local")	# Defer the scene change
func spawn_player(name):
	var id = multiplayer.get_unique_id()
	var player_scene = preload("res://player.tscn")
	var player = $PlayerSpawn.spawn(player_scene)
	player.camera.current = true
	player.set_multiplayer_authority(id)

#@rpc("authority", "call_local")
#func setup_player(player_id):
	#var self_id = multiplayer.get_unique_id()
	#var is_player = self_id == player_id
	##set_process(is_player)
	##set_physics_process(is_player)
	#camera.enabled = is_player
	#if is_player:
		#camera.make_current()

@rpc
func _authenticate_game_enter(name, token):
	pass
