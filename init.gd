extends Control

@export_file("*.tscn") var server_scene
@export_file("*.tscn") var client_scene

@onready var client_button = $ClientButton
@onready var server_button = $ServerButton

var arguments = {}

func _ready():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	print(arguments)
	if "server" in arguments:
		get_tree().change_scene_to_file(server_scene)
	else:
		get_tree().change_scene_to_file(client_scene)
