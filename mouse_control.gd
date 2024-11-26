extends Control

var movement:= false
var direction: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_use_accumulated_input(true)

func _process(delta: float) -> void:
	pass
	
func _gui_input(event: InputEvent) -> void:
	if InputEventMouse:
		if InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return

func handle_mouse_press():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			movement = true
			var player_3d_position = global_position
			var camera = get_viewport().get_camera_3d()
			var mouse_positon = get_viewport().get_mouse_position()
			var player_screen_position = camera.unproject_position(player_3d_position)
			var vector : Vector2 = (mouse_positon - player_screen_position).normalized()
			calculate_direction_from_angle(rad_to_deg(vector.angle()))
	else:
			movement = false
	
func calculate_direction_from_angle(angle: float) -> Vector3:
	angle = fmod(angle + 360.0, 360.0)  # Normalize angle to [0, 360)
	
	# Create the direction vector based on the angle
	if angle < 22.5 or angle >= 337.5:  # Right
		return Vector3(0, 0, -1)  # Originally "up"
	elif angle < 67.5:  # Down-Right
		return Vector3(1, 0, -1).normalized()
	elif angle < 112.5:  # Down
		return Vector3(1, 0, 0)  # Originally "right"
	elif angle < 157.5:  # Down-Left
		return Vector3(1, 0, 1).normalized()
	elif angle < 202.5:  # Left
		return Vector3(0, 0, 1)  # Originally "down"
	elif angle < 247.5:  # Up-Left
		return Vector3(-1, 0, 1).normalized()
	elif angle < 292.5:  # Up
		return Vector3(-1, 0, 0)  # Originally "left"
	elif angle < 337.5:  # Up-Right
		return Vector3(-1, 0, -1).normalized()
	
	return Vector3.ZERO  # Default fallback, should not be reached
