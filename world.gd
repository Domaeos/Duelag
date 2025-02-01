extends Node3D

@onready var player_spawner = $PlayerSpawn
@onready var death_menu = get_parent().get_node_or_null("DeathMenu")
var player_scene = preload("res://player.tscn")

# Constants for connection handling
const MAX_SPAWN_ATTEMPTS = 3
const SPAWN_RETRY_DELAY = 1.0
const INITIAL_SYNC_DELAY = 0.5

# Track spawn attempts and connected players
var spawn_attempts = {}
var player_ready = {}

func _ready() -> void:
	await get_tree().create_timer(INITIAL_SYNC_DELAY).timeout
	if not multiplayer.is_server():
		await attempt_connection()
		
	if multiplayer.has_multiplayer_peer():
		_on_network_ready()
		
	if multiplayer.is_server():
		DisplayServer.window_set_title("Server")
	else:
		DisplayServer.window_set_title("Client " + str(multiplayer.get_unique_id()))

func _on_network_ready():
	var gridmap = get_node_or_null("GridMap")
	if gridmap and gridmap.has_method("setup_networking"):
		gridmap.setup_networking()
		
func attempt_connection():
	while not multiplayer.has_multiplayer_peer():
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(0.5).timeout
	
	var server_connection = multiplayer.multiplayer_peer.get_peer(1)
	var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
	await get_tree().create_timer(latency).timeout
	
	if multiplayer.has_multiplayer_peer():
		rpc_id(1, "sync_world")
		request_spawn()

func request_spawn():
	
	if not multiplayer.has_multiplayer_peer():
		await get_tree().create_timer(0.5).timeout
		request_spawn()
		return
		
	var player_id = multiplayer.get_unique_id()
	if not spawn_attempts.has(player_id):
		spawn_attempts[player_id] = 0
	
	if spawn_attempts[player_id] < MAX_SPAWN_ATTEMPTS:
		spawn_attempts[player_id] += 1
		rpc_id(1, "add_player")
	else:
		push_error("Failed to spawn player after maximum attempts")

func _on_multiplayer_spawner_spawned(node: Node):
	# Ensure the node exists and has the correct name format
	if not is_instance_valid(node) or not str(node.name).is_valid_int():
		return
		
	var player_id = int(str(node.name))
	
	node.rpc("setup_multiplayer", player_id)
	node.input_control.rpc("setup_multiplayer", player_id)
	player_ready[player_id] = true
	
	if multiplayer.is_server():
		rpc_id(player_id, "confirm_spawn")

@rpc("any_peer", "call_local")
func sync_world():
	var player_id = multiplayer.get_remote_sender_id()
	get_tree().call_group("Sync", "set_visibility_for", player_id, true)

@rpc("any_peer", "call_remote")
func add_player():
	var player_id = multiplayer.get_remote_sender_id()
	
	if player_spawner.has_node(str(player_id)):
		rpc_id(player_id, "confirm_spawn")
		return
	
	var player = player_scene.instantiate()
	player.name = str(player_id)
	player_spawner.add_child(player, true)
	player.input_control.set_multiplayer_authority(player_id)
	Global.active_players[player.name] = player

	rpc_id(player_id, "add_my_player_to_global")
	rpc_id(player_id, "confirm_spawn")

@rpc("authority", "call_local", "reliable", 5)
func add_my_player_to_global():
	var player_node = player_spawner.get_node(str(multiplayer.get_unique_id()))
	if player_node:
		Global.my_player = player_node

@rpc("authority", "call_local")
func confirm_spawn():
	var player_id = multiplayer.get_unique_id()
	spawn_attempts.erase(player_id)

@rpc("authority")
func show_death_menu(): 
	death_menu.show_menu()

@rpc("authority")
func hide_death_menu():
	death_menu.hide()

@rpc("any_peer")
func resurrect_player():
	var player_id = multiplayer.get_remote_sender_id()
	var player = Global.active_players[str(player_id)]
	player.current_health = player.max_health
	player.current_mana = 100
	player.set_process(true)
	player.set_physics_process(true)
	rpc_id(player_id, "hide_death_menu")
