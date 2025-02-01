extends Node3D

class_name Door

@export var door_area: Area3D
@export var door_collision: CollisionShape3D
var door_path

var is_open: bool = false
var initial_rotation: float

func _ready() -> void:
	add_to_group("doors")
	door_area = get_node_or_null("Area3D")
	door_collision = door_area.get_node_or_null("CollisionShape3D")
	set_multiplayer_authority(1)  
	if multiplayer.is_server():
		door_path = get_path()
		initial_rotation = rotation_degrees.y
		door_area.connect("body_entered", Callable(self, "_on_body_entered"))
		door_area.connect("body_exited", Callable(self, "_on_body_exited"))

@rpc("any_peer", "call_local")
func toggle_open() -> void:
	if multiplayer.is_server():
		if is_open:
			rotation_degrees.y = initial_rotation - 90
			is_open = false
		else:
			rotation_degrees.y = initial_rotation
			is_open = true

func _on_body_entered(body: Node3D) -> void:
	if body is can_be_damaged and body.door_in_range != door_path:
		print(body, " entered door wood")
		print("path is: ", door_path)
		body.door_in_range = door_path
		print("body door in range: ", body.door_in_range)

func _on_body_exited(body: Node3D) -> void:
	if body is can_be_damaged:
		if body.door_in_range == door_path:
			body.door_in_range = null
