extends StaticBody3D

class_name Door

# Called when the node enters the scene tree for the first time.
var is_open: bool = false
var initial_rotation: float = 0.0

func _ready() -> void:
	add_to_group("doors")
	print( rotation_degrees.y)
	initial_rotation = rotation_degrees.y
	print(initial_rotation)
	
func toggle_open() -> void:
	if is_open:
		# Close the door by rotating back to the initial position
		rotation_degrees.y = initial_rotation - 90
		is_open = false
	else:
		# Open the door by rotating 90 degrees from the initial position
		rotation_degrees.y = initial_rotation
		is_open = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
