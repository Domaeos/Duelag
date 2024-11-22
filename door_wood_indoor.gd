extends Door


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door_area = get_node("Door_A2/Area3D")
	super._ready()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
