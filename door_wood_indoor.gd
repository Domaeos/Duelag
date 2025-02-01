extends Door


var door_collision: CollisionShape3D

func _ready() -> void:
	super._ready()
	door_area = get_node_or_null("Area3D")
	door_collision = door_area.get_node_or_null("CollisionShape3D")
	door_collision.disabled = false
