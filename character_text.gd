extends Sprite3D
@export var char_label: RichTextLabel
@export var max_messages:= 3

var text_label = preload("res://floating_label.tscn")
@onready var container = $SubViewport/Container
@onready var private_label = preload("res://floating_label_private.tscn")

func _on_player_show_text(message: String, private: bool = false, receiver: int = 0) -> void:
	if not private:
		rpc("broadcast_speech", message)
	else:
		rpc_id(receiver, "broadcast_speech", message, true)

@rpc("call_local")
func broadcast_speech(message: String, private = false):
	var text_node
	if private:
		text_node = private_label.instantiate()
	else:	
		text_node = text_label.instantiate()

	text_node.text = message
	container.add_child(text_node)
