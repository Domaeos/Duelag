extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var server_node = get_node("/root/Server")  # Assuming Server is at root

func _ready():
	# Configure multiplayer spawner
	multiplayer_spawner.spawn_function = spawn_player
	
	# Only the server should spawn players
	if multiplayer.is_server():
		spawn_local_player()

func spawn_local_player():
	# Get the local player's information from the server
	var local_peer_id = multiplayer.get_unique_id()
	var player_info = server_node.authenticated_players.get(local_peer_id, {})
	
	if player_info:
		spawn_player(local_peer_id, player_info)

func spawn_player(peer_id, player_info):
	# Instantiate player scene
	var player = preload("res://player.tscn").instantiate()
	player.name = str(peer_id)  # Use peer ID as node name
	
	# Set player name (optional)
	if player.has_method("set_player_name"):
		player.set_player_name(player_info.get("name", "Unnamed"))
	
	# Add to scene
	multiplayer_spawner.add_child(player, true)
	return player
