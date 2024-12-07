extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_parent()
	
	if not player or int(str(player.name)) != multiplayer.get_unique_id(): 
		set_process(false)
		hide()
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
