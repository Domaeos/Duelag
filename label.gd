extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_update_label")
	

func _update_label():
	if multiplayer.is_server():
		text = "SERVER"
