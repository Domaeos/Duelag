extends Door

var door_collision: CollisionShape3D

func _ready() -> void:
	door_area = get_node("Door_B2/Area3D")
	door_collision = door_area.get_node("CollisionShape3D")
	door_collision.disabled = false
	super._ready()

func _on_overlap_exited(body: Node3D) -> void:
	door_collision.disabled = false

func on_overlap_entered(body: Node3D) -> void:
	door_collision.disabled = true
