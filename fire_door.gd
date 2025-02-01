extends Door

func _ready() -> void:
	super._ready()
#
#func _on_overlap_exited(body: Node3D) -> void:
	#door_collision.set_deferred("disabled", false)  # Use set_deferred to modify during physics flush
#
#func on_overlap_entered(body: Node3D) -> void:
	#door_collision.set_deferred("disabled", true)  # Use set_deferred to avoid flushing query issues
