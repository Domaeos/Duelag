extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner

func _ready():
	# Configure multiplayer spawner
	multiplayer_spawner.spawn_function = spawn_player
	
	# Only the server should spawn players
	_authenticate_game_enter()

@rpc("authority", "call_local")
func spawn_player(name, player_info):
	var player = preload("res://player.tscn").instantiate()
	player.name = name
	
	# Set player name (optional)
	if player.has_method("set_player_name"):
		player.set_player_name(player_info.get("name", "Unnamed"))
	
	multiplayer_spawner.add_child(player, true)
	return player
	
@rpc
func _authenticate_game_enter():
	pass
