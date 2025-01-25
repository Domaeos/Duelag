extends Node3D

@export_file("*.tscn") var server_scene
@export_file("*.tscn") var client_scene

var arguments = {}

func _ready() -> void:
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	if "server" in arguments:
		call_deferred("_change_scene", server_scene)
	else:
		call_deferred("_change_scene", client_scene)

func _change_scene(scene_file: String):
	get_tree().change_scene_to_file(scene_file)
