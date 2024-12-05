extends Node3D

@onready var player_spawner = $PlayerSpawn
var player_scene = preload("res://player.tscn")

var active_players = {}

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout

	if not multiplayer.is_server():
		var server_connection = multiplayer.multiplayer_peer.get_peer(1)
		var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
		await get_tree().create_timer(latency).timeout
		rpc_id(1, "sync_world")
		rpc_id(1, "add_player")


func _on_multiplayer_spawner_spawned(node: Node):
	node.rpc("setup_multiplayer", int(str(node.name)))

@rpc("any_peer", "call_local")
func sync_world():
	var player_id = multiplayer.get_remote_sender_id()
	get_tree().call_group("Sync", "set_visibility_for", player_id, true)

@rpc("any_peer", "call_remote")
func add_player():
	var player_id = multiplayer.get_remote_sender_id()
	var player = player_scene.instantiate()
	player.name = str(player_id)
	player_spawner.add_child(player, true)
	active_players[player.name] = player

@rpc("any_peer", "call_remote")
func cast_spell(target):
	print(active_players[target])
	
@rpc("authority")
func set_players_door(door):
	var player = get_parent().find_child(str(multiplayer.get_remote_sender_id()))
	print("setting door for player: ", player)

#@rpc("any_peer", "call_remote")
#func show_effect(target_id, spell: String):
	#var target = active_players[str(target_id)]
	#var spell_information = Global.spelldictionary[spell]
	#
	#target.spell_node.position = spell_information.position
	#target.spell_node.scale = spell_information.scale
	#target.spell_node.show()
	#
	#target.spell_emitter.play(spell_information.animation)
