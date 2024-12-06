extends Sprite3D
@export var char_label: RichTextLabel
@export var max_messages:= 3

var text_label = preload("res://floating_label.tscn")
@onready var container = $SubViewport/Container

func _on_player_show_text(message: String) -> void:
	rpc("broadcast_speech", message)

@rpc("call_local")
func broadcast_speech(message: String):
	var text_node = text_label.instantiate()
	text_node.text = message
	container.add_child(text_node)
